local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.0.5 support.

### Action Bars

- Removed bag bar mover. Use Edit Mode to move it.
  - The micro menu is unchanged.

### Auras

- Re-added an option to destroy totems by right-clicking the totem buttons.

### Blizzard

- Removed durability frame mover. Use Edit Mode to move it.

### Minimap

- Fixed an issue where mousing over the difficulty flag would throw errors while in the guild group.
]]
