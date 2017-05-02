local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:CreateName(parent, textFontObject)
	local element = parent:CreateFontString("$parentNameText", "OVERLAY", textFontObject)
	element:SetWordWrap(false)
	E:ResetFontStringHeight(element)

	return element
end

function UF:UpdateName(frame)
	local config = frame._config.name
	local element = frame.Name

	element:SetJustifyV(config.v_alignment or "MIDDLE")
	element:SetJustifyH(config.h_alignment or "CENTER")

	local point1 = config.point1

	element:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)

	local point2 = config.point2

	if point2 then
		element:SetPoint(point2.p, E:ResolveAnchorPoint(frame, point2.anchor), point2.rP, point2.x, point2.y)
	end

	frame:Tag(element, config.tag)
end
