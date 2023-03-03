local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Unit Frames

- Added the "Health" option to fading. It's controlled by the player's health, and if it's below
  <100% the frame will fade in.
- Added an option to disable status icons. These are the round role, class, etc icons at the bottom
  of a frame.
- Removed fading options from pet, target of focus, and target of target frames. These are now
  controlled by the fading options of player, focus, and target frames respectively.
]]
