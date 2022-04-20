local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Blizz
local GetTime = _G.GetTime

-- Mine
E.Cooldowns = {}
local handledCooldowns = {}
local activeCooldowns = {}

local defaults = {
	exp_threshold = 5, -- [1; 10]
	m_ss_threshold = 0, -- [91; 3599]
	s_ms_threshold = 5, -- [1; 10]
	swipe = {
		enabled = true,
		reversed = false,
	},
	text = {
		enabled = true,
		size = 12,
		v_alignment = "MIDDLE",
	},
}

local updater  = CreateFrame("Frame", "LSCooldownUpdater")
local updateTime = 0
local time1, time2, format, color

updater:SetScript("OnUpdate", function(_, elapsed)
	updateTime = updateTime + elapsed
	if updateTime >= 0.1 then
		for cooldown, expiration in next, activeCooldowns do
			if cooldown:IsVisible() and cooldown.Timer:IsVisible() then
				local remain = expiration - GetTime()
				if remain <= 0 then
					cooldown.Timer:SetText("")
					activeCooldowns[cooldown] = nil
					return
				end

				color = C.db.global.colors.white

				if remain >= 86400 then
					time1, time2, format = E:SecondsToTime(remain, "abbr")
					color = C.db.global.colors.cooldown.day
				elseif remain >= 3600 then
					time1, time2, format = E:SecondsToTime(remain, "abbr")
					color = C.db.global.colors.cooldown.hour
				elseif remain >= 60 then
					if cooldown.config.m_ss_threshold == 0 or remain > cooldown.config.m_ss_threshold then
						time1, time2, format = E:SecondsToTime(remain, "abbr")
					else
						time1, time2, format = E:SecondsToTime(remain, "x:xx")
					end

					color = C.db.global.colors.cooldown.minute
				elseif remain >= 1 then
					if remain > cooldown.config.s_ms_threshold then
						time1, time2, format = E:SecondsToTime(remain, "abbr")
					else
						time1, time2, format = E:SecondsToTime(remain, "frac")
					end

					color = C.db.global.colors.cooldown.second
				elseif remain >= 0.001 then
					time1, time2, format = E:SecondsToTime(remain)
					color = C.db.global.colors.cooldown.second
				end

				if remain <= cooldown.config.exp_threshold then
					color = C.db.global.colors.cooldown.expiration
				end

				if time1 then
					cooldown.Timer:SetFormattedText(format, time1, time2)
					cooldown.Timer:SetVertexColor(E:GetRGB(color))
				end
			end
		end

		updateTime = 0
	end
end)

local function clearHook(self)
	self.Timer:SetText("")
	activeCooldowns[self] = nil
end

local function setCooldownHook(self, start, duration)
	if self.config.text.enabled then
		if duration > 1.5 then
			activeCooldowns[self] = start + duration
			return
		end
	end

	self.Timer:SetText("")
	activeCooldowns[self] = nil
end

local cooldown_proto = {}

function cooldown_proto:UpdateFont()
	local config = self.config.text

	self.Timer:UpdateFont(config.size)
	self.Timer:SetJustifyH("CENTER")
	self.Timer:SetJustifyV(config.v_alignment)
	self.Timer:SetShown(config.enabled)
end

function cooldown_proto:UpdateSwipe()
	local config = self.config.swipe

	self:SetDrawSwipe(config.enabled)
	self:SetReverse(config.reversed)
end

function cooldown_proto:UpdateConfig(config)
	if config then
		self.config = E:CopyTable(defaults, self.config)
		self.config = E:CopyTable(config, self.config)
	end

	if self.config.m_ss_threshold ~= 0 and self.config.m_ss_threshold < 91 then
		self.config.m_ss_threshold = 0
	end
end

function E.Cooldowns.Handle(cooldown)
	if E.OMNICC or handledCooldowns[cooldown] then
		return cooldown
	end

	Mixin(cooldown, cooldown_proto)

	cooldown:SetDrawBling(false)
	cooldown:SetDrawEdge(false)
	cooldown:SetHideCountdownNumbers(true)
	cooldown:GetRegions():SetAlpha(0) -- Default CD timer is region #1

	local textParent = CreateFrame("Frame", nil, cooldown)
	textParent:SetAllPoints()

	local timer = textParent:CreateFontString(nil, "ARTWORK")
	E.FontStrings:Capture(timer, "cooldown")
	timer:SetWordWrap(false)
	timer:SetPoint("TOPLEFT", -8, 0)
	timer:SetPoint("BOTTOMRIGHT", 8, 0)
	cooldown.Timer = timer

	hooksecurefunc(cooldown, "Clear", clearHook)
	hooksecurefunc(cooldown, "SetCooldown", setCooldownHook)

	cooldown:UpdateConfig(defaults)
	cooldown:UpdateFont()
	cooldown:UpdateSwipe()

	handledCooldowns[cooldown] = true

	local start, duration = cooldown:GetCooldownTimes()
	if start > 0 or duration > 0 then
		setCooldownHook(cooldown, start / 1000, duration / 1000)
	end

	return cooldown
end

function E.Cooldowns.Create(parent)
	local cooldown = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
	cooldown:SetPoint("TOPLEFT", 1, -1)
	cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

	E.Cooldowns.Handle(cooldown)

	return cooldown
end

function E.Cooldowns:ForEach(method, ...)
	for cooldown in next, handledCooldowns do
		if cooldown[method] then
			cooldown[method](cooldown, ...)
		end
	end
end
