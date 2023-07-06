local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local element_proto = {}

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].status, self._config)
end

function element_proto:UpdateTags()
	local tag = ""

	if self._config.enabled then
		tag = self.__owner.__unit == "player" and "[ls:combatresticon][ls:leadericon][ls:lfdroleicon]"
			or "[ls:questicon][ls:sheepicon][ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]"
	end

	if tag ~= "" then
		self.__owner:Tag(self, tag)
		self:UpdateTag()
	else
		self.__owner:Untag(self)
		self:SetText("")
	end
end

local frame_proto = {}

function frame_proto:UpdateStatus()
	local element = self.Status
	element:UpdateConfig()
	element:UpdateTags()
end

function UF:CreateStatus(frame, textParent)
	Mixin(frame, frame_proto)

	local element = Mixin((textParent or frame):CreateFontString(nil, "ARTWORK"), element_proto)
	element:SetFont(GameFontNormal:GetFont(), 16)
	element:SetJustifyH("LEFT")
	element:SetPoint("LEFT", frame, "BOTTOMLEFT", 4, -1)
	element.__owner = frame

	return element
end
