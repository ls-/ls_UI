local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Fixed outdated "Name" formatting tooltip. "ls:name:5/10/etc" tags have been gone for a long long time, instead use "ls:name(N)"
  where N is the number of characters you want to shorten the name to.
]]
