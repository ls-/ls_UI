local AddOn, ns = ...
local E, M = ns.E, ns.M

local B = E.Blizzard

function B:HandleArchaeology()
	LoadAddOn("Blizzard_ArchaeologyUI")

	ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 250)
	E:HandleStatusBar(ArcheologyDigsiteProgressBar, true)
	ArcheologyDigsiteProgressBar.Texture:SetVertexColor(0.65, 0.26, 0)
	E:CreateMover(ArcheologyDigsiteProgressBar)
end
