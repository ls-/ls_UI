local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Action Bars

- Reworked the instance lockout tooltip. Instances and world bosses are now grouped by the lockout expiration time. 
  Instance names and difficulties are also properly sorted. This should greatly increase its readability.
]]
