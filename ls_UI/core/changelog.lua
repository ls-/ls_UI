local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Action Bars

- Added mouseover casting to action bars.
- Added an option to scale the main action bar artwork.

### Blizzard

- Fixed the option to hide the talking head.

### Buffs and Debuffs

- Fixed an issue where it's impossible to cancel an aura by right-clicking it.

### Unit Frames

- Fixed an issue where disabling the player castbar would result in an error.

### Known Issues

- Spell flyouts don't work. It's not a bug in my UI, it's a Blizz bug that affects all addons.
  I feel your pain, I have a mage alt, but for the time being either place frequently used spells
  on your action bars or use them directly from your spellbook.
- Tooltips don't work. Just to reiterate, Blizz chose to delay the new tooltip system until 10.0.2,
  the rewritten tooltip module relies on it to work, so I had to disable it for the time being.
]]
