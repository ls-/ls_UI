local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS = M.colors

local select = select
local strupper = strupper

function E:GetCreatureDifficultyColor(level)
	local color = GetCreatureDifficultyColor(level > 0 and level or 199)

	return {r = color.r, g = color.g, b = color.b, hex = E:RGBToHEX(color)}
end

function E:GetUnitReactionColor(unit)
	local color
	if unit then
		color = COLORS.reaction[UnitReaction(unit, "player")]
	end

	color = color or COLORS.reaction[4] -- use Neutral faction colour by default

	return {r = color[1], g = color[2], b = color[3], hex = E:RGBToHEX(color)}
end

function E:GetUnitClassColor(unit)
	local color

	if unit then
		local _, class = UnitClass(unit)
		color = COLORS.class[class]
	end

	color = color or COLORS.reaction[4]

	return {r = color[1], g = color[2], b = color[3], hex = E:RGBToHEX(color)}
end

function E:GetSmartReactionColor(unit)
	local color

	if unit then
		if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
			color = COLORS.disconnected
		elseif UnitIsPlayer(unit) then
			color = COLORS.class[select(2, UnitClass(unit))]
		elseif not UnitIsUnit(unit, "player") and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
			color = COLORS.tapped
		else
			color = COLORS.reaction[UnitReaction(unit, "player")]
		end
	end

	color = color or COLORS.reaction[4]

	return {r = color[1], g = color[2], b = color[3], hex = E:RGBToHEX(color)}
end

function E:GetUnitClassification(unit)
	if not unit then return "" end

	local c = UnitClassification(unit)

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
	local faction = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) then
		return true, "FFA"
	elseif UnitIsPVP(unit) and faction and faction ~= "Neutral" then
		return true, strupper(faction)
	else
		return
	end
end
