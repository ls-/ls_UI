local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Action Bars

- Removed main bar specific "Scale" option.
- Added "Scale" options to all action bars.
- Added an option to change the number of main bar buttons.
- Fixed an issue where the xp bar would sometimes disappear.
]]
