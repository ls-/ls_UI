std = "none"
max_line_length = false
self = false

exclude_files = {
	".luacheckrc",
	"embeds/",
}

ignore = {
	"211/_G", -- Unused local variable "_G"
	"211/C",  -- Unused local variable "C"
	"211/D",  -- Unused local variable "D"
	"211/E",  -- Unused local variable "E"
	"211/L",  -- Unused local variable "L"
	"211/M",  -- Unused local variable "M"
	"211/P",  -- Unused local variable "P"
}

globals = {
	"getfenv",
	"print",
}

read_globals = {
	-- AddOns
	"LibStub",

	-- API functions
	"CreateFrame",
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
	"C_MountJournal",
	"C_PvP",

	-- FrameXML functions
	"CastingBarFrame_SetUnit",
	"Mixin",
	"UnitFrame_OnEnter",
	"UnitFrame_OnLeave",

	-- FrameXML objects
	"CastingBarFrame",
	"GameFontNormal",
	"GameTooltip",
	"PetCastingBarFrame",

	-- FrameXML constants
}
