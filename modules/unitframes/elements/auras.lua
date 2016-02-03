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
	button.CD = nil

	if button.cd.SetTimerTextHeight then
		button.cd:SetTimerTextHeight(10)
	end

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

---------
-- NEW --
---------

function CustomAuraTrackerFilter(frame, aura, unit, index, filter)
	local name, rank, texture, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura, isCastByPlayer = UnitAura(unit, index, filter)
end

function CustomBuffFilter(frame, unit, buff, ...)
	local name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura = ...
	local config = frame.aura_config[E.playerspec].HELPFUL
	local filter = buff.filter
	local isMine = buff.isPlayer or caster == "pet"
	local canAssist = UnitCanAssist("player", unit)

	if canAssist then
		if config.include_castable or config.include_relevant then
			if config.include_castable then
				if UnitAura(unit, name, nil, filter.."|RAID") then
					return true
				end
			end

			if config.include_relevant then
				if isBossAura then
					return true
				end

				local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

				if hasCustom and showForMySpec then
					return true
				end
			end

			return false
		else -- show all
			return true
		end
	else
		if config.include_relevant or config.include_stealable then
			if config.include_relevant then
				if isBossAura then
					return true
				end
			end

			if config.include_stealable then
				if isStealable then
					return true
				end
			end

			return false
		else -- show all
			return true
		end
	end
end

function CustomDebuffFilter(frame, unit, debuff, ...)
	local name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossAura = ...
	local config = frame.aura_config[E.playerspec].HARMFUL
	local filter = debuff.filter
	local isMine = debuff.isPlayer or caster == "pet"
	local canAssist = UnitCanAssist("player", unit)

	if canAssist then
		if config.include_dispellable or config.include_relevant then
			if config.include_dispellable then
				if UnitAura(unit, name, nil, filter.."|RAID") then
					return true
				end
			end

			if config.include_relevant then
				if isMine or isBossAura then
					return true
				end

				local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

				if hasCustom and showForMySpec then
					return true
				end
			end

			return false
		else -- show all
			return true
		end
	else
		if config.include_relevant then
			if SpellIsAlwaysShown(spellID) then
				return true
			end

			if isMine or isBossAura then
				return true
			end

			local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")

			if hasCustom and showForMySpec then
				return true
			end

			return false
		else -- show all
			return true
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

	if parent.unit == "target" then
		frame.aura_config = C.units.target.auras

		-- frame.UpdateIcon = UpdateIconOverride
		frame.CustomFilter = CustomBuffFilter
	end

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

	if parent.unit == "target" then
		frame.aura_config = C.units.target.auras

		-- frame.UpdateIcon = UpdateIconOverride
		frame.CustomFilter = CustomDebuffFilter
	end

	return frame
end
