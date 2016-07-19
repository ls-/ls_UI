local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:AddModule("Blizzard")

function B:Initialize()
	B:HandleArchaeology()
	B:HandleCommandBar()
	B:HandleSpellFlyout()
	B:HandleObjectiveTracker()
	B:HandlePowerBarAlt()
	B:HandleTimers()
end
