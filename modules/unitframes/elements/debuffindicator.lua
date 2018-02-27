local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function frame_PreviewDebuffIndicator(self)
	local element = self.DebuffIndicator

	if element._preview then
		self:Tag(element, self._config.debuff.enabled and "[ls:debuffs]" or "")
		element:UpdateTag()

		element._preview = false
	else
		self:Tag(element, "|TInterface\\RaidFrame\\Raid-Icon-DebuffCurse:0:0:0:0:16:16:2:14:2:14|t|TInterface\\RaidFrame\\Raid-Icon-DebuffDisease:0:0:0:0:16:16:2:14:2:14|t|TInterface\\RaidFrame\\Raid-Icon-DebuffMagic:0:0:0:0:16:16:2:14:2:14|t|TInterface\\RaidFrame\\Raid-Icon-DebuffPoison:0:0:0:0:16:16:2:14:2:14|t")
		element:UpdateTag()

		element._preview = true
	end
end

local function frame_UpdateDebuffIndicator(self)
	local config = self._config.debuff
	local element = self.DebuffIndicator

	element:SetJustifyV(config.v_alignment or "MIDDLE")
	element:SetJustifyH(config.h_alignment or "CENTER")
	element:ClearAllPoints()

	local point1 = config.point1

	if point1 and point1.p then
		element:SetPoint(point1.p, E:ResolveAnchorPoint(self, point1.anchor), point1.rP, point1.x, point1.y)
	end

	self:Tag(element, config.enabled and "[ls:debuffs]" or "")
end

function UF:CreateDebuffIndicator(frame, textParent)
	local element = (textParent or frame):CreateFontString(nil, "ARTWORK", "LSStatusIcon12Font")

	frame.PreviewDebuffIndicator = frame_PreviewDebuffIndicator
	frame.UpdateDebuffIndicator = frame_UpdateDebuffIndicator

	return element
end
