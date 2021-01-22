local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function element_UpdateConfig(self)
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].raid_target, self._config)
end

local function element_UpdateSize(self)
	self:SetSize(self._config.size, self._config.size)
end

local function element_UpdatePoints(self)
	self:ClearAllPoints()

	local config = self._config.point1
	if config and config.p and config.p ~= "" then
		self:SetPoint(config.p, E:ResolveAnchorPoint(self.__owner, config.anchor), config.rP, config.x, config.y)
	end
end

local function frame_UpdateRaidTargetIndicator(self)
	local element = self.RaidTargetIndicator
	element:UpdateConfig()
	element:UpdateSize()
	element:UpdatePoints()

	if element._config.enabled and not self:IsElementEnabled("RaidTargetIndicator") then
		self:EnableElement("RaidTargetIndicator")
	elseif not element._config.enabled and self:IsElementEnabled("RaidTargetIndicator") then
		self:DisableElement("RaidTargetIndicator")
	end

	if self:IsElementEnabled("RaidTargetIndicator") then
		element:ForceUpdate()
	end
end

function UF:CreateRaidTargetIndicator(frame, parent)
	local element = (parent or frame):CreateTexture(nil, "ARTWORK", nil, 3)

	element.UpdateConfig = element_UpdateConfig
	element.UpdatePoints = element_UpdatePoints
	element.UpdateSize = element_UpdateSize

	frame.UpdateRaidTargetIndicator = frame_UpdateRaidTargetIndicator

	return element
end
