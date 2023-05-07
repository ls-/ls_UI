local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Minimap

- Added minimap coordinates. Disabled by default.
- Adjusted minimap border textures to make zone colouring more pronounced.

### Unit Frames

- Readded fading options for pet, target of focus, and target of target frames.
]]
