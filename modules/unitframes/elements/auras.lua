local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local b_lshift = _G.bit.lshift
local next = _G.next

-- Blizz
local C_MountJournal = _G.C_MountJournal
local UnitIsFriend = _G.UnitIsFriend
local UnitIsUnit = _G.UnitIsUnit

-- Mine
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
	[233641] = true, -- Legionfall Commander
	[237137] = true, -- Knowledgeable
	[237139] = true, -- Power Overwhelming
	[239966] = true, -- War Effort
	[239967] = true, -- Seal Your Fate
	[239968] = true, -- Fate Smiles Upon You
	[239969] = true, -- Netherstorm
	[240979] = true, -- Reputable
	[240980] = true, -- Light As a Feather
	[240985] = true, -- Reinforced Reins
	[240986] = true, -- Worthy Champions
	[240987] = true, -- Well Prepared
	[240989] = true, -- Heavily Augmented
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

local function CreateAuraIcon(element, index)
	local button = E:CreateButton(element, "$parentAura"..index, true)

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
	default = function(frame, unit, aura, _, _, _, _, debuffType, duration, _, caster, isStealable, _, spellID, _, isBossAura)
		-- blacklist
		if BLACKLIST[spellID] then
			return false
		end

		local config = frame._config
		local isFriend = UnitIsFriend("player", unit)
		local friendlyBuffFlag = (isFriend and not aura.isDebuff) and E:GetPlayerSpecFlag() or 0x00000000
		local hostileBuffFlag = (not isFriend and not aura.isDebuff) and b_lshift(E:GetPlayerSpecFlag(), 4) or 0x00000000
		local friendlyDebuffFlag = (isFriend and aura.isDebuff) and b_lshift(E:GetPlayerSpecFlag(), 8) or 0x00000000
		local hostileDebuffFlag = (not isFriend and aura.isDebuff) and b_lshift(E:GetPlayerSpecFlag(), 12) or 0x00000000
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
			if aura.filter == "HARMFUL"then
				-- dispellable
				if debuffType and E:IsDispellable(debuffType) then
					-- print(name, spellID, caster, "|cffe5a526DISPELLABLE|r")
					return E:CheckFlag(config.show_dispellable, friendlyBuffFlag)
				end
			end
		else
			-- stealable
			if isStealable and not UnitIsUnit(unit, "player") then
				-- print(name, spellID, caster, "|cffe5a526STEALABLE|r")
				return E:CheckFlag(config.show_dispellable, hostileBuffFlag)
			end
		end

		return false
	end,
	boss = function(frame, unit, aura, _, _, _, _, _, _, _, caster, _, _, _, _, isBossAura)
		local config = frame._config
		local isFriend = UnitIsFriend("player", unit)
		local friendlyBuffFlag = (isFriend and not aura.isDebuff) and E:GetPlayerSpecFlag() or 0x00000000
		local hostileBuffFlag = (not isFriend and not aura.isDebuff) and b_lshift(E:GetPlayerSpecFlag(), 4) or 0x00000000
		local friendlyDebuffFlag = (isFriend and aura.isDebuff) and b_lshift(E:GetPlayerSpecFlag(), 8) or 0x00000000
		local hostileDebuffFlag = (not isFriend and aura.isDebuff) and b_lshift(E:GetPlayerSpecFlag(), 12) or 0x00000000
		isBossAura = isBossAura or caster and (UnitIsUnit(caster, "boss1") or UnitIsUnit(caster, "boss2") or UnitIsUnit(caster, "boss3") or UnitIsUnit(caster, "boss4") or UnitIsUnit(caster, "boss5"))

		-- boss
		if isBossAura then
			-- print(name, spellID, caster, "|cffe5a526BOSS|r")
			return E:CheckFlag(config.show_boss, hostileDebuffFlag, friendlyDebuffFlag, hostileBuffFlag, friendlyBuffFlag)
		end

		return false
	end,
}

local function UpdateAuraType(_, _, aura)
	if aura.isDebuff then
		aura.AuraType:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Weak")
	else
		aura.AuraType:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Strong")
	end
end

function UF:CreateAuras(parent, unit)
	local element = _G.CreateFrame("Frame", nil, parent)

	element.spacing = 4
	element.showDebuffType = true
	element.showStealableBuffs = true
	element.CreateIcon = CreateAuraIcon
	element.CustomFilter = filterFunctions[unit] or filterFunctions.default
	element.PostUpdateIcon = UpdateAuraType
	element._config = C.db.profile.units[C.db.char.layout][unit].auras

	return element
end

function UF:UpdateAuras(frame)
	local config = frame._config.auras
	local element = frame.Auras
	local size = config.size_override ~= 0 and config.size_override or E:Round((frame._config.width - (element.spacing * (config.per_row - 1)) + 2) / config.per_row)

	element:SetSize((size * config.per_row + element.spacing * (config.per_row - 1)), size * config.rows + element.spacing * (config.rows - 1))

	element.size = size
	element.numTotal = config.per_row * config.rows
	element.initialAnchor = config.init_anchor
	element.disableMouse = config.disable_mouse
	element["growth-x"] = config.x_growth
	element["growth-y"] = config.y_grwoth

	local point1 = config.point1

	if point1 and point1.p then
		element:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)
	end

	if config.enabled and not frame:IsElementEnabled("Auras") then
		frame:EnableElement("Auras")
	elseif not config.enabled and frame:IsElementEnabled("Auras") then
		frame:DisableElement("Auras")
	end

	if frame:IsElementEnabled("Auras") then
		element:ForceUpdate()
	end
end
