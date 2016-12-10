local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:AddModule("Blizzard", true)

-- Mine
local isInit = false

-----------------
-- INITIALISER --
-----------------

function BLIZZARD:IsInit()
	return isInit
end

function BLIZZARD:Init()
	if not isInit and C.blizzard.enabled then
		self:CommandBar_Init()
		self:DigsiteBar_Init()
		self:Durability_Init()
		self:GM_Init()
		self:NPE_Init()
		self:ObjectiveTracker_Init()
		self:PlayerAltPowerBar_Init()
		self:TalkingHead_Init()
		self:Timer_Init()
		self:Vehicle_Init()

		-- Finalise
		isInit = true

		return true
	end
end
