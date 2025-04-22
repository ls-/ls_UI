local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.1.5 support.

### Unit Frames

- Fixed an issue where the cast bar would break whenever you tried to empower a spell with 4+ stages.
- Removed "[ls:sheepicon]" tag. It's way too inaccurate, it's time to lay the old sheep to rest.
- Misc bug fixes and tweaks. 
]]
