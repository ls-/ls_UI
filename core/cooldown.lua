local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local s_format = _G.string.format

-- Blizz
local GetTime = _G.GetTime

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local handled = {}
local defaults = {
	expire_threshold = 5, -- [1; 10]
	m_ss_threshold = 0, -- [91; 3599]
	colors = {
		enabled = true,
		expire = {229 / 255, 25 / 255, 25 / 255},
		second = {255 / 255, 191 / 255, 25 / 255},
		minute = {255 / 255, 255 / 255, 255 / 255},
		hour = {255 / 255, 255 / 255, 255 / 255},
		day = {255 / 255, 255 / 255, 255 / 255},
	},
	text = {
		enabled = true,
		size = 12,
		flag = "_Outline", -- "_Shadow", ""
		h_alignment = "CENTER",
		v_alignment = "MIDDLE",
	}
}

local function cooldown_OnUpdate(self, elapsed)
	if not self.Timer:IsShown() then return end

	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		local duration = self.Timer.expire - GetTime()
		local color, time, _

		if duration >= 86400 then
			time = E:SecondsToTime(duration, true)

			if self.config.colors.enabled then
				color = self.config.colors.day
			end
		elseif duration >= 3600 then
			_, time = E:SecondsToTime(duration, true)

			if self.config.colors.enabled then
				color = self.config.colors.hour
			end
		elseif duration >= 60 then
			if self.config.m_ss_threshold == 0 or duration >= self.config.m_ss_threshold then
				_, _, time = E:SecondsToTime(duration, true)
			else
				local m, s
				_, _, m, s = E:SecondsToTime(duration)
				time = s_format("%d:%02d", m, s)
			end

			if self.config.colors.enabled then
				color = self.config.colors.minute
			end
		elseif duration >= 1 then
			if duration >= self.config.expire_threshold then
				_, _, _, time = E:SecondsToTime(duration, true)
			else
				local s, ms
				_, _, _, s, ms = E:SecondsToTime(duration)
				time = s_format("%d.%d", s, ms / 100)
			end

			if self.config.colors.enabled then
				color = self.config.colors.second
			end
		elseif duration >= 0.001 then
			_, _, _, _, time = E:SecondsToTime(duration)
			time = s_format("%.1f", time / 1000)

			if self.config.colors.enabled then
				color = self.config.colors.second
			end
		end

		if self.config.colors.enabled and duration < self.config.expire_threshold then
			color = self.config.colors.expire
		end

		if time then
			self.Timer:SetFormattedText(time)

			if color then
				self.Timer:SetVertexColor(color[1], color[2], color[3])
			end
		else
			self.Timer:SetText("")
			self:SetScript("OnUpdate", nil)
		end

		self.elapsed = 0
	end
end

local function cooldown_SetCooldown(self, start, duration)
	if self.config.text.enabled then
		if start > 0 and duration > 1.5 then
			self.Timer.expire = start + duration

			self:SetScript("OnUpdate", cooldown_OnUpdate)
		else
			self.Timer.expire = nil
			self.Timer:SetText("")

			self:SetScript("OnUpdate", nil)
		end
	end
end

local function cooldown_SetTimerTextHeight()
end

local function cooldown_UpdateFontObject(self, fontObject)
	local config = self.config.text

	self.Timer:SetFontObject(fontObject or "LSFont" .. config.size .. config.flag)
	self.Timer:SetJustifyH(config.h_alignment)
	self.Timer:SetJustifyV(config.v_alignment)
	self.Timer:SetShown(config.enabled)
	self.Timer:SetWordWrap(false)
end

local function cooldown_UpdateConfig(self, config)
	self.config = E:CopyTable(config)
	self.config = E:UpdateTable(defaults, self.config)

	if self.config.m_ss_threshold ~= 0 and self.config.m_ss_threshold < 91 then
		self.config.m_ss_threshold = 0
	end
end

function E:HandleCooldown(cooldown)
	if E.OMNICC or handled[cooldown] then
		return
	end

	cooldown:SetDrawEdge(false)
	cooldown:SetHideCountdownNumbers(true)
	cooldown:GetRegions():SetAlpha(0) -- Default CD timer is region #1

	local textParent = CreateFrame("Frame", nil, cooldown)
	textParent:SetAllPoints()

	local timer = textParent:CreateFontString(nil, "ARTWORK")
	timer:SetPoint("TOPLEFT", -4, 0)
	timer:SetPoint("BOTTOMRIGHT", 4, 0)
	cooldown.Timer = timer

	hooksecurefunc(cooldown, "SetCooldown", cooldown_SetCooldown)

	cooldown.SetTimerTextHeight = cooldown_SetTimerTextHeight
	cooldown.UpdateConfig = cooldown_UpdateConfig
	cooldown.UpdateFontObject = cooldown_UpdateFontObject

	cooldown:UpdateConfig(defaults)
	cooldown:UpdateFontObject()

	handled[cooldown] = true

	return cooldown
end

function E:CreateCooldown(parent, textSize, textJustifyH, textJustifyV)
	local cooldown = CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
	cooldown:SetPoint("TOPLEFT", 1, -1)
	cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

	self:HandleCooldown(cooldown, textSize, textJustifyH, textJustifyV)

	return cooldown
end
