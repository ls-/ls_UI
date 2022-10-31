local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
### Action Bars

- Fixed a bug where the extra action button would stay hidden despite being enabled.
- Fixed a bug where an action bar anchored to another frame would appear in a different spot from
  its mover. I had to rework movers for DF, so there might be more of these, please, continue to
  report them.

### Minimap

- Added custom difficulty flags. LFR, normal, heroic, mythic, and M+ difficulties will now have
  unique flags. There's also an option to show the tooltip with the difficulty info, it's disabled
  by default.

### Unit Frames

- Added an option to use Blizzard castbar. When you disable the player castbar, the new "Enable
  Blizzard Castbar" option will appear next to it.

### Known Issues

- Spell flyouts don't work. It's not a bug in my UI, it's a Blizz bug that affects all addons.
  I feel your pain, I have a mage alt, but for the time being either place frequently used spells
  on your action bars or use them directly from your spellbook.
- Tooltips don't work. Just to reiterate, Blizz chose to delay the new tooltip system until 10.0.2,
  the rewritten tooltip module relies on it to work, so I had to disable it for the time being.
]]
