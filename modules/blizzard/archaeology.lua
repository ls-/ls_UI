local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS = M.colors
local B = E:GetModule("Blizzard")

local unpack = unpack

function B:HandleArchaeology()
	if not IsAddOnLoaded("Blizzard_ArchaeologyUI") then
		E:ForceLoadAddOn("Blizzard_ArchaeologyUI")
	end

	local ArcheologyDigsiteProgressBar = ArcheologyDigsiteProgressBar
	ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 250)
	ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
	E:HandleStatusBar(ArcheologyDigsiteProgressBar)
	E:SetStatusBarSkin(ArcheologyDigsiteProgressBar, "HORIZONTAL-BIG")
	ArcheologyDigsiteProgressBar.Texture:SetVertexColor(unpack(COLORS.orange))
	E:CreateMover(ArcheologyDigsiteProgressBar)
end
