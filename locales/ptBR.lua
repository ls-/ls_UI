-- Contributors:

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	GetLocale
]]

if GetLocale() ~= "ptBR" then return end

--[[ L["ACTION_BARS"] = "Action Bars" ]]
--[[ L["ADDITIONAL_BAR"] = "Additional Bar" ]]
--[[ L["ADVENTURE_JOURNAL_DESC"] = "Show raid lockout information." ]]
--[[ L["ALT_POWER_BAR"] = "Alt Power Bar" ]]
--[[ L["ALT_POWER_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:altpower:cur]|r - the current value;
- |cffffd200[ls:altpower:max]|r - the max value;
- |cffffd200[ls:altpower:perc]|r - the percentage;
- |cffffd200[ls:altpower:cur-max]|r - the current value followed by the max value;
- |cffffd200[ls:altpower:cur-perc]|r - the current value followed by the percentage;
- |cffffd200[ls:color:altpower]|r - colour.

If the current value is equal to the max value, only the max value will be displayed.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=] ]]
--[[ L["ALTERNATIVE_POWER"] = "Alternative Power" ]]
--[[ L["ALWAYS_SHOW"] = "Always Show" ]]
--[[ L["ANCHOR"] = "Attach To" ]]
--[[ L["ANCHOR_TO_CURSOR"] = "Attach to Cursor" ]]
--[[ L["ARTIFACT_LEVEL_TOOLTIP"] = "Artefact Level: |cffffffff%s|r" ]]
--[[ L["ARTIFACT_POWER"] = "Artefact Power" ]]
--[[ L["ASCENDING"] = "Ascending" ]]
--[[ L["AURA_TRACKER"] = "Aura Tracker" ]]
--[[ L["AURA_TYPE"] = "Aura Type" ]]
--[[ L["AURAS"] = "Auras" ]]
--[[ L["AUTO"] = "Auto" ]]
--[[ L["BAG_SLOTS"] = "Bag Slots" ]]
--[[ L["BAR"] = "Bar" ]]
--[[ L["BAR_1"] = "Bar 1" ]]
--[[ L["BAR_2"] = "Bar 2" ]]
--[[ L["BAR_3"] = "Bar 3" ]]
--[[ L["BAR_4"] = "Bar 4" ]]
--[[ L["BAR_5"] = "Bar 5" ]]
--[[ L["BAR_COLOR"] = "Bar Colour" ]]
--[[ L["BAR_TEXT"] = "Bar Text" ]]
--[[ L["BLIZZARD"] = "Blizzard" ]]
--[[ L["BONUS_XP_TOOLTIP"] = "Bonus XP: |cffffffff%s|r" ]]
--[[ L["BORDER"] = "Border" ]]
--[[ L["BORDER_COLOR"] = "Border Colour" ]]
--[[ L["BOSS"] = "Boss" ]]
--[[ L["BOSS_BUFFS"] = "Boss Buffs" ]]
--[[ L["BOSS_BUFFS_DESC"] = "Show buffs cast by the boss." ]]
--[[ L["BOSS_DEBUFFS"] = "Boss Debuffs" ]]
--[[ L["BOSS_DEBUFFS_DESC"] = "Show debuffs cast by the boss." ]]
--[[ L["BOSS_FRAMES"] = "Boss Frames" ]]
--[[ L["BOTTOM"] = "Bottom" ]]
--[[ L["BOTTOM_INSET_SIZE"] = "Bottom Inset Size" ]]
--[[ L["BOTTOM_INSET_SIZE_DESC"] = "Used by the power bar." ]]
--[[ L["BUFFS"] = "Buffs" ]]
--[[ L["BUFFS_AND_DEBUFFS"] = "Buffs and Debuffs" ]]
--[[ L["BUTTON_GRID"] = "Button Grid" ]]
--[[ L["CALENDAR"] = "Calendar" ]]
--[[ L["CAST_ON_KEY_DOWN"] = "Cast on Key Down" ]]
--[[ L["CASTABLE_BUFFS"] = "Castable Buffs" ]]
--[[ L["CASTABLE_BUFFS_DESC"] = "Show buffs cast by you." ]]
--[[ L["CASTABLE_BUFFS_PERMA"] = "Castable Perma Buffs" ]]
--[[ L["CASTABLE_BUFFS_PERMA_DESC"] = "Show permanent buffs cast by you." ]]
--[[ L["CASTABLE_DEBUFFS"] = "Castable Debuffs" ]]
--[[ L["CASTABLE_DEBUFFS_DESC"] = "Show debuffs cast by you." ]]
--[[ L["CASTABLE_DEBUFFS_PERMA"] = "Castable Perma Debuffs" ]]
--[[ L["CASTABLE_DEBUFFS_PERMA_DESC"] = "Show permanent debuffs cast by you." ]]
--[[ L["CASTBAR"] = "Castbar" ]]
--[[ L["CHARACTER_BUTTON_DESC"] = "Show equipment durability information." ]]
--[[ L["CLASS_POWER"] = "Class Power" ]]
--[[ L["CLASSIC"] = "Classic" ]]
--[[ L["CLOCK"] = "Clock" ]]
--[[ L["COLOR_BY_SPEC"] = "Colour by Spec" ]]
--[[ L["COLORS"] = "Colours" ]]
--[[ L["COMMAND_BAR"] = "Command Bar" ]]
--[[ L["COOLDOWN"] = "Cooldown" ]]
--[[ L["COOLDOWN_TEXT"] = "Cooldown Text" ]]
--[[ L["COPY_FROM"] = "Copy from" ]]
--[[ L["COPY_FROM_DESC"] = "Select a unit to copy settings from." ]]
--[[ L["COST_PREDICTION"] = "Cost Prediction" ]]
--[[ L["COST_PREDICTION_DESC"] = "Show a bar that represents power cost of a spell. Doesn't work with instant cast abilities." ]]
--[[ L["COUNT_TEXT"] = "Count Text" ]]
--[[ L["DAILY_QUEST_RESET_TIME_TOOLTIP"] = "Daily Quest Reset Time: |cffffffff%s|r" ]]
--[[ L["DAMAGE_ABSORB_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:absorb:damage]|r - the current value;
- |cffffd200[ls:color:absorb-damage]|r - the colour.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=] ]]
--[[ L["DAMAGE_ABSORB_TEXT"] = "Damage Absorb Text" ]]
--[[ L["DAYS"] = "Days" ]]
--[[ L["DEAD"] = "Dead" ]]
--[[ L["DEBUFF_TYPE"] = "Debuff Type" ]]
--[[ L["DEBUFFS"] = "Debuffs" ]]
--[[ L["DESATURATION"] = "Desaturation" ]]
--[[ L["DESCENDING"] = "Descending" ]]
--[[ L["DETACH_FROM_FRAME"] = "Detach from Frame" ]]
--[[ L["DIFFICULTY_FLAG"] = "Difficulty Flag" ]]
--[[ L["DIGSITE_BAR"] = "Digsite Progress Bar" ]]
--[[ L["DISABLE_MOUSE"] = "Disable Mouse" ]]
--[[ L["DISABLE_MOUSE_DESC"] = "Ignore mouse events." ]]
--[[ L["DISPELLABLE_BUFFS"] = "Dispellable Buffs" ]]
--[[ L["DISPELLABLE_BUFFS_DESC"] = "Show buffs you can spellsteal or purge from your target." ]]
--[[ L["DISPELLABLE_DEBUFF_ICONS"] = "Dispellable Debuff Icons" ]]
--[[ L["DISPELLABLE_DEBUFFS"] = "Dispellable Debuffs" ]]
--[[ L["DISPELLABLE_DEBUFFS_DESC"] = "Show debuffs you can dispel on your target." ]]
--[[ L["DOWN"] = "Down" ]]
--[[ L["DRAG_KEY"] = "Drag Key" ]]
--[[ L["DUNGEONS_BUTTON_DESC"] = "Show 'Call to Arms' information." ]]
--[[ L["DURABILITY_FRAME"] = "Durability Frame" ]]
--[[ L["ENEMY_UNITS"] = "Enemy Units" ]]
--[[ L["ENHANCED_TOOLTIPS"] = "Enhanced Tooltips" ]]
--[[ L["ENTER_SPELL_ID"] = "Enter Spell ID" ]]
--[[ L["EXP_THRESHOLD"] = "Expiration Threshold" ]]
--[[ L["EXP_THRESHOLD_DESC"] = "The threshold (in seconds) below which the remaining time will be shown as a decimal number." ]]
--[[ L["EXPERIENCE"] = "Experience" ]]
--[[ L["EXPIRATION"] = "Expiration" ]]
--[[ L["EXTRA_ACTION_BUTTON"] = "Extra Action Button" ]]
--[[ L["FADE_IN_DELAY"] = "Fade In Delay" ]]
--[[ L["FADE_IN_DURATION"] = "Fade In Duration" ]]
--[[ L["FADE_OUT_DELAY"] = "Fade Out Delay" ]]
--[[ L["FADE_OUT_DURATION"] = "Fade Out Duration" ]]
--[[ L["FADING"] = "Fading" ]]
--[[ L["FCF"] = "Floating Combat Feedback" ]]
--[[ L["FILTER_SETTINGS"] = "Filter Settings" ]]
--[[ L["FILTERS"] = "Filters" ]]
--[[ L["FLAG"] = "Flag" ]]
--[[ L["FLYOUT_DIR"] = "Flyout Direction" ]]
--[[ L["FOCUS_FRAME"] = "Focus Frame" ]]
--[[ L["FOCUS_TOF"] = "Focus & ToF" ]]
--[[ L["FORMAT"] = "Format" ]]
--[[ L["FRAME"] = "Frame" ]]
--[[ L["FREE_BAG_SLOTS_TOOLTIP"] = "Free Bag Slots: |cffffffff%s|r" ]]
--[[ L["FRIENDLY_TERRITORY"] = "Friendly Territory" ]]
--[[ L["FRIENDLY_UNITS"] = "Friendly Units" ]]
--[[ L["GAIN_LOSS_THRESHOLD"] = "Gain/Loss Threshold" ]]
--[[ L["GAIN_LOSS_THRESHOLD_DESC"] = "The threshold (in percentages) above which resource gain and loss will be animated. Set to 100 to disable." ]]
--[[ L["GM_FRAME"] = "Ticket Status Frame" ]]
--[[ L["GOLD"] = "Gold" ]]
--[[ L["GROWTH_DIR"] = "Growth Direction" ]]
--[[ L["HEAL_ABSORB_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:absorb:heal]|r - the current value;
- |cffffd200[ls:color:absorb-heal]|r - the colour.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=] ]]
--[[ L["HEAL_ABSORB_TEXT"] = "Heal Absorb Text" ]]
--[[ L["HEAL_PREDICTION"] = "Heal Prediction" ]]
--[[ L["HEALTH"] = "Health" ]]
--[[ L["HEALTH_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:health:cur]|r - the current value;
- |cffffd200[ls:health:perc]|r - the percentage;
- |cffffd200[ls:health:cur-perc]|r - the current value followed by the percentage;
- |cffffd200[ls:health:deficit]|r - the deficit value.

If the current value is equal to the max value, only the max value will be displayed.

Use |cffffd200[nl]|r for line breaking.]=] ]]
--[[ L["HEALTH_TEXT"] = "Health Text" ]]
--[[ L["HEIGHT"] = "Height" ]]
--[[ L["HONOR"] = "Honour" ]]
--[[ L["HONOR_LEVEL_TOOLTIP"] = "Honour Level: |cffffffff%d|r" ]]
--[[ L["HOSTILE_TERRITORY"] = "Hostile Territory" ]]
--[[ L["HOURS"] = "Hours" ]]
--[[ L["ICON"] = "Icon" ]]
--[[ L["INDEX"] = "Index" ]]
--[[ L["INSPECT_INFO"] = "Inspect Info" ]]
--[[ L["INSPECT_INFO_DESC"] = "Show the current tooltip unit's specialisation and item level. This data may not be available right away." ]]
--[[ L["INVALID_TAGS_ERR"] = "Attempted to use invalid tags: %s." ]]
--[[ L["INVENTORY_BUTTON"] = "Inventory" ]]
--[[ L["INVENTORY_BUTTON_DESC"] = "Show currency information." ]]
--[[ L["INVENTORY_BUTTON_RCLICK_TOOLTIP"] = "|cffffffffRight-Click|r to toggle bag slots." ]]
--[[ L["ITEM_COUNT"] = "Item Count" ]]
--[[ L["ITEM_COUNT_DESC"] = "Show how many of an item you have in your bank and bags." ]]
--[[ L["KEYBIND_TEXT"] = "Keybind Text" ]]
--[[ L["LATENCY"] = "Latency" ]]
--[[ L["LATENCY_HOME"] = "Home" ]]
--[[ L["LATENCY_WORLD"] = "World" ]]
--[[ L["LATER"] = "Later" ]]
--[[ L["LEFT"] = "Left" ]]
--[[ L["LEFT_DOWN"] = "Left and Down" ]]
--[[ L["LEFT_UP"] = "Left and Up" ]]
--[[ L["LEVEL_TOOLTIP"] = "Level: |cffffffff%d|r" ]]
--[[ L["LOCK"] = "Lock" ]]
--[[ L["LOCK_BUTTONS"] = "Lock Buttons" ]]
--[[ L["LOCK_BUTTONS_DESC"] = "Prevents you from picking up and dragging spells off the action bar." ]]
--[[ L["LOOT_ALL"] = "Loot All" ]]
--[[ L["M_SS_THRESHOLD"] = "M:SS Threshold" ]]
--[[ L["M_SS_THRESHOLD_DESC"] = "The threshold (in seconds) below which the remaining time will be shown in the M:SS format. Set to 0 to disable." ]]
--[[ L["MACRO_TEXT"] = "Macro Text" ]]
--[[ L["MAIN_BAR"] = "Main Bar" ]]
--[[ L["MAINMENU_BUTTON_DESC"] = "Show performance information." ]]
--[[ L["MAINMENU_BUTTON_HOLD_TOOLTIP"] = "|cffffffffHold Shift|r to show memory usage." ]]
--[[ L["MAX_ALPHA"] = "Max Alpha" ]]
--[[ L["MEMORY"] = "Memory" ]]
--[[ L["MICRO_BUTTONS"] = "Micro Buttons" ]]
--[[ L["MIN_ALPHA"] = "Min Alpha" ]]
--[[ L["MINUTES"] = "Minutes" ]]
--[[ L["MIRROR_TIMER"] = "Mirror Timers" ]]
--[[ L["MIRROR_TIMER_DESC"] = "Breath, fatigue and other indicators." ]]
--[[ L["MODE"] = "Mode" ]]
--[[ L["MOUNT_AURAS"] = "Mount Auras" ]]
--[[ L["MOUNT_AURAS_DESC"] = "Show mount auras." ]]
--[[ L["MOVER_BUTTONS_DESC"] = "|cffffffffClick|r to toggle buttons." ]]
--[[ L["MOVER_CYCLE_DESC"] = "Press the |cffffffffAlt|r key to cycle through frames under the cursor." ]]
--[[ L["MOVER_RESET_DESC"] = "|cffffffffShift-Click|r to reset the position." ]]
--[[ L["NAME"] = "Name" ]]
--[[ L["NAME_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:name]|r - the name;
- |cffffd200[ls:name:5]|r - the name shortened to 5 characters;
- |cffffd200[ls:name:10]|r - the name shortened to 10 characters;
- |cffffd200[ls:name:15]|r - the name shortened to 15 characters;
- |cffffd200[ls:name:20]|r - the name shortened to 20 characters;
- |cffffd200[ls:server]|r - the (*) tag for players from foreign realms;
- |cffffd200[ls:color:class]|r - the class colour;
- |cffffd200[ls:color:reaction]|r - the reaction colour;
- |cffffd200[ls:color:difficulty]|r - the difficulty colour.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=] ]]
--[[ L["NO_SEPARATION"] = "No Separation" ]]
--[[ L["NOTHING_TO_SHOW"] = "Nothing to show." ]]
--[[ L["NPE_FRAME"] = "NPE Tutorial Frame" ]]
--[[ L["NUM_BUTTONS"] = "Number of Buttons" ]]
--[[ L["NUM_ROWS"] = "Number of Rows" ]]
--[[ L["NUMERIC"] = "Numeric" ]]
--[[ L["NUMERIC_PERCENTAGE"] = "Numeric & Percentage" ]]
--[[ L["OBJECTIVE_TRACKER"] = "Objective Tracker" ]]
--[[ L["OOM"] = "Out of Power" ]]
--[[ L["OOM_INDICATOR"] = "Out-of-Power Indicator" ]]
--[[ L["OOR"] = "Out of Range" ]]
--[[ L["OOR_INDICATOR"] = "Out-of-Range Indicator" ]]
--[[ L["OPEN_CONFIG"] = "Open Config" ]]
--[[ L["ORBS"] = "Orbs" ]]
--[[ L["OTHER"] = "Other" ]]
--[[ L["OTHERS_FIRST"] = "Others First" ]]
--[[ L["OUTLINE"] = "Outline" ]]
--[[ L["PER_ROW"] = "Per Row" ]]
--[[ L["PET_BAR"] = "Pet Bar" ]]
--[[ L["PET_BATTLE_BAR"] = "Pet Battle Bar" ]]
--[[ L["PET_CASTBAR"] = "Pet Casting Bar" ]]
--[[ L["PET_FRAME"] = "Pet Frame" ]]
--[[ L["PLAYER_FRAME"] = "Player Frame" ]]
--[[ L["PLAYER_PET"] = "Player & Pet" ]]
--[[ L["PLAYER_TITLE"] = "Player Title" ]]
--[[ L["POINT"] = "Point" ]]
--[[ L["POINT_DESC"] = "Point of the object." ]]
--[[ L["POSITION"] = "Position" ]]
--[[ L["POWER"] = "Power" ]]
--[[ L["POWER_FORMAT_DESC"] = [=[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:power:cur]|r - the current value;
- |cffffd200[ls:power:max]|r - the max value;
- |cffffd200[ls:power:perc]|r - the percentage;
- |cffffd200[ls:power:cur-max]|r - the current value followed by the max value;
- |cffffd200[ls:power:cur-perc]|r - the current value followed by the percentage;
- |cffffd200[ls:power:deficit]|r - the deficit value;
- |cffffd200[ls:color:power]|r - the colour.

If the current value is equal to the max value, only the max value will be displayed.

Use |cffffd200||r|r to close colour tags.
Use |cffffd200[nl]|r for line breaking.]=] ]]
--[[ L["POWER_TEXT"] = "Power Text" ]]
--[[ L["PREVIEW"] = "Preview" ]]
--[[ L["PVP_ICON"] = "PvP Icon" ]]
--[[ L["QUESTLOG_BUTTON_DESC"] = "Show daily quest reset timer." ]]
--[[ L["RAID_ICON"] = "Raid Icon" ]]
--[[ L["RCLICK_SELFCAST"] = "Self Cast on Right-Click" ]]
--[[ L["REACTION"] = "Reaction" ]]
--[[ L["RELATIVE_POINT"] = "Relative Point" ]]
--[[ L["RELATIVE_POINT_DESC"] = "The point of the region to attach the object to." ]]
--[[ L["RELOAD_NOW"] = "Reload Now" ]]
--[[ L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"] = "You've just changed a character only setting. These settings are independent of your profiles. For the changes to take effect, you must reload UI." ]]
--[[ L["RELOAD_UI_WARNING"] = "Reload UI after you're done setting up the addon." ]]
--[[ L["RESTORE_DEFAULTS"] = "Restore Defaults" ]]
--[[ L["RESTRICTED_MODE"] = "Restricted Mode" ]]
--[[ L["RESTRICTED_MODE_DESC"] = [=[Enables artwork, animations and dynamic resizing for the main action bar.

|cffdc4436Warning!|r Many action bar customisation options won't be available in this mode.|r]=] ]]
--[[ L["RIGHT"] = "Right" ]]
--[[ L["RIGHT_DOWN"] = "Right and Down" ]]
--[[ L["RIGHT_UP"] = "Right and Up" ]]
--[[ L["ROWS"] = "Rows" ]]
--[[ L["RUNES"] = "Runes" ]]
--[[ L["SECOND_ANCHOR"] = "Second Anchor" ]]
--[[ L["SECONDS"] = "Seconds" ]]
--[[ L["SELF_BUFFS"] = "Self Buffs" ]]
--[[ L["SELF_BUFFS_DESC"] = "Show buffs cast by the unit itself." ]]
--[[ L["SELF_BUFFS_PERMA"] = "Perma Self Buffs" ]]
--[[ L["SELF_BUFFS_PERMA_DESC"] = "Show permanent buffs cast by the unit itself." ]]
--[[ L["SELF_DEBUFFS"] = "Self Debuffs" ]]
--[[ L["SELF_DEBUFFS_DESC"] = "Show debuffs cast by the unit itself." ]]
--[[ L["SELF_DEBUFFS_PERMA"] = "Perma Self Debuffs" ]]
--[[ L["SELF_DEBUFFS_PERMA_DESC"] = "Show permanent debuffs cast by the unit itself." ]]
--[[ L["SEPARATION"] = "Separation" ]]
--[[ L["SHADOW"] = "Shadow" ]]
--[[ L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffShift-Click|r to show as experience bar." ]]
--[[ L["SHOW_ON_MOUSEOVER"] = "Show on Mouseover" ]]
--[[ L["SIZE"] = "Size" ]]
--[[ L["SIZE_OVERRIDE"] = "Size Override" ]]
--[[ L["SIZE_OVERRIDE_DESC"] = "If set to 0, element's size will be calculated automatically." ]]
--[[ L["SORT_DIR"] = "Sort Direction" ]]
--[[ L["SORT_METHOD"] = "Sort Method" ]]
--[[ L["SPACING"] = "Spacing" ]]
--[[ L["SPELL_CAST"] = "Cast" ]]
--[[ L["SPELL_CHANNELED"] = "Channelled" ]]
--[[ L["SPELL_FAILED"] = "Failed" ]]
--[[ L["SPELL_UNINTERRUPTIBLE"] = "Uninterruptible" ]]
--[[ L["STANCE_BAR"] = "Stance Bar" ]]
--[[ L["TALKING_HEAD_FRAME"] = "Talking Head Frame" ]]
--[[ L["TARGET_FRAME"] = "Target Frame" ]]
--[[ L["TARGET_INFO"] = "Target Info" ]]
--[[ L["TARGET_INFO_DESC"] = "Show the current tooltip unit's target." ]]
--[[ L["TARGET_TOT"] = "Target & ToT" ]]
--[[ L["TEXT"] = "Text" ]]
--[[ L["TEXT_HORIZ_ALIGNMENT"] = "Horizontal Alignment" ]]
--[[ L["TEXT_VERT_ALIGNMENT"] = "Vertical Alignment" ]]
--[[ L["THREAT_GLOW"] = "Threat Glow" ]]
--[[ L["TIME"] = "Time" ]]
--[[ L["TOF_FRAME"] = "Target of Focus Frame" ]]
--[[ L["TOGGLE_ANCHORS"] = "Toggle Anchors" ]]
--[[ L["TOOLTIP_IDS"] = "Spell and Item IDs" ]]
--[[ L["TOOLTIPS"] = "Tooltips" ]]
--[[ L["TOP"] = "Top" ]]
--[[ L["TOP_INSET_SIZE"] = "Top Inset Size" ]]
--[[ L["TOP_INSET_SIZE_DESC"] = "Used by the class, alternative and additional power bars." ]]
--[[ L["TOT_FRAME"] = "Target of Target Frame" ]]
--[[ L["TOTEMS"] = "Totems" ]]
--[[ L["UI_LAYOUT"] = "UI Layout" ]]
--[[ L["UI_LAYOUT_DESC"] = "Changes the appearance of the player and pet frames. This will also change the layout of the UI." ]]
--[[ L["UNITS"] = "Units" ]]
--[[ L["UNSPENT_TRAIT_POINTS_TOOLTIP"] = "Unspent Trait Points: |cffffffff%s|r" ]]
--[[ L["UNUSABLE"] = "Not Usable" ]]
--[[ L["UP"] = "Up" ]]
--[[ L["USABLE"] = "Usable" ]]
--[[ L["USE_BLIZZARD_VEHICLE_UI"] = "Use Blizzard Vehicle UI" ]]
--[[ L["VEHICLE_EXIT_BUTTON"] = "Vehicle Exit Button" ]]
--[[ L["VEHICLE_SEAT_INDICATOR"] = "Vehicle Seat Indicator" ]]
--[[ L["VISIBILITY"] = "Visibility" ]]
--[[ L["WIDTH"] = "Width" ]]
--[[ L["WIDTH_OVERRIDE"] = "Width Override" ]]
--[[ L["WORD_WRAP"] = "Word Wrap" ]]
--[[ L["X_OFFSET"] = "xOffset" ]]
--[[ L["XP_BAR"] = "XP Bar" ]]
--[[ L["Y_OFFSET"] = "yOffset" ]]
--[[ L["YOURS_FIRST"] = "Yours First" ]]
--[[ L["ZONE_ABILITY_BUTTON"] = "Zone Ability Button" ]]
--[[ L["ZONE_TEXT"] = "Zone Text" ]]
