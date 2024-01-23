local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Fixed an issue where the options sub-addon wouldn't load.

### Tooltips

- Fixed an issue where unit tooltips would get stuck on the screen if the shift key was pressed.
]]
