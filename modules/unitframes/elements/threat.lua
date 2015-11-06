local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E.UF
local THREATCOLORS = M.colors.threat

local ThreatUpdateOverride

function ThreatUpdateOverride(self, event, unit)
	if unit ~= self.unit then return end

	if not self:IsEventRegistered("UNIT_THREAT_LIST_UPDATE") then
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", ThreatUpdateOverride)
	end

	local threat = self.Threat
	local status

	if UnitPlayerControlled(unit) and unit ~= "target" and unit ~= "focus" then
		status = UnitThreatSituation(unit)
	else
		status = UnitThreatSituation("player", unit)
	end

	if(status and status > 0) then
		threat:SetVertexColor(unpack(THREATCOLORS[status]))
		threat:Show()
	else
		threat:Hide()
	end
end

function UF:CreateThreat(parent, texture, l, r, t, b)
	local threat = parent:CreateTexture("$parentThreatGlow", "BACKGROUND", nil, 1)
	threat:SetTexture(texture)
	threat:SetTexCoord(l, r, t, b)
	threat.Override = ThreatUpdateOverride

	return threat
end
