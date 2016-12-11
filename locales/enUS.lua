local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = _G
local next = _G.next

-- Mine
L["ACTION_BAR"] = _G.ACTIONBAR_LABEL
L["AURAS"] = _G.AURAS
L["ENABLE"] = _G.ENABLE
L["FRAME_HEIGHT"] = _G.COMPACT_UNIT_FRAME_PROFILE_FRAMEHEIGHT
L["ICON_GREEN_INLINE"] = "|TInterface\\COMMON\\Indicator-Green:0|t"
L["ICON_RED_INLINE"] = "|TInterface\\COMMON\\Indicator-Red:0|t"
L["ICON_YELLOW_INLINE"] = "|TInterface\\COMMON\\Indicator-Yellow:0|t"
L["INFO"] = _G.INFO
L["LOCK_FRAME"] = _G.LOCK_FRAME
L["MAIL"] = _G.MAIL_LABEL
L["MINIMAP"] = _G.MINIMAP_LABEL
L["MISC"] = _G.MISCELLANEOUS
L["RELOADUI"] = _G.RELOADUI
L["REQUIRES_RELOAD"] = "|cffdc4436".._G.REQUIRES_RELOAD..".|r" -- M.COLORS.RED
L["UNIT_FRAME"] = _G.UNITFRAME_LABEL
L["UNIT_FRAME_CASTBAR"] = _G.SHOW_ARENA_ENEMY_CASTBAR_TEXT
L["TOOLTIP_UNIT_NAME_COLOR_CLASS_TOOLTIP"] = (function()
	local temp = ""

	for k, v in next, _G.CLASS_SORT_ORDER do
		temp = temp.."|cff"..M.COLORS.CLASS[v]:GetHEX().._G.LOCALIZED_CLASS_NAMES_MALE[v].."|r"

		if next(_G.CLASS_SORT_ORDER, k) then
			temp = temp.."\n"
		end
	end

	return temp
end)()
L["TOOLTIP_UNIT_NAME_COLOR_REACTION_TOOLTIP"] = (function()
	local temp = ""

	for i = 1, 8 do
		temp = temp.."|cff"..M.COLORS.REACTION[i]:GetHEX().._G["FACTION_STANDING_LABEL"..i].."|r"

		if i ~= 8 then
			temp = temp.."\n"
		end
	end

	return temp
end)()

L["ACTION_BAR_1"] = "Main Action Bar"
L["ACTION_BAR_1_SHORT"] = "Main"
L["ACTION_BAR_2"] = "Action Bar 1"
L["ACTION_BAR_2_SHORT"] = "Bar 1"
L["ACTION_BAR_3"] = "Action Bar 2"
L["ACTION_BAR_3_SHORT"] = "Bar 2"
L["ACTION_BAR_4"] = "Action Bar 3"
L["ACTION_BAR_4_SHORT"] = "Bar 3"
L["ACTION_BAR_5"] = "Action Bar 4"
L["ACTION_BAR_5_SHORT"] = "Bar 4"
L["ACTION_BAR_DESC"] = "Action bars, bags and stuff."
L["ACTION_BAR_INFO_TOOLTIP"] ="To enable or disable additional action bars, please, see |cff1a9fc0ls:|r UI config.\n\n|cffdc4436Clicking this button will bring you there.|r" -- M.COLORS.RED
L["ACTION_BAR_RESTRICTED_MODE"] = "Restricted Mode"
L["ACTION_BAR_RESTRICTED_MODE_TOOLTIP"] = "Enables artwork, animations and dynamic resizing for main action bar.\n\n|cffdc4436You WILL NOT be able to move micro menu, bags and main action bar!|r" -- M.COLORS.RED
L["AURA_TRACKER"] = "Aura Tracker"
L["AURA_TRACKER_DESC"] = "These options allow you to setup player's aura tracking."
L["BAGS"] = "Bags"
L["BARS"] = "Bars"
L["BLIZZARD"] = "Blizzard"
L["BLIZZARD_COMMAND_BAR"] = "Command Bar"
L["BLIZZARD_DESC"] = "These settings allow you to enable or disable tweaks for various elements of default UI."
L["BLIZZARD_DIGSITE_BAR"] = "Digsite Progress Bar"
L["BLIZZARD_DURABILITY_FRAME"] = "Durability Frame"
L["BLIZZARD_GM_FRAME"] = "Ticket Status Frame"
L["BLIZZARD_MIRROR_TIMER"] = "Mirror Timers"
L["BLIZZARD_MISC_DESC"] = "Some of these settings reskin default widgets, others add 'movers', etc."
L["BLIZZARD_NPE_FRAME"] = "NPE Tutorial Frame"
L["BLIZZARD_OBJECTIVE_TRACKER"] = "Objective Tracker"
L["BLIZZARD_OBJECTIVE_TRACKER_DESC"] = "By enabling this tweak, you'll be able to move objective tracker and change its height.\n|cffffd200If you use other addons that alter tracker's behaviour, disable this tweak!|r"
L["BLIZZARD_PLAYER_ALT_POWER_BAR"] = "Player Alt Power Bar"
L["BLIZZARD_TALKING_HEAD_FRAME"] = "Talking Head Frame"
L["BLIZZARD_VEHICLE_SEAT_INDICATOR"] = "Vehicle Seat Indicator"
L["BUFFS"] = "Buffs"
L["BUTTON_ANCHOR_POINT"] = "Button Anchor Point"
L["BUTTON_SIZE"] = "Button Size"
L["BUTTON_SPACING"] = "Button Spacing"
L["BUTTONS"] = "Buttons"
L["BUTTONS_PER_ROW"] = "Buttons Per Row"
L["DEBUFFS"] = "Debuffs"
L["ENABLE_BAGS"] = "Enable Bags"
L["KEY_BINDING_TEXT"] = "Binding Text"
L["LOG_DISABLED"] = "%s'%s' has been disabled. %s"
L["LOG_DISABLED_ERR"] = L["ICON_RED_INLINE"].."'%s' is already disabled."
L["LOG_ENABLED"] = "%s'%s' has been enabled. %s"
L["LOG_ENABLED_ERR"] = L["ICON_RED_INLINE"].."'%s' is already enabled."
L["LOG_FOUND_ITEM"] = L["ICON_GREEN_INLINE"].."Found: '%s'."
L["LOG_ITEM_ADDED"] = L["ICON_GREEN_INLINE"].."'%s' has been added to the list."
L["LOG_ITEM_ADDED_ERR"] = L["ICON_RED_INLINE"].."'%s' is already in the list."
L["LOG_NOTHING_FOUND"] = L["ICON_RED_INLINE"].."Nothing found."
L["LS_UI"] = "|cff1a9fc0ls:|r UI"
L["LS_UI_DESC"] = "Yet another UI, but this one is a bit special...\nI strongly recommend to |cffe52626/reload|r UI after you're done setting up the addon. Even if you opened and closed this panel without changing anything, |cffe52626/reload|r UI. |cffffd200By doing so, you'll remove this config entry from the system and prevent possible taints.|r"
L["MACRO_TEXT"] = "Macro Text"
L["MASK_COLON"] = "Mask:"
L["MODULES"] = "Modules"
L["PET_BAR"] = "Pet Action Bar"
L["PET_BAR_SHORT"] = "Pet"
L["STANCE_BAR"] = "Stance Bar"
L["STANCE_BAR_SHORT"] = "Stance"
L["TOGGLE_ANCHORS"] = "Toggle Anchors"
L["TOOLTIP"] = "Tooltips"
L["TOOLTIP_DESC"] = "Tooltips, spell and item IDs, etc."
L["TOOLTIP_SHOW_ID"] = "Show IDs"
L["TOOLTIP_UNIT_NAME_COLOR"] = "Unit Name Colouring"
L["TOOLTIP_UNIT_NAME_COLOR_CLASS"] = "Class (Player Only)"
L["TOOLTIP_UNIT_NAME_COLOR_DESC"] = "These options allow you to change flags that are used to resolve unit's name colour. |cffffd200They are listed in order of priority.|r"
L["TOOLTIP_UNIT_NAME_COLOR_PVP"] = "PvP Hostility (Player Only)"
L["TOOLTIP_UNIT_NAME_COLOR_PVP_TOOLTIP"] = "|cffdc4436Can attack you\n|cffffb73cCan be attacked\n|cff2eac34Friendly\n|cff1798fbCan't be attacked|r" -- M.COLORS.RED, M.COLORS.YELLOW, M.COLORS.GREEN, M.COLORS.BLUE
L["TOOLTIP_UNIT_NAME_COLOR_REACTION"] = "Reaction"
L["TOOLTIP_UNIT_NAME_COLOR_TAP"] = "Tapping (NPC Only)"
L["TOOLTIP_UNIT_NAME_COLOR_TAP_TOOLTIP"] = "|cff888987Tapped|r"
L["UNIT_FRAME_BOSS"] = "Boss"
L["UNIT_FRAME_DESC"] = "These settings allow you to enable or disable unit frames.\n|cffffd200This section is unfinished. I'm planning to revamp unit frames in the future, thus I don't want to do same job twice.|r"
L["UNIT_FRAME_FOCUS"] = "Focus"
L["UNIT_FRAME_FOCUS_TOF"] = "Focus & ToF"
L["UNIT_FRAME_PLAYER"] = "Player"
L["UNIT_FRAME_PLAYER_PET"] = "Player & Pet"
L["UNIT_FRAME_TARGET"] = "Target"
L["UNIT_FRAME_TARGET_TOT"] = "Target & ToT"
L["UNITS"] = "Units"
