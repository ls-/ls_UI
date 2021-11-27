local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local AURAS = P:GetModule("Auras")
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)
local s_split = _G.string.split

-- Mine
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

local FLAGS = {
	-- [""] = L["NONE"],
	["_Outline"] = L["OUTLINE"],
	["_Shadow"] = L["SHADOW"],
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

local function getOptionsTable_Aura(order, name, filter)
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
				AURAS:ForHeader(filter, "Update")
			end
		end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.auras[filter], C.db.profile.auras[filter], {point = true})
					AURAS:ForHeader(filter, "Update")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			num_rows = {
				order = 10,
				type = "range",
				name = L["ROWS"],
				min = 1, max = 40, step = 1,
			},
			per_row = {
				order = 11,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 40, step = 1,
			},
			spacing = {
				order = 12,
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 2,
			},
			size = {
				order = 13,
				type = "range",
				name = L["SIZE"],
				min = 24, max = 64, step = 1,
			},
			growth_dir = {
				order = 14,
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.auras[filter].x_growth .. "_" .. C.db.profile.auras[filter].y_growth
				end,
				set = function(_, value)
					C.db.profile.auras[filter].x_growth, C.db.profile.auras[filter].y_growth = s_split("_", value)
					AURAS:ForHeader(filter, "Update")
				end,
			},
			sort_method = {
				order = 15,
				type = "select",
				name = L["SORT_METHOD"],
				values = SORT_METHODS,
			},
			sort_dir = {
				order = 16,
				type = "select",
				name = L["SORT_DIR"],
				values = SORT_DIRS,
			},
			sep_own = {
				order = 17,
				type = "select",
				name = L["SEPARATION"],
				values = SEP_TYPES
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			type = {
				order = 20,
				type = "group",
				name = "Aura Type",
				inline = true,
				get = function(info)
					return C.db.profile.auras[filter].type[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.auras[filter].type[info[#info]] ~= value then
						C.db.profile.auras[filter].type[info[#info]] = value
						AURAS:ForHeader(filter, "UpdateConfig")
						AURAS:ForHeader(filter, "ForEachButton", "UpdateAuraTypeIcon")
					end
				end,
				args = {
					debuff_type = {
						order = 1,
						type = "toggle",
						name = "Debuff Type",
					},
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 10, max = 32, step = 2,
					},
					position = {
						order = 3,
						type = "select",
						name = L["POINT"],
						values = POINTS,
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			count = {
				order = 30,
				type = "group",
				name = L["COUNT_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.auras[filter].count[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.auras[filter].count[info[#info]] ~= value then
						C.db.profile.auras[filter].count[info[#info]] = value
						AURAS:ForHeader(filter, "UpdateConfig")
						AURAS:ForHeader(filter, "ForEachButton", "UpdateCountFont")
					end
				end,
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					h_alignment = {
						order = 3,
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = H_ALIGNMENTS,
					},
					v_alignment = {
						order = 4,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = V_ALIGNMENTS,
					},
				},
			},
			spacer_4 = {
				order = 39,
				type = "description",
				name = " ",
			},
			cooldown = {
				order = 40,
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.auras[filter].cooldown.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.auras[filter].cooldown.text[info[#info]] ~= value then
						C.db.profile.auras[filter].cooldown.text[info[#info]] = value
						AURAS:ForHeader(filter, "UpdateConfig")
						AURAS:ForHeader(filter, "UpdateCooldownConfig")
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
						values = V_ALIGNMENTS,
					},
				},
			},
		},
	}

	if filter == "TOTEM" then
		temp.args.num_rows = nil
		temp.args.sep_own = nil
		temp.args.sort_dir = nil
		temp.args.sort_method = nil
		temp.args.count = nil
		temp.args.type = nil
		temp.args.spacer_3 = nil
		temp.args.spacer_4 = nil

		temp.args.num = {
			order = 10,
			type = "range",
			name = L["NUM_BUTTONS"],
			min = 1, max = 4, step = 1,
		}
	elseif filter == "HELPFUL" then
		temp.args.type = nil
		temp.args.spacer_3 = nil
	end

	return temp
end

function CONFIG.CreateAurasPanel(_, order)
	C.options.args.auras = {
		order = order,
		type = "group",
		name = L["BUFFS_AND_DEBUFFS"],
		childGroups = "tab",
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return PrC.db.profile.auras.enabled
				end,
				set = function(_, value)
					PrC.db.profile.auras.enabled = value

					if AURAS:IsInit() then
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if value then
							P:Call(AURAS.Init, AURAS)
						end
					end
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				disabled = isModuleDisabled,
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.auras, C.db.profile.auras, {point = true})
					AURAS:ForEachHeader("Update")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			cooldown = {
				order = 10,
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.auras.cooldown[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.auras.cooldown[info[#info]] ~= value then
						C.db.profile.auras.cooldown[info[#info]] = value
						AURAS:UpdateHeaders("UpdateConfig")
						AURAS:UpdateHeaders("UpdateCooldownConfig")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.auras.cooldown, C.db.profile.auras.cooldown)
							AURAS:UpdateHeaders("UpdateConfig")
							AURAS:UpdateHeaders("UpdateCooldownConfig")
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					exp_threshold = {
						order = 10,
						type = "range",
						name = L["EXP_THRESHOLD"],
						min = 1, max = 10, step = 1,
					},
					m_ss_threshold = {
						order = 11,
						type = "range",
						name = L["M_SS_THRESHOLD"],
						desc = L["M_SS_THRESHOLD_DESC"],
						min = 0, max = 3599, step = 1,
						softMin = 91,
						set = function(info, value)
							if C.db.profile.auras.cooldown[info[#info]] ~= value then
								if value < info.option.softMin then
									value = info.option.min
								end

								C.db.profile.auras.cooldown[info[#info]] = value
								AURAS:UpdateHeaders("UpdateConfig")
								AURAS:UpdateHeaders("UpdateCooldownConfig")
							end
						end,
					},
					s_ms_threshold = {
						order = 12,
						type = "range",
						name = L["S_MS_THRESHOLD"],
						desc = L["S_MS_THRESHOLD_DESC"],
						min = 1, max = 10, step = 1,
						set = function(info, value)
							if C.db.profile.auras.cooldown[info[#info]] ~= value then
								C.db.profile.auras.cooldown[info[#info]] = value

								AURAS:UpdateHeaders("UpdateConfig")
								AURAS:UpdateHeaders("UpdateCooldownConfig")
							end
						end,
					},
				},
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			buffs = getOptionsTable_Aura(20, L["BUFFS"], "HELPFUL"),
			debuffs = getOptionsTable_Aura(30, L["DEBUFFS"], "HARMFUL"),
			totems = getOptionsTable_Aura(40, L["TOTEMS"], "TOTEM"),
		},
	}
end
