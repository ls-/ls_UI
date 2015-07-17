local AddOn, ns = ...
local E, M = ns.E, ns.M

local B = E.Blizzard

function B:HandleArchaeology()
	if not IsAddOnLoaded("Blizzard_ArchaeologyUI") then
		E:ForceLoadAddOn("Blizzard_ArchaeologyUI")
	end

	ArcheologyDigsiteProgressBar:SetPoint("BOTTOM", 0, 250)
	E:HandleStatusBar(ArcheologyDigsiteProgressBar, true)
	ArcheologyDigsiteProgressBar.Texture:SetVertexColor(0.65, 0.26, 0)
	E:CreateMover(ArcheologyDigsiteProgressBar)
end
