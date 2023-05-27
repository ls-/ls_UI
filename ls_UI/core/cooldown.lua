local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler

-- Lua
local _G = getfenv(0)
local collectgarbage = _G.collectgarbage
local debugprofilestop = _G.debugprofilestop
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
		local timeStart, memStart
		if Profiler:IsLogging() then
			timeStart, memStart = debugprofilestop(), collectgarbage("count")
		end

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
					cooldown.Timer:SetVertexColor(color:GetRGB())
				end
			end
		end

		updateTime = 0

		if Profiler:IsLogging() then
			Profiler:Log("LSCooldownUpdater", "OnUpdate", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
		end
	end
end)

local function clearHook(self)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self.Timer:SetText("")
	activeCooldowns[self] = nil

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "clearHook", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function setCooldownHook(self, start, duration)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if self.config.text.enabled then
		if duration > 1.5 then
			activeCooldowns[self] = start + duration
			return
		end
	end

	self.Timer:SetText("")
	activeCooldowns[self] = nil

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "setCooldownHook", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local cooldown_proto = {}

function cooldown_proto:UpdateFont()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local config = self.config.text

	self.Timer:UpdateFont(config.size)
	self.Timer:SetJustifyH("CENTER")
	self.Timer:SetJustifyV(config.v_alignment)
	self.Timer:SetShown(config.enabled)

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateFont", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function cooldown_proto:UpdateSwipe()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local config = self.config.swipe

	self:SetDrawSwipe(config.enabled)
	self:SetReverse(config.reversed)

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateSwipe", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function cooldown_proto:UpdateConfig(config)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if config then
		self.config = E:CopyTable(defaults, self.config)
		self.config = E:CopyTable(config, self.config)
	end

	if self.config.m_ss_threshold ~= 0 and self.config.m_ss_threshold < 91 then
		self.config.m_ss_threshold = 0
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateConfig", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function E.Cooldowns.Handle(cooldown)
	if E.OMNICC or handledCooldowns[cooldown] then
		return cooldown
	end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
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

	if Profiler:IsLogging() then
		Profiler:Log("E.Cooldowns", "Handle", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end

	return cooldown
end

function E.Cooldowns.Create(parent)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local cooldown = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
	cooldown:SetPoint("TOPLEFT", 1, -1)
	cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

	E.Cooldowns.Handle(cooldown)

	if Profiler:IsLogging() then
		Profiler:Log("E.Cooldowns", "Create", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end

	return cooldown
end

function E.Cooldowns:ForEach(method, ...)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for cooldown in next, handledCooldowns do
		if cooldown[method] then
			cooldown[method](cooldown, ...)
		end
	end

	if Profiler:IsLogging() then
		Profiler:Log("E.Cooldowns", "ForEach", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end
