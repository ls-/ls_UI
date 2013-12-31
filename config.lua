local _, ns = ...

ns.C = {}

ns.C.units = {
	player = {
		point = { "BOTTOM", "UIParent", "BOTTOM", -306 , 80 },
	},
	pet = {
		point = {"RIGHT", "oUF_LSPlayerFrame" , "LEFT"},
	},
	target = {
		point = {"BOTTOMLEFT", "UIParent", "BOTTOM", 166, 336},
		long = true,
	},
	targettarget = {
		point = { "LEFT", "oUF_LSTargetFrame", "RIGHT", 14, 0 },
	},
	focus = {
		point = { "BOTTOMRIGHT", "UIParent", "BOTTOM", -166, 336},
		long = true,
	},
	focustarget = {
		point = { "RIGHT", "oUF_LSFocusFrame", "LEFT", -14, 0 },
	},
	party = {
		point = {"TOPLEFT", "CompactRaidFrameManager", "TOPRIGHT", 6, 0},
		attributes = {"showPlayer", true, "showParty", true, "showRaid", false, "point", "BOTTOM", "yOffset", 40},
		visibility = "party",
	},
	boss1 = {
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -84, -240},
	},	
	boss2 = {
		point = {"TOP", "oUF_LSBoss1Frame", "BOTTOM", 0, -46},
	},
	boss3 = {
		point = {"TOP", "oUF_LSBoss2Frame", "BOTTOM", 0, -46},
	},
	boss4 = {
		point = {"TOP", "oUF_LSBoss3Frame", "BOTTOM", 0, -46},
	},
	boss5 = {
		point = {"TOP", "oUF_LSBoss4Frame", "BOTTOM", 0, -46},
	},
}

ns.C.minimap = {
	[1] = {"Minimap", "BOTTOM", "UIParent", "BOTTOM", 306, 80},
	[2] = {"MiniMapTracking", "CENTER", "Minimap",	"CENTER", 72, 30},
	[3] = {"GameTimeFrame", "CENTER",	"Minimap", "CENTER", 55, 55},
	[4] = {"MiniMapInstanceDifficulty", "BOTTOM", "Minimap", "BOTTOM", -1, -38},
	[5] = {"GuildInstanceDifficulty", "BOTTOM", "Minimap", "BOTTOM", -6, -38},
	[6] = {"QueueStatusMinimapButton", "CENTER", "Minimap", "CENTER", 55, -55},
}

ns.C.width, ns.C.height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")

ns.C.playerclass = select(2, UnitClass("player"))
