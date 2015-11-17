local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")
local HPCOLORS = M.colors.healprediction

local function UpdateHealPredictionAnchor(self, orientation, appendTexture, offset)
	if orientation == "HORIZONTAL" then
		self:SetPoint('LEFT', appendTexture, 'RIGHT', offset or 0, 0)
	else
		self:SetPoint('BOTTOM', appendTexture, 'TOP', 0, offset or 0)
	end

	if self.Overlay then
		if self:GetValue() == 0 then
			self.Overlay:Hide()
		else
			self.Overlay:Show()
		end
	end

	return self:GetStatusBarTexture()
end

function PostUpdateHealPrediction(self, unit, overAbsorb, overHealAbsorb)
	local healthbar = self.__owner.Health
	local myHeals = self.myBar
	local otherHeals = self.otherBar
	local healAbsorb = self.healAbsorbBar
	local damageAbsorb = self.absorbBar
	local absorbGlow = self.__owner.AbsorbGlow
	local appendTexture = healthbar:GetStatusBarTexture()
	local orientation = self.myBar:GetOrientation()
	local healthSize = orientation == "HORIZONTAL" and healthbar:GetWidth() or healthbar:GetHeight()
	local totalHealAbsorbValue = UnitGetTotalHealAbsorbs(unit) or 0
	local curHealAbsorbValue = healAbsorb:GetValue()
	local maxHealth = UnitHealthMax(unit)

	if myHeals and myHeals:GetValue() > 0 then
		appendTexture = UpdateHealPredictionAnchor(myHeals, orientation, appendTexture, -(healthSize * totalHealAbsorbValue / maxHealth))
	end

	if otherHeals and otherHeals:GetValue() > 0 then
		appendTexture = UpdateHealPredictionAnchor(otherHeals, orientation, appendTexture)
	end

	if healAbsorb and curHealAbsorbValue > 0 then
		appendTexture = UpdateHealPredictionAnchor(healAbsorb, orientation, healthbar:GetStatusBarTexture(), -(healthSize * curHealAbsorbValue / maxHealth))
	end

	if damageAbsorb then
		appendTexture = UpdateHealPredictionAnchor(damageAbsorb, orientation, appendTexture)
	end

	if absorbGlow then
		if overAbsorb then
			E:Blink(absorbGlow, 0.5, 0, 1)
		else
			E:StopBlink(absorbGlow)
		end
	end
end

function UF:CreateHealPrediction(parent, isVertical)
	local healthbar = parent.Health
	local level = healthbar:GetFrameLevel()
	local width, height = healthbar:GetSize()

	local myBar = CreateFrame("StatusBar", "$parentMyIncomingHeal", healthbar)
	myBar:SetFrameLevel(level)
	myBar:SetOrientation(isVertical and "VERTICAL" or "HORIZONTAL")
	myBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	myBar:SetStatusBarColor(unpack(HPCOLORS.myheal))
	myBar:Hide()

	local otherBar = CreateFrame("StatusBar", "$parentOtherIncomingHeal", healthbar)
	otherBar:SetFrameLevel(level)
	otherBar:SetOrientation(isVertical and "VERTICAL" or "HORIZONTAL")
	otherBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	otherBar:SetStatusBarColor(unpack(HPCOLORS.otherheal))
	otherBar:Hide()

	local healAbsorbBar = CreateFrame("StatusBar", "$parentHealAbsorb", healthbar)
	healAbsorbBar:SetFrameLevel(level + 1)
	healAbsorbBar:SetOrientation(isVertical and "VERTICAL" or "HORIZONTAL")
	healAbsorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	healAbsorbBar:SetStatusBarColor(unpack(HPCOLORS.healabsorb))
	healAbsorbBar:Hide()

	local damageAbsorbBar = CreateFrame("StatusBar", "$parentTotalAbsorb", healthbar)
	damageAbsorbBar:SetFrameLevel(level + 1)
	damageAbsorbBar:SetOrientation(isVertical and "VERTICAL" or "HORIZONTAL")
	damageAbsorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	damageAbsorbBar:SetStatusBarColor(unpack(HPCOLORS.damageabsorb))
	damageAbsorbBar:Hide()

	damageAbsorbBar.Overlay = damageAbsorbBar:CreateTexture(nil, "ARTWORK", "TotalAbsorbBarOverlayTemplate", 1)
	damageAbsorbBar.Overlay:SetAllPoints(damageAbsorbBar:GetStatusBarTexture())

	if isVertical then
		myBar:SetPoint("LEFT")
		myBar:SetPoint("RIGHT")
		myBar:SetHeight(height)

		otherBar:SetPoint("LEFT")
		otherBar:SetPoint("RIGHT")
		otherBar:SetHeight(height)

		healAbsorbBar:SetPoint("LEFT")
		healAbsorbBar:SetPoint("RIGHT")
		healAbsorbBar:SetHeight(height)

		damageAbsorbBar:SetPoint("LEFT")
		damageAbsorbBar:SetPoint("RIGHT")
		damageAbsorbBar:SetHeight(height)
	else
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetWidth(width)

		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetWidth(width)

		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetWidth(width)

		damageAbsorbBar:SetPoint("TOP")
		damageAbsorbBar:SetPoint("BOTTOM")
		damageAbsorbBar:SetWidth(width)
	end

	return {
		myBar = myBar,
		otherBar = otherBar,
		healAbsorbBar = healAbsorbBar,
		absorbBar = damageAbsorbBar,
		maxOverflow = 1,
		frequentUpdates = true,
		PostUpdate = PostUpdateHealPrediction
	}
end
