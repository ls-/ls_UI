local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Mine
local function PostUpdate(self, _, status)
	if status and status == 0 then
		self:SetVertexColor(M.COLORS.THREAT[1]:GetRGB())
		self:Show()
	end
end

function UF:CreateThreatIndicator(parent, isTexture)
	local element

	if isTexture then
		element = parent:CreateTexture(nil, "BACKGROUND", nil, -7)
	else
		element = E:CreateBorderGlow(parent, true)
	end

	element.PostUpdate = PostUpdate

	return element
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
