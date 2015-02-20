local _, ns = ...
local E, M = ns.E, ns.M

local THRESHOLD = 1.5

local function Timer_OnUpdate(self, elapsed)
	if not self.timer:IsShown() then return end

	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		local timer = self.timer

		local time, color, abbr = E:TimeFormat(timer.duration + timer.start - GetTime(), true)

		if time >= 0.1 then
			self.timer:SetFormattedText("%s"..abbr.."|r", color, time)
		else
			self.timer:SetText("")
		end

		self.elapsed = 0
	end
end

local function SetCustomCooldown(self, start, duration, charges, maxCharges)
	local timer = self.timer

	if start > 0 and duration > THRESHOLD then
		timer.start = start
		timer.duration = duration
		timer:Show()
	else
		timer:Hide()
	end
end

local function CreateCooldownTimer(cooldown, textSize)
	local holder= CreateFrame("Frame", nil, cooldown)
	holder:SetAllPoints()
	holder:SetScript("OnUpdate", Timer_OnUpdate)

	local timer = E:CreateFontString(holder, textSize, nil, true, "THINOUTLINE")
	timer:SetPoint("CENTER", 1, 0)
	timer:SetJustifyH("CENTER")

	holder.timer = timer

	return timer

end

function E:HandleCooldown(cooldown, textSize)
	if OmniCC or cooldown.handled then return end

	cooldown.timer = CreateCooldownTimer(cooldown, textSize)

	hooksecurefunc(cooldown, "SetCooldown", SetCustomCooldown)

	cooldown:SetHideCountdownNumbers(true)

	cooldown.handled = true
end
