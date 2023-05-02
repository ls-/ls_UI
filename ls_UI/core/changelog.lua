local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.1.0 support.
- Removed login message for good. It served its purpose.

### Minimap

- Fixed an issue where the difficulty flag's position wasn't adjusted when flipping the minimap.
]]
