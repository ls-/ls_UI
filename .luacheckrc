std = "none"
max_line_length = false
self = false

exclude_files = {
	".luacheckrc",
	"ls_UI/embeds/",
}

ignore = {
	"111/SLASH_.*", -- Setting an undefined global variable starting with SLASH_
	"111/LS.*", -- Setting an undefined global variable starting with SLASH_
	"112/LS.*", -- Mutating an undefined global variable starting with LS
	"112/ls_UI", -- Mutating an undefined global variable ls_UI
	"113/LS.*", -- Accessing an undefined global variable starting with LS
	"113/ls_UI", -- Accessing an undefined global variable ls_UI
	"122", -- Setting a read-only field of a global variable
	"211/_G", -- Unused local variable _G
	"211/PrC",  -- Unused local variable C
	"211/C",  -- Unused local variable C
	"211/PrD",  -- Unused local variable D
	"211/D",  -- Unused local variable D
	"211/E",  -- Unused local variable E
	"211/L",  -- Unused local variable L
	"211/M",  -- Unused local variable M
	"211/P",  -- Unused local variable P
	"211/oUF",  -- Unused local variable oUF
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
	"AdiButtonAuras",
	"LibStub",
	"MaxDps",
	"MinimapButtonFrame",

	-- API functions
	"BreakUpLargeNumbers",
	"CreateFrame",
	"DeleteInboxItem",
	"GetAverageItemLevel",
	"GetCursorPosition",
	"GetDetailedItemLevelInfo",
	"GetFriendshipReputation",
	"GetGameTime",
	"GetInboxHeaderInfo",
	"GetInboxNumItems",
	"GetInventoryItemLink",
	"GetInventoryItemTexture",
	"GetItemInfo",
	"GetItemInfoInstant",
	"GetMinimapZoneText",
	"GetNetStats",
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
	"UnitIsPossessed",
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
	"C_Mail",
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
	"CastingBarFrame_OnEvent",
	"CastingBarFrame_SetFailedCastColor",
	"CastingBarFrame_SetFinishedCastColor",
	"CastingBarFrame_SetNonInterruptibleCastColor",
	"CastingBarFrame_SetStartCastColor",
	"CastingBarFrame_SetStartChannelColor",
	"CastingBarFrame_SetUnit",
	"CastingBarFrame_SetUseStartColorForFinished",
	"HideUIPanel",
	"IsPlayerAtEffectiveMaxLevel",
	"IsWatchingHonorAsXP",
	"Minimap_ZoomIn",
	"Minimap_ZoomOut",
	"MiniMapTracking_OnMouseDown",
	"Mixin",
	"RegisterStateDriver",
	"SetWatchingHonorAsXP",
	"TalkingHeadFrame_CloseImmediately",
	"UIDropDownMenu_GetCurrentDropDown",
	"UnitFrame_OnEnter",
	"UnitFrame_OnLeave",

	-- FrameXML objects
	"AlertFrame",
	"ArcheologyDigsiteProgressBar",
	"CalendarFrame",
	"CastingBarFrame",
	"CharacterBackSlot",
	"CharacterChestSlot",
	"CharacterFeetSlot",
	"CharacterFinger0Slot",
	"CharacterFinger1Slot",
	"CharacterFrame",
	"CharacterHandsSlot",
	"CharacterHeadSlot",
	"CharacterLegsSlot",
	"CharacterMainHandSlot",
	"CharacterModelFrame",
	"CharacterNeckSlot",
	"CharacterSecondaryHandSlot",
	"CharacterShirtSlot",
	"CharacterShoulderSlot",
	"CharacterStatsPane",
	"CharacterTabardSlot",
	"CharacterTrinket0Slot",
	"CharacterTrinket1Slot",
	"CharacterWaistSlot",
	"CharacterWristSlot",
	"DropDownList1",
	"DurabilityFrame",
	"GameFontNormal",
	"GameTimeFrame",
	"GameTooltip",
	"GarrisonLandingPageMinimapButton",
	"GuildInstanceDifficulty",
	"HybridMinimap",
	"InboxFrame",
	"MailFrameInset",
	"MawBuffsBelowMinimapFrame",
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
	"ObjectiveTrackerFrame",
	"OrderHallCommandBar",
	"PaperDollEquipmentManagerPane",
	"PaperDollInnerBorderBottom",
	"PaperDollInnerBorderBottom2",
	"PaperDollInnerBorderBottomLeft",
	"PaperDollInnerBorderBottomRight",
	"PaperDollInnerBorderLeft",
	"PaperDollInnerBorderRight",
	"PaperDollInnerBorderTop",
	"PaperDollInnerBorderTopLeft",
	"PaperDollInnerBorderTopRight",
	"PaperDollTitlesPane",
	"PetCastingBarFrame",
	"PlayerPowerBarAlt",
	"PVPQueueFrame",
	"QueueStatusFrame",
	"QueueStatusMinimapButton",
	"ReputationDetailMainScreenCheckBox",
	"SpellFlyout",
	"TalkingHeadFrame",
	"TicketStatusFrame",
	"TimeManagerClockButton",
	"TimerTracker",
	"UIParent",
	"VehicleSeatIndicator",

	-- FrameXML vars
	"ChatTypeInfo",
	"CLOSE",
	"DEFAULT_CHAT_FRAME",
	"FACTION_STANDING_LABEL1",
	"FACTION_STANDING_LABEL2",
	"FACTION_STANDING_LABEL3",
	"FACTION_STANDING_LABEL4",
	"FACTION_STANDING_LABEL5",
	"FACTION_STANDING_LABEL6",
	"FACTION_STANDING_LABEL7",
	"FACTION_STANDING_LABEL8",
	"ITEM_QUALITY_COLORS",
	"LE_BATTLE_PET_ALLY",
	"MAX_REPUTATION_REACTION",
	"MIRRORTIMER_NUMTIMERS",
	"TIMER_MINUTES_DISPLAY",
	"UIPARENT_ALTERNATE_FRAME_POSITIONS",
	"UIPARENT_MANAGED_FRAME_POSITIONS",
	"WOW_TOKEN_ITEM_ID",
}
