local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE.CreateZoneButton()
	if not isInit then
		local point = C.db.profile.bars.zone.point

		ZoneAbilityFrame:SetParent(UIParent)
		ZoneAbilityFrame:ClearAllPoints()
		ZoneAbilityFrame:EnableMouse(false)
		ZoneAbilityFrame:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(ZoneAbilityFrame)

		ZoneAbilityFrame.ignoreFramePositionManager = true
		UIPARENT_MANAGED_FRAME_POSITIONS["ZoneAbilityFrame"] = nil

		ZoneAbilityFrame.SpellButton:SetPoint("TOPLEFT", 2, -2)
		ZoneAbilityFrame.SpellButton:SetPoint("BOTTOMRIGHT", -2, 2)
		E:SkinZoneAbilityButton(ZoneAbilityFrame.SpellButton)

		isInit = true

		MODULE:UpdateZoneButton()
	end
end

function MODULE.UpdateZoneButton()
	if isInit then
		ZoneAbilityFrame:SetSize(C.db.profile.bars.zone.size + 4, C.db.profile.bars.zone.size + 4)
		E:UpdateMoverSize(ZoneAbilityFrame)
	end
end
