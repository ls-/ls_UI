local AddOn, ns = ...
local E, M = ns.E, ns.M

local B = E.Blizzard

function B:HandleArchaeology()
	LoadAddOn("Blizzard_ArchaeologyUI")

	ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 250)
	E:HandleStatusBar(ArcheologyDigsiteProgressBar)
	E:CreateMover(ArcheologyDigsiteProgressBar)
end
