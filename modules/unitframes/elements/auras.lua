local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local m_max = _G.math.max
local m_min = _G.math.min
local next = _G.next
local unpack = _G.unpack

-- Blizz
local C_MountJournal = _G.C_MountJournal
local UnitIsFriend = _G.UnitIsFriend
local UnitIsUnit = _G.UnitIsUnit

--[[ luacheck: globals
	CreateFrame GameTooltip UIParent
]]

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
	[245686] = true, -- Fashionable!
	[264408] = true, -- Soldier of the Horde
	[264420] = true, -- Soldier of the Alliance
	[269083] = true, -- Enlisted
}

local ICONS = {
	["Buff"] = {1 / 128, 33 / 128, 1 / 128, 33 / 128},
	["Debuff"] = {34 / 128, 66 / 128, 1 / 128, 33 / 128},
	["Curse"] = {67 / 128, 99 / 128, 1 / 128, 33 / 128},
	["Disease"] = {1 / 128, 33 / 128, 34 / 128, 66 / 128},
	["Magic"] = {34 / 128, 66 / 128, 34 / 128, 66 / 128},
	["Poison"] = {67 / 128, 99 / 128, 34 / 128, 66 / 128},
}

local function isUnitBoss(unit)
	return unit and (UnitIsUnit(unit, "boss1") or UnitIsUnit(unit, "boss2") or UnitIsUnit(unit, "boss3") or UnitIsUnit(unit, "boss4") or UnitIsUnit(unit, "boss5"))
end

local filterFunctions = {
	default = function(element, unit, aura, _, _, _, debuffType, duration, _, caster, isStealable, _, spellID, _, isBossAura)
		-- blacklist
		if BLACKLIST[spellID] then
			return false
		end

		local isFriend = UnitIsFriend("player", unit)
		local config = element._config and element._config.filter or nil

		if config then
			config = isFriend and config.friendly or config.enemy

			if config then
				config = aura.isDebuff and config.debuff or config.buff
			else
				return
			end
		else
			return
		end

		isBossAura = isBossAura or isUnitBoss(caster)

		-- boss
		if isBossAura then
			-- print(name, spellID, caster, "|cffe5a526BOSS|r")
			return config.boss
		end

		-- mounts
		if MOUNTS[spellID] then
			-- print(name, spellID, caster, "|cffe5a526MOUNT|r")
			return config.mount
		end

		-- self-cast
		if caster and UnitIsUnit(unit, caster) then
			if duration and duration ~= 0 then
				-- print(name, spellID, caster, "|cffe5a526SELFCAST|r")
				return config.selfcast
			else
				-- print(name, spellID, caster, "|cffe5a526PERMA-SELFCAST|r")
				return config.selfcast and config.selfcast_permanent
			end
		end

		-- applied by player
		if aura.isPlayer or (caster and UnitIsUnit(caster, "pet")) then
			if duration and duration ~= 0 then
				return config.player
			else
				return config.player and config.player_permanent
			end
		end

		if isFriend then
			if aura.isDebuff then
				-- dispellable
				if debuffType and E:IsDispellable(debuffType) then
					-- print(name, spellID, caster, "|cffe5a526DISPELLABLE|r")
					return config.dispellable
				end
			end
		else
			-- stealable
			if isStealable then
				-- print(name, spellID, caster, "|cffe5a526STEALABLE|r")
				return config.dispellable
			end
		end

		return false
	end,
	boss = function(element, unit, aura, _, _, _, debuffType, duration, _, caster, isStealable, _, _, _, isBossAura)
		local isFriend = UnitIsFriend("player", unit)
		local config = element._config and element._config.filter or nil

		if config then
			config = isFriend and config.friendly or config.enemy

			if config then
				config = aura.isDebuff and config.debuff or config.buff
			else
				return
			end
		else
			return
		end

		isBossAura = isBossAura or isUnitBoss(caster)

		-- boss
		if isBossAura then
			-- print(name, spellID, caster, "|cffe5a526BOSS|r")
			return config.boss
		end

		-- applied by player
		if aura.isPlayer or (caster and UnitIsUnit(caster, "pet")) then
			if duration and duration ~= 0 then
				return config.player
			else
				return config.player and config.player_permanent
			end
		end

		if isFriend then
			if aura.isDebuff then
				-- dispellable
				if debuffType and E:IsDispellable(debuffType) then
					-- print(name, spellID, caster, "|cffe5a526DISPELLABLE|r")
					return config.dispellable
				end
			end
		else
			-- stealable
			if isStealable then
				-- print(name, spellID, caster, "|cffe5a526STEALABLE|r")
				return config.dispellable
			end
		end

		return false
	end,
}

local function overlay_HideOverride(self)
	self:SetVertexColor(1, 1, 1)
end

local function button_UpdateTooltip(self)
	GameTooltip:SetUnitAura(self:GetParent().__owner.unit, self:GetID(), self.filter)
end

local function button_OnEnter(self)
	if not self:IsVisible() then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local function button_OnLeave()
	GameTooltip:Hide()
end

local function element_CreateAuraIcon(element, index)
	local config = element._config
	local button = E:CreateButton(element, "$parentAura" .. index, true)

	button.icon = button.Icon
	button.Icon = nil

	local count = button.Count
	count:SetAllPoints()
	count:SetFontObject("LSFont" .. config.text.size .. (config.text.outline and "_Outline" or ""))
	count:SetJustifyH(config.text.h_alignment)
	count:SetJustifyV(config.text.v_alignment)
	count:SetWordWrap(false)

	if config.text.shadow then
		count:SetShadowOffset(1, -1)
	else
		count:SetShadowOffset(0, 0)
	end

	button.count = count
	button.Count = nil

	button.cd = button.CD
	button.CD = nil

	if button.cd.UpdateConfig then
		button.cd:UpdateConfig(element.cooldownConfig or {})
		button.cd:UpdateFontObject()
	end

	button:SetPushedTexture("")
	button:SetHighlightTexture("")

	button.overlay = button.Border
	button.overlay.Hide = overlay_HideOverride
	button.Border = nil

	local stealable = button.FGParent:CreateTexture(nil, "OVERLAY", nil, 2)
	stealable:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Stealable")
	stealable:SetTexCoord(2 / 32, 30 / 32, 2 / 32, 30 / 32)
	stealable:SetPoint("TOPLEFT", -1, 1)
	stealable:SetPoint("BOTTOMRIGHT", 1, -1)
	stealable:SetBlendMode("ADD")
	button.stealable = stealable

	local auraType = button.FGParent:CreateTexture(nil, "OVERLAY", nil, 3)
	auraType:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons")
	auraType:SetPoint(config.type.position, 0, 0)
	auraType:SetSize(config.type.size, config.type.size)
	button.AuraType = auraType

	button.UpdateTooltip = button_UpdateTooltip
	button:SetScript("OnEnter", button_OnEnter)
	button:SetScript("OnLeave", button_OnLeave)

	return button
end

local function element_PostUpdateIcon(self, _, aura, _, _, _, _, debuffType)
	if aura.isDebuff then
		if self._config.type.debuff_type then
			aura.AuraType:SetTexCoord(unpack(ICONS[debuffType] or ICONS["Debuff"]))
		else
			aura.AuraType:SetTexCoord(unpack(ICONS["Debuff"]))
		end
	else
		aura.AuraType:SetTexCoord(unpack(ICONS["Buff"]))
	end
end

local function element_UpdateConfig(element)
	element._config = E:CopyTable(element.__owner._config.auras, element._config)
end

local function element_UpdateCooldownConfig(element)
	if not element.cooldownConfig then
		element.cooldownConfig = {
			colors = {},
			text = {},
		}
	end

	element.cooldownConfig.exp_threshold = C.db.profile.units.cooldown.exp_threshold
	element.cooldownConfig.m_ss_threshold = C.db.profile.units.cooldown.m_ss_threshold
	element.cooldownConfig.colors = E:CopyTable(C.db.profile.units.cooldown.colors, element.cooldownConfig.colors)
	element.cooldownConfig.text = E:CopyTable(element._config.cooldown.text, element.cooldownConfig.text)

	for i = 1, #element do
		if not element[i].cd.UpdateConfig then
			break
		end

		element[i].cd:UpdateConfig(element.cooldownConfig)
		element[i].cd:UpdateFontObject()
	end
end

local function element_UpdateFonts(element)
	local config = element._config.text
	local fontObj = "LSFont" .. config.size .. (config.outline and "_Outline" or "")
	local count

	for i = 1, element.createdIcons do
		count = element[i].count
		count:SetFontObject(fontObj)
		count:SetJustifyH(config.h_alignment)
		count:SetJustifyV(config.v_alignment)
		count:SetWordWrap(false)

		if config.shadow then
			count:SetShadowOffset(1, -1)
		else
			count:SetShadowOffset(0, 0)
		end
	end
end

local function element_UpdateAuraTypeIcon(element)
	local config = element._config.type
	local auraType

	for i = 1, element.createdIcons do
		auraType = element[i].AuraType
		auraType:ClearAllPoints()
		auraType:SetPoint(config.position, 0, 0)
		auraType:SetSize(config.size, config.size)
	end
end

local function frame_UpdateAuras(self)
	local element = self.Auras
	element:UpdateConfig()
	element:UpdateCooldownConfig()

	local config = element._config
	local size = config.size_override ~= 0 and config.size_override
		or E:Round((self._config.width - (element.spacing * (config.per_row - 1)) + 2) / config.per_row)
	size = m_min(m_max(size, 24), 64)

	element.size = size
	element.numTotal = config.per_row * config.rows
	element.disableMouse = config.disable_mouse
	element["growth-x"] = config.x_growth
	element["growth-y"] = config.y_growth

	if config.y_growth == "UP" then
		if config.x_growth == "RIGHT" then
			element.initialAnchor = "BOTTOMLEFT"
		else
			element.initialAnchor = "BOTTOMRIGHT"
		end
	else
		if config.x_growth == "RIGHT" then
			element.initialAnchor = "TOPLEFT"
		else
			element.initialAnchor = "TOPRIGHT"
		end
	end

	element:SetSize((size * config.per_row + element.spacing * (config.per_row - 1)), size * config.rows + element.spacing * (config.rows - 1))
	element:ClearAllPoints()

	local point1 = config.point1
	if point1 and point1.p then
		element:SetPoint(point1.p, E:ResolveAnchorPoint(self, point1.anchor), point1.rP, point1.x, point1.y)
	end

	element:UpdateAuraTypeIcon()
	element:UpdateFonts()

	if config.enabled and not self:IsElementEnabled("Auras") then
		self:EnableElement("Auras")
	elseif not config.enabled and self:IsElementEnabled("Auras") then
		self:DisableElement("Auras")
	end

	if self:IsElementEnabled("Auras") then
		element:ForceUpdate()
	end
end

function UF:CreateAuras(frame, unit)
	local element = CreateFrame("Frame", nil, frame)
	element:SetSize(48, 48)

	element.showDebuffType = true
	element.showStealableBuffs = true
	element.spacing = 4
	element.CreateIcon = element_CreateAuraIcon
	element.CustomFilter = filterFunctions[unit] or filterFunctions.default
	element.PostUpdateIcon = element_PostUpdateIcon
	element.UpdateAuraTypeIcon = element_UpdateAuraTypeIcon
	element.UpdateConfig = element_UpdateConfig
	element.UpdateCooldownConfig = element_UpdateCooldownConfig
	element.UpdateFonts = element_UpdateFonts

	frame.UpdateAuras = frame_UpdateAuras

	return element
end
