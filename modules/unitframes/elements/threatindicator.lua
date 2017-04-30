local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Mine
function UF:CreateThreat(parent, feedbackUnit)
	local element = parent:CreateTexture("$parentThreatGlow", "BACKGROUND", nil, 0)

	element.feedbackUnit = feedbackUnit

	return element
end
