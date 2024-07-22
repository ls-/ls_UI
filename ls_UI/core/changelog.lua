local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

-- Lua
local _G = getfenv(0)

-- Mine
E.CHANGELOG = [[
- Added 11.0.0 support.
- Added a set of options to adjust status bar textures. Can be found /LSUI > General > Textures.
- Updated a bunch of art assets.

### Config

- Removed outdated and confusing "character-specific" wording. Clarified what global and private profiles are for. To reiterate, the global profile is for settings of various modules and submodules, these don't need a UI reload to work, whereas the private profile includes the aura tracker settings and which modules and submodules are enabled or disabled, these typically require a UI reload.
- Marked all private profile setting that require a UI reload to take effect with a light blue colour.
- Reworked the reload UI popup. Instead of appearing right away, it'll appear after you close the config panel.

### Action Bars

- Added an option to increase the number of main action bar's button slots up to 24 when the artwork is enabled. The main action bar will take up the first 12 slots, the extra slots are empty, and they're there to create room for additional action bars that can be moved there manually. All animations were adjusted accordingly to support this. Can be found at /LSUI > Action Bars > Action Bar 1 > Number of Buttons.
- Split the spacing option into vertical and horizontal spacings. This will allow to create more space between the row without affecting the gap between the buttons.
- Reduced the minimum button size to 8. Fun fact, at the height set to 14 and the number of buttons per row set to 6 a single 12 button action bar to be as big as just 6 button slots.
- Fixed an issue where the XP bar would occasionally blink/flash. It generally should perform a lot better now.

### Blizzard

- Added compact variant for the Suggested Content tab of the Adventure Guide. Can be found at /LSUI > Blizzard > Adventure Guide, enabled by default.

### Unit Frames

- Added adjustable gradient. Can be found at /LSUI > Unit Frames, next to the gloss slider.
- Added temporary max health reduction bar. It's a new feature in TWW, most likely will be used in raid and dungeon encounters. Can be found at /LSUI > Unit Frames > Unit Frame > Health > Health Reduction, next to the heal prediction toggle.
- Reworked the damage absorb shield into a widget that's displayed on top of the health bar.
- Added an option to adjust the zoom of 3D portraits. /LSUI > Unit Frames > Unit Frame > Portrait > Scale, only visible when using 3D portraits.
- Cropped 2D portraits. They're less round now, and there's less wasted space. There's no way to completely remove the round mask.
- Added options to enable word wrapping for health and power texts.
]]
