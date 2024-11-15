local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local function updateAlpha(self, alpha)
	self.Portrait3D.alpha = alpha
	self.Portrait3D:SetModelAlpha(alpha)
end

local element_proto = {}

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].portrait, self._config)
end

function element_proto:PostUpdate(_, hasStateChanged)
	if self:IsObjectType("PlayerModel") and hasStateChanged then
		self:SetCamDistanceScale(1 / self._config.scale)
		self:SetModelAlpha(self.alpha)
	end
end

local frame_proto = {}

function frame_proto:UpdatePortrait()
	local style = C.db.profile.units[self.__unit].portrait.style
	if style == "3D" then
		self.Portrait = self.Portrait3D
		self.Portrait2D:ClearAllPoints()
		self.Portrait2D:Hide()
	else
		self.Portrait = self.Portrait2D
		self.Portrait3D:ClearAllPoints()
		self.Portrait3D:Hide()

		if style == "2D" then
			self.Portrait:SetTexCoord(0.125, 0.875, 0.125, 0.875)
		else
			self.Portrait:SetTexCoord(0, 1, 0, 1)
		end
	end

	self.Portrait3D.__owner = self.Portrait2D.__owner
	self.Portrait3D.ForceUpdate = self.Portrait2D.ForceUpdate

	local element = self.Portrait
	element:UpdateConfig()
	element:Hide()

	element.showClass = style == "Class"

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

	hooksecurefunc(frame, "SetAlpha", updateAlpha)

	return frame.Portrait2D
end
