local _, ns = ...
local D = ns.D

D["units"] = {
	enabled =  true,
	player = {
		enabled = true,
		point = {"BOTTOM", "UIParent", "BOTTOM", -314 , 80},
		combo_bar_type = "VERTICAL" -- "HORIZONTAL" is a second option
	},
	pet = {
		enabled = true,
		point = {"RIGHT", "LSPlayerFrame" , "LEFT", -2, 0},
	},
	target = {
		enabled = true,
		point = {"BOTTOMLEFT", "UIParent", "BOTTOM", 166, 336},
	},
	targettarget = {
		enabled = true,
		point = { "LEFT", "LSTargetFrame", "RIGHT", 6, 0 },
	},
	focus = {
		enabled = true,
		point = { "BOTTOMRIGHT", "UIParent", "BOTTOM", -166, 336},
	},
	focustarget = {
		enabled = true,
		point = { "RIGHT", "LSFocusFrame", "LEFT", -6, 0 },
	},
	party = {
		enabled = true,
		point1 = {"TOPLEFT", "CompactRaidFrameManager", "TOPRIGHT", 6, 0},
		point2 = {"TOPLEFT", "UIParent", "TOPLEFT", 14, -140},
	},
	boss = {
		enabled = true,
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -72, -240},
	},
	arena = {
		enabled = true,
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -72, -240},
	},
}

D["auratracker"] = {
	enabled = true,
	locked = false,
	point = {"CENTER", "UIParent", "CENTER", 0, 0},
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
	point = {"BOTTOM", "UIParent", "BOTTOM", 314 , 80},
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
		point = {"BOTTOM", 0, 12},
		button_size = 28,
		button_gap = 4,
		direction = "RIGHT",
	},
	bar2 = { -- MultiBarBottomLeft
		point = {"BOTTOM", 0, 53},
		button_size = 28,
		button_gap = 4,
		direction = "RIGHT",
	},
	bar3 = { -- MultiBarBottomRight
		point = {"BOTTOM", 0, 85},
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
		point = {"BOTTOM", -170, 149},
		button_size = 40,
	},
	vehicle = { -- LeaveVehicle
		point = {"BOTTOM", 170, 149},
		button_size = 40,
	},
}

D["micromenu"] = {
	holder1 = {
		point = {"BOTTOM", -266, 4},
	},
	holder2 = {
		point = {"BOTTOM", 266, 4},
	},
}

D["mail"] = {
	enabled = true,
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
	point = {"BOTTOM", 0, 15},
	button_size = 28,
	button_gap = 4,
	direction = "RIGHT",
}

D["bags"] = {
	enabled = true,
	point = {"LEFT", "LSMBHolderRight", "RIGHT", 6, 0},
	button_size = 26,
	button_gap = 4,
	direction = "RIGHT",
}

D["movers"] = {}

D["width"] = 0

D["height"] = 0

D["playerclass"] = ""
