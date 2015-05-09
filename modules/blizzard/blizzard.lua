local AddOn, ns = ...
local E, M = ns.E, ns.M

E.Blizzard = {}

local B = E.Blizzard

function B:Initialize()
	self:HandleArchaeology()
	self:HandleMirrorTimer()
	self:HandleObjectiveTracker()
	self:HandlePowerBarAlt()
end
