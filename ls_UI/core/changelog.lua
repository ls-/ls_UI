local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.0.5 support.

### Action Bars

- Fixed an issue where the guild emblem would appear on top the guild micro button.

### Blizzard

- Added custom inspect panel. Can be found at /LSUI > Blizzard > Inspect Frame, enabled by default.

### Unit Frames

- Fixed an issue where 3D portrait wouldn't fade properly.
]]
