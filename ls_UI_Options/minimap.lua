local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
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
				name = L["ENABLE"],
				get = function()
					return PrC.db.profile.minimap.enabled
				end,
				set = function(_, value)
					PrC.db.profile.minimap.enabled = value

					if not MINIMAP:IsInit() then
						if value then
							P:Call(MINIMAP.Init, MINIMAP)
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
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
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
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
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
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
			spacer_6 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
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
			spacer_7 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
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
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
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
