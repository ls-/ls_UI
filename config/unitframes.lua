local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local UNITFRAMES = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_split = _G.string.split
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local tostring = _G.tostring

local function isModuleDisabled()
	return not UNITFRAMES:IsInit()
end

local function isPlayerFrameDisabled()
	return not UNITFRAMES:HasPlayerFrame()
end

local function isTargetFrameDisabled()
	return not UNITFRAMES:HasTargetFrame()
end

local function isFocusFrameDisabled()
	return not UNITFRAMES:HasFocusFrame()
end

local function isBossFrameDisabled()
	return not UNITFRAMES:HasBossFrame()
end

local resetIgnoredKeys = {
	["point"] = true,
}

local aurasResetIgnoredKeys = {
	["point"] = true,
	["filter"] = true,
}

local function getUFOption_Copy(order, unit)
	local ignoredUnits = {
		[unit] = true,
		["pet"] = true,
		["player"] = true,
	}

	return {
		order = order,
		type = "select",
		name = L["COPY_FROM"],
		desc = L["COPY_FROM_DESC"],
		values = function()
			return UNITFRAMES:GetUnits(ignoredUnits)
		end,
		get = function() end,
		set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[value], C.db.profile.units[unit], resetIgnoredKeys)
			UNITFRAMES:UpdateUnitFrame(unit, "Update")
		end,
	}
end

local function getUFOption_Preview(order, unit)
	return {
		order = order,
		type = "execute",
		name = L["PREVIEW"],
		func = function()
			UNITFRAMES:UpdateUnitFrame(unit, "Preview")
		end,
	}
end

local function getUFOption_PvPIndicator(order, unit)
	return {
		order = order,
		type = "toggle",
		name = L["PVP_ICON"],
		get = function()
			return C.db.profile.units[unit].pvp.enabled
		end,
		set = function(_, value)
			C.db.profile.units[unit].pvp.enabled = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
		end,
	}
end

local function getUFOption_Border(order, unit)
	local temp = {
		order = order,
		type = "group",
		name = L["BORDER_COLOR"],
		inline = true,
		get = function(info)
			return C.db.profile.units[unit].border.color[info[#info]]
		end,
		set = function(info, value)
			C.db.profile.units[unit].border.color[info[#info]] = value
			UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassIndicator")
		end,
		args = {
			class = {
				order = 1,
				type = "toggle",
				name = L["CLASS"],
			},
			reaction = {
				order = 2,
				type = "toggle",
				name = L["REACTION"],
			},
		},
	}

	return temp
end

local function getUFOption_Width(order, unit)
	return {
		order = order,
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
	}
end

local function getUFOption_Height(order, unit)
	return {
		order = order,
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
	}
end

local function getUFOption_TopInset(order, unit)
	return {
		order = order,
		type = "range",
		name = L["TOP_INSET_SIZE"],
		desc = L["TOP_INSET_SIZE_DESC"],
		min = 8, max = 88, step = 2,
		get = function()
			return C.db.profile.units[unit].insets.t_height
		end,
		set = function(_, value)
			if C.db.profile.units[unit].insets.t_height ~= value then
				C.db.profile.units[unit].insets.t_height = value
				UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Insets", "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Insets", "UpdateTopInset")
			end
		end,
	}
end

local function getUFOption_BottomInset(order, unit)
	return {
		order = order,
		type = "range",
		name = L["BOTTOM_INSET_SIZE"],
		desc = L["BOTTOM_INSET_SIZE_DESC"],
		min = 8, max = 88, step = 2,
		get = function()
			return C.db.profile.units[unit].insets.b_height
		end,
		set = function(_, value)
			if C.db.profile.units[unit].insets.b_height ~= value then
				C.db.profile.units[unit].insets.b_height = value
				UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Insets", "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Insets", "UpdateBottomInset")
			end
		end,
	}
end

local function getUFOption_Health(order, unit)
	local ignoredAnchors = {
		["Health.Text"] = true
	}

	local temp = {
		order = order,
		type = "group",
		name = L["HEALTH"],
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].health, C.db.profile.units[unit].health, resetIgnoredKeys)
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
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateColors")
				end,
				args = {
					class = {
						order = 1,
						type = "toggle",
						name = L["CLASS"],
					},
				},
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			change_threshold = {
				order = 20,
				type = "input",
				name = L["GAIN_LOSS_THRESHOLD"],
				desc = L["GAIN_LOSS_THRESHOLD_DESC"],
				get = function()
					return tostring(C.db.profile.units[unit].health.change_threshold * 100)
				end,
				set = function(_, value)
					C.db.profile.units[unit].health.change_threshold = E:Clamp((tonumber(value) or 0.1) / 100, 0.001, 1)
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateGainLossThreshold")
				end,
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			text = {
				order = 30,
				type = "group",
				name = L["BAR_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].health.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].health.text[info[#info]] ~= value then
						C.db.profile.units[unit].health.text[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateFonts")
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
						order = 4,
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = CONFIG.H_ALIGNMENTS,
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
							return C.db.profile.units[unit].health.text.point1[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].health.text.point1[info[#info]] ~= value then
								C.db.profile.units[unit].health.text.point1[info[#info]] = value
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateConfig")
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateTextPoints")
							end
						end,
						args = {
							p = {
								order = 4,
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = CONFIG.POINTS,
							},
							anchor = {
								order = 5,
								type = "select",
								name = L["ANCHOR"],
								values = CONFIG:GetRegionAnchors(ignoredAnchors),
							},
							rP = {
								order = 6,
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = CONFIG.POINTS,
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
						},
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					tag = {
						order = 20,
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
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Health", "UpdateTags")
						end,
					},
				},
			},
			spacer_4 = {
				order = 39,
				type = "description",
				name = " ",
			},
			prediction = {
				order = 40,
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
							return C.db.profile.units[unit].health.prediction.absorb_text[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].health.prediction.absorb_text[info[#info]] ~= value then
								C.db.profile.units[unit].health.prediction.absorb_text[info[#info]] = value
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateConfig")
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateFonts")
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
								order = 4,
								type = "select",
								name = L["TEXT_HORIZ_ALIGNMENT"],
								values = CONFIG.H_ALIGNMENTS,
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
									return C.db.profile.units[unit].health.prediction.absorb_text.point1[info[#info]]
								end,
								set = function(info, value)
									if C.db.profile.units[unit].health.prediction.absorb_text.point1[info[#info]] ~= value then
										C.db.profile.units[unit].health.prediction.absorb_text.point1[info[#info]] = value
										UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateConfig")
										UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateTextPoints")
									end
								end,
								args = {
									p = {
										order = 1,
										type = "select",
										name = L["POINT"],
										desc = L["POINT_DESC"],
										values = CONFIG.POINTS,
									},
									anchor = {
										order = 2,
										type = "select",
										name = L["ANCHOR"],
										values = CONFIG:GetRegionAnchors(),
									},
									rP = {
										order = 3,
										type = "select",
										name = L["RELATIVE_POINT"],
										desc = L["RELATIVE_POINT_DESC"],
										values = CONFIG.POINTS,
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
							tag = {
								order = 20,
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
									UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateConfig")
									UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateTags")
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
							return C.db.profile.units[unit].health.prediction.heal_absorb_text[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].health.prediction.heal_absorb_text[info[#info]] ~= value then
								C.db.profile.units[unit].health.prediction.heal_absorb_text[info[#info]] = value
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateConfig")
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateFonts")
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
								order = 4,
								type = "select",
								name = L["TEXT_HORIZ_ALIGNMENT"],
								values = CONFIG.H_ALIGNMENTS,
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
									return C.db.profile.units[unit].health.prediction.heal_absorb_text.point1[info[#info]]
								end,
								set = function(info, value)
									if C.db.profile.units[unit].health.prediction.heal_absorb_text.point1[info[#info]] ~= value then
										C.db.profile.units[unit].health.prediction.heal_absorb_text.point1[info[#info]] = value
										UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateConfig")
										UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateTextPoints")
									end
								end,
								args = {
									p = {
										order = 1,
										type = "select",
										name = L["POINT"],
										desc = L["POINT_DESC"],
										values = CONFIG.POINTS,
									},
									anchor = {
										order = 2,
										type = "select",
										name = L["ANCHOR"],
										values = CONFIG:GetRegionAnchors(),
									},
									rP = {
										order = 3,
										type = "select",
										name = L["RELATIVE_POINT"],
										desc = L["RELATIVE_POINT_DESC"],
										values = CONFIG.POINTS,
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
							tag = {
								order = 20,
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
									UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateConfig")
									UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "HealthPrediction", "UpdateTags")
								end,
							},
						},
					},
				},
			},
		},
	}

	if unit ~= "player" and unit ~= "pet" then
		temp.args.color.args.reaction = {
			order = 2,
			type = "toggle",
			name = L["REACTION"],
		}
	end

	return temp
end

local function getUFOption_Power(order, unit)
	local ignoredAnchors = {
		["Power.Text"] = true
	}

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
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].power, C.db.profile.units[unit].power, resetIgnoredKeys)
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePower")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			change_threshold = {
				order = 10,
				type = "input",
				name = L["GAIN_LOSS_THRESHOLD"],
				desc = L["GAIN_LOSS_THRESHOLD_DESC"],
				get = function()
					return tostring(C.db.profile.units[unit].power.change_threshold * 100)
				end,
				set = function(_, value)
					C.db.profile.units[unit].power.change_threshold = E:Clamp((tonumber(value) or 0.1) / 100, 0.001, 1)
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Power", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Power", "UpdateGainLossThreshold")
				end,
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
					return C.db.profile.units[unit].power.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].power.text[info[#info]] ~= value then
						C.db.profile.units[unit].power.text[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Power", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Power", "UpdateFonts")
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
						order = 4,
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = CONFIG.H_ALIGNMENTS,
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
							return C.db.profile.units[unit].power.text.point1[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].power.text.point1[info[#info]] ~= value then
								C.db.profile.units[unit].power.text.point1[info[#info]] = value
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Power", "UpdateConfig")
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Power", "UpdateTextPoints")
							end
						end,
						args = {
							p = {
								order = 4,
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = CONFIG.POINTS,
							},
							anchor = {
								order = 5,
								type = "select",
								name = L["ANCHOR"],
								values = CONFIG:GetRegionAnchors(ignoredAnchors),
							},
							rP = {
								order = 6,
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = CONFIG.POINTS,
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
						},
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			tag = {
				order = 30,
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
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Power", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Power", "UpdateTags")
				end,
			},
		},
	}

	if unit == "player" then
		temp.args.spacer_3 = {
			order = 29,
			type = "description",
			name = " ",
		}

		temp.args.prediction = {
			order = 30,
			type = "toggle",
			name = L["COST_PREDICTION"],
			desc = L["COST_PREDICTION_DESC"],
			get = function()
				return C.db.profile.units[unit].power.prediction.enabled
			end,
			set = function(_, value)
				C.db.profile.units[unit].power.prediction.enabled = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
			end,
		}
	end

	return temp
end

local function getUFOption_AlternativePower(order, unit)
	local additonalAnchors = {
		["AlternativePower"] = L["ALTERNATIVE_POWER"]
	}

	local temp = {
		order = order,
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
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].alt_power, C.db.profile.units[unit].alt_power, resetIgnoredKeys)
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAlternativePower")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			change_threshold = {
				order = 10,
				type = "input",
				name = L["GAIN_LOSS_THRESHOLD"],
				desc = L["GAIN_LOSS_THRESHOLD_DESC"],
				get = function()
					return tostring(C.db.profile.units[unit].alt_power.change_threshold * 100)
				end,
				set = function(_, value)
					C.db.profile.units[unit].alt_power.change_threshold = E:Clamp((tonumber(value) or 0.1) / 100, 0.001, 1)
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AlternativePower", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AlternativePower", "UpdateGainLossThreshold")
				end,
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
					return C.db.profile.units[unit].alt_power.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].alt_power.text[info[#info]] ~= value then
						C.db.profile.units[unit].alt_power.text[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AlternativePower", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AlternativePower", "UpdateFonts")
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
						order = 4,
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = CONFIG.H_ALIGNMENTS,
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
							return C.db.profile.units[unit].alt_power.text.point1[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].alt_power.text.point1[info[#info]] ~= value then
								C.db.profile.units[unit].alt_power.text.point1[info[#info]] = value
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AlternativePower", "UpdateConfig")
								UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AlternativePower", "UpdateTextPoints")
							end
						end,
						args = {
							p = {
								order = 4,
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = CONFIG.POINTS,
							},
							anchor = {
								order = 5,
								type = "select",
								name = L["ANCHOR"],
								values = CONFIG:GetRegionAnchors(nil, additonalAnchors),
							},
							rP = {
								order = 6,
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = CONFIG.POINTS,
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
						},
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			tag = {
				order = 30,
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
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AlternativePower", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AlternativePower", "UpdateTags")
				end,
			},
		},
	}

	return temp
end

local function getUFOption_ClassPower(order, unit)
	return {
		order = order,
		type = "group",
		name = L["CLASS_POWER"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].class_power.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].class_power.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAdditionalPower")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassPower")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateRunes")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateStagger")
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].class_power, C.db.profile.units[unit].class_power, resetIgnoredKeys)
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
			change_threshold = {
				order = 10,
				type = "input",
				name = L["GAIN_LOSS_THRESHOLD"],
				desc = L["GAIN_LOSS_THRESHOLD_DESC"],
				get = function()
					return tostring(C.db.profile.units[unit].class_power.change_threshold * 100)
				end,
				set = function(_, value)
					C.db.profile.units[unit].class_power.change_threshold = E:Clamp((tonumber(value) or 0.1) / 100, 0.001, 1)
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Stagger", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Stagger", "UpdateGainLossThreshold")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AdditionalPower", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "AdditionalPower", "UpdateGainLossThreshold")
				end,
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			prediction = {
				order = 20,
				type = "toggle",
				name = L["COST_PREDICTION"],
				desc = L["COST_PREDICTION_DESC"],
				get = function()
					return C.db.profile.units[unit].class_power.prediction.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].class_power.prediction.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePowerPrediction")

				end,
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			runes = {
				order = 30,
				type = "group",
				name = L["RUNES"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].class_power.runes[info[#info]]
				end,
				args = {
					color_by_spec = {
						order = 1,
						type = "toggle",
						name = L["COLOR_BY_SPEC"],
						set = function(_, value)
							C.db.profile.units[unit].class_power.runes.color_by_spec = value
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Runes", "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Runes", "UpdateColors")
						end,
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
						set = function(_, value)
							C.db.profile.units[unit].class_power.runes.sort_order = value
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Runes", "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Runes", "UpdateSortOrder")
						end,
					},
				},
			},
		},
	}
end

local function getUFOption_Castbar(order, unit)
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
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].castbar, C.db.profile.units[unit].castbar, resetIgnoredKeys)
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
					if C.db.profile.units[unit].castbar.width_override ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end

						C.db.profile.units[unit].castbar.width_override = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateSize")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdatePvPIndicator")
					end
				end,
			},
			height = {
				order = 12,
				type = "range",
				name = L["HEIGHT"],
				min = 8, max = 32, step = 4,
				set = function(_, value)
					if C.db.profile.units[unit].castbar.height ~= value then
						C.db.profile.units[unit].castbar.height = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateSize")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateIcon")
					end
				end,
			},
			icon = {
				order = 14,
				type = "select",
				name = L["ICON"],
				values = CONFIG.CASTBAR_ICON_POSITIONS,
				get = function()
					return C.db.profile.units[unit].castbar.icon.position
				end,
				set = function(_, value)
					if C.db.profile.units[unit].castbar.icon.position ~= value then
						C.db.profile.units[unit].castbar.icon.position = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateIcon")
					end
				end,
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			text = {
				order = 20,
				type = "group",
				name = L["TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].castbar.text[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[unit].castbar.text[info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateFonts")
				end,
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
				},
			},
		},
	}

	if unit == "player" or unit == "pet" then
		if E.UI_LAYOUT == "ls" then
			temp.args.detached = nil
			temp.args.width_override.name = L["WIDTH"]
		end

		temp.args.latency = {
			order = 13,
			type = "toggle",
			name = L["LATENCY"],
			set = function(_, value)
				if C.db.profile.units[unit].castbar.latency ~= value then
					C.db.profile.units[unit].castbar.latency = value
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Castbar", "UpdateLatency")
				end
			end,
		}
	end

	return temp
end

local function getUFOption_Name(order, unit)
	local function isSecondaryAnchorDisabled()
		return C.db.profile.units[unit].name.point2.p == ""
	end

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
				UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Name", "UpdateConfig")
				UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Name", "UpdateFonts")
			end
		end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].name, C.db.profile.units[unit].name, resetIgnoredKeys)
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
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Name", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Name", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS,
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["ANCHOR"],
						values = CONFIG:GetRegionAnchors(),
					},
					rP = {
						order = 3,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
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
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Name", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Name", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS_EXT,
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["ANCHOR"],
						values = CONFIG:GetRegionAnchors(),
						disabled = isSecondaryAnchorDisabled,
					},
					rP = {
						order = 3,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
						disabled = isSecondaryAnchorDisabled,
					},
					x = {
						order = 4,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
						disabled = isSecondaryAnchorDisabled,
					},
					y = {
						order = 5,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
						disabled = isSecondaryAnchorDisabled,
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			size = {
				order = 30,
				type = "range",
				name = L["SIZE"],
				min = 8, max = 48, step = 1,
			},
			h_alignment = {
				order = 33,
				type = "select",
				name = L["TEXT_HORIZ_ALIGNMENT"],
				values = CONFIG.H_ALIGNMENTS,
			},
			v_alignment = {
				order = 34,
				type = "select",
				name = L["TEXT_VERT_ALIGNMENT"],
				values = CONFIG.V_ALIGNMENTS,
				disabled = isSecondaryAnchorDisabled,
			},
			word_wrap = {
				order = 35,
				type = "toggle",
				name = L["WORD_WRAP"],
				disabled = isSecondaryAnchorDisabled,
			},
			spacer_4 = {
				order = 39,
				type = "description",
				name = " ",
			},
			tag = {
				order = 40,
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
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Name", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Name", "UpdateTags")
				end,
			},
		},
	}

	return temp
end

local function getUFOption_RaidTargetIndicator(order, unit)
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
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].raid_target, C.db.profile.units[unit].raid_target, resetIgnoredKeys)
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
				set = function(info, value)
					if C.db.profile.units[unit].raid_target[info[#info]] ~= value then
						C.db.profile.units[unit].raid_target[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "RaidTargetIndicator", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "RaidTargetIndicator", "UpdateSize")
					end
				end,
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
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "RaidTargetIndicator", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "RaidTargetIndicator", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS,
					},
					rP = {
						order = 2,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
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

	return temp
end

local function getUFOption_DebuffIcons(order, unit)
	local ignoredAnchors = {
		["Health.Text"] = true,
		["Power"] = true,
		["Power.Text"] = true,
	}

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
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateDebuffIndicator")
					end
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].debuff, C.db.profile.units[unit].debuff, resetIgnoredKeys)
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateDebuffIndicator")
				end,
			},
			preview = {
				type = "execute",
				order = 3,
				name = L["PREVIEW"],
				func = function()
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "DebuffIndicator", "Preview")
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
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "DebuffIndicator", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "DebuffIndicator", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS,
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["ANCHOR"],
						values = CONFIG:GetRegionAnchors(ignoredAnchors),
					},
					rP = {
						order = 3,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
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

	return temp
end

local customAuraFilters = {}
do
	local filterCache = {}

	function CONFIG:UpdateUFAuraFilters()
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

local function getUFOption_Auras(order, unit)
	local copyIgnoredKeys = {
		["filter"] = true,
	}

	local ignoredUnits = {
		[unit] = true,
		["player"] = true,
		["pet"] = true,
		["targettarget"] = true,
		["focustarget"] = true
	}

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
				values = function()
					return UNITFRAMES:GetUnits(ignoredUnits)
				end,
				get = function() end,
				set = function(_, value)
					CONFIG:CopySettings(C.db.profile.units[value].auras, C.db.profile.units[unit].auras, copyIgnoredKeys)
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateAuras")
				end,
			},
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].auras, C.db.profile.units[unit].auras, aurasResetIgnoredKeys)
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
				set = function(_, value)
					if C.db.profile.units[unit].auras.rows ~= value then
						C.db.profile.units[unit].auras.rows = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateSize")
					end
				end,
			},
			per_row = {
				order = 11,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 10, step = 1,
				set = function(_, value)
					if C.db.profile.units[unit].auras.per_row ~= value then
						C.db.profile.units[unit].auras.per_row = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateSize")
					end
				end,
			},
			size_override = {
				order = 12,
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
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateSize")
					end
				end,
			},
			growth_dir = {
				order = 13,
				type = "select",
				name = L["GROWTH_DIR"],
				values = CONFIG.GROWTH_DIRS,
				get = function()
					return C.db.profile.units[unit].auras.x_growth .. "_" .. C.db.profile.units[unit].auras.y_growth
				end,
				set = function(_, value)
					C.db.profile.units[unit].auras.x_growth, C.db.profile.units[unit].auras.y_growth = s_split("_", value)
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateGrowthDirection")
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
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS,
					},
					rP = {
						order = 2,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
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
				name = L["AURA_TYPE"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].auras.type[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].auras.type[info[#info]] ~= value then
						C.db.profile.units[unit].auras.type[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateAuraTypeIcon")
					end
				end,
				args = {
					debuff_type = {
						order = 1,
						type = "toggle",
						name = L["DEBUFF_TYPE"],
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
						values = CONFIG.POINTS,
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
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateFontObjects")
					end
				end,
				args = {
					size = {
						order = 1,
						type = "range",
						name = L["SIZE"],
						min = 10, max = 20, step = 2,
					},
					outline = {
						order = 2,
						type = "toggle",
						name = L["OUTLINE"],
					},
					shadow = {
						order = 3,
						type = "toggle",
						name = L["SHADOW"],
					},
					h_alignment = {
						order = 4,
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = CONFIG.H_ALIGNMENTS,
					},
					v_alignment = {
						order = 5,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = CONFIG.V_ALIGNMENTS,
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
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateCooldownConfig")
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
						values = CONFIG.FLAGS,
					},
					v_alignment = {
						order = 4,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = CONFIG.V_ALIGNMENTS,
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
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
					UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
				end,
				args = {
					copy = {
						order = 1,
						type = "select",
						name = L["COPY_FROM"],
						desc = L["COPY_FROM_DESC"],
						values = function()
							return UNITFRAMES:GetUnits(ignoredUnits)
						end,
						get = function() end,
					},
					reset = {
						type = "execute",
						order = 2,
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.units[unit].auras.filter, C.db.profile.units[unit].auras.filter)
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
						end,
					},
					custom = {
						order = 2,
						type = "group",
						inline = true,
						name = L["USER_CREATED"],
						get = function(info)
							return C.db.profile.units[unit].auras.filter[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.units[unit].auras.filter[info[#info - 1]][info[#info]] = value
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
							UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
						end,
						args = customAuraFilters,
					},
					friendly = {
						order = 3,
						type = "group",
						inline = true,
						name = "|c" .. C.db.global.colors.green.hex .. L["FRIENDLY_UNITS"] .. "|r",
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
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.friendly.buff.selfcast
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
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.friendly.buff.player
										end,
									},
									misc = {
										order = 9,
										type = "toggle",
										name = L["MISC"],
									},
								},
							},
							spacer_1 = {
								order = 2,
								type = "description",
								name = " ",
							},
							debuff = {
								order = 3,
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
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.friendly.debuff.selfcast
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
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.friendly.debuff.player
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
							},
						},
					},
					enemy = {
						order = 4,
						type = "group",
						inline = true,
						name = "|c" .. C.db.global.colors.red.hex .. L["ENEMY_UNITS"] .. "|r",
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
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.enemy.buff.selfcast
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
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.enemy.buff.player
										end,
									},
									dispellable = {
										order = 9,
										type = "toggle",
										name = L["DISPELLABLE_BUFFS"],
										desc = L["DISPELLABLE_BUFFS_DESC"],
									},
									misc = {
										order = 10,
										type = "toggle",
										name = L["MISC"],
									},
								},
							},
							spacer_1 = {
								order = 2,
								type = "description",
								name = " ",
							},
							debuff = {
								order = 3,
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
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.enemy.debuff.selfcast
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
										disabled = function()
											return not C.db.profile.units[unit].auras.filter.enemy.debuff.player
										end,
									},
									misc = {
										order = 8,
										type = "toggle",
										name = L["MISC"],
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
		local ignoredFilters = {
			["player"] = true,
			["player_permanent"] = true,
		}

		temp.args.filter.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[value].auras.filter.friendly, C.db.profile.units[unit].auras.filter.friendly, ignoredFilters)
			UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
		end

		temp.args.filter.args.friendly.args.buff.args.player = nil
		temp.args.filter.args.friendly.args.buff.args.player_permanent = nil

		temp.args.filter.args.friendly.args.debuff.args.player = nil
		temp.args.filter.args.friendly.args.debuff.args.player_permanent = nil

		temp.args.filter.args.enemy = nil
	elseif unit == "boss" then
		local ignoredFilters = {
			["mount"] = true,
			["selfcast"] = true,
			["selfcast_permanent"] = true,
		}

		temp.args.filter.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[value].auras.filter.friendly, C.db.profile.units[unit].auras.filter.friendly, ignoredFilters)
			CONFIG:CopySettings(C.db.profile.units[value].auras.filter.enemy, C.db.profile.units[unit].auras.filter.enemy, ignoredFilters)
			UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
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
			UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "UpdateConfig")
			UNITFRAMES:UpdateUnitFrame(unit, "ForElement", "Auras", "ForceUpdate")
		end
	end

	return temp
end

local function getUFOption_Portrait(order, unit)
	local temp = {
		order = order,
		type = "group",
		name = L["PORTRAIT"],
		get = function(info)
			return C.db.profile.units[unit].portrait[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].portrait[info[#info]] ~= value then
				C.db.profile.units[unit].portrait[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit, "UpdatePortrait")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassPower")
				UNITFRAMES:UpdateUnitFrame(unit, "UpdateRunes")
			end
		end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].portrait.enabled
				end,
				set = function(_, value)
					if C.db.profile.units[unit].portrait.enabled ~= value then
						C.db.profile.units[unit].portrait.enabled = value
						UNITFRAMES:UpdateUnitFrame(unit, "UpdatePortrait")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassPower")
						UNITFRAMES:UpdateUnitFrame(unit, "UpdateRunes")
					end
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].portrait, C.db.profile.units[unit].portrait, resetIgnoredKeys)
					UNITFRAMES:UpdateUnitFrame(unit, "UpdatePortrait")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateClassPower")
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateRunes")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			style = {
				order = 10,
				type = "select",
				name = L["STYLE"],
				values = CONFIG.PORTRAIT_STYLES,
			},
			position = {
				order = 11,
				type = "select",
				name = L["POSITION"],
				values = CONFIG.PORTRAIT_POSITIONS,
			},
		},
	}

	return temp
end

local function getUFOptions(order, unit, name)
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
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit], C.db.profile.units[unit], resetIgnoredKeys)
					UNITFRAMES:UpdateUnitFrame(unit, "Update")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
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
					UNITFRAMES:UpdateUnitFrame(unit, "UpdateThreatIndicator")
				end,
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
		},
	}

	if unit == "player" then
		temp.disabled = isPlayerFrameDisabled
		temp.args.pvp = getUFOption_PvPIndicator(18, unit)
		temp.args.border = getUFOption_Border(20, unit)
		temp.args.health = getUFOption_Health(100, unit)
		temp.args.power = getUFOption_Power(200, unit)
		temp.args.class_power = getUFOption_ClassPower(300, unit)
		temp.args.castbar = getUFOption_Castbar(400, unit)
		temp.args.name = getUFOption_Name(600, unit)
		temp.args.raid_target = getUFOption_RaidTargetIndicator(700, unit)
		temp.args.debuff = getUFOption_DebuffIcons(800, unit)

		if E.UI_LAYOUT == "traditional" then
			temp.args.copy = getUFOption_Copy(2, unit)
			temp.args.width = getUFOption_Width(10, unit)
			temp.args.height = getUFOption_Height(11, unit)
			temp.args.top_inset = getUFOption_TopInset(15, unit)
			temp.args.bottom_inset = getUFOption_BottomInset(16, unit)
			temp.args.portrait = getUFOption_Portrait(500, unit)
			temp.args.auras = getUFOption_Auras(900, unit)
		end
	elseif unit == "pet" then
		temp.disabled = isPlayerFrameDisabled
		temp.args.preview = getUFOption_Preview(4, unit)
		temp.args.health = getUFOption_Health(100, unit)
		temp.args.power = getUFOption_Power(200, unit)
		temp.args.castbar = getUFOption_Castbar(400, unit)
		temp.args.raid_target = getUFOption_RaidTargetIndicator(700, unit)
		temp.args.debuff = getUFOption_DebuffIcons(800, unit)

		if E.UI_LAYOUT == "traditional" then
			temp.args.copy = getUFOption_Copy(2, unit)
			temp.args.width = getUFOption_Width(10, unit)
			temp.args.height = getUFOption_Height(11, unit)
			temp.args.top_inset = getUFOption_TopInset(15, unit)
			temp.args.bottom_inset = getUFOption_BottomInset(16, unit)
			temp.args.border = getUFOption_Border(20, unit)
			temp.args.portrait = getUFOption_Portrait(500, unit)
			temp.args.name = getUFOption_Name(600, unit)
		end
	elseif unit == "target" then
		temp.disabled = isTargetFrameDisabled
		temp.args.copy = getUFOption_Copy(2, unit)
		temp.args.width = getUFOption_Width(10, unit)
		temp.args.height = getUFOption_Height(11, unit)
		temp.args.top_inset = getUFOption_TopInset(15, unit)
		temp.args.bottom_inset = getUFOption_BottomInset(16, unit)
		temp.args.pvp = getUFOption_PvPIndicator(18, unit)
		temp.args.border = getUFOption_Border(20, unit)
		temp.args.health = getUFOption_Health(100, unit)
		temp.args.power = getUFOption_Power(200, unit)
		temp.args.castbar = getUFOption_Castbar(400, unit)
		temp.args.portrait = getUFOption_Portrait(500, unit)
		temp.args.name = getUFOption_Name(600, unit)
		temp.args.raid_target = getUFOption_RaidTargetIndicator(700, unit)
		temp.args.debuff = getUFOption_DebuffIcons(800, unit)
		temp.args.auras = getUFOption_Auras(900, unit)
	elseif unit == "targettarget" then
		temp.disabled = isTargetFrameDisabled
		temp.args.copy = getUFOption_Copy(2, unit)
		temp.args.width = getUFOption_Width(10, unit)
		temp.args.height = getUFOption_Height(11, unit)
		temp.args.top_inset = getUFOption_TopInset(15, unit)
		temp.args.bottom_inset = getUFOption_BottomInset(16, unit)
		temp.args.border = getUFOption_Border(20, unit)
		temp.args.health = getUFOption_Health(100, unit)
		temp.args.power = getUFOption_Power(200, unit)
		temp.args.portrait = getUFOption_Portrait(500, unit)
		temp.args.name = getUFOption_Name(600, unit)
		temp.args.raid_target = getUFOption_RaidTargetIndicator(700, unit)
	elseif unit == "focus" then
		temp.disabled = isFocusFrameDisabled
		temp.args.copy = getUFOption_Copy(2, unit)
		temp.args.width = getUFOption_Width(10, unit)
		temp.args.height = getUFOption_Height(11, unit)
		temp.args.top_inset = getUFOption_TopInset(15, unit)
		temp.args.bottom_inset = getUFOption_BottomInset(16, unit)
		temp.args.pvp = getUFOption_PvPIndicator(18, unit)
		temp.args.border = getUFOption_Border(20, unit)
		temp.args.health = getUFOption_Health(100, unit)
		temp.args.power = getUFOption_Power(200, unit)
		temp.args.castbar = getUFOption_Castbar(400, unit)
		temp.args.portrait = getUFOption_Portrait(500, unit)
		temp.args.name = getUFOption_Name(600, unit)
		temp.args.raid_target = getUFOption_RaidTargetIndicator(700, unit)
		temp.args.debuff = getUFOption_DebuffIcons(800, unit)
		temp.args.auras = getUFOption_Auras(900, unit)
	elseif unit == "focustarget" then
		temp.disabled = isFocusFrameDisabled
		temp.args.copy = getUFOption_Copy(2, unit)
		temp.args.width = getUFOption_Width(10, unit)
		temp.args.height = getUFOption_Height(11, unit)
		temp.args.top_inset = getUFOption_TopInset(15, unit)
		temp.args.bottom_inset = getUFOption_BottomInset(16, unit)
		temp.args.border = getUFOption_Border(20, unit)
		temp.args.health = getUFOption_Health(100, unit)
		temp.args.power = getUFOption_Power(200, unit)
		temp.args.portrait = getUFOption_Portrait(500, unit)
		temp.args.name = getUFOption_Name(600, unit)
		temp.args.raid_target = getUFOption_RaidTargetIndicator(700, unit)
	elseif unit == "boss" then
		temp.disabled = isBossFrameDisabled
		temp.args.copy = getUFOption_Copy(2, unit)
		temp.args.preview = getUFOption_Preview(4, unit)
		temp.args.width = getUFOption_Width(10, unit)
		temp.args.height = getUFOption_Height(11, unit)
		temp.args.top_inset = getUFOption_TopInset(15, unit)
		temp.args.bottom_inset = getUFOption_BottomInset(16, unit)
		temp.args.border = getUFOption_Border(20, unit)
		temp.args.health = getUFOption_Health(100, unit)
		temp.args.power = getUFOption_Power(200, unit)
		temp.args.alt_power = getUFOption_AlternativePower(300, unit)
		temp.args.castbar = getUFOption_Castbar(400, unit)
		temp.args.portrait = getUFOption_Portrait(500, unit)
		temp.args.name = getUFOption_Name(600, unit)
		temp.args.raid_target = getUFOption_RaidTargetIndicator(700, unit)
		temp.args.debuff = getUFOption_DebuffIcons(800, unit)
		temp.args.auras = getUFOption_Auras(900, unit)

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
			values = CONFIG.GROWTH_DIRS,
			get = function()
				return C.db.profile.units[unit].x_growth .. "_" .. C.db.profile.units[unit].y_growth
			end,
			set = function(_, value)
				C.db.profile.units[unit].x_growth, C.db.profile.units[unit].y_growth = s_split("_", value)
				UNITFRAMES:UpdateBossHolder()
			end,
		}
	end

	return temp
end

function CONFIG:CreateUnitFramesPanel(order)
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
							P:Call(UNITFRAMES.Init, UNITFRAMES)
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
			text = {
				order = 20,
				type = "group",
				guiInline = true,
				name = L["FONT"],
				get = function(info)
					return C.db.profile.units.text[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units.text[info[#info]] = value

					UNITFRAMES:ForEach("ForElement", "Health", "UpdateConfig")
					UNITFRAMES:ForEach("ForElement", "Health", "UpdateFonts")
					UNITFRAMES:ForEach("ForElement", "HealthPrediction", "UpdateConfig")
					UNITFRAMES:ForEach("ForElement", "HealthPrediction", "UpdateFonts")
					UNITFRAMES:ForEach("ForElement", "Power", "UpdateConfig")
					UNITFRAMES:ForEach("ForElement", "Power", "UpdateFonts")
					UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateConfig")
					UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateFonts")
					UNITFRAMES:ForEach("ForElement", "Castbar", "UpdateConfig")
					UNITFRAMES:ForEach("ForElement", "Castbar", "UpdateFonts")
					UNITFRAMES:ForEach("ForElement", "Name", "UpdateConfig")
					UNITFRAMES:ForEach("ForElement", "Name", "UpdateFonts")
				end,
				args = {
					font = {
						order = 1,
						type = "select",
						name = L["NAME"],
						dialogControl = "LSM30_Font",
						values = LibStub("LibSharedMedia-3.0"):HashTable("font"),
						get = function()
							return LibStub("LibSharedMedia-3.0"):IsValid("font", C.db.profile.units.text.font)
								and C.db.profile.units.text.font
								or LibStub("LibSharedMedia-3.0"):GetDefault("font")
						end,
					},
					outline = {
						order = 2,
						type = "toggle",
						name = L["OUTLINE"],
					},
					shadow = {
						order = 3,
						type = "toggle",
						name = L["SHADOW"],
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			cooldown = {
				order = 30,
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
						UNITFRAMES:UpdateUnitFrames("ForElement", "Auras", "UpdateConfig")
						UNITFRAMES:UpdateUnitFrames("ForElement", "Auras", "UpdateCooldownConfig")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.units.cooldown, C.db.profile.units.cooldown)
							UNITFRAMES:UpdateUnitFrames("ForElement", "Auras", "UpdateConfig")
							UNITFRAMES:UpdateUnitFrames("ForElement", "Auras", "UpdateCooldownConfig")
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
								UNITFRAMES:UpdateUnitFrames("ForElement", "Auras", "UpdateConfig")
								UNITFRAMES:UpdateUnitFrames("ForElement", "Auras", "UpdateCooldownConfig")
							end
						end,
					},
				},
			},
			player = getUFOptions(3, "player", L["PLAYER_FRAME"]),
			pet = getUFOptions(4, "pet", L["PET_FRAME"]),
			target = getUFOptions(5, "target", L["TARGET_FRAME"]),
			targettarget = getUFOptions(6, "targettarget", L["TOT_FRAME"]),
			focus = getUFOptions(7, "focus", L["FOCUS_FRAME"]),
			focustarget = getUFOptions(8, "focustarget", L["TOF_FRAME"]),
			boss = getUFOptions(9, "boss", L["BOSS_FRAMES"]),
		},
	}

	self:UpdateUFAuraFilters()
end
