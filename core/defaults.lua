local _, ns = ...
local D = ns.D

D.global = {}

D.profile = {
	units = {
		ls = {
			player = {
				enabled = true,
				width = 166,
				height = 166,
				point = {"BOTTOM", "UIParent", "BOTTOM", -312 , 74},
				health = {
					orientation = "VERTICAL",
					color = {
						class = false,
						reaction = false,
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
						absorb_text = {
							tag = "[ls:color:absorb-damage][ls:absorb:damage]|r",
							point1 = {
								p = "BOTTOM",
								anchor = "Health.Text",
								rP = "TOP",
								x = 0,
								y = 2,
							},
						},
						heal_absorb_text = {
							tag = "[ls:color:absorb-heal][ls:absorb:heal]|r",
							point1 = {
								p = "BOTTOM",
								anchor = "Health.Text",
								rP = "TOP",
								x = 0,
								y = 16,
							},
						},
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
					latency = true,
					detached = true,
					width_override = 200,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "BOTTOM",
						anchor = "",
						detached_anchor = "UIParent",
						rP = "BOTTOM",
						x = 0,
						y = 190,
					},
				},
				name = {
					tag = "",
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					word_wrap = false,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
					point2 = {
						p = "",
						anchor = "",
						rP = "CENTER",
						x = 0,
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
						y = -6,
					},
				},
				pvp = {
					enabled = true,
					point1 = {
						p = "TOP",
						anchor = "FGParent",
						rP = "BOTTOM",
						x = 0,
						y = 10,
					},
				},
				debuff = {
					enabled = true,
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 0,
						y = 0,
					},
				},
				threat = {
					enabled = true,
				},
				combat_feedback = {
					enabled = false,
					mode = "Fountain",
					x_offset = 15,
					y_offset = 20,
				},
			},
			pet = {
				enabled = true,
				width = 42,
				height = 134,
				point = {"RIGHT", "LSPlayerFrame" , "LEFT", -2, 0},
				health = {
					orientation = "VERTICAL",
					color = {
						class = true,
						reaction = true,
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
					latency = true,
					detached = true,
					width_override = 200,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "BOTTOM",
						anchor = "LSPlayerFrameCastbarHolder",
						detached_anchor = "LSPlayerFrameCastbarHolder",
						rP = "TOP",
						x = 0,
						y = 6,
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
					enabled = true,
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
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
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
						absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
						heal_absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
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
					latency = false,
					detached = false,
					width_override = 0,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "TOPLEFT",
						anchor = "",
						detached_anchor = "FRAME",
						rP = "BOTTOMLEFT",
						x = 0,
						y = -6,
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
					point1 = {
						p = "TOPRIGHT",
						anchor = "FGParent",
						rP = "BOTTOMRIGHT",
						x = -8,
						y = -2,
					},
				},
				debuff = {
					enabled = true,
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
					rows = 4,
					per_row = 8,
					size_override = 0,
					x_growth = "RIGHT",
					y_growth = "UP",
					disable_mouse = false,
					filter = {
						friendly = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
						},
						enemy = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
							},
						},
					},
					point1 = {
						p = "BOTTOMLEFT",
						anchor = "",
						rP = "TOPLEFT",
						x = -1,
						y = 7,
					},
				},
				class = {
					player = true,
					npc = true,
				},
			},
			targettarget = {
				enabled = true,
				width = 112,
				height = 28,
				point = { "BOTTOMLEFT", "LSTargetFrame", "BOTTOMRIGHT", 12, 0},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						reaction = true,
					},
					text = {
						tag = "",
						point1 = {
							p = "CENTER",
							anchor = "",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
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
						point1 = {
							p = "CENTER",
							anchor = "",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
				class = {
					player = true,
					npc = true,
				},
			},
			focus = {
				enabled = true,
				width = 250,
				height = 52,
				point = {"BOTTOM", "UIParent", "BOTTOM", -286, 336},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						reaction = true,
					},
					text = {
						tag = "[ls:health:cur-perc]",
						h_alignment = "LEFT",
						point1 = {
							p = "LEFT",
							anchor = "Health",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
						absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
						heal_absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
					},
				},
				power = {
					enabled = true,
					orientation = "HORIZONTAL",
					text = {
						tag = "[ls:power:cur-color-max]",
						h_alignment = "LEFT",
						point1 = {
							p = "LEFT",
							anchor = "Power",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
				},
				castbar = {
					enabled = true,
					latency = false,
					detached = false,
					width_override = 0,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "TOPRIGHT",
						anchor = "",
						detached_anchor = "FRAME",
						rP = "BOTTOMRIGHT",
						x = 0,
						y = -6,
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
					h_alignment = "RIGHT",
					v_alignment = "MIDDLE",
					word_wrap = false,
					point1 = {
						p = "RIGHT",
						anchor = "Health",
						rP = "RIGHT",
						x = -2,
						y = 0,
					},
					point2 = {
						p = "LEFT",
						anchor = "Health.Text",
						rP = "RIGHT",
						x = 2,
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
					point1 = {
						p = "TOPLEFT",
						anchor = "FGParent",
						rP = "BOTTOMLEFT",
						x = 8,
						y = -2,
					},
				},
				debuff = {
					enabled = true,
					point1 = {
						p = "TOPLEFT",
						anchor = "Health",
						rP = "TOPLEFT",
						x = 2,
						y = -2,
					},
				},
				threat = {
					enabled = true,
					feedback_unit = "player",
				},
				auras = {
					enabled = true,
					rows = 4,
					per_row = 8,
					size_override = 0,
					x_growth = "RIGHT",
					y_growth = "UP",
					disable_mouse = false,
					filter = {
						friendly = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
						},
						enemy = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
							},
						},
					},
					point1 = {
						p = "BOTTOMLEFT",
						anchor = "",
						rP = "TOPLEFT",
						x = -1,
						y = 7,
					},
				},
				class = {
					player = true,
					npc = true,
				},
			},
			focustarget = {
				enabled = true,
				width = 112,
				height = 28,
				point = { "BOTTOMRIGHT", "LSFocusFrame", "BOTTOMLEFT", -12, 0},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						reaction = true,
					},
					text = {
						tag = "",
						point1 = {
							p = "CENTER",
							anchor = "",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
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
						point1 = {
							p = "CENTER",
							anchor = "",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
					feedback_unit = "focus",
				},
				class = {
					player = true,
					npc = true,
				},
			},
			boss = {
				enabled = true,
				width = 188,
				height = 52,
				spacing = 28,
				x_growth = "LEFT",
				y_growth = "DOWN",
				per_row = 1,
				point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -82, -268},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
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
						absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
						heal_absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
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
					latency = false,
					detached = false,
					width_override = 0,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "TOPLEFT",
						anchor = "",
						detached_anchor = "FRAME",
						rP = "BOTTOMLEFT",
						x = 0,
						y = -6,
					},
				},
				name = {
					tag = "[ls:name]",
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
					enabled = true,
					point1 = {
						p = "CENTER",
						anchor = "Health",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
				},
				threat = {
					enabled = true,
					feedback_unit = "player",
				},
				auras = {
					enabled = true,
					rows = 2,
					per_row = 3,
					size_override = 25,
					x_growth = "LEFT",
					y_growth = "DOWN",
					disable_mouse = false,
					filter = {
						friendly = {
							buff = {
								boss = true,
								player = false,
								player_permanent = false,
							},
							debuff = {
								boss = true,
								player = false,
								player_permanent = false,
								dispellable = false,
							},
						},
						enemy = {
							buff = {
								boss = true,
								player = false,
								player_permanent = false,
								dispellable = false,
							},
							debuff = {
								boss = true,
								player = false,
								player_permanent = false,
							},
						},
					},
					point1 = {
						p = "TOPRIGHT",
						anchor = "",
						rP = "TOPLEFT",
						x = -7,
						y = 1,
					},
				},
				class = {
					player = true,
					npc = true,
				},
			},
		},
		traditional = {
			player = {
				enabled = true,
				width = 250,
				height = 52,
				point = {"BOTTOM", "UIParent", "BOTTOM", -286, 256},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						reaction = false,
					},
					text = {
						tag = "[ls:health:cur]",
						h_alignment = "LEFT",
						point1 = {
							p = "LEFT",
							anchor = "Health",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
						absorb_text = {
							tag = "[ls:color:absorb-damage][ls:absorb:damage]|r",
							h_alignment = "RIGHT",
							point1 = {
								p = "BOTTOMRIGHT",
								anchor = "Health",
								rP = "RIGHT",
								x = -2,
								y = 1,
							},
						},
						heal_absorb_text = {
							tag = "[ls:color:absorb-heal][ls:absorb:heal]|r",
							h_alignment = "RIGHT",
							point1 = {
								p = "TOPRIGHT",
								anchor = "Health",
								rP = "RIGHT",
								x = -2,
								y = -1,
							},
						},
					},
				},
				power = {
					enabled = true,
					orientation = "HORIZONTAL",
					text = {
						tag = "[ls:color:power][ls:power:cur]|r",
						h_alignment = "LEFT",
						point1 = {
							p = "LEFT",
							anchor = "Power",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				class_power = {
					enabled = true,
					orientation = "HORIZONTAL",
					prediction = {
						enabled = true,
					},
				},
				castbar = {
					enabled = true,
					latency = true,
					detached = false,
					width_override = 0,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "TOPRIGHT",
						anchor = "",
						detached_anchor = "FRAME",
						rP = "BOTTOMRIGHT",
						x = 0,
						y = -6,
					},
				},
				name = {
					tag = "",
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					word_wrap = false,
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
					point2 = {
						p = "",
						anchor = "",
						rP = "CENTER",
						x = 0,
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
					point1 = {
						p = "TOPLEFT",
						anchor = "FGParent",
						rP = "BOTTOMLEFT",
						x = 8,
						y = -2,
					},
				},
				debuff = {
					enabled = true,
					point1 = {
						p = "CENTER",
						anchor = "Health",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
				},
				threat = {
					enabled = true,
				},
				auras = {
					enabled = false,
					rows = 4,
					per_row = 8,
					size_override = 0,
					x_growth = "RIGHT",
					y_growth = "UP",
					disable_mouse = false,
					filter = {
						friendly = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								dispellable = true,
							},
						},
					},
					point1 = {
						p = "BOTTOMLEFT",
						anchor = "",
						rP = "TOPLEFT",
						x = -1,
						y = 7,
					},
				},
				combat_feedback = {
					enabled = false,
					mode = "Standard",
					x_offset = 64,
					y_offset = 32,
				},
				class = {
					player = true,
					npc = true,
				},
			},
			pet = {
				enabled = true,
				width = 112,
				height = 28,
				point = { "BOTTOMRIGHT", "LSPlayerFrame", "BOTTOMLEFT", -12, 0},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = true,
						reaction = true,
					},
					text = {
						tag = "[ls:health:cur]",
						h_alignment = "LEFT",
						point1 = {
							p = "LEFT",
							anchor = "Health",
							rP = "LEFT",
							x = 2,
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
						tag = "[ls:color:power][ls:power:cur]|r",
						h_alignment = "LEFT",
						point1 = {
							p = "LEFT",
							anchor = "Power",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
				},
				castbar = {
					enabled = true,
					latency = true,
					detached = false,
					width_override = 0,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "TOPLEFT",
						anchor = "",
						detached_anchor = "FRAME",
						rP = "BOTTOMLEFT",
						x = 0,
						y = -6,
					},
				},
				name = {
					tag = "",
					h_alignment = "CENTER",
					point1 = {
						p = "CENTER",
						anchor = "Health",
						rP = "CENTER",
						x = 2,
						y = 0,
					},
					point2 = {
						p = "",
						anchor = "",
						rP = "CENTER",
						x = 0,
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
					enabled = true,
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
				class = {
					player = true,
					npc = true,
				},
			},
			target = {
				enabled = true,
				width = 250,
				height = 52,
				point = {"BOTTOM", "UIParent", "BOTTOM", 286, 256},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
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
						absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
						heal_absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
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
					latency = false,
					detached = false,
					width_override = 0,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "TOPLEFT",
						anchor = "",
						detached_anchor = "FRAME",
						rP = "BOTTOMLEFT",
						x = 0,
						y = -6,
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
					point1 = {
						p = "TOPRIGHT",
						anchor = "FGParent",
						rP = "BOTTOMRIGHT",
						x = -8,
						y = -2,
					},
				},
				debuff = {
					enabled = true,
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
					rows = 4,
					per_row = 8,
					size_override = 0,
					x_growth = "RIGHT",
					y_growth = "UP",
					disable_mouse = false,
					filter = {
						friendly = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
						},
						enemy = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
							},
						},
					},
					point1 = {
						p = "BOTTOMLEFT",
						anchor = "",
						rP = "TOPLEFT",
						x = -1,
						y = 7,
					},
				},
				class = {
					player = true,
					npc = true,
				},
			},
			targettarget = {
				enabled = true,
				width = 112,
				height = 28,
				point = { "BOTTOMLEFT", "LSTargetFrame", "BOTTOMRIGHT", 12, 0},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						reaction = true,
					},
					text = {
						tag = "",
						point1 = {
							p = "CENTER",
							anchor = "",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
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
						point1 = {
							p = "CENTER",
							anchor = "",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
				class = {
					player = true,
					npc = true,
				},
			},
			focus = {
				enabled = true,
				width = 250,
				height = 52,
				point = {"BOTTOM", "UIParent", "BOTTOM", 286, 480},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
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
						absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
						heal_absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
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
					latency = false,
					detached = false,
					width_override = 0,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "TOPRIGHT",
						anchor = "",
						detached_anchor = "FRAME",
						rP = "BOTTOMRIGHT",
						x = 0,
						y = -6,
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
					point1 = {
						p = "TOPRIGHT",
						anchor = "FGParent",
						rP = "BOTTOMRIGHT",
						x = -8,
						y = -2,
					},
				},
				debuff = {
					enabled = true,
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
					rows = 4,
					per_row = 8,
					size_override = 0,
					x_growth = "RIGHT",
					y_growth = "UP",
					disable_mouse = false,
					filter = {
						friendly = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
						},
						enemy = {
							buff = {
								boss = true,
								mount = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
							debuff = {
								boss = true,
								selfcast = true,
								selfcast_permanent = true,
								player = true,
								player_permanent = true,
							},
						},
					},
					point1 = {
						p = "BOTTOMLEFT",
						anchor = "",
						rP = "TOPLEFT",
						x = -1,
						y = 7,
					},
				},
				class = {
					player = true,
					npc = true,
				},
			},
			focustarget = {
				enabled = true,
				width = 112,
				height = 28,
				point = { "BOTTOMLEFT", "LSFocusFrame", "BOTTOMRIGHT", 12, 0},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
						reaction = true,
					},
					text = {
						tag = "",
						point1 = {
							p = "CENTER",
							anchor = "",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
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
						point1 = {
							p = "CENTER",
							anchor = "",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
				name = {
					tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
				class = {
					player = true,
					npc = true,
				},
			},
			boss = {
				enabled = true,
				width = 188,
				height = 52,
				spacing = 28,
				x_growth = "LEFT",
				y_growth = "DOWN",
				per_row = 1,
				point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -82, -268},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					orientation = "HORIZONTAL",
					color = {
						class = false,
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
						absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
						heal_absorb_text = {
							tag = "",
							point1 = {
								p = "CENTER",
								anchor = "",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
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
					latency = false,
					detached = false,
					width_override = 0,
					height = 12,
					icon = {
						enabled = true,
						position = "LEFT", -- or "RIGHT"
					},
					point1 = {
						p = "TOPLEFT",
						anchor = "",
						detached_anchor = "FRAME",
						rP = "BOTTOMLEFT",
						x = 0,
						y = -6,
					},
				},
				name = {
					tag = "[ls:name]",
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					word_wrap = false,
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
					enabled = true,
					point1 = {
						p = "CENTER",
						anchor = "Health",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
				},
				threat = {
					enabled = true,
					feedback_unit = "player",
				},
				auras = {
					enabled = true,
					rows = 2,
					per_row = 3,
					size_override = 25,
					x_growth = "LEFT",
					y_growth = "DOWN",
					disable_mouse = false,
					filter = {
						friendly = {
							buff = {
								boss = true,
								player = true,
								player_permanent = true,
							},
							debuff = {
								boss = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
						},
						enemy = {
							buff = {
								boss = true,
								player = true,
								player_permanent = true,
								dispellable = true,
							},
							debuff = {
								boss = true,
								player = true,
								player_permanent = true,
							},
						},
					},
					point1 = {
						p = "TOPRIGHT",
						anchor = "",
						rP = "TOPLEFT",
						x = -7,
						y = 1,
					},
				},
				class = {
					player = true,
					npc = true,
				},
			},
		},
	},
	minimap = {
		ls = {
			zone_text = {
				mode = 1, -- 0 - hide, 1 - mouseover, 2 - show
				position = 0, -- 0 - top, 1 - bottom
				border = false,
			},
			clock = {
				mode = 2, -- 0 - hide, 1 - mouseover, 2 - show
				position = 0, -- 0 - top, 1 - bottom
			},
			flag = {
				mode = 2, -- 0 - hide, 1 - mouseover, 2 - show
				position = 0, -- 0 - zone text, 1 - clock, 2 - bottom
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 312 , 74},
		},
		traditional = {
			zone_text = {
				mode = 2,
				position = 0,
				border = true,
			},
			clock = {
				mode = 2,
				position = 1,
			},
			flag = {
				mode = 2,
				position = 0,
			},
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -8 , -24},
		},
		buttons = {},
	},
	bars = {
		mana_indicator = "button", -- hotkey
		range_indicator = "button", -- hotkey
		lock = true, -- watch: LOCK_ACTIONBAR
		rightclick_selfcast = false,
		desaturate_on_cd = false,
		click_on_down = false,
		draw_bling = true,
		blizz_vehicle = false,
		bar1 = { -- MainMenuBar
			flyout_dir = "UP",
			grid = true,
			num = 12,
			per_row = 12,
			size = 32,
			spacing = 4,
			visibility = "[petbattle] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			count = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 0,
				y = 16
			},
		},
		bar2 = { -- MultiBarBottomLeft
			flyout_dir = "UP",
			grid = true,
			num = 12,
			per_row = 12,
			size = 32,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			count = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 0,
				y = 52
			},
		},
		bar3 = { -- MultiBarBottomRight
			flyout_dir = "UP",
			grid = true,
			num = 12,
			per_row = 12,
			size = 32,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			count = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 0,
				y = 88
			},
		},
		bar4 = { -- MultiBarLeft
			flyout_dir = "LEFT",
			grid = true,
			num = 12,
			per_row = 1,
			size = 32,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "LEFT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			count = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			point = {
				p = "BOTTOMRIGHT",
				anchor = "UIParent",
				rP = "BOTTOMRIGHT",
				x = -40,
				y = 240
			},
		},
		bar5 = { -- MultiBarRight
			flyout_dir = "LEFT",
			grid = true,
			num = 12,
			per_row = 1,
			size = 32,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "LEFT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			count = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			point = {
				p = "BOTTOMRIGHT",
				anchor = "UIParent",
				rP = "BOTTOMRIGHT",
				x = -4,
				y = 240,
			},
		},
		bar6 = { --PetAction
			flyout_dir = "UP",
			num = 10,
			per_row = 10,
			size = 24,
			spacing = 4,
			visibility = "[pet,nopetbattle,novehicleui,nooverridebar,nopossessbar] show; hide",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
		},
		bar7 = { -- Stance
			flyout_dir = "UP",
			num = 10,
			per_row = 10,
			size = 24,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
		},
		pet_battle = {
			num = 6,
			per_row = 6,
			size = 32,
			spacing = 4,
			visibility = "[petbattle] show; hide",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 0,
				y = 16
			},
		},
		extra = { -- ExtraAction
			size = 40,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = -168,
				y = 130
			},
		},
		zone = { -- ZoneAbility
			size = 40,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = -168,
				y = 174
			},
		},
		vehicle = { -- LeaveVehicle
			size = 40,
			visible = true,
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 168,
				y = 130
			},
		},
		micromenu = {
			visible = true,
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			menu1 = {
				point = {
					p = "BOTTOM",
					anchor = "UIParent",
					rP = "BOTTOM",
					x = -280,
					y = 16
				},
			},
			menu2 = {
				point = {
					p = "BOTTOM",
					anchor = "UIParent",
					rP = "BOTTOM",
					x = 280,
					y = 16
				},
			},
			tooltip = {
				character = false,
				quest = true,
				lfd = true,
				ej = true,
				main = true,
			},
		},
		xpbar = {
			visible = true,
			width = 746,
			height = 8,
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 0,
				y = 4
			},
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
		},
		bags = {
			num = 5,
			per_row = 5,
			size = 32,
			spacing = 4,
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			count = {
				enabled = true,
				size = 12,
				flag = "Outline",
			},
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 434,
				y = 16
			},
			currency = {},
		},
	},
	auras = {
		ls = {
			HELPFUL = {
				size = 32,
				spacing = 4,
				x_growth = "LEFT",
				y_growth = "DOWN",
				per_row = 16,
				num_rows = 2,
				sep_own = 0,
				sort_method = "INDEX",
				sort_dir = "+",
				point = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -6,
					y = -6,
				},
			},
			HARMFUL = {
				size = 32,
				spacing = 4,
				x_growth = "LEFT",
				y_growth = "DOWN",
				per_row = 16,
				num_rows = 1,
				sep_own = 0,
				sort_method = "INDEX",
				sort_dir = "+",
				point = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -6,
					y = -114,
				},
			},
			TOTEM = {
				num = 4,
				size = 32,
				spacing = 4,
				x_growth = "LEFT",
				y_growth = "DOWN",
				per_row = 4,
				point = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -4,
					y = -148,
				},
			},
		},
		traditional = {
			HELPFUL = {
				size = 32,
				spacing = 4,
				x_growth = "LEFT",
				y_growth = "DOWN",
				per_row = 16,
				num_rows = 2,
				sep_own = 0,
				sort_method = "INDEX",
				sort_dir = "+",
				point = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -184,
					y = -6,
				},
			},
			HARMFUL = {
				size = 32,
				spacing = 4,
				x_growth = "LEFT",
				y_growth = "DOWN",
				per_row = 16,
				num_rows = 1,
				sep_own = 0,
				sort_method = "INDEX",
				sort_dir = "+",
				point = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -184,
					y = -114,
				},
			},
			TOTEM = {
				num = 4,
				size = 32,
				spacing = 4,
				x_growth = "LEFT",
				y_growth = "DOWN",
				per_row = 4,
				point = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -182,
					y = -148,
				},
			},
		},
	},
	tooltips = {
		id = true,
		count = true,
		title = true,
		target = true,
		inspect = true,
	},
	blizzard = {
		objective_tracker = { -- ObjectiveTrackerFrame
			height = 600,
			drag_key = "NONE"
		},
	},
	movers = {
		ls = {},
		traditional = {},
	},
}

D.char = {
	layout = "ls", -- or traditional
	auras = {
		enabled = true,
	},
	auratracker = {
		enabled = false,
		locked = false,
		num = 12,
		size = 32,
		spacing = 4,
		per_row = 12,
		x_growth = "RIGHT",
		y_growth = "DOWN",
		drag_key = "NONE",
		filter = {
			HELPFUL = {},
			HARMFUL = {},
			ALL = {},
		},
	},
	bars = {
		enabled = true,
		restricted = true,
		bags = {
			enabled = true,
		},
		pet_battle = {
			enabled = false,
		},
		xpbar = {
			enabled = true,
		},
	},
	blizzard = {
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
	minimap = {
		enabled = true,
	},
	tooltips = {
		enabled = true,
	},
	units = {
		enabled = true,
		player = {
			enabled = true,
		},
		target = {
			enabled = true,
		},
		focus = {
			enabled = true,
		},
		boss = {
			enabled = true,
		},
	},
}
