-- Lua
local _G = getfenv(0)
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

local ignoredAnchors = {
	["Health.Text"] = true
}

function CONFIG:CreateUnitFrameHealthOptions(order, unit)
	return {
		order = order,
		type = "group",
		name = L["HEALTH"],
		args = {
			reset = {
				type = "execute",
				order = reset(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].health, C.db.profile.units[unit].health)
					UNITFRAMES:For(unit, "UpdateHealth")
					UNITFRAMES:For(unit, "UpdateHealthPrediction")
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
				name = L["HEAL_PREDICTION"],
				get = function()
					return C.db.profile.units[unit].health.prediction.enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].health.prediction.enabled = value

					UNITFRAMES:For(unit, "UpdateHealthPrediction")
				end,
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			color = {
				order = inc(1),
				type = "group",
				name = L["BAR_COLOR"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].health.color[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].health.color[info[#info]] ~= value then
						C.db.profile.units[unit].health.color[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Health", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Health", "UpdateColors")
					end
				end,
				args = {
					class = {
						order = reset(2),
						type = "toggle",
						name = L["CLASS"],
					},
					reaction = {
						order = inc(2),
						type = "toggle",
						name = L["REACTION"],
					},
				},
			},
			spacer_3 = {
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
					return C.db.profile.units[unit].health.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].health.text[info[#info]] ~= value then
						C.db.profile.units[unit].health.text[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Health", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Health", "UpdateFonts")
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
							return C.db.profile.units[unit].health.text.point1[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.units[unit].health.text.point1[info[#info]] ~= value then
								C.db.profile.units[unit].health.text.point1[info[#info]] = value

								UNITFRAMES:For(unit, "For", "Health", "UpdateConfig")
								UNITFRAMES:For(unit, "For", "Health", "UpdateTextPoints")
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
								values = CONFIG:GetRegionAnchors(ignoredAnchors),
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
						desc = L["HEALTH_FORMAT_DESC"],
						get = function()
							return C.db.profile.units[unit].health.text.tag:gsub("\124", "\124\124")
						end,
						set = function(_, value)
							value = value:gsub("\124\124+", "\124")
							if C.db.profile.units[unit].health.text.tag ~= value then
								C.db.profile.units[unit].health.text.tag = value

								UNITFRAMES:For(unit, "For", "Health", "UpdateConfig")
								UNITFRAMES:For(unit, "For", "Health", "UpdateTags")
							end
						end,
					},
				},
			},
		},
	}
end
