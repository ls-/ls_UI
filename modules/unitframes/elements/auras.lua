local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

local UnitCanAssist, UnitCanAttack, UnitIsUnit, UnitIsPlayer, UnitPlayerControlled, UnitAura =
	UnitCanAssist, UnitCanAttack, UnitIsUnit, UnitIsPlayer, UnitPlayerControlled, UnitAura
local SpellGetVisibilityInfo, SpellIsAlwaysShown = SpellGetVisibilityInfo, SpellIsAlwaysShown

local mceil = math.ceil

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

---------
-- NEW --
---------

function CustomAuraFilter(frame, unit, buff, ...)
	local name, _, _, _, _, _, _, caster, isStealable, _, spellID, _, isBossAura = ...
	local filter = buff.filter
	local config = frame.aura_config[filter]
	local isMine = buff.isPlayer or caster == "pet"
	local playerSpec = E:GetPlayerSpecFlag()

	if isBossAura then
		-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526BOSSAURA|r")
		return true
	elseif config.auralist[spellID] then
		if E:IsFilterApplied(config.auralist[spellID], playerSpec) then
			-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526FROM WHITELIST|r")
			return true
		else
			-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526FROM BLACKLIST|r")
			return false
		end
	elseif caster and (UnitIsUnit(caster, "vehicle") and not UnitIsPlayer("vehicle")) then
		-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526VEHICLE|r")
		return true
	elseif not caster then
		if not IsInInstance() then
			-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526UNKNOWN (JUNK, NOT IN INSTANCE)|r")
			return false
		else
			-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526UNKNOWN (IN INSTANCE)|r")
			return true
		end
	end

	if UnitCanAttack("player", unit) or not UnitCanAssist("player", unit) then -- hostile
		if filter == "HELPFUL" then
			if E:IsFilterApplied(config.include_all_enemy_buffs, playerSpec) then
				return true
			end

			-- ALWAYS shown
			if not UnitPlayerControlled(unit) and caster == unit then
				-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE NPC SELFCAST|r")
				return true
			end

			if isStealable then
				-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE STEALABLE|r")
				return true
			end
		else
			if E:IsFilterApplied(config.show_all_enemy_debuffs, playerSpec) then
				return true
			end

			if E:IsFilterApplied(config.include_relevant, playerSpec) then
				if isMine then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE RELEVANT (MINE)|r")
					return true
				end

				if SpellIsAlwaysShown(spellID) then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE RELEVANT (ALWAYS)|r")
					return true
				end

				local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")

				if hasCustom and showForMySpec then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE RELEVANT (MY SPEC)|r")
					return true
				end
			end
		end
	else -- friendly
		if filter == "HELPFUL" then
			if E:IsFilterApplied(config.include_all_friendly_buffs, playerSpec) then
				return true
			end

			if E:IsFilterApplied(config.include_castable, playerSpec) then
				if UnitAura(unit, name, nil, filter.."|RAID") then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY CASTABLE|r")
					return true
				end
			end

			if E:IsFilterApplied(config.include_relevant, playerSpec) then
				local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

				if hasCustom and showForMySpec then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY RELEVANT|r")
					return true
				end
			end
		else
			if E:IsFilterApplied(config.show_all_friendly_debuffs, playerSpec) then
				return true
			end

			if E:IsFilterApplied(config.include_dispellable, playerSpec) then
				if UnitAura(unit, name, nil, filter.."|RAID") then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY DISPELLABLE|r")
					return true
				end
			end

			if E:IsFilterApplied(config.include_relevant, playerSpec) then
				local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

				if hasCustom and showForMySpec then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY RELEVANT (MY SPEC)|r")
					return true
				end
			end
		end
	end

	-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526JUNK|r")
	return false
end



local function UpdateDebuffsPosition(self)
	local rows = mceil(self.visibleBuffs / 8)
	local debuffs = self.__owner.Debuffs

	debuffs:ClearAllPoints()
	debuffs:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 26 * rows) -- 22 + 4
end

function UF:CreateBuffs(parent, unit, count)
	local rows = mceil(count / 8)
	local frame = CreateFrame("Frame", "$parentBuffs", parent)
	frame:SetSize(204, 22 * rows + 4 * (rows - 1)) -- 22 * 8 + 4 * 7

	frame["num"] = count
	frame["size"] = 22
	frame["spacing-x"] = 4
	frame["spacing-y"] = 4
	frame.showStealableBuffs = true

	frame.aura_config = C.units[unit].auras
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = CustomAuraFilter
	frame.PostUpdate = UpdateDebuffsPosition

	return frame
end

function UF:CreateDebuffs(parent, unit, count)
	local rows = mceil(count / 8)
	local frame = CreateFrame("Frame", "$parentDebuffs", parent)
	frame:SetSize(204, 22 * rows + 4 * (rows - 1)) -- 22 * 8 + 4 * 7

	frame["growth-x"] = "LEFT"
	frame["initialAnchor"] = "BOTTOMRIGHT"
	frame["num"] = count
	frame["size"] = 22
	frame["spacing-x"] = 4
	frame["spacing-y"] = 4
	frame["showType"] = true

	frame.aura_config = C.units[unit].auras
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = CustomAuraFilter

	return frame
end
