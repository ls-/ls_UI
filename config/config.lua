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
	point = {"CENTER", "UIParent", "CENTER", 0, 0},
	num_buttons = 8,
	button_size = 40,
	button_gap = 5,
	direction = "RIGHT",
	HELPFUL = {},
	HARMFUL = {},
	["0"] = { -- for level < 10 and buffer
		HELPFUL = {},
		HARMFUL = {},
	},
	["1"] = {
		HELPFUL = {},
		HARMFUL = {},
	},
	["2"] = {
		HELPFUL = {},
		HARMFUL = {},
	},
	["3"] = {
		HELPFUL = {},
		HARMFUL = {},
	},
	["4"] = {
		HELPFUL = {},
		HARMFUL = {},
	},
}

D["minimap"] = {
	enabled = true,
	point = {"BOTTOM", "UIParent", "BOTTOM", 306, 86},
}

D["infobars"] = {
	enabled = true,
	clock = {
		enabled = true,
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -4, -4},
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
		direction = "RIGHT",
	},
	bar2 = { -- MultiBarBottomLeft
		point = {"BOTTOM", 0, 62},
		button_size = 28,
		button_gap = 4,
		direction = "RIGHT",
	},
	bar3 = { -- MultiBarBottomRight
		point = {"BOTTOM", 0, 94},
		button_size = 28,
		button_gap = 4,
		direction = "RIGHT",
	},
	bar4 = { -- MultiBarLeft
		point = {"BOTTOMRIGHT", -32, 300},
		button_size = 28,
		button_gap = 4,
		direction = "DOWN",
	},
	bar5 = { -- MultiBarRight
		point = {"BOTTOMRIGHT", 0, 300},
		button_size = 28,
		button_gap = 4,
		direction = "DOWN",
	},
	bar6 = { --PetAction
		-- point = {}, -- NYI
		button_size = 24,
		button_gap = 4,
		direction = "RIGHT",
	},
	bar7 = { -- Stance
		-- point = {}, -- NYI
		button_size = 24,
		button_gap = 4,
		direction = "RIGHT",
	},
	extra = { -- ExtraAction
		point = {"BOTTOM", -171, 154},
		button_size = 40,
	},
	vehicle = { -- LeaveVehicle
		point = {"BOTTOM", 171, 154},
		button_size = 40,
	},
}

D["micromenu"] = {
	holder1 = {
		point = {"BOTTOM", -270, 8},
	},
	holder2 = {
		point = {"BOTTOM", 270, 8},
	},
}

D["auras"] = {
	enabled = true,
	buff = {
		point = {"TOPRIGHT", -4, -40},
	},
	debuff = {
		point = {"TOPRIGHT", -4, -124},
	},
	tempench = {
		point = {"TOPRIGHT", -4, -164},
	},
	aura_size = 28,
	aura_gap = 4,
}

D["petbattle"] = {
	enabled = true,
	point = {"BOTTOM", 0, 15},
	button_size = 28,
	button_gap = 4,
	direction = "RIGHT",
}

D["bags"] = {
	enabled = true,
	point = {"LEFT", "LSMBHolderRight", "RIGHT", 12, 0},
	button_size = 26,
	button_gap = 4,
	direction = "RIGHT",
}

D["movers"] = {}

D["width"] = 0

D["height"] = 0

D["playerclass"] = ""
