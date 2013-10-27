local _, ns = ...
local oUF = ns.oUF or oUF
local cfg = ns.cfg
local L = ns.L

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

oUF.Tags.Methods["custom:raceclass"] = function(unit)
	local torr, class
	if UnitIsPlayer(unit) then
		torr = UnitRace(unit)
		class = UnitClass(unit)
		local color = oUF.colors.class[select(2, UnitClass(unit))]
		return torr.." |cff"..RGBToHEX(color)..class.."|r"
	else
		local temp = ""
		torr = UnitCreatureType(unit)
		class = UnitClassification(unit)
		if class == "worldboss" or UnitLevel(unit) == -1 then
			return torr.." ("..L["boss"]..")"
		elseif class == "normal" or class == "minus" or class == "trivial" then
			return torr
		else
			return torr.." ("..L[class]..")"
		end
	end
end

oUF.Tags.Events["custom:raceclass"] = "UNIT_CLASSIFICATION_CHANGED"

oUF.Tags.Methods["custom:threat"] = function(unit)
	local _, status, scaledPercent = UnitDetailedThreatSituation("player", unit)
	local color = RGBToHEX(GetThreatStatusColor(status))
	if scaledPercent and scaledPercent ~= 0 and ShowNumericThreat() and UnitClassification(unit) ~= "minus" then
		return "|cff"..color..format("%d", scaledPercent).."%|r"
	else
		return ""
	end
end

oUF.Tags.Events["custom:threat"] = "UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE"