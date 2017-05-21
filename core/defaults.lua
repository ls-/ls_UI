local _, ns = ...
local D = ns.D

D["global"] = {}

D["profile"] = {
	["units"] = {
		["**"] = {
			player = {
				enabled = true,
				width = 166,
				height = 166,
				point = {"BOTTOM", "UIParent", "BOTTOM", -312 , 74},
				health = {
					orientation = "VERTICAL",
					color = {
						class = false,
					},
					text = {
						tag = "[ls:health:cur]",
						point1 = {
							p = "BOTTOM",
							anchor = "", -- frame[anchor] or "" if anchor is frame itself
							rP = "CENTER",
							x = 0,
							y = 1,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				power = {
					enabled = true,
					orientation = "VERTICAL",
					text = {
						tag = "[ls:color:power][ls:power:cur]|r",
						point1 = {
							p = "TOP",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = -1,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				class_power = {
					enabled = true,
					orientation = "VERTICAL",
					prediction = {
						enabled = true,
					},
				},
				castbar = {
					enabled = true,
					width_override = 200,
					icon = true,
					latency = true,
				},
				raid_target = {
					enabled = true,
					size = 24,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "TOP",
						x = 0,
						y = -6,
					},
				},
				pvp = {
					enabled = true,
				},
				debuff = {
					tag = "[ls:debuffs]",
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 0,
						y = 0,
					},
				},
				combat_feedback = {
					enabled = true,
					mode = "Fountain",
					x_offset = 15,
					y_offset = 20,
				},
				threat = {
					enabled = true,
				},
			},
			pet = {
				width = 42,
				height = 134,
				point = {"RIGHT", "LSPlayerFrame" , "LEFT", -2, 0},
				health = {
					orientation = "VERTICAL",
					color = {
						class = false,
					},
					text = {
						tag = "[ls:health:cur]",
						h_alignment = "RIGHT",
						point1 = {
							p = "BOTTOMRIGHT",
							anchor = "",
							rP = "BOTTOMLEFT",
							x = 8,
							y = 26,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				power = {
					enabled = true,
					orientation = "VERTICAL",
					text = {
						tag = "[ls:color:power][ls:power:cur]|r",
						h_alignment = "RIGHT",
						point1 = {
							p = "BOTTOMRIGHT",
							anchor = "",
							rP = "BOTTOMLEFT",
							x = 8,
							y = 14,
						},
					},
				},
				castbar = {
					enabled = true,
					width = 200,
					icon = true,
					latency = true,
				},
				raid_target = {
					enabled = true,
					size = 24,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "TOP",
						x = 0,
						y = 6,
					},
				},
				debuff = {
					tag = "[ls:debuffs]",
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
				},
				threat = {
					enabled = true,
				},
			},
			target = {
				enabled = true,
				width = 250,
				height = 52,
				point = {"BOTTOM", "UIParent", "BOTTOM", 286, 336},
				insets = {
					t_height = 14, -- should be either 10 or 14
					b_height = 14,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						tapped = true,
						disconnected = true,
						reaction = true,
					},
					text = {
						tag = "[ls:health:cur-perc]",
						h_alignment = "RIGHT",
						point1 = {
							p = "RIGHT",
							anchor = "Health",
							rP = "RIGHT",
							x = -2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				power = {
					enabled = true,
					orientation = "HORIZONTAL",
					text = {
						tag = "[ls:power:cur-color-max]",
						h_alignment = "RIGHT",
						point1 = {
							p = "RIGHT",
							anchor = "Power",
							rP = "RIGHT",
							x = -2,
							y = 0,
						},
					},
				},
				castbar = {
					enabled = true,
					width_override = 0,
					icon = true,
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]|r",
					h_alignment = "LEFT",
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 2,
						y = 0,
					},
					point2 = {
						p = "RIGHT",
						anchor = "Health.Text",
						rP = "LEFT",
						x = -2,
						y = 0,
					},
				},
				raid_target = {
					enabled = true,
					size = 24,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "TOP",
						x = 0,
						y = 6,
					},
				},
				pvp = {
					enabled = true,
				},
				debuff = {
					tag = "[ls:debuffs]",
					h_alignment = "RIGHT",
					point1 = {
						p = "TOPRIGHT",
						anchor = "Health",
						rP = "TOPRIGHT",
						x = -2,
						y = -2,
					},
				},
				threat = {
					enabled = true,
					feedback_unit = "player",
				},
				auras = {
					enabled = true,
					per_row = 8,
					rows = 4,
					size_override = 0,
					x_growth = "RIGHT",
					y_grwoth = "UP",
					init_anchor = "BOTTOMLEFT",
					disable_mouse = false,
					-- 0x0000000X -- friendly buff
					-- 0x000000X0 -- hostile buff
					-- 0x00000X00 -- friendly debuff
					-- 0x0000X000 -- hostile debuff
					show_boss = 0x0000ffff,
					show_mount = 0x000000ff,
					show_selfcast = 0x0000ffff,
					show_selfcast_permanent = 0x0000ffff,
					show_blizzard = 0x0000ffff,
					show_player = 0x0000ffff,
					show_dispellable = 0x00000ff0, -- friendly debuff / hostile buff
					point1 = {
						p = "BOTTOMLEFT",
						anchor = "",
						rP = "TOPLEFT",
						x = -1,
						y = 7,
					},
				},
			},
			targettarget = {
				width = 112,
				height = 28,
				point = { "BOTTOMLEFT", "LSTargetFrame", "BOTTOMRIGHT", 12, 0},
				insets = {
					t_height = 14,
					b_height = 14,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						tapped = true,
						disconnected = true,
						reaction = true,
					},
					text = {
						tag = "",
						point1 = {},
					},
					prediction = {
						enabled = true,
					},
				},
				power = {
					enabled = false,
					orientation = "HORIZONTAL",
					text = {
						tag = "",
						point1 = {},
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]|r",
					point1 = {
						p = "TOPLEFT",
						anchor = "Health",
						rP = "TOPLEFT",
						x = 2,
						y = -2,
					},
					point2 = {
						p = "BOTTOMRIGHT",
						anchor = "Health",
						rP = "BOTTOMRIGHT",
						x = -2,
						y = 2,
					},
				},
				raid_target = {
					enabled = true,
					size = 24,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "TOP",
						x = 0,
						y = 6,
					},
				},
				threat = {
					enabled = false,
					feedback_unit = "target",
				},
			},
			focus = {
				enabled = true,
				width = 250,
				height = 52,
				point = {"BOTTOM", "UIParent", "BOTTOM", -286, 336},
				insets = {
					t_height = 14,
					b_height = 14,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						tapped = true,
						disconnected = true,
						reaction = true,
					},
					text = {
						tag = "[ls:health:cur-perc]",
						h_alignment = "RIGHT",
						point1 = {
							p = "RIGHT",
							anchor = "Health",
							rP = "RIGHT",
							x = -2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				power = {
					enabled = true,
					orientation = "HORIZONTAL",
					text = {
						tag = "[ls:power:cur-color-max]",
						h_alignment = "RIGHT",
						point1 = {
							p = "RIGHT",
							anchor = "Power",
							rP = "RIGHT",
							x = -2,
							y = 0,
						},
					},
				},
				castbar = {
					enabled = true,
					width_override = 0,
					icon = true,
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]|r",
					h_alignment = "LEFT",
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 2,
						y = 0,
					},
					point2 = {
						p = "RIGHT",
						anchor = "Health.Text",
						rP = "LEFT",
						x = -2,
						y = 0,
					},
				},
				raid_target = {
					enabled = true,
					size = 24,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "TOP",
						x = 0,
						y = 6,
					},
				},
				pvp = {
					enabled = true,
				},
				debuff = {
					tag = "[ls:debuffs]",
					h_alignment = "RIGHT",
					point1 = {
						p = "TOPRIGHT",
						anchor = "Health",
						rP = "TOPRIGHT",
						x = -2,
						y = -2,
					},
				},
				threat = {
					enabled = true,
					feedback_unit = "player",
				},
				auras = {
					enabled = true,
					per_row = 8,
					rows = 4,
					size_override = 0,
					x_growth = "RIGHT",
					y_grwoth = "UP",
					init_anchor = "BOTTOMLEFT",
					disable_mouse = false,
					-- 0x0000000X -- friendly buff
					-- 0x000000X0 -- hostile buff
					-- 0x00000X00 -- friendly debuff
					-- 0x0000X000 -- hostile debuff
					show_boss = 0x0000ffff,
					show_mount = 0x000000ff,
					show_selfcast = 0x0000ffff,
					show_selfcast_permanent = 0x0000ffff,
					show_blizzard = 0x0000ffff,
					show_player = 0x0000ffff,
					show_dispellable = 0x00000ff0, -- friendly debuff / hostile buff
					point1 = {
						p = "BOTTOMLEFT",
						anchor = "",
						rP = "TOPLEFT",
						x = -1,
						y = 7,
					},
				},
			},
			focustarget = {
				width = 112,
				height = 28,
				point = { "BOTTOMRIGHT", "LSFocusFrame", "BOTTOMLEFT", -12, 0},
				insets = {
					t_height = 14,
					b_height = 14,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						tapped = true,
						disconnected = true,
						reaction = true,
					},
					text = {
						tag = "",
						point1 = {},
					},
					prediction = {
						enabled = true,
					},
				},
				power = {
					enabled = false,
					orientation = "HORIZONTAL",
					text = {
						tag = "",
						point1 = {},
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]|r",
					point1 = {
						p = "TOPLEFT",
						anchor = "Health",
						rP = "TOPLEFT",
						x = 2,
						y = -2,
					},
					point2 = {
						p = "BOTTOMRIGHT",
						anchor = "Health",
						rP = "BOTTOMRIGHT",
						x = -2,
						y = 2,
					},
				},
				raid_target = {
					enabled = true,
					size = 24,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "TOP",
						x = 0,
						y = 6,
					},
				},
				threat = {
					enabled = false,
					feedback_unit = "target",
				},
			},
			boss = {
				enabled = true,
				width = 188,
				height = 52,
				point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -82, -240},
				insets = {
					t_height = 14,
					b_height = 14,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						tapped = true,
						disconnected = true,
						reaction = true,
					},
					text = {
						tag = "[ls:health:perc]",
						h_alignment = "RIGHT",
						point1 = {
							p = "RIGHT",
							anchor = "Health",
							rP = "RIGHT",
							x = -2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				power = {
					enabled = true,
					orientation = "HORIZONTAL",
					text = {
						tag = "[ls:power:cur-color-perc]",
						h_alignment = "RIGHT",
						point1 = {
							p = "RIGHT",
							anchor = "Power",
							rP = "RIGHT",
							x = -2,
							y = 0,
						},
					},
				},
				alt_power = {
					enabled = true,
					orientation = "HORIZONTAL",
					text = {
						tag = "[ls:altpower:cur-color-perc]",
						h_alignment = "RIGHT",
						point1 = {
							p = "RIGHT",
							anchor = "AlternativePower",
							rP = "RIGHT",
							x = -2,
							y = 0,
						},
					},
				},
				castbar = {
					enabled = true,
					width_override = 0,
					icon = true,
				},
				name = {
					tag = "[ls:name]",
					h_alignment = "LEFT",
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 2,
						y = 0,
					},
					point2 = {
						p = "RIGHT",
						anchor = "Health.Text",
						rP = "LEFT",
						x = -2,
						y = 0,
					},
				},
				raid_target = {
					enabled = true,
					size = 24,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "TOP",
						x = 0,
						y = 6,
					},
				},
				debuff = {
					tag = "[ls:debuffs]",
					h_alignment = "RIGHT",
					point1 = {
						p = "TOPRIGHT",
						anchor = "Health",
						rP = "TOPRIGHT",
						x = -2,
						y = -2,
					},
				},
				threat = {
					enabled = true,
					feedback_unit = "player",
				},
				auras = {
					enabled = true,
					per_row = 3,
					rows = 2,
					size_override = 25,
					x_growth = "LEFT",
					y_grwoth = "DOWN",
					init_anchor = "TOPRIGHT",
					disable_mouse = false,
					-- 0x0000000X -- friendly buff
					-- 0x000000X0 -- hostile buff
					-- 0x00000X00 -- friendly debuff
					-- 0x0000X000 -- hostile debuff
					show_boss = 0x0000ffff,
					point1 = {
						p = "TOPRIGHT",
						anchor = "",
						rP = "TOPLEFT",
						x = -7,
						y = 1,
					},
				},
			},
		},
		ls = {},
		traditional = {},
	},
	["auratracker"] = {
		locked = false,
		button_size = 36,
		button_gap = 4,
		init_anchor = "TOPLEFT",
		buttons_per_row = 12,
		HELPFUL = {},
		HARMFUL = {},
	},
	["minimap"] = {
		["**"] = {
			point = {"BOTTOM", "UIParent", "BOTTOM", 312 , 74},
		},
		ls = {},
		traditional = {},
	},
	["bars"] = {
		show_hotkey = true,
		show_name = true,
		use_icon_as_indicator = true,
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
	},
	["auras"] = {
		["**"] = {
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
		},
		ls = {},
		traditional = {},
	},
	["tooltips"] = {
		show_id = true,
		unit = {
			name_color_pvp_hostility = true,
			name_color_class = true,
			name_color_tapping = true,
			name_color_reaction = true,
		}
	},
	["blizzard"] = {
		objective_tracker = { -- ObjectiveTrackerFrame
			height = 600,
		},
	},
	["movers"] = {
		ls = {},
		traditional = {},
	},
}

D["char"] = {
	["layout"] = "ls", -- or traditional
	["auratracker"] = {
		enabled = true,
	},
	["units"] = {
		enabled = true,
	},
	["minimap"] = {
		enabled = true,
	},
	["bars"] = {
		enabled = true,
		restricted = true,
		bags = {
			enabled = true,
		},
		xpbar = {
			enabled = true,
		},
	},
	["auras"] = {
		enabled = true,
	},
	["tooltips"] = {
		enabled = true,
	},
	["blizzard"] = {
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
	},
}
