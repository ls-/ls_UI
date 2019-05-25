local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].portrait, self._config)
end

local function frame_UpdatePortrait(self)
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

	self.Insets.Left:Collapse()
	self.Insets.Right:Collapse()

	if element._config.enabled and not self:IsElementEnabled("Portrait") then
		self:EnableElement("Portrait")
	elseif not element._config.enabled and self:IsElementEnabled("Portrait") then
		self:DisableElement("Portrait")
	end

	if self:IsElementEnabled("Portrait") then
		self.Insets[element._config.position]:Capture(element)
		self.Insets[element._config.position]:Expand()

		element:Show()
		element:ForceUpdate()
	end
end

function UF:CreatePortrait(frame, parent)
	frame.Portrait2D = (parent or frame):CreateTexture(nil, "ARTWORK")
	frame.Portrait2D.UpdateConfig = element_UpdateConfig

	frame.Portrait3D = CreateFrame("PlayerModel", nil, parent or frame)
	frame.Portrait3D.UpdateConfig = element_UpdateConfig

	frame.UpdatePortrait = frame_UpdatePortrait

	return frame.Portrait2D
end
