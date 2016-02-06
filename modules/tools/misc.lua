local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS = M.colors

local select = select
local strupper = strupper

local _, playerClass = UnitClass("player")
local playerSpec = GetSpecialization() or 0
local playerRole

local PLAYER_SPEC_FLAGS = {
	-- [-1] = 0x00000000, -- none
	[0] = 0x0000000f, -- all
	[1] = 0x00000001, -- 1st
	[2] = 0x00000002, -- 2nd
	[3] = 0x00000004, -- 3rd
	[4] = 0x00000008, -- 4th
}

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

function E:GetPlayerClass()
	return playerClass
end

function E:GetPlayerSpec()
	return playerSpec
end

function E:GetPlayerSpecFlag()
	return PLAYER_SPEC_FLAGS[playerSpec]
end

function E:GetPlayerRole(spec)
	local _, _, _, _, _, role = GetSpecializationInfo(playerSpec)
	return role or "DAMAGER"
end

function E:PLAYER_SPECIALIZATION_CHANGED()
	local oldSpec = playerSpec
	local oldRole = playerRole

	playerSpec = GetSpecialization() or 0
	playerRole = E:GetPlayerRole(playerSpec)

	if oldSpec ~= playerSpec then
		-- do smth
	end

	if oldRole ~= playerRole then
		-- do smth
	end
end

E:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
