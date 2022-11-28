local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.0.2 support.
- Updated embeds.

### Action Bars

- The latest LAB includes custom flyouts (a bit buggy).
- Reverted the hack added in 100000.01 that locked action bars, it's no longer necessary.

### Unit Frames

- Fixed an issue where heal and power cost predictions would sometimes be displayed outside the
  bounds of the unit frame.

### Known Issues

- Empowered spell casts have very basic support atm. I'm planning to rework castbars and other
  progress bars later, so I chose not to do the same work twice. Soz.
]]
