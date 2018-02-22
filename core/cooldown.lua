local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Blizz
local GetTime = _G.GetTime

-- Mine
local handled = {}

local function cooldown_OnUpdate(self, elapsed)
	if not self.Timer:IsShown() then return end

	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		local timer = self.Timer
		local time, color, abbr = E:TimeFormat(timer.expire - GetTime())

		if time >= 0.1 then
			timer:SetFormattedText("%s"..abbr.."|r", color, time)
		else
			timer.expire = nil
			timer:SetText("")
			timer:Hide()

			self:SetScript("OnUpdate", nil)
		end

		self.elapsed = 0
	end
end

local function setCooldownHook(self, start, duration)
	local timer = self.Timer

	if start > 0 and duration > 1.5 then
		timer.expire = start + duration
		timer:Show()

		self:SetScript("OnUpdate", cooldown_OnUpdate)
	else
		timer.expire = nil
		timer:Hide()

		self:SetScript("OnUpdate", nil)
	end
end

local function cooldown_SetTimerTextHeight(self, height)
	self.Timer:SetFontObject("LSFont"..height.."_Outline")
end

function E:HandleCooldown(cooldown, textSize, textJustifyH, textJustifyV)
	if E.OMNICC or handled[cooldown] then
		return
	end

	cooldown:SetDrawEdge(false)
	cooldown:SetHideCountdownNumbers(true)
	cooldown:GetRegions():SetAlpha(0) -- Default CD timer is region #1

	local textParent = CreateFrame("Frame", nil, cooldown)
	textParent:SetAllPoints()

	local timer = textParent:CreateFontString(nil, "ARTWORK", "LSFont"..textSize.."_Outline")
	timer:SetPoint("TOPLEFT", -4, 0)
	timer:SetPoint("BOTTOMRIGHT", 4, 0)
	timer:SetWordWrap(false)
	timer:SetJustifyH(textJustifyH or "CENTER")
	timer:SetJustifyV(textJustifyV or "MIDDLE")

	hooksecurefunc(cooldown, "SetCooldown", setCooldownHook)

	cooldown.Timer = timer
	cooldown.SetTimerTextHeight = cooldown_SetTimerTextHeight

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
