local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CFG = P:GetModule("Config")
local AURAS = P:GetModule("Auras")

-- Lua
local _G = getfenv(0)
local s_split = _G.string.split

-- Mine
local function GetOptionsTable_Aura(filter, order, name)
	local temp = {
		order = order,
		type = "group",
		name = name,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CFG:CopySettings(D.profile.auras[E.UI_LAYOUT][filter], C.db.profile.auras[E.UI_LAYOUT][filter], {point = true})
					AURAS:UpdateHeader(filter)
				end,
			},
			spacer1 = {
				order = 9,
				type = "description",
				name = "",
			},
			rows = {
				order = 10,
				type = "range",
				name = L["ROWS"],
				min = 1, max = 40, step = 1,
				disabled = function() return not AURAS:IsInit() end,
				get = function()
					return C.db.profile.auras[E.UI_LAYOUT][filter].num_rows
				end,
				set = function(_, value)
					C.db.profile.auras[E.UI_LAYOUT][filter].num_rows = value
					AURAS:UpdateHeader(filter)
				end,
			},
			per_row = {
				order = 11,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 40, step = 1,
				disabled = function() return not AURAS:IsInit() end,
				get = function()
					return C.db.profile.auras[E.UI_LAYOUT][filter].per_row
				end,
				set = function(_, value)
					C.db.profile.auras[E.UI_LAYOUT][filter].per_row = value
					AURAS:UpdateHeader(filter)
				end,
			},
			spacing = {
				order = 12,
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 2,
				disabled = function() return not AURAS:IsInit() end,
				get = function()
					return C.db.profile.auras[E.UI_LAYOUT][filter].spacing
				end,
				set = function(_, value)
					C.db.profile.auras[E.UI_LAYOUT][filter].spacing = value
					AURAS:UpdateHeader(filter)
				end,
			},
			size = {
				order = 13,
				type = "range",
				name = L["SIZE"],
				min = 24, max = 64, step = 1,
				disabled = function() return not AURAS:IsInit() end,
				get = function()
					return C.db.profile.auras[E.UI_LAYOUT][filter].size
				end,
				set = function(_, value)
					C.db.profile.auras[E.UI_LAYOUT][filter].size = value
					AURAS:UpdateHeader(filter)
				end,
			},
			growth_dir = {
				order = 14,
				type = "select",
				name = L["GROWTH_DIR"],
				values = {
					LEFT_DOWN = L["LEFT_DOWN"],
					LEFT_UP = L["LEFT_UP"],
					RIGHT_DOWN = L["RIGHT_DOWN"],
					RIGHT_UP = L["RIGHT_UP"],
				},
				disabled = function() return not AURAS:IsInit() end,
				get = function()
					return C.db.profile.auras[E.UI_LAYOUT][filter].x_growth.."_"..C.db.profile.auras[E.UI_LAYOUT][filter].y_growth
				end,
				set = function(_, value)
					C.db.profile.auras[E.UI_LAYOUT][filter].x_growth, C.db.profile.auras[E.UI_LAYOUT][filter].y_growth = s_split("_", value)
					AURAS:UpdateHeader(filter)
				end,
			},
			sort_method = {
				order = 15,
				type = "select",
				name = L["SORT_METHOD"],
				values = {
					INDEX = L["INDEX"],
					NAME = L["NAME"],
					TIME = L["TIME"],
				},
				disabled = function() return not AURAS:IsInit() end,
				get = function()
					return C.db.profile.auras[E.UI_LAYOUT][filter].sort_method
				end,
				set = function(_, value)
					C.db.profile.auras[E.UI_LAYOUT][filter].sort_method = value
					AURAS:UpdateHeader(filter)
				end,
			},
			sort_dir = {
				order = 16,
				type = "select",
				name = L["SORT_DIR"],
				values = {
					["+"] = L["ASCENDING"],
					["-"] = L["DESCENDING"],
				},
				disabled = function() return not AURAS:IsInit() end,
				get = function()
					return C.db.profile.auras[E.UI_LAYOUT][filter].sort_dir
				end,
				set = function(_, value)
					C.db.profile.auras[E.UI_LAYOUT][filter].sort_dir = value
					AURAS:UpdateHeader(filter)
				end,
			},
			sep_own = {
				order = 17,
				type = "select",
				name = L["SEPARATION"],
				values = {
					[-1] = L["OTHERS_FIRST"],
					[0] = L["NO_SEPARATION"],
					[1] = L["YOURS_FIRST"],
				},
				disabled = function() return not AURAS:IsInit() end,
				get = function()
					return C.db.profile.auras[E.UI_LAYOUT][filter].sep_own
				end,
				set = function(_, value)
					C.db.profile.auras[E.UI_LAYOUT][filter].sep_own = value
					AURAS:UpdateHeader(filter)
				end,
			},
		},
	}

	return temp
end

function CFG:CreateAurasPanel(order)
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
					return C.db.char.auras.enabled
				end,
				set = function(_, value)
					C.db.char.auras.enabled = value

					if AURAS:IsInit() then
						if not value then
							CFG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if value then
							AURAS:Init()
						end
					end
				end
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CFG:CopySettings(D.profile.auras[E.UI_LAYOUT], C.db.profile.auras[E.UI_LAYOUT], {point = true})
					AURAS:Update()
				end,
			},
			buffs = GetOptionsTable_Aura("HELPFUL", 10, L["BUFFS"]),
			debuffs = GetOptionsTable_Aura("HARMFUL", 11, L["DEBUFFS"]),
			totems = {
				order = 12,
				type = "group",
				name = L["TOTEMS"],
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CFG:CopySettings(D.profile.auras[E.UI_LAYOUT].TOTEM, C.db.profile.auras[E.UI_LAYOUT].TOTEM, {point = true})
							AURAS:UpdateHeader("TOTEM")
						end,
					},
					spacer1 = {
						order = 9,
						type = "description",
						name = "",
					},
					num = {
						order = 10,
						type = "range",
						name = L["NUM_BUTTONS"],
						min = 1, max = 4, step = 1,
						disabled = function() return not AURAS:IsInit() end,
						get = function()
							return C.db.profile.auras[E.UI_LAYOUT].TOTEM.num
						end,
						set = function(_, value)
							C.db.profile.auras[E.UI_LAYOUT].TOTEM.num = value
							AURAS:UpdateHeader("TOTEM")
						end,
					},
					per_row = {
						order = 11,
						type = "range",
						name = L["PER_ROW"],
						min = 1, max = 4, step = 1,
						disabled = function() return not AURAS:IsInit() end,
						get = function()
							return C.db.profile.auras[E.UI_LAYOUT].TOTEM.per_row
						end,
						set = function(_, value)
							C.db.profile.auras[E.UI_LAYOUT].TOTEM.per_row = value
							AURAS:UpdateHeader("TOTEM")
						end,
					},
					spacing = {
						order = 12,
						type = "range",
						name = L["SPACING"],
						min = 4, max = 24, step = 2,
						disabled = function() return not AURAS:IsInit() end,
						get = function()
							return C.db.profile.auras[E.UI_LAYOUT].TOTEM.spacing
						end,
						set = function(_, value)
							C.db.profile.auras[E.UI_LAYOUT].TOTEM.spacing = value
							AURAS:UpdateHeader("TOTEM")
						end,
					},
					size = {
						order = 13,
						type = "range",
						name = L["SIZE"],
						min = 24, max = 64, step = 1,
						disabled = function() return not AURAS:IsInit() end,
						get = function()
							return C.db.profile.auras[E.UI_LAYOUT].TOTEM.size
						end,
						set = function(_, value)
							C.db.profile.auras[E.UI_LAYOUT].TOTEM.size = value
							AURAS:UpdateHeader("TOTEM")
						end,
					},
					growth_dir = {
						order = 14,
						type = "select",
						name = L["GROWTH_DIR"],
						values = {
							LEFT_DOWN = L["LEFT_DOWN"],
							LEFT_UP = L["LEFT_UP"],
							RIGHT_DOWN = L["RIGHT_DOWN"],
							RIGHT_UP = L["RIGHT_UP"],
						},
						disabled = function() return not AURAS:IsInit() end,
						get = function()
							return C.db.profile.auras[E.UI_LAYOUT].TOTEM.x_growth.."_"..C.db.profile.auras[E.UI_LAYOUT].TOTEM.y_growth
						end,
						set = function(_, value)
							C.db.profile.auras[E.UI_LAYOUT].TOTEM.x_growth, C.db.profile.auras[E.UI_LAYOUT].TOTEM.y_growth = s_split("_", value)
							AURAS:UpdateHeader("TOTEM")
						end,
					},
				},
			},
		},
	}
end
