local _, ns = ...
local D = ns.D

D["units"] = {
	enabled =  true,
	player = {
		enabled = true,
		point = {"BOTTOM", "UIParent", "BOTTOM", -306 , 80},
	},
	pet = {
		enabled = true,
		point = {"RIGHT", "lsPlayerFrame" , "LEFT"},
	},
	target = {
		enabled = true,
		point = {"BOTTOMLEFT", "UIParent", "BOTTOM", 166, 336},
		long = true,
	},
	targettarget = {
		enabled = true,
		point = { "LEFT", "lsTargetFrame", "RIGHT", 14, 0 },
	},
	focus = {
		enabled = true,
		point = { "BOTTOMRIGHT", "UIParent", "BOTTOM", -166, 336},
		long = true,
	},
	focustarget = {
		enabled = true,
		point = { "RIGHT", "lsFocusFrame", "LEFT", -14, 0 },
	},
	party = {
		enabled = true,
		point = {"TOPLEFT", "CompactRaidFrameManager", "TOPRIGHT", 6, 0},
		attributes = {"showPlayer", true, "showParty", true, "showRaid", false, "point", "BOTTOM", "yOffset", 40},
		visibility = "custom [group:raid] hide; [group:party] show; hide",
	},
	boss = {
		enabled = true,
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -84, -240},
		yOffset = 46,
	},
	-- boss2 = {
	-- 	enabled = true,
	-- 	point = {"TOP", "lsBoss1Frame", "BOTTOM", 0, -46},
	-- },
	-- boss3 = {
	-- 	enabled = true,
	-- 	point = {"TOP", "lsBoss2Frame", "BOTTOM", 0, -46},
	-- },
	-- boss4 = {
	-- 	enabled = true,
	-- 	point = {"TOP", "lsBoss3Frame", "BOTTOM", 0, -46},
	-- },
	-- boss5 = {
	-- 	enabled = true,
	-- 	point = {"TOP", "lsBoss4Frame", "BOTTOM", 0, -46},
	-- },
}

D["auratracker"] = {
	enabled = true,
	locked = false,
	showHeader = true,
	HELPFUL = {},
	buffList = {},
	HARMFUL = {},
	debuffList = {},
	point = {"CENTER", "UIParent", "CENTER", 0, 0},
}

D["minimap"] = {
	enabled = true,
	point = {"BOTTOM", "UIParent", "BOTTOM", 306, 86},
}

D["objectivetracker"] = {
	point = {"RIGHT", "UIParent", "RIGHT", -100, 0},
	locked = false,
}

D["infobars"] = {
	enabled = true,
	location = {
		enabled = true,
		point = {"TOPLEFT", "UIParent", "TOPLEFT", 4, -4},
	},
	memory = {
		enabled = true,
		point = {"LEFT", "lsLocationInfoBar", "RIGHT", 24, 0},
	},
	fps = {
		enabled = true,
		point = {"LEFT", "lsMemoryInfoBar", "RIGHT", 4, 0},
	},
	latency = {
		enabled = true,
		point = {"LEFT", "lsFPSInfoBar", "RIGHT", 4, 0},
	},
	bag = {
		enabled = true,
		point = {"LEFT", "lsLatencyInfoBar", "RIGHT", 24, 0},
	},
	clock = {
		enabled = true,
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -4, -4},
	},
	mail = {
		enabled = true,
		point = {"RIGHT", "lsClockInfoBar", "LEFT", -4, 0},
	},
}

D["nameplates"] = {
	enabled = true,
	showText = false,
}

D["bars"] = {
	enabled = true,
	bar1 = { -- MainMenuBar
		point = {"BOTTOM", 0, 15},
		button_size = 28,
		button_gap = 4,
		orientation = "HORIZONTAL",
	},
	bar2 = { -- MultiBarBottomLeft
		point = {"BOTTOM", 0, 62},
		button_size = 28,
		button_gap = 4,
		orientation = "HORIZONTAL",
	},
	bar3 = { -- MultiBarBottomRight
		point = {"BOTTOM", 0, 94},
		button_size = 28,
		button_gap = 4,
		orientation = "HORIZONTAL",
	},
	bar4 = { -- MultiBarLeft
		point = {"BOTTOMRIGHT", -32, 300},
		button_size = 28,
		button_gap = 4,
		orientation = "VERTICAL",
	},
	bar5 = { -- MultiBarRight
		point = {"BOTTOMRIGHT", 0, 300},
		button_size = 28,
		button_gap = 4,
		orientation = "VERTICAL",
	},
	bar6 = { --PetAction
		-- point = {}, -- NYI
		button_size = 24,
		button_gap = 4,
		orientation = "HORIZONTAL",
	},
	bar7 = { -- Stance
		-- point = {}, -- NYI
		button_size = 24,
		button_gap = 4,
		orientation = "HORIZONTAL",
	},
	bar9 = { -- ExtraAction
		point = {"BOTTOM", -171, 154},
		button_size = 40,
		button_gap = 4,
		orientation = "HORIZONTAL",
	},
	bar12 = { --PlayerPowerBarAlt
		point = {"BOTTOM", 0, 240},
		button_size = 128,
		button_gap = 4,
		orientation = "HORIZONTAL",
	},
	vehicle = { -- LeaveVehicle
		point = {"BOTTOM", 171, 154},
		button_size = 40,
	},
}

D["auras"] = {
	enabled = true,
	buff = {
		point = {"TOPRIGHT", -4, -42},
	},
	debuff = {
		point = {"TOPRIGHT", -4, -122},
	},
	tempench = {
		point = {"TOPRIGHT", -4, -162},
	},
	aura_size = 28,
	aura_gap = 4,
}

D["petbattle"] = {
	enabled = true,
	point = {"BOTTOM", 0, 15},
	button_size = 28,
	button_gap = 4,
	orientation = "HORIZONTAL",
	direction = "RIGHT",
}

D["bags"] = {
	enabled = true,
	point = {"LEFT", "lsLatencyInfoBar", "RIGHT", 24, 0},
	button_size = 28,
	button_gap = 4,
	orientation = "HORIZONTAL",
	direction = "RIGHT",
}

D["width"] = 0

D["height"] = 0

D["playerclass"] = ""