local _, ns = ...
local E, M = ns.E, ns.M
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G
local unpack = _G.unpack

-- Mine
function B:HandleArchaeology()
	local isLoaded = true

	if not _G.IsAddOnLoaded("Blizzard_ArchaeologyUI") then
		isLoaded = _G.LoadAddOn("Blizzard_ArchaeologyUI")
	end

	if isLoaded then
		_G.ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
		_G.UIPARENT_MANAGED_FRAME_POSITIONS["ArcheologyDigsiteProgressBar"] = nil

		E:HandleStatusBar(_G.ArcheologyDigsiteProgressBar)
		E:SetStatusBarSkin(_G.ArcheologyDigsiteProgressBar, "HORIZONTAL-BIG")
		_G.ArcheologyDigsiteProgressBar.Texture:SetVertexColor(unpack(M.colors.orange))

		_G.ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 250)
		E:CreateMover(_G.ArcheologyDigsiteProgressBar)
	end
end
