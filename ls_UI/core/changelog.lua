local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.1.0 support.

### Action Bars

- The CTA tracker in the group finder micro button now shows the info for all specs available to your character.
- Fixed an issue where the reputation bar would fail to display some paragon reputations correctly.

### Minimap

- Fixed hybrid minimap. All (2) the people who still run Torghast, rejoice! :v

### Config

- Added missing "Essence" colour. Can be found at /LSUI > General > Colours > Power.
]]
