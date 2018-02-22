local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_abs = _G.math.abs
local next = _G.next
local s_match = _G.string.match
local s_split = _G.string.split
local type = _G.type

-- Blizz
local GetTime = _G.GetTime

-- Mine
function E:CalcSegmentsSizes(size, num)
	local size_wo_gaps = size - 2 * (num - 1)
	local seg_size = size_wo_gaps / num
	local mod = seg_size % 1
	local result = {}

	if mod == 0 then
		for k = 1, num do
			result[k] = seg_size
		end
	else
		seg_size = self:Round(seg_size)

		if num % 2 == 0 then
			local range = (num - 2) / 2

			for k = 1, range do
				result[k] = seg_size
			end

			for k = num - range + 1, num do
				result[k] = seg_size
			end

			seg_size = (size_wo_gaps - seg_size * range * 2) / 2
			result[range + 1] = seg_size
			result[range + 2] = seg_size
		else
			local range = (num - 1) / 2

			for k = 1, range do
				result[k] = seg_size
			end

			for k = num - range + 1, num do
				result[k] = seg_size
			end

			seg_size = size_wo_gaps - seg_size * range * 2
			result[range + 1] = seg_size
		end
	end

	return result
end

--------------
-- COOLDOWN --
--------------

do
	local THRESHOLD = 1.5

	local handled = {}

	local function Timer_OnUpdate(self, elapsed)
		if not self.Timer:IsShown() then return end

		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			local timer = self.Timer
			local time, color, abbr = E:TimeFormat(timer.expire - GetTime(), true)

			if time >= 0.1 then
				timer:SetFormattedText("%s"..abbr.."|r", color, time)
			else
				timer:SetText("")
				timer:Hide()
			end

			self.elapsed = 0
		end
	end

	local function SetCooldownHook(self, start, duration)
		local timer = self.Timer

		if start > 0 and duration > THRESHOLD then
			local expire = start + duration

			-- BUG: start value may be an incorrect number, won't be fixed
			timer.expire = expire - GetTime() > duration and duration or expire
			timer:Show()

			self:SetScript("OnUpdate", Timer_OnUpdate)
		else
			timer:Hide()

			self:SetScript("OnUpdate", nil)
		end
	end

	local function SetTimerTextHeight(self, height)
		self.Timer:SetFontObject("LSFont"..height.."_Outline")
	end

	local function HandleCooldown(cooldown, textSize, textJustifyH, textJustifyV)
		if E.OMNICC or handled[cooldown] then
			return
		end

		cooldown:SetDrawEdge(false)
		cooldown:SetHideCountdownNumbers(true)
		cooldown:GetRegions():SetAlpha(0) -- Default CD timer is region #1

		local text_parent = _G.CreateFrame("Frame", nil, cooldown)
		text_parent:SetAllPoints()

		local timer = text_parent:CreateFontString(nil, "ARTWORK", "LSFont"..textSize.."_Outline")
		timer:SetPoint("TOPLEFT", -4, 0)
		timer:SetPoint("BOTTOMRIGHT", 4, 0)
		timer:SetWordWrap(false)
		timer:SetJustifyH(textJustifyH or "CENTER")
		timer:SetJustifyV(textJustifyV or "MIDDLE")

		hooksecurefunc(cooldown, "SetCooldown", SetCooldownHook)

		cooldown.Timer = timer
		cooldown.SetTimerTextHeight = SetTimerTextHeight

		handled[cooldown] = true

		return cooldown
	end

	local function CreateCooldown(parent, textSize, textJustifyH, textJustifyV)
		local cooldown = _G.CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
		cooldown:SetPoint("TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

		HandleCooldown(cooldown, textSize, textJustifyH, textJustifyV)

		return cooldown
	end

	function E:HandleCooldown(...)
		return HandleCooldown(...)
	end

	function E:CreateCooldown(...)
		return CreateCooldown(...)
	end
end
