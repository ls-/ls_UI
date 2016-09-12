## Version 3.10

- NEW! Reworked garrison minimap button. Left-click it to open Class Hall report, right-click for Garrison report;
- Added experimental workaround for world map zooming issue. You'll have to zoom in and out manually while in combat. I may remove it later, if it breaks more than it fixes.

## Version 3.09

- Fixed additional action bar visibility, when player possesses something;
- Fixed vehicle/override buttons update process, e.g. you'll be able to get/use new abilities during Illidan scenario in BRH.

## Version 3.08

- Restored minimap rotation and compass;
- Fixed party frame auras.

## Version 3.07

- NEW! Added optional experience, honour, artefact power and reputation bars to objective tracker. Disabled by default. Settings can be found in general section of a config;
- NEW! Added pvp flag expiration timer. However, there's a bug in API, and function may return bogus numbers, in this case timer won't be shown;
- Reworked unit frame aura buttons. Increased size from 22px to 28px, buffs and debuffs are handled by one widget now, added buff/debuff indicators to aura buttons;
- Fixed C stack overflow error in mail module. Finally! While auto-receiving mail loot, inbox will be properly refreshed, if you have more than 50 letters;
- Fixed position calculation for movers, now works better with scaled UIs;
- Tweaked unit frame aura filter. Now you can override it from in-game config, and show only auras from your list;
- Additional action bars' visibility is now handled by the addon. Added a note about it to Blizz config;
- Updated unit frame aura, action bar and general config sections;
- Updated embedded addons and plugins;
- Misc bug fixes and tweaks.

NOTE: At this point in-game config became quite messy. I'll revamp it in next update.

## Version 3.06

- Fixed hot key texts;
- Fixed battle pet tooltips;
- Restored compatibility with OmniCC, again;
- Misc bug fixes and tweaks.

## Version 3.05

- Fixed archive readability on Macs, blame M$ for this one;
- Fixed power colour issue;
- Fixed 0 ids in item tooltips;
- Restored compatibility with OmniCC, ugh.

## Version 3.04

- Renamed addon, oUF LS -> ls: UI;
- Updated embedded oUF_FCF plug-in;
- Fixed issue in auras module, that caused TempEnchant3 button to be erroneously shown;
- Fixed pet selector availability during pet battles;
- Fixed issue which caused additional bars to stay hidden after pet battle was over;
- Misc bug fixes and tweaks.

## Version 3.03

- Fixed combo points visibility for druids and vehicles;
- Fixed issue caused by an empty item link in mail module;
- Fixed heal prediction anchoring issues;
- Misc tweaks.

## Version 3.02

- Fixed movers' strata and visibility issues;
- Fixed unit frame power text;
- Fixed few colour issues.

## Version 3.01

- Added Legion 7.0 support;
- Removed nameplate module, but it'll return later in Legion;
- Improved performance;
- Updated many textures;
- Numerous bug fixes.

NOTE: v3 is still WIP, so you may expect minor updates every few days.

## Version 2.21

- Revamped "Receive Mail" button tooltip. Now it shows detailed info about mailbox content;
- As of now player castbar has dynamic latency indicator;
- Misc bug fixes and tweaks.

## Version 2.20

- NEW! Finally re-skinned garrison ability button;
- Fixed spec/trinket icons on arena frames;
- Improved item level calculation on unit tooltip.

## Version 2.19

- NEW! Added character info to unit tooltip, hold down Shift button to display spec and iLvl;
- Updated AuraTracker module, brand new flexible in-game config;
- Fixed status icons' height on unit frames;
- Misc bug fixes and tweaks.

## Version 2.18

- Fixed number abbreviation for Korean and Simplified/Traditional Chinese locales.

## Version 2.17

- NEW! Call To Arms bonus tracker in "Group Finder" micro button tooltip;
- Fixed alt power bars on boss frames;
- Fixed pet action bar display.

## Version 2.16

- As of now dispellable debuffs are also shown as special icons on health bars;
- Removed unit frame debuff highlight;
- Misc bug fixes and tweaks.

## Version 2.15

- Updated aura widget on unit frames;
- Added in-game config for unit frame auras;
- Misc bug fixes and tweaks.

NOTE: As of now you can white- or blacklist buffs and debuffs on said frames, or completely disable aura widget, if you wish to do so.

## Version 2.14

- Added a pin to unit frames and nameplate textures at 35% health mark;
- Restored compatibility with OmniCC, yet again;
- Fixed pet action bar taint issue;
- Misc bug fixes and tweaks.

## Version 2.13

- Fixed tag issue.

## Version 2.12

- Updated unit frame status icons (leader, role, pvp, etc), added new class and sheep icons;
  - Sheep icon is a simple polymorph/hex indicator;
- Added "Reload UI" button to config panels;
- Fixed numerous texture issues;
- Misc bug fixes and tweaks.

## Version 2.11

- Bottom bar revamp. New artwork, animations, features and in-game config;
- Misc bug fixes and tweaks.

## Version 2.10

- Fixed party frame visibility issue.

## Version 2.9

- Fixed massive memory leak in aura tracker module;
- Added an option to disable player, target and focus castbars;
- Added an option to disable tooltip module;
- Removed clock form top right corner, reskinned and repositioned blizz clock on minimap is used instead of it now;
- Numerous bug fixes and tweaks.

## Version 2.8

- Added nameplate combo bar and simple in-game config;
- Added a possibility to pick up usable items directly from quest tracker. Hold shift button, drag it and then drop it on your actionbar;
- Replaced character micro button tooltip durability text with a simple indicator on the button;
- Restored compatibility with OmniCC;
- Fixed few bugs here and there.

## Version 2.7

- Fixed combo bar issue.

## Version 2.6

- Added customized unit tooltip;
- Added arena prep frames;
- Added polymorph indicator to arena frames. It replaces spec icon, when enemy player is polymorphed;
- Added horizontal combo bar as an option. To change it, please, go to ..\oUF LS\config\config.lua file, find line 9, that says combo_bar_type = "VERTICAL", and set it to "HORIZONTAL";
- Fixed various taint issues.

## Version 2.5

- Added rarity indication to unit frames and nameplates;
- Added daily quest reset time to quest micro button tooltip;
- New textures for minimap, minimap buttons and various statusbars;
- Updated damage absorb bar behaviour and appearance, now uses blizzard textures;
- New version format is MAJOR.MINOR, I'll stick with v2 for quite a while.
