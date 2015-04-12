local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

local COORD = {
	["Leader"] = {2 / 128, 20 / 128, 2 / 64, 20 / 64},
	["Phase"] = {62 / 128, 80 / 128, 22 / 64, 40 / 64},
	["Resting"] = {82 / 128, 100 / 128, 2 / 64, 20 / 64},
	["Quest"] = {82 / 128, 100 / 128, 22 / 64, 40 / 64},
	["Horde"] = {2 / 128, 20 / 128, 22 / 64, 40 / 64},
	["Alliance"] = {22 / 128, 40 / 128, 22 / 64, 40 / 64},
	["TANK"] = {62 / 128, 80 / 128, 2 / 64, 20 / 64},
	["HEALER"] = {42 / 128, 60 / 128, 2 / 64, 20 / 64},
	["DAMAGER"] = {22 / 128, 40 / 128, 2 / 64, 20 / 64},
}

local function LFDRoleOverride(frame, event)
	local icon = frame.LFDRole
	local role = UnitGroupRolesAssigned(frame.unit)

	if role and role ~= "NONE" then
		icon:SetTexCoord(unpack(COORD[role]))
		icon:Show()
	else
		icon:Hide()
	end
end

local function PvPOverride(frame, event, unit)
	if unit ~= frame.unit then return end

	local icon = frame.PvP
	local faction = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) then
		icon:SetTexCoord(42 / 128, 60 / 128, 22 / 64, 40 / 64)
		icon:Show()
	elseif UnitIsPVP(unit) and faction and faction ~= "Neutral" then
		icon:SetTexCoord(unpack(COORD[faction]))
		icon:Show()
	else
		icon:Hide()
	end
end

function UF:CreateIcon(parent, type)
	local icon = parent:CreateTexture("$parent"..type.."Icon", "BACKGROUND")
	icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icons")
	icon:SetSize(18, 18)

	if COORD[type] then
		icon:SetTexCoord(unpack(COORD[type]))
	end

	if type == "LFDRole" then
		icon.Override = LFDRoleOverride
	elseif type == "PvP" then
		icon.Override = PvPOverride
	end

	return icon
end
