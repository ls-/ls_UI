local _, ns = ...
local E, M = ns.E, ns.M

E.width, E.height = string.match(GetCVar("gxResolution"), "(%d+)x(%d+)")
E.playerclass = select(2, UnitClass("player"))
