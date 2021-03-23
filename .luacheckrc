std = "none"
max_line_length = false
self = false

exclude_files = {
	".luacheckrc",
	"embeds/",
}

ignore = {
	"112/LS.*", -- Mutating an undefined global variable starting with LS
	"113/LS.*", -- Accessing an undefined global variable starting with LS
	"122", -- Setting a read-only field of a global variable
	"211/_G", -- Unused local variable _G
	"211/C",  -- Unused local variable C
	"211/D",  -- Unused local variable D
	"211/E",  -- Unused local variable E
	"211/L",  -- Unused local variable L
	"211/M",  -- Unused local variable M
	"211/P",  -- Unused local variable P
	"432", -- Shadowing an upvalue argument
}

globals = {
	-- Lua
	"getfenv",
	"print",

	-- AddOns
	"GetMinimapShape",

	-- FrameXML
	"SlashCmdList",
}

read_globals = {
	-- AddOns
	"LibStub",

	-- API functions
	"CreateFrame",
	"GetCursorPosition",
	"GetGameTime",
	"GetItemInfo",
	"GetMinimapZoneText",
	"GetZonePVPInfo",
	"IsAddOnLoaded",
	"LoadAddOn",
	"RegisterUnitWatch",
	"UnitClass",
	"UnitClassification",
	"UnitFactionGroup",
	"UnitGUID",
	"UnitHasVehicleUI",
	"UnitHonorLevel",
	"UnitIsFriend",
	"UnitIsMercenary",
	"UnitIsPlayer",
	"UnitIsPVP",
	"UnitIsPVPFreeForAll",
	"UnitIsUnit",
	"UnitReaction",
	"UnregisterUnitWatch",

	-- Namespaces
	"C_Calendar",
	"C_DateAndTime",
	"C_MountJournal",
	"C_PvP",
	"C_Timer",
	"C_WowTokenPublic",

	-- FrameXML functions
	"CastingBarFrame_SetUnit",
	"Minimap_ZoomIn",
	"Minimap_ZoomOut",
	"MiniMapTracking_OnMouseDown",
	"RegisterStateDriver",
	"UIDropDownMenu_GetCurrentDropDown",
	"UnitFrame_OnEnter",
	"UnitFrame_OnLeave",

	-- FrameXML objects
	"CalendarFrame",
	"CastingBarFrame",
	"DropDownList1",
	"GameFontNormal",
	"GameTimeFrame",
	"GameTooltip",
	"GarrisonLandingPageMinimapButton",
	"GuildInstanceDifficulty",
	"HybridMinimap",
	"Minimap",
	"MiniMapChallengeMode",
	"MinimapCompassTexture",
	"MiniMapInstanceDifficulty",
	"MiniMapMailFrame",
	"MiniMapTracking",
	"MiniMapTrackingBackground",
	"MiniMapTrackingButton",
	"MiniMapTrackingDropDown",
	"MiniMapTrackingIcon",
	"MinimapZoneText",
	"MinimapZoneTextButton",
	"PetCastingBarFrame",
	"QueueStatusFrame",
	"QueueStatusMinimapButton",
	"TimeManagerClockButton",
	"UIParent",

	-- FrameXML vars
	"ChatTypeInfo",
	"DEFAULT_CHAT_FRAME",
	"ITEM_QUALITY_COLORS",
	"WOW_TOKEN_ITEM_ID",
}
