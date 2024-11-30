local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Fixed an issue where movers would fail to initialise properly if they're a part of a convoluted hierarchy.

### Blizzard

- Updated character and inspect panels. Added optional upgrade level (hero, champion, etc) texts, disabled by default.
  Gems and sockets are now displayed via Remix-like widgets. Enchant and upgrade level texts are now shown on mouseover
  to reduce the visual clutter.

### Unit Frames

- Fixed an issue where a 3D portrait wouldn't inherit the unit frame's alpha.
]]
