local AddOn, ns = ...
local E, M = ns.E, ns.M
local B = E.Blizzard
local COLORS = M.colors

local unpack = unpack

function B:HandleArchaeology()
	if not IsAddOnLoaded("Blizzard_ArchaeologyUI") then
		E:ForceLoadAddOn("Blizzard_ArchaeologyUI")
	end

	local ArcheologyDigsiteProgressBar = ArcheologyDigsiteProgressBar
	ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 250)
	ArcheologyDigsiteProgressBar.ignoreFramePositionManager = true
	E:HandleStatusBar(ArcheologyDigsiteProgressBar, true)
	ArcheologyDigsiteProgressBar.Texture:SetVertexColor(unpack(COLORS.orange))
	E:CreateMover(ArcheologyDigsiteProgressBar)
end
