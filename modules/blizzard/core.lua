local _, ns = ...
local E = ns.E
local B = E:AddModule("Blizzard", nil, true)

function B:Initialize()
	B:HandleArchaeology()
	B:HandleCommandBar()
	B:HandleDurabilityFrame()
	B:HandleGM()
	B:HandleNPE()
	B:HandlePowerBarAlt()
	B:HandleSpellFlyout()
	B:HandleTH()
	B:HandleTimers()
	B:HandleVehicleSeatIndicator()
	B:HandleWorldMap()
	B:OT_Initialize()
end
