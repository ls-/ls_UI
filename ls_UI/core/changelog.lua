local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Updated Simplified Chinese translation. Translated by sylvanas54@Curse.

### Action Bars

- Added support for the one button rotation and rotation highlight.

### Blizzard

- Added an option to enable highlights for missing enchants. These can be enabled per slot. Can be found at /LSUI > Blizzard > Character Frame > Missing Enhancements, disabled by default.

### Minimap

- Aligned the expansion summary button with the round minimap border.

### Unit Frames

- Fixed an issue where disabling tank or healer aura filters would hide more or sometimes fewer auras than they're supposed to.
]]
