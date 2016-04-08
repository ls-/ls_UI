local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L

-- Lua
local _G = _G
local pairs, tonumber, select = pairs, tonumber, select
local strupper, strgsub, strmatch = string.upper, string.gsub, string.match
local mfloor = math.floor

-- Mine
local _, playerClass = _G.UnitClass("player")
local playerSpec = _G.GetSpecialization() or 0
local playerRole

local ScanTooltip = _G.CreateFrame("GameTooltip", "LSiLevelScanTooltip", nil, "GameTooltipTemplate")
ScanTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")

local dispelTypesByClass = {
	PALADIN = {},
	SHAMAN = {},
	DRUID = {},
	PRIEST = {},
	MONK = {},
	MAGE = {},
}

local ITEM_LEVEL_PATTERN = strgsub(ITEM_LEVEL, "%%d", "(%%d+)")

local INSPECT_ILVL_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}

function E:GetCreatureDifficultyColor(level)
	local color = _G.GetCreatureDifficultyColor(level > 0 and level or 199)

	return {r = color.r, g = color.g, b = color.b, hex = E:RGBToHEX(color)}
end

function E:GetUnitReactionColor(unit)
	local color
	if unit then
		color = M.colors.reaction[_G.UnitReaction(unit, "player")]
	end

	color = color or M.colors.reaction[4] -- use Neutral faction colour by default

	return {r = color[1], g = color[2], b = color[3], hex = E:RGBToHEX(color)}
end

function E:GetUnitClassColor(unit)
	local color

	if unit then
		local _, class = _G.UnitClass(unit)
		color = M.colors.class[class]
	end

	color = color or M.colors.reaction[4]

	return {r = color[1], g = color[2], b = color[3], hex = E:RGBToHEX(color)}
end

function E:GetSmartReactionColor(unit)
	local color

	if unit then
		if _G.UnitIsDeadOrGhost(unit) or not _G.UnitIsConnected(unit) then
			color = M.colors.disconnected
		elseif _G.UnitIsPlayer(unit) then
			color = M.colors.class[select(2, _G.UnitClass(unit))]
		elseif not _G.UnitIsUnit(unit, "player") and _G.UnitIsTapped(unit) and not _G.UnitIsTappedByPlayer(unit) then
			color = M.colors.tapped
		else
			color = M.colors.reaction[_G.UnitReaction(unit, "player")]
		end
	end

	color = color or M.colors.reaction[4]

	return {r = color[1], g = color[2], b = color[3], hex = E:RGBToHEX(color)}
end

function E:GetUnitClassification(unit)
	if not unit then return "" end

	local c = _G.UnitClassification(unit)

	if c == "rare" then
		return "R"
	elseif c == "rareelite" then
		return "R+"
	elseif c == "elite" then
		return "+"
	elseif c == "worldboss" then
		return "B"
	elseif c == "minus" then
		return "-"
	else
		return ""
	end
end

function E:GetUnitPVPStatus(unit)
	local faction = _G.UnitFactionGroup(unit)

	if _G.UnitIsPVPFreeForAll(unit) then
		return true, "FFA"
	elseif _G.UnitIsPVP(unit) and faction and faction ~= "Neutral" then
		return true, strupper(faction)
	else
		return
	end
end

function E:GetPlayerClass()
	return playerClass
end

function E:GetPlayerSpec()
	return playerSpec
end

function E:GetPlayerSpecFlag()
	return M.PLAYER_SPEC_FLAGS[playerSpec]
end

function E:GetPlayerRole(spec)
	local _, _, _, _, _, role = _G.GetSpecializationInfo(playerSpec)
	return role or "DAMAGER"
end

function E:PLAYER_SPECIALIZATION_CHANGED()
	local oldSpec = playerSpec
	local oldRole = playerRole

	playerSpec = _G.GetSpecialization() or 0
	playerRole = E:GetPlayerRole(playerSpec)

	-- if oldSpec ~= playerSpec then
		-- do smth
	-- end

	-- if oldRole ~= playerRole then
		-- do smth
	-- end
end

function E:GetDispelTypes()
	return dispelTypesByClass[playerClass]
end

function E:SPELLS_CHANGED(...)
	local dispelTypes = dispelTypesByClass[playerClass]

	if dispelTypes then
		if playerClass == "PALADIN" then
			dispelTypes.Disease = _G.IsPlayerSpell(4987) or nil -- Cleanse
			dispelTypes.Magic = _G.IsPlayerSpell(53551) or nil -- Sacred Cleansing
			dispelTypes.Poison = dispelTypes.Disease
		elseif playerClass == "SHAMAN" then
			dispelTypes.Curse = _G.IsPlayerSpell(51886) or _G.IsPlayerSpell(77130) or nil -- Cleanse Spirit or Purify Spirit
			dispelTypes.Magic = _G.IsPlayerSpell(77130) or nil -- Purify Spirit
		elseif playerClass == "DRUID" then
			dispelTypes.Curse = _G.IsPlayerSpell(2782) or _G.IsPlayerSpell(88423) or nil -- Remove Corruption or Nature's Cure
			dispelTypes.Magic = _G.IsPlayerSpell(88423) or nil -- Nature's Cure
			dispelTypes.Poison = dispelTypes.Curse
		elseif playerClass == "PRIEST"  then
			dispelTypes.Disease = _G.IsPlayerSpell(527) or nil -- Purify
			dispelTypes.Magic = _G.IsPlayerSpell(527) or _G.IsPlayerSpell(32375) or nil -- Purify or Mass Dispel
		elseif playerClass == "MONK" then
			dispelTypes.Disease = _G.IsPlayerSpell(115450) or nil -- Detox
			dispelTypes.Magic = _G.IsPlayerSpell(115451) or nil -- Internal Medicine
			dispelTypes.Poison = dispelTypes.Disease
		elseif playerClass == "MAGE" then
			dispelTypes.Curse = _G.IsPlayerSpell(475) or nil -- Remove Curse
		end
	end
end

function E:GetUnitSpecializationInfo(unit)
	local isPlayer = _G.UnitIsUnit(unit, "player")
	local specID = isPlayer and playerSpec or _G.GetInspectSpecialization(unit)

	if specID and specID > 0 then
		if isPlayer then
			local _, name = _G.GetSpecializationInfo(specID)

			return name
		else
			if _G.GetSpecializationRoleByID(specID) then
				local _, name = _G.GetSpecializationInfoByID(specID)

				return name
			end
		end
	end
end

function E:GetItemLevel(itemLink)
	ScanTooltip:ClearLines()
	ScanTooltip:SetHyperlink(itemLink)

	for i = 2, ScanTooltip:NumLines() do
		local text = _G["LSiLevelScanTooltipTextLeft"..i]:GetText()

		if(text and text ~= "") then
			local iLevel = tonumber(strmatch(text, ITEM_LEVEL_PATTERN))

			if iLevel then
				return iLevel
			end
		end
	end
end

function E:GetUnitAverageItemLevel(unit)
	local isPlayer = _G.UnitIsUnit(unit, "player")

	if isPlayer then
		local _, avgItemLevelEquipped = _G.GetAverageItemLevel()

		return mfloor(avgItemLevelEquipped)
	else
		local iLevelTotal, numItems = 0
		for _, id in pairs(INSPECT_ILVL_SLOTS) do
			local itemLink = _G.GetInventoryItemLink(unit, id)
			if itemLink then
				local iLevel = E:GetItemLevel(itemLink)
				if iLevel and iLevel > 0 then
					numItems = (numItems or 0) + 1
					iLevelTotal = iLevelTotal + iLevel
				end
			end
		end

		return numItems and mfloor(iLevelTotal / numItems)
	end
end

E:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
E:RegisterEvent("SPELLS_CHANGED")
