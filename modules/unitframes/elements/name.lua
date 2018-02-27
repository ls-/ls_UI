local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function frame_UpdateName(self)
	local config = self._config.name
	local element = self.Name

	element:SetJustifyV(config.v_alignment or "MIDDLE")
	element:SetJustifyH(config.h_alignment or "CENTER")
	element:SetWordWrap(config.word_wrap)
	element:ClearAllPoints()

	local point1 = config.point1

	if point1 and point1.p then
		element:SetPoint(point1.p, E:ResolveAnchorPoint(self, point1.anchor), point1.rP, point1.x, point1.y)
	end

	local point2 = config.point2

	if point2 and point2.p ~= "" then
		element:SetPoint(point2.p, E:ResolveAnchorPoint(self, point2.anchor), point2.rP, point2.x, point2.y)
	end

	self:Tag(element, config.tag)
end

function UF:CreateName(frame, textFontObject, textParent)
	local element = (textParent or frame):CreateFontString(nil, "OVERLAY", textFontObject)

	frame.UpdateName = frame_UpdateName

	return element
end
