local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE:HasMawBuffs()
	return isInit
end

function MODULE:SetUpMawBuffs()
	if not isInit and C.db.char.blizzard.maw_buffs.enabled then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_MawBuffs") then
			isLoaded = LoadAddOn("Blizzard_MawBuffs")
		end

		if isLoaded then
			MawBuffsBelowMinimapFrame.ignoreFramePositionManager = true
			UIPARENT_MANAGED_FRAME_POSITIONS["MawBuffsBelowMinimapFrame"] = nil

			MawBuffsBelowMinimapFrame:ClearAllPoints()
			MawBuffsBelowMinimapFrame:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -182, -188)
			E.Movers:Create(MawBuffsBelowMinimapFrame)

			isInit = true
		end
	end
end
