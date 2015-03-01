local AddOn, ns = ...
local E, M = ns.E, ns.M

local B = E.Blizzard

function B:HandleMirrorTimer()
	E:HandleStatusBar(MirrorTimer1)

	MirrorTimer2:ClearAllPoints()
	MirrorTimer2:SetPoint("TOP", "MirrorTimer1", "BOTTOM", 0, -6)
	E:HandleStatusBar(MirrorTimer2)

	MirrorTimer3:ClearAllPoints()
	MirrorTimer3:SetPoint("TOP", "MirrorTimer2", "BOTTOM", 0, -6)
	E:HandleStatusBar(MirrorTimer3)
end
