local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.2.7 support.
- Fixed an issue where the addon would fail to create a mover if the parent object it's supposed to be attached to was
  no longer available. Now such a mover will be reset to its default state.

### Action Bars

- Added an option to wipe the list of tracked currencies to remove retired inaccessible currencies from previous
  seasons. Can be found at /LSUI > Action Bars > Backpack > Restore Defaults button in the Currency panel.
- Fixed micro menu help tip hiding. Blizz keep changing how this stuff works, so it'll get broken again eventually.
- Fixed an issue where the reputation bar wouldn't display reputation gains past the renown cap.

### Tooltips

- Fixed an issue where names would appear as blank for players in another zone.

### Unit Frames

- Added proper empowered cast support. Better late than never T_T
]]
