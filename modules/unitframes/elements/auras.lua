local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

local tcontains = tContains

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

		button.cd.Timer:ClearAllPoints()
		button.cd.Timer:SetPoint("BOTTOM")
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

function CustomBuffFilter(frame, unit, buff, ...)
	local name, _, _, _, _, _, _, caster, isStealable, _, spellID, canApplyAura, isBossAura = ...
	local config = frame.aura_config.HELPFUL
	local filter = buff.filter
	local isMine = buff.isPlayer or caster == "pet"
	local playerSpec = E:GetPlayerSpecFlag()

	if isBossAura then
		-- print("|cff26a526"..filter.."|r", name, spellID, "|cffe5a526BOSSAURA|r")
		return true
	elseif config.auralist[spellID] then
		if E:IsFilterApplied(config.auralist[spellID], playerSpec) then
			-- print("|cff26a526"..filter.."|r", name, spellID, "|cffe5a526FROM WHITELIST|r")
			return true
		else
			-- print("|cff26a526"..filter.."|r", name, spellID, "|cffe5a526FROM BLACKLIST|r")
			return false
		end
	elseif isMine and canApplyAura then
		-- print("|cff26a526"..filter.."|r", name, spellID, "|cffe5a526YOURS|r")
		return true
	end

	if UnitCanAttack("player", unit) or not UnitCanAssist("player", unit) then -- hostile
		if E:IsFilterApplied(config.include_all_enemy_buffs, playerSpec) then
			return true
		end

		if E:IsFilterApplied(config.include_stealable, playerSpec) then
			if isStealable then
				-- print("|cff26a526"..filter.."|r", name, spellID, "|cffe52626HOSTILE STEALABLE|r")
				return true
			end
		end

		-- ALWAYS shown for hostile NPCs
		if not UnitPlayerControlled(unit) and SpellIsSelfBuff(spellID) then
			-- print("|cff26a526"..filter.."|r", name, spellID, "|cffe52626HOSTILE NPC SELFCAST|r")
			return true
		end
	else -- friendly
		if E:IsFilterApplied(config.include_all_friendly_buffs, playerSpec) then
			return true
		end

		if E:IsFilterApplied(config.include_castable, playerSpec) then
			if UnitAura(unit, name, nil, filter.."|RAID") then
				-- print("|cff26a526"..filter.."|r", name, spellID, "|cff26a526FRIENDLY CASTABLE|r")
				return true
			end
		end

		if E:IsFilterApplied(config.include_relevant, playerSpec) then
			local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

			if hasCustom and showForMySpec then
				-- print("|cff26a526"..filter.."|r", name, spellID, "|cff26a526FRIENDLY RELEVANT|r")
				return true
			end
		end
	end

	-- print("|cff26a526"..filter.."|r", name, spellID, "|cffe5a526JUNK|r")
	return false
end

function CustomDebuffFilter(frame, unit, debuff, ...)
	local name, _, _, _, dtype, _, _, caster, _, _, spellID, _, isBossAura = ...
	local config = frame.aura_config.HARMFUL
	local filter = debuff.filter
	local isMine = debuff.isPlayer or caster == "pet"
	local playerSpec = E:GetPlayerSpecFlag()

	-- ALWAYS shown
	if isBossAura then
		-- print("|cffe52626"..filter.."|r", name, spellID, "|cffe5a526BOSSAURA|r")
		return true
	elseif config.auralist[spellID] then
		if E:IsFilterApplied(config.auralist[spellID], playerSpec) then
			-- print("|cffe52626"..filter.."|r", name, spellID, "|cffe5a526FROM WHITELIST|r")
			return true
		else
			-- print("|cffe52626"..filter.."|r", name, spellID, "|cffe5a526FROM BLACKLIST|r")
			return false
		end
	elseif isMine then
		-- print("|cffe52626"..filter.."|r", name, spellID, "|cffe5a526YOURS|r")
		return true
	end

	-- OPTIONAL stuff
	if UnitCanAttack("player", unit) or not UnitCanAssist("player", unit) then -- hostile
		if E:IsFilterApplied(config.show_all_enemy_debuffs, playerSpec) then
			return true
		end

		if E:IsFilterApplied(config.include_relevant, playerSpec) then
			if SpellIsAlwaysShown(spellID) then
				-- print("|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE RELEVANT (ALWAYS)|r")
				return true
			end

			local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")

			if hasCustom and showForMySpec then
				-- print("|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE RELEVANT (MY SPEC)|r")
				return true
			end
		end
	else -- friendly
		if E:IsFilterApplied(config.show_all_friendly_debuffs, playerSpec) then
			return true
		end

		if E:IsFilterApplied(config.include_dispellable, playerSpec) then
			if UnitAura(unit, name, nil, filter.."|RAID") then
				-- print("|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY DISPELLABLE|r")
				return true
			end
		end

		if E:IsFilterApplied(config.include_relevant, playerSpec) then
			local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

			if hasCustom and showForMySpec then
				-- print("|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY RELEVANT (MY SPEC)|r")
				return true
			end
		end
	end

	-- print("|cffe52626"..filter.."|r", name, spellID, "|cffe5a526JUNK|r")
	return false
end

function UF:CreateBuffs(parent, coords, count)
	if parent.unit ~= "target" then return end

	local config = C.units[parent.unit].auras

	if not E:IsFilterApplied(config.enabled, E:GetPlayerSpecFlag()) then return end

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

	frame.aura_config = config
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = CustomBuffFilter

	return frame
end

function UF:CreateDebuffs(parent, coords, count)
	if parent.unit ~= "target" then return end

	local config = C.units[parent.unit].auras

	if not E:IsFilterApplied(config.enabled, E:GetPlayerSpecFlag()) then return end

	local rows = E:Round(count / 4)
	local frame = CreateFrame("Frame", "$parentDebuffs", parent)
	frame:SetPoint(unpack(coords))
	frame:SetSize(22 * 4 + 3 * 4, 22 * rows + 3)

	frame["showType"] = true
	frame["num"] = count
	frame["size"] = 22
	frame["spacing-x"] = 3
	frame["spacing-y"] = 3

	frame.aura_config = config
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = CustomDebuffFilter

	return frame
end
