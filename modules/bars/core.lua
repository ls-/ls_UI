local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:AddModule("Bars")

function B:Initialize()
	if C.bars.enabled then
		B:HandleActionBars()
		B:HandlePetBattleBar()
		B:HandleExtraActionButton()
		B:HandleVehicleExitButton()
		B:HandleMicroMenu()
		B:HandleBags()
	end
end
