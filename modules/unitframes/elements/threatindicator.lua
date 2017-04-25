local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local UnitThreatSituation = _G.UnitThreatSituation

-- Mine
local function ThreatUpdateOverride(self, event, unit)
	if unit ~= self.unit then return end

	local element = self.ThreatIndicator
	local status

	if unit ~= element.feedbackUnit then
		status = UnitThreatSituation(element.feedbackUnit, unit)
	else
		status = UnitThreatSituation(unit)
	end

	if status then
		element:SetVertexColor(M.COLORS.THREAT[status + 1]:GetRGB())
		element:Show()
	else
		element:Hide()
	end
end

function UF:CreateThreat(parent, feedbackUnit)
	local element = parent:CreateTexture("$parentThreatGlow", "BACKGROUND", nil, 0)

	element.feedbackUnit = feedbackUnit
	element.Override = ThreatUpdateOverride

	return element
end
