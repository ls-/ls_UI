local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Blizz
local IsAddOnLoaded = _G.IsAddOnLoaded
local LoadAddOn = _G.LoadAddOn

-- Mine
local isInit = false

function MODULE.HasDigsiteBar()
	return isInit
end

function MODULE.SetUpDigsiteBar()
	if not isInit and C.db.char.blizzard.digsite_bar.enabled then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_ArchaeologyUI") then
			isLoaded = LoadAddOn("Blizzard_ArchaeologyUI")
		end

		if isLoaded then
			ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
			UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil

			ArcheologyDigsiteProgressBar:ClearAllPoints()
			ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 250)
			E:HandleStatusBar(ArcheologyDigsiteProgressBar)
			E:SetStatusBarSkin(ArcheologyDigsiteProgressBar, "HORIZONTAL-12")
			E.Movers:Create(ArcheologyDigsiteProgressBar)

			ArcheologyDigsiteProgressBar.Texture:SetVertexColor(M.COLORS.ORANGE:GetRGB())

			isInit = true
		end
	end
end
