local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Mine
function UF:CreateThreatIndicator(parent)
	return E:CreateBorderGlow(parent, true)
end

function UF:UpdateThreatIndicator(frame)
	local config = frame._config.threat
	local element = frame.ThreatIndicator

	element.feedbackUnit = config.feedback_unit

	if config.enabled and not frame:IsElementEnabled("ThreatIndicator") then
		frame:EnableElement("ThreatIndicator")
	elseif not config.enabled and frame:IsElementEnabled("ThreatIndicator") then
		frame:DisableElement("ThreatIndicator")
	end

	if frame:IsElementEnabled("ThreatIndicator") then
		element:ForceUpdate()
	end
end
