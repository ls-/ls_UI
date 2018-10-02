local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local UNITFRAMES = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_split = _G.string.split
local unpack = _G.unpack

-- Mine
local FCF_MODES = {
	["Fountain"] = "Fountain",
	["Standard"] = "Straight",
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

local CASTBAR_ICON_POSITIONS = {
	["LEFT"] = L["LEFT"],
	["RIGHT"] = L["RIGHT"],
}

local GROWTH_DIRS = {
	["LEFT_DOWN"] = L["LEFT_DOWN"],
	["LEFT_UP"] = L["LEFT_UP"],
	["RIGHT_DOWN"] = L["RIGHT_DOWN"],
	["RIGHT_UP"] = L["RIGHT_UP"],
}

local function isModuleDisabled()
	return not UNITFRAMES:IsInit()
end

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
							if not CONFIG:IsTagStringValid(value) then return end

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
									if not CONFIG:IsTagStringValid(value) then return end

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
									if not CONFIG:IsTagStringValid(value) then return end

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
			if not CONFIG:IsTagStringValid(value) then return end

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
				if not CONFIG:IsTagStringValid(value) then return end

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
				if not CONFIG:IsTagStringValid(value) then return end

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
							if not CONFIG:IsTagStringValid(value) then return end

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
			if not CONFIG:IsTagStringValid(value) then return end

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
				set = function(info, value)
					if C.db.profile.units[unit].castbar[info[#info]] ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end

						C.db.profile.units[unit].castbar[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
					end
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
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			text = {
				order = 30,
				type = "group",
				name = L["TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].castbar[info[#info - 1]][info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[unit].castbar[info[#info - 1]][info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
				end,
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["SIZE"],
						min = 10, max = 20, step = 2,
					},
					flag = {
						order = 2,
						type = "select",
						name = L["FLAG"],
						values = FLAGS,
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

		temp.args.width_override.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].castbar[info[#info]] ~= value then
				if value < info.option.softMin then
					value = info.option.min
				end

				C.db.profile.units[unit][E.UI_LAYOUT].castbar[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateCastbar")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
			end
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

		temp.args.text.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].castbar.text[info[#info]]
		end
		temp.args.text.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].castbar.text[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].castbar.text[info[#info]] = value
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
				values = H_ALIGNMENTS,
				disabled = function()
					return C.db.profile.units[unit].name.point2.p == ""
				end,
			},
			v_alignment = {
				order = 31,
				type = "select",
				name = L["TEXT_VERT_ALIGNMENT"],
				values = V_ALIGNMENTS,
				disabled = function()
					return C.db.profile.units[unit].name.point2.p == ""
				end,
			},
			word_wrap = {
				order = 32,
				type = "toggle",
				name = L["WORD_WRAP"],
				disabled = function()
					return C.db.profile.units[unit].name.point2.p == ""
				end,
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
					if not CONFIG:IsTagStringValid(value) then return end

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

		temp.args.word_wrap.disabled = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].name.point2.p == ""
		end

		temp.args.tag.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].name.tag:gsub("\124", "\124\124")
		end
		temp.args.tag.set = function(_, value)
			if not CONFIG:IsTagStringValid(value) then return end

			C.db.profile.units[unit][E.UI_LAYOUT].name.tag = value:gsub("\124\124+", "\124")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateName")
		end
	end

	return temp
end

local function getOptionsTable_RaidIcon(order, unit)
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
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
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
					CONFIG:CopySettings(D.profile.units[unit].raid_target, C.db.profile.units[unit].raid_target, {["point"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			size = {
				order = 10,
				type = "range",
				name = L["SIZE"],
				min = 8, max = 64, step = 1,
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
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
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
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
		},
	}

	if unit == "player" or unit == "pet" then
		temp.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].raid_target[info[#info]]
		end
		temp.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].raid_target[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].raid_target[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
			end
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].raid_target, C.db.profile.units[unit][E.UI_LAYOUT].raid_target, {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
		end

		temp.args.point.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].raid_target.point1[info[#info]]
		end
		temp.args.point.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].raid_target.point1[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].raid_target.point1[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateRaidTargetIndicator")
			end
		end
	end

	return temp
end

local function getOptionsTable_DebuffIcons(order, unit)
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
				order = 9,
				type = "description",
				name = " ",
			},
			point = {
				order = 10,
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].debuff.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].debuff.point1[info[#info]] ~= value then
						C.db.profile.units[unit].debuff.point1[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateDebuffIndicator")
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
		},
	}

	if unit == "player" or unit == "pet" then
		temp.args.enabled.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].debuff.enabled
		end
		temp.args.enabled.set = function(_, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].debuff.enabled ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].debuff.enabled = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateDebuffIndicator")
			end
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].debuff, C.db.profile.units[unit][E.UI_LAYOUT].debuff, {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateDebuffIndicator")
		end

		temp.args.point.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].debuff.point1[info[#info]]
		end
		temp.args.point.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].debuff.point1[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].debuff.point1[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateDebuffIndicator")
			end
		end
	end

	return temp
end

local function getOptionsTable_Auras(order, unit)
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
			},
			copy = {
				order = 2,
				type = "select",
				name = L["COPY_FROM"],
				desc = L["COPY_FROM_DESC"],
				values = function() return UNITFRAMES:GetUnits({[unit] = true, ["player"] = true, ["pet"] = true, ["targettarget"] = true, ["focustarget"] = true}) end,
				get = function() end,
				set = function(_, value)
					CONFIG:CopySettings(C.db.profile.units[value].auras, C.db.profile.units[unit].auras, {["filter"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
			},
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].auras, C.db.profile.units[unit].auras, {["point"] = true, ["filter"] = true})
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
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
				min = 0, max = 64, step = 1,
				softMin = 24,
				set = function(info, value)
					if C.db.profile.units[unit].auras[info[#info]] ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end

						C.db.profile.units[unit].auras[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
					end
				end,
			},
			growth_dir = {
				order = 13,
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.units[unit].auras.x_growth .. "_" .. C.db.profile.units[unit].auras.y_growth
				end,
				set = function(_, value)
					C.db.profile.units[unit].auras.x_growth, C.db.profile.units[unit].auras.y_growth = s_split("_", value)
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
			},
			disable_mouse = {
				order = 14,
				type = "toggle",
				name = L["DISABLE_MOUSE"],
				desc = L["DISABLE_MOUSE_DESC"],
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
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
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
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
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			type = {
				order = 30,
				type = "group",
				name = "Aura Type",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.type[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.type[info[#info]] ~= value then
						C.db.profile.units[unit].auras.type[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
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
			spacer_4 = {
				order = 39,
				type = "description",
				name = " ",
			},
			count = {
				order = 40,
				type = "group",
				name = L["COUNT_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.count[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.count[info[#info]] ~= value then
						C.db.profile.units[unit].auras.count[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
					end
				end,
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["SIZE"],
						min = 10, max = 20, step = 2,
					},
					flag = {
						order = 2,
						type = "select",
						name = L["FLAG"],
						values = FLAGS,
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
			spacer_5 = {
				order = 49,
				type = "description",
				name = " ",
			},
			cooldown = {
				order = 50,
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.cooldown.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.cooldown.text[info[#info]] ~= value then
						C.db.profile.units[unit].auras.cooldown.text[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
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
						min = 10, max = 20, step = 2,
					},
					flag = {
						order = 3,
						type = "select",
						name = L["FLAG"],
						values = FLAGS,
					},
					v_alignment = {
						order = 4,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = V_ALIGNMENTS,
					},
				},
			},
			spacer_6 = {
				order = 59,
				type = "description",
				name = " ",
			},
			filter = {
				order = 60,
				type = "group",
				name = L["FILTERS"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
				args = {
					copy = {
						order = 1,
						type = "select",
						name = L["COPY_FROM"],
						desc = L["COPY_FROM_DESC"],
						values = function() return UNITFRAMES:GetUnits({[unit] = true, ["player"] = true, ["pet"] = true, ["targettarget"] = true, ["focustarget"] = true}) end,
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

	if unit == "player" then
		temp.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].auras[info[#info]]
		end
		temp.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].auras[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].auras[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
			end
		end

		temp.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[value].auras, C.db.profile.units[unit][E.UI_LAYOUT].auras, {["filter"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].auras, C.db.profile.units[unit][E.UI_LAYOUT].auras, {["point"] = true, ["filter"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end

		temp.args.size_override.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].auras[info[#info]] ~= value then
				if value < info.option.softMin then
					value = info.option.min
				end

				C.db.profile.units[unit][E.UI_LAYOUT].auras[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
			end
		end

		temp.args.growth_dir.get = function()
			return C.db.profile.units[unit][E.UI_LAYOUT].auras.x_growth .. "_" .. C.db.profile.units[unit][E.UI_LAYOUT].auras.y_growth
		end
		temp.args.growth_dir.set = function(_, value)
			C.db.profile.units[unit][E.UI_LAYOUT].auras.x_growth, C.db.profile.units[unit][E.UI_LAYOUT].auras.y_growth = s_split("_", value)
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end

		temp.args.point.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].auras.point1[info[#info]]
		end
		temp.args.point.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].auras.point1[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].auras.point1[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
			end
		end

		temp.args.type.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].auras.type[info[#info]]
		end
		temp.args.type.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].auras.type[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].auras.type[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
			end
		end

		temp.args.count.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].auras.count[info[#info]]
		end
		temp.args.count.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].auras.count[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].auras.count[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
			end
		end

		temp.args.cooldown.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].auras.cooldown.text[info[#info]]
		end
		temp.args.cooldown.set = function(info, value)
			if C.db.profile.units[unit][E.UI_LAYOUT].auras.cooldown.text[info[#info]] ~= value then
				C.db.profile.units[unit][E.UI_LAYOUT].auras.cooldown.text[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
			end
		end

		temp.args.filter.get = function(info)
			return C.db.profile.units[unit][E.UI_LAYOUT].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]]
		end
		temp.args.filter.set = function(info, value)
			C.db.profile.units[unit][E.UI_LAYOUT].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]] = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end

		temp.args.filter.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[value].auras.filter.friendly, C.db.profile.units[unit][E.UI_LAYOUT].auras.filter.friendly, {["player"] = true, ["player_permanent"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end

		temp.args.filter.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].auras.filter, C.db.profile.units[unit][E.UI_LAYOUT].auras.filter)
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
		end

		temp.args.filter.args.friendly.args.buff.args.selfcast_permanent.disabled = function()
			return not C.db.profile.units[unit][E.UI_LAYOUT].auras.filter.friendly.buff.selfcast
		end

		temp.args.filter.args.friendly.args.debuff.args.selfcast_permanent.disabled = function()
			return not C.db.profile.units[unit][E.UI_LAYOUT].auras.filter.friendly.debuff.selfcast
		end

		temp.args.filter.args.friendly.args.buff.args.player = nil
		temp.args.filter.args.friendly.args.buff.args.player_permanent = nil

		temp.args.filter.args.friendly.args.debuff.args.player = nil
		temp.args.filter.args.friendly.args.debuff.args.player_permanent = nil

		temp.args.filter.args.enemy = nil
	elseif unit == "boss" then
		temp.args.filter.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[value].auras.filter.friendly, C.db.profile.units[unit].auras.filter.friendly, {["mount"] = true, ["selfcast"] = true, ["selfcast_permanent"] = true})
			CONFIG:CopySettings(C.db.profile.units[value].auras.filter.enemy, C.db.profile.units[unit].auras.filter.enemy, {["mount"] = true, ["selfcast"] = true, ["selfcast_permanent"] = true})
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
			CONFIG:CopySettings(C.db.profile.units[value].auras.filter, C.db.profile.units[unit].auras.filter)
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
				order = 15,
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
				order = 16,
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
				order = 17,
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
				order = 18,
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
	temp.args.raid_target = getOptionsTable_RaidIcon(600, unit)
	temp.args.debuff = getOptionsTable_DebuffIcons(700, unit)
	temp.args.auras = getOptionsTable_Auras(800, unit)

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
			CONFIG:CopySettings(C.db.profile.units[value], C.db.profile.units[unit][E.UI_LAYOUT], {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "Update")
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT], C.db.profile.units[unit][E.UI_LAYOUT], {["point"] = true})
			UNITFRAMES:UpdateUnitFrame(unit, "Update")
		end

		if unit == "player" then
			temp.args.preview = nil
		end

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

		if unit == "player" then
			temp.args.class_power = {
				order = 300,
				type = "group",
				name = L["CLASS_POWER"],
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return C.db.profile.units[unit][E.UI_LAYOUT].class_power.enabled
						end,
						set = function(_, value)
							C.db.profile.units[unit][E.UI_LAYOUT].class_power.enabled = value
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateAdditionalPower")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassPower")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateRunes")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateStagger")
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					prediction = {
						order = 10,
						type = "toggle",
						name = L["COST_PREDICTION"],
						desc = L["COST_PREDICTION_DESC"],
						get = function()
							return C.db.profile.units[unit][E.UI_LAYOUT].class_power.prediction.enabled
						end,
						set = function(_, value)
							C.db.profile.units[unit][E.UI_LAYOUT].class_power.prediction.enabled = value
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")

						end,
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					runes = {
						order = 20,
						type = "group",
						name = L["RUNES"],
						inline = true,
						get = function(info)
							return C.db.profile.units[unit][E.UI_LAYOUT].class_power.runes[info[#info]]
						end,
						set = function(info, value)
							C.db.profile.units[unit][E.UI_LAYOUT].class_power.runes[info[#info]] = value
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateRunes")
						end,
						args = {
							color_by_spec = {
								order = 1,
								type = "toggle",
								name = L["COLOR_BY_SPEC"],
							},
							sort_order = {
								order = 2,
								type = "select",
								name = L["SORT_DIR"],
								values = {
									["none"] = L["NONE"],
									["asc"] = L["ASCENDING"],
									["desc"] = L["DESCENDING"],
								},
							},
						},
					},
				},
			}

			temp.args.combat_feedback = {
				order = 900,
				type = "group",
				name = L["FCF"],
				get = function(info)
					return C.db.profile.units[unit][E.UI_LAYOUT].combat_feedback[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[unit][E.UI_LAYOUT].combat_feedback[info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateCombatFeedback")
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
							CONFIG:CopySettings(D.profile.units[unit][E.UI_LAYOUT].combat_feedback, C.db.profile.units[unit][E.UI_LAYOUT].combat_feedback, {["point"] = true})
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateCombatFeedback")
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					x_offset = {
						order = 10,
						type = "range",
						name = L["X_OFFSET"],
						min = 0, max = 128, step = 1,
					},
					y_offset = {
						order = 12,
						type = "range",
						name = L["Y_OFFSET"],
						min = 0, max = 128, step = 1,
					},
					mode = {
						order = 13,
						type = "select",
						name = L["MODE"],
						values = FCF_MODES,
					},
				},
			}
		end

		if E.UI_LAYOUT == "ls" then
			temp.args.copy = nil
			temp.args.width = nil
			temp.args.height = nil
			temp.args.top_inset = nil
			temp.args.bottom_inset = nil
			temp.args.auras = nil

			temp.args.border.args.npc = nil

			if unit == "pet" then
				temp.args.border = nil
				temp.args.pvp = nil
				temp.args.name = nil
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
				temp.args.pvp = nil
				temp.args.auras = nil
			end
		end
	elseif unit == "target" then
		temp.disabled = function() return not UNITFRAMES:HasTargetFrame() end
		temp.args.preview = nil
	elseif unit == "targettarget" then
		temp.disabled = function() return not UNITFRAMES:HasTargetFrame() end
		temp.args.preview = nil
		temp.args.pvp = nil
		temp.args.castbar = nil
		temp.args.debuff = nil
		temp.args.auras = nil
	elseif unit == "focus" then
		temp.disabled = function() return not UNITFRAMES:HasFocusFrame() end
		temp.args.preview = nil
	elseif unit == "focustarget" then
		temp.disabled = function() return not UNITFRAMES:HasFocusFrame() end
		temp.args.preview = nil
		temp.args.pvp = nil
		temp.args.castbar = nil
		temp.args.debuff = nil
		temp.args.auras = nil
	elseif unit == "boss" then
		temp.disabled = function() return not UNITFRAMES:HasBossFrame() end
		temp.args.pvp = nil
		temp.args.debuff = nil

		temp.args.per_row = {
			order = 12,
			type = "range",
			name = L["PER_ROW"],
			min = 1, max = 5, step = 1,
			get = function()
				return C.db.profile.units[unit].per_row
			end,
			set = function(_, value)
				if C.db.profile.units[unit].per_row ~= value then
					C.db.profile.units[unit].per_row = value
					UNITFRAMES:UpdateBossHolder()
				end
			end,
		}

		temp.args.spacing = {
			order = 13,
			type = "range",
			name = L["SPACING"],
			min = 8, max = 64, step = 2,
			get = function()
				return C.db.profile.units[unit].spacing
			end,
			set = function(_, value)
				if C.db.profile.units[unit].spacing ~= value then
					C.db.profile.units[unit].spacing = value
					UNITFRAMES:UpdateBossHolder()
				end
			end,
		}

		temp.args.growth_dir = {
			order = 14,
			type = "select",
			name = L["GROWTH_DIR"],
			values = GROWTH_DIRS,
			get = function()
				return C.db.profile.units[unit].x_growth .. "_" .. C.db.profile.units[unit].y_growth
			end,
			set = function(_, value)
				C.db.profile.units[unit].x_growth, C.db.profile.units[unit].y_growth = s_split("_", value)
				UNITFRAMES:UpdateBossHolder()
			end,
		}

		temp.args.alt_power = {
			order = 300,
			type = "group",
			name = L["ALTERNATIVE_POWER"],
			args = {
				enabled = {
					order = 1,
					type = "toggle",
					name = L["ENABLE"],
					get = function()
						return C.db.profile.units[unit].alt_power.enabled
					end,
					set = function(_, value)
						C.db.profile.units[unit].alt_power.enabled = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
					end,
				},
				reset = {
					type = "execute",
					order = 2,
					name = L["RESTORE_DEFAULTS"],
					func = function()
						CONFIG:CopySettings(D.profile.units[unit].alt_power, C.db.profile.units[unit].alt_power, {["point"] = true})
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
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
						return C.db.profile.units[unit].alt_power.text.point1[info[#info]]
					end,
					set = function(info, value)
						if C.db.profile.units[unit].alt_power.text.point1[info[#info]] ~= value then
							C.db.profile.units[unit].alt_power.text.point1[info[#info]] = value
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
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
							values = getRegionAnchors(nil, {["AlternativePower"] = L["ALTERNATIVE_POWER"]}),
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
							desc = L["ALT_POWER_FORMAT_DESC"],
							get = function()
								return C.db.profile.units[unit].alt_power.text.tag:gsub("\124", "\124\124")
							end,
							set = function(_, value)
								if not CONFIG:IsTagStringValid(value) then return end

								C.db.profile.units[unit].alt_power.text.tag = value:gsub("\124\124+", "\124")
								UNITFRAMES:UpdateUnitFrame(unit, "UpdateConfig")
								UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
							end,
						},
					},
				},
			},
		}
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
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			units = {
				order = 10,
				type = "group",
				name = L["UNITS"],
				inline = true,
				disabled = isModuleDisabled,
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
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			cooldown = {
				order = 20,
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.units.cooldown[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units.cooldown[info[#info]] ~= value then
						C.db.profile.units.cooldown[info[#info]] = value
						UNITFRAMES:UpdateUnitFrames("UpdateConfig")
						UNITFRAMES:UpdateUnitFrames("UpdateAuras")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.units.cooldown, C.db.profile.units.cooldown)
							UNITFRAMES:UpdateUnitFrames("UpdateConfig")
							UNITFRAMES:UpdateUnitFrames("UpdateAuras")
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
						desc = L["EXP_THRESHOLD_DESC"],
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
							if C.db.profile.units.cooldown[info[#info]] ~= value then
								if value < info.option.softMin then
									value = info.option.min
								end

								C.db.profile.units.cooldown[info[#info]] = value
								UNITFRAMES:UpdateUnitFrames("UpdateConfig")
								UNITFRAMES:UpdateUnitFrames("UpdateAuras")
							end
						end,
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					colors = {
						order = 20,
						type = "group",
						name = L["COLORS"],
						inline = true,
						get = function(info)
							return unpack(C.db.profile.units.cooldown.colors[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.units.cooldown.colors[info[#info]]
								if color[1] ~= r or color[2] ~= g or color[3] ~= b then
									color[1], color[2], color[3] = r, g, b
									UNITFRAMES:UpdateUnitFrames("UpdateConfig")
									UNITFRAMES:UpdateUnitFrames("UpdateAuras")
								end
							end
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["ENABLE"],
								get = function()
									return C.db.profile.units.cooldown.colors.enabled
								end,
								set = function(_, value)
									C.db.profile.units.cooldown.colors.enabled = value
									UNITFRAMES:UpdateUnitFrames("UpdateConfig")
									UNITFRAMES:UpdateUnitFrames("UpdateAuras")
								end,
							},
							expiration = {
								order = 2,
								type = "color",
								name = L["EXPIRATION"],
							},
							second = {
								order = 3,
								type = "color",
								name = L["SECONDS"],
							},
							minute = {
								order = 4,
								type = "color",
								name = L["MINUTES"],
							},
							hour = {
								order = 5,
								type = "color",
								name = L["HOURS"],
							},
							day = {
								order = 6,
								type = "color",
								name = L["DAYS"],
							},
						},
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			castbar = {
				order = 30,
				type = "group",
				name = L["CASTBAR"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return unpack(C.db.profile.units.castbar.colors[info[#info]])
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.profile.units.castbar.colors[info[#info]]
						if color[1] ~= r or color[2] ~= g or color[3] ~= b then
							color[1], color[2], color[3] = r, g, b
							UNITFRAMES:UpdateUnitFrames("UpdateConfig")
							UNITFRAMES:UpdateUnitFrames("ForElement", "Castbar", "UpdateConfig")
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.units.castbar.colors, C.db.profile.units.castbar.colors)
							UNITFRAMES:UpdateUnitFrames("UpdateConfig")
							UNITFRAMES:UpdateUnitFrames("ForElement", "Castbar", "UpdateConfig")
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					casting = {
						order = 10,
						type = "color",
						name = L["SPELL_CAST"],
					},
					channeling = {
						order = 11,
						type = "color",
						name = L["SPELL_CHANNELED"],
					},
					failed = {
						order = 12,
						type = "color",
						name = L["SPELL_FAILED"],
					},
					notinterruptible = {
						order = 13,
						type = "color",
						name = L["SPELL_UNINTERRUPTIBLE"],
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
