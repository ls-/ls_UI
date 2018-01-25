local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false
local bar

function MODULE.CreateZoneButton()
	if not isInit then
		local point = C.db.profile.bars.zone.point

		bar = CreateFrame("Frame", "LSZoneAbilityBar", UIParent, "SecureHandlerStateTemplate")
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		ZoneAbilityFrame.ignoreFramePositionManager = true
		UIPARENT_MANAGED_FRAME_POSITIONS["ZoneAbilityFrame"] = nil

		ZoneAbilityFrame:EnableMouse(false)
		ZoneAbilityFrame:SetParent(bar)
		ZoneAbilityFrame:SetAllPoints()

		ZoneAbilityFrame.SpellButton:SetPoint("TOPLEFT", 2, -2)
		ZoneAbilityFrame.SpellButton:SetPoint("BOTTOMRIGHT", -2, 2)
		E:SkinZoneAbilityButton(ZoneAbilityFrame.SpellButton)

		MODULE:InitBarFading(bar)

		isInit = true

		MODULE:UpdateZoneButton()
	end
end

function MODULE.UpdateZoneButton()
	if isInit then
		bar._config = C.db.profile.bars.zone

		ZoneAbilityFrame:SetAllPoints()

		bar:SetSize(bar._config.size + 4, bar._config.size + 4)
		bar:AdjustMoverSize()
		MODULE:UpdateBarFading(bar)
		MODULE:UpdateBarVisibility(bar)
	end
end
