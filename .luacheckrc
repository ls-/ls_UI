std = "none"
max_line_length = false
self = false

exclude_files = {
	".luacheckrc",
	"embeds/",
}

ignore = {
	"111/SLASH_.*", -- Setting an undefined global variable starting with SLASH_
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
	"BreakUpLargeNumbers",
	"CreateFrame",
	"GetCursorPosition",
	"GetFriendshipReputation",
	"GetGameTime",
	"GetItemInfo",
	"GetItemInfoInstant",
	"GetMinimapZoneText",
	"GetQuestLogCompletionText",
	"GetSelectedFaction",
	"GetText",
	"GetWatchedFactionInfo",
	"GetXPExhaustion",
	"GetZonePVPInfo",
	"HasArtifactEquipped",
	"InCombatLockdown",
	"IsAddOnLoaded",
	"IsAltKeyDown",
	"IsControlKeyDown",
	"IsInActiveWorldPVP",
	"IsShiftKeyDown",
	"IsXPUserDisabled",
	"LoadAddOn",
	"PlaySound",
	"RegisterUnitWatch",
	"ReloadUI",
	"SetWatchedFactionIndex",
	"UnitClass",
	"UnitClassification",
	"UnitExists",
	"UnitFactionGroup",
	"UnitGUID",
	"UnitHasVehicleUI",
	"UnitHonor",
	"UnitHonorLevel",
	"UnitHonorMax",
	"UnitIsFriend",
	"UnitIsMercenary",
	"UnitIsPlayer",
	"UnitIsPVP",
	"UnitIsPVPFreeForAll",
	"UnitIsUnit",
	"UnitLevel",
	"UnitReaction",
	"UnitSex",
	"UnitXP",
	"UnitXPMax",
	"UnregisterUnitWatch",

	-- Namespaces
	"C_ArtifactUI",
	"C_AzeriteItem",
	"C_Calendar",
	"C_DateAndTime",
	"C_MountJournal",
	"C_PetBattles",
	"C_PvP",
	"C_QuestLog",
	"C_Reputation",
	"C_Timer",
	"C_WowTokenPublic",
	"Enum",

	-- FrameXML functions
	"ArtifactBarGetNumArtifactTraitsPurchasableFromXP",
	"CastingBarFrame_SetUnit",
	"IsPlayerAtEffectiveMaxLevel",
	"IsWatchingHonorAsXP",
	"Minimap_ZoomIn",
	"Minimap_ZoomOut",
	"MiniMapTracking_OnMouseDown",
	"Mixin",
	"RegisterStateDriver",
	"SetWatchingHonorAsXP",
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
	"PVPQueueFrame",
	"QueueStatusFrame",
	"QueueStatusMinimapButton",
	"ReputationDetailMainScreenCheckBox",
	"SpellFlyout",
	"TimeManagerClockButton",
	"UIParent",

	-- FrameXML vars
	"ChatTypeInfo",
	"DEFAULT_CHAT_FRAME",
	"ITEM_QUALITY_COLORS",
	"LE_BATTLE_PET_ALLY",
	"MAX_REPUTATION_REACTION",
	"WOW_TOKEN_ITEM_ID",
}
