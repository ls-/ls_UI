local _, ns = ...
local E, M = ns.E, ns.M
local B = CreateFrame("Frame", "LSBlizzardModule"); E.Blizzard = B

function B:Initialize()
	B:HandleArchaeology()
	B:HandleTimers()
	B:HandleObjectiveTracker()
	B:HandlePowerBarAlt()
end
