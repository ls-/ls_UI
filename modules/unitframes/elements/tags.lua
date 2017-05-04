local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF

--Lua
local _G = getfenv(0)
local string = _G.string
local t_contains = _G.tContains

-- Blizz
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL:gsub("%s", "")
local UnitEffectiveLevel = _G.UnitEffectiveLevel
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitIsPlayer = _G.UnitIsPlayer
local UnitReaction = _G.UnitReaction
local UnitClassification = _G.UnitClassification

-- Mine
local SHEEPABLE_TYPES = {
	"Beast", "Wildtier", "Bestia", "Bête", "Fera", "Животное", "야수", "野兽", "野獸",
	"Humanoid", "Humanoide", "Humanoïde", "Umanoide", "Гуманоид", "인간형", "人型生物", "人形生物",
}

------------
-- COLOUR --
------------

oUF.Tags.Events["ls:color:class"] = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:color:class"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)

		if class then
			return "|cff"..M.COLORS.CLASS[class]:GetHEX()
		end
	end

	return "|cffffffff"
end

oUF.Tags.Events["ls:color:reaction"] = "UNIT_FACTION UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:color:reaction"] = function(unit)
	local reaction = UnitReaction(unit, 'player')

	if reaction then
		return "|cff"..M.COLORS.REACTION[reaction]:GetHEX()
	end

	return "|cffffffff"
end

oUF.Tags.Events["ls:color:difficulty"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["ls:color:difficulty"] = function(unit)
	return "|cff"..E:GetCreatureDifficultyColor(UnitEffectiveLevel(unit)):GetHEX()
end

----------
-- NAME --
----------

oUF.Tags.Events["ls:name"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name"] = function(unit, r)
	local name = UnitName(r or unit) or ""

	return name
end

oUF.Tags.Events["ls:name:5"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name:5"] = function(unit, r)
	local name = UnitName(r or unit) or ""

	return name ~= "" and E:TruncateString(name, 5) or name
end

oUF.Tags.Events["ls:name:10"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name:10"] = function(unit, r)
	local name = UnitName(r or unit) or ""

	return name ~= "" and E:TruncateString(name, 10) or name
end

oUF.Tags.Events["ls:name:15"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name:15"] = function(unit, r)
	local name = UnitName(r or unit) or ""

	return name ~= "" and E:TruncateString(name, 15) or name
end

oUF.Tags.Events["ls:name:20"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name:20"] = function(unit, r)
	local name = UnitName(r or unit) or ""

	return name ~= "" and E:TruncateString(name, 20) or name
end

oUF.Tags.Events["ls:server"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:server"] = function(unit, r)
	local _, realm = UnitName(r or unit)

	if realm and realm ~= "" then
		local relationship = _G.UnitRealmRelationship(r or unit)

		if relationship ~= _G.LE_REALM_RELATION_VIRTUAL then
			return FOREIGN_SERVER_LABEL
		end
	end

	return ""
end

-----------
-- CLASS --
-----------

oUF.Tags.Events["ls:npc:type"] = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:npc:type"] = function(unit)
	local t = UnitClassification(unit)

	if t == "rare" then
		return "R"
	elseif t == "rareelite" then
		return "R+"
	elseif t == "elite" then
		return "+"
	elseif t == "worldboss" then
		return "B"
	elseif t == "minus" then
		return "-"
	else
		return ""
	end
end

oUF.Tags.Events["ls:player:class"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["ls:player:class"] = function(unit)
	if UnitIsPlayer(unit) then
		local class = UnitClass(unit)

		if class then
			return class
		end
	end

	return ""
end

------------
-- ABSORB --
------------

oUF.Tags.Events["ls:absorb:heal"] = "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Methods["ls:absorb:heal"] = function(unit)
	local absorb = _G.UnitGetTotalHealAbsorbs(unit) or 0
	local hex = M.COLORS.HEALPREDICTION.HEAL_ABSORB:GetHEX()

	return absorb > 0 and string.format("|cff%s-|r%s", hex, E:NumberFormat(absorb, 1)) or " "
end

oUF.Tags.Events["ls:absorb:damage"] = "UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Methods["ls:absorb:damage"] = function(unit)
	local absorb = _G.UnitGetTotalAbsorbs(unit) or 0
	local hex = M.COLORS.HEALPREDICTION.DAMAGE_ABSORB:GetHEX()

	return absorb > 0 and string.format("|cff%s+|r%s", hex, E:NumberFormat(absorb, 1)) or " "
end

-----------
-- LEVEL --
-----------

oUF.Tags.Methods["ls:level"] = function(unit)
	local level = _G.UnitLevel(unit)

	if _G.UnitIsWildBattlePet(unit) or _G.UnitIsBattlePetCompanion(unit) then
		level = _G.UnitBattlePetLevel(unit)
	end

	if level > 0 then
		return level
	else
		return "??"
	end
end

oUF.Tags.Events["ls:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

oUF.Tags.Methods["ls:level:effective"] = function(unit)
	local level = _G.UnitEffectiveLevel(unit)

	if _G.UnitIsWildBattlePet(unit) or _G.UnitIsBattlePetCompanion(unit) then
		level = _G.UnitBattlePetLevel(unit)
	end

	if level > 0 then
		return level
	else
		return "??"
	end
end

oUF.Tags.Events["ls:level:effective"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

----------
-- MISC --
----------

oUF.Tags.Events["ls:debuffs"] = "UNIT_AURA"
oUF.Tags.Methods["ls:debuffs"] = function(unit)
	-- return "|TInterface\\RaidFrame\\Raid-Icon-DebuffCurse:0:0:0:0:16:16:2:14:2:14|t|TInterface\\RaidFrame\\Raid-Icon-DebuffDisease:0:0:0:0:16:16:2:14:2:14|t|TInterface\\RaidFrame\\Raid-Icon-DebuffMagic:0:0:0:0:16:16:2:14:2:14|t|TInterface\\RaidFrame\\Raid-Icon-DebuffPoison:0:0:0:0:16:16:2:14:2:14|t"

	local types = E:GetDispelTypes()

	if not types or not _G.UnitCanAssist("player", unit) then return "" end

	local hasDebuff = {Curse = false, Disease = false, Magic = false, Poison = false}
	local status = ""

	for i = 1, 40 do
		local name, _, _, _, debuffType = _G.UnitDebuff(unit, i, "RAID")

		if name then
			if types[debuffType] and not hasDebuff[debuffType] then
				status = status.."|TInterface\\RaidFrame\\Raid-Icon-Debuff"..debuffType..":0:0:0:0:16:16:2:14:2:14|t"
				hasDebuff[debuffType] = true
			end
		else
			break
		end
	end

	return status
end

oUF.Tags.Events["ls:classicon"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["ls:classicon"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)

		if class then
			return M.textures.inlineicons[class]:format(0, 0)
		end
	end

	return ""
end

oUF.Tags.Methods["ls:questicon"] = function(unit)
	if _G.UnitIsQuestBoss(unit) then
		return M.textures.inlineicons["QUEST"]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:questicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:sheepicon"] = function(unit)
	if _G.UnitCanAttack("player", unit)
		and (UnitIsPlayer(unit) or t_contains(SHEEPABLE_TYPES, _G.UnitCreatureType(unit)))
		and (E.PLAYER_CLASS == "MAGE" or E.PLAYER_CLASS == "SHAMAN") then
		return M.textures.inlineicons["SHEEP"]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:sheepicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:phaseicon"] = function(unit)
	if not _G.UnitInPhase(unit) then
		return M.textures.inlineicons["PHASE"]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:phaseicon"] = "UNIT_PHASE"

oUF.Tags.Methods["ls:leadericon"] = function(unit)
	if (_G.UnitInParty(unit) or _G.UnitInRaid(unit)) and _G.UnitIsGroupLeader(unit) then
		return M.textures.inlineicons["LEADER"]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:leadericon"] = "PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"

oUF.Tags.Methods["ls:lfdroleicon"] = function(unit)
	local role = _G.UnitGroupRolesAssigned(unit)

	if role and role ~= "NONE" then
		return M.textures.inlineicons[role]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:lfdroleicon"] = "GROUP_ROSTER_UPDATE"

oUF.Tags.Methods["ls:combatresticon"] = function()
	if _G.UnitAffectingCombat("player") then
		return M.textures.inlineicons["COMBAT"]:format(0, 0)
	else
		if _G.IsResting() then
			return M.textures.inlineicons["RESTING"]:format(0, 0)
		else
			return ""
		end
	end
end

oUF.Tags.Events["ls:combatresticon"] = "PLAYER_UPDATE_RESTING PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED"

oUF.Tags.SharedEvents["PLAYER_REGEN_DISABLED"] = true
oUF.Tags.SharedEvents["PLAYER_REGEN_ENABLED"] = true

oUF.Tags.Methods["ls:pvptimer"] = function()
	if _G.IsPVPTimerRunning() then
		local pattern, time = _G.SecondsToTimeAbbrev(_G.GetPVPTimer() / 1000)
		if time >= 1 then
			return pattern:gsub(" ", ""):format(time)
		end
	end
end
