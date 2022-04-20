local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE:HasMawBuffs()
	return isInit
end

function MODULE:SetUpMawBuffs()
	if not isInit and PrC.db.profile.blizzard.maw_buffs.enabled then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_MawBuffs") then
			isLoaded = LoadAddOn("Blizzard_MawBuffs")
		end

		if isLoaded then
			MawBuffsBelowMinimapFrame.ignoreFramePositionManager = true
			UIPARENT_MANAGED_FRAME_POSITIONS["MawBuffsBelowMinimapFrame"] = nil

			local point = C.db.profile.blizzard.maw_buffs.point[E.UI_LAYOUT]
			MawBuffsBelowMinimapFrame:ClearAllPoints()
			MawBuffsBelowMinimapFrame:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E.Movers:Create(MawBuffsBelowMinimapFrame)

			isInit = true
		end
	end
end
