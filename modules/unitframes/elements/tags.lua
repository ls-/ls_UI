local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF

--Lua
local _G = getfenv(0)
local s_format = _G.string.format

-- Blizz
local ALTERNATE_POWER_INDEX = _G.ALTERNATE_POWER_INDEX or 10
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL
local GetPVPTimer = _G.GetPVPTimer
local IsPVPTimerRunning = _G.IsPVPTimerRunning
local IsResting = _G.IsResting
local SecondsToTimeAbbrev = _G.SecondsToTimeAbbrev
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitAlternatePowerInfo = _G.UnitAlternatePowerInfo
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitCanAssist = _G.UnitCanAssist
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitCreatureType = _G.UnitCreatureType
local UnitDebuff = _G.UnitDebuff
local UnitEffectiveLevel = _G.UnitEffectiveLevel
local UnitGetTotalAbsorbs = _G.UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = _G.UnitGetTotalHealAbsorbs
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitInParty = _G.UnitInParty
local UnitInPhase = _G.UnitInPhase
local UnitInRaid = _G.UnitInRaid
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsQuestBoss = _G.UnitIsQuestBoss
local UnitIsWarModePhased = _G.UnitIsWarModePhased
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction
local UnitRealmRelationship = _G.UnitRealmRelationship

-- Mine
local DEBUFF_ICON_TEMPLATE = "|TInterface\\RaidFrame\\Raid-Icon-Debuff%s:0:0:0:0:16:16:2:14:2:14|t"
local SHEEPABLE_TYPES = {
	["Beast"] = true,
	["Bestia"] = true,
	["Bête"] = true,
	["Fera"] = true,
	["Humanoid"] = true,
	["Humanoide"] = true,
	["Humanoïde"] = true,
	["Umanoide"] = true,
	["Wildtier"] = true,
	["Гуманоид"] = true,
	["Животное"] = true,
	["야수"] = true,
	["인간형"] = true,
	["人型生物"] = true,
	["人形生物"] = true,
	["野兽"] = true,
	["野獸"] = true,
}

------------
-- COLOUR --
------------

oUF.Tags.Events["ls:color:class"] = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:color:class"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)

		if class then
			return "|cff" .. M.COLORS.CLASS[class]:GetHEX()
		end
	end

	return "|cffffffff"
end

oUF.Tags.Events["ls:color:reaction"] = "UNIT_FACTION UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:color:reaction"] = function(unit)
	local reaction = UnitReaction(unit, 'player')

	if reaction then
		return "|cff" .. M.COLORS.REACTION[reaction]:GetHEX()
	end

	return "|cffffffff"
end

oUF.Tags.Events["ls:color:difficulty"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["ls:color:difficulty"] = function(unit)
	return "|cff" .. E:GetCreatureDifficultyColor(UnitEffectiveLevel(unit)):GetHEX()
end

oUF.Tags.Methods["ls:color:power"] = function(unit)
	local type, _, altR, altG, altB = UnitPowerType(unit)
	local hex

	if altR then
		hex = E:RGBToHEX(E:AdjustColor(altR, altG, altB, 0.3))
	else
		hex = M.COLORS.POWER[type]:GetHEX(0.3)
	end

	return "|cff" .. hex
end

oUF.Tags.Methods["ls:color:altpower"] = function()
	return "|cff" .. M.COLORS.INDIGO:GetHEX(0.3)
end

oUF.Tags.Methods["ls:color:absorb-damage"] = function()
	return "|cff" .. M.COLORS.HEALPREDICTION.DAMAGE_ABSORB:GetHEX(0.3)
end

oUF.Tags.Methods["ls:color:absorb-heal"] = function()
	return "|cff" .. M.COLORS.HEALPREDICTION.HEAL_ABSORB:GetHEX(0.3)
end

------------
-- HEALTH --
------------

oUF.Tags.Events["ls:health:cur"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods["ls:health:cur"] = function(unit)
	if not UnitIsConnected(unit) then
		return L["OFFLINE"]
	elseif UnitIsDeadOrGhost(unit) then
		return L["DEAD"]
	else
		return E:NumberFormat(UnitHealth(unit), 1)
	end
end

oUF.Tags.Events["ls:health:perc"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods["ls:health:perc"] = function(unit)
	if not UnitIsConnected(unit) then
		return L["OFFLINE"]
	elseif UnitIsDeadOrGhost(unit) then
		return L["DEAD"]
	else
		return s_format("%.1f%%", E:NumberToPerc(UnitHealth(unit), UnitHealthMax(unit)))
	end
end

oUF.Tags.Events["ls:health:cur-perc"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods["ls:health:cur-perc"] = function(unit)
	if not UnitIsConnected(unit) then
		return L["OFFLINE"]
	elseif UnitIsDeadOrGhost(unit) then
		return L["DEAD"]
	else
		local cur, max = UnitHealth(unit), UnitHealthMax(unit)

		if cur == max then
			return E:NumberFormat(cur, 1)
		else
			return s_format("%s - %.1f%%", E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
		end
	end
end

oUF.Tags.Events["ls:health:deficit"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
oUF.Tags.Methods["ls:health:deficit"] = function(unit)
	if not UnitIsConnected(unit) then
		return L["OFFLINE"]
	elseif UnitIsDeadOrGhost(unit) then
		return L["DEAD"]
	else
		local cur, max = UnitHealth(unit), UnitHealthMax(unit)

		if cur == max then
			return ""
		else
			return s_format("-%s", E:NumberFormat(max - cur, 1))
		end
	end
end

-----------
-- POWER --
-----------

oUF.Tags.Events["ls:power:cur"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:cur"] = function(unit)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return ""
	else
		local type = UnitPowerType(unit)
		local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)

		if not max or max == 0 then
			return ""
		else
			return E:NumberFormat(cur, 1)
		end
	end
end

oUF.Tags.Events["ls:power:max"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:max"] = function(unit)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return ""
	else
		local type = UnitPowerType(unit)
		local max = UnitPowerMax(unit, type)

		if not max or max == 0 then
			return ""
		else
			return E:NumberFormat(max, 1)
		end
	end
end

oUF.Tags.Events["ls:power:perc"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:perc"] = function(unit)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return ""
	else
		local type = UnitPowerType(unit)
		local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)

		if not max or max == 0 then
			return ""
		else
			return s_format("%.1f%%", E:NumberToPerc(cur, max))
		end
	end
end

oUF.Tags.Events["ls:power:cur-perc"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:cur-perc"] = function(unit)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return ""
	else
		local type = UnitPowerType(unit)
		local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)

		if not max or max == 0 then
			return ""
		elseif cur == max then
			return E:NumberFormat(cur, 1)
		else
			return s_format("%s - %.1f%%", E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
		end
	end
end

oUF.Tags.Events["ls:power:cur-color-perc"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:cur-color-perc"] = function(unit)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return ""
	else
		local type, _, altR, altG, altB = UnitPowerType(unit)
		local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)
		local hex

		if altR then
			hex = E:RGBToHEX(E:AdjustColor(altR, altG, altB, 0.3))
		else
			hex = M.COLORS.POWER[type]:GetHEX(0.3)
		end

		if not max or max == 0 then
			return ""
		elseif cur == 0 or cur == max then
			return s_format("|cff%s%s|r", hex, E:NumberFormat(cur, 1))
		else
			return s_format("%s - |cff%s%.1f%%|r", E:NumberFormat(cur, 1), hex, E:NumberToPerc(cur, max))
		end
	end
end

oUF.Tags.Events["ls:power:cur-max"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:cur-max"] = function(unit)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return ""
	else
		local type = UnitPowerType(unit)
		local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)

		if not max or max == 0 then
			return ""
		elseif cur == max then
			return E:NumberFormat(cur, 1)
		else
			return s_format("%s - %s", E:NumberFormat(cur, 1), E:NumberFormat(max, 1))
		end
	end
end

oUF.Tags.Events["ls:power:cur-color-max"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:cur-color-max"] = function(unit)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return ""
	else
		local type, _, altR, altG, altB = UnitPowerType(unit)
		local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)
		local hex

		if altR then
			hex = E:RGBToHEX(E:AdjustColor(altR, altG, altB, 0.3))
		else
			hex = M.COLORS.POWER[type]:GetHEX(0.3)
		end

		if not max or max == 0 then
			return ""
		elseif cur == 0 or cur == max then
			return s_format("|cff%s%s|r", hex, E:NumberFormat(cur, 1))
		else
			return s_format("%s - |cff%s%s|r", E:NumberFormat(cur, 1), hex, E:NumberFormat(max, 1))
		end
	end
end

oUF.Tags.Events["ls:power:deficit"] = 'UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER'
oUF.Tags.Methods["ls:power:deficit"] = function(unit)
	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		return ""
	else
		local type = UnitPowerType(unit)
		local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)

		if not max or max == 0 or cur == max then
			return ""
		else
			return s_format("-%s", E:NumberFormat(max - cur, 1))
		end
	end
end

---------------
-- ALT POWER --
---------------

oUF.Tags.Events["ls:altpower:cur"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:cur"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		return E:NumberFormat(UnitPower(unit, ALTERNATE_POWER_INDEX), 1)
	else
		return ""
	end
end

oUF.Tags.Events["ls:altpower:max"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:max"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		return E:NumberFormat(UnitPowerMax(unit, ALTERNATE_POWER_INDEX), 1)
	else
		return ""
	end
end

oUF.Tags.Events["ls:altpower:perc"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:perc"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		return s_format("%.1f%%", E:NumberToPerc(UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)))
	else
		return ""
	end
end

oUF.Tags.Events["ls:altpower:cur-perc"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:cur-perc"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

		if cur == max then
			return E:NumberFormat(cur, 1)
		else
			return s_format("%s - %.1f%%", E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
		end
	else
		return ""
	end
end

oUF.Tags.Events["ls:altpower:cur-color-perc"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:cur-color-perc"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

		if cur == 0 or cur == max then
			return s_format("|cff%s%s|r", M.COLORS.INDIGO:GetHEX(0.3), E:NumberFormat(cur, 1))
		else
			return s_format("%s - |cff%s%.1f%%|r", E:NumberFormat(cur, 1), M.COLORS.INDIGO:GetHEX(0.3), E:NumberToPerc(cur, max))
		end
	else
		return ""
	end
end

oUF.Tags.Events["ls:altpower:cur-max"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:cur-max"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

		if cur == max then
			return E:NumberFormat(cur, 1)
		else
			return s_format("%s - %s", E:NumberFormat(cur, 1), E:NumberFormat(max, 1))
		end
	else
		return ""
	end
end

oUF.Tags.Events["ls:altpower:cur-color-max"] = 'UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER'
oUF.Tags.Methods["ls:altpower:cur-color-max"] = function(unit)
	if UnitAlternatePowerInfo(unit) then
		local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)

		if cur == 0 or cur == max then
			return s_format("|cff%s%s|r", M.COLORS.INDIGO:GetHEX(0.3), E:NumberFormat(cur, 1))
		else
			return s_format("%s - |cff%s%.1f%%|r", E:NumberFormat(cur, 1), M.COLORS.INDIGO:GetHEX(0.3), E:NumberFormat(max, 1))
		end
	else
		return ""
	end
end

----------
-- NAME --
----------

oUF.Tags.Events["ls:name"] = "UNIT_NAME_UPDATE"
oUF.Tags.Methods["ls:name"] = function(unit, r)
	return UnitName(r or unit) or ""
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
		local relationship = UnitRealmRelationship(r or unit)

		if relationship ~= LE_REALM_RELATION_VIRTUAL then
			return L["FOREIGN_SERVER_LABEL"]
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
	local absorb = UnitGetTotalHealAbsorbs(unit) or 0

	return absorb > 0 and E:NumberFormat(absorb, 1) or " "
end

oUF.Tags.Events["ls:absorb:damage"] = "UNIT_ABSORB_AMOUNT_CHANGED"
oUF.Tags.Methods["ls:absorb:damage"] = function(unit)
	local absorb = UnitGetTotalAbsorbs(unit) or 0

	return absorb > 0 and E:NumberFormat(absorb, 1) or " "
end

-----------
-- LEVEL --
-----------

oUF.Tags.Events["ls:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["ls:level"] = function(unit)
	local level = UnitLevel(unit)

	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	end

	if level > 0 then
		return level
	else
		return "??"
	end
end

oUF.Tags.Events["ls:level:effective"] = "UNIT_LEVEL PLAYER_LEVEL_UP"
oUF.Tags.Methods["ls:level:effective"] = function(unit)
	local level = UnitEffectiveLevel(unit)

	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	end

	if level > 0 then
		return level
	else
		return "??"
	end
end

----------
-- MISC --
----------

oUF.Tags.Methods["nl"] = function() return "\n" end

oUF.Tags.Events["ls:debuffs"] = "UNIT_AURA"
oUF.Tags.Methods["ls:debuffs"] = function(unit)
	local types = E:GetDispelTypes()

	if not types or not UnitCanAssist("player", unit) then return "" end

	local hasDebuff = {Curse = false, Disease = false, Magic = false, Poison = false}
	local status = ""

	for i = 1, 40 do
		local name, _, _, type = UnitDebuff(unit, i, "RAID")

		if name then
			if types[type] and not hasDebuff[type] then
				status = status .. DEBUFF_ICON_TEMPLATE:format(type)
				hasDebuff[type] = true
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

oUF.Tags.Events["ls:questicon"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["ls:questicon"] = function(unit)
	if UnitIsQuestBoss(unit) then
		return M.textures.inlineicons["QUEST"]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:sheepicon"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["ls:sheepicon"] = function(unit)
	if UnitCanAttack("player", unit)
		and (UnitIsPlayer(unit) or SHEEPABLE_TYPES[UnitCreatureType(unit)])
		and (E.PLAYER_CLASS == "MAGE" or E.PLAYER_CLASS == "SHAMAN") then
		return M.textures.inlineicons["SHEEP"]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:phaseicon"] = "UNIT_PHASE"
oUF.Tags.Methods["ls:phaseicon"] = function(unit)
	if (not UnitInPhase(unit) or UnitIsWarModePhased(unit)) and UnitIsPlayer(unit) and UnitIsConnected(unit) then
		if UnitIsWarModePhased(unit) then
			return M.textures.inlineicons["PHASE_WM"]:format(0, 0)
		else
			return M.textures.inlineicons["PHASE"]:format(0, 0)
		end
	else
		return ""
	end
end

oUF.Tags.Events["ls:leadericon"] = "PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["ls:leadericon"] = function(unit)
	if (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit) then
		return M.textures.inlineicons["LEADER"]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:lfdroleicon"] = "GROUP_ROSTER_UPDATE"
oUF.Tags.Methods["ls:lfdroleicon"] = function(unit)
	local role = UnitGroupRolesAssigned(unit)

	if role and role ~= "NONE" then
		return M.textures.inlineicons[role]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:combatresticon"] = "PLAYER_UPDATE_RESTING PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED"
oUF.Tags.Methods["ls:combatresticon"] = function()
	if UnitAffectingCombat("player") then
		return M.textures.inlineicons["COMBAT"]:format(0, 0)
	else
		if IsResting() then
			return M.textures.inlineicons["RESTING"]:format(0, 0)
		else
			return ""
		end
	end
end

oUF.Tags.SharedEvents["PLAYER_REGEN_DISABLED"] = true
oUF.Tags.SharedEvents["PLAYER_REGEN_ENABLED"] = true
oUF.Tags.Methods["ls:pvptimer"] = function()
	if IsPVPTimerRunning() then
		local remain = GetPVPTimer() / 1000
		if remain >= 1 then
			local time1, time2, format

			if remain >= 60 then
				time1, time2, format = E:SecondsToTime(remain, "x:xx")
			else
				time1, time2, format = E:SecondsToTime(remain)
			end

			return format:format(time1, time2)
		end
	end
end
