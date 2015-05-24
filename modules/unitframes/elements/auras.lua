local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

local UnitCanAssist, UnitCanAttack, GetCVar = UnitCanAssist, UnitCanAttack, GetCVar

local function SetCustomVertexColor(self, r, g, b)
	local fg = self:GetParent().Fg

	if not r then
		fg:SetBorderColor(1, 1, 1)
	else
		fg:SetBorderColor(r, g, b)
	end
end

local function PostCreateAuraIcon(frame, button)
	local bIcon = button.icon
	local bCD = button.cd
	local bOverlay = button.overlay
	local bCount = button.count
	local bSteal = button.stealable

	E:TweakIcon(bIcon)

	E:HandleCooldown(bCD, 10)

	bCD:SetReverse(true)

	if bCD.Timer then
		bCD.Timer:ClearAllPoints()
		bCD.Timer:SetPoint("BOTTOM", 1, 0)
	end

	bOverlay:Hide()
	bOverlay.Hide = SetCustomVertexColor
	bOverlay.SetVertexColor = SetCustomVertexColor
	bOverlay.Show = function() return end

	local fg = CreateFrame("Frame", nil, button)
	fg:SetAllPoints(button)
	fg:SetFrameLevel(button:GetFrameLevel() + 2)
	button.Fg = fg

	E:CreateBorder(fg, 6)

	bCount:SetFont(M.font, 10, "THINOUTLINE")
	bCount:SetParent(fg)
	bCount:ClearAllPoints()
	bCount:SetPoint("TOPRIGHT", 2, 1)

	bSteal:SetTexCoord(2 / 32, 30 / 32, 2 / 32, 30 / 32)
	bSteal:SetParent(fg)
	bSteal:SetDrawLayer("BORDER", 3)
	bSteal:ClearAllPoints()
	bSteal:SetPoint("TOPLEFT", -1, 1)
	bSteal:SetPoint("BOTTOMRIGHT", 1, -1)
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

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint(unpack(coords))
	frame:SetSize(22 * 4 + 3 * 4, 22 * rows + 3)

	frame["growth-x"] = "LEFT"
	frame["initialAnchor"] = "BOTTOMRIGHT"
	frame["num"] = count
	frame["size"] = 22
	frame["spacing-x"] = 3
	frame["spacing-y"] = 3
	frame.showStealableBuffs = true

	frame.PostCreateIcon = PostCreateAuraIcon
	frame.PostUpdateIcon = PostUpdateAuraIcon
	frame.PreUpdate = PreUpdateBuffIcon

	return frame
end

function UF:CreateDebuffs(parent, coords, count)
	local rows = E:Round(count / 4)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint(unpack(coords))
	frame:SetSize(22 * 4 + 3 * 4, 22 * rows + 3)

	frame["showType"] = true
	frame["num"] = count
	frame["size"] = 22
	frame["spacing-x"] = 3
	frame["spacing-y"] = 3

	frame.PostCreateIcon = PostCreateAuraIcon
	frame.PostUpdateIcon = PostUpdateAuraIcon
	frame.PreUpdate = PreUpdateDebuffIcon
	frame.CustomFilter = CustomDebuffFilter

	return frame
end
