local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
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
	colors = {
		enabled = true,
		expiration = {229 / 255, 25 / 255, 25 / 255},
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

				color = nil

				if remain >= 86400 then
					time1, time2, format = E:SecondsToTime(remain, "abbr")

					if cooldown.config.colors.enabled then
						color = cooldown.config.colors.day
					end
				elseif remain >= 3600 then
					time1, time2, format = E:SecondsToTime(remain, "abbr")

					if cooldown.config.colors.enabled then
						color = cooldown.config.colors.hour
					end
				elseif remain >= 60 then
					if cooldown.config.m_ss_threshold == 0 or remain > cooldown.config.m_ss_threshold then
						time1, time2, format = E:SecondsToTime(remain, "abbr")
					else
						time1, time2, format = E:SecondsToTime(remain, "x:xx")
					end

					if cooldown.config.colors.enabled then
						color = cooldown.config.colors.minute
					end
				elseif remain >= 1 then
					if remain > cooldown.config.exp_threshold then
						time1, time2, format = E:SecondsToTime(remain, "abbr")
					else
						time1, time2, format = E:SecondsToTime(remain, "frac")
					end

					if cooldown.config.colors.enabled then
						color = cooldown.config.colors.second
					end
				elseif remain >= 0.001 then
					time1, time2, format = E:SecondsToTime(remain)

					if cooldown.config.colors.enabled then
						color = cooldown.config.colors.second
					end
				end

				if cooldown.config.colors.enabled and remain <= cooldown.config.exp_threshold then
					color = cooldown.config.colors.expiration
				end

				if time1 then
					cooldown.Timer:SetFormattedText(format, time1, time2)

					if color then
						cooldown.Timer:SetVertexColor(unpack(color))
					else
						cooldown.Timer:SetVertexColor(1, 1, 1)
					end
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
		if start > 0 and duration > 1.5 then
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
	self.Timer:SetJustifyH(config.h_alignment)
	self.Timer:SetJustifyV(config.v_alignment)
	self.Timer:SetShown(config.enabled)
	self.Timer:SetWordWrap(false)
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
