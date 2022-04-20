local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local element_proto = {}

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].raid_target, self._config)
end

function element_proto:UpdateSize()
	self:SetSize(self._config.size, self._config.size)
end

function element_proto:UpdatePoints()
	self:ClearAllPoints()

	local config = self._config.point1
	if config and config.p and config.p ~= "" then
		self:SetPoint(config.p, E:ResolveAnchorPoint(self.__owner, config.anchor), config.rP, config.x, config.y)
	end
end

local frame_proto = {}

function frame_proto:UpdateRaidTargetIndicator()
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
	P:Mixin(frame, frame_proto)

	return P:Mixin((parent or frame):CreateTexture(nil, "ARTWORK", nil, 3), element_proto)
end
