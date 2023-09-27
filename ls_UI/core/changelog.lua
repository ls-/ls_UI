local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.1.7 support.

### Blizzard

- Fixed an issue where populated gem sockets were sometimes shown as empty.

### Minimap

- Added 125% and 150% minimap size options.
]]
