local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:CreateRaidTargetIndicator(parent)
	local element = parent:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)

	return element
end

function UF:UpdateRaidTargetIndicator(frame)
	local config = frame._config.raid_target
	local element = frame.RaidTargetIndicator

	element:SetSize(config.size, config.size)
	element:ClearAllPoints()

	local point1 = config.point1

	if point1 and point1.p then
		element:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)
	end

	if config.enabled and not frame:IsElementEnabled("RaidTargetIndicator") then
		frame:EnableElement("RaidTargetIndicator")
	elseif not config.enabled and frame:IsElementEnabled("RaidTargetIndicator") then
		frame:DisableElement("RaidTargetIndicator")
	end

	if frame:IsElementEnabled("RaidTargetIndicator") then
		element:ForceUpdate()
	end
end
