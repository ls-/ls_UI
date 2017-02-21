## Version 70100.12

- Added "ls: UI" config entry w/ "Enable" button to interface options panel. However, It doesn't change the fact that you still need to reload UI after you're done setting up the addon;
- Added "Use Icon as Indicator" option to disable action button's icon colour change that is based on ability's states: not in range, OOM, not usable, etc;
- Tweaked target/focus frame aura filter, I messed up a bit in v70100.09;
- Honour bar's colour is now based on player's faction;
- Changed addon name's colour so it'll no longer interfere w/ addon list sorting;

## Version 70100.11

- Yet another attempt to fix action bar issues.

## Version 70100.10

- Fixed action bar taint issues. Again...

## Version 70100.09

- Fixed action bar taint issues.

## Version 70100.08

- Revamped player orb;
- Revamped minimap;
- Numerous bug fixes and tweaks.

## Version 70100.07

- Revamped bottom bar. New high-res textures, default button size is 32px, up from 28px, added XP/AP/honour/rep bars;
- Reworked slash commands. Now there's only one command, `/LSUI`, others are passed as arguments, e.g. `/LSMOVERS` is now `/LSUI MOVERS`;
- Misc bug fixes and tweaks.

## Version 70100.06

- Added 7.1.5 support;
- Added login chat message. It can be disabled via in-game config. Quite many people asked for it.

## Version 70100.05

- Fixed micro menu visibility in non-restricted bar mode.

## Version 70100.04

- Fixed binding texts on action buttons.

## Version 70100.03

- Rewrote addon's core, and majority of its modules;
- Reworked in-game config. Added a lot of new options, but some things are still missing. By default, ls: UI entry isn't present in Interface > AddOns section, to create one use **/lsui** (el ess ui) command, I decided to do so to avoid any possible taint issues;
- Reworked CTA tracker. Now it rescans all queues every 10s, and highlights 'Group Finder' micro button if player is eligible for CTA rewards;
- Switched to Munsell colour palette. It should be easier on the eyes;
- Removed party frames. Because I don't use them on my chars, I use compact raid frames instead, it became a bit difficult to maintain them in adequate state;
- Temporarily disabled arena frames. They're quite outdated right now;
- Numerous bug fixes and tweaks.

NOTE: This update is quite big, ~13'000 lines of code, but it doesn't bring a lot of visual changes, they'll come later. I've already started working on new UI design and artwork, however this process will take some time.

## Version 70100.02

- Fixed tooltip issue which was caused by sometimes nonexistent `.GetAttribute` method. There's one more call...

## Version 70100.01

- Added 7.1 support;
- New version format: INTERFACE_VERSION.PATCH;
- Updated embedded oUF;
- Updated tooltip ilvl calculator;
- Fixed tooltip issue which was caused by sometimes nonexistent `.GetAttribute` method.

NOTE: I decided to change version format, because I'm planning to introduce quite many internal changes that will be followed by texture overhaul in the "near" future, however, I won't be able to do so within one single update, it'll take some time. But if I kept previous version format, I'd have to bump major version number few times, and that's not something I'd like to do.

## Version 3.13

- Fixed party frames visibility.

## Version 3.12

- **Removed experience, reputation, artefact power and honour bars from objective tracker.** I had to do so to fix world map frame issues that were caused by tainted objective tracker, e.g. not working Class Hall ability button. I was planning to remove it in 7.1, but I had to push this change a bit earlier. I'll try to find another way to show these stats, but later;
- Removed quest item button skinning, for the same reason as above;
- Updated embedded oUF;
- Added aura filter to show permanent (de)buffs on hostile NPCs;
- Added "talking head", vehicle seat indicator, durability frame, and few more movers;
- Fixed stance bar taint;
- Numerous quite important, but not really interesting code tweaks and bug fixes.

## Version 3.11

- Fixed garrison minimap button for people who don't have either class hall or garrison.

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
