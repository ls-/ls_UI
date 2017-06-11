local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function BLIZZARD:HasDigsiteBar()
	return isInit
end

function BLIZZARD:SetUpDigsiteBar()
	if C.db.char.blizzard.digsite_bar.enabled then
		local isLoaded = true

		if not _G.IsAddOnLoaded("Blizzard_ArchaeologyUI") then
			isLoaded = _G.LoadAddOn("Blizzard_ArchaeologyUI")
		end

		if isLoaded then
			_G.ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
			_G.UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil

			_G.ArcheologyDigsiteProgressBar:ClearAllPoints()
			_G.ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 250)
			E:HandleStatusBar(_G.ArcheologyDigsiteProgressBar)
			E:SetStatusBarSkin(_G.ArcheologyDigsiteProgressBar, "HORIZONTAL-L")
			E:CreateMover(_G.ArcheologyDigsiteProgressBar)

			_G.ArcheologyDigsiteProgressBar.Texture:SetVertexColor(M.COLORS.ORANGE:GetRGB())

			isInit = true

			self.SetUpDigsiteBar = E.NOOP
		end
	end
end
