local _, ns = ...
local E, C, M, L, P, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.oUF

--Lua
local _G = getfenv(0)
local string = _G.string
local tcontains = _G.tContains

-- Blizz
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL:gsub("%s", "")

-- Mine
local SHEEPABLE_TYPES = {
	"Beast", "Wildtier", "Bestia", "Bête", "Fera", "Животное", "야수", "野兽", "野獸",
	"Humanoid", "Humanoide", "Humanoïde", "Umanoide", "Гуманоид", "인간형", "人型生物", "人形生物",
}

oUF.Tags.Methods["ls:unitcolor"] = function(unit, r)
	return "|cff"..E:GetUnitColor(r or unit, false, true, true, true):GetHEX()
end

oUF.Tags.Events["ls:unitcolor"] = "UNIT_HEALTH UNIT_CONNECTION UNIT_THREAT_SITUATION_UPDATE UNIT_FACTION"

oUF.Tags.Methods["ls:name"] = function(unit, r)
	local name = _G.UnitName(r or unit)

	return name or _G.UNKNOWN
end

oUF.Tags.Events["ls:name"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["ls:server"] = function(unit, r)
	local _, realm = _G.UnitName(r or unit)

	if realm and realm ~= "" then
		local relationship = _G.UnitRealmRelationship(r or unit)

		if relationship ~= _G.LE_REALM_RELATION_VIRTUAL then
			return FOREIGN_SERVER_LABEL
		end
	end

	return ""
end

oUF.Tags.Events["ls:server"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["ls:healabsorb"] = function(unit)
	local healAbsorb = _G.UnitGetTotalHealAbsorbs(unit) or 0
	local hex = M.COLORS.HEALPREDICTION.HEAL_ABSORB:GetHEX()

	if healAbsorb > 0 then
		return string.format("|cff%s-|r%s", hex, E:NumberFormat(healAbsorb, 1))
	else
		return " "
	end
end

oUF.Tags.Events["ls:healabsorb"] = "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["ls:damageabsorb"] = function(unit)
	local damageAbsorb = _G.UnitGetTotalAbsorbs(unit) or 0
	local hex = M.COLORS.HEALPREDICTION.DAMAGE_ABSORB:GetHEX()

	if damageAbsorb > 0 then
		return string.format("|cff%s+|r%s", hex, E:NumberFormat(damageAbsorb, 1))
	else
		return " "
	end
end

oUF.Tags.Events["ls:damageabsorb"] = "UNIT_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["ls:difficulty"] = function(unit)
	return "|cff"..E:GetCreatureDifficultyColor(_G.UnitEffectiveLevel(unit)):GetHEX()
end

oUF.Tags.Methods["ls:effectivelevel"] = function(unit)
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

oUF.Tags.Events["ls:effectivelevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

oUF.Tags.Methods["ls:questicon"] = function(unit)
	if _G.UnitIsQuestBoss(unit) then
		return M.textures.inlineicons["QUEST"]:format(0, 0)
	else
		return ""
	end
end

oUF.Tags.Events["ls:questicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:classicon"] = function(unit)
	if _G.UnitIsPlayer(unit) then
		local _, class = _G.UnitClass(unit)

		if class then
			return M.textures.inlineicons[class]:format(0, 0)
		else
			return ""
		end
	else
		return ""
	end
end

oUF.Tags.Events["ls:classicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:sheepicon"] = function(unit)
	if _G.UnitCanAttack("player", unit)
		and (_G.UnitIsPlayer(unit) or tcontains(SHEEPABLE_TYPES, _G.UnitCreatureType(unit)))
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

oUF.Tags.Methods["ls:debuffstatus"] = function(unit)
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

oUF.Tags.Events["ls:debuffstatus"] = "UNIT_AURA"

oUF.Tags.Methods["ls:pvptimer"] = function()
	if _G.IsPVPTimerRunning() then
		local pattern, time = _G.SecondsToTimeAbbrev(_G.GetPVPTimer() / 1000)
		if time >= 1 then
			return pattern:gsub(" ", ""):format(time)
		end
	end
end
