local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local ALL_ICONS = M.textures.aura_icons_inline["Curse"]
	.. M.textures.aura_icons_inline["Disease"]
	.. M.textures.aura_icons_inline["Magic"]
	.. M.textures.aura_icons_inline["Poison"]
	.. M.textures.aura_icons_inline[""]

local element_proto = {}

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].debuff, self._config)
end

function element_proto:UpdatePoints()
	self:ClearAllPoints()

	local config = self._config.point1
	if config and config.p and config.p ~= "" then
		self:SetPoint(config.p, E:ResolveAnchorPoint(self.__owner, config.anchor), config.rP, config.x, config.y)
	end
end

function element_proto:UpdateTags()
	local tag = self._config.enabled and "[ls:debuffs]" or ""
	if tag ~= "" then
		self.__owner:Tag(self, tag)
		self:UpdateTag()
	else
		self.__owner:Untag(self)
		self:SetText("")
	end

	self.__preview = nil
end

function element_proto:Preview()
	if self.__preview then
		self:UpdateTags()
	else
		self.__owner:Tag(self, ALL_ICONS)
		self:UpdateTag()

		self.__preview = true
	end
end

local frame_proto = {}

function frame_proto:UpdateDebuffIndicator()
	local element = self.DebuffIndicator
	element:UpdateConfig()
	element:UpdatePoints()
	element:UpdateTags()
end

function UF:CreateDebuffIndicator(frame, textParent)
	Mixin(frame, frame_proto)

	local element = Mixin((textParent or frame):CreateFontString(nil, "ARTWORK"), element_proto)
	element:SetFont(GameFontNormal:GetFont(), 12)
	element:SetNonSpaceWrap(true)
	element:SetJustifyH("CENTER")
	element:SetJustifyV("MIDDLE")
	element.__owner = frame

	return element
end
