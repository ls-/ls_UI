local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Tooltips

- Improved compatibility with addons that use old-school tooltip scanning. No more unit names in all
  kinds of tooltips!
- Added expansion info to item tooltips. It's tied to the "Spell and Item ID" option.
]]
