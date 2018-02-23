local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
-- These rely on Blizz strings
L["ADVENTURE_JOURNAL"] = _G.ADVENTURE_JOURNAL
L["ARTIFACT_POWER"] = _G.ARTIFACT_POWER
L["AURAS"] = _G.AURAS
L["BUFFS_AND_DEBUFFS"] = _G.BUFFOPTIONS_LABEL
L["CALENDAR_EVENT_ALARM_MESSAGE"] = _G.CALENDAR_EVENT_ALARM_MESSAGE
L["CALENDAR_PENDING_INVITES"] = _G.GAMETIME_TOOLTIP_CALENDAR_INVITES
L["CANCEL"] = _G.CANCEL
L["CAST_ON_KEY_DOWN_DESC"] = _G.OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN
L["CHARACTER_BUTTON"] = _G.CHARACTER_BUTTON
L["CURRENCY"] = _G.CURRENCY
L["CURRENCY_COLON"] = _G.CURRENCY..":"
L["DAMAGER_RED"] = "|cffdc4436".._G.DAMAGER.."|r"
L["DEAD"] = _G.DEAD
L["DUNGEONS_BUTTON"] = _G.DUNGEONS_BUTTON
L["DURABILITY_COLON"] = _G.DURABILITY..":"
L["ENABLE"] = _G.ENABLE
L["FEATURE_BECOMES_AVAILABLE_AT_LEVEL"] = _G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL
L["FEATURE_NOT_AVAILBLE_NEUTRAL"] = _G.FEATURE_NOT_AVAILBLE_PANDAREN
L["FOREIGN_SERVER_LABEL"] = _G.FOREIGN_SERVER_LABEL:gsub("%s", "")
L["GENERAL"] = _G.GENERAL_LABEL
L["HEALER_GREEN"] = "|cff2eac34".._G.HEALER.."|r"
L["HIDE"] = _G.HIDE
L["HONOR"] = _G.HONOR
L["LFG_CALL_TO_ARMS"] = _G.LFG_CALL_TO_ARMS
L["LS_UI"] = "ls: |cff1a9fc0UI|r"
L["MAINMENU_BUTTON"] = _G.MAINMENU_BUTTON
L["MINIMAP"] = _G.MINIMAP_LABEL
L["NEWBIE_TOOLTIP_SPELLBOOK"] = _G.NEWBIE_TOOLTIP_SPELLBOOK
L["OFFLINE"] = _G.PLAYER_OFFLINE
L["PET"] = _G.PET
L["QUESTLOG_BUTTON"] = _G.QUESTLOG_BUTTON
L["RAID_INFO_COLON"] = _G.RAID_INFO..":"
L["RAID_INFO_WORLD_BOSS"] = _G.RAID_INFO_WORLD_BOSS
L["RELOADUI"] = _G.RELOADUI
L["REPUTATION"] = _G.REPUTATION
L["RETRIEVING_DATA"] = _G.RETRIEVING_DATA
L["SHOW"] = _G.SHOW
L["SHOW_AS_XP_BAR"] = _G.SHOW_FACTION_ON_MAINSCREEN
L["SPELLBOOK_ABILITIES"] = _G.SPELLBOOK_ABILITIES_BUTTON
L["TANK_BLUE"] = "|cff1798fb".._G.TANK.."|r"
L["TOGGLE_CALENDAR"] = _G.GAMETIME_TOOLTIP_TOGGLE_CALENDAR
L["TOTAL"] = _G.TOTAL
L["UNIT_FRAME"] = _G.UNITFRAME_LABEL
L["UNKNOWN"] = _G.UNKNOWN
L["XP_BAR_ARTIFACT_NUM_PURCHASED_RANKS_TOOLTIP"] = _G.ARTIFACTS_NUM_PURCHASED_RANKS:gsub("%%d", "|cffffffff%%s|r")
L["XP_BAR_LEVEL_TOOLTIP"] = _G.LEVEL..": |cffffffff%d|r"
L["COLOR_CLASS_DESC"] = (function()
	local temp = ""

	for k, class in next, _G.CLASS_SORT_ORDER do
		temp = temp..M.COLORS.CLASS[class]:WrapText(_G.LOCALIZED_CLASS_NAMES_MALE[class])

		if k ~= #_G.CLASS_SORT_ORDER then
			temp = temp.."\n"
		end
	end

	return temp
end)()
L["COLOR_REACTION_DESC"] = (function()
	local temp = ""

	for i = 1, 8 do
		temp = temp..M.COLORS.REACTION[i]:WrapText(_G["FACTION_STANDING_LABEL"..i])

		if i ~= 8 then
			temp = temp.."\n"
		end
	end

	return temp
end)()

-- Require translation
L["ACTION_BARS"] = "Action Bars"
L["ADVENTURE_JOURNAL_DESC"] = "Show raid lockout information."
L["ALWAYS_SHOW"] = "Always Show"
L["ANCHOR"] = "Attach To"
L["ASCENDING"] = "Ascending"
L["AURA_TRACKER"] = "Aura Tracker"
L["BAGS"] = "Bags"
L["BAR_1"] = "Bar 1"
L["BAR_2"] = "Bar 2"
L["BAR_3"] = "Bar 3"
L["BAR_4"] = "Bar 4"
L["BAR_5"] = "Bar 5"
L["BAR_COLOR"] = "Bar Colour"
L["BAR_TEXT"] = "Bar Text"
L["BLIZZARD"] = "Blizzard"
L["BOTTOM"] = "Bottom"
L["BUFFS"] = "Buffs"
L["CAST_ON_KEY_DOWN"] = "Cast on Key Down"
L["CHARACTER_BUTTON_DESC"] = "Show equipment durability information."
L["CLASSIC"] = "Classic"
L["CLOCK"] = "Clock"
L["COLOR_CLASS"] = "Player Class"
L["COLOR_CLASSIFICATION"] = "NPC Type"
L["COLOR_DISCONNECTED"] = "Disconnected"
L["COLOR_REACTION"] = "Reaction"
L["COLOR_TAPPED"] = "Tapped"
L["COMMAND_BAR"] = "Command Bar"
L["COPY_FROM"] = "Copy From"
L["COPY_FROM_DESC"] = "Select a unit to copy settings from."
L["DAILY_QUEST_RESET_TIME"] = "Daily Quest Reset Time: |cffffffff%s|r"
L["DEBUFFS"] = "Debuffs"
L["DESATURATE_ON_COOLDOWN"] = "Desaturate on Cooldown"
L["DESCENDING"] = "Descending"
L["DETACH_FROM_FRAME"] = "Detach From Frame"
L["DIGSITE_BAR"] = "Digsite Progress Bar"
L["DISABLE_MOUSE"] = "Disable Mouse"
L["DISABLE_MOUSE_DESC"] = "Ignore mouse events."
L["DOWN"] = "Down"
L["DRAG_KEY"] = "Drag Key"
L["DRAW_COOLDOWN_BLING"] = "Show Cooldown Bling"
L["DRAW_COOLDOWN_BLING_DESC"] = "Show the bling animation at the end of the cooldown."
L["DUNGEONS_BUTTON_DESC"] = "Show 'Call to Arms' information."
L["DURABILITY_FRAME"] = "Durability Frame"
L["ELITE"] = "Elite"
L["ENEMY_UNITS"] = "Enemy Units"
L["ENHANCED_TOOLTIPS"] = "Enhanced Tooltips"
L["ENTER_SPELL_ID"] = "Enter Spell ID"
L["EXPERIENCE"] = "Experience"
L["EXTRA_ACTION_BUTTON"] = "Extra Action Button"
L["FADE_IN_DELAY"] = "Fade In Delay"
L["FADE_IN_DURATION"] = "Fade In Duration"
L["FADE_OUT_DELAY"] = "Fade Out Delay"
L["FADE_OUT_DURATION"] = "Fade Out Duration"
L["FADING"] = "Fading"
L["FILTER"] = "Filter"
L["FILTER_SETTINGS"] = "Filter Settings"
L["FILTERS"] = "Filters"
L["FLYOUT_DIR"] = "Flyout Direction"
L["FRAME"] = "Frame"
L["FRIENDLY_UNITS"] = "Friendly Units"
L["GM_FRAME"] = "Ticket Status Frame"
L["GOLD"] = "Gold"
L["GRID"] = "Button Grid"
L["GROWTH_DIR"] = "Growth Direction"
L["HEIGHT"] = "Height"
L["HORIZ_GROWTH_DIR"] = "Horizontal Growth Direction"
L["ICON"] = "Icon"
L["INDEX"] = "Index"
L["INSPECT_INFO"] = "Inspect Info"
L["INSPECT_INFO_DESC"] = "Display player's specialisation and item level. This data is not available right away. Hold Shift to request and, if available, show this info."
L["ITEM_COUNT"] = "Item Count"
L["ITEM_COUNT_DESC"] = "Display how many of an item you have in your bags and bank."
L["KEYBIND_TEXT"] = "Keybind Text"
L["LATENCY_COLON"] = "Latency:"
L["LATENCY_HOME"] = "Home"
L["LATENCY_WORLD"] = "World"
L["LATER"] = "Later"
L["LEFT"] = "Left"
L["LEFT_DOWN"] = "Left and Down"
L["LEFT_UP"] = "Left and Up"
L["LIST_OF_COMMANDS_COLON"] = "List of Commands:"
L["LOCK"] = "Lock"
L["LOCK_BUTTONS"] = "Lock Buttons"
L["LOCK_BUTTONS_DESC"] = "Prevents you from picking up and dragging spells off the action bar."
L["MACRO_TEXT"] = "Macro Text"
L["MAIN_MICRO_BUTTON_HOLD_TEXT"] = "|cffffffffHold Shift|r to show memory usage."
L["MAINMENU_BUTTON_DESC"] = "Show performance information."
L["MAX_ALPHA"] = "Max Alpha"
L["MEMORY_COLON"] = "Memory:"
L["MICRO_BUTTONS"] = "Micro Buttons"
L["MIN_ALPHA"] = "Min Alpha"
L["MIRROR_TIMER"] = "Mirror Timers"
L["MOUSEOVER_SHOW"] = "Show on Mouseover"
L["MOVER_RESET_DESC"] = "|cffffffffShift-Click|r to reset position."
L["NAME"] = "Name"
L["NO_SEPARATION"] = "No Separation"
L["NPE_FRAME"] = "NPE Tutorial Frame"
L["NUM_BUTTONS"] = "Number of Buttons"
L["NUM_ROWS"] = "Number of Rows"
L["OBJECTIVE_TRACKER"] = "Objective Tracker"
L["OOM_INDICATOR"] = "Out-of-Mana Indicator"
L["OOR_INDICATOR"] = "Out-of-Range Indicator"
L["OPEN_CONFIG"] = "Open Config"
L["ORBS"] = "Orbs"
L["OTHER"] = "Other"
L["OTHERS_FIRST"] = "Others First"
L["PER_ROW"] = "Per Row"
L["PET_BAR"] = "Pet Bar"
L["PET_BATTLE_BAR"] = "Pet Battle Bar"
L["PLAYER_ALT_POWER_BAR"] = "Alt Power Bar"
L["PLAYER_TITLE"] = "Player Title"
L["POINT"] = "Point"
L["POINT_DESC"] = "Point of the object."
L["POSITION"] = "Position"
L["PREVIEW"] = "Preview"
L["QUESTLOG_BUTTON_DESC"] = "Show daily quest reset timer."
L["RCLICK_SELFCAST"] = "Right-Click Self-Cast"
L["RELATIVE_POINT"] = "Relative Point"
L["RELATIVE_POINT_DESC"] = "Point of the region to attach the object to."
L["RELOAD_NOW"] = "Reload Now"
L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"] = "You've just changed a setting for this character only. Character only settings aren't unaffected by the changing of profiles. For the changes to take effect, you must reload UI."
L["RELOAD_UI_WARNING"] = "Reload UI after you're done setting up the addon."
L["RESTORE_DEFAULTS"] = "Restore Defaults"
L["RESTRICTED_MODE"] = "Restricted Mode"
L["RIGHT"] = "Right"
L["RIGHT_DOWN"] = "Right and Down"
L["RIGHT_UP"] = "Right and Up"
L["ROWS"] = "Rows"
L["SECOND_ANCHOR"] = "Second Anchor"
L["SEPARATION"] = "Separation"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffShift-Click|r to Show as Experience Bar."
L["SIZE"] = "Size"
L["SIZE_OVERRIDE"] = "Size Override"
L["SIZE_OVERRIDE_DESC"] = "If set to 0, element's size will be calculated automatically."
L["SORT_DIR"] = "Sort Direction"
L["SORT_METHOD"] = "Sort Method"
L["SPACING"] = "Spacing"
L["STANCE_BAR"] = "Stance Bar"
L["TALKING_HEAD_FRAME"] = "Talking Head Frame"
L["TARGET_INFO"] = "Target Info"
L["TARGET_INFO_DESC"] = "Display unit's target."
L["TEXT_FORMAT"] = "Format"
L["TEXT_HORIZ_ALIGNMENT"] = "Horizontal Alignment"
L["TEXT_VERT_ALIGNMENT"] = "Vertical Alignment"
L["TIME"] = "Time"
L["TOGGLE_ANCHORS"] = "Toggle Anchors"
L["TOOLTIP_IDS"] = "Spell and Item IDs"
L["TOOLTIPS"] = "Tooltips"
L["TOP"] = "Top"
L["TOTEMS"] = "Totems"
L["UI_LAYOUT"] = "UI Layout"
L["UNIT_BOSS"] = "Boss"
L["UNIT_FOCUS_TOF"] = "Focus & ToF"
L["UNIT_FRAME_ALT_POWER"] = "Alternative Power"
L["UNIT_FRAME_AURAS"] = "Auras"
L["UNIT_FRAME_BORDER"] = "Border"
L["UNIT_FRAME_BORDER_COLOR"] = "Border Colour"
L["UNIT_FRAME_BOSS"] = "Boss Frames"
L["UNIT_FRAME_BOSS_BUFFS"] = "Boss Buffs"
L["UNIT_FRAME_BOSS_BUFFS_DESC"] = "Show buffs cast by the boss."
L["UNIT_FRAME_BOSS_DEBUFFS"] = "Boss Debuffs"
L["UNIT_FRAME_BOSS_DEBUFFS_DESC"] = "Show debuffs cast by the boss."
L["UNIT_FRAME_BOTTOM_INSET_SIZE"] = "Bottom Inset Size"
L["UNIT_FRAME_BOTTOM_INSET_SIZE_DESC"] = "Used by power bar."
L["UNIT_FRAME_CASTABLE_BUFFS"] = "Castable Buffs"
L["UNIT_FRAME_CASTABLE_BUFFS_DESC"] = "Show buffs cast by yourself."
L["UNIT_FRAME_CASTABLE_BUFFS_PERMA"] = "Castable Perma Buffs"
L["UNIT_FRAME_CASTABLE_BUFFS_PERMA_DESC"] = "Show permanent buffs cast by yourself."
L["UNIT_FRAME_CASTABLE_DEBUFFS"] = "Castable Debuffs"
L["UNIT_FRAME_CASTABLE_DEBUFFS_DESC"] = "Show debuffs cast by yourself."
L["UNIT_FRAME_CASTABLE_DEBUFFS_PERMA"] = "Castable Perma Debuffs"
L["UNIT_FRAME_CASTABLE_DEBUFFS_PERMA_DESC"] = "Show permanent debuffs cast by yourself."
L["UNIT_FRAME_CASTBAR"] = "Castbar"
L["UNIT_FRAME_CASTBAR_ICON"] = "Icon"
L["UNIT_FRAME_CASTBAR_LATENCY"] = "Latency"
L["UNIT_FRAME_CASTBAR_PVP_ICON"] = "PvP Icon"
L["UNIT_FRAME_CLASS_POWER"] = "Class Power"
L["UNIT_FRAME_COST_PREDICTION"] = "Cost Prediction"
L["UNIT_FRAME_COST_PREDICTION_DESC"] = "Show a bar that represents power cost of a spell that's being casted. Does not work for instant-cast abilities."
L["UNIT_FRAME_DAMAGE_ABSORB_TEXT"] = "Damage Absorb Text"
L["UNIT_FRAME_DISPELLABLE_BUFFS"] = "Dispellable Buffs"
L["UNIT_FRAME_DISPELLABLE_BUFFS_TOOLTIP"] = "Show buffs you can spellsteal or purge from your target."
L["UNIT_FRAME_DISPELLABLE_DEBUFF_ICONS"] = "Dispellable Debuff Icons"
L["UNIT_FRAME_DISPELLABLE_DEBUFFS"] = "Dispellable Debuffs"
L["UNIT_FRAME_DISPELLABLE_DEBUFFS_TOOLTIP"] = "Show debuffs you can dispel from your target."
L["UNIT_FRAME_FCF"] = "Floating Combat Feedback"
L["UNIT_FRAME_FCF_MODE"] = "Mode"
L["UNIT_FRAME_FOCUS"] = "Focus Frame"
L["UNIT_FRAME_HEAL_ABSORB_TEXT"] = "Heal Absorb Text"
L["UNIT_FRAME_HEAL_PREDICTION"] = "Heal Prediction"
L["UNIT_FRAME_HEALTH"] = "Health"
L["UNIT_FRAME_HEALTH_TEXT"] = "Health Text"
L["UNIT_FRAME_MOUNT_AURAS"] = "Mount Auras"
L["UNIT_FRAME_MOUNT_AURAS_DESC"] = "Show mount auras."
L["UNIT_FRAME_NAME"] = "Name"
L["UNIT_FRAME_PET"] = "Pet Frame"
L["UNIT_FRAME_PLAYER"] = "Player Frame"
L["UNIT_FRAME_POWER"] = "Power"
L["UNIT_FRAME_POWER_TEXT"] = "Power Text"
L["UNIT_FRAME_RAID_ICON"] = "Raid Icon"
L["UNIT_FRAME_SELF_BUFFS"] = "Self Buffs"
L["UNIT_FRAME_SELF_BUFFS_DESC"] = "Show buffs cast by oneself."
L["UNIT_FRAME_SELF_BUFFS_PERMA"] = "Perma Self Buffs"
L["UNIT_FRAME_SELF_BUFFS_PERMA_DESC"] = "Show permanent buffs cast by oneself."
L["UNIT_FRAME_SELF_DEBUFFS"] = "Self Debuffs"
L["UNIT_FRAME_SELF_DEBUFFS_DESC"] = "Show debuffs cast by oneself."
L["UNIT_FRAME_SELF_DEBUFFS_PERMA"] = "Perma Self Debuffs"
L["UNIT_FRAME_SELF_DEBUFFS_PERMA_DESC"] = "Show permanent debuffs cast by oneself."
L["UNIT_FRAME_TARGET"] = "Target Frame"
L["UNIT_FRAME_THREAT_GLOW"] = "Threat Glow"
L["UNIT_FRAME_TOF"] = "Target of Focus Frame"
L["UNIT_FRAME_TOP_INSET_SIZE"] = "Top Inset Size"
L["UNIT_FRAME_TOP_INSET_SIZE_DESC"] = "Used by class, alternative and additional power bars."
L["UNIT_FRAME_TOT"] = "Target of Target Frame"
L["UNIT_PLAYER_PET"] = "Player & Pet"
L["UNIT_TARGET_TOT"] = "Target & ToT"
L["UNITS"] = "Units"
L["UP"] = "Up"
L["USE_BLIZZARD_VEHICLE_UI"] = "Use Blizzard Vehicle UI"
L["USE_ICON_AS_INDICATOR"] = "Use Icon as Indicator"
L["USE_ICON_AS_INDICATOR_DESC"] = "Icon's colour and transparency will change according to ability's state."
L["VEHICLE_EXIT_BUTTON"] = "Vehicle Exit Button"
L["VEHICLE_SEAT_INDICATOR"] = "Vehicle Seat Indicator"
L["VERT_GROWTH_DIR"] = "Vertical Growth Direction"
L["VISIBILITY"] = "Visibility"
L["WIDTH"] = "Width"
L["WIDTH_OVERRIDE"] = "Width Override"
L["WORD_WRAP"] = "Word Wrap"
L["X_OFFSET"] = "xOffset"
L["XP_BAR"] = "XP Bar"
L["XP_BAR_ARTIFACT_NUM_UNSPENT_TRAIT_POINTS_TOOLTIP"] = "Unspent Trait Points: |cffffffff%s|r"
L["XP_BAR_HONOR_BONUS_TOOLTIP"] = "Bonus Honor: |cffffffff%s|r"
L["XP_BAR_HONOR_TOOLTIP"] = "Honor Level: |cffffffff%d|r"
L["XP_BAR_PRESTIGE_LEVEL_TOOLTIP"] = "Prestige Level: |cffffffff%s|r"
L["XP_BAR_XP_BONUS_TOOLTIP"] = "Bonus XP: |cffffffff%s|r"
L["Y_OFFSET"] = "yOffset"
L["YOURS_FIRST"] = "Yours First"
L["ZONE_ABILITY_BUTTON"] = "Zone Ability Button"
L["ZONE_TEXT"] = "Zone Text"

-- Multi-lines
L["ALT_POWER_TEXT_FORMAT_DESC"] = [[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:altpower:cur]|r - current value;
- |cffffd200[ls:altpower:max]|r - maximum value;
- |cffffd200[ls:altpower:perc]|r - percentage;
- |cffffd200[ls:altpower:cur-max]|r - current value followed by maximum value, will display only current value if it's equal to max;
- |cffffd200[ls:altpower:cur-color-max]|r - current value followed by coloured maximum value, will display only coloured current value if it's equal to max;
- |cffffd200[ls:altpower:cur-perc]|r - current value followed by percentage, will display only current value if it's equal to max;
- |cffffd200[ls:altpower:cur-color-perc]|r - current value followed by coloured percentage, will display only coloured current value if it's equal to max;
- |cffffd200[ls:color:altpower]|r - colour.

Use '||r' to terminate colour tags.
]]
L["DAMAGE_ABSORB_TEXT_FORMAT_DESC"] = [[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:absorb:damage]|r - current value;
- |cffffd200[ls:color:absorb-damage]|r - colour.

Use '||r' to terminate colour tags.
]]
L["HEAL_ABSORB_TEXT_FORMAT_DESC"] = [[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:absorb:heal]|r - current value;
- |cffffd200[ls:color:absorb-heal]|r - colour.

Use '||r' to terminate colour tags.
]]
L["HEALTH_TEXT_FORMAT_DESC"] = [[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:health:cur]|r - current value;
- |cffffd200[ls:health:perc]|r - percentage;
- |cffffd200[ls:health:cur-perc]|r - current value followed by percentage, will display only current value if it's equal to max;
- |cffffd200[ls:health:deficit]|r - deficit value.
]]
L["NAME_TEXT_FORMAT_DESC"] = [[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:name]|r - full name;
- |cffffd200[ls:name:5]|r - name shortened to 5 characters;
- |cffffd200[ls:name:10]|r - name shortened to 10 characters;
- |cffffd200[ls:name:15]|r - name shortened to 15 characters;
- |cffffd200[ls:name:20]|r - name shortened to 20 characters;
- |cffffd200[ls:server]|r - (*) sever tag for players from foreign realms;
- |cffffd200[ls:color:class]|r - difficulty colour;
- |cffffd200[ls:color:reaction]|r - reaction colour;
- |cffffd200[ls:color:difficulty]|r - difficulty colour.

Use '||r' to terminate colour tags.
]]
L["POWER_TEXT_FORMAT_DESC"] = [[Provide a string to change the text. To disable, leave the field blank.

Tags:
- |cffffd200[ls:power:cur]|r - current value;
- |cffffd200[ls:power:max]|r - maximum value;
- |cffffd200[ls:power:perc]|r - percentage;
- |cffffd200[ls:power:cur-max]|r - current value followed by maximum value, will display only current value if it's equal to max;
- |cffffd200[ls:power:cur-color-max]|r - current value followed by coloured maximum value, will display only coloured current value if it's equal to max;
- |cffffd200[ls:power:cur-perc]|r - current value followed by percentage, will display only current value if it's equal to max;
- |cffffd200[ls:power:cur-color-perc]|r - current value followed by coloured percentage, will display only coloured current value if it's equal to max;
- |cffffd200[ls:power:deficit]|r - deficit value;
- |cffffd200[ls:color:power]|r - colour.

Use '||r' to terminate colour tags.
]]
L["RESTRICTED_MODE_DESC"] = [[Enables artwork, animations and dynamic resizing for main action bar.

|cffdc4436You WILL NOT be able to move micro menu, bags and main action bar in this mode!|r]]
L["UI_LAYOUT_DESC"] = [[Orbs: Player frame is an orb, pet and player frames use vertical bars, player frame and minimap are in the bottom section of the screen.

Classic: All unit frames are rectangular and use horizontal bars, minimap is in the top right corner.]]

-- These rely on custom strings
L["COLOR_CLASSIFICATION_DESC"] = (function()
	return M.COLORS.YELLOW:WrapText(L["ELITE"]).."\n"..M.COLORS.WHITE:WrapText(L["OTHER"])
end)()
