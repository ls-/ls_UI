local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local element_proto = {}

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].threat, self._config)
end

function element_proto:PostUpdate(_, status)
	if status and status == 0 then
		self:SetVertexColor(C.db.global.colors.threat[1]:GetRGB())
		self:Show()
	end
end

local frame_proto = {}

function frame_proto:UpdateThreatIndicator()
	local element = self.ThreatIndicator
	element:UpdateConfig()

	element.feedbackUnit = element._config.feedback_unit

	if element._config.enabled and not self:IsElementEnabled("ThreatIndicator") then
		self:EnableElement("ThreatIndicator")
	elseif not element._config.enabled and self:IsElementEnabled("ThreatIndicator") then
		self:DisableElement("ThreatIndicator")
	end

	if self:IsElementEnabled("ThreatIndicator") then
		element:ForceUpdate()
	end
end

function UF:CreateThreatIndicator(frame)
	Mixin(frame, frame_proto)

	local element = Mixin(E:CreateBorder(frame), element_proto)
	element:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick-glow", "BACKGROUND", -7)

	return element
end
