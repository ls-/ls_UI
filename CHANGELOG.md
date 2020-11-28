# CHANGELOG

## Version 90002.03

- Fixed an issue that prevented square minimap from working in Torghast.

## Version 90002.02

- Added support for charged combo points. For now it'll use Chi colour. I'll add a proper colour
  later.

NOTE: I'm aware of the fact that the minimap doesn't work in Torghast.

## Version 90002.01

- Added 9.0.2 support;
- Fixed azerite power bar visibility. Now it's disabled when HoA is unequipped;
- Updated embeds;
- Misc bug fixes and tweaks.

## Version 90001.05

- Added LibSharedMedia support. Can be found at /LSUI > General > Fonts. For now, only unit frames,
  action bars, and cooldown spirals support font customisation. For the sake of consistency all
  fonts of a given module will be updated at once, for example, if you change the unit frame font,
  then health, heal prediction, power, alternative power, castbar, name, and aura fonts will be
  changed. However, each element will retain individual size controls, and unit frame auras will
  retain their shadow and outline controls on top of that. I'll be adding LSM support to missing
  modules with the next update;
- Reenabled extra and zone action buttons. Sadly, the size option is gone;
- Fixed an issue where action bar fading won't resume after leaving a vehicle;
- Updated French translation. Translated by cybern4ut@Curse and Brainc3ll@Curse;
- Updated Spanish translation. Translated by justregular16@Curse.

![Imgur](https://i.imgur.com/eCIxxqs.gif)

## Version 90001.04

- Fixed paragon reputation handling;
- Fixed additional power bar visibility for priests, shamans, and druids.

## Version 90001.03

- Fixed an "issue" where you'd see an error while managing profiles. Due to how the addon is  
  written it's just an error message, but nothing was actually broken and everything was  
  updating properly.

## Version 90001.02

- Fixed health tags;
- Fixed hotkey font.

## Version 90001.01

- Added 9.0.1 support.

NOTE: Extra and zone buttons are currently disabled, I'll figure out what to do with them later.

## Version 80300.01

- Added 8.3.0 support;
- Fixed tooltip errors.

## Version 80205.01

- Added 8.2.5 support;
- Fixed an issue where the round minimap's size and position would be set incorrectly;
- Fixed an issue where movers' tootlips didn't disappear sometimes;
- Updated Simplified Chinese translation. Translated by aenerv7@Curse.

## Version 80200.03

- Added resizeable square minimap. It's the new default style for the "Classic" UI layout;
- Added an option to hide MBC tooltip;
- Fixed an issue where some font strings didn't have a shadow;
- Updated Simplified Chinese translation. Translated by aenerv7@Curse;
- Misc bug fixes and tweaks.

![Imgur](https://i.imgur.com/nmPJzT1.png)

## Version 80200.02

- Added minimap button collection. Can be found at /LSUI > Minimap > Collect Buttons. It can  
  collect both Blizz and addon minimap buttons, however, by default, it only collects addon  
  buttons. If Minimap Button Frame is detected, the feature will be disabled;
- Added portraits to pet, target of target, and target of focus frames;
- Fixed an issue where disabling player/pet castbars would re-enable Blizz player/pet castbars.  
  Quartz users rejoice!
- Misc bug fixes and tweaks;
- Updated embeds.

![Imgur](https://i.imgur.com/WSm2tdk.gif)

## Version 80200.01

- Added 8.2.0 support;
- Added new M+ affix's auras to the aura filter;
- Updated embeds.

## Version 80100.10

- Added MaxDps Rotation Helper support;
- Fixed an issue where player's buffs and debuffs weren't updating correctly when changing their  
  settings;
- Updated both Spanish translations. Translated by Gotxiko@Curse;
- Updated embedded oUF.

NOTE: You'll have to restart WoW client to make things work after the update.

## Version 80100.09

- Added portraits to target, focus, boss, and "classic" player frames. Available in 2D and 3D.  
  Disabled by default;
- Slightly reworked movers. Added highlight textures, grid and axes;
- Updated "Classic" layout. Moved unit frames closer to the bottom of the screen;
- Moved action buttons' count/stack text above the cooldown spiral.

![Imgur](https://i.imgur.com/yMKaGiW.gif)

NOTE: You'll have to restart WoW client to make things work after the update.

## Version 80100.08

- Reworked unit frame aura filters:
  - Added an option to create custom aura filters. Can be found at /LSUI > General > Aura Filters.  
    You can create both black- and whitelist, after you create your aura filter, you'll need to  
    enable it for a unit frame. There's a new "User-created" section in UF Auras that contains all  
    custom filters. Please note that all custom filters are global and shared across all chars  
    and profiles;
  - Added tanks', healers', and misc buffs and debuffs. Misc or miscellaneous is everything that  
    wasn't filtered out by other filters.
- Added reset confirmation popups to all "Restore Defaults" buttons;
- Updated aura types' icons. Added support for enrage auras.

NOTE: You'll have to restart WoW client to make things work after the update.

## Version 80100.07

- Added tag editor. Can be found at /LSUI > General > Tags. Moved all of my tags to the config, if  
  you know Lua, you can try editing mine or creating your own. If you find any tags that stopped  
  working, please, report them;
- Moved colours from the profile table to the global one;
- Updated embedded oUF.

## Version 80100.06

- Removed floating combat feedback from the player frame;
- Fixed xp bonus bar updates;
- Fixed rune bar sorting;
- Updated azerite bar to use a custom texture. Suggested by Heybarbaruiva@WoWInterface;
- Updated embedded oUF.

## Version 80100.05

- Added a workaround for a Blizz's bug where the default UI tries to call missing  
  AchievementMicroButton_Update function;
- Added a workaround for a Blizz's bug where vehicle's health bar on the player frame wasn't  
  updating correctly;
- Fixed an issue where the main action bar's page wasn't updated correctly while doing "The Cycle  
  of Life" world quest;
- Updated embedded oUF.

## Version 80100.04

- Added 8.1.5 support;
- Adjusted custom character frame so it doesn't interfere with Pawn's and DejaCharacterStats'  
  buttons;
- Updated embedded oUF.

## Version 80100.03

- Reworked the character frame. It now shows info on gems and enchants. Enabled by default, can be  
  toggled at /LSUI > Blizzard > Character Frame;
- Added the "Clean Up" button to the mail frame. Removes all empty messages that are left after  
  using Blizz's "Open All" button. Disabled by default, can be toggled at /LSUI > Blizzard > Mail;
- Added an option to auto-dismiss the "Talking Head" frame. Disabled by default, can be toggled  
  at /LSUI > Blizzard > Talking Head Frame > Hide;
- Updated French Translation. Translated by edward9mm@Curse;
- Misc bug fixes and tweaks;
- Updated embeds.

## Version 80100.02

- Reworked the micro menu module and its config;
- Fixed an issue where class power bar would sometimes disappear from the player orb;
- Updated French Translation. Translated by edward9mm@Curse;
- Updated German Translation. Translated by NicoCaine90@Curse;
- Updated both Spanish translations. Translated by Gotzon@Curse;
- Updated embeds.

## Version 80100.01

- Added 8.1.0 support;
- Added AdiButtonAuras support. Requires AdiButtonAuras alpha release;
- Fixed an issue where opening PvP panel was causing errors;
- Updated embeds.

## Version 80000.15

- Fixed an issue where xp bar was causing errors when there's no bars to show;
- Fixed unit name colouring in tooltips;
- Updated Simplified Chinese translation. Translated by aenerv7@Curse.

## Version 80000.14

- Fixed an issue which made pet action buttons turn black;
- Fixed minimap zone text updates.

## Version 80000.13

- Added options to adjust practically every colour ls: UI uses. Can be found at /LSUI > General >  
  Colours;
- Removed action button desaturation and colouring on cooldown. It's too buggy;
- Removed [ls:altpower:cur-color-max], [ls:altpower:cur-color-perc], [ls:power:cur-color-max], and  
  [ls:power:cur-color-perc] tags. Their uncoloured counterparts will be used instead;
- Fixed castbar's detachment from and reattachment to its unit frame;
- Added partial German Translation. Translated by NicoCaine90@Curse, Terijaki@Curse;
- Updated Simplified Chinese translation. Translated by aenerv7@Curse;
- Updated embeds.

![Imgur](https://i.imgur.com/ctrDyrI.png)

NOTE: You'll have to restart WoW client to make things work after the update.

## Version 80000.12

- Added options to adjust text size, outline, and shadow of various unit frame elements, e.g.,  
  health, power, etc;
- Reworked resource gain/loss animations. Added health loss animations, and options to adjust  
  health, power, class power, and alternative power gain/loss thresholds;
- Tweaked unit frame border textures;
- Fixed compatibility issues with Masque;
- Updated embeds.

![Imgur](https://i.imgur.com/3qWfxxS.gif)

## Version 80000.11

- Added options to adjust auras' count text and aura type icon. It's also possible to display  
  actual debuff types instead of generic down arrows;
- Added options to adjust xp bar's text's format and visibility;
- Added options to adjust castbars' colours;
- Added a hack for cooldown numbers. Cooldown spirals are still bugged, but that's a Blizz bug;
- Updated minimap button handling. This should greatly improve compatibility w/ addons that add  
  various markers, for instance, TomTom, ZygorGuides;
- Updated embeds.

## Version 80000.10

- Added cooldown options to the "Unit Frames" and unit frames' "Auras" configs;
- Removed "Show Cooldown Bling" option. The bling is disabled on all handled cooldowns now  
  because the animation is bugged anyway;
- Updated Simplified Chinese translation. Translated by aenerv7@GitHub;
- Updated embeds.

## Version 80000.09

- Reworked fade in and out animations. Previously, their performance was degrading over time, and  
  after long gaming sessions they could cause micro stuttering and/or big freezes when being played;
- Added unit frame tag validation to avoid issues caused by invalid tags;
- Added options to colour minimap border and to adjust border's and text's colours;
- Added options to adjust xp bar's text;
- Added the option to colour player orb's border;
- Normal and war mode phase indicators now use different icons, blue and red respectively;
- Updated both Spanish translations. Translated by Gotzon@Curse;
- Updated embeds.

## Version 80000.08

- Fixed the "Inventory" micro button's currency tracker;
- Fixed an issue where getting and/or setting a key binding text for a button with no name would  
  result in an error. This issue mainly affected the Pet Battle UI;
- Blizz castbars' movers are now properly disabled when the default castbars aren't actually  
  used;
- Player's buffs, debuffs, and totems are now hidden while doing pet battles.

## Version 80000.07

- Reworked UF config tables' structure. Target, target of target, focus, target of focus, and boss  
  frames' settings are cross-layout, so their settings are shared between "Orbs" and "Classic" UI  
  layouts. Player and pet frames' settings will stay tied to UI layouts because those frames are  
  unique. Unit frame settings of the currently active UI layout will be copied, but some settings  
  may be lost. This will also help people with copying profiles from one char to another, even if  
  different UI layouts are used on those chars;
- Fixed numerous bugs in the "Unit Frames" config. Copying settings between unit frame, incl. aura  
  filters, should work as intended now;
- Unit frame auras' min and max sizes are set to 24px and 64px respectively. These will also be  
  applied to automatic size calculations;
- Reduced the xp bar's width and updated the artwork;
- Updated embeds.

## Version 80000.06

- Fixed action buttons' icons' colouring.

## Version 80000.05

- Added "Desaturation" section to "Action Bars" config. Replaces "Desaturate on Cooldown" and  
  "Desaturate when Not Usable" options;
- Fixed the default castbars' skin.

## Version 80000.04

- Reworked cooldowns' handling. Action bars, auras, and aura tracker received a set of options to  
  customise cooldowns' appearance. Unit frames will get a similar update a bit later;
- Reworked mirror timers, e.g., fatigue, breath, etc. They now show the remaining time in the M:SS  
  format;
- Added the default cast bars' skin for people who don't use my unit frames;
- Updated "Blizzard" config section. Added options to customise mirror timers, digsite bar;
- Updated "Action Bars" config section. In addition to aforementioned cooldown changes, I also  
  added options to customise action buttons' colours and to desaturate icons when buttons are  
  unusable;
- Updated the loot frame, so it's impossible to click through it;
- Numerous bug fixes and tweaks;
- Updated embeds.

NOTE #1: You'll have to restart WoW client to make things work after the update.

NOTE #2: Aura module's config is now cross-layout, which means that it'll use the same settings  
for both "Orbs" and "Classic" layouts. Although almost everything should be copied, some data loss  
may occur.

## Version 80000.03

- Reworked micro menu. Again. Added options to split micro menu into two bars and to assign each  
  button to either bar individually;
- Fixed loot frame error that occurred for people who like to spam-click things;
- Updated both Spanish translations. Translated by Gotzon@Curse.

## Version 80000.02

- Fixed "Classic" layout.

## Version 80000.01

- Added 8.0.1 support;
- Added custom loot frame;
- Added mouseover key binding. Use "/lsui kb" command or "Binding Mode" button in the config;
- Added options to enable DK runes' sorting and colouring by spec;
- Reworked action bar hub. Retired bag bar;
- Reworked micro menu and its config. Added "Inventory" micro button;
- Reworked tooltips. Added tooltip mover and the option to attach it to the mouse cursor;
- Numerous bug fixes and tweaks;
- Updated embeds.

## Version 70300.16

- Fixed number formatting for non-Asian locales.

## Version 70300.15

- Added Russian translation. Translated by Biowoolf@WoWInterface and me;
- Updated Simplified Chinese translation. Translated by aenerv7@GitHub;
- Updated embeds.

## Version 70300.14

- Added French translation. Translated by Daniel8513@Curse;
- Updated Spanish translation. Translated by Gotzon@Curse;
- Added Latin American Spanish translation. Copied from Spanish.

## Version 70300.13

- Added Simplified Chinese translation. Translated by aenerv7@GitHub;
- Added Spanish translation. Translated by Gotxiko@GitHub a.k.a. Gotzon@Curse;
- Fixed issues which caused some tags to not update right away.

## Version 70300.12

- Added "Enable" toggle for each unit frame;
- Added hotkey, macro, and count text size controls to action bar config;
- Added minimap difficulty flag visibility and position controls;
- Fixed issue which caused XP bar to not update its size;
- Updated embeds.

## Version 70300.11

- Fixed number formatting.

## Version 70300.10

- Added options to adjust minimap clock and zone text position and visibility;
- Added optional minimap zone text border;
- Blizzard minimap buttons are now movable;
- Added options to adjust boss frames growth direction and spacing;
- Added the option to preview boss and pet frames;
- Added the option to cycle through movers under the cursor by pressing Alt key;
- Added the option to adjust castbar height;
- Added the option to adjust XP bar height. Unavailable in restricted mode;
- Added the option to copy unit frame aura filter settings from another unit frame;
- Fixed the issue which caused unit frame auras settings to not be applied correctly after being changed in the config;
- Fixed the issue where castbar position wasn't set correctly;
- Tweaked formulas that are used to calculate action bar size, you may or may not need to adjust their positions;
- Various bug fixes, code reworks and tweaks.

NOTE: You'll have to restart WoW client to make things work after the update.

## Version 70300.09

- Added "Use Blizzard Vehicle UI" option to action bar config. Unavailable in restricted mode;
- Added disable/enable toggle to pet battle bar config. Unavailable in restricted mode.

## Version 70300.08

- Added "Cast on Key Down" option to action bar config;
- Added "Show Cooldown Bling" option to action bar config;
- Added missing action bar visibility toggles;
- Minimap module will now set round mask on enable;
- Fixed stance bar issue which caused empty buttons to be shown;
- Fixed micro menu fade control.

## Version 70300.07

- Fixed font scaling on HiDPI displays;
- Updated embedded LibActionButton.

## Version 70300.06

- Added the option to use hotkey text as OOM indicator. By default button's icon is used as such;
- Minor bug fixes and tweaks.

## Version 70300.05

- Added "Desaturate on CD" option to action bar config;
- Fixed issue with spell activation glow effect not being shown. Client restart is required;
- Fixed issue which caused pet action button grid to not respect its settings.

## Version 70300.04

- Reworked action bars. Added numerous options: fading, grid, hotkey, name visibility. Each bar is configured individually;
- Tweaked XP bars. Added rested XP bar. Removed idle animation from XP bars;
- Added movers for pet battle pet selector and turn timer;
- Updated embeds.

NOTE: Bar module revamp was a big update code-wise, thus you will experience few bugs here and there, feel free to report them.

## Version 70300.03

- Added currency options for backpack tooltip. See /lsui > Action Bars > Bags panel;
- Added [nl] tag for breaking lines;
- Reworked minimap button handling, it should be compatible with addons that add various buttons or indicators to minimap;
- Updated embedded oUF;

## Version 70300.02

- Added Veiled Argunite to backpack tooltip;
- Fixed vehicle exit button;
- Fixed and tweaked xp bar.

## Version 70300.01

- Added player's and dispellable auras to boss frame aura filter. Disabled by default;
- Added options to enable objective tracker and aura tracker dragging only if a modifier key is being held down. Disabled by default;
- Misc bug fixes and tweaks.

## Version 70200.12

- Fixed classic layout.

## Version 70200.11

- New PvP banner artwork;
- Customisable totem bar. See in-game config Buffs and Debuffs > Totems tab;
- Added reset buttons for all UF elements;
- Fixed few cooldown spiral bugs;
- Fixed few colour tag issues.

NOTE: Totem bar is a reskin of default one. If/when Blizz devs add necessary API to do so, I'll write my own.

## Version 70200.10

- Fixed auras' movers.

## Version 70200.09

- Reworked auras. Added "Buffs and Debuffs" config entry;
- Updated embeds;
- Movers' positions are now properly updated after profile change.

## Version 70200.08

- Reworked in-game config;
- Updated embeds.

NOTE: This update is huge, there's definitely some bugs here and there.

## Version 70200.07

- Addon now uses AceDB. I strongly recommend to /reload UI right after your first login on each char, otherwise you risk losing all your settings if you get DCed;
- Not full class powers are now a bit dimmed.

NOTE: You have to restart your client to make this update work.

## Version 70200.06

- Fixed loading process.

## Version 70200.05

- Reworked unit frames;
- Fixed old bug in action button code. It's affecting game performance quite significantly.

KNOWN CAVEATS: Player health bar texture may distort/stretch from time to time. It's a known Blizzard bug, I already reported it, and it's fixed in the latest PTR build.

NOTE #1: There's no in-game config for new unit frames' features yet, however, new unit frames are quite customisable, e.g., you can resize them, enable/disable various elements, etc, so you may want to edit /core/defaults.lua file. I'm not adding new features to in-game config just yet, because I need to add optional horizontal player and pet frames, alternative layout style, figure out new config table(s) structure, and while doing so I also need to consider future addition of profiles. And only then I can start working on new in-game config which will be based on Ace* libs, basically ls: UI is slowly turning into ElvUI w/ artwork.

NOTE #2: I'll be removing AuraTracker in the near future, I tend to use WA more and more nowadays.

## Version 70200.04

- Updated embedded oUF to 7.0.0;
- Misc bug fixes and tweaks.

## Version 70200.03

- Slimmed down cast bars. I'm currently preparing for unit frame revamp, so I needed to make cast bars a bit more compact;
- Reworked main micro button tooltip. Because many people have either way too many addons installed or use quite "heavy" addons, calculations that are necessary for memory usage info may cause micro freezes. As of now, memory usage info won't be shown until you hold down shift key;
- Fixed artefact trait tooltips;
- Fixed action bar controller issues;
- Misc bug fixes and tweaks.

## Version 70200.02

- Added paragon rep support to the rep bar;
- Reworked backpack tooltip. Nethershards, Seals of Broken Fate and Legionfall War Supplies are always included, you can track something else instead. Added currencies' caps. Capped currencies' counters are coloured red, uncapped green, others white.

## Version 70200.01

- Added 7.2 support;
- Added permanent self buff and debuff filter for focus/target frame auras. Some of permanent buffs and debuffs were [blacklisted](https://github.com/ls-/ls_UI/blob/master/modules/unitframes/elements/auras.lua#L29-L81);
- Moved additional mana bar, which is used by elemental shamans, balance druids and shadow priests, to the left side of player frame, where various class power bars usually are. Theoretically class power and additional mana bars shouldn't overlap, but if it happens, I'll revert this change;
- Removed "Receive All" mail button. There's default one now;
- Misc bug fixes and tweaks.

## Version 70100.15

- Fixed artefact bar text.

## Version 70100.14

- Added unit frame aura filter config, reworked the filter;
- Added AK info to artefact bar tooltip;
- Fixed a bug in aura tracker config that didn't allow to scroll aura list;
- Removed login chat message;
- Numerous bug fixes and tweaks.

NOTE: This update is quite big, so there might be some bugs.

## Version 70100.13

- Disable icons' desaturation if they aren't used as indicators.

## Version 70100.12

- Added "ls: UI" config entry w/ "Enable" button to interface options panel. However, It doesn't change the fact that you still need to reload UI after you're done setting up the addon;
- Added "Use Icon as Indicator" option to disable action button's icon colour change that is based on ability's states: not in range, OOM, not usable, etc;
- Tweaked target/focus frame aura filter, I messed up a bit in v70100.09;
- Honour bar's colour is now based on player's faction;
- Changed addon name's colour so it'll no longer interfere w/ addon list sorting.

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
