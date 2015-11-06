local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E.UF

local ICONS = {
	["Leader"] = {2 / 128, 20 / 128, 2 / 64, 20 / 64},
	["Phase"] = {62 / 128, 80 / 128, 22 / 64, 40 / 64},
	["Resting"] = {82 / 128, 100 / 128, 2 / 64, 20 / 64},
	["Quest"] = {82 / 128, 100 / 128, 22 / 64, 40 / 64},
	["Combat"] = {102 / 128, 120 / 128, 2 / 64, 20 / 64},
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
		icon:SetTexCoord(unpack(ICONS[role]))
		icon:SetAlpha(1)
	else
		icon:SetAlpha(0)
	end
end

local function PvPOverride(frame, event, unit)
	if unit ~= frame.unit then return end

	local icon = frame.PvP
	local faction = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) then
		icon:SetTexCoord(42 / 128, 60 / 128, 22 / 64, 40 / 64)
		icon:SetAlpha(1)
	elseif UnitIsPVP(unit) and faction and faction ~= "Neutral" then
		icon:SetTexCoord(unpack(ICONS[faction]))
		icon:SetAlpha(1)
	else
		icon:SetAlpha(0)
	end
end

local function CombatOverride(self)
	local icon = self.Combat

	if UnitAffectingCombat("player") then
		icon:SetAlpha(1)
		self.Resting:SetAlpha(0)
	else
		icon:SetAlpha(0)
	end
end

local function PhaseOverride(self)
	local icon = self.PhaseIcon

	if not UnitInPhase(self.unit) then
		icon:SetAlpha(1)
	else
		icon:SetAlpha(0)
	end
end

local function LeaderOverride(self)
	local icon = self.Leader
	local unit = self.unit

	if (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit) then
		icon:SetAlpha(1)
	else
		icon:SetAlpha(0)
	end
end

local function RestingOverride(self)
	local icon = self.Resting

	if IsResting() then
		icon:SetAlpha(1)
	else
		icon:SetAlpha(0)
	end
end

function UF:CreateIcon(parent, type, size)
	local icon = parent:CreateTexture("$parent"..type.."Icon", "ARTWORK", nil, 3)
	icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icons")
	icon:SetSize(size or 18, size or 18)
	icon:Hide()

	if ICONS[type] then
		icon:SetTexCoord(unpack(ICONS[type]))
	end

	if type == "LFDRole" then
		icon.Override = LFDRoleOverride
	elseif type == "PvP" then
		icon.Override = PvPOverride
	elseif type == "Combat" then
		icon.Override = CombatOverride
	elseif type == "Phase" then
		icon.Override = PhaseOverride
	elseif type == "Leader" then
		icon.Override = LeaderOverride
	elseif type == "Resting" then
		icon.Override = RestingOverride
	end

	return icon
end
