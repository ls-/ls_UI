local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Action Bars

- Removed various range checks in accordance with the latest range API restriction by Blizz.
- The currency list in the backpack tooltip is now sorted by name.
]]
