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

local BLACKLIST = {
	[  8326] = true, -- Ghost
	[ 26013] = true, -- Deserter
	[ 39953] = true, -- A'dal's Song of Battle
	[ 57819] = true, -- Argent Champion
	[ 57820] = true, -- Ebon Champion
	[ 57821] = true, -- Champion of the Kirin Tor
	[ 71041] = true, -- Dungeon Deserter
	[ 72968] = true, -- Precious's Ribbon
	[ 85612] = true, -- Fiona's Lucky Charm
	[ 85613] = true, -- Gidwin's Weapon Oil
	[ 85614] = true, -- Tarenar's Talisman
	[ 85615] = true, -- Pamela's Doll
	[ 85616] = true, -- Vex'tul's Armbands
	[ 85617] = true, -- Argus' Journal
	[ 85618] = true, -- Rimblat's Stone
	[ 85619] = true, -- Beezil's Cog
	[ 93337] = true, -- Champion of Ramkahen
	[ 93339] = true, -- Champion of the Earthen Ring
	[ 93341] = true, -- Champion of the Guardians of Hyjal
	[ 93347] = true, -- Champion of Therazane
	[ 93368] = true, -- Champion of the Wildhammer Clan
	[ 93795] = true, -- Stormwind Champion
	[ 93805] = true, -- Ironforge Champion
	[ 93806] = true, -- Darnassus Champion
	[ 93811] = true, -- Exodar Champion
	[ 93816] = true, -- Gilneas Champion
	[ 93821] = true, -- Gnomeregan Champion
	[ 93825] = true, -- Orgrimmar Champion
	[ 93827] = true, -- Darkspear Champion
	[ 93828] = true, -- Silvermoon Champion
	[ 93830] = true, -- Bilgewater Champion
	[ 94158] = true, -- Champion of the Dragonmaw Clan
	[ 94462] = true, -- Undercity Champion
	[ 94463] = true, -- Thunder Bluff Champion
	[ 97340] = true, -- Guild Champion
	[ 97341] = true, -- Guild Champion
	[126434] = true, -- Tushui Champion
	[126436] = true, -- Huojin Champion
	[143625] = true, -- Brawling Champion
	[170616] = true, -- Pet Deserter
	[182957] = true, -- Treasures of Stormheim
	[182958] = true, -- Treasures of Azsuna
	[185719] = true, -- Treasures of Val'sharah
	[186401] = true, -- Sign of the Skirmisher
	[186403] = true, -- Sign of Battle
	[186404] = true, -- Sign of the Emissary
	[186406] = true, -- Sign of the Critter
	[188741] = true, -- Treasures of Highmountain
	[199416] = true, -- Treasures of Suramar
	[225787] = true, -- Sign of the Warrior
	[225788] = true, -- Sign of the Emissary
	[227723] = true, -- Mana Divining Stone
	[231115] = true, -- Treasures of Broken Shore
}

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
		-- blacklist
		if BLACKLIST[spellID] then
			return false
		end

		local config = frame.cfg
		local isFriend = UnitIsFriend("player", unit)
		local friendlyBuffFlag = (isFriend and not aura.isDebuff) and E:GetPlayerSpecFlag() or 0x00000000
		local hostileBuffFlag = (not isFriend and not aura.isDebuff) and bit.lshift(E:GetPlayerSpecFlag(), 4) or 0x00000000
		local friendlyDebuffFlag = (isFriend and aura.isDebuff) and bit.lshift(E:GetPlayerSpecFlag(), 8) or 0x00000000
		local hostileDebuffFlag = (not isFriend and aura.isDebuff) and bit.lshift(E:GetPlayerSpecFlag(), 12) or 0x00000000
		local isPlayerAura = aura.isPlayer or (caster and UnitIsUnit(caster, "pet"))
		isBossAura = isBossAura or caster and (UnitIsUnit(caster, "boss1") or UnitIsUnit(caster, "boss2") or UnitIsUnit(caster, "boss3") or UnitIsUnit(caster, "boss4") or UnitIsUnit(caster, "boss5"))

		-- boss
		if isBossAura then
			-- print(name, spellID, caster, "|cffe5a526BOSS|r")
			return E:CheckFlag(config.show_boss, hostileDebuffFlag, friendlyDebuffFlag, hostileBuffFlag, friendlyBuffFlag)
		end

		-- mounts
		if MOUNTS[spellID] then
			-- print(name, spellID, caster, "|cffe5a526MOUNT|r")
			return E:CheckFlag(config.show_mount, hostileBuffFlag, friendlyBuffFlag)
		end

		-- self-cast
		if caster and UnitIsUnit(unit, caster) then
			if duration and duration ~= 0 then
				-- print(name, spellID, caster, "|cffe5a526SELFCAST|r")
				return E:CheckFlag(config.show_selfcast, hostileDebuffFlag, friendlyDebuffFlag, hostileBuffFlag, friendlyBuffFlag)
			else
				-- print(name, spellID, caster, "|cffe5a526PERMA-SELFCAST|r")
				return E:CheckFlag(config.show_selfcast_permanent, hostileDebuffFlag, friendlyDebuffFlag, hostileBuffFlag, friendlyBuffFlag)
			end
		end

		-- applied by player
		if isPlayerAura and duration and duration ~= 0 then
			return E:CheckFlag(config.show_player, hostileDebuffFlag, friendlyDebuffFlag, hostileBuffFlag, friendlyBuffFlag)
		end

		if isFriend then
			-- NOTE: Do not release! Defined by blizzard
			-- local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

			-- if hasCustom and showForMySpec and E:CheckFlag(config.show_blizzard, hostileDebuffFlag, friendlyDebuffFlag, hostileBuffFlag, friendlyBuffFlag) then
			-- 	print(name, spellID, caster, "|cffe5a526DEFINED BY BLIZZARD|r")
			-- 	return true
			-- end

			if aura.filter == "HARMFUL"then
				-- dispellable
				if debuffType and E:IsDispellable(debuffType) then
					-- print(name, spellID, caster, "|cffe5a526DISPELLABLE|r")
					return E:CheckFlag(config.show_dispellable, friendlyBuffFlag)
				end
			end
		else
			-- NOTE: Do not release! Defined by blizzard
			-- local hasCustom, _, showForMySpec = SpellGetVisibilityInfo(spellID, "ENEMY_TARGET")

			-- if hasCustom and showForMySpec and E:CheckFlag(config.show_blizzard, hostileDebuffFlag, friendlyDebuffFlag, hostileBuffFlag) then
			-- 	print(name, spellID, caster, "|cffe5a526DEFINED BY BLIZZARD|r")
			-- 	return true
			-- end

			-- stealable
			if isStealable and not UnitIsUnit(unit, "player") then
				-- print(name, spellID, caster, "|cffe5a526STEALABLE|r")
				return E:CheckFlag(config.show_dispellable, hostileBuffFlag)
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
