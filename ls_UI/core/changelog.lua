local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Action Bars

- Fixed an issue which sometimes would make the Edit Mode throw SetScale errors.

### Minimap

- Added "Auto Zoom Out" option. Set to 5s by default.
- Improved compatibility with other minimap addons like FarmHud. There's still issues on the
  FarmHud's end, but I already notified its dev about them.
]]
