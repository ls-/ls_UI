local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function updateTextPoint(frame, fontString, config)
	if config and config.p and config.p ~= "" then
		fontString:SetPoint(config.p, E:ResolveAnchorPoint(frame, config.anchor), config.rP, config.x, config.y)
	end
end

local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].name, self._config)
end

local function element_UpdateFontObjects(self)
	local config = self._config

	self:SetFontObject("LSFont" .. config.size .. (config.outline and "_Outline" or ""))
	self:SetJustifyH(config.h_alignment)
	self:SetJustifyV(config.v_alignment)
	self:SetWordWrap(config.word_wrap)

	if config.shadow then
		self:SetShadowOffset(1, -1)
	else
		self:SetShadowOffset(0, 0)
	end
end

local function element_UpdatePoints(self)
	self:ClearAllPoints()

	updateTextPoint(self.__owner, self, self._config.point1)
	updateTextPoint(self.__owner, self, self._config.point2)
end

local function element_UpdateTags(self)
	if self._config.tag ~= "" then
		self.__owner:Tag(self, self._config.tag)
		self:UpdateTag()
	else
		self.__owner:Untag(self)
		self:SetText("")
	end
end

local function frame_UpdateName(self)
	local element = self.Name
	element:UpdateConfig()
	element:UpdateFontObjects()
	element:UpdatePoints()
	element:UpdateTags()
end

function UF:CreateName(frame, textParent)
	local element = (textParent or frame):CreateFontString(nil, "OVERLAY", "LSFont12")

	element.__owner = frame

	element.UpdateConfig = element_UpdateConfig
	element.UpdateFontObjects = element_UpdateFontObjects
	element.UpdatePoints = element_UpdatePoints
	element.UpdateTags = element_UpdateTags

	frame.UpdateName = frame_UpdateName

	return element
end
