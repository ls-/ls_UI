local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = _G

-- Blizz
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitThreatSituation = _G.UnitThreatSituation

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
		threat:SetVertexColor(M.COLORS.THREAT[status + 1]:GetRGB())
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
