local AddOn, ns = ...
local E, M = ns.E, ns.M

local B = E.Blizzard

function B:HandleMirrorTimer()
	E:HandleStatusBar(MirrorTimer1, true)

	MirrorTimer2:ClearAllPoints()
	MirrorTimer2:SetPoint("TOP", "MirrorTimer1", "BOTTOM", 0, -6)
	E:HandleStatusBar(MirrorTimer2, true)

	MirrorTimer3:ClearAllPoints()
	MirrorTimer3:SetPoint("TOP", "MirrorTimer2", "BOTTOM", 0, -6)
	E:HandleStatusBar(MirrorTimer3, true)
end
