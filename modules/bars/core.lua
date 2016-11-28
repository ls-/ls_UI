local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:AddModule("Bars", true)

-- Mine
local isInit = false

-----------------
-- INITIALISER --
-----------------

function BARS:IsInit()
	return isInit
end

function BARS:Init(isForced)
	if not isInit and (C.bars.enabled or isForced) then
		self:ActionBars_Init()
		self:Bags_Init()
		self:ExtraActionButton_Init()
		self:MicroMenu_Init()
		self:PetBattleBar_Init()
		self:VehicleExitButton_Init()
		self:ZoneAbilityButton_Init()

		-- Should be the last one
		self:ActionBarController_Init()

		-- Finalise
		isInit = true
	end
end
