local _, ns = ...
local oUF = ns.oUF or oUF

local function RGBToHEX(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

oUF.Tags.Methods["custom:color"] = function(unit)
	local color
	if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		color = oUF.colors.disconnected
	elseif UnitIsPlayer(unit) then
		color = oUF.colors.class[select(2, UnitClass(unit))]
	elseif UnitIsUnit(unit, "target") and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		color = oUF.colors.tapped
	else
		color = oUF.colors.reaction[UnitReaction(unit, "player")]
	end
 	if color then
		return RGBToHEX(color)
	else
		return "ffffff"
	end
end

oUF.Tags.Methods["custom:name"] = function(unit, r)
	local color = oUF.Tags.Methods["custom:color"](r or unit)
	local name = UnitName(r or unit)
	return "|cff"..color..(name).."|r"
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

oUF.Tags.Methods["custom:threat"] = function(unit)
	local _, status, scaledPercent = UnitDetailedThreatSituation("player", unit)
	local color = RGBToHEX(GetThreatStatusColor(status))
	if scaledPercent and scaledPercent ~= 0 and ShowNumericThreat() and UnitClassification(unit) ~= "minus" then
		return "|cff"..color..format("%d", scaledPercent).."%|r"
	else
		return " "
	end
end

oUF.Tags.Events["custom:threat"] = "UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE"

oUF.Tags.Methods["custom:healabsorb"] = function(unit)
	local healAbsorb = UnitGetTotalHealAbsorbs("player") or 0
	local color = RGBToHEX(0.9, 0.1, 0.3)
	if healAbsorb > 0 then
		return "|cff"..color.."-|r"..ns.NumFormat(healAbsorb)
	else
		return " "
	end
end

oUF.Tags.Events["custom:healabsorb"] = "UNIT_HEAL_ABSORB_AMOUNT_CHANGED"

oUF.Tags.Methods["custom:damageabsorb"] = function(unit)
	local damageAbsorb = UnitGetTotalAbsorbs(unit) or 0
	local color = RGBToHEX(0, 0.7, 0.95)
	if damageAbsorb > 0 then
		return "|cff"..color.."+|r"..ns.NumFormat(damageAbsorb)
	else
		return " "
	end
end

oUF.Tags.Events["custom:damageabsorb"] = "UNIT_ABSORB_AMOUNT_CHANGED"
