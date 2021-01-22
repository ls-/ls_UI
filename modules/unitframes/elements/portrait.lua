local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

--[[ luacheck: globals
	CreateFrame Mixin
]]

-- Mine
local element_proto = {}

function element_proto:UpdateConfig()
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].portrait, self._config)
end

local frame_proto = {}

function frame_proto:UpdatePortrait()
	if C.db.profile.units[self._unit].portrait.style == "2D" then
		self.Portrait = self.Portrait2D
		self.Portrait3D:ClearAllPoints()
		self.Portrait3D:Hide()
	else
		self.Portrait = self.Portrait3D
		self.Portrait2D:ClearAllPoints()
		self.Portrait2D:Hide()
	end

	self.Portrait3D.__owner = self.Portrait2D.__owner
	self.Portrait3D.ForceUpdate = self.Portrait2D.ForceUpdate

	local element = self.Portrait
	element:UpdateConfig()
	element:Hide()

	self.Insets.Left:Release(element)
	self.Insets.Right:Release(element)

	if element._config.enabled and not self:IsElementEnabled("Portrait") then
		self:EnableElement("Portrait")
	elseif not element._config.enabled and self:IsElementEnabled("Portrait") then
		self:DisableElement("Portrait")
	end

	if self:IsElementEnabled("Portrait") then
		self.Insets[element._config.position]:Capture(element)

		element:Show()
		element:ForceUpdate()
	end
end

function UF:CreatePortrait(frame, parent)
	Mixin(frame, frame_proto)

	frame.Portrait2D = Mixin((parent or frame):CreateTexture(nil, "ARTWORK"), element_proto)
	frame.Portrait3D = Mixin(CreateFrame("PlayerModel", nil, parent or frame), element_proto)

	return frame.Portrait2D
end
