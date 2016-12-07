local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = _G
-- local string = _G.string

-- Mine
L["LS_UI"] = "|cff1a9fc0ls:|r UI"
L["DONE"] = _G.DONE
L["ENABLE"] = _G.ENABLE
L["INFO"] = _G.INFO
L["LOCK_FRAME"] = _G.LOCK_FRAME
L["RELOADUI"] = _G.RELOADUI
L["REQUIRES_RELOAD"] = "|cffff0000".._G.REQUIRES_RELOAD.."|r"

L["AURA_TRACKER"] = "Aura Tracker"
L["BUFFS"] = "Buffs"
L["DEBUFFS"] = "Debuffs"
L["ICON_GREEN_INLINE"] = "|TInterface\\COMMON\\Indicator-Green:0|t"
L["ICON_RED_INLINE"] = "|TInterface\\COMMON\\Indicator-Yellow:0|t"
L["ICON_YELLOW_INLINE"] = "|TInterface\\COMMON\\Indicator-Red:0|t"
L["MODULES"] = "Modules"
L["SETTINGS_AURA_TRACKER_DESC"] = "These options allow you to setup player's aura tracking."
L["SETTINGS_GENERAL_DESC"] = "Yet another UI, but this one is a bit special..."
L["TOGGLE_ANCHORS"] = "Toggle Anchors"
L["BUTTON_ANCHOR_POINT"] = "Button Anchor Point"
L["BUTTON_SIZE"] = "Button Size"
L["BUTTON_SPACING"] = "Button Spacing"
L["BUTTONS_PER_ROW"] = "Buttons Per Row"
L["MASK_COLON"] = "Mask:"

-- Config log messages
L["LOG_DONE"] = L["ICON_GREEN_INLINE"].." ".._G.DONE.."."
L["LOG_ITEM_ADDED_ERR"] = L["ICON_RED_INLINE"].."'%s' is already in the list."
L["LOG_ITEM_ADDED"] = L["ICON_GREEN_INLINE"].."'%s' has been added to the list."
L["LOG_MODULE_DISABLED"] = "%s'%s' module has been disabled. %s"
L["LOG_MODULE_DISABLED_ERR"] = L["ICON_RED_INLINE"].."'%s' module is already disabled."
L["LOG_MODULE_ENABLED"] = "%s'%s' module has been enabled. %s"
L["LOG_MODULE_ENABLED_ERR"] = L["ICON_RED_INLINE"].."'%s' module is already enabled."
L["LOG_NOTHING_FOUND"] = L["ICON_RED_INLINE"].."Nothing found."
L["LOG_FOUND_ITEM"] = L["ICON_GREEN_INLINE"].."Found: '%s'."
