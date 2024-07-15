-- Lua
local _G = getfenv(0)
local unpack = _G.unpack
local tonumber = _G.tonumber

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
local MINIMAP = P:GetModule("Minimap")

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local function isModuleDisabled()
	return not MINIMAP:IsInit()
end

local function isFadingDisabled()
	return not (MINIMAP:IsInit() and C.db.profile.minimap.fade.enabled)
end

function CONFIG:CreateMinimapOptions(order)
	self.options.args.minimap = {
		order = order,
		type = "group",
		name = L["MINIMAP"],
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["ENABLE"]),
				get = function()
					return PrC.db.profile.minimap.enabled
				end,
				set = function(_, value)
					PrC.db.profile.minimap.enabled = value

					if MINIMAP:IsInit() then
						CONFIG:AskToReloadUI("minimap.enabled", value)
					else
						if value then
							P:Call(MINIMAP.Init, MINIMAP)
						end
					end
				end,
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				disabled = isModuleDisabled,
				func = function()
					CONFIG:CopySettings(D.profile.minimap, C.db.profile.minimap, {["point"] = true})
					CONFIG:CopySettings(D.profile.minimap.color, C.db.profile.minimap.color)

					MINIMAP:Update()
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			shape = {
				order = inc(1),
				type = "select",
				name = L["SHAPE"],
				values = {
					["round"] = L["SHAPE_ROUND"],
					["square"] = L["SHAPE_SQUARE"],
				},
				get = function()
					return C.db.profile.minimap.shape
				end,
				set = function(_, value)
					if C.db.profile.minimap.shape ~= value then
						C.db.profile.minimap.shape = value

						Minimap:UpdateConfig()
						Minimap:UpdateLayout()
					end
				end,
				disabled = isModuleDisabled,
			},
			scale = {
				order = inc(1),
				type = "select",
				name = L["SCALE"],
				values = {
					[100] = "100%",
					[125] = "125%",
					[150] = "150%",
				},
				get = function()
					return C.db.profile.minimap.scale
				end,
				set = function(_, value)
					if C.db.profile.minimap.scale ~= value then
						C.db.profile.minimap.scale = value

						Minimap:UpdateConfig()
						Minimap:UpdateLayout()
						Minimap:UpdateDifficultyFlag()
					end
				end,
				disabled = isModuleDisabled,
			},
			flip = {
				order = inc(1),
				type = "toggle",
				name = L["MINIMAP_HEADER_UNDERNEATH"],
				get = function()
					return C.db.profile.minimap.flip
				end,
				set = function(_, value)
					C.db.profile.minimap.flip = value

					Minimap:UpdateConfig()
					Minimap:UpdateLayout()
				end,
				disabled = isModuleDisabled,
			},
			rotate = {
				order = inc(1),
				type = "toggle",
				name = L["ROTATE_MINIMAP"],
				get = function()
					return C.db.profile.minimap.rotate
				end,
				set = function(_, value)
					C.db.profile.minimap.rotate = value

					Minimap:UpdateConfig()
					Minimap:UpdateRotation()
				end,
				disabled = isModuleDisabled,
			},
			auto_zoom = {
				order = inc(1),
				type = "range",
				name = L["MINIMAP_AUTO_ZOOM_OUT"],
				desc = L["MINIMAP_AUTO_ZOOM_OUT_DESC"],
				min = 0, max = 30, step = 1,
				get = function()
					return C.db.profile.minimap.auto_zoom
				end,
				set = function(_, value)
					if C.db.profile.minimap.auto_zoom ~= value then
						C.db.profile.minimap.auto_zoom = value
					end
				end,
				disabled = isModuleDisabled,
			},
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			colors = {
				order = inc(1),
				type = "group",
				name = L["COLORS"],
				inline = true,
				disabled = isModuleDisabled,
				args = {
					border = {
						order = reset(2),
						type = "toggle",
						name = L["BORDER"],
						get = function()
							return C.db.profile.minimap.color.border
						end,
						set = function(_, value)
							C.db.profile.minimap.color.border = value

							Minimap:UpdateConfig()
							Minimap:UpdateBorderColor()
						end,
					},
				},
			},
			spacer_6 = CONFIG:CreateSpacer(inc(1)),
			flag = {
				order = inc(1),
				type = "group",
				name = L["DIFFICULTY_FLAG"],
				inline = true,
				get = function(info)
					return C.db.profile.minimap.flag[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap.flag[info[#info]] = value

					Minimap:UpdateConfig()
					Minimap:UpdateDifficultyFlag()
				end,
				disabled = isModuleDisabled,
				args = {
					enabled = {
						order = reset(2),
						type = "toggle",
						name = L["ENABLE"],
					},
					tooltip = {
						order = inc(2),
						type = "toggle",
						name = L["TOOLTIP"],
						disabled = function()
							return isModuleDisabled() or not C.db.profile.minimap.flag.enabled
						end
					},
				},
			},
			spacer_7 = CONFIG:CreateSpacer(inc(1)),
			coords = {
				order = inc(1),
				type = "group",
				name = L["COORDS"],
				inline = true,
				get = function(info)
					return C.db.profile.minimap.coords[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap.coords[info[#info]] = value

					Minimap:UpdateConfig()
					Minimap:UpdateCoords()
				end,
				disabled = isModuleDisabled,
				args = {
					enabled = {
						order = reset(2),
						type = "toggle",
						name = L["ENABLE"],
					},
					background = {
						order = inc(2),
						type = "toggle",
						name = L["BACKGROUND"],
					},
					spacer_1 = CONFIG:CreateSpacer(inc(2)),
					point = {
						order = inc(2),
						type = "group",
						name = "",
						inline = true,
						get = function(info)
							return C.db.profile.minimap.coords.point[tonumber(info[#info])]
						end,
						set = function(info, value)
							if C.db.profile.minimap.coords.point[tonumber(info[#info])] ~= value then
								C.db.profile.minimap.coords.point[tonumber(info[#info])] = value

								Minimap:UpdateConfig()
								Minimap:UpdateCoords()
							end
						end,
						args = {
							["1"] = {
								order = reset(2),
								type = "select",
								name = L["POINT"],
								desc = L["POINT_DESC"],
								values = CONFIG.POINTS_NO_CENTER,
							},
							["3"] = {
								order = inc(2),
								type = "select",
								name = L["RELATIVE_POINT"],
								desc = L["RELATIVE_POINT_DESC"],
								values = CONFIG.POINTS_NO_CENTER,
							},
							["4"] = {
								order = inc(2),
								type = "range",
								name = L["X_OFFSET"],
								min = -128, max = 128, step = 1,
							},
							["5"] = {
								order = inc(2),
								type = "range",
								name = L["Y_OFFSET"],
								min = -128, max = 128, step = 1,
							},
						},
					},
				},
			},
			spacer_8 = CONFIG:CreateSpacer(inc(1)),
			fading = {
				order = inc(1),
				type = "group",
				name = L["FADING"],
				inline = true,
				get = function(info)
					return C.db.profile.minimap.fade[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap.fade[info[#info]] = value

					Minimap:UpdateConfig()
					MinimapCluster:UpdateFading()
				end,
				args = {
					enabled = {
						order = reset(2),
						type = "toggle",
						name = L["ENABLE"],
						disabled = isModuleDisabled,
					},
					reset = {
						order = inc(2),
						type = "execute",
						name = L["RESTORE_DEFAULTS"],
						disabled = isFadingDisabled,
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.minimap.fade, C.db.profile.minimap.fade, {enabled = true})

							Minimap:UpdateConfig()
							MinimapCluster:UpdateFading()
						end,
					},
					spacer_1 = CONFIG:CreateSpacer(inc(2)),
					combat = {
						order = inc(2),
						type = "toggle",
						name = L["COMBAT"],
						disabled = isFadingDisabled,
					},
					target = {
						order = inc(2),
						type = "toggle",
						name = L["TARGET"],
						disabled = isFadingDisabled,
					},
					in_duration = {
						order = inc(2),
						type = "range",
						name = L["FADE_IN_DURATION"],
						disabled = isFadingDisabled,
						min = 0.05, max = 1, step = 0.05,
					},
					out_delay = {
						order = inc(2),
						type = "range",
						name = L["FADE_OUT_DELAY"],
						disabled = isFadingDisabled,
						min = 0, max = 2, step = 0.05,
					},
					out_duration = {
						order = inc(2),
						type = "range",
						name = L["FADE_OUT_DURATION"],
						disabled = isFadingDisabled,
						min = 0.05, max = 1, step = 0.05,
					},
					min_alpha = {
						order = inc(2),
						type = "range",
						name = L["MIN_ALPHA"],
						disabled = isFadingDisabled,
						min = 0, max = 1, step = 0.05,
					},
					max_alpha = {
						order = inc(2),
						type = "range",
						name = L["MAX_ALPHA"],
						disabled = isFadingDisabled,
						min = 0, max = 1, step = 0.05
					},
				},
			},
		},
	}
end
