local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local s_split = _G.string.split
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber

-- Blizz
local GetCurrencyListInfo = _G.GetCurrencyListInfo
local GetCurrencyListLink = _G.GetCurrencyListLink
local GetCurrencyListSize = _G.GetCurrencyListSize

-- Mine
local growth_dirs = {
	LEFT_DOWN = L["LEFT_DOWN"],
	LEFT_UP = L["LEFT_UP"],
	RIGHT_DOWN = L["RIGHT_DOWN"],
	RIGHT_UP = L["RIGHT_UP"],
}

local CURRENCY_TABLE = {
	order = 20,
	type = "group",
	name = L["CURRENCY"],
	guiInline = true,
	args = {}
}

local function UpdateCurrencyOptions()
	local options = C.options and C.options.args.bars and C.options.args.bars.args.bags.args.currency.args or CURRENCY_TABLE.args
	local name, isHeader, icon, link, _

	t_wipe(options)

	for i = 1, GetCurrencyListSize() do
		name, isHeader, _, _, _, _, icon = GetCurrencyListInfo(i)

		if isHeader then
			options["currency_"..i] = {
				order = i,
				type = "header",
				name = name,
			}
		else
			link = GetCurrencyListLink(i)

			if link then
				local id = tonumber(link:match("currency:(%d+)") or "", nil)

				if id then
					options["currency_"..i] = {
						order = i,
						type = "toggle",
						name = name,
						image = icon,
						get = function()
							return C.db.profile.bars.bags.currency[id]
						end,
						set = function(_, value)
							C.db.profile.bars.bags.currency[id] = value and value or nil
						end,
					}
				end
			end
		end
	end
end

E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", UpdateCurrencyOptions)
hooksecurefunc("TokenFrame_Update", UpdateCurrencyOptions)

local function GetOptionsTable_Bar(barID, order, name)
	local temp = {
		order = order,
		type = "group",
		childGroups = "select",
		name = name,
		disabled = function() return not BARS:IsInit() end,
		args = {
			visible = {
				order = 1,
				type = "toggle",
				name = L["SHOW"],
				get = function()
					return C.db.profile.bars[barID].visible
				end,
				set = function(_, value)
					C.db.profile.bars[barID].visible = value
					BARS:ToggleBar(barID, value)
				end
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.bars[barID], C.db.profile.bars[barID], {visible = true, point = true})
					BARS:UpdateBar(barID)
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
				min = 1, max = 12, step = 1,
				get = function()
					return C.db.profile.bars[barID].num
				end,
				set = function(_, value)
					C.db.profile.bars[barID].num = value
					BARS:UpdateBar(barID)
				end,
			},
			per_row = {
				order = 11,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 12, step = 1,
				get = function()
					return C.db.profile.bars[barID].per_row
				end,
				set = function(_, value)
					C.db.profile.bars[barID].per_row = value
					BARS:UpdateBar(barID)
				end,
			},
			spacing = {
				order = 12,
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 2,
				get = function()
					return C.db.profile.bars[barID].spacing
				end,
				set = function(_, value)
					C.db.profile.bars[barID].spacing = value
					BARS:UpdateBar(barID)
				end,
			},
			size = {
				order = 13,
				type = "range",
				name = L["SIZE"],
				min = 18, max = 64, step = 1,
				get = function()
					return C.db.profile.bars[barID].size
				end,
				set = function(_, value)
					C.db.profile.bars[barID].size = value
					BARS:UpdateBar(barID)
				end,
			},
			growth_dir = {
				order = 14,
				type = "select",
				name = L["GROWTH_DIR"],
				values = growth_dirs,
				get = function()
					return C.db.profile.bars[barID].x_growth.."_"..C.db.profile.bars[barID].y_growth
				end,
				set = function(_, value)
					C.db.profile.bars[barID].x_growth, C.db.profile.bars[barID].y_growth = s_split("_", value)
					BARS:UpdateBar(barID)
				end,
			},
		},
	}

	if barID == "bar1" then
		temp.disabled = function()
			return BARS:IsRestricted() or not BARS:IsInit()
		end
	elseif barID == "bar6" then
		temp.args.num.max = 10
		temp.args.per_row.max = 10
	elseif barID == "bar7" then
		temp.args.num.max = 10
		temp.args.per_row.max = 10
	elseif barID == "pet_battle" then
		temp.disabled = function()
			return BARS:IsRestricted() or not BARS:IsInit()
		end

		temp.args.visible = nil
		temp.args.num.max = 6
		temp.args.per_row.max = 6
	elseif barID == "bags" then
		temp.args.enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			get = function()
				return C.db.char.bars[barID].enabled
			end,
			set = function(_, value)
				C.db.char.bars[barID].enabled = value

				if BARS:IsInit() then
					if BARS:HasBags() then
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if BARS:IsRestricted() then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						else
							if value then
								BARS:CreateBags()
							end
						end
					end
				end
			end
		}
		temp.args.reset.disabled = function()
			return BARS:IsRestricted() or not BARS:HasBags()
		end
		temp.args.visible = nil
		temp.args.num = nil
		temp.args.per_row.disabled = function()
			return BARS:IsRestricted() or not BARS:HasBags()
		end
		temp.args.per_row.max = 5
		temp.args.spacing.disabled = function()
			return BARS:IsRestricted() or not BARS:HasBags()
		end
		temp.args.size.disabled = function()
			return BARS:IsRestricted() or not BARS:HasBags()
		end
		temp.args.growth_dir.disabled = function()
			return BARS:IsRestricted() or not BARS:HasBags()
		end
		temp.args.currency = CURRENCY_TABLE
	end

	return temp
end

function CONFIG.CreateActionBarsPanel(_, order)
	C.options.args.bars = {
		order = order,
		type = "group",
		name = L["ACTION_BARS"],
		childGroups = "tree",
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.bars.enabled
				end,
				set = function(_, value)
					C.db.char.bars.enabled = value

					if BARS:IsInit() then
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if value then
							BARS:Init()
						end
					end
				end
			},
			restricted = {
				order = 2,
				type = "toggle",
				name = L["RESTRICTED_MODE"],
				desc = L["RESTRICTED_MODE_DESC"],
				get = function()
					return C.db.char.bars.restricted
				end,
				set = function(_, value)
					C.db.char.bars.restricted = value

					if BARS:IsInit() then
						CONFIG:ShowStaticPopup("RELOAD_UI")
					end
				end
			},
			spacer1 = {
				order = 3,
				type = "description",
				name = "",
			},
			macro = {
				order = 4,
				type = "toggle",
				name = L["MACRO_TEXT"],
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.macro
				end,
				set = function(_, value)
					C.db.profile.bars.macro = value
					BARS:ToggleMacroText(value)
				end,
			},
			hotkey = {
				order = 5,
				type = "toggle",
				name = L["KEYBIND_TEXT"],
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.hotkey
				end,
				set = function(_, value)
					C.db.profile.bars.hotkey = value
					BARS:ToggleHotKeyText(value)
				end,
			},
			icon_indicator = {
				order = 6,
				type = "toggle",
				width = "double",
				name = L["USE_ICON_AS_INDICATOR"],
				desc = L["USE_ICON_AS_INDICATOR_DESC"],
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.icon_indicator
				end,
				set = function(_, value)
					C.db.profile.bars.icon_indicator = value
					BARS:ToggleIconIndicators(value)
				end,
			},
			action_bar_1 = GetOptionsTable_Bar("bar1", 1, L["BAR_1"]),
			action_bar_2 = GetOptionsTable_Bar("bar2", 2, L["BAR_2"]),
			action_bar_3 = GetOptionsTable_Bar("bar3", 3, L["BAR_3"]),
			action_bar_4 = GetOptionsTable_Bar("bar4", 4, L["BAR_4"]),
			action_bar_5 = GetOptionsTable_Bar("bar5", 5, L["BAR_5"]),
			action_bar_6 = GetOptionsTable_Bar("bar6", 6, L["PET_BAR"]),
			action_bar_7 = GetOptionsTable_Bar("bar7", 7, L["STANCE_BAR"]),
			pet_battle = GetOptionsTable_Bar("pet_battle", 8, L["PET_BATTLE_BAR"]),
		},
	}

	C.options.args.bars.args.extra = {
		order = 9,
		type = "group",
		childGroups = "select",
		name = L["EXTRA_ACTION_BUTTON"],
		disabled = function() return not BARS:IsInit() end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.bars.extra, C.db.profile.bars.extra, {point = true})
					BARS:UpdateExtraButton()
				end,
			},
			spacer1 = {
				order = 2,
				type = "description",
				name = "",
			},
			size = {
				order = 3,
				type = "range",
				name = L["SIZE"],
				min = 18, max = 64, step = 1,
				get = function()
					return C.db.profile.bars.extra.size
				end,
				set = function(_, value)
					C.db.profile.bars.extra.size = value
					BARS:UpdateExtraButton()
				end,
			},
		},
	}

	C.options.args.bars.args.zone = {
		order = 10,
		type = "group",
		childGroups = "select",
		name = L["ZONE_ABILITY_BUTTON"],
		disabled = function() return not BARS:IsInit() end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.bars.zone, C.db.profile.bars.zone, {point = true})
					BARS:UpdateZoneButton()
				end,
			},
			spacer1 = {
				order = 2,
				type = "description",
				name = "",
			},
			size = {
				order = 3,
				type = "range",
				name = L["SIZE"],
				min = 18, max = 64, step = 1,
				get = function()
					return C.db.profile.bars.zone.size
				end,
				set = function(_, value)
					C.db.profile.bars.zone.size = value
					BARS:UpdateZoneButton()
				end,
			},
		},
	}

	C.options.args.bars.args.vehicle = {
		order = 11,
		type = "group",
		childGroups = "select",
		name = L["VEHICLE_EXIT_BUTTON"],
		disabled = function() return not BARS:IsInit() end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.bars.vehicle, C.db.profile.bars.vehicle, {point = true})
					BARS:UpdateVehicleExitButton()
				end,
			},
			spacer1 = {
				order = 2,
				type = "description",
				name = "",
			},
			size = {
				order = 3,
				type = "range",
				name = L["SIZE"],
				min = 18, max = 64, step = 1,
				get = function()
					return C.db.profile.bars.vehicle.size
				end,
				set = function(_, value)
					C.db.profile.bars.vehicle.size = value
					BARS:UpdateVehicleExitButton()
				end,
			},
		},
	}

	C.options.args.bars.args.micromenu = {
		order = 12,
		type = "group",
		childGroups = "select",
		name = L["MICRO_BUTTONS"],
		disabled = function() return not BARS:IsInit() end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.bars.micromenu.tooltip, C.db.profile.bars.micromenu.tooltip)
					BARS:UpdateMicroButtons()
				end,
			},
			spacer1 = {
				order = 9,
				type = "description",
				name = "",
			},
			tooltip = {
				order = 10,
				type = "group",
				name = L["ENHANCED_TOOLTIPS"],
				guiInline = true,
				args = {
					character = {
						order = 1,
						type = "toggle",
						name = L["CHARACTER_BUTTON"],
						desc = L["CHARACTER_BUTTON_DESC"],
						get = function()
							return C.db.profile.bars.micromenu.tooltip.character
						end,
						set = function(_, value)
							C.db.profile.bars.micromenu.tooltip.character = value

							BARS:UpdateMicroButton("CharacterMicroButton")
						end,
					},
					quest = {
						order = 2,
						type = "toggle",
						name = L["QUESTLOG_BUTTON"],
						desc = L["QUESTLOG_BUTTON_DESC"],
						get = function()
							return C.db.profile.bars.micromenu.tooltip.quest
						end,
						set = function(_, value)
							C.db.profile.bars.micromenu.tooltip.quest = value

							BARS:UpdateMicroButton("QuestLogMicroButton")
						end,
					},
					lfd = {
						order = 3,
						type = "toggle",
						name = L["DUNGEONS_BUTTON"],
						desc = L["DUNGEONS_BUTTON_DESC"],
						get = function()
							return C.db.profile.bars.micromenu.tooltip.lfd
						end,
						set = function(_, value)
							C.db.profile.bars.micromenu.tooltip.lfd = value

							BARS:UpdateMicroButton("LFDMicroButton")
						end,
					},
					ej = {
						order = 4,
						type = "toggle",
						name = L["ADVENTURE_JOURNAL"],
						desc = L["ADVENTURE_JOURNAL_DESC"],
						get = function()
							return C.db.profile.bars.micromenu.tooltip.ej
						end,
						set = function(_, value)
							C.db.profile.bars.micromenu.tooltip.ej = value

							BARS:UpdateMicroButton("EJMicroButton")
						end,
					},
					main = {
						order = 5,
						type = "toggle",
						name = L["MAINMENU_BUTTON"],
						desc = L["MAINMENU_BUTTON_DESC"],
						get = function()
							return C.db.profile.bars.micromenu.tooltip.main
						end,
						set = function(_, value)
							C.db.profile.bars.micromenu.tooltip.main = value

							BARS:UpdateMicroButton("MainMenuMicroButton")
						end,
					},
				},
			},
		},
	}

	C.options.args.bars.args.xpbar = {
		order = 13,
		type = "group",
		childGroups = "select",
		name = L["XP_BAR"],
		disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.bars.xpbar.enabled
				end,
				set = function(_, value)
					C.db.char.bars.xpbar.enabled = value

					if BARS:IsInit() then
						if BARS:HasXPBar() then
							if not value then
								CONFIG:ShowStaticPopup("RELOAD_UI")
							end
						else
							if value then
								BARS:CreateXPBar()
							end
						end
					end
				end
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.bars.xpbar, C.db.profile.bars.xpbar, {point = true})
					BARS:UpdateXPBar()
				end,
				disabled = function() return not BARS:HasXPBar() end,
			},
			spacer1 = {
				order = 9,
				type = "description",
				name = "",
			},
			width = {
				order = 10,
				type = "range",
				name = L["WIDTH"],
				min = 530, max = 1912, step = 2,
				get = function()
					return C.db.profile.bars.xpbar.width
				end,
				set = function(_, value)
					C.db.profile.bars.xpbar.width = value
					BARS:UpdateXPBar()
				end,
				disabled = function() return not BARS:HasXPBar() end,
			},
		},
	}

	C.options.args.bars.args.bags = GetOptionsTable_Bar("bags", 14, L["BAGS"])
end
