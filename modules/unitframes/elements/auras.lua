local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local math = _G.math
local bit = _G.bit
local next = _G.next

-- Blizz
local C_MountJournal = _G.C_MountJournal
local SpellGetVisibilityInfo = _G.SpellGetVisibilityInfo
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitIsFriend = _G.UnitIsFriend
local UnitIsUnit = _G.UnitIsUnit

-- Mine
local AURA_GAP = 4
local AURA_SIZE = 28
local AURAS_PER_ROW = 6
local MOUNTS = {}

for _, id in next, C_MountJournal.GetMountIDs() do
	local _, spellID = C_MountJournal.GetMountInfoByID(id)

	MOUNTS[spellID] = true
end

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

	local stealable = button.Cover:CreateTexture(nil, "OVERLAY", nil, 2)
	stealable:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Stealable")
	stealable:SetTexCoord(2 / 32, 30 / 32, 2 / 32, 30 / 32)
	stealable:SetPoint("TOPLEFT", -1, 1)
	stealable:SetPoint("BOTTOMRIGHT", 1, -1)
	stealable:SetBlendMode("ADD")
	button.stealable = stealable

	local auraType = button.Cover:CreateTexture(nil, "OVERLAY", nil, 3)
	auraType:SetSize(16, 16)
	auraType:SetPoint("TOPLEFT", -2, 2)
	button.AuraType = auraType

	button.UpdateTooltip = UpdateTooltip
	button:SetScript("OnEnter", AuraButton_OnEnter)
	button:SetScript("OnLeave", AuraButton_OnLeave)

	return button
end

local filterFunctions = {
	default = function(frame, unit, aura, _, _, _, count, debuffType, duration, _, caster, isStealable, _, spellID, _, isBossAura)
		local config = frame.cfg
		local friendlyFlag = E:GetPlayerSpecFlag()
		local enemyFlag = bit.lshift(friendlyFlag, 4)
		local buffFlag = bit.lshift(friendlyFlag, 8)
		local debuffFlag = bit.lshift(friendlyFlag, 12)
		local isPlayerAura = aura.isPlayer or (caster and UnitIsUnit(caster, "pet"))
		isBossAura = isBossAura or caster and (UnitIsUnit(caster, "boss1") or UnitIsUnit(caster, "boss2") or UnitIsUnit(caster, "boss3") or UnitIsUnit(caster, "boss4") or UnitIsUnit(caster, "boss5"))

		-- boss
		if isBossAura and E:CheckFlag(config.show_boss, debuffFlag, buffFlag, enemyFlag, friendlyFlag) then
			-- print(name, spellID, caster, "|cffe5a526BOSS|r")
			return true
		end

		-- mounts
		if MOUNTS[spellID] and E:CheckFlag(config.show_mount, enemyFlag, friendlyFlag) then
			-- print(name, spellID, caster, "|cffe5a526MOUNT|r")
			return true
		end

		-- non-permanent self-cast
		if caster and UnitIsUnit(unit, caster) and duration and duration ~= 0 and E:CheckFlag(config.show_selfcast, debuffFlag, buffFlag, enemyFlag, friendlyFlag) then
			-- print(name, spellID, caster, "|cffe5a526SELFCAST|r")
			return true
		end

		-- applied by player
		if isPlayerAura and duration and duration ~= 0 and E:CheckFlag(config.show_player, debuffFlag, buffFlag, enemyFlag, friendlyFlag) then
			-- print(name, spellID, caster, "|cffe5a526APPLIED BY PLAYER|r")
			return true
		end

		if UnitIsFriend("player", unit) then
			-- defined by blizzard
			local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

			if hasCustom and showForMySpec and E:CheckFlag(config.show_blizzard, debuffFlag, buffFlag, enemyFlag, friendlyFlag) then
				-- print(name, spellID, caster, "|cffe5a526DEFINED BY BLIZZARD|r")
				return true
			end

			if aura.filter == "HARMFUL"then
				-- dispellable
				if debuffType and E:IsDispellable(debuffType) and E:CheckFlag(config.show_dispellable, friendlyFlag) then
					-- print(name, spellID, caster, "|cffe5a526DISPELLABLE|r")
					return true
				end

				-- NOTE: sometimes both caster and isBossAura params are nil, it'll be fixed in 7.2
				if count > 1 and E:CheckFlag(config.show_boss, friendlyFlag) then
					-- print(name, spellID, caster, "|cffe5a526SBOSS (HACK)|r")
					return true
				end
			end
		else
			-- defined by blizzard
			local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")

			if hasCustom and showForMySpec and E:CheckFlag(config.show_blizzard, debuffFlag, buffFlag, enemyFlag) then
				-- print(name, spellID, caster, "|cffe5a526DEFINED BY BLIZZARD|r")
				return true
			end

			-- stealable
			if isStealable and not UnitIsUnit(unit, "player") and E:CheckFlag(config.show_dispellable, enemyFlag) then
				-- print(name, spellID, caster, "|cffe5a526STEALABLE|r")
				return true
			end
		end

		return false
	end
}

local function UpdateAuraType(_, _, aura)
	if aura.isDebuff then
		aura.AuraType:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Weak")
	else
		aura.AuraType:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Strong")
	end
end

function UF:CreateAuras(parent, unit, num, size, gap, perRow)
	size = size or AURA_SIZE
	gap = gap or AURA_GAP
	perRow = perRow or AURAS_PER_ROW
	local rows = math.ceil(num / perRow)

	local frame = _G.CreateFrame("Frame", "$parentAuras", parent)
	frame:SetSize(size * math.min(num, perRow) + gap * math.min(num - 1, perRow - 1), size * rows + gap * (rows - 1))

	frame.numBuffs = num / 2
	frame.numDebuffs = num / 2
	frame.size = size
	frame["spacing-x"] = gap
	frame["spacing-y"] = gap
	frame.showStealableBuffs = true
	frame.showDebuffType = true
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = filterFunctions[unit] or filterFunctions.default
	frame.PostUpdateIcon = UpdateAuraType
	frame.cfg = C.units[unit].auras

	return frame
end

function UF:CreateBuffs(parent, unit, num, size, gap, perRow)
	size = size or AURA_SIZE
	gap = gap or AURA_GAP
	perRow = perRow or AURAS_PER_ROW
	local rows = math.ceil(num / perRow)

	local frame = _G.CreateFrame("Frame", "$parentBuffs", parent)
	frame:SetSize(size * math.min(num, perRow) + gap * math.min(num - 1, perRow - 1), size * rows + gap * (rows - 1))

	frame.num = num
	frame.size = size
	frame["spacing-x"] = gap
	frame["spacing-y"] = gap
	frame.showStealableBuffs = true
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = filterFunctions[unit] or filterFunctions.default
	frame.cfg = C.units[unit].auras

	return frame
end

function UF:CreateDebuffs(parent, unit, num, size, gap, perRow)
	size = size or AURA_SIZE
	gap = gap or AURA_GAP
	perRow = perRow or AURAS_PER_ROW
	local rows = math.ceil(num / perRow)

	local frame = _G.CreateFrame("Frame", "$parentDebuffs", parent)
	frame:SetSize(size * math.min(num, perRow) + gap * math.min(num - 1, perRow - 1), size * rows + gap * (rows - 1))

	frame.num = num
	frame.size = size
	frame["spacing-x"] = gap
	frame["spacing-y"] = gap
	frame.showType = true
	frame.CreateIcon = CreateAuraIcon
	frame.CustomFilter = filterFunctions[unit] or filterFunctions.default
	frame.cfg = C.units[unit].auras

	return frame
end
