local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L

-- Lua
local _G = _G
local pairs, tonumber, select = pairs, tonumber, select
local strupper, strgsub, strmatch = string.upper, string.gsub, string.match
local mfloor = math.floor

-- Mine
local ITEM_LEVEL_PATTERN = strgsub(ITEM_LEVEL, "%%d", "(%%d+)")
local INSPECT_ARMOR_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
local INSPECT_WEAPON_SLOTS = {16, 17}
local playerSpec = _G.GetSpecialization() or 0
local playerRole
local dispelTypesByClass = {
	PALADIN = {},
	SHAMAN = {},
	DRUID = {},
	PRIEST = {},
	MONK = {},
	MAGE = {},
}

local ScanTooltip = _G.CreateFrame("GameTooltip", "LSiLevelScanTooltip", nil, "GameTooltipTemplate")
ScanTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")

function E:GetUnitClassColor(unit)
	local color

	if unit then
		color = M.colors.class[select(2, _G.UnitClass(unit))]
	end

	color = color or {1, 1, 1}

	return {r = color[1], g = color[2], b = color[3], hex = E:RGBToHEX(color)}
end

function E:GetCreatureDifficultyColor(level)
	local color = _G.GetCreatureDifficultyColor(level > 0 and level or 199)

	return {r = color.r, g = color.g, b = color.b, hex = E:RGBToHEX(color)}
end

function E:GetUnitReactionColor(unit)
	local color

	if unit then
		color = M.colors.reaction[_G.UnitReaction(unit, "player")]
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
		elseif not _G.UnitPlayerControlled(unit) and _G.UnitIsTapDenied(unit) then
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
		if(_G.UnitIsMercenary(unit)) then
			if(faction == "Horde") then
				faction = "Alliance"
			elseif(faction == "Alliance") then
				faction = "Horde"
			end
		end

		return true, strupper(faction)
	else
		return
	end
end

function E:GetPlayerSpec()
	return playerSpec
end

function E:GetPlayerSpecFlag()
	return E.PLAYER_SPEC_FLAGS[playerSpec]
end

function E:GetPlayerRole()
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
	return dispelTypesByClass[E.PLAYER_CLASS]
end

function E:SPELLS_CHANGED(...)
	local dispelTypes = dispelTypesByClass[E.PLAYER_CLASS]

	if dispelTypes then
		if E.PLAYER_CLASS == "PALADIN" then
			dispelTypes.Disease = _G.IsPlayerSpell(4987) or _G.IsPlayerSpell(213644) or nil -- Cleanse or Cleanse Toxins
			dispelTypes.Magic = _G.IsPlayerSpell(4987) or nil -- Cleanse
			dispelTypes.Poison = dispelTypes.Disease
		elseif E.PLAYER_CLASS == "SHAMAN" then
			dispelTypes.Curse = _G.IsPlayerSpell(51886) or _G.IsPlayerSpell(77130) or nil -- Cleanse Spirit or Purify Spirit
			dispelTypes.Magic = _G.IsPlayerSpell(77130) or nil -- Purify Spirit
		elseif E.PLAYER_CLASS == "DRUID" then
			dispelTypes.Curse = _G.IsPlayerSpell(2782) or _G.IsPlayerSpell(88423) or nil -- Remove Corruption or Nature's Cure
			dispelTypes.Magic = _G.IsPlayerSpell(88423) or nil -- Nature's Cure
			dispelTypes.Poison = dispelTypes.Curse
		elseif E.PLAYER_CLASS == "PRIEST"  then
			dispelTypes.Disease = _G.IsPlayerSpell(527) or nil -- Purify
			dispelTypes.Magic = _G.IsPlayerSpell(527) or _G.IsPlayerSpell(32375) or nil -- Purify or Mass Dispel
		elseif E.PLAYER_CLASS == "MONK" then
			dispelTypes.Disease = _G.IsPlayerSpell(115450) or nil -- Detox
			dispelTypes.Magic = dispelTypes.Disease
			dispelTypes.Poison = dispelTypes.Disease
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
	if not itemLink then return end

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
	if _G.UnitIsUnit(unit, "player") then
		local _, avgItemLevelEquipped = _G.GetAverageItemLevel()

		return mfloor(avgItemLevelEquipped)
	else
		local isInspectSuccessful = true
		local iLevelTotal = 0
		for _, id in pairs(INSPECT_ARMOR_SLOTS) do
			local itemLink = _G.GetInventoryItemLink(unit, id)
			local hasItem = ScanTooltip:SetInventoryItem(unit, id)
			if itemLink then
				local iLevel = E:GetItemLevel(itemLink)
				if iLevel and iLevel > 0 then
					iLevelTotal = iLevelTotal + iLevel
				end
			else
				if hasItem then
					isInspectSuccessful = false
				end
			end
		end

		local numItems = 14
		for _, id in pairs(INSPECT_WEAPON_SLOTS) do
			local itemLink = _G.GetInventoryItemLink(unit, id)
			local hasItem = ScanTooltip:SetInventoryItem(unit, id)
			if itemLink then
				local iLevel = E:GetItemLevel(itemLink)
				if iLevel and iLevel > 0 then
					numItems = numItems + 1
					iLevelTotal = iLevelTotal + iLevel
				end
			else
				if hasItem then
					isInspectSuccessful = false
				end
			end
		end

		numItems = numItems < 15 and 15 or numItems

		-- print(numItems, "total:", iLevelTotal, "cur:", mfloor(iLevelTotal / numItems), isInspectSuccessful and "SUCCESS!" or "FAIL!")
		return isInspectSuccessful and mfloor(iLevelTotal / numItems)
	end
end

E:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
E:RegisterEvent("SPELLS_CHANGED")
