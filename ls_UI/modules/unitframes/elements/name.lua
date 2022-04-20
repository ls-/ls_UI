local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function updatePoint(frame, fontString, point)
	if point and point.p and point.p ~= "" then
		fontString:SetPoint(point.p, E:ResolveAnchorPoint(frame, point.anchor), point.rP, point.x, point.y)
	end
end

local element_proto = {}

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].name, self._config)
end

function element_proto:UpdateFonts()
	local config = self._config

	self:UpdateFont(config.size)
	self:SetJustifyH(config.h_alignment)
	self:SetJustifyV(config.v_alignment)
	self:SetWordWrap(config.word_wrap)
end

function element_proto:UpdatePoints()
	self:ClearAllPoints()

	updatePoint(self.__owner, self, self._config.point1)
	updatePoint(self.__owner, self, self._config.point2)
end

function element_proto:UpdateTags()
	if self._config.tag ~= "" then
		self.__owner:Tag(self, self._config.tag)
		self:UpdateTag()
	else
		self.__owner:Untag(self)
		self:SetText("")
	end
end

local frame_proto = {}

function frame_proto:UpdateName()
	local element = self.Name
	element:UpdateConfig()
	element:UpdateFonts()
	element:UpdatePoints()
	element:UpdateTags()
end

function UF:CreateName(frame, textParent)
	P:Mixin(frame, frame_proto)

	local element = P:Mixin((textParent or frame):CreateFontString(nil, "OVERLAY"), element_proto)
	element.__owner = frame
	E.FontStrings:Capture(element, "unit")

	return element
end
