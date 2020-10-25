local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local ALL_ICONS = M.textures.aura_icons_inline["Curse"] .. M.textures.aura_icons_inline["Disease"]
	.. M.textures.aura_icons_inline["Magic"] .. M.textures.aura_icons_inline["Poison"]
	.. M.textures.aura_icons_inline[""]

local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].debuff, self._config)
end

local function element_UpdatePoints(self)
	self:ClearAllPoints()

	local config = self._config.point1
	if config and config.p and config.p ~= "" then
		self:SetPoint(config.p, E:ResolveAnchorPoint(self.__owner, config.anchor), config.rP, config.x, config.y)
	end
end

local function element_UpdateTags(self)
	local tag = self._config.enabled and "[ls:debuffs]" or ""
	if tag ~= "" then
		self.__owner:Tag(self, tag)
		self:UpdateTag()
	else
		self.__owner:Untag(self)
		self:SetText("")
	end

	self._preview = nil
end

local function element_Preview(self)
	if self._preview then
		self:UpdateTags()
	else
		self.__owner:Tag(self, ALL_ICONS)
		self:UpdateTag()

		self._preview = true
	end
end

local function frame_UpdateDebuffIndicator(self)
	local element = self.DebuffIndicator
	element:UpdateConfig()
	element:UpdatePoints()
	element:UpdateTags()
end

function UF:CreateDebuffIndicator(frame, textParent)
	local element = (textParent or frame):CreateFontString(nil, "ARTWORK")
	element:SetFont(GameFontNormal:GetFont(), 12)
	element:SetJustifyH("CENTER")
	element:SetJustifyV("MIDDLE")
	element:SetNonSpaceWrap(true)

	element.__owner = frame
	element.Preview = element_Preview
	element.UpdateConfig = element_UpdateConfig
	element.UpdatePoints = element_UpdatePoints
	element.UpdateTags = element_UpdateTags

	frame.UpdateDebuffIndicator = frame_UpdateDebuffIndicator

	return element
end
