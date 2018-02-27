local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function frame_UpdateRaidTargetIndicator(self)
	local config = self._config.raid_target
	local element = self.RaidTargetIndicator

	element:SetSize(config.size, config.size)
	element:ClearAllPoints()

	local point1 = config.point1

	if point1 and point1.p then
		element:SetPoint(point1.p, E:ResolveAnchorPoint(self, point1.anchor), point1.rP, point1.x, point1.y)
	end

	if config.enabled and not self:IsElementEnabled("RaidTargetIndicator") then
		self:EnableElement("RaidTargetIndicator")
	elseif not config.enabled and self:IsElementEnabled("RaidTargetIndicator") then
		self:DisableElement("RaidTargetIndicator")
	end

	if self:IsElementEnabled("RaidTargetIndicator") then
		element:ForceUpdate()
	end
end

function UF:CreateRaidTargetIndicator(frame, parent)
	local element = (parent or frame):CreateTexture(nil, "ARTWORK", nil, 3)

	frame.UpdateRaidTargetIndicator = frame_UpdateRaidTargetIndicator

	return element
end
