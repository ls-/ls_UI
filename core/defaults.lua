local _, ns = ...
local D = ns.D

D["units"] = {
	enabled =  true,
	player = {
		enabled = true,
		castbar = true,
		point = {"BOTTOM", "UIParent", "BOTTOM", -318, 90},
	},
	pet = {
		point = {"RIGHT", "LSPlayerFrame" , "LEFT", -2, 0},
	},
	target = {
		enabled = true,
		castbar = true,
		point = {"BOTTOM", "UIParent", "BOTTOM", 268, 336},
		auras = {
			enabled = 0x0000000f,
			show_only_filtered = 0x00000000,
			HELPFUL = {
				include_castable = 0x00000000, -- f
				auralist = {},
			},
			HARMFUL = {
				auralist = {},
			},
		},
	},
	targettarget = {
		point = { "LEFT", "LSTargetFrame", "RIGHT", 6, 0 },
	},
	focus = {
		enabled = true,
		castbar = true,
		point = {"BOTTOM", "UIParent", "BOTTOM", -268, 336},
		auras = {
			enabled = 0x0000000f,
			show_only_filtered = 0x00000000,
			HELPFUL = {
				include_castable = 0x00000000,
				auralist = {},
			},
			HARMFUL = {
				auralist = {},
			},
		},
	},
	focustarget = {
		point = { "RIGHT", "LSFocusFrame", "LEFT", -6, 0 },
	},
	boss = {
		enabled = true,
		castbar = true,
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -72, -240},
	},
	-- arena = {
	-- 	enabled = true,
	-- 	point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -72, -240},
	-- 	castbar = true,
	-- },
}

D["auratracker"] = {
	enabled = true,
	locked = false,
	button_size = 36,
	button_gap = 4,
	init_anchor = "TOPLEFT",
	buttons_per_row = 12,
	HELPFUL = {},
	HARMFUL = {},
}

D["minimap"] = {
	enabled = true,
	point = {"BOTTOM", "UIParent", "BOTTOM", 312 , 74},
}

D["bars"] = {
	enabled = true,
	restricted = true,
	show_hotkey = true,
	show_name = true,
	bar1 = { -- MainMenuBar
		visible = true,
		point = {"BOTTOM", 0, 16},
		button_size = 32,
		button_gap = 4,
		init_anchor = "TOPLEFT",
		buttons_per_row = 12,
	},
	bar2 = { -- MultiBarBottomLeft
		visible = true,
		point = {"BOTTOM", 0, 52},
		button_size = 32,
		button_gap = 4,
		init_anchor = "TOPLEFT",
		buttons_per_row = 12,
	},
	bar3 = { -- MultiBarBottomRight
		visible = true,
		point = {"BOTTOM", 0, 88},
		button_size = 32,
		button_gap = 4,
		init_anchor = "TOPLEFT",
		buttons_per_row = 12,
	},
	bar4 = { -- MultiBarLeft
		visible = true,
		point = {"BOTTOMRIGHT", -40, 240},
		button_size = 32,
		button_gap = 4,
		init_anchor = "TOPRIGHT",
		buttons_per_row = 1,
	},
	bar5 = { -- MultiBarRight
		visible = true,
		point = {"BOTTOMRIGHT", -4, 240},
		button_size = 32,
		button_gap = 4,
		init_anchor = "TOPRIGHT",
		buttons_per_row = 1,
	},
	bar6 = { --PetAction
		visible = true,
		button_size = 24,
		button_gap = 4,
		init_anchor = "TOPLEFT",
		buttons_per_row = 10,
	},
	bar7 = { -- Stance
		visible = true,
		button_size = 24,
		button_gap = 4,
		init_anchor = "TOPLEFT",
		buttons_per_row = 10,
	},
	extra = { -- ExtraAction
		visible = true,
		point = {"BOTTOM", -170, 138},
		button_size = 40,
	},
	vehicle = { -- LeaveVehicle
		visible = true,
		point = {"BOTTOM", 170, 138},
		button_size = 40,
	},
	garrison = {
		visible = true,
		point = {"BOTTOM", -170, 182},
		button_size = 40,
	},
	micromenu = {
		visible = true,
		holder1 = {
			point = {"BOTTOM", -280, 16},
		},
		holder2 = {
			point = {"BOTTOM", 280, 16},
		},
	},
	bags = {
		enabled = true,
		visible = true,
		point = {"BOTTOM", 434, 16},
		button_size = 32,
		button_gap = 4,
		init_anchor = "TOPLEFT",
		buttons_per_row = 5,
	},
	xpbar = {
		enabled = true,
		point = {"BOTTOM", "UIParent", "BOTTOM", 0, 4},
	},
}

D["mail"] = {
	enabled = true,
}

D["auras"] = {
	enabled = true,
	buff = {
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -4, -4},
	},
	debuff = {
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -4, -76},
	},
	tempench = {
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -4, -112},
	},
	aura_size = 32,
	aura_gap = 4,
}

D["tooltips"] = {
	enabled = true,
	show_id = true,
	unit = {
		name_color_pvp_hostility = true,
		name_color_class = true,
		name_color_tapping = true,
		name_color_reaction = true,
	}
}

D["movers"] = {}

D["blizzard"] ={
	enabled = true,
	command_bar = { -- OrderHallCommandBar
		enabled = true
	},
	digsite_bar = { -- ArcheologyDigsiteProgressBar
		enabled = true,
	},
	durability = { -- DurabilityFrame
		enabled = true
	},
	gm = { -- TicketStatusFrame
		enabled = true
	},
	npe = { -- NPE_TutorialInterfaceHelp
		enabled = true
	},
	objective_tracker = { -- ObjectiveTrackerFrame
		enabled = true,
		height = 600,
	},
	player_alt_power_bar = { -- PlayerPowerBarAlt
		enabled = true
	},
	talking_head = { -- TalkingHeadFrame
		enabled = true
	},
	timer = { -- MirrorTimer*, TimerTrackerTimer*
		enabled = true
	},
	vehicle = { -- VehicleSeatIndicator
		enabled = true
	},
}

D["login_msg"] = true
