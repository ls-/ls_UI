local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
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

local powerIgnoredAnchors = {
	["Power.Text"] = true
}

function CONFIG:CreateUnitFramePowerOptions(order, unit)
	local temp = {
		order = order,
		type = "group",
		name = L["POWER"],
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].power.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].power.enabled = value

					UNITFRAMES:For(unit, "UpdatePower")
					UNITFRAMES:For(unit, "UpdatePowerPrediction")
				end,
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].power, C.db.profile.units[unit].power)
					UNITFRAMES:For(unit, "UpdatePower")
					UNITFRAMES:For(unit, "UpdatePowerPrediction")
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			prediction = {
				order = inc(1),
				type = "toggle",
				name = L["COST_PREDICTION"],
				desc = L["COST_PREDICTION_DESC"],
				get = function()
					return C.db.profile.units[unit].power.prediction.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].power.prediction.enabled = value

					UNITFRAMES:For(unit, "UpdatePowerPrediction")
				end,
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			text = {
				order = inc(1),
				type = "group",
				name = L["BAR_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].power.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].power.text[info[#info]] ~= value then
						C.db.profile.units[unit].power.text[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Power", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Power", "UpdateFonts")
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
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					point = {
						order = inc(2),
						type = "group",
						name = "",
						inline = true,
						get = function(info)
							return C.db.profile.units[unit].power.text.point1[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].power.text.point1[info[#info]] ~= value then
								C.db.profile.units[unit].power.text.point1[info[#info]] = value

								UNITFRAMES:For(unit, "For", "Power", "UpdateConfig")
								UNITFRAMES:For(unit, "For", "Power", "UpdateTextPoints")
							end
						end,
						args = {
							p = {
								order = reset(3),
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = CONFIG.POINTS,
							},
							anchor = {
								order = inc(3),
								type = "select",
								name = L["ANCHOR"],
								values = CONFIG:GetRegionAnchors(powerIgnoredAnchors),
							},
							rP = {
								order = inc(3),
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = CONFIG.POINTS,
							},
							x = {
								order = inc(3),
								type = "range",
								name = L["X_OFFSET"],
								min = -128, max = 128, step = 1,
							},
							y = {
								order = inc(3),
								type = "range",
								name = L["Y_OFFSET"],
								min = -128, max = 128, step = 1,
							},
						},
					},
					spacer_2 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					tag = {
						order = inc(2),
						type = "input",
						width = "full",
						name = L["FORMAT"],
						desc = L["POWER_FORMAT_DESC"],
						get = function()
							return C.db.profile.units[unit].power.text.tag:gsub("\124", "\124\124")
						end,
						set = function(_, value)
							if not CONFIG:IsTagStringValid(value) then return end

							value = value:gsub("\124\124+", "\124")
							if C.db.profile.units[unit].power.text.tag ~= value then
								C.db.profile.units[unit].power.text.tag = value:gsub("\124\124+", "\124")
								UNITFRAMES:For(unit, "For", "Power", "UpdateConfig")
								UNITFRAMES:For(unit, "For", "Power", "UpdateTags")
							end
						end,
					},
				},
			},
		},
	}

	if unit ~= "player" then
		temp.args.spacer_1 = nil
		temp.args.prediction = nil
	end

	return temp
end

local altPowerExtraAnchors = {
	["AlternativePower"] = L["ALTERNATIVE_POWER"]
}

function CONFIG:CreateUnitFrameAltPowerOptions(order, unit)
	return {
		order = order,
		type = "group",
		name = L["ALTERNATIVE_POWER"],
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].alt_power.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].alt_power.enabled = value

					UNITFRAMES:For(unit, "UpdateAlternativePower")
				end,
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].alt_power, C.db.profile.units[unit].alt_power)
					UNITFRAMES:For(unit, "UpdateAlternativePower")
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			text = {
				order = inc(1),
				type = "group",
				name = L["BAR_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].alt_power.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].alt_power.text[info[#info]] ~= value then
						C.db.profile.units[unit].alt_power.text[info[#info]] = value

						UNITFRAMES:For(unit, "For", "AlternativePower", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "AlternativePower", "UpdateFonts")
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
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					point = {
						order = inc(2),
						type = "group",
						name = "",
						inline = true,
						get = function(info)
							return C.db.profile.units[unit].alt_power.text.point1[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].alt_power.text.point1[info[#info]] ~= value then
								C.db.profile.units[unit].alt_power.text.point1[info[#info]] = value

								UNITFRAMES:For(unit, "For", "AlternativePower", "UpdateConfig")
								UNITFRAMES:For(unit, "For", "AlternativePower", "UpdateTextPoints")
							end
						end,
						args = {
							p = {
								order = reset(3),
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = CONFIG.POINTS,
							},
							anchor = {
								order = reset(3),
								type = "select",
								name = L["ANCHOR"],
								values = CONFIG:GetRegionAnchors(nil, altPowerExtraAnchors),
							},
							rP = {
								order = reset(3),
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = CONFIG.POINTS,
							},
							x = {
								order = reset(3),
								type = "range",
								name = L["X_OFFSET"],
								min = -128, max = 128, step = 1,
							},
							y = {
								order = reset(3),
								type = "range",
								name = L["Y_OFFSET"],
								min = -128, max = 128, step = 1,
							},
						},
					},
					spacer_2 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					tag = {
						order = inc(2),
						type = "input",
						width = "full",
						name = L["FORMAT"],
						desc = L["ALT_POWER_FORMAT_DESC"],
						get = function()
							return C.db.profile.units[unit].alt_power.text.tag:gsub("\124", "\124\124")
						end,
						set = function(_, value)
							if not CONFIG:IsTagStringValid(value) then return end

							value = value:gsub("\124\124+", "\124")
							if C.db.profile.units[unit].alt_power.text.tag ~= value then
								C.db.profile.units[unit].alt_power.text.tag = value
								UNITFRAMES:For(unit, "For", "AlternativePower", "UpdateConfig")
								UNITFRAMES:For(unit, "For", "AlternativePower", "UpdateTags")
							end
						end,
					},
				},
			},
		},
	}
end

local function isPlayerDeathKnight()
	return E.PLAYER_CLASS ~= "DEATHKNIGHT"
end

local function hidePowerCost()
	return E.PLAYER_CLASS ~= "DRUID" and E.PLAYER_CLASS ~= "MONK" and E.PLAYER_CLASS ~= "SHAMAN"
end

function CONFIG:CreateUnitFrameClassPowerOptions(order, unit)
	return {
		order = order,
		type = "group",
		name = L["CLASS_POWER"],
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].class_power.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].class_power.enabled = value

					UNITFRAMES:For(unit, "UpdateAdditionalPower")
					UNITFRAMES:For(unit, "UpdatePowerPrediction")
					UNITFRAMES:For(unit, "UpdateClassPower")
					UNITFRAMES:For(unit, "UpdateRunes")
					UNITFRAMES:For(unit, "UpdateStagger")
				end,
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].class_power, C.db.profile.units[unit].class_power)
					UNITFRAMES:For(unit, "UpdateAdditionalPower")
					UNITFRAMES:For(unit, "UpdatePowerPrediction")
					UNITFRAMES:For(unit, "UpdateClassPower")
					UNITFRAMES:For(unit, "UpdateRunes")
					UNITFRAMES:For(unit, "UpdateStagger")
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			prediction = {
				order = inc(1),
				type = "toggle",
				name = L["COST_PREDICTION"],
				desc = L["COST_PREDICTION_DESC"],
				hidden = hidePowerCost,
				get = function()
					return C.db.profile.units[unit].class_power.prediction.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].class_power.prediction.enabled = value

					UNITFRAMES:For(unit, "UpdatePowerPrediction")
				end,
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
				hidden = isPlayerDeathKnight,
			},
			runes = {
				order = inc(1),
				type = "group",
				name = L["RUNES"],
				hidden = isPlayerDeathKnight,
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].class_power.runes[info[#info]]
				end,
				args = {
					color_by_spec = {
						order = reset(2),
						type = "toggle",
						name = L["COLOR_BY_SPEC"],
						set = function(_, value)
							C.db.profile.units[unit].class_power.runes.color_by_spec = value

							UNITFRAMES:For(unit, "For", "Runes", "UpdateConfig")
							UNITFRAMES:For(unit, "For", "Runes", "UpdateColors")
						end,
					},
					sort_order = {
						order = inc(2),
						type = "select",
						name = L["SORT_DIR"],
						values = {
							["none"] = L["NONE"],
							["asc"] = L["ASCENDING"],
							["desc"] = L["DESCENDING"],
						},
						set = function(_, value)
							if C.db.profile.units[unit].class_power.runes.sort_order ~= value then
								C.db.profile.units[unit].class_power.runes.sort_order = value

								UNITFRAMES:For(unit, "For", "Runes", "UpdateConfig")
								UNITFRAMES:For(unit, "For", "Runes", "UpdateSortOrder")
							end
						end,
					},
				},
			},
		},
	}
end
