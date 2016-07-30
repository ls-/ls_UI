local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF

--Lua
local strformat = string.format
local tcontains = tContains

--Blizz
local GetCreatureDifficultyColor = GetCreatureDifficultyColor
local IsResting = IsResting
local UnitAffectingCombat = UnitAffectingCombat
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitCanAssist = UnitCanAssist
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitCreatureType = UnitCreatureType
local UnitDebuff = UnitDebuff
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitInParty = UnitInParty
local UnitInPhase = UnitInPhase
local UnitInRaid = UnitInRaid
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsPlayer = UnitIsPlayer
local UnitIsQuestBoss = UnitIsQuestBoss
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitName = UnitName
local UnitRealmRelationship = UnitRealmRelationship
local FOREIGN_SERVER_LABEL = FOREIGN_SERVER_LABEL
local LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_VIRTUAL
local UNKNOWN = UNKNOWN

-- Mine
local SHEEPABLE_TYPES = {
	"Beast", "Wildtier", "Bestia", "Bête", "Fera", "Животное", "야수", "野兽", "野獸",
	"Humanoid", "Humanoide", "Humanoïde", "Umanoide", "Гуманоид", "인간형", "人型生物", "人形生物",
}

oUF.Tags.Methods["ls:smartreaction"] = function(unit, r)
	local color = E:GetSmartReactionColor(r or unit)

	return "|cff"..color.hex
end

oUF.Tags.Events["ls:smartreaction"] = "UNIT_HEALTH UNIT_CONNECTION UNIT_THREAT_SITUATION_UPDATE"

oUF.Tags.Methods["ls:name"] = function(unit, r)
	local name = UnitName(r or unit)

	return name or UNKNOWN
end

oUF.Tags.Events["ls:name"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["ls:server"] = function(unit, r)
	local _, realm = UnitName(r or unit)

	if realm and realm ~= "" then
		local relationship = UnitRealmRelationship(r or unit)

		if relationship ~= LE_REALM_RELATION_VIRTUAL then
			return FOREIGN_SERVER_LABEL
		else
			return ""
		end
	end
end

oUF.Tags.Events["ls:server"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["ls:healabsorb"] = function(unit)
	local healAbsorb = UnitGetTotalHealAbsorbs("player") or 0
	local color = E:RGBToHEX(M.colors.healprediction.healabsorb)

	if healAbsorb > 0 then
		return "|cff"..color.."-|r"..E:NumberFormat(healAbsorb)
	else
		return " "
	end
end

oUF.Tags.Events["ls:healabsorb"] = "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["ls:damageabsorb"] = function(unit)
	local damageAbsorb = UnitGetTotalAbsorbs(unit) or 0
	local color = E:RGBToHEX(M.colors.healprediction.damageabsorb)

	if damageAbsorb > 0 then
		return "|cff"..color.."+|r"..E:NumberFormat(damageAbsorb)
	else
		return " "
	end
end

oUF.Tags.Events["ls:damageabsorb"] = "UNIT_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["ls:difficulty"] = function(unit)
	local level = UnitEffectiveLevel(unit)
	local color = E:GetCreatureDifficultyColor(level)

	return "|cff"..color.hex
end

oUF.Tags.Methods["ls:effectivelevel"] = function(unit)
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

oUF.Tags.Events["ls:effectivelevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

oUF.Tags.Methods["ls:questicon"] = function(unit)
	if UnitIsQuestBoss(unit) then
		return strformat(M.textures.inlineicons["QUEST"], 0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:questicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:classicon"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)

		if class then
			return strformat(M.textures.inlineicons[class], 0, 0)
		else
			return ""
		end
	else
		return ""
	end
end

oUF.Tags.Events["ls:classicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:sheepicon"] = function(unit)
	if (UnitIsPlayer(unit) or tcontains(SHEEPABLE_TYPES, UnitCreatureType(unit))) and
		UnitCanAttack("player", unit) and (E.PLAYER_CLASS == "MAGE" or E.PLAYER_CLASS == "SHAMAN") then
		return strformat(M.textures.inlineicons["SHEEP"], 0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:sheepicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:phaseicon"] = function(unit)
	if not UnitInPhase(unit) then
		return strformat(M.textures.inlineicons["PHASE"], 0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:phaseicon"] = "UNIT_PHASE"

oUF.Tags.Methods["ls:leadericon"] = function(unit)
	if (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit) then
		return strformat(M.textures.inlineicons["LEADER"], 0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:leadericon"] = "PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"

oUF.Tags.Methods["ls:lfdroleicon"] = function(unit)
	local role = UnitGroupRolesAssigned(unit)

	if role and role ~= "NONE" then
		return strformat(M.textures.inlineicons[role], 0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:lfdroleicon"] = "GROUP_ROSTER_UPDATE"

oUF.Tags.Methods["ls:combatresticon"] = function()
	if UnitAffectingCombat("player") then
		return strformat(M.textures.inlineicons["COMBAT"], 0, 0)
	else
		if IsResting() then
			return strformat(M.textures.inlineicons["RESTING"], 0, 0)
		else
			return ""
		end
	end
end

oUF.Tags.Events["ls:combatresticon"] = "PLAYER_UPDATE_RESTING PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED"

oUF.Tags.SharedEvents["PLAYER_REGEN_DISABLED"] = true
oUF.Tags.SharedEvents["PLAYER_REGEN_ENABLED"] = true

oUF.Tags.Methods["ls:debuffstatus"] = function(unit)
	local types = E:GetDispelTypes()

	if not types or not UnitCanAssist("player", unit) then return "" end

	local hasDebuff = {Curse = false, Disease = false, Magic = false, Poison = false}
	local status = ""

	for i = 1, 40 do
		local name, _, _, _, debuffType = UnitDebuff(unit, i, "RAID")
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

oUF.Tags.Events["ls:debuffstatus"] = "UNIT_AURA"
