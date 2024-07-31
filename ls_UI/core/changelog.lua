local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Blizzard

- Added an option to scale the game menu. Can be found at /LSUI > Blizzard > Game Menu.

### Tooltips

- Added the bag vs bank (bank + reagent bank + warbank) details to the total item count. It'll only be shown if you have that item in your banks.
]]
