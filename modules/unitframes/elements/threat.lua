local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

-- Lua
local unpack = unpack

-- Blizz
local UnitPlayerControlled = UnitPlayerControlled
local UnitThreatSituation = UnitThreatSituation

-- Mine
local function ThreatUpdateOverride(self, event, unit)
	if unit ~= self.unit then return end

	if not self:IsEventRegistered("UNIT_THREAT_LIST_UPDATE") then
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", ThreatUpdateOverride)
	end

	local threat = self.Threat
	local status

	if UnitPlayerControlled(unit) then
		status = UnitThreatSituation(unit, unit.."target")
	else
		status = UnitThreatSituation("player", unit)
	end

	if status then
		threat:SetVertexColor(unpack(M.colors.threat[status + 1]))
		threat:Show()
	else
		threat:Hide()
	end
end

function UF:CreateThreat(parent)
	local threat = parent:CreateTexture("$parentThreatGlow", "BACKGROUND", nil, 0)
	threat.Override = ThreatUpdateOverride

	return threat
end
