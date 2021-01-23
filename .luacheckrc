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
	"211/P",  -- Unused local variable "P"
}

globals = {
	"getfenv",
}

read_globals = {
	-- AddOns
	"LibStub",

	-- API functions
	"CreateFrame",
	"UnitIsFriend",
	"UnitIsUnit",

	-- FrameXML functions
	"Mixin",

	-- FrameXML frames
	"GameTooltip",

	-- FrameXML Constants
}
