-- Lua
local _G = getfenv(0)
local s_split = _G.string.split
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
local AURAS = P:GetModule("Auras")

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local H_ALIGNMENTS = {
	["CENTER"] = "CENTER",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
}

local V_ALIGNMENTS = {
	["BOTTOM"] = "BOTTOM",
	["MIDDLE"] = "MIDDLE",
	["TOP"] = "TOP",
}

local GROWTH_DIRS = {
	["LEFT_DOWN"] = L["LEFT_DOWN"],
	["LEFT_UP"] = L["LEFT_UP"],
	["RIGHT_DOWN"] = L["RIGHT_DOWN"],
	["RIGHT_UP"] = L["RIGHT_UP"],
}

local SORT_METHODS = {
	["INDEX"] = L["INDEX"],
	["NAME"] = L["NAME"],
	["TIME"] = L["TIME"],
}

local SORT_DIRS = {
	["+"] = L["ASCENDING"],
	["-"] = L["DESCENDING"],
}

local SEP_TYPES = {
	[-1] = L["OTHERS_FIRST"],
	[0] = L["NO_SEPARATION"],
	[1] = L["YOURS_FIRST"],
}

local POINTS = {
	["BOTTOM"] = "BOTTOM",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	["CENTER"] = "CENTER",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
	["TOP"] = "TOP",
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
}

local function isModuleDisabled()
	return not AURAS:IsInit()
end

local function isModuleDisabledOrOCCEnabled()
	return isModuleDisabled() or E.OMNICC
end

local function getAuraOptions(order, name, filter)
	local temp = {
		order = order,
		type = "group",
		name = name,
		disabled = isModuleDisabled,
		get = function(info)
			return C.db.profile.auras[filter][info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.auras[filter][info[#info]] ~= value then
				C.db.profile.auras[filter][info[#info]] = value

				AURAS:For(filter, "Update")
			end
		end,
		args = {
			reset = {
				type = "execute",
				order = reset(2),
				name = L["RESET_TO_DEFAULT"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.auras[filter], C.db.profile.auras[filter], {point = true})

					AURAS:For(filter, "Update")
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(2)),
			num_rows = {
				order = inc(2),
				type = "range",
				name = L["ROWS"],
				min = 1, max = 40, step = 1,
			},
			num = {
				order = inc(2),
				type = "range",
				name = L["NUM_BUTTONS"],
				min = 1, max = 4, step = 1,
			},
			per_row = {
				order = inc(2),
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 40, step = 1,
			},
			spacing = {
				order = inc(2),
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 1,
			},
			width = {
				order = inc(2),
				type = "range",
				name = L["WIDTH"],
				min = 16, max = 64, step = 1,
			},
			height = {
				order = inc(2),
				type = "range",
				name = L["HEIGHT"],
				desc = L["HEIGHT_OVERRIDE_DESC"],
				min = 0, max = 64, step = 1,
				softMin = 16,
				set = function(info, value)
					if C.db.profile.auras[filter].height ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end
					end

					C.db.profile.auras[filter].height = value

					AURAS:For(filter, "Update")
				end,
			},
			growth_dir = {
				order = inc(2),
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.auras[filter].x_growth .. "_" .. C.db.profile.auras[filter].y_growth
				end,
				set = function(_, value)
					C.db.profile.auras[filter].x_growth, C.db.profile.auras[filter].y_growth = s_split("_", value)

					AURAS:For(filter, "Update")
				end,
			},
			sort_method = {
				order = inc(2),
				type = "select",
				name = L["SORT_METHOD"],
				values = SORT_METHODS,
			},
			sort_dir = {
				order = inc(2),
				type = "select",
				name = L["SORT_DIR"],
				values = SORT_DIRS,
			},
			sep_own = {
				order = inc(2),
				type = "select",
				name = L["SEPARATION"],
				values = SEP_TYPES
			},
			spacer_2 = CONFIG:CreateSpacer(inc(2)),
			type = {
				order = inc(2),
				type = "group",
				name = L["AURA_TYPE"],
				inline = true,
				get = function(info)
					return C.db.profile.auras[filter].type[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.auras[filter].type[info[#info]] ~= value then
						C.db.profile.auras[filter].type[info[#info]] = value

						AURAS:For(filter, "UpdateConfig")
						AURAS:For(filter, "ForEachButton", "UpdateAuraTypeIcon")
					end
				end,
				args = {
					enabled = {
						order = reset(3),
						type = "toggle",
						name = L["SHOW"],
					},
					size = {
						order = inc(3),
						type = "range",
						name = L["SIZE"],
						min = 10, max = 32, step = 2,
					},
					position = {
						order = inc(3),
						type = "select",
						name = L["POINT"],
						values = POINTS,
					},
				},
			},
			spacer_3 = CONFIG:CreateSpacer(inc(2)),
			count = {
				order = inc(2),
				type = "group",
				name = L["COUNT_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.auras[filter].count[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.auras[filter].count[info[#info]] ~= value then
						C.db.profile.auras[filter].count[info[#info]] = value

						AURAS:For(filter, "UpdateConfig")
						AURAS:For(filter, "ForEachButton", "UpdateCountFont")
					end
				end,
				args = {
					size = {
						order = reset(3),
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					h_alignment = {
						order = inc(3),
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = H_ALIGNMENTS,
					},
					v_alignment = {
						order = inc(3),
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = V_ALIGNMENTS,
					},
				},
			},
			spacer_4 = CONFIG:CreateSpacer(inc(2)),
			cooldown = {
				order = inc(2),
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				disabled = isModuleDisabledOrOCCEnabled,
				get = function(info)
					return C.db.profile.auras[filter].cooldown.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.auras[filter].cooldown.text[info[#info]] ~= value then
						C.db.profile.auras[filter].cooldown.text[info[#info]] = value

						AURAS:For(filter, "UpdateConfig")
						AURAS:For(filter, "UpdateCooldownConfig")
					end
				end,
				args = {
					enabled = {
						order = reset(3),
						type = "toggle",
						name = L["SHOW"],
					},
					size = {
						order = inc(3),
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					v_alignment = {
						order = inc(3),
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = V_ALIGNMENTS,
					},
				},
			},
		},
	}

	if filter == "TOTEM" then
		temp.args.num_rows = nil
		temp.args.per_row.max = 4
		temp.args.sep_own = nil
		temp.args.sort_dir = nil
		temp.args.sort_method = nil
		temp.args.count = nil
		temp.args.type = nil
		temp.args.spacer_3 = nil
		temp.args.spacer_4 = nil
	elseif filter == "HELPFUL" then
		temp.args.num = nil
		temp.args.type = nil
		temp.args.spacer_3 = nil
	elseif filter == "HARMFUL" then
		temp.args.num = nil
	end

	return temp
end

function CONFIG:CreateAurasOptions(order)
	CONFIG.options.args.auras = {
		order = order,
		type = "group",
		name = L["BUFFS_AND_DEBUFFS"],
		childGroups = "tab",
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["ENABLE"]),
				get = function()
					return PrC.db.profile.auras.enabled
				end,
				set = function(_, value)
					PrC.db.profile.auras.enabled = value

					if AURAS:IsInit() then
						CONFIG:AskToReloadUI("auras.enabled", value)
					else
						if value then
							P:Call(AURAS.Init, AURAS)
						end
					end
				end,
			},
			masque = {
				order = inc(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting("Enable Masque"),
				disabled = not _G.Masque,
				get = function()
					return PrC.db.profile.auras.masque
				end,
				set = function(_, value)
					PrC.db.profile.auras.masque = value

					if _G.Masque then
						AURAS:ForEach("Update")
						CONFIG:AskToReloadUI("auras.masque", false)
					end
				end,
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESET_TO_DEFAULT"],
				disabled = isModuleDisabled,
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.auras, C.db.profile.auras, {point = true})

					AURAS:ForEach("Update")
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			cooldown = {
				order = inc(1),
				type = "group",
				name = L["COOLDOWN"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.auras.cooldown[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.auras.cooldown[info[#info]] ~= value then
						C.db.profile.auras.cooldown[info[#info]] = value

						AURAS:ForEach("UpdateConfig")
						AURAS:ForEach("UpdateCooldownConfig")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESET_TO_DEFAULT"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.auras.cooldown, C.db.profile.auras.cooldown)

							AURAS:ForEach("UpdateConfig")
							AURAS:ForEach("UpdateCooldownConfig")
						end,
					},
					spacer_1 = CONFIG:CreateSpacer(inc(2)),
					exp_threshold = {
						order = inc(2),
						type = "range",
						name = L["EXP_THRESHOLD"],
						min = 1, max = 10, step = 1,
						disabled = isModuleDisabledOrOCCEnabled,
					},
					m_ss_threshold = {
						order = inc(2),
						type = "range",
						name = L["M_SS_THRESHOLD"],
						desc = L["M_SS_THRESHOLD_DESC"],
						min = 0, max = 3599, step = 1,
						softMin = 91,
						disabled = isModuleDisabledOrOCCEnabled,
						set = function(info, value)
							if C.db.profile.auras.cooldown[info[#info]] ~= value then
								if value < info.option.softMin then
									value = info.option.min
								end

								C.db.profile.auras.cooldown[info[#info]] = value

								AURAS:ForEach("UpdateConfig")
								AURAS:ForEach("UpdateCooldownConfig")
							end
						end,
					},
					s_ms_threshold = {
						order = inc(2),
						type = "range",
						name = L["S_MS_THRESHOLD"],
						desc = L["S_MS_THRESHOLD_DESC"],
						min = 1, max = 10, step = 1,
						disabled = isModuleDisabledOrOCCEnabled,
					},
					spacer_2 = CONFIG:CreateSpacer(inc(2)),
					swipe = {
						order = inc(2),
						type = "group",
						name = L["COOLDOWN_SWIPE"],
						inline = true,
						get = function(info)
							return C.db.profile.auras.cooldown.swipe[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.auras.cooldown.swipe[info[#info]] ~= value then
								C.db.profile.auras.cooldown.swipe[info[#info]] = value

								AURAS:ForEach("UpdateConfig")
								AURAS:ForEach("UpdateCooldownConfig")
							end
						end,
						args = {
							enabled = {
								order = reset(3),
								type = "toggle",
								name = L["SHOW"],
							},
							reversed = {
								order = inc(3),
								type = "toggle",
								disabled = function()
									return isModuleDisabledOrOCCEnabled() or not C.db.profile.auras.cooldown.swipe.enabled
								end,
								name = L["REVERSE"],
							},
						},
					},
				},
			},
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			buffs = getAuraOptions(inc(1), L["BUFFS"], "HELPFUL"),
			debuffs = getAuraOptions(inc(1), L["DEBUFFS"], "HARMFUL"),
			totems = getAuraOptions(inc(1), L["TOTEMS"], "TOTEM"),
		},
	}
end
