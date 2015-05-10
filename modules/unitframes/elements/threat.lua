local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

local function ThreatUpdateOverride (self, event, unit)
	if(unit ~= self.unit) then return end
	if not self:IsEventRegistered("UNIT_THREAT_LIST_UPDATE") and (self.unit == "target" or self.unit == "focus" or string.sub(self.unit, 1, 4) == "boss") then
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", ns.ThreatUpdateOverride)
	end
	local threat = self.Threat
	local status
	if UnitPlayerControlled(unit) then
		status = UnitThreatSituation(unit)
	else
		status = UnitThreatSituation("player", unit)
	end

	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
		threat:SetVertexColor(r, g, b)
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
