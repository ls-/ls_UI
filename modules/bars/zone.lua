local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Blizz
local ZoneAbilityFrame = _G.ZoneAbilityFrame
local ZoneAbilityButton = _G.ZoneAbilityFrame.SpellButton

-- Mine
function BARS:CreateZoneButton()
	local point = C.db.profile.bars.zone.point

	ZoneAbilityFrame:SetParent(_G.UIParent)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:EnableMouse(false)
	ZoneAbilityFrame:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
	E:CreateMover(ZoneAbilityFrame)

	ZoneAbilityFrame.ignoreFramePositionManager = true
	_G.UIPARENT_MANAGED_FRAME_POSITIONS["ZoneAbilityFrame"] = nil

	ZoneAbilityButton:SetPoint("TOPLEFT", 2, -2)
	ZoneAbilityButton:SetPoint("BOTTOMRIGHT", -2, 2)
	E:SkinZoneAbilityButton(ZoneAbilityButton)

	self:UpdateZoneButton()

	self.CreateZoneButton = E.NOOP
end

function BARS:UpdateZoneButton()
	ZoneAbilityFrame:SetSize(C.db.profile.bars.zone.size + 4, C.db.profile.bars.zone.size + 4)
	E:UpdateMoverSize(ZoneAbilityFrame)
end
