local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 10.0.0 support.
- Despite the overall lack of visual changes, practically the entire UI was rewritten due to how
  extensive DF changes were.
- The "Round" layout is gone. I'm really sorry :(

### Action Bars

- Added support for the new extra action bars.
- Added an option to toggle wyverns/gryphons. You can now choose between one, two, or no endcaps.
- Removed an option to split the micromenu into two parts.
- Removed the custom bag bar in favour of the new bag bar from Blizz.
- Removed the "Inventory" microbutton, the new backpack button will host the currency tooltip.

### Blizzard

- Removed customisation options and movers for a bunch of the default UI widgets because they're
  reworked by Blizzard. Affected widgets are castbars, the objective tracker, mirror timers (breath,
  fatigue), and the alternative player power bar (the dragon riding bar, various widgets for boss
  encounters, etc).
  - I left in an option to auto-hide the talking head.
  - From now on use Blizz layout manager to move the talking head and objective tracker, I removed
    movers for these two because I wanted to avoid breaking anything in the layout manager, it's
    really easy. And on top of that the objective tracker itself is a very, let's say, sensitive
    widget.
  - If in the future Blizz add an option to safely remove things from their layout manager, I'll
    gladly readd objective tracker and talking head movers.
- Temporarily disabled gem and enchant texts in the character frame. Both rely on the new tooltip
  system that's not available in the pre-patch, more on that later.

### Filters

- Turned "Blacklist" and "M+ Affixes" filters into curated read-only filters. I hope folks in our
  Discord server will help me to maintain the M+ filter. If you added anything to these two filters,
  don't worry, you'll find all the extra auras in new "Blacklist.bak" and "M+ Affixes.bak" filters.

### Loot

- Removed the custom loot frame.

### Minimap

- Both round and square minimaps now use fixed size textures. The 125% size option may come back in
  the future, but I feel like the current size is big enough for everyone.
- Removed minimap button collecting and skinning. By default, there's no need to collect buttons
  anymore, Blizz removed practically everything. I'll most likely release it as a separate addon.
- While the minimap has both my and Blizz (Edit Mode) movers, Blizz mover does nothing, it can't
  move the minimap, it can't change its settings. Unfortunately, Blizz didn't give addon devs a way
  to safely remove things from their layout manager.

### Tooltips

- While the module was rewritten from the ground up, it'll be disabled during 10.0.0 because Blizz
  for some reason decided to release their new tooltip system with 10.0.2.

### Unit Frames

- Added support for evokers.

NOTE: Unfortunately, due to all the changes in DF is became impossible to maintain the round layout
within the UI. To maintain it, I'd basically have to turn it one a separate addon, for this reasons
I chose to retire it for good. It's been with me for almost 15 years, from way before this addon
became publicly available, it's heartbreaking to see it gone :(
]]
