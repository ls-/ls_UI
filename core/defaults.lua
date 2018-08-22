local _, ns = ...
local D = ns.D

D.global = {}

D.profile = {
	units = {
		cooldown = {
			exp_threshold = 5, -- [1; 10]
			m_ss_threshold = 600, -- [91; 3599]
			colors = {
				enabled = true,
				expiration = {229 / 255, 25 / 255, 25 / 255},
				second = {255 / 255, 191 / 255, 25 / 255},
				minute = {255 / 255, 255 / 255, 255 / 255},
				hour = {255 / 255, 255 / 255, 255 / 255},
				day = {255 / 255, 255 / 255, 255 / 255},
			},
		},
		player = {
			ls = {
				enabled = true,
				width = 166,
				height = 166,
				point = {
					ls = {"BOTTOM", "UIParent", "BOTTOM", -312 , 74},
					traditional = {"BOTTOM", "UIParent", "BOTTOM", -312 , 74},
				},
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
					runes = {
						color_by_spec = true,
						sort_order = "none",
					}
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
						anchor = "TextureParent",
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
				class = {
					player = false,
					npc = false,
				},
			},
			traditional = {
				enabled = true,
				width = 250,
				height = 52,
				point = {
					ls = {"BOTTOM", "UIParent", "BOTTOM", -286, 256},
					traditional = {"BOTTOM", "UIParent", "BOTTOM", -286, 256},
				},
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
					runes = {
						color_by_spec = true,
						sort_order = "none",
					}
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
						anchor = "TextureParent",
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
					cooldown = {
						text = {
							enabled = true,
							size = 10,
							flag = "_Outline", -- "_Shadow", ""
							h_alignment = "CENTER",
							v_alignment = "BOTTOM",
						},
					},
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
		},
		pet = {
			ls = {
				enabled = true,
				width = 42,
				height = 134,
				point = {
					ls = {"RIGHT", "LSPlayerFrame" , "LEFT", -2, 0},
					traditional = {"RIGHT", "LSPlayerFrame" , "LEFT", -2, 0},
				},
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
			traditional = {
				enabled = true,
				width = 112,
				height = 28,
				point = {
					ls = {"BOTTOMRIGHT", "LSPlayerFrame", "BOTTOMLEFT", -12, 0},
					traditional = {"BOTTOMRIGHT", "LSPlayerFrame", "BOTTOMLEFT", -12, 0},
				},
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
					npc = false,
				},
			},
		},
		target = {
			enabled = true,
			width = 250,
			height = 52,
			point = {
				ls = {"BOTTOM", "UIParent", "BOTTOM", 286, 336},
				traditional = {"BOTTOM", "UIParent", "BOTTOM", 286, 256},
			},
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
					anchor = "TextureParent",
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
				cooldown = {
					text = {
						enabled = true,
						size = 10,
						flag = "_Outline", -- "_Shadow", ""
						h_alignment = "CENTER",
						v_alignment = "BOTTOM",
					},
				},
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
			point = {
				ls = {"BOTTOMLEFT", "LSTargetFrame", "BOTTOMRIGHT", 12, 0},
				traditional = {"BOTTOMLEFT", "LSTargetFrame", "BOTTOMRIGHT", 12, 0},
			},
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
			point = {
				ls = {"BOTTOM", "UIParent", "BOTTOM", -286, 336},
				traditional = {"BOTTOM", "UIParent", "BOTTOM", 286, 480},
			},
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
					anchor = "TextureParent",
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
				cooldown = {
					text = {
						enabled = true,
						size = 10,
						flag = "_Outline", -- "_Shadow", ""
						h_alignment = "CENTER",
						v_alignment = "BOTTOM",
					},
				},
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
			point = {
				ls = {"BOTTOMRIGHT", "LSFocusFrame", "BOTTOMLEFT", -12, 0},
				traditional = {"BOTTOMRIGHT", "LSFocusFrame", "BOTTOMLEFT", -12, 0},
			},
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
			point = {
				ls = {"TOPRIGHT", "UIParent", "TOPRIGHT", -82, -268},
				traditional = {"TOPRIGHT", "UIParent", "TOPRIGHT", -82, -268},
			},
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
				cooldown = {
					text = {
						enabled = true,
						size = 10,
						flag = "_Outline", -- "_Shadow", ""
						h_alignment = "CENTER",
						v_alignment = "BOTTOM",
					},
				},
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
				position = 2, -- 0 - zone text, 1 - clock, 2 - bottom
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
		colors = {
			contested = {250 / 255, 193 / 255, 74 / 255},
			friendly = {85 / 255, 240 / 255, 83 / 255},
			hostile = {240 / 255, 72 / 255, 63 / 255},
			sanctuary = {105 / 255, 204 / 255, 240 / 255},
		},
		color = {
			border = false,
			zone_text = true,
		},
	},
	bars = {
		mana_indicator = "button", -- hotkey
		range_indicator = "button", -- hotkey
		lock = true, -- watch: LOCK_ACTIONBAR
		rightclick_selfcast = false,
		click_on_down = false,
		draw_bling = true,
		blizz_vehicle = false,
		cooldown = {
			exp_threshold = 5,
			m_ss_threshold = 120, -- [91; 3599]
			colors = {
				enabled = true,
				expiration = {229 / 255, 25 / 255, 25 / 255},
				second = {255 / 255, 191 / 255, 25 / 255},
				minute = {255 / 255, 255 / 255, 255 / 255},
				hour = {255 / 255, 255 / 255, 255 / 255},
				day = {255 / 255, 255 / 255, 255 / 255},
			},
		},
		colors = {
			normal = {255 / 255, 255 / 255, 255 / 255},
			unusable = {102 / 255, 102 / 255, 102 / 255},
			mana = {38 / 255, 97 / 255, 172 / 255},
			range = {141 / 255, 28 / 255, 33 / 255},
		},
		desaturation = {
			cooldown = true,
			unusable = true,
			mana = true,
			range = true,
		},
		bar1 = { -- MainMenuBar
			flyout_dir = "UP",
			grid = false,
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
				flag = "_Outline", -- "_Shadow", ""
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			count = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 0,
				y = 20
			},
		},
		bar2 = { -- MultiBarBottomLeft
			flyout_dir = "UP",
			grid = false,
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
				flag = "_Outline", -- "_Shadow", ""
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			count = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 0,
				y = 56
			},
		},
		bar3 = { -- MultiBarBottomRight
			flyout_dir = "UP",
			grid = false,
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
				flag = "_Outline", -- "_Shadow", ""
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			count = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = 0,
				y = 92
			},
		},
		bar4 = { -- MultiBarLeft
			flyout_dir = "LEFT",
			grid = false,
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
				flag = "_Outline", -- "_Shadow", ""
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			count = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
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
			grid = false,
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
				flag = "_Outline", -- "_Shadow", ""
			},
			macro = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			count = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
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
			grid = false,
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
				size = 10,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 10,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
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
				size = 10,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 10,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
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
				flag = "_Outline", -- "_Shadow", ""
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
				size = 14,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 14,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = -168,
				y = 134
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
			cooldown = {
				text = {
					enabled = true,
					size = 14,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
				},
			},
			point = {
				p = "BOTTOM",
				anchor = "UIParent",
				rP = "BOTTOM",
				x = -168,
				y = 178
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
				y = 134
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
			bars = {
				micromenu1 = {
					enabled = true,
					num = 13,
					per_row = 13,
					width = 18,
					height = 24,
					spacing = 4,
					x_growth = "RIGHT",
					y_growth = "DOWN",
					point = {
						p = "BOTTOMRIGHT",
						anchor = "UIParent",
						rP = "BOTTOMRIGHT",
						x = -4,
						y = 4,
					},
				},
				micromenu2 = {
					enabled = true,
					num = 13,
					per_row = 13,
					width = 18,
					height = 24,
					spacing = 4,
					x_growth = "RIGHT",
					y_growth = "DOWN",
				},
				bags = {
					enabled = true,
					num = 4,
					per_row = 4,
					x_growth = "RIGHT",
					y_growth = "DOWN",
					size = 32,
					spacing = 4,
					point = {
						p = "BOTTOMRIGHT",
						anchor = "UIParent",
						rP = "BOTTOMRIGHT",
						x = -4,
						y = 32,
					},
				},
			},
			buttons = {
				character = {
					enabled = true,
					parent = "micromenu1",
					tooltip = false,
				},
				inventory = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
					currency = {},
				},
				spellbook = {
					enabled = true,
					parent = "micromenu1",
				},
				talent = {
					enabled = true,
					parent = "micromenu1",
				},
				achievement = {
					enabled = true,
					parent = "micromenu1",
				},
				quest = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
				},
				guild = {
					enabled = true,
					parent = "micromenu1",
				},
				lfd = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
				},
				collection = {
					enabled = true,
					parent = "micromenu1",
				},
				ej = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
				},
				store = {
					enabled = false,
					parent = "micromenu1",
				},
				main = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
				},
				help = {
					enabled = false,
					parent = "micromenu1",
				},
			},
		},
		xpbar = {
			visible = true,
			width = 594,
			height = 12,
			text = {
				size = 10,
				flag = "_Outline", -- "_Shadow", ""
			},
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
	},
	auras = {
		cooldown = {
			exp_threshold = 5, -- [1; 10]
			m_ss_threshold = 600, -- [91; 3599]
			colors = {
				enabled = true,
				expiration = {229 / 255, 25 / 255, 25 / 255},
				second = {255 / 255, 191 / 255, 25 / 255},
				minute = {255 / 255, 255 / 255, 255 / 255},
				hour = {255 / 255, 255 / 255, 255 / 255},
				day = {255 / 255, 255 / 255, 255 / 255},
			},
		},
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
			count = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "BOTTOM",
				},
			},
			point = {
				ls = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -6,
					y = -6,
				},
				traditional = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -184,
					y = -6,
				},
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
			count = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "BOTTOM",
				},
			},
			point = {
				ls = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -6,
					y = -114,
				},
				traditional = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -184,
					y = -114,
				},
			},
		},
		TOTEM = {
			num = 4,
			size = 32,
			spacing = 4,
			x_growth = "LEFT",
			y_growth = "DOWN",
			per_row = 4,
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					flag = "_Outline", -- "_Shadow", ""
					h_alignment = "CENTER",
					v_alignment = "BOTTOM",
				},
			},
			point = {
				ls = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -4,
					y = -148,
				},
				traditional = {
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
		anchor_cursor = false,
		point = {
			p = "BOTTOMRIGHT",
			anchor = "UIParent",
			rP = "BOTTOMRIGHT",
			x = -76,
			y = 126,
		},
	},
	blizzard = {
		castbar = { -- CastingBarFrame, PetCastingBarFrame
			width = 200,
			height = 12,
			icon = {
				enabled = true,
				position = "LEFT",
			},
			text = {
				size = 12,
				flag = "_Shadow", -- "_Outline", ""
			},
			show_pet = -1, -- -1 - auto, 0 - false, 1 - true
			latency = true,
		},
		digsite_bar = { -- ArcheologyDigsiteProgressBar
			width = 200,
			height = 12,
			text = {
				size = 12,
				flag = "_Shadow", -- "_Outline", ""
			},
		},
		timer = { -- MirrorTimer*, TimerTrackerTimer*
			width = 200,
			height = 12,
			text = {
				size = 12,
				flag = "_Shadow", -- "_Outline", ""
			},
		},
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
	layout = "ls", -- or "traditional"
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
		count = {
			enabled = true,
			size = 12,
			flag = "_Outline", -- "_Shadow", ""
		},
		cooldown = {
			exp_threshold = 5, -- [1; 10]
			m_ss_threshold = 0, -- [91; 3599]
			colors = {
				enabled = true,
				expiration = {229 / 255, 25 / 255, 25 / 255},
				second = {255 / 255, 191 / 255, 25 / 255},
				minute = {255 / 255, 255 / 255, 255 / 255},
				hour = {255 / 255, 255 / 255, 255 / 255},
				day = {255 / 255, 255 / 255, 255 / 255},
			},
			text = {
				enabled = true,
				size = 12,
				flag = "_Outline", -- "_Shadow", ""
				h_alignment = "CENTER",
				v_alignment = "BOTTOM",
			}
		},
		filter = {
			HELPFUL = {},
			HARMFUL = {},
			ALL = {},
		},
	},
	bars = {
		enabled = true,
		restricted = true,
		pet_battle = {
			enabled = false,
		},
		xpbar = {
			enabled = true,
		},
	},
	blizzard = {
		enabled = true,
		castbar = { -- CastingBarFrame
			enabled = true
		},
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
	loot = {
		enabled = true,
	},
}
