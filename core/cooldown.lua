local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_abs = _G.math.abs
local next = _G.next
local unpack = _G.unpack

-- Blizz
local GetTime = _G.GetTime

--[[ luacheck: globals
	CreateFrame UIParent
]]

-- Mine
E.Cooldowns = {}
local handledCooldowns = {}
local activeCooldowns = {}

local defaults = {
	exp_threshold = 5, -- [1; 10]
	m_ss_threshold = 0, -- [91; 3599]
	text = {
		enabled = true,
		size = 12,
		flag = "_Outline", -- "_Shadow", ""
		v_alignment = "MIDDLE",
	},
}

local updateTime = 0
local time1, time2, format, color
E.Cooldowns.Updater = CreateFrame("Frame")
E.Cooldowns.Updater:SetScript("OnUpdate", function(_, elapsed)
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
					color = C.db.profile.colors.cooldown.day
				elseif remain >= 3600 then
					time1, time2, format = E:SecondsToTime(remain, "abbr")
					color = C.db.profile.colors.cooldown.hour
				elseif remain >= 60 then
					if cooldown.config.m_ss_threshold == 0 or remain > cooldown.config.m_ss_threshold then
						time1, time2, format = E:SecondsToTime(remain, "abbr")
					else
						time1, time2, format = E:SecondsToTime(remain, "x:xx")
					end

					color = C.db.profile.colors.cooldown.minute
				elseif remain >= 1 then
					if remain > cooldown.config.exp_threshold then
						time1, time2, format = E:SecondsToTime(remain, "abbr")
					else
						time1, time2, format = E:SecondsToTime(remain, "frac")
					end

					color = C.db.profile.colors.cooldown.second
				elseif remain >= 0.001 then
					time1, time2, format = E:SecondsToTime(remain)
					color = C.db.profile.colors.cooldown.second
				end

				if remain <= cooldown.config.exp_threshold then
					color = C.db.profile.colors.cooldown.expiration
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

local function cooldown_Clear(self)
	self.Timer:SetText("")
	activeCooldowns[self] = nil
end

local function cooldown_SetCooldown(self, start, duration)
	if self.config.text.enabled then
		if duration > 1.5 then
			activeCooldowns[self] = start + duration
			return
		end
	end

	self.Timer:SetText("")
	activeCooldowns[self] = nil
end

local function cooldown_UpdateFontObject(self, fontObject)
	local config = self.config.text

	self.Timer:SetFontObject(fontObject or "LSFont" .. config.size .. config.flag)
	self.Timer:SetJustifyH("CENTER")
	self.Timer:SetJustifyV(config.v_alignment)
	self.Timer:SetShown(config.enabled)
	self.Timer:SetWordWrap(false)

	if config.flag == "_Shadow" then
		self.Timer:SetShadowOffset(1, -1)
	else
		self.Timer:SetShadowOffset(0, 0)
	end
end

local function cooldown_UpdateConfig(self, config)
	self.config = E:CopyTable(defaults, self.config)
	self.config = E:CopyTable(config, self.config)

	if self.config.m_ss_threshold ~= 0 and self.config.m_ss_threshold < 91 then
		self.config.m_ss_threshold = 0
	end
end

function E.Cooldowns.Handle(cooldown)
	if E.OMNICC or handledCooldowns[cooldown] then
		return cooldown
	end

	cooldown:SetDrawBling(false)
	cooldown:SetDrawEdge(false)
	cooldown:SetHideCountdownNumbers(true)
	cooldown:GetRegions():SetAlpha(0) -- Default CD timer is region #1

	local textParent = CreateFrame("Frame", nil, cooldown)
	textParent:SetAllPoints()

	local timer = textParent:CreateFontString(nil, "ARTWORK")
	timer:SetPoint("TOPLEFT", -8, 0)
	timer:SetPoint("BOTTOMRIGHT", 8, 0)
	cooldown.Timer = timer

	hooksecurefunc(cooldown, "Clear", cooldown_Clear)
	hooksecurefunc(cooldown, "SetCooldown", cooldown_SetCooldown)

	cooldown.UpdateConfig = cooldown_UpdateConfig
	cooldown.UpdateFontObject = cooldown_UpdateFontObject

	cooldown:UpdateConfig(defaults)
	cooldown:UpdateFontObject()

	handledCooldowns[cooldown] = true

	return cooldown
end

function E.Cooldowns.Create(parent)
	local cooldown = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
	cooldown:SetPoint("TOPLEFT", 1, -1)
	cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

	E.Cooldowns.Handle(cooldown)

	return cooldown
end
