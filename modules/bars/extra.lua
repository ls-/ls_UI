local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Blizz
local ExtraActionFrame = _G.ExtraActionBarFrame
local ExtraActionButton = _G.ExtraActionButton1

-- Mine
function BARS:CreateExtraButton()
	local point = C.db.profile.bars.extra.point

	ExtraActionFrame:SetParent(_G.UIParent)
	ExtraActionFrame:ClearAllPoints()
	ExtraActionFrame:EnableMouse(false)
	ExtraActionFrame:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
	E:CreateMover(ExtraActionFrame)

	ExtraActionFrame.ignoreFramePositionManager = true
	_G.UIPARENT_MANAGED_FRAME_POSITIONS["ExtraActionFrame"] = nil

	ExtraActionButton:SetPoint("TOPLEFT", 2, -2)
	ExtraActionButton:SetPoint("BOTTOMRIGHT", -2, 2)
	E:SkinExtraActionButton(ExtraActionButton)

	self:UpdateExtraButton()

	self.CreateExtraButton = E.NOOP
end

function BARS:UpdateExtraButton()
	ExtraActionFrame:SetSize(C.db.profile.bars.extra.size + 4, C.db.profile.bars.extra.size + 4)
	E:UpdateMoverSize(ExtraActionFrame)
end
