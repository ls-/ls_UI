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

function BLIZZARD:Init(isForced)
	if not isInit and (C.blizzard.enabled or isForced) then
		self:CommandBar_Init(isForced)
		self:DigsiteBar_Init(isForced)
		self:Durability_Init(isForced)
		self:GM_Init(isForced)
		self:NPE_Init(isForced)
		self:ObjectiveTracker_Init(isForced)
		self:PlayerAltPowerBar_Init(isForced)
		self:TalkingHead_Init(isForced)
		self:Timer_Init(isForced)
		self:Vehicle_Init(isForced)

		-- Finalise
		isInit = true
	end
end
