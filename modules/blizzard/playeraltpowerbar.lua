local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE:HasAltPowerBar()
	return isInit
end

function MODULE:SetUpAltPowerBar()
	if not isInit and C.db.char.blizzard.player_alt_power_bar.enabled then
		PlayerPowerBarAlt.ignoreFramePositionManager = true
		UIPARENT_ALTERNATE_FRAME_POSITIONS["PlayerPowerBarAlt_Top"] = nil
		UIPARENT_ALTERNATE_FRAME_POSITIONS["PlayerPowerBarAlt_Bottom"] = nil
		UIPARENT_MANAGED_FRAME_POSITIONS["PlayerPowerBarAlt"] = nil

		local holder = CreateFrame("Frame", "LSPowerBarAltHolder", UIParent)
		holder:SetSize(64, 64)

		local point = C.db.profile.blizzard.player_alt_power_bar.point[E.UI_LAYOUT]
		holder:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(holder)

		PlayerPowerBarAlt:SetMovable(true)
		PlayerPowerBarAlt:SetUserPlaced(true)
		PlayerPowerBarAlt:SetParent(holder)
		PlayerPowerBarAlt:ClearAllPoints()
		PlayerPowerBarAlt:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)

		isInit = true
	end
end
