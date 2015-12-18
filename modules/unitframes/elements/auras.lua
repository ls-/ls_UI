local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

local UnitCanAssist, UnitCanAttack, GetCVar = UnitCanAssist, UnitCanAttack, GetCVar

local function SetVertexColorOverride(self, r, g, b)
	local button = self:GetParent()

	if not r then
		button:SetBorderColor(1, 1, 1)
	else
		button:SetBorderColor(r, g, b)
	end
end

local function UpdateTooltip(self)
	GameTooltip:SetUnitAura(self:GetParent().__owner.unit, self:GetID(), self.filter)
end

local function AuraButton_OnEnter(self)
	if not self:IsVisible() then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local function AuraButton_OnLeave()
	GameTooltip:Hide()
end

local function CreateAuraIcon(frame, index)
	local button = E:CreateButton(frame, "$parentButton"..index, true)
	button:SetBorderSize(6)

	button.icon = button.Icon
	button.Icon = nil

	button.count = button.Count
	button.Count = nil

	button.cd = button.CD
	button.cd:SetTimerTextHeight(10)
	button.CD = nil

	button:SetPushedTexture("")
	button:SetHighlightTexture("")

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:Hide()
	overlay.Hide = SetVertexColorOverride
	overlay.SetVertexColor = SetVertexColorOverride
	overlay.Show = function() return end
	button.overlay = overlay

	local stealable = _G[button:GetName().."Cover"]:CreateTexture(nil, "OVERLAY", nil, 2)
	stealable:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Stealable")
	stealable:SetTexCoord(2 / 32, 30 / 32, 2 / 32, 30 / 32)
	stealable:SetPoint("TOPLEFT", -1, 1)
	stealable:SetPoint("BOTTOMRIGHT", 1, -1)
	stealable:SetBlendMode("ADD")
	button.stealable = stealable

	button.UpdateTooltip = UpdateTooltip
	button:SetScript("OnEnter", AuraButton_OnEnter)
	button:SetScript("OnLeave", AuraButton_OnLeave)

	return button
end

local function PostUpdateAuraIcon(self, unit, aura, index, offset)
	local _, _, _, _, _, _, _, caster, isStealable  = UnitAura(unit, index, aura.filter)
	local icon = aura.icon
	local isMine = aura.isPlayer or caster == "pet"

	if not self.onlyShowPlayer then
		if isMine or isStealable  then
			icon:SetDesaturated(false)
			icon:SetAlpha(1)
		else
			icon:SetDesaturated(true)
			icon:SetAlpha(0.65)
		end
	end
end

local function PreUpdateBuffIcon(self, unit)
	if GetCVar("showCastableBuffs") == "1" and UnitCanAssist("player", unit) then
		self.filter = "HELPFUL|RAID"
	else
		self.filter = nil
	end
end

local function PreUpdateDebuffIcon(self, unit)
	if GetCVar("showDispelDebuffs") == "1" and UnitCanAssist("player", unit) then
		self.filter = "HARMFUL|RAID"
	else
		self.filter = nil
	end
end

function CustomDebuffFilter(self, unit, debuff, ...)
	local name, _, _, _, _, _, _, caster, _, _, spellID = ...
	local isMine = debuff.isPlayer or caster == "pet"

	if GetCVar("showAllEnemyDebuffs") == "1" or not UnitCanAttack("player", unit) or (self.onlyShowPlayer and isMine) then
		return true
	else
		if SpellIsAlwaysShown(spellID) then
			return true
		end

		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")

		if hasCustom then
			return showForMySpec or (alwaysShowMine and isMine)
		else
			return isMine
		end
	end
end

function UF:CreateBuffs(parent, coords, count)
	local rows = E:Round(count / 4)

	local frame = CreateFrame("Frame", "$parentBuffs", parent)
	frame:SetPoint(unpack(coords))
	frame:SetSize(22 * 4 + 3 * 4, 22 * rows + 3)

	frame["growth-x"] = "LEFT"
	frame["initialAnchor"] = "BOTTOMRIGHT"
	frame["num"] = count
	frame["size"] = 22
	frame["spacing-x"] = 3
	frame["spacing-y"] = 3
	frame.showStealableBuffs = true

	frame.CreateIcon = CreateAuraIcon
	frame.PostUpdateIcon = PostUpdateAuraIcon
	frame.PreUpdate = PreUpdateBuffIcon

	return frame
end

function UF:CreateDebuffs(parent, coords, count)
	local rows = E:Round(count / 4)
	local frame = CreateFrame("Frame", "$parentDebuffs", parent)
	frame:SetPoint(unpack(coords))
	frame:SetSize(22 * 4 + 3 * 4, 22 * rows + 3)

	frame["showType"] = true
	frame["num"] = count
	frame["size"] = 22
	frame["spacing-x"] = 3
	frame["spacing-y"] = 3

	frame.CreateIcon = CreateAuraIcon
	frame.PostUpdateIcon = PostUpdateAuraIcon
	frame.PreUpdate = PreUpdateDebuffIcon
	frame.CustomFilter = CustomDebuffFilter

	return frame
end
