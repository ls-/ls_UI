local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local UNITFRAMES = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_split = _G.string.split

-- Mine
local FCF_MODES = {
	["Fountain"] = "Fountain",
	["Standard"] = "Standard",
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

local POINTS_EXT = {
	[""] = "NONE",
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

local INSETS = {
	[8] = "8",
	[12] = "12",
}

local H_ALIGNMENT = {
	CENTER = "CENTER",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
}
local V_ALIGNMENT = {
	BOTTOM = "BOTTOM",
	MIDDLE = "MIDDLE",
	TOP = "TOP",
}

local CASTBAR_ICON_POSITIONS = {
	LEFT = L["LEFT"],
	RIGHT = L["RIGHT"],
}

local GROWTH_DIRS = {
	LEFT_DOWN = L["LEFT_DOWN"],
	LEFT_UP = L["LEFT_UP"],
	RIGHT_DOWN = L["RIGHT_DOWN"],
	RIGHT_UP = L["RIGHT_UP"],
}

local function getRegionAnchors(anchorsToRemove, anchorsToAdd)
	local temp = {
		[""] = L["FRAME"],
		["Health"] = L["HEALTH"],
		["Health.Text"] = L["HEALTH_TEXT"],
		["Power"] = L["POWER"],
		["Power.Text"] = L["POWER_TEXT"],
	}

	if anchorsToRemove then
		for anchor in next, anchorsToRemove do
			temp[anchor] = nil
		end
	end

	if anchorsToAdd then
		for anchor, name in next, anchorsToAdd do
			temp[anchor] = name
		end
	end

	return temp
end

local function getOptionsTable_Health(order, unit)
	local temp = {
		order = order,
		type = "group",
		name = L["HEALTH"],
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].health, C.db.profile.units[unit].health, {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealth")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			color = {
				order = 10,
				type = "group",
				name = L["BAR_COLOR"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].health.color[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[unit].health.color[info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealth")
				end,
				args = {
					class = {
						order = 1,
						type = "toggle",
						name = L["PLAYER_CLASS"],
						desc = L["COLOR_CLASS_DESC"],
					},
					reaction = {
						order = 2,
						type = "toggle",
						name = L["REACTION"],
						desc = L["COLOR_REACTION_DESC"],
					},
				},
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			text = {
				order = 20,
				type = "group",
				name = L["BAR_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].health.text.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].health.text.point1[info[#info]] ~= value then
						C.db.profile.units[unit].health.text.point1[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealth")
					end
				end,
				args = {
					p = {
						order = 4,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = POINTS,
					},
					anchor = {
						order = 5,
						type = "select",
						name = L["ANCHOR"],
						values = getRegionAnchors({["Health.Text"] = true}),
					},
					rP = {
						order = 6,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = POINTS,
					},
					x = {
						order = 7,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = 8,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					tag = {
						order = 10,
						type = "input",
						width = "full",
						name = L["FORMAT"],
						desc = L["HEALTH_FORMAT_DESC"],
						get = function()
							return C.db.profile.units[unit].health.text.tag:gsub("\124", "\124\124")
						end,
						set = function(_, value)
							C.db.profile.units[unit].health.text.tag = value:gsub("\124\124+", "\124")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealth")
						end,
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			prediction = {
				order = 30,
				type = "group",
				name = L["HEAL_PREDICTION"],
				inline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return C.db.profile.units[unit].health.prediction.enabled
						end,
						set = function(_, value)
							C.db.profile.units[unit].health.prediction.enabled = value
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					absorb_text = {
						order = 10,
						type = "group",
						name = L["DAMAGE_ABSORB_TEXT"],
						inline = true,
						get = function(info)
							return C.db.profile.units[unit].health.prediction.absorb_text.point1[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].health.prediction.absorb_text.point1[info[#info]] ~= value then
								C.db.profile.units[unit].health.prediction.absorb_text.point1[info[#info]] = value
								UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
								UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
							end
						end,
						args = {
							p = {
								order = 1,
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = POINTS,
							},
							anchor = {
								order = 2,
								type = "select",
								name = L["ANCHOR"],
								values = getRegionAnchors(),
							},
							rP = {
								order = 3,
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = POINTS,
							},
							x = {
								order = 4,
								type = "range",
								name = L["X_OFFSET"],
								min = -128, max = 128, step = 1,
							},
							y = {
								order = 5,
								type = "range",
								name = L["Y_OFFSET"],
								min = -128, max = 128, step = 1,
							},
							tag = {
								order = 9,
								type = "input",
								width = "full",
								name = L["FORMAT"],
								desc = L["DAMAGE_ABSORB_FORMAT_DESC"],
								get = function()
									return C.db.profile.units[unit].health.prediction.absorb_text.tag:gsub("\124", "\124\124")
								end,
								set = function(_, value)
									C.db.profile.units[unit].health.prediction.absorb_text.tag = value:gsub("\124\124+", "\124")
									UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
									UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
								end,
							},
						},
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					heal_absorb_text = {
						order = 20,
						type = "group",
						name = L["HEAL_ABSORB_TEXT"],
						inline = true,
						get = function(info)
							return C.db.profile.units[unit].health.prediction.heal_absorb_text.point1[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].health.prediction.heal_absorb_text.point1[info[#info]] ~= value then
								C.db.profile.units[unit].health.prediction.heal_absorb_text.point1[info[#info]] = value
								UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
								UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
							end
						end,
						args = {
							p = {
								order = 1,
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = POINTS,
							},
							anchor = {
								order = 2,
								type = "select",
								name = L["ANCHOR"],
								values = getRegionAnchors(),
							},
							rP = {
								order = 3,
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = POINTS,
							},
							x = {
								order = 4,
								type = "range",
								name = L["X_OFFSET"],
								min = -128, max = 128, step = 1,
							},
							y = {
								order = 5,
								type = "range",
								name = L["Y_OFFSET"],
								min = -128, max = 128, step = 1,
							},
							tag = {
								order = 9,
								type = "input",
								width = "full",
								name = L["FORMAT"],
								desc = L["HEAL_ABSORB_FORMAT_DESC"],
								get = function()
									return C.db.profile.units[unit].health.prediction.heal_absorb_text.tag:gsub("\124", "\124\124")
								end,
								set = function(_, value)
									C.db.profile.units[unit].health.prediction.heal_absorb_text.tag = value:gsub("\124\124+", "\124")
									UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
									UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
								end,
							},
						},
					},
				},
			},
		},
	}

	if unit == "player" or unit == "pet" then
		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].health, C.db.profile.units[unit][E.UI_LAYOUT].health, {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealth")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
		end

		temp.args.color.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].health.color[info[#info]]
		end
		temp.args.color.set = function(info, value)
			C.db.profile.units[unit][E.UI_LAYOUT].health.color[info[#info]] = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealth")
		end

		temp.args.color.args.reaction = nil

		temp.args.text.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].health.text.point1[info[#info]]
		end
		temp.args.text.set = function(info, value)
			C.db.profile.units[unit][E.UI_LAYOUT].health.text.point1[info[#info]] = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealth")
		end

		temp.args.text.args.tag.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].health.text.tag:gsub("\124", "\124\124")
		end
		temp.args.text.args.tag.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].health.text.tag = value:gsub("\124\124+", "\124")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealth")
		end

		temp.args.prediction.args.enabled.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.enabled
		end
		temp.args.prediction.args.enabled.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.enabled = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
		end

		if unit == "player" then
			temp.args.prediction.args.absorb_text.get = function(info)
				return C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.absorb_text.point1[info[#info]]
			end
			temp.args.prediction.args.absorb_text.set = function(info, value)
				if C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.absorb_text.point1[info[#info]] ~= value then
					C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.absorb_text.point1[info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
				end
			end

			temp.args.prediction.args.absorb_text.args.tag.get = function()
				return C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.absorb_text.tag:gsub("\124", "\124\124")
			end
			temp.args.prediction.args.absorb_text.args.tag.set = function(_, value)
				C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.absorb_text.tag = value:gsub("\124\124+", "\124")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
			end

			temp.args.prediction.args.heal_absorb_text.get = function(info)
				return C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.heal_absorb_text.point1[info[#info]]
			end
			temp.args.prediction.args.heal_absorb_text.set = function(info, value)
				if C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.heal_absorb_text.point1[info[#info]] ~= value then
					C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.heal_absorb_text.point1[info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
				end
			end

			temp.args.prediction.args.heal_absorb_text.args.tag.get = function()
				return C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.heal_absorb_text.tag:gsub("\124", "\124\124")
			end
			temp.args.prediction.args.heal_absorb_text.args.tag.set = function(_, value)
				C.db.profile.units[unit][E.UI_LAYOUT].health.prediction.heal_absorb_text.tag = value:gsub("\124\124+", "\124")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateHealthPrediction")
			end
		else
			temp.args.prediction.args.spacer_1 = nil
			temp.args.prediction.args.absorb_text = nil
			temp.args.prediction.args.spacer_2 = nil
			temp.args.prediction.args.heal_absorb_text = nil
		end
	elseif unit == "targettarget" then
		temp.args.prediction.args.spacer_1 = nil
		temp.args.prediction.args.absorb_text = nil
		temp.args.prediction.args.spacer_2 = nil
		temp.args.prediction.args.heal_absorb_text = nil
	elseif unit == "focustarget" then
		temp.args.prediction.args.spacer_1 = nil
		temp.args.prediction.args.absorb_text = nil
		temp.args.prediction.args.spacer_2 = nil
		temp.args.prediction.args.heal_absorb_text = nil
	end

	return temp
end

local function getOptionsTable_Power(order, unit)
	local temp = {
		order = order,
		type = "group",
		name = L["POWER"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].power.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].power.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].power, C.db.profile.units[unit].power, {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			text = {
				order = 10,
				type = "group",
				name = L["BAR_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].power.text.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].power.text.point1[info[#info]] ~= value then
						C.db.profile.units[unit].power.text.point1[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
					end
				end,
				args = {
					p = {
						order = 4,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = POINTS,
					},
					anchor = {
						order = 5,
						type = "select",
						name = L["ANCHOR"],
						values = getRegionAnchors({["Power.Text"] = true}),
					},
					rP = {
						order = 6,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = POINTS,
					},
					x = {
						order = 7,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = 8,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					tag = {
						order = 10,
						type = "input",
						width = "full",
						name = L["FORMAT"],
						desc = L["POWER_FORMAT_DESC"],
						get = function()
							return C.db.profile.units[unit].power.text.tag:gsub("\124", "\124\124")
						end,
						set = function(_, value)
							C.db.profile.units[unit].power.text.tag = value:gsub("\124\124+", "\124")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
						end,
					},
				},
			},
		},
	}

	if unit == "player" or unit == "pet" then
		temp.args.enabled.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].power.enabled
		end
		temp.args.enabled.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].power.enabled = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].power, C.db.profile.units[unit][E.UI_LAYOUT].power, {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
		end

		temp.args.text.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].power.text.point1[info[#info]]
		end
		temp.args.text.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].power.text.point1[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].power.text.point1[info[#info]] = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
			end
		end

		temp.args.text.args.tag.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].power.text.tag:gsub("\124", "\124\124")
		end
		temp.args.text.args.tag.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].power.text.tag = value:gsub("\124\124+", "\124")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
		end

		if unit == "player" then
			temp.args.spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			}

			temp.args.prediction = {
				order = 20,
				type = "toggle",
				name = L["COST_PREDICTION"],
				desc = L["COST_PREDICTION_DESC"],
				get = function()
					return C.db.profile.units[unit][E.UI_LAYOUT].power.prediction.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit][E.UI_LAYOUT].power.prediction.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
				end,
			}
		end
	end

	return temp
end

local function getOptionsTable_Castbar(order, unit)
	local temp = {
		order = order,
		type = "group",
		name = L["CASTBAR"],
		get = function(info)
			return C.db.profile.units[unit].castbar[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].castbar[info[#info]] ~= value then
				C.db.profile.units[unit].castbar[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
			end
		end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].castbar, C.db.profile.units[unit].castbar, {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			detached = {
				order = 10,
				type = "toggle",
				name = L["DETACH_FROM_FRAME"],
			},
			width_override = {
				order = 11,
				type = "range",
				name = L["WIDTH_OVERRIDE"],
				desc = L["SIZE_OVERRIDE_DESC"],
				min = 0, max = 1024, step = 2,
				softMin = 96,
				disabled = function()
					return not C.db.profile.units[unit].castbar.detached
				end,
			},
			height = {
				order = 12,
				type = "range",
				name = L["HEIGHT"],
				min = 8, max = 32, step = 4,
			},
			latency = {
				order = 13,
				type = "toggle",
				name = L["LATENCY"],
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			icon = {
				order = 20,
				type = "group",
				name = L["ICON"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].castbar.icon[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].castbar.icon[info[#info]] ~= value then
						C.db.profile.units[unit].castbar.icon[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
					},
					position = {
						order = 2,
						type = "select",
						name = L["POSITION"],
						values = CASTBAR_ICON_POSITIONS,
					},
				},
			},
		},
	}

	if unit == "player" or unit == "pet" then
		temp.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].castbar[info[#info]]
		end
		temp.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].castbar[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].castbar[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
			end
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].castbar, C.db.profile.units[unit][E.UI_LAYOUT].castbar, {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
		end

		temp.args.width_override.disabled = function()
			return not C.db.profile.units[unit][E.UI_LAYOUT].castbar.detached
		end

		temp.args.icon.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].castbar.icon[info[#info]]
		end
		temp.args.icon.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].castbar.icon[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].castbar.icon[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
			end
		end

		if E.UI_LAYOUT == "ls" then
			temp.args.detached = nil
			temp.args.width_override.name = L["WIDTH"]
		end
	else
		temp.args.latency = nil
	end

	return temp
end

local function getOptionsTable_Name(order, unit)
	local temp = {
		order = order,
		type = "group",
		name = L["NAME"],
		get = function(info)
			return C.db.profile.units[unit].name[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].name[info[#info]] ~= value then
				C.db.profile.units[unit].name[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
			end
		end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].name, C.db.profile.units[unit].name, {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			point1 = {
				order = 10,
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].name.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].name.point1[info[#info]] ~= value then
						C.db.profile.units[unit].name.point1[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = POINTS,
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["ANCHOR"],
						values = getRegionAnchors(),
					},
					rP = {
						order = 3,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = POINTS,
					},
					x = {
						order = 4,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = 5,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
				},
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			point2 = {
				order = 20,
				type = "group",
				name = L["SECOND_ANCHOR"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].name.point2[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].name.point2[info[#info]] ~= value then
						C.db.profile.units[unit].name.point2[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
					end
				end,
				disabled = function()
					return C.db.profile.units[unit].name.point2.p == ""
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = POINTS_EXT,
						disabled = false,
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["ANCHOR"],
						values = getRegionAnchors(),
					},
					rP = {
						order = 3,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = POINTS,
					},
					x = {
						order = 4,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = 5,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			h_alignment = {
				order = 30,
				type = "select",
				name = L["TEXT_HORIZ_ALIGNMENT"],
				values = H_ALIGNMENT,
				disabled = function()
					return C.db.profile.units[unit].name.point2.p == ""
				end,
			},
			v_alignment = {
				order = 31,
				type = "select",
				name = L["TEXT_VERT_ALIGNMENT"],
				values = V_ALIGNMENT,
				disabled = function()
					return C.db.profile.units[unit].name.point2.p == ""
				end,
			},
			word_wrap = {
				order = 32,
				type = "toggle",
				name = L["WORD_WRAP"],
			},
			tag = {
				order = 34,
				type = "input",
				width = "full",
				name = L["FORMAT"],
				desc = L["NAME_FORMAT_DESC"],
				get = function()
					return C.db.profile.units[unit].name.tag:gsub("\124", "\124\124")
				end,
				set = function(_, value)
					C.db.profile.units[unit].name.tag = value:gsub("\124\124+", "\124")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
				end,
			},
		},
	}

	if unit == "player" or unit == "pet" then
		temp.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].name[info[#info]]
		end
		temp.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].name[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].name[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
			end
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].name, C.db.profile.units[unit][E.UI_LAYOUT].name, {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
		end

		temp.args.point1.get = function(info)
					return C.db.profile.units[unit][E.UI_LAYOUT].name.point1[info[#info]]
				end
		temp.args.point1.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].name.point1[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].name.point1[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
			end
		end

		temp.args.point2.get = function(info)
					return C.db.profile.units[unit][E.UI_LAYOUT].name.point2[info[#info]]
				end
		temp.args.point2.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].name.point2[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].name.point2[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
			end
		end
		temp.args.point2.disabled = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].name.point2.p == ""
		end

		temp.args.h_alignment.disabled = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].name.point2.p == ""
		end

		temp.args.v_alignment.disabled = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].name.point2.p == ""
		end

		temp.args.tag.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].name.tag:gsub("\124", "\124\124")
		end
		temp.args.tag.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].name.tag = value:gsub("\124\124+", "\124")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
		end
	end

	return temp
end

local function getOptionsTable_RaidIcon(unit, order)
	local temp = {
		order = order,
		type = "group",
		name = L["RAID_ICON"],
		get = function(info)
			return C.db.profile.units[unit].raid_target[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].raid_target[info[#info]] ~= value then
				C.db.profile.units[unit].raid_target[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
			end
		end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				set = function(_, value)
					if C.db.profile.units[unit].raid_target.enabled ~= value then
						C.db.profile.units[unit].raid_target.enabled = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
					end
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].raid_target, C.db.profile.units[unit].raid_target, {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
			},
			size = {
				order = 10,
				type = "range",
				name = L["SIZE"],
				min = 8, max = 64, step = 1,
			},
			point = {
				order = 20,
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].raid_target.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].raid_target.point1[info[#info]] ~= value then
						C.db.profile.units[unit].raid_target.point1[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
					end
				end,
				args = {
					p = {
						order = 11,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = POINTS,
					},
					rP = {
						order = 12,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = POINTS,
					},
					x = {
						order = 13,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = 14,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
				},
			},
		},
	}

	return temp
end

local function getOptionsTable_DebuffIcons(unit, order)
	local temp = {
		order = order,
		type = "group",
		name = L["DISPELLABLE_DEBUFF_ICONS"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].debuff.enabled
				end,
				set = function(_, value)
					if C.db.profile.units[unit].debuff.enabled ~= value then
						C.db.profile.units[unit].debuff.enabled = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateDebuffIndicator")
					end
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].debuff, C.db.profile.units[unit].debuff, {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateDebuffIndicator")
				end,
			},
			preview = {
				type = "execute",
				order = 3,
				name = L["PREVIEW"],
				func = function()
					UNITFRAMES:UpdateUnitFrame(unit, "PreviewDebuffIndicator")
				end,
			},
			spacer_1 = {
				order = 10,
				type = "description",
				name = "",
			},
			point = {
				order = 20,
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].debuff.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].debuff.point1[info[#info]] ~= value then
						C.db.profile.units[unit].debuff.point1[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "PreviewDebuffIndicator")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = POINTS,
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["ANCHOR"],
						values = getRegionAnchors({["Health.Text"] = true, ["Power"] = true, ["Power.Text"] = true}),
					},
					rP = {
						order = 3,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = POINTS,
					},
					x = {
						order = 4,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = 5,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
				},
			},
		}
	}

	return temp
end

local function getOptionsTable_Auras(unit, order)
	local temp = {
		order = order,
		type = "group",
		name = L["AURAS"],
		get = function(info)
			return C.db.profile.units[unit].auras[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].auras[info[#info]] ~= value then
				C.db.profile.units[unit].auras[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
			end
		end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				set = function(_, value)
					if C.db.profile.units[unit].auras.enabled ~= value then
						C.db.profile.units[unit].auras.enabled = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
					end
				end,
			},
			copy = {
				order = 2,
				type = "select",
				name = L["COPY_FROM"],
				desc = L["COPY_FROM_DESC"],
				get = function() end,
				set = function(_, value)
					CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras, C.db.profile.units[unit].auras, {filter = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
			},
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].auras, C.db.profile.units[unit].auras, {["point"] = true, filter = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
			},
			rows = {
				order = 10,
				type = "range",
				name = L["NUM_ROWS"],
				min = 1, max = 4, step = 1,
			},
			per_row = {
				order = 11,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 10, step = 1,
			},
			size_override = {
				order = 12,
				type = "range",
				name = L["SIZE_OVERRIDE"],
				desc = L["SIZE_OVERRIDE_DESC"],
				min = 0, max = 48, step = 1,
			},
			growth_dir = {
				order = 13,
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.units[unit].auras.x_growth.."_"..C.db.profile.units[unit].auras.y_growth
				end,
				set = function(_, value)
					C.db.profile.units[unit].auras.x_growth, C.db.profile.units[unit].auras.y_growth = s_split("_", value)
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
			},
			disable_mouse = {
				order = 14,
				type = "toggle",
				name = L["DISABLE_MOUSE"],
				desc = L["DISABLE_MOUSE_DESC"],
			},
			point = {
				order = 20,
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.point1[info[#info]] ~= value then
						C.db.profile.units[unit].auras.point1[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = POINTS,
					},
					rP = {
						order = 2,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = POINTS,
					},
					x = {
						order = 3,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = 4,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
				},
			},
			filter = {
				order = 30,
				type = "group",
				name = L["FILTERS"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
				args = {
					copy = {
						order = 1,
						type = "select",
						name = L["COPY_FROM"],
						desc = L["COPY_FROM_DESC"],
						get = function() end,
					},
					reset = {
						type = "execute",
						order = 2,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.units[unit].auras.filter, C.db.profile.units[unit].auras.filter)
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
						end,
					},
					friendly = {
						order = 2,
						type = "group",
						inline = true,
						name = M.COLORS.GREEN:WrapText(L["FRIENDLY_UNITS"]),
						args = {
							buff = {
								order = 1,
								type = "group",
								name = "",
								inline = true,
								args = {
									boss = {
										order = 1,
										type = "toggle",
										name = L["BOSS_BUFFS"],
										desc = L["BOSS_BUFFS_DESC"],
									},
									mount = {
										order = 2,
										type = "toggle",
										name = L["MOUNT_AURAS"],
										desc = L["MOUNT_AURAS_DESC"],
									},
									selfcast = {
										order = 3,
										type = "toggle",
										name = L["SELF_BUFFS"],
										desc = L["SELF_BUFFS_DESC"],
									},
									selfcast_permanent = {
										order = 4,
										type = "toggle",
										name = L["SELF_BUFFS_PERMA"],
										desc = L["SELF_BUFFS_PERMA_DESC"],
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.friendly.buff.selfcast
										end,
									},
									player = {
										order = 5,
										type = "toggle",
										name = L["CASTABLE_BUFFS"],
										desc = L["CASTABLE_BUFFS_DESC"],
									},
									player_permanent = {
										order = 6,
										type = "toggle",
										name = L["CASTABLE_BUFFS_PERMA"],
										desc = L["CASTABLE_BUFFS_PERMA_DESC"],
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.friendly.buff.player
										end,
									},
								},
							},
							debuff = {
								order = 2,
								type = "group",
								name = "",
								inline = true,
								args = {
									boss = {
										order = 1,
										type = "toggle",
										name = L["BOSS_DEBUFFS"],
										desc = L["BOSS_DEBUFFS_DESC"],
									},
									selfcast = {
										order = 2,
										type = "toggle",
										name = L["SELF_DEBUFFS"],
										desc = L["SELF_DEBUFFS_DESC"],
									},
									selfcast_permanent = {
										order = 3,
										type = "toggle",
										name = L["SELF_DEBUFFS_PERMA"],
										desc = L["SELF_DEBUFFS_PERMA_DESC"],
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.friendly.debuff.selfcast
										end,
									},
									player = {
										order = 4,
										type = "toggle",
										name = L["CASTABLE_DEBUFFS"],
										desc = L["CASTABLE_DEBUFFS_DESC"],
									},
									player_permanent = {
										order = 5,
										type = "toggle",
										name = L["CASTABLE_DEBUFFS_PERMA"],
										desc = L["CASTABLE_DEBUFFS_PERMA_DESC"],
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.friendly.debuff.player
										end,
									},
									dispellable = {
										order = 6,
										type = "toggle",
										name = L["DISPELLABLE_DEBUFFS"],
										desc = L["DISPELLABLE_DEBUFFS_DESC"],
									},
								},
							},
						},
					},
					enemy = {
						order = 3,
						type = "group",
						inline = true,
						name = M.COLORS.RED:WrapText(L["ENEMY_UNITS"]),
						args = {
							buff = {
								order = 1,
								type = "group",
								name = "",
								inline = true,
								args = {
									boss = {
										order = 1,
										type = "toggle",
										name = L["BOSS_BUFFS"],
										desc = L["BOSS_BUFFS_DESC"],
									},
									mount = {
										order = 2,
										type = "toggle",
										name = L["MOUNT_AURAS"],
										desc = L["MOUNT_AURAS_DESC"],
									},
									selfcast = {
										order = 3,
										type = "toggle",
										name = L["SELF_BUFFS"],
										desc = L["SELF_BUFFS_DESC"],
									},
									selfcast_permanent = {
										order = 4,
										type = "toggle",
										name = L["SELF_BUFFS_PERMA"],
										desc = L["SELF_BUFFS_PERMA_DESC"],
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.enemy.buff.selfcast
										end,
									},
									player = {
										order = 5,
										type = "toggle",
										name = L["CASTABLE_BUFFS"],
										desc = L["CASTABLE_BUFFS_DESC"],
									},
									player_permanent = {
										order = 6,
										type = "toggle",
										name = L["CASTABLE_BUFFS_PERMA"],
										desc = L["CASTABLE_BUFFS_PERMA_DESC"],
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.enemy.buff.player
										end,
									},
									dispellable = {
										order = 7,
										type = "toggle",
										name = L["DISPELLABLE_BUFFS"],
										desc = L["DISPELLABLE_BUFFS_DESC"],
									},
								},
							},
							debuff = {
								order = 2,
								type = "group",
								name = "",
								inline = true,
								args = {
									boss = {
										order = 1,
										type = "toggle",
										name = L["BOSS_DEBUFFS"],
										desc = L["BOSS_DEBUFFS_DESC"],
									},
									selfcast = {
										order = 2,
										type = "toggle",
										name = L["SELF_DEBUFFS"],
										desc = L["SELF_DEBUFFS_DESC"],
									},
									selfcast_permanent = {
										order = 3,
										type = "toggle",
										name = L["SELF_DEBUFFS_PERMA"],
										desc = L["SELF_DEBUFFS_PERMA_DESC"],
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.enemy.debuff.selfcast
										end,
									},
									player = {
										order = 4,
										type = "toggle",
										name = L["CASTABLE_DEBUFFS"],
										desc = L["CASTABLE_DEBUFFS_DESC"],
									},
									player_permanent = {
										order = 5,
										type = "toggle",
										name = L["CASTABLE_DEBUFFS_PERMA"],
										desc = L["CASTABLE_DEBUFFS_PERMA_DESC"],
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.enemy.debuff.player
										end,
									},
								},
							},
						},
					},
				},
			},
		},
	}

	if E.UI_LAYOUT then
		temp.args.copy.values = UNITFRAMES:GetUnits({[unit] = true, player = true, pet = true, targettarget = true, focustarget = true})
		temp.args.filter.args.copy.values = UNITFRAMES:GetUnits({[unit] = true, player = true, pet = true, targettarget = true, focustarget = true})
	else
		temp.args.copy.values = UNITFRAMES:GetUnits({[unit] = true, pet = true, targettarget = true, focustarget = true})
		temp.args.filter.args.copy.values = UNITFRAMES:GetUnits({[unit] = true, pet = true, targettarget = true, focustarget = true})
	end

	if unit == "player" then
		temp.args.filter.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.friendly, C.db.profile.units[unit].auras.filter.friendly, {player = true, player_permanent = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end
		temp.args.filter.args.friendly.args.buff.args.player = nil
		temp.args.filter.args.friendly.args.buff.args.player_permanent = nil
		temp.args.filter.args.friendly.args.debuff.args.player = nil
		temp.args.filter.args.friendly.args.debuff.args.player_permanent = nil
		temp.args.filter.args.enemy = nil
	elseif unit == "boss" then
		temp.args.filter.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.friendly, C.db.profile.units[unit].auras.filter.friendly, {mount = true, selfcast = true, selfcast_permanent = true})
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.enemy, C.db.profile.units[unit].auras.filter.enemy, {mount = true, selfcast = true, selfcast_permanent = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end
		temp.args.filter.args.friendly.args.buff.args.mount = nil
		temp.args.filter.args.friendly.args.buff.args.selfcast = nil
		temp.args.filter.args.friendly.args.buff.args.selfcast_permanent = nil
		temp.args.filter.args.friendly.args.debuff.args.selfcast = nil
		temp.args.filter.args.friendly.args.debuff.args.selfcast_permanent = nil
		temp.args.filter.args.enemy.args.buff.args.mount = nil
		temp.args.filter.args.enemy.args.buff.args.selfcast = nil
		temp.args.filter.args.enemy.args.buff.args.selfcast_permanent = nil
		temp.args.filter.args.enemy.args.debuff.args.selfcast = nil
		temp.args.filter.args.enemy.args.debuff.args.selfcast_permanent = nil
	else
		temp.args.filter.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter, C.db.profile.units[unit].auras.filter)
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end
	end

	return temp
end

local function getOptionsTable_UnitFrame(order, unit, name)
	local temp = {
		order = order,
		type = "group",
		childGroups = "tab",
		name = name,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].enabled = value
					UNITFRAMES:UpdateUnitFrame(unit, "Update")
				end,
			},
			copy = {
				order = 2,
				type = "select",
				name = L["COPY_FROM"],
				desc = L["COPY_FROM_DESC"],
				values = function() return UNITFRAMES:GetUnits({[unit] = true, ["player"] = true, ["pet"] = true}) end,
				get = function() end,
				set = function(_, value)
					CONFIG:CopySettings(C.db.profile.units[value], C.db.profile.units[unit], {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "Update")
				end,
			},
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit], C.db.profile.units[unit], {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "Update")
				end,
			},
			preview = {
				order = 4,
				type = "execute",
				name = L["PREVIEW"],
				func = function()
					UNITFRAMES:UpdateUnitFrame(unit, "Preview")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			width = {
				order = 10,
				type = "range",
				name = L["WIDTH"],
				min = 96, max = 512, step = 2,
				get = function()
					return C.db.profile.units[unit].width
				end,
				set = function(_, value)
					if C.db.profile.units[unit].width ~= value then
						C.db.profile.units[unit].width = value
						UNITFRAMES:UpdateUnitFrame(unit, "Update")
					end
				end,
			},
			height = {
				order = 11,
				type = "range",
				name = L["HEIGHT"],
				min = 28, max = 256, step = 2,
				get = function()
					return C.db.profile.units[unit].height
				end,
				set = function(_, value)
					if C.db.profile.units[unit].height ~= value then
						C.db.profile.units[unit].height = value
						UNITFRAMES:UpdateUnitFrame(unit, "Update")
					end
				end,
			},
			top_inset = {
				order = 12,
				type = "select",
				name = L["TOP_INSET_SIZE"],
				desc = L["TOP_INSET_SIZE_DESC"],
				values = INSETS,
				get = function()
					return C.db.profile.units[unit].insets.t_height
				end,
				set = function(_, value)
					if C.db.profile.units[unit].insets.t_height ~= value then
						C.db.profile.units[unit].insets.t_height = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateInsets")
					end
				end,
			},
			bottom_inset = {
				order = 13,
				type = "select",
				name = L["BOTTOM_INSET_SIZE"],
				desc = L["BOTTOM_INSET_SIZE_DESC"],
				values = INSETS,
				get = function()
					return C.db.profile.units[unit].insets.b_height
				end,
				set = function(_, value)
					if C.db.profile.units[unit].insets.b_height ~= value then
						C.db.profile.units[unit].insets.b_height = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateInsets")
					end
				end,
			},
			threat = {
				order = 14,
				type = "toggle",
				name = L["THREAT_GLOW"],
				get = function()
					return C.db.profile.units[unit].threat.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].threat.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateThreatIndicator")
				end,
			},
			pvp = {
				order = 15,
				type = "toggle",
				name = L["PVP_ICON"],
				get = function()
					return C.db.profile.units[unit].pvp.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].pvp.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
				end,
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			border = {
				order = 20,
				type = "group",
				name = L["BORDER_COLOR"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].class[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[unit].class[info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassIndicator")
				end,
				args = {
					player = {
						order = 1,
						type = "toggle",
						name = L["PLAYER_CLASS"],
						desc = L["COLOR_CLASS_DESC"],
					},
					npc = {
						order = 2,
						type = "toggle",
						name = L["NPC_CLASSIFICATION"],
						desc = L["COLOR_CLASSIFICATION_DESC"],
					},
				},
			},
		},
	}

	temp.args.health = getOptionsTable_Health(100, unit)
	temp.args.power = getOptionsTable_Power(200, unit)
	temp.args.castbar = getOptionsTable_Castbar(400, unit)
	temp.args.name = getOptionsTable_Name(500, unit)
	-- temp.args.raid_target = getOptionsTable_RaidIcon(unit, 600)
	-- temp.args.debuff = getOptionsTable_DebuffIcons(unit, 700)
	-- temp.args.auras = getOptionsTable_Auras(unit, 800)

	if unit == "player" or unit == "pet" then
		temp.disabled = function() return not UNITFRAMES:HasPlayerFrame() end

		temp.args.enabled.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].enabled
		end
		temp.args.enabled.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].enabled = value
			UNITFRAMES:UpdateUnitFrame(unit, "Update")
		end

		temp.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[value][E.UI_LAYOUT], C.db.profile.units[unit][E.UI_LAYOUT], {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "Update")
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT], C.db.profile.units[unit][E.UI_LAYOUT], {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "Update")
		end

		temp.args.preview = nil

		temp.args.width.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].width
		end
		temp.args.width.set = function(_, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].width ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].width = value
				UNITFRAMES:UpdateUnitFrame(unit, "Update")
			end
		end

		temp.args.height.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].height
		end
		temp.args.height.set = function(_, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].height ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].height = value
				UNITFRAMES:UpdateUnitFrame(unit, "Update")
			end
		end

		temp.args.threat.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].threat.enabled
		end
		temp.args.threat.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].threat.enabled = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateThreatIndicator")
		end

		temp.args.pvp.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].pvp.enabled
		end
		temp.args.pvp.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].pvp.enabled = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
		end

		temp.args.border.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].class[info[#info]]
		end
		temp.args.border.set = function(info, value)
			C.db.profile.units[unit][E.UI_LAYOUT].class[info[#info]] = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassIndicator")
		end

	-- 	temp.args.class_power = {
	-- 		order = 300,
	-- 		type = "group",
	-- 		name = L["CLASS_POWER"],
	-- 		args = {
	-- 			enabled = {
	-- 				order = 1,
	-- 				type = "toggle",
	-- 				name = L["ENABLE"],
	-- 				get = function()
	-- 					return C.db.profile.units[unit].class_power.enabled
	-- 				end,
	-- 				set = function(_, value)
	-- 					C.db.profile.units[unit].class_power.enabled = value
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAdditionalPower")
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassPower")
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateRunes")
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateStagger")
	-- 				end,
	-- 			},
	-- 			prediction = {
	-- 				order = 2,
	-- 				type = "toggle",
	-- 				name = L["COST_PREDICTION"],
	-- 				desc = L["COST_PREDICTION_DESC"],
	-- 				get = function()
	-- 					return C.db.profile.units[unit].class_power.prediction.enabled
	-- 				end,
	-- 				set = function(_, value)
	-- 					C.db.profile.units[unit].class_power.prediction.enabled = value
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")

	-- 				end,
	-- 			},
	-- 			runes = {
	-- 				order = 10,
	-- 				type = "group",
	-- 				name = L["RUNES"],
	-- 				inline = true,
	-- 				get = function(info)
	-- 					return C.db.profile.units[unit].class_power.runes[info[#info]]
	-- 				end,
	-- 				set = function(info, value)
	-- 					C.db.profile.units[unit].class_power.runes[info[#info]] = value
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateRunes")
	-- 				end,
	-- 				args = {
	-- 					color_by_spec = {
	-- 						order = 1,
	-- 						type = "toggle",
	-- 						name = L["COLOR_BY_SPEC"],
	-- 					},
	-- 					sort_order = {
	-- 						order = 2,
	-- 						type = "select",
	-- 						name = L["SORT_DIR"],
	-- 						values = {
	-- 							["none"] = L["NONE"],
	-- 							["asc"] = L["ASCENDING"],
	-- 							["desc"] = L["DESCENDING"],
	-- 						},
	-- 					},
	-- 				},
	-- 			},
	-- 		},
	-- 	}
	-- 	temp.args.combat_feedback = {
	-- 		order = 900,
	-- 		type = "group",
	-- 		name = L["FCF"],
	-- 		get = function(info)
	-- 			return C.db.profile.units[unit].combat_feedback[info[#info]]
	-- 		end,
	-- 		set = function(info, value)
	-- 			C.db.profile.units[unit].combat_feedback[info[#info]] = value
	-- 			UNITFRAMES:UpdateUnitFrame(unit, "UpdateCombatFeedback")
	-- 		end,
	-- 		args = {
	-- 			enabled = {
	-- 				order = 1,
	-- 				type = "toggle",
	-- 				name = L["ENABLE"],
	-- 				set = function(_, value)
	-- 					C.db.profile.units[unit].combat_feedback.enabled = value
	-- 						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
	-- 						UNITFRAMES:UpdateUnitFrame(unit, "UpdateCombatFeedback")
	-- 				end,
	-- 			},
	-- 			reset = {
	-- 				type = "execute",
	-- 				order = 2,
	-- 				name = L["RESTORE_DEFAULTS"],
	-- 				func = function()
	-- 					CONFIG:CopySettings(D.profile.units[unit].combat_feedback, C.db.profile.units[unit].combat_feedback, {["point"] = true})
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateCombatFeedback")
	-- 				end,
	-- 			},
	-- 			spacer_1 = {
	-- 				order = 9,
	-- 				type = "description",
	-- 				name = "",
	-- 			},
	-- 			x_offset = {
	-- 				order = 10,
	-- 				type = "range",
	-- 				name = L["X_OFFSET"],
	-- 				min = 0, max = 128, step = 1,
	-- 			},
	-- 			y_offset = {
	-- 				order = 12,
	-- 				type = "range",
	-- 				name = L["Y_OFFSET"],
	-- 				min = 0, max = 64, step = 1,
	-- 			},
	-- 			mode = {
	-- 				order = 13,
	-- 				type = "select",
	-- 				name = L["MODE"],
	-- 				values = FCF_MODES,
	-- 			},
	-- 		},
	-- 	}

		if E.UI_LAYOUT == "ls" then
			temp.args.copy = nil
			temp.args.width = nil
			temp.args.height = nil
			temp.args.top_inset = nil
			temp.args.bottom_inset = nil
			temp.args.border = nil
			temp.args.auras = nil

			if unit == "pet" then
				temp.args.pvp = nil
			end
		else
			temp.args.top_inset.get = function()
				return C.db.profile.units[unit][E.UI_LAYOUT].insets.t_height
			end
			temp.args.top_inset.set = function(_, value)
				if C.db.profile.units[unit][E.UI_LAYOUT].insets.t_height ~= value then
					C.db.profile.units[unit][E.UI_LAYOUT].insets.t_height = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateInsets")
				end
			end

			temp.args.bottom_inset.get = function()
				return C.db.profile.units[unit][E.UI_LAYOUT].insets.b_height
			end
			temp.args.bottom_inset.set = function(_, value)
				if C.db.profile.units[unit][E.UI_LAYOUT].insets.b_height ~= value then
					C.db.profile.units[unit][E.UI_LAYOUT].insets.b_height = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateInsets")
				end
			end

			temp.args.border.args.npc = nil

			if unit == "pet" then
				temp.args.auras = nil
			end
		end
	-- elseif unit == "pet" then
	-- 	temp.disabled = function() return not UNITFRAMES:HasPlayerFrame() end
	-- 	temp.args.pvp = nil
	-- -- 	temp.args.auras = nil

	-- 	if E.UI_LAYOUT == "ls" then
	-- 		temp.args.copy = nil
	-- 		temp.args.name = nil
	-- 		temp.args.width = nil
	-- 		temp.args.height = nil
	-- 		temp.args.top_inset = nil
	-- 		temp.args.bottom_inset = nil
	-- 		temp.args.border = nil
	-- 	end
	elseif unit == "target" then
		temp.disabled = function() return not UNITFRAMES:HasTargetFrame() end
		temp.args.preview = nil
	elseif unit == "targettarget" then
		temp.disabled = function() return not UNITFRAMES:HasTargetFrame() end
		temp.args.preview = nil
		temp.args.pvp = nil
		temp.args.castbar = nil
		-- temp.args.debuff = nil
		-- temp.args.auras = nil
	elseif unit == "focus" then
		temp.disabled = function() return not UNITFRAMES:HasFocusFrame() end
		temp.args.preview = nil
	elseif unit == "focustarget" then
		temp.disabled = function() return not UNITFRAMES:HasFocusFrame() end
		temp.args.preview = nil
		temp.args.pvp = nil
		temp.args.castbar = nil
	-- 	temp.args.debuff = nil
	-- 	temp.args.auras = nil
	elseif unit == "boss" then
		temp.disabled = function() return not UNITFRAMES:HasBossFrame() end
		temp.args.pvp = nil
	-- 	temp.args.debuff = nil
	-- 	temp.args.per_row = {
	-- 		order = 13,
	-- 		type = "range",
	-- 		name = L["PER_ROW"],
	-- 		min = 1, max = 5, step = 1,
	-- 		get = function()
	-- 			return C.db.profile.units[unit].per_row
	-- 		end,
	-- 		set = function(_, value)
	-- 			if C.db.profile.units[unit].per_row ~= value then
	-- 				C.db.profile.units[unit].per_row = value
	-- 				UNITFRAMES:UpdateBossHolder()
	-- 			end
	-- 		end,
	-- 	}
	-- 	temp.args.spacing = {
	-- 		order = 14,
	-- 		type = "range",
	-- 		name = L["SPACING"],
	-- 		min = 8, max = 64, step = 2,
	-- 		get = function()
	-- 			return C.db.profile.units[unit].spacing
	-- 		end,
	-- 		set = function(_, value)
	-- 			if C.db.profile.units[unit].spacing ~= value then
	-- 				C.db.profile.units[unit].spacing = value
	-- 				UNITFRAMES:UpdateBossHolder()
	-- 			end
	-- 		end,
	-- 	}
	-- 	temp.args.growth_dir = {
	-- 		order = 15,
	-- 		type = "select",
	-- 		name = L["GROWTH_DIR"],
	-- 		values = GROWTH_DIRS,
	-- 		get = function()
	-- 			return C.db.profile.units[unit].x_growth.."_"..C.db.profile.units[unit].y_growth
	-- 		end,
	-- 		set = function(_, value)
	-- 			C.db.profile.units[unit].x_growth, C.db.profile.units[unit].y_growth = s_split("_", value)
	-- 			UNITFRAMES:UpdateBossHolder()
	-- 		end,
	-- 	}
	-- 	temp.args.alt_power = {
	-- 		order = 300,
	-- 		type = "group",
	-- 		name = L["ALTERNATIVE_POWER"],
	-- 		args = {
	-- 			enabled = {
	-- 				order = 1,
	-- 				type = "toggle",
	-- 				name = L["ENABLE"],
	-- 				get = function()
	-- 					return C.db.profile.units[unit].alt_power.enabled
	-- 				end,
	-- 				set = function(_, value)
	-- 					C.db.profile.units[unit].alt_power.enabled = value
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
	-- 				end,
	-- 			},
	-- 			reset = {
	-- 				type = "execute",
	-- 				order = 2,
	-- 				name = L["RESTORE_DEFAULTS"],
	-- 				func = function()
	-- 					CONFIG:CopySettings(D.profile.units[unit].alt_power, C.db.profile.units[unit].alt_power, {["point"] = true})
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
	-- 					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
	-- 				end,
	-- 			},
	-- 			spacer_1 = {
	-- 				order = 9,
	-- 				type = "description",
	-- 				name = "",
	-- 			},
	-- 			text = {
	-- 				order = 10,
	-- 				type = "group",
	-- 				name = L["BAR_TEXT"],
	-- 				inline = true,
	-- 				get = function(info)
	-- 					return C.db.profile.units[unit].alt_power.text.point1[info[#info]]
	-- 				end,
	-- 				set = function(info, value)
	-- 					if C.db.profile.units[unit].alt_power.text.point1[info[#info]] ~= value then
	-- 						C.db.profile.units[unit].alt_power.text.point1[info[#info]] = value
	-- 						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
	-- 					end
	-- 				end,
	-- 				args = {
	-- 					p = {
	-- 						order = 4,
	-- 						type = "select",
	-- 						name = L["POINT"],
	-- 						desc = L["POINT_DESC"],
	-- 						values = POINTS,
	-- 					},
	-- 					anchor = {
	-- 						order = 5,
	-- 						type = "select",
	-- 						name = L["ANCHOR"],
	-- 						values = getRegionAnchors(nil, {["AlternativePower"] = L["ALTERNATIVE_POWER"]}),
	-- 					},
	-- 					rP = {
	-- 						order = 6,
	-- 						type = "select",
	-- 						name = L["RELATIVE_POINT"],
	-- 						desc = L["RELATIVE_POINT_DESC"],
	-- 						values = POINTS,
	-- 					},
	-- 					x = {
	-- 						order = 7,
	-- 						type = "range",
	-- 						name = L["X_OFFSET"],
	-- 						min = -128, max = 128, step = 1,
	-- 					},
	-- 					y = {
	-- 						order = 8,
	-- 						type = "range",
	-- 						name = L["Y_OFFSET"],
	-- 						min = -128, max = 128, step = 1,
	-- 					},
	-- 					tag = {
	-- 						order = 10,
	-- 						type = "input",
	-- 						width = "full",
	-- 						name = L["FORMAT"],
	-- 						desc = L["ALT_POWER_FORMAT_DESC"],
	-- 						get = function()
	-- 							return C.db.profile.units[unit].alt_power.text.tag:gsub("\124", "\124\124")
	-- 						end,
	-- 						set = function(_, value)
	-- 							C.db.profile.units[unit].alt_power.text.tag = value:gsub("\124\124+", "\124")
	-- 							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
	-- 							UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
	-- 						end,
	-- 					},
	-- 				},
	-- 			},
	-- 		},
	-- 	}
	end

	return temp
end

function CONFIG.CreateUnitFramesPanel(_, order)
	C.options.args.unitframes = {
		order = order,
		type = "group",
		name = L["UNIT_FRAME"],
		childGroups = "tree",
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.units.enabled
				end,
				set = function(_, value)
					C.db.char.units.enabled = value

					if UNITFRAMES:IsInit() then
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if value then
							UNITFRAMES:Init()
						end
					end
				end
			},
			units = {
				order = 2,
				type = "group",
				name = L["UNITS"],
				inline = true,
				disabled = function()
					return not UNITFRAMES:IsInit()
				end,
				get = function(info)
					return C.db.char.units[info[#info]].enabled
				end,
				set = function(info, value)
					C.db.char.units[info[#info]].enabled = value

					if UNITFRAMES:IsInit() then
						if value then
							if info[#info] == "player" then
								UNITFRAMES:CreateUnitFrame("player", "LSPlayer")
								UNITFRAMES:UpdateUnitFrame("player", "Update")
								UNITFRAMES:CreateUnitFrame("pet", "LSPet")
								UNITFRAMES:UpdateUnitFrame("pet", "Update")

								if P:GetModule("Blizzard"):HasCastBars() then
									P:GetModule("Blizzard"):UpdateCastBars()
								end
							elseif info[#info] == "target" then
								UNITFRAMES:CreateUnitFrame("target", "LSTarget")
								UNITFRAMES:UpdateUnitFrame("target", "Update")
								UNITFRAMES:CreateUnitFrame("targettarget", "LSTargetTarget")
								UNITFRAMES:UpdateUnitFrame("targettarget", "Update")
							elseif info[#info] == "focus" then
								UNITFRAMES:CreateUnitFrame("focus", "LSFocus")
								UNITFRAMES:UpdateUnitFrame("focus", "Update")
								UNITFRAMES:CreateUnitFrame("focustarget", "LSFocusTarget")
								UNITFRAMES:UpdateUnitFrame("focustarget", "Update")
							else
								UNITFRAMES:CreateUnitFrame("boss", "LSBoss")
								UNITFRAMES:UpdateUnitFrame("boss", "Update")
							end
						else
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end,
				args = {
					player = {
						order = 1,
						type = "toggle",
						name = L["PLAYER_PET"],
					},
					target = {
						order = 2,
						type = "toggle",
						name = L["TARGET_TOT"],
					},
					focus = {
						order = 3,
						type = "toggle",
						name = L["FOCUS_TOF"],
					},
					boss = {
						order = 4,
						type = "toggle",
						name = L["BOSS"],
					},
				},
			},
			player = getOptionsTable_UnitFrame(3, "player", L["PLAYER_FRAME"]),
			pet = getOptionsTable_UnitFrame(4, "pet", L["PET_FRAME"]),
			target = getOptionsTable_UnitFrame(5, "target", L["TARGET_FRAME"]),
			targettarget = getOptionsTable_UnitFrame(6, "targettarget", L["TOT_FRAME"]),
			focus = getOptionsTable_UnitFrame(7, "focus", L["FOCUS_FRAME"]),
			focustarget = getOptionsTable_UnitFrame(8, "focustarget", L["TOF_FRAME"]),
			boss = getOptionsTable_UnitFrame(9, "boss", L["BOSS_FRAMES"]),
		},
	}
end
