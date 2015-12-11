local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF
local COLORS = M.colors
local HPCOLORS = COLORS.healprediction
local THREATCOLORS = COLORS.threat

local UnitIsDeadOrGhost, UnitIsConnected, UnitIsPlayer, UnitIsUnit, UnitIsTapped, UnitIsTappedByPlayer, UnitIsWildBattlePet, UnitIsBattlePetCompanion =
	UnitIsDeadOrGhost, UnitIsConnected, UnitIsPlayer, UnitIsUnit, UnitIsTapped, UnitIsTappedByPlayer, UnitIsWildBattlePet, UnitIsBattlePetCompanion
local UnitReaction, UnitName, UnitClass, UnitRace, UnitCreatureType, UnitEffectiveLevel, UnitBattlePetLevel =
	UnitReaction, UnitName, UnitClass, UnitRace, UnitCreatureType, UnitEffectiveLevel, UnitBattlePetLevel
local UnitGetTotalAbsorbs, UnitGetTotalHealAbsorbs = UnitGetTotalAbsorbs, UnitGetTotalHealAbsorbs
local GetCreatureDifficultyColor = GetCreatureDifficultyColor

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
