local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local UNITFRAMES = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_split = _G.string.split

-- Mine
local fcf_modes = {
	Fountain = "Fountain",
	Standard = "Standard",
}

local points = {
	BOTTOM = "BOTTOM",
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	CENTER = "CENTER",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	TOP = "TOP",
	TOPLEFT = "TOPLEFT",
	TOPRIGHT = "TOPRIGHT",
}

local insets = {
	[8] = "8",
	[12] = "12",
}

local h_alignment = {
	CENTER = "CENTER",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
}
local v_alignment = {
	BOTTOM = "BOTTOM",
	MIDDLE = "MIDDLE",
	TOP = "TOP",
}

local castbar_icon_positions = {
	LEFT = L["LEFT"],
	RIGHT = L["RIGHT"],
}

local growth_dirs = {
	LEFT_DOWN = L["LEFT_DOWN"],
	LEFT_UP = L["LEFT_UP"],
	RIGHT_DOWN = L["RIGHT_DOWN"],
	RIGHT_UP = L["RIGHT_UP"],
}

local function GetPoints(addNone)
	if addNone then
		return E:CopyTable(points, {[""] = "NONE"})
	else
		return E:CopyTable(points, {})
	end
end

local function GetRegionAnchors(removeAnchors, addAnchors)
	local temp = {
		[""] = L["FRAME"],
		["Health"] = L["HEALTH"],
		["Health.Text"] = L["HEALTH_TEXT"],
		["Power"] = L["POWER"],
		["Power.Text"] = L["POWER_TEXT"],
	}

	if removeAnchors then
		for i = 1, #removeAnchors do
			temp[removeAnchors[i]] = nil
		end
	end

	if addAnchors then
		for k, v in next, addAnchors do
			temp[k] = v
		end
	end

	return temp
end

local function GetOptionsTable_Health(unit, order)
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
					CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].health, C.db.profile.units[E.UI_LAYOUT][unit].health, {point = true})
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
			},
			color = {
				order = 10,
				type = "group",
				name = L["BAR_COLOR"],
				guiInline = true,
				args = {
					class = {
						order = 1,
						type = "toggle",
						name = L["PLAYER_CLASS"],
						desc = L["COLOR_CLASS_DESC"],
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.color.class
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.color.class = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					reaction = {
						order = 2,
						type = "toggle",
						name = L["REACTION"],
						desc = L["COLOR_REACTION_DESC"],
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.color.reaction
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.color.reaction = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
				},
			},
			text = {
				order = 11,
				type = "group",
				name = L["BAR_TEXT"],
				guiInline = true,
				args = {
					p = {
						order = 4,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = GetPoints(),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.p
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.p = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					anchor = {
						order = 5,
						type = "select",
						name = L["ANCHOR"],
						values = GetRegionAnchors({"Health.Text"}),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.anchor
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.anchor = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					rP = {
						order = 6,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = GetPoints(),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.rP
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.rP = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					x = {
						order = 7,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.x
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.x = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					y = {
						order = 8,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.y
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.text.point1.y = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					tag = {
						order = 10,
						type = "input",
						width = "full",
						name = L["FORMAT"],
						desc = L["HEALTH_FORMAT_DESC"],
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.text.tag:gsub("\124", "\124\124")
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.text.tag = value:gsub("\124\124+", "\124")
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
				},
			},
			prediction = {
				order = 12,
				type = "group",
				name = L["HEAL_PREDICTION"],
				guiInline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.enabled
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.enabled = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					absorb_text = {
						order = 2,
						type = "group",
						name = L["DAMAGE_ABSORB_TEXT"],
						guiInline = true,
						args = {
							p = {
								order = 0,
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = GetPoints(),
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.p
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.p = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							anchor = {
								order = 1,
								type = "select",
								name = L["ANCHOR"],
								values = GetRegionAnchors(),
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.anchor
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.anchor = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							rP = {
								order = 2,
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = GetPoints(),
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.rP
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.rP = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							x = {
								order = 3,
								type = "range",
								name = L["X_OFFSET"],
								min = -128, max = 128, step = 1,
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.x
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.x = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							y = {
								order = 4,
								type = "range",
								name = L["Y_OFFSET"],
								min = -128, max = 128, step = 1,
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.y
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.point1.y = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							tag = {
								order = 9,
								type = "input",
								width = "full",
								name = L["FORMAT"],
								desc = L["DAMAGE_ABSORB_FORMAT_DESC"],
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.tag:gsub("\124", "\124\124")
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.absorb_text.tag = value:gsub("\124\124+", "\124")
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
						},
					},
					heal_absorb_text = {
						order = 2,
						type = "group",
						name = L["HEAL_ABSORB_TEXT"],
						guiInline = true,
						args = {
							p = {
								order = 1,
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = GetPoints(),
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.p
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.p = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							anchor = {
								order = 2,
								type = "select",
								name = L["ANCHOR"],
								values = GetRegionAnchors(),
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.anchor
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.anchor = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							rP = {
								order = 3,
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = GetPoints(),
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.rP
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.rP = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							x = {
								order = 4,
								type = "range",
								name = L["X_OFFSET"],
								min = -128, max = 128, step = 1,
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.x
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.x = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							y = {
								order = 5,
								type = "range",
								name = L["Y_OFFSET"],
								min = -128, max = 128, step = 1,
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.y
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.point1.y = value
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
							tag = {
								order = 9,
								type = "input",
								width = "full",
								name = L["FORMAT"],
								desc = L["HEAL_ABSORB_FORMAT_DESC"],
								get = function()
									return C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.tag:gsub("\124", "\124\124")
								end,
								set = function(_, value)
									C.db.profile.units[E.UI_LAYOUT][unit].health.prediction.heal_abosrb_text.tag = value:gsub("\124\124+", "\124")
									UNITFRAMES:UpdateUnitFrame(unit)
								end,
							},
						},
					},
				},
			},
		},
	}

	if unit == "player" then
		temp.args.color.args.reaction = nil
	elseif unit == "pet" then
		temp.args.prediction.args.absorb_text = nil
		temp.args.prediction.args.heal_absorb_text = nil
	elseif unit == "targettarget" then
		temp.args.prediction.args.absorb_text = nil
		temp.args.prediction.args.heal_absorb_text = nil
	elseif unit == "focustarget" then
		temp.args.prediction.args.absorb_text = nil
		temp.args.prediction.args.heal_absorb_text = nil
	end

	return temp
end

local function GetOptionsTable_Power(unit, order)
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
					return C.db.profile.units[E.UI_LAYOUT][unit].power.enabled
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].power.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].power, C.db.profile.units[E.UI_LAYOUT][unit].power, {point = true})
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
			},
			prediction = {
				order = 10,
				type = "toggle",
				name = L["COST_PREDICTION"],
				desc = L["COST_PREDICTION_DESC"],
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].power.prediction.enabled
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].power.prediction.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			text = {
				order = 11,
				type = "group",
				name = L["BAR_TEXT"],
				guiInline = true,
				args = {
					p = {
						order = 4,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = GetPoints(),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.p
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.p = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					anchor = {
						order = 5,
						type = "select",
						name = L["ANCHOR"],
						values = GetRegionAnchors({"Power.Text"}),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.anchor
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.anchor = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					rP = {
						order = 6,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = GetPoints(),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.rP
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.rP = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					x = {
						order = 7,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.x
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.x = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					y = {
						order = 8,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.y
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].power.text.point1.y = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					tag = {
						order = 10,
						type = "input",
						width = "full",
						name = L["FORMAT"],
						desc = L["POWER_FORMAT_DESC"],
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].power.text.tag:gsub("\124", "\124\124")
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].power.text.tag = value:gsub("\124\124+", "\124")
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
				},
			},
		},
	}

	if unit ~= "player" then
		temp.args.prediction = nil
	end

	return temp
end

local function GetOptionsTable_Castbar(unit, order)
	local temp = {
		order = order,
		type = "group",
		name = L["CASTBAR"],
		get = function(info)
			return C.db.profile.units[E.UI_LAYOUT][unit].castbar[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[E.UI_LAYOUT][unit].castbar[info[#info]] ~= value then
				C.db.profile.units[E.UI_LAYOUT][unit].castbar[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit)
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
					CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].castbar, C.db.profile.units[E.UI_LAYOUT][unit].castbar, {point = true})
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
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
				disabled = function() return not C.db.profile.units[E.UI_LAYOUT][unit].castbar.detached end,
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
			icon = {
				order = 20,
				type = "group",
				name = L["ICON"],
				guiInline = true,
				get = function(info)
					return C.db.profile.units[E.UI_LAYOUT][unit].castbar.icon[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[E.UI_LAYOUT][unit].castbar.icon[info[#info]] ~= value then
						C.db.profile.units[E.UI_LAYOUT][unit].castbar.icon[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit)
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
						values = castbar_icon_positions,
					},
				},
			},
		},
	}

	if unit == "player" then
		if E.UI_LAYOUT == "ls" then
			temp.args.detached = nil
		end
	elseif unit == "pet" then
		if E.UI_LAYOUT == "ls" then
			temp.args.detached = nil
		end
	else
		temp.args.latency = nil
	end

	return temp
end

local function GetOptionsTable_Name(unit, order)
	local temp = {
		order = order,
		type = "group",
		name = L["NAME"],
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].name, C.db.profile.units[E.UI_LAYOUT][unit].name, {point = true})
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
			},
			p = {
				order = 10,
				type = "select",
				name = L["POINT"],
				desc = L["POINT_DESC"],
				values = GetPoints(),
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].name.point1.p
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].name.point1.p = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			anchor = {
				order = 11,
				type = "select",
				name = L["ANCHOR"],
				values = GetRegionAnchors(),
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].name.point1.anchor
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].name.point1.anchor = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			rP = {
				order = 12,
				type = "select",
				name = L["RELATIVE_POINT"],
				desc = L["RELATIVE_POINT_DESC"],
				values = GetPoints(),
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].name.point1.rP
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].name.point1.rP = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			x = {
				order = 13,
				type = "range",
				name = L["X_OFFSET"],
				min = -128, max = 128, step = 1,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].name.point1.x
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].name.point1.x = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			y = {
				order = 14,
				type = "range",
				name = L["Y_OFFSET"],
				min = -128, max = 128, step = 1,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].name.point1.y
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].name.point1.y = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			text_p2 = {
				order = 15,
				type = "group",
				name = L["SECOND_ANCHOR"],
				guiInline = true,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = GetPoints(true),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.p
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].name.point2.p = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["ANCHOR"],
						values = GetRegionAnchors(),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.anchor
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].name.point2.anchor = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
						disabled = function() return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.p == "" end,
					},
					rP = {
						order = 3,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = GetPoints(),
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.rP
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].name.point2.rP = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
						disabled = function() return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.p == "" end,
					},
					x = {
						order = 4,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.x
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].name.point2.x = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
						disabled = function() return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.p == "" end,
					},
					y = {
						order = 5,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.y
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].name.point2.y = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
						disabled = function() return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.p == "" end,
					},
					h_alignment = {
						order = 7,
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = h_alignment,
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].name.h_alignment
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].name.h_alignment = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
						disabled = function() return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.p == "" end,
					},
					v_alignment = {
						order = 8,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = v_alignment,
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].name.v_alignment
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].name.v_alignment = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
						disabled = function() return C.db.profile.units[E.UI_LAYOUT][unit].name.point2.p == "" end,
					},
				},
			},
			text_tag = {
				order = 16,
				type = "input",
				width = "full",
				name = L["FORMAT"],
				desc = L["NAME_FORMAT_DESC"],
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].name.tag:gsub("\124", "\124\124")
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].name.tag = value:gsub("\124\124+", "\124")
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			word_wrap = {
				order = 17,
				type = "toggle",
				name = L["WORD_WRAP"],
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].name.word_wrap
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].name.word_wrap = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end
			},
		},
	}

	return temp
end

local function GetOptionsTable_RaidIcon(unit, order)
	local temp = {
		order = order,
		type = "group",
		name = L["RAID_ICON"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].raid_target.enabled
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].raid_target.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].raid_target, C.db.profile.units[E.UI_LAYOUT][unit].raid_target, {point = true})
					UNITFRAMES:UpdateUnitFrame(unit)
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
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].raid_target.size
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].raid_target.size = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			p = {
				order = 11,
				type = "select",
				name = L["POINT"],
				desc = L["POINT_DESC"],
				values = GetPoints(),
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].raid_target.point1.p
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].raid_target.point1.p = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			rP = {
				order = 12,
				type = "select",
				name = L["RELATIVE_POINT"],
				desc = L["RELATIVE_POINT_DESC"],
				values = GetPoints(),
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].raid_target.point1.rP
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].raid_target.point1.rP = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			x = {
				order = 13,
				type = "range",
				name = L["X_OFFSET"],
				min = -128, max = 128, step = 1,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].raid_target.point1.x
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].raid_target.point1.x = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			y = {
				order = 14,
				type = "range",
				name = L["Y_OFFSET"],
				min = -128, max = 128, step = 1,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].raid_target.point1.y
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].raid_target.point1.y = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
		}
	}

	return temp
end

local function GetOptionsTable_DebuffIcons(unit, order)
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
					return C.db.profile.units[E.UI_LAYOUT][unit].debuff.enabled
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].debuff.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].debuff, C.db.profile.units[E.UI_LAYOUT][unit].debuff, {point = true})
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
			},
			preview = {
				type = "execute",
				order = 10,
				name = L["PREVIEW"],
				func = function()
					UNITFRAMES:PreviewDebuffIndicator(UNITFRAMES:GetUnitFrameForUnit(unit))
				end,
			},
			p = {
				order = 11,
				type = "select",
				name = L["POINT"],
				desc = L["POINT_DESC"],
				values = GetPoints(),
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.p
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.p = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			anchor = {
				order = 12,
				type = "select",
				name = L["ANCHOR"],
				values = GetRegionAnchors({"Health.Text", "Power", "Power.Text"}),
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.anchor
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.anchor = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			rP = {
				order = 13,
				type = "select",
				name = L["RELATIVE_POINT"],
				desc = L["RELATIVE_POINT_DESC"],
				values = GetPoints(),
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.rP
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.rP = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			x = {
				order = 14,
				type = "range",
				name = L["X_OFFSET"],
				min = -128, max = 128, step = 1,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.x
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.x = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			y = {
				order = 15,
				type = "range",
				name = L["Y_OFFSET"],
				min = -128, max = 128, step = 1,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.y
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].debuff.point1.y = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
		}
	}

	return temp
end

local function GetOptionsTable_Auras(unit, order)
	local temp = {
		order = order,
		type = "group",
		name = L["AURAS"],
		get = function(info)
			return C.db.profile.units[E.UI_LAYOUT][unit].auras[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[E.UI_LAYOUT][unit].auras[info[#info]] ~= value then
				C.db.profile.units[E.UI_LAYOUT][unit].auras[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit)
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
				get = function() end,
				set = function(_, value)
					CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras, C.db.profile.units[E.UI_LAYOUT][unit].auras, {filter = true})
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].auras, C.db.profile.units[E.UI_LAYOUT][unit].auras, {point = true, filter = true})
					UNITFRAMES:UpdateUnitFrame(unit)
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
				values = growth_dirs,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].auras.x_growth.."_"..C.db.profile.units[E.UI_LAYOUT][unit].auras.y_growth
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].auras.x_growth, C.db.profile.units[E.UI_LAYOUT][unit].auras.y_growth = s_split("_", value)
					UNITFRAMES:UpdateUnitFrame(unit)
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
				inline  = true,
				get = function(info)
					return C.db.profile.units[E.UI_LAYOUT][unit].auras.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[E.UI_LAYOUT][unit].auras.point1[info[#info]] ~= value then
						C.db.profile.units[E.UI_LAYOUT][unit].auras.point1[info[#info]] = value
						UNITFRAMES:UpdateUnitFrame(unit)
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = GetPoints(),
					},
					rP = {
						order = 2,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = GetPoints(),
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
				inline  = true,
				get = function(info)
					return C.db.profile.units[E.UI_LAYOUT][unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]]
				end,
				set = function(info, value)
					C.db.profile.units[E.UI_LAYOUT][unit].auras.filter[info[#info - 2]][info[#info - 1]][info[#info]] = value
					UNITFRAMES:UpdateUnitFrame(unit)
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
							CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].auras.filter, C.db.profile.units[E.UI_LAYOUT][unit].auras.filter)
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					friendly = {
						order = 2,
						type = "group",
						inline  = true,
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
											return not C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.friendly.buff.selfcast
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
											return not C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.friendly.buff.player
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
											return not C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.friendly.debuff.selfcast
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
											return not C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.friendly.debuff.player
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
						inline  = true,
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
											return not C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.enemy.buff.selfcast
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
											return not C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.enemy.buff.player
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
											return not C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.enemy.debuff.selfcast
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
											return not C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.enemy.debuff.player
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
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.friendly.buff, C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.friendly.buff, {player = true, player_permanent = true})
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.friendly.debuff, C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.friendly.debuff, {player = true, player_permanent = true})
			UNITFRAMES:UpdateUnitFrame(unit)
		end
		temp.args.filter.args.friendly.args.buff.args.player = nil
		temp.args.filter.args.friendly.args.buff.args.player_permanent = nil

		temp.args.filter.args.friendly.args.debuff.args.player = nil
		temp.args.filter.args.friendly.args.debuff.args.player_permanent = nil

		temp.args.filter.args.enemy = nil
	elseif unit == "boss" then
		temp.args.filter.args.copy.set = function(_, value)
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.friendly.buff, C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.friendly.buff, {mount = true, selfcast = true, selfcast_permanent = true})
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.friendly.debuff, C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.friendly.debuff, {selfcast = true, selfcast_permanent = true})
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.enemy.buff, C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.enemy.buff, {mount = true, selfcast = true, selfcast_permanent = true})
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter.enemy.debuff, C.db.profile.units[E.UI_LAYOUT][unit].auras.filter.enemy.debuff, {selfcast = true, selfcast_permanent = true})
			UNITFRAMES:UpdateUnitFrame(unit)
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
			CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value].auras.filter, C.db.profile.units[E.UI_LAYOUT][unit].auras.filter)
			UNITFRAMES:UpdateUnitFrame(unit)
		end
	end

	return temp
end

local function GetOptionsTable_UnitFrame(unit, order, name)
	local temp = {
		order = order,
		type = "group",
		childGroups = "tab",
		name = name,
		args = {
			copy = {
				order = 1,
				type = "select",
				name = L["COPY_FROM"],
				desc = L["COPY_FROM_DESC"],
				values = UNITFRAMES:GetUnits({[unit] = true, player = true, pet = true}),
				get = function() end,
				set = function(_, value)
					CONFIG:CopySettings(C.db.profile.units[E.UI_LAYOUT][value], C.db.profile.units[E.UI_LAYOUT][unit], {point = true})
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit], C.db.profile.units[E.UI_LAYOUT][unit], {point = true})
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			preview = {
				order = 3,
				type = "execute",
				name = L["PREVIEW"],
				func = function()
						UNITFRAMES:GetUnitFrameForUnit(unit):Preview()
				end,
			},
			spacer_1 = {
				order = 10,
				type = "description",
				name = "",
				width = "full",
			},
			width = {
				order = 11,
				type = "range",
				name = L["WIDTH"],
				min = 64, max = 512, step = 2,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].width
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].width = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			height = {
				order = 12,
				type = "range",
				name = L["HEIGHT"],
				min = 28, max = 256, step = 2,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].height
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].height = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			top_inset = {
				order = 16,
				type = "select",
				name = L["TOP_INSET_SIZE"],
				desc = L["TOP_INSET_SIZE_DESC"],
				values = insets,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].insets.t_height
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].insets.t_height = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			bottom_inset = {
				order = 17,
				type = "select",
				name = L["BOTTOM_INSET_SIZE"],
				desc = L["BOTTOM_INSET_SIZE_DESC"],
				values = insets,
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].insets.b_height
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].insets.b_height = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			threat = {
				order = 18,
				type = "toggle",
				name = L["THREAT_GLOW"],
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].threat.enabled
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].threat.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			pvp = {
				order = 19,
				type = "toggle",
				name = L["PVP_ICON"],
				get = function()
					return C.db.profile.units[E.UI_LAYOUT][unit].pvp.enabled
				end,
				set = function(_, value)
					C.db.profile.units[E.UI_LAYOUT][unit].pvp.enabled = value
					UNITFRAMES:UpdateUnitFrame(unit)
				end,
			},
			border = {
				order = 30,
				type = "group",
				name = L["BORDER_COLOR"],
				guiInline = true,
				args = {
					player = {
						order = 1,
						type = "toggle",
						name = L["PLAYER_CLASS"],
						desc = L["COLOR_CLASS_DESC"],
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].class.player
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].class.player = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
					npc = {
						order = 2,
						type = "toggle",
						name = L["NPC_CLASSIFICATION"],
						desc = L["COLOR_CLASSIFICATION_DESC"],
						get = function()
							return C.db.profile.units[E.UI_LAYOUT][unit].class.npc
						end,
						set = function(_, value)
							C.db.profile.units[E.UI_LAYOUT][unit].class.npc = value
							UNITFRAMES:UpdateUnitFrame(unit)
						end,
					},
				},
			}
		},
	}

	temp.args.health = GetOptionsTable_Health(unit, 100)
	temp.args.power = GetOptionsTable_Power(unit, 200)
	temp.args.castbar = GetOptionsTable_Castbar(unit, 400)
	temp.args.name = GetOptionsTable_Name(unit, 500)
	temp.args.raid_target = GetOptionsTable_RaidIcon(unit, 600)
	temp.args.debuff = GetOptionsTable_DebuffIcons(unit, 700)
	temp.args.auras = GetOptionsTable_Auras(unit, 800)

	if unit == "player" then
		temp.disabled = function() return not UNITFRAMES:HasPlayerFrame() end
		temp.args.preview = nil
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
						return C.db.profile.units[E.UI_LAYOUT][unit].class_power.enabled
					end,
					set = function(_, value)
						C.db.profile.units[E.UI_LAYOUT][unit].class_power.enabled = value
						UNITFRAMES:UpdateUnitFrame(unit)
					end,
				},
				prediction = {
					order = 2,
					type = "toggle",
					name = L["COST_PREDICTION"],
					desc = L["COST_PREDICTION_DESC"],
					get = function()
						return C.db.profile.units[E.UI_LAYOUT][unit].class_power.prediction.enabled
					end,
					set = function(_, value)
						C.db.profile.units[E.UI_LAYOUT][unit].class_power.prediction.enabled = value
						UNITFRAMES:UpdateUnitFrame(unit)
					end,
				},
			},
		}
		temp.args.combat_feedback = {
			order = 900,
			type = "group",
			name = L["FCF"],
			get = function(info)
				return C.db.profile.units[E.UI_LAYOUT][unit].combat_feedback[info[#info]]
			end,
			set = function(info, value)
				C.db.profile.units[E.UI_LAYOUT][unit].combat_feedback[info[#info]] = value
				UNITFRAMES:UpdateUnitFrame(unit)
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
						CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].combat_feedback, C.db.profile.units[E.UI_LAYOUT][unit].combat_feedback, {point = true})
						UNITFRAMES:UpdateUnitFrame(unit)
					end,
				},
				spacer_1 = {
					order = 9,
					type = "description",
					name = "",
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
					min = 0, max = 64, step = 1,
				},
				mode = {
					order = 13,
					type = "select",
					name = L["MODE"],
					values = fcf_modes,
				},
			},
		}

		if E.UI_LAYOUT == "ls" then
			temp.args.copy = nil
			temp.args.width = nil
			temp.args.height = nil
			temp.args.top_inset = nil
			temp.args.bottom_inset = nil
			temp.args.border = nil
			temp.args.auras = nil
		else
			temp.args.border.args.npc = nil
		end
	elseif unit == "pet" then
		temp.disabled = function() return not UNITFRAMES:HasPlayerFrame() end
		temp.args.pvp = nil
		temp.args.auras = nil

		if E.UI_LAYOUT == "ls" then
			temp.args.copy = nil
			temp.args.name = nil
			temp.args.width = nil
			temp.args.height = nil
			temp.args.top_inset = nil
			temp.args.bottom_inset = nil
			temp.args.border = nil
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
		temp.args.preview = {
			order = 3,
			type = "execute",
			name = L["PREVIEW"],
			func = function()
				for i = 1, 5 do
					UNITFRAMES:GetUnitFrameForUnit(unit..i):Preview()
				end
			end,
		}
		temp.args.pvp = nil
		temp.args.debuff = nil
		temp.args.per_row = {
			order = 13,
			type = "range",
			name = L["PER_ROW"],
			min = 1, max = 5, step = 1,
			get = function()
				return C.db.profile.units[E.UI_LAYOUT][unit].per_row
			end,
			set = function(_, value)
				if C.db.profile.units[E.UI_LAYOUT][unit].per_row ~= value then
					C.db.profile.units[E.UI_LAYOUT][unit].per_row = value
					UNITFRAMES:UpdateBossHolder()
				end
			end,
		}
		temp.args.spacing = {
			order = 14,
			type = "range",
			name = L["SPACING"],
			min = 8, max = 64, step = 2,
			get = function()
				return C.db.profile.units[E.UI_LAYOUT][unit].spacing
			end,
			set = function(_, value)
				if C.db.profile.units[E.UI_LAYOUT][unit].spacing ~= value then
					C.db.profile.units[E.UI_LAYOUT][unit].spacing = value
					UNITFRAMES:UpdateBossHolder()
				end
			end,
		}
		temp.args.growth_dir = {
			order = 15,
			type = "select",
			name = L["GROWTH_DIR"],
			values = growth_dirs,
			get = function()
				return C.db.profile.units[E.UI_LAYOUT][unit].x_growth.."_"..C.db.profile.units[E.UI_LAYOUT][unit].y_growth
			end,
			set = function(_, value)
				C.db.profile.units[E.UI_LAYOUT][unit].x_growth, C.db.profile.units[E.UI_LAYOUT][unit].y_growth = s_split("_", value)
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
						return C.db.profile.units[E.UI_LAYOUT][unit].alt_power.enabled
					end,
					set = function(_, value)
						C.db.profile.units[E.UI_LAYOUT][unit].alt_power.enabled = value
						UNITFRAMES:UpdateUnitFrame(unit)
					end,
				},
				reset = {
					type = "execute",
					order = 2,
					name = L["RESTORE_DEFAULTS"],
					func = function()
						CONFIG:CopySettings(D.profile.units[E.UI_LAYOUT][unit].alt_power, C.db.profile.units[E.UI_LAYOUT][unit].alt_power, {point = true})
						UNITFRAMES:UpdateUnitFrame(unit)
					end,
				},
				spacer_1 = {
					order = 9,
					type = "description",
					name = "",
				},
				text = {
					order = 10,
					type = "group",
					name = L["BAR_TEXT"],
					guiInline = true,
					args = {
						p = {
							order = 4,
							type = "select",
							name = L["POINT"],
							desc = L["POINT_DESC"],
							values = GetPoints(),
							get = function()
								return C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.p
							end,
							set = function(_, value)
								C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.p = value
								UNITFRAMES:UpdateUnitFrame(unit)
							end,
						},
						anchor = {
							order = 5,
							type = "select",
							name = L["ANCHOR"],
							values = GetRegionAnchors(nil, {["AlternativePower"] = L["ALTERNATIVE_POWER"]}),
							get = function()
								return C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.anchor
							end,
							set = function(_, value)
								C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.anchor = value
								UNITFRAMES:UpdateUnitFrame(unit)
							end,
						},
						rP = {
							order = 6,
							type = "select",
							name = L["RELATIVE_POINT"],
							desc = L["RELATIVE_POINT_DESC"],
							values = GetPoints(),
							get = function()
								return C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.rP
							end,
							set = function(_, value)
								C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.rP = value
								UNITFRAMES:UpdateUnitFrame(unit)
							end,
						},
						x = {
							order = 7,
							type = "range",
							name = L["X_OFFSET"],
							min = -128, max = 128, step = 1,
							get = function()
								return C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.x
							end,
							set = function(_, value)
								C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.x = value
								UNITFRAMES:UpdateUnitFrame(unit)
							end,
						},
						y = {
							order = 8,
							type = "range",
							name = L["Y_OFFSET"],
							min = -128, max = 128, step = 1,
							get = function()
								return C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.y
							end,
							set = function(_, value)
								C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.point1.y = value
								UNITFRAMES:UpdateUnitFrame(unit)
							end,
						},
						tag = {
							order = 10,
							type = "input",
							width = "full",
							name = L["FORMAT"],
							desc = L["ALT_POWER_FORMAT_DESC"],
							get = function()
								return C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.tag:gsub("\124", "\124\124")
							end,
							set = function(_, value)
								C.db.profile.units[E.UI_LAYOUT][unit].alt_power.text.tag = value:gsub("\124\124+", "\124")
								UNITFRAMES:UpdateUnitFrame(unit)
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
			units = {
				order = 2,
				type = "group",
				name = L["UNITS"],
				guiInline = true,
				disabled = function()
					return not UNITFRAMES:IsInit()
				end,
				get = function(info)
					return C.db.profile.units[E.UI_LAYOUT][info[#info]].enabled
				end,
				set = function(info, value)
					local unit = info[#info]

					C.db.profile.units[E.UI_LAYOUT][unit].enabled = value

					if UNITFRAMES:IsInit() then
						if value then
							UNITFRAMES:CreateUnitFrame(unit)

							if unit == "player" then
								UNITFRAMES:UpdateUnitFrame(unit)
								UNITFRAMES:UpdateUnitFrame("pet")
							elseif unit == "target" then
								UNITFRAMES:UpdateUnitFrame(unit)
								UNITFRAMES:UpdateUnitFrame("targettarget")
							elseif unit == "focus" then
								UNITFRAMES:UpdateUnitFrame(unit)
								UNITFRAMES:UpdateUnitFrame("focustarget")
							else
								UNITFRAMES:UpdateUnitFrame(unit)
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
			player = GetOptionsTable_UnitFrame("player", 3, L["PLAYER_FRAME"]),
			pet = GetOptionsTable_UnitFrame("pet", 4, L["PET_FRAME"]),
			target = GetOptionsTable_UnitFrame("target", 5, L["TARGET_FRAME"]),
			targettarget = GetOptionsTable_UnitFrame("targettarget", 6, L["TOT_FRAME"]),
			focus = GetOptionsTable_UnitFrame("focus", 7, L["FOCUS_FRAME"]),
			focustarget = GetOptionsTable_UnitFrame("focustarget", 8, L["TOF_FRAME"]),
			boss = GetOptionsTable_UnitFrame("boss", 9, L["BOSS_FRAMES"]),
		},
	}
end
