local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

-- Lua
local _G = _G
local mceil, mmin = math.ceil, math.min

-- Blizz
local IsInInstance = IsInInstance
local SpellGetVisibilityInfo = SpellGetVisibilityInfo
local SpellIsAlwaysShown = SpellIsAlwaysShown
local UnitAffectingCombat = UnitAffectingCombat
local UnitAura = UnitAura
local UnitCanAssist = UnitCanAssist
local UnitCanAttack = UnitCanAttack
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled

-- Mine
local AURA_GAP = 4
local AURA_SIZE = 28
local AURAS_PER_ROW = 6

local function SetVertexColorOverride(self, r, g, b)
	local button = self:GetParent()

	if not r then
		button:SetBorderColor(1, 1, 1)
	else
		button:SetBorderColor(r, g, b)
	end
end

local function UpdateTooltip(self)
	_G.GameTooltip:SetUnitAura(self:GetParent().__owner.unit, self:GetID(), self.filter)
end

local function AuraButton_OnEnter(self)
	if not self:IsVisible() then return end

	_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local function AuraButton_OnLeave()
	_G.GameTooltip:Hide()
end

local function CreateAuraIcon(frame, index)
	local button = E:CreateButton(frame, "$parentButton"..index, true)

	button.icon = button.Icon
	button.Icon = nil

	button.count = button.Count
	button.Count = nil

	button.cd = button.CD
	button.CD = nil

	if button.cd.SetTimerTextHeight then
		button.cd:SetTimerTextHeight(10)

		button.cd.Timer:SetJustifyV("BOTTOM")
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

local filterFunctions = {
	default = function(frame, unit, aura, ...)
		local filter = aura.filter
		local playerSpec = E:GetPlayerSpecFlag()

		if not E:IsFilterApplied(frame.aura_config.enabled, playerSpec) then return false end

		local config = frame.aura_config[filter]
		local name, _, _, _, debuffType, _, _, caster, isStealable, _, spellID, _, isBossAura = ...
		local isMine = aura.isPlayer or caster == "pet"
		local hostileTarget = UnitCanAttack("player", unit) or not UnitCanAssist("player", unit)
		local dispelTypes = E:GetDispelTypes()

		if E:IsFilterApplied(frame.aura_config.show_only_filtered, playerSpec) then
			if config.auralist[spellID] and E:IsFilterApplied(config.auralist[spellID], playerSpec) then
				-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526OVERRIDE|r")
				return true
			end

			return false
		end

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
		elseif not caster and filter == "HARMFUL" then
			if not IsInInstance() then
				-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526UNKNOWN (JUNK, NOT IN INSTANCE)|r")
				return false
			else
				-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526UNKNOWN (IN INSTANCE)|r")
				return true
			end
		end

		if hostileTarget then -- hostile
			if filter == "HELPFUL" then
				-- ALWAYS shown
				if not UnitPlayerControlled(unit) and caster and UnitIsUnit(unit, caster) then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE NPC SELFCAST|r")
					return true
				end

				if isStealable then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe52626HOSTILE STEALABLE|r")
					return true
				end
			elseif filter == "HARMFUL" then
				-- ALWAYS shown
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
		else -- friendly
			if filter == "HELPFUL" then
				if E:IsFilterApplied(config.include_castable, playerSpec) then
					if UnitAura(unit, name, nil, filter.."|RAID") then
						-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY CASTABLE|r")
						return true
					end
				end

				-- ALWAYS shown
				local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

				if hasCustom and showForMySpec then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY RELEVANT|r")
					return true
				end
			elseif filter == "HARMFUL" then
				if dispelTypes and dispelTypes[debuffType] and UnitAura(unit, name, nil, filter.."|RAID") then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY DISPELLABLE|r")
					return true
				end

				-- ALWAYS shown
				local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

				if hasCustom and showForMySpec then
					-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cff26a526FRIENDLY RELEVANT (MY SPEC)|r")
					return true
				end
			end
		end

		-- print(filter == "HELPFUL" and "|cff26a526"..filter.."|r" or "|cffe52626"..filter.."|r", name, spellID, "|cffe5a526JUNK|r")
		return false
	end,
	party = function(frame, unit, aura, ...)
		local name, _, _, _, debuffType, _, _, _, _, _, spellID, _, isBossAura = ...
		local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
		local dispelTypes = E:GetDispelTypes()
		local filter = aura.filter

		if isBossAura then
			return true
		elseif dispelTypes and dispelTypes[debuffType] and UnitAura(unit, name, nil, filter.."|RAID") then
			-- dispellable debuffs
			return true
		elseif hasCustom and showForMySpec then
			-- something defined by blizz
			return true
		elseif (E.PLAYER_CLASS == "PALADIN" and spellID == 25771) or (E.PLAYER_CLASS == "PRIEST" and spellID == 6788) then
			-- Forbearance and Weakened Soul
			return true
		end

		-- Temporal Displacement, Sated, Exhaustion, Insanity, Fatigued
		-- if spellID == 80354 or spellID == 57724 or spellID == 57723 or spellID == 95809 or spellID == 160455 then
		-- 	return true
		-- end

		return false
	end,
}

local function UpdateDebuffsPosition(self)
	local rows = mceil(self.visibleBuffs / AURAS_PER_ROW)
	local debuffs = self.__owner.Debuffs

	debuffs:ClearAllPoints()
	debuffs:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, (AURA_SIZE + AURA_GAP) * rows)
end

function UF:CreateBuffs(parent, unit, count)
	local rows = mceil(count / AURAS_PER_ROW)
	local frame = _G.CreateFrame("Frame", nil, parent)
	frame:SetSize(AURA_SIZE * mmin(count, AURAS_PER_ROW) + AURA_GAP * mmin(count - 1, AURAS_PER_ROW - 1), AURA_SIZE * rows + AURA_GAP * (rows - 1))

	frame["num"] = count
	frame["size"] = AURA_SIZE
	frame["spacing-x"] = AURA_GAP
	frame["spacing-y"] = AURA_GAP
	frame.showStealableBuffs = true

	frame.aura_config = C.units[unit].auras
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = filterFunctions[unit] or filterFunctions.default
	-- frame.CustomFilter = function() return true end
	frame.PostUpdate = UpdateDebuffsPosition

	return frame
end

function UF:CreateDebuffs(parent, unit, count, growthDirectionX, initAnchor)
	local rows = mceil(count / AURAS_PER_ROW)
	local frame = _G.CreateFrame("Frame", "$parentDebuffs", parent)
	frame:SetSize(AURA_SIZE * mmin(count, AURAS_PER_ROW) + AURA_GAP * mmin(count - 1, AURAS_PER_ROW - 1), AURA_SIZE * rows + AURA_GAP * (rows - 1))

	frame["growth-x"] = growthDirectionX
	frame["initialAnchor"] = initAnchor
	frame["num"] = count
	frame["size"] = AURA_SIZE
	frame["spacing-x"] = AURA_GAP
	frame["spacing-y"] = AURA_GAP
	frame["showType"] = true

	frame.aura_config = C.units[unit].auras
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = filterFunctions[unit] or filterFunctions.default
	-- frame.CustomFilter = function() return true end

	return frame
end

-- local function CustomAuraFilterOverride()
-- 	return true
-- end

-- local alteredState = false
-- function UF:MODIFIER_STATE_CHANGED(...)
-- 	if not alteredState then
-- 		if IsControlKeyDown() and IsShiftKeyDown() then
-- 			for _, object in pairs(oUF.objects) do
-- 				local buffs = object.Buffs
-- 				if buffs then
-- 					buffs.CustomFilter = CustomAuraFilterOverride
-- 					buffs:ForceUpdate()
-- 				end

-- 				local debuffs = object.Debuffs
-- 				if debuffs then
-- 					debuffs.CustomFilter = CustomAuraFilterOverride
-- 					debuffs:ForceUpdate()
-- 				end
-- 			end

-- 			alteredState = true
-- 		end
-- 	else
-- 		for _, object in pairs(oUF.objects) do
-- 			local buffs = object.Buffs
-- 			if buffs then
-- 				buffs.CustomFilter = CustomAuraFilter
-- 				buffs:ForceUpdate()
-- 			end

-- 			local debuffs = object.Debuffs
-- 			if debuffs then
-- 				debuffs.CustomFilter = CustomAuraFilter
-- 				debuffs:ForceUpdate()
-- 			end
-- 		end

-- 		alteredState = false
-- 	end
-- end

-- UF:RegisterEvent("MODIFIER_STATE_CHANGED")
