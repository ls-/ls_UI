local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF
local COLORS = M.colors
local HPCOLORS = COLORS.healprediction
local THREATCOLORS = COLORS.threat
local ICONS = M.textures.inlineicons

local tcontains = tContains

local UnitIsDeadOrGhost, UnitIsConnected, UnitIsPlayer, UnitIsUnit, UnitIsTapped, UnitIsTappedByPlayer, UnitIsWildBattlePet, UnitIsBattlePetCompanion =
	UnitIsDeadOrGhost, UnitIsConnected, UnitIsPlayer, UnitIsUnit, UnitIsTapped, UnitIsTappedByPlayer, UnitIsWildBattlePet, UnitIsBattlePetCompanion
local UnitReaction, UnitName, UnitClass, UnitRace, UnitCreatureType, UnitEffectiveLevel, UnitBattlePetLevel =
	UnitReaction, UnitName, UnitClass, UnitRace, UnitCreatureType, UnitEffectiveLevel, UnitBattlePetLevel
local UnitGetTotalAbsorbs, UnitGetTotalHealAbsorbs = UnitGetTotalAbsorbs, UnitGetTotalHealAbsorbs
local GetCreatureDifficultyColor = GetCreatureDifficultyColor

local SHEEPABLE_TYPES = {
	"Beast", "Wildtier", "Bestia", "Bête", "Fera", "Животное", "야수", "野兽", "野獸",
	"Humanoid", "Humanoide", "Humanoïde", "Umanoide", "Гуманоид", "인간형", "人型生物", "人形生物",
}

oUF.Tags.Methods["custom:color"] = function(unit)
	local color
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		color = COLORS.disconnected
	elseif UnitIsPlayer(unit) then
		color = COLORS.class[select(2, UnitClass(unit))]
	elseif UnitIsUnit(unit, "target") and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = COLORS.tapped
	else
		color = COLORS.reaction[UnitReaction(unit, "player")]
	end

 	if color then
		return E:RGBToHEX(color)
	else
		return "ffffff"
	end
end

oUF.Tags.Methods["custom:name"] = function(unit, r)
	local color = oUF.Tags.Methods["custom:color"](r or unit)
	local name = UnitName(r or unit)
	return "|cff"..color..(name or UNKNOWN).."|r"
end

oUF.Tags.Events["custom:name"] = "UNIT_NAME_UPDATE UNIT_HEALTH UNIT_CONNECTION"

oUF.Tags.Methods["custom:racetype"] = function(unit)
	local raceType
	if UnitIsPlayer(unit) then
		raceType = UnitRace(unit)
		return raceType
	else
		raceType = UnitCreatureType(unit)
		return raceType
	end
end

oUF.Tags.Events["custom:racetype"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["custom:healabsorb"] = function(unit)
	local healAbsorb = UnitGetTotalHealAbsorbs("player") or 0
	local color = E:RGBToHEX(HPCOLORS.healabsorb)
	if healAbsorb > 0 then
		return "|cff"..color.."-|r"..E:NumberFormat(healAbsorb)
	else
		return " "
	end
end

oUF.Tags.Events["custom:healabsorb"] = "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["custom:damageabsorb"] = function(unit)
	local damageAbsorb = UnitGetTotalAbsorbs(unit) or 0
	local color = E:RGBToHEX(HPCOLORS.damageabsorb)
	if damageAbsorb > 0 then
		return "|cff"..color.."+|r"..E:NumberFormat(damageAbsorb)
	else
		return " "
	end
end

oUF.Tags.Events["custom:damageabsorb"] = "UNIT_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["custom:difficulty"] = function(unit)
	local l = UnitEffectiveLevel(unit)
	return "|cff"..E:RGBToHEX(GetCreatureDifficultyColor((l > 0) and l or 199))
end

oUF.Tags.Methods["custom:effectivelevel"] = function(unit)
	local l = UnitEffectiveLevel(unit)
	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		l = UnitBattlePetLevel(unit)
	end

	if l > 0 then
		return l
	else
		return "??"
	end
end

oUF.Tags.Events["custom:effectivelevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

oUF.Tags.Methods["ls:questicon"] = function(unit)
	if UnitIsQuestBoss(unit) then
		return format(ICONS["QUEST"], 0, 0)
	else
		-- return format(ICONS["QUEST"], 0, 0)
		return ""
	end
end

oUF.Tags.Events["ls:questicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:classicon"] = function(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		if class then
			return format(ICONS[class], 0, 0)
		else
			return ""
		end
	else
		-- return format(ICONS["QUEST"], 0, 0)
		return ""
	end
end

oUF.Tags.Events["ls:classicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:sheepicon"] = function(unit)
	if (UnitIsPlayer(unit) or tcontains(SHEEPABLE_TYPES, UnitCreatureType(unit))) and
		UnitCanAttack("player", unit) and (E.playerclass == "MAGE" or E.playerclass == "SHAMAN") then
		return format(ICONS["SHEEP"], 0, 0)
	else
		-- return format(ICONS["QUEST"], 0, 0)
		return ""
	end
end

oUF.Tags.Events["ls:sheepicon"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["ls:pvpicon"] = function(unit)
	local faction = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) then
		return format(ICONS["FFA"], 0, 0)
	elseif UnitIsPVP(unit) and faction and faction ~= "Neutral" then
		return format(ICONS[strupper(faction)], 0, 0)
	else
		-- return format(ICONS["QUEST"], 0, 0)
		return ""
	end
end

oUF.Tags.Events["ls:pvpicon"] = "UNIT_FACTION"

oUF.Tags.Methods["ls:phaseicon"] = function(unit)
	if not UnitInPhase(unit) then
		return format(ICONS["PHASE"], 0, 0)
	else
		-- return format(ICONS["QUEST"], 0, 0)
		return ""
	end
end

oUF.Tags.Events["ls:phaseicon"] = "UNIT_PHASE"

oUF.Tags.Methods["ls:leadericon"] = function(unit)
	if (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit) then
		return format(ICONS["LEADER"], 0, 0)
	else
		-- return format(ICONS["QUEST"], 0, 0)
		return ""
	end
end

oUF.Tags.Events["ls:leadericon"] = "PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE"

oUF.Tags.Methods["ls:lfdroleicon"] = function(unit)
	local role = UnitGroupRolesAssigned(unit)

	if role and role ~= "NONE" then
		return format(ICONS[role], 0, 0)
	else
		-- return format(ICONS["QUEST"], 0, 0)
		return ""
	end
end

oUF.Tags.Events["ls:lfdroleicon"] = "GROUP_ROSTER_UPDATE"

oUF.Tags.Methods["ls:combatresticon"] = function(unit, realunit)
	if UnitAffectingCombat("player") then
		return format(ICONS["COMBAT"], 0, 0)
	else
		if IsResting() then
			return format(ICONS["RESTING"], 0, 0)
		else
			-- return format(ICONS["QUEST"], 0, 0)
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

	-- status = "|TInterface\\RaidFrame\\Raid-Icon-DebuffCurse:0:0:0:0:16:16:2:14:2:14|t"
	-- status = status.."|TInterface\\RaidFrame\\Raid-Icon-DebuffDisease:0:0:0:0:16:16:2:14:2:14|t"
	-- status = status.."|TInterface\\RaidFrame\\Raid-Icon-DebuffMagic:0:0:0:0:16:16:2:14:2:14|t"
	-- status = status.."|TInterface\\RaidFrame\\Raid-Icon-DebuffPoison:0:0:0:0:16:16:2:14:2:14|t"

	return status
end

oUF.Tags.Events["ls:debuffstatus"] = "UNIT_AURA"
