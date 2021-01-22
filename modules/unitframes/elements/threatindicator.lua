local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Mine
local function element_UpdateConfig(self)
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].threat, self._config)
end

local function element_PostUpdate(self, _, status)
	if status and status == 0 then
		self:SetVertexColor(E:GetRGB(C.db.global.colors.threat[1]))
		self:Show()
	end
end

local function frame_UpdateThreatIndicator(self)
	local element = self.ThreatIndicator
	element:UpdateConfig()

	element.feedbackUnit = element._config.feedback__unit

	if element._config.enabled and not self:IsElementEnabled("ThreatIndicator") then
		self:EnableElement("ThreatIndicator")
	elseif not element._config.enabled and self:IsElementEnabled("ThreatIndicator") then
		self:DisableElement("ThreatIndicator")
	end

	if self:IsElementEnabled("ThreatIndicator") then
		element:ForceUpdate()
	end
end

function UF:CreateThreatIndicator(frame, parent, isTexture)
	local element
	if isTexture then
		element = (parent or frame):CreateTexture(nil, "BACKGROUND", nil, -7)
	else
		element = E:CreateBorder(parent or frame)
		element:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick-glow", "BACKGROUND", -7)
		element:SetOffset(-8)
		element:SetSize(16)
	end

	element.PostUpdate = element_PostUpdate
	element.UpdateConfig = element_UpdateConfig

	frame.UpdateThreatIndicator = frame_UpdateThreatIndicator

	return element
end
