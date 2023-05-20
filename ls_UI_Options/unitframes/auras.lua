-- Lua
local _G = getfenv(0)
local next = _G.next
local s_split = _G.string.split
local t_wipe = _G.table.wipe
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
local UNITFRAMES = P:GetModule("UnitFrames")

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local customAuraFilters = {}
do
	local filterCache = {}

	function CONFIG:UpdateUnitFrameAuraFilters()
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
		name = function() return C.db.global.colors.green:WrapTextInColorCode(L["FRIENDLY_UNITS"]) end,
	},
	enemy = {
		name = function() return C.db.global.colors.red:WrapTextInColorCode(L["ENEMY_UNITS"]) end,
	},
	buff = {
		boss = {
			order = reset(1),
			type = "toggle",
			name = L["BOSS_BUFFS"],
			desc = L["BOSS_BUFFS_DESC"],
		},
		tank = {
			order = inc(1),
			type = "toggle",
			name = L["TANK_BUFFS"],
			desc = L["TANK_BUFFS_DESC"],
		},
		healer = {
			order = inc(1),
			type = "toggle",
			name = L["HEALER_BUFFS"],
			desc = L["HEALER_BUFFS_DESC"],
		},
		mount = {
			order = inc(1),
			type = "toggle",
			name = L["MOUNT_AURAS"],
			desc = L["MOUNT_AURAS_DESC"],
		},
		selfcast = {
			order = inc(1),
			type = "toggle",
			name = L["SELF_BUFFS"],
			desc = L["SELF_BUFFS_DESC"],
		},
		selfcast_permanent = {
			order = inc(1),
			type = "toggle",
			name = L["SELF_BUFFS_PERMA"],
			desc = L["SELF_BUFFS_PERMA_DESC"],
			disabled = function(info)
				return not C.db.profile.units[info[#info - 5]].auras.filter[info[#info - 2]][info[#info - 1]].selfcast
			end,
		},
		player = {
			order = inc(1),
			type = "toggle",
			name = L["CASTABLE_BUFFS"],
			desc = L["CASTABLE_BUFFS_DESC"],
		},
		player_permanent = {
			order = inc(1),
			type = "toggle",
			name = L["CASTABLE_BUFFS_PERMA"],
			desc = L["CASTABLE_BUFFS_PERMA_DESC"],
			disabled = function(info)
				return not C.db.profile.units[info[#info - 5]].auras.filter[info[#info - 2]][info[#info - 1]].player
			end,
		},
		misc = {
			order = inc(1),
			type = "toggle",
			name = L["MISC"],
		},
	},
	debuff = {
		boss = {
			order = reset(1),
			type = "toggle",
			name = L["BOSS_DEBUFFS"],
			desc = L["BOSS_DEBUFFS_DESC"],
		},
		tank = {
			order = inc(1),
			type = "toggle",
			name = L["TANK_DEBUFFS"],
			desc = L["TANK_DEBUFFS_DESC"],
		},
		healer = {
			order = inc(1),
			type = "toggle",
			name = L["HEALER_DEBUFFS"],
			desc = L["HEALER_DEBUFFS_DESC"],
		},
		selfcast = {
			order = inc(1),
			type = "toggle",
			name = L["SELF_DEBUFFS"],
			desc = L["SELF_DEBUFFS_DESC"],
		},
		selfcast_permanent = {
			order = inc(1),
			type = "toggle",
			name = L["SELF_DEBUFFS_PERMA"],
			desc = L["SELF_DEBUFFS_PERMA_DESC"],
			disabled = function(info)
				return not C.db.profile.units[info[#info - 5]].auras.filter[info[#info - 2]][info[#info - 1]].selfcast
			end,
		},
		player = {
			order = inc(1),
			type = "toggle",
			name = L["CASTABLE_DEBUFFS"],
			desc = L["CASTABLE_DEBUFFS_DESC"],
		},
		player_permanent = {
			order = inc(1),
			type = "toggle",
			name = L["CASTABLE_DEBUFFS_PERMA"],
			desc = L["CASTABLE_DEBUFFS_PERMA_DESC"],
			disabled = function(info)
				return not C.db.profile.units[info[#info - 5]].auras.filter[info[#info - 2]][info[#info - 1]].player
			end,
		},
		dispellable = {
			order = inc(1),
			type = "toggle",
			name = L["DISPELLABLE_DEBUFFS"],
			desc = L["DISPELLABLE_DEBUFFS_DESC"],
		},
		misc = {
			order = inc(1),
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

function CONFIG:CreateUnitFrameAurasOptions(order, unit)
	local ignoredUnits = {
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
			width = {
				order = inc(1),
				type = "range",
				name = L["WIDTH"],
				desc = L["WIDTH_OVERRIDE_DESC"],
				min = 0, max = 64, step = 1,
				softMin = 16,
				set = function(info, value)
					if C.db.profile.units[unit].auras.width ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end
					end

					C.db.profile.units[unit].auras.width = value

					UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
					UNITFRAMES:For(unit, "For", "Auras", "UpdateSize")
					UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
				end,
			},
			height = {
				order = inc(1),
				type = "range",
				name = L["HEIGHT"],
				desc = L["HEIGHT_OVERRIDE_DESC"],
				min = 0, max = 64, step = 1,
				softMin = 16,
				set = function(info, value)
					if C.db.profile.units[unit].auras.height ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end
					end

					C.db.profile.units[unit].auras.height = value

					UNITFRAMES:For(unit, "For", "Auras", "UpdateConfig")
					UNITFRAMES:For(unit, "For", "Auras", "UpdateSize")
					UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
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
						UNITFRAMES:For(unit, "For", "Auras", "ForceUpdate")
					end
				end,
				args = {
					enabled = {
						order = reset(2),
						type = "toggle",
						name = L["SHOW"],
					},
					size = {
						order = inc(2),
						type = "range",
						name = L["SIZE"],
						min = 10, max = 32, step = 2,
					},
					position = {
						order = inc(2),
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
