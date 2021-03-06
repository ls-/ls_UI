local _, ns = ...
local E, C, M, L, P, D, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D, ns.oUF
local CONFIG = P:GetModule("Config")
local UNITFRAMES = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_wipe = _G.table.wipe
local s_split = _G.string.split

-- Mine
local offsets = {"", "   ", "      "}
local function d(c, o, v)
	print(offsets[o].."|cff"..c..v.."|r")
end

local orders = {0, 0, 0}

local function reset(order)
	orders[order] = 1
	-- d("d20000", order, orders[order])
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	-- d("00d200", order, orders[order])
	return orders[order]
end

local customAuraFilters = {}
do
	local filterCache = {}

	function CONFIG:CreateUnitFrameAuraFilters()
		t_wipe(customAuraFilters)

		local index = 1
		for filter in next, C.db.global.aura_filters do
			if not filterCache[filter] then
				filterCache[filter] = {
					type = "toggle",
					name = filter,
				}
			end

			filterCache[filter].order = index

			customAuraFilters[filter] = filterCache[filter]

			index = index + 1
		end
	end
end

local FILTERS = {
	friendly = {
		-- name = L["FRIENDLY_UNITS"],
		name = function() return "|c" .. C.db.global.colors.green.hex .. L["FRIENDLY_UNITS"] .. "|r" end,
	},
	enemy = {
		-- name = L["ENEMY_UNITS"],
		name = function() return "|c" .. C.db.global.colors.red.hex .. L["ENEMY_UNITS"] .. "|r" end,
	},
	buff = {
		boss = {
			order = 1,
			type = "toggle",
			name = L["BOSS_BUFFS"],
			desc = L["BOSS_BUFFS_DESC"],
		},
		tank = {
			order = 2,
			type = "toggle",
			name = L["TANK_BUFFS"],
			desc = L["TANK_BUFFS_DESC"],
		},
		healer = {
			order = 3,
			type = "toggle",
			name = L["HEALER_BUFFS"],
			desc = L["HEALER_BUFFS_DESC"],
		},
		mount = {
			order = 4,
			type = "toggle",
			name = L["MOUNT_AURAS"],
			desc = L["MOUNT_AURAS_DESC"],
		},
		selfcast = {
			order = 5,
			type = "toggle",
			name = L["SELF_BUFFS"],
			desc = L["SELF_BUFFS_DESC"],
		},
		selfcast_permanent = {
			order = 6,
			type = "toggle",
			name = L["SELF_BUFFS_PERMA"],
			desc = L["SELF_BUFFS_PERMA_DESC"],
			disabled = function(info)
				return not C.db.profile.units[info[#info - 5]].auras.filter[info[#info - 2]][info[#info - 1]].selfcast
			end,
		},
		player = {
			order = 7,
			type = "toggle",
			name = L["CASTABLE_BUFFS"],
			desc = L["CASTABLE_BUFFS_DESC"],
		},
		player_permanent = {
			order = 8,
			type = "toggle",
			name = L["CASTABLE_BUFFS_PERMA"],
			desc = L["CASTABLE_BUFFS_PERMA_DESC"],
			disabled = function(info)
				return not C.db.profile.units[info[#info - 5]].auras.filter[info[#info - 2]][info[#info - 1]].player
			end,
		},
		misc = {
			order = 9,
			type = "toggle",
			name = L["MISC"],
		},
	},
	debuff = {
		boss = {
			order = 1,
			type = "toggle",
			name = L["BOSS_DEBUFFS"],
			desc = L["BOSS_DEBUFFS_DESC"],
		},
		tank = {
			order = 2,
			type = "toggle",
			name = L["TANK_DEBUFFS"],
			desc = L["TANK_DEBUFFS_DESC"],
		},
		healer = {
			order = 3,
			type = "toggle",
			name = L["HEALER_DEBUFFS"],
			desc = L["HEALER_DEBUFFS_DESC"],
		},
		selfcast = {
			order = 4,
			type = "toggle",
			name = L["SELF_DEBUFFS"],
			desc = L["SELF_DEBUFFS_DESC"],
		},
		selfcast_permanent = {
			order = 5,
			type = "toggle",
			name = L["SELF_DEBUFFS_PERMA"],
			desc = L["SELF_DEBUFFS_PERMA_DESC"],
			disabled = function(info)
				return not C.db.profile.units[info[#info - 5]].auras.filter[info[#info - 2]][info[#info - 1]].selfcast
			end,
		},
		player = {
			order = 6,
			type = "toggle",
			name = L["CASTABLE_DEBUFFS"],
			desc = L["CASTABLE_DEBUFFS_DESC"],
		},
		player_permanent = {
			order = 7,
			type = "toggle",
			name = L["CASTABLE_DEBUFFS_PERMA"],
			desc = L["CASTABLE_DEBUFFS_PERMA_DESC"],
			disabled = function(info)
				return not C.db.profile.units[info[#info - 5]].auras.filter[info[#info - 2]][info[#info - 1]].player
			end,
		},
		dispellable = {
			order = 8,
			type = "toggle",
			name = L["DISPELLABLE_DEBUFFS"],
			desc = L["DISPELLABLE_DEBUFFS_DESC"],
		},
		misc = {
			order = 9,
			type = "toggle",
			name = L["MISC"],
		},
	},
}

local function getFilters(order, unit, type)
	local temp

	if C.db.profile.units[unit].auras.filter[type] then
		temp = {
			order = order,
			type = "group",
			inline = true,
			name = FILTERS[type].name,
			args = {},
		}

		if C.db.profile.units[unit].auras.filter[type].buff then
			temp.args.buff = {
				order = reset(3),
				type = "group",
				name = "",
				inline = true,
				args = {},
			}

			for k in next, C.db.profile.units[unit].auras.filter[type].buff do
				temp.args.buff.args[k] = FILTERS.buff[k]
			end

			if C.db.profile.units[unit].auras.filter[type].debuff then
				temp.args.spacer_1 = {
					order = inc(3),
					type = "description",
					name = " ",
				}
			end
		end

		if C.db.profile.units[unit].auras.filter[type].debuff then
			temp.args.debuff = {
				order = inc(3),
				type = "group",
				name = "",
				inline = true,
				args = {},
			}

			for k in next, C.db.profile.units[unit].auras.filter[type].debuff do
				temp.args.debuff.args[k] = FILTERS.debuff[k]
			end
		end
	end

	return temp
end

local copyIgnoredKeys = {
	["filter"] = true,
}

local resetIgnoredKeys = {
	["filter"] = true,
}

function CONFIG:CreateUnitFrameAurasPanel(order, unit)
	local ignoredUnits = {
		["player"] = E.UI_LAYOUT == "ls",
		["pet"] = E.UI_LAYOUT == "ls",
		["targettarget"] = true,
		["focustarget"] = true,
		[unit] = true,
	}

	return {
		order = order,
		type = "group",
		name = L["AURAS"],
		get = function(info)
			return C.db.profile.units[unit].auras[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].auras[info[#info]] ~= value then
				C.db.profile.units[unit].auras[info[#info]] = value

				UNITFRAMES:For(unit, "UpdateAuras")
			end
		end,
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
			},
			copy = {
				order = inc(1),
				type = "select",
				name = L["COPY_FROM"],
				desc = L["COPY_FROM_DESC"],
				values = function()
					return UNITFRAMES:GetUnits(ignoredUnits)
				end,
				get = function() end,
				set = function(_, value)
					CONFIG:CopySettings(C.db.profile.units[value].auras, C.db.profile.units[unit].auras, copyIgnoredKeys)
					UNITFRAMES:For(unit, "UpdateAuras")
				end,
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].auras, C.db.profile.units[unit].auras, resetIgnoredKeys)
					UNITFRAMES:For(unit, "UpdateAuras")
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			disable_mouse = {
				order = inc(1),
				type = "toggle",
				name = L["DISABLE_MOUSE"],
				desc = L["DISABLE_MOUSE_DESC"],
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			rows = {
				order = inc(1),
				type = "range",
				name = L["NUM_ROWS"],
				min = 1, max = 4, step = 1,
				set = function(_, value)
					if C.db.profile.units[unit].auras.rows ~= value then
						C.db.profile.units[unit].auras.rows = value

						UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Auras", "UpdateSize")
						UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
					end
				end,
			},
			per_row = {
				order = inc(1),
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 10, step = 1,
				set = function(_, value)
					if C.db.profile.units[unit].auras.per_row ~= value then
						C.db.profile.units[unit].auras.per_row = value

						UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Auras", "UpdateSize")
						UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
					end
				end,
			},
			size_override = {
				order = inc(1),
				type = "range",
				name = L["SIZE_OVERRIDE"],
				desc = L["SIZE_OVERRIDE_DESC"],
				min = 0, max = 64, step = 1,
				softMin = 24,
				set = function(info, value)
					if C.db.profile.units[unit].auras.size_override ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end

						C.db.profile.units[unit].auras.size_override = value

						UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Auras", "UpdateSize")
						UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
					end
				end,
			},
			growth_dir = {
				order = inc(1),
				type = "select",
				name = L["GROWTH_DIR"],
				values = CONFIG.GROWTH_DIRS,
				get = function()
					return C.db.profile.units[unit].auras.x_growth .. "_" .. C.db.profile.units[unit].auras.y_growth
				end,
				set = function(_, value)
					C.db.profile.units[unit].auras.x_growth, C.db.profile.units[unit].auras.y_growth = s_split("_", value)

					UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
					UNITFRAMES:For(unit, "For", "Auras", "UpdateGrowthDirection")
				end,
			},
			spacer_3 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			point = {
				order = inc(1),
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.point1[info[#info]] ~= value then
						C.db.profile.units[unit].auras.point1[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Auras", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = reset(2),
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS,
					},
					rP = {
						order = inc(2),
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
					},
					x = {
						order = inc(2),
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = inc(2),
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
				},
			},
			spacer_4 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			type = {
				order = inc(1),
				type = "group",
				name = L["AURA_TYPE"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.type[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.type[info[#info]] ~= value then
						C.db.profile.units[unit].auras.type[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Auras", "UpdateAuraTypeIcon")
					end
				end,
				args = {
					debuff_type = {
						order = reset(2),
						type = "toggle",
						name = L["DEBUFF_TYPE"],
					},
					size = {
						order = reset(2),
						type = "range",
						name = L["SIZE"],
						min = 10, max = 32, step = 2,
					},
					position = {
						order = reset(2),
						type = "select",
						name = L["POINT"],
						values = CONFIG.POINTS,
					},
				},
			},
			spacer_5 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			count = {
				order = inc(1),
				type = "group",
				name = L["COUNT_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.count[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.count[info[#info]] ~= value then
						C.db.profile.units[unit].auras.count[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Auras", "UpdateFonts")
					end
				end,
				args = {
					size = {
						order = reset(2),
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					h_alignment = {
						order = inc(2),
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = CONFIG.H_ALIGNMENTS,
					},
					v_alignment = {
						order = inc(2),
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = CONFIG.V_ALIGNMENTS,
					},
				},
			},
			spacer_6 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			cooldown = {
				order = inc(1),
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.cooldown.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.cooldown.text[info[#info]] ~= value then
						C.db.profile.units[unit].auras.cooldown.text[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Auras", "UpdateCooldownConfig")
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
					},
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					v_alignment = {
						order = 4,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = CONFIG.V_ALIGNMENTS,
					},
				},
			},
			spacer_7 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			filter = {
				order = inc(1),
				type = "group",
				name = L["FILTERS"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]] ~= value then
						C.db.profile.units[unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]] = value

						UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
					end
				end,
				args = {
					copy = {
						order = reset(2),
						type = "select",
						name = L["COPY_FROM"],
						desc = L["COPY_FROM_DESC"],
						values = function()
							return UNITFRAMES:GetUnits(ignoredUnits)
						end,
						get = function() end,
						set = function(_, value)
							CONFIG:CopySettings(C.db.profile.units[value].auras.filter, C.db.profile.units[unit].auras.filter)
							UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
							UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
						end,
					},
					reset = {
						type = "execute",
						order = inc(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.units[unit].auras.filter, C.db.profile.units[unit].auras.filter)
							UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
							UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
						end,
					},
					custom = {
						order = inc(2),
						type = "group",
						inline = true,
						name = L["USER_CREATED"],
						get = function(info)
							return C.db.profile.units[unit].auras.filter[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].auras.filter[info[#info - 1]][info[#info]] ~= value then
								C.db.profile.units[unit].auras.filter[info[#info - 1]][info[#info]] = value

								UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
								UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
							end
						end,
						args = customAuraFilters,
					},
					friendly = getFilters(inc(2), unit, "friendly"),
					enemy = getFilters(inc(2), unit, "enemy"),
				},
			},
		},
	}
end
