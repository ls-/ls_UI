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

local flyout_dirs = {
	UP = L["UP"],
	DOWN = L["DOWN"],
	LEFT = L["LEFT"],
	RIGHT = L["RIGHT"],
}

local button_indicators = {
	button = L["ICON"],
	hotkey = L["KEYBIND_TEXT"],
}

local CURRENCY_TABLE = {
	order = 20,
	type = "group",
	name = L["CURRENCY"],
	guiInline = true,
	disabled = function() return not BARS:HasBags() end,
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

local function getOptionsTable_Fading(barID, order)
	local temp = {
		order = order,
		type = "group",
		name = L["FADING"],
		guiInline = true,
		get = function(info)
			return C.db.profile.bars[barID].fade[info[#info]]
		end,
		set = function(info, value)
			C.db.profile.bars[barID].fade[info[#info]] = value
			BARS:GetBar(barID):UpdateFading()
		end,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
			},
			in_delay = {
				order = 2,
				type = "range",
				name = L["FADE_IN_DELAY"],
				min = 0, max = 1, step = 0.05,
			},
			in_duration = {
				order = 3,
				type = "range",
				name = L["FADE_IN_DURATION"],
				min = 0, max = 1, step = 0.05,
			},
			out_delay = {
				order = 4,
				type = "range",
				name = L["FADE_OUT_DELAY"],
				min = 0, max = 2, step = 0.05,
			},
			out_duration = {
				order = 5,
				type = "range",
				name = L["FADE_OUT_DURATION"],
				min = 0, max = 1, step = 0.05,
			},
			min_alpha = {
				order = 6,
				type = "range",
				name = L["MIN_ALPHA"],
				min = 0, max = 1, step = 0.05,
			},
			max_alpha = {
				order = 7,
				type = "range",
				name = L["MIN_ALPHA"],
				min = 0, max = 1, step = 0.05
			},
		},
	}

	if barID == "bar1" then
		temp.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
	elseif barID == "pet_battle" then
		temp.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
	elseif barID == "micromenu" then
		temp.set = function(info, value)
			C.db.profile.bars[barID].fade[info[#info]] = value
			BARS:GetBar("menu1"):UpdateFading()
			BARS:GetBar("menu2"):UpdateFading()
		end
	elseif barID == "bags" then
		temp.disabled = function() return BARS:IsRestricted() or not BARS:HasBags() end
	elseif barID == "xpbar" then
		temp.disabled = function() return not BARS:HasXPBar() end
	end

	return temp
end

local function getOptionsTable_Bar(barID, order, name)
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
					BARS:GetBar(barID):UpdateFading()
					BARS:GetBar(barID):UpdateVisibility()
				end
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.bars[barID], C.db.profile.bars[barID], {visible = true, point = true})
					BARS:GetBar(barID):Update()
				end,
			},
			spacer1 = {
				order = 10,
				type = "description",
				name = "",
			},
			grid = {
				order = 11,
				type = "toggle",
				name = L["GRID"],
				get = function()
					return C.db.profile.bars[barID].grid
				end,
				set = function(_, value)
					C.db.profile.bars[barID].grid = value
					BARS:GetBar(barID):UpdateConfig()
					BARS:GetBar(barID):UpdateButtonConfig()
				end,
			},
			hotkey = {
				order = 12,
				type = "toggle",
				name = L["KEYBIND_TEXT"],
				get = function()
					return C.db.profile.bars[barID].hotkey
				end,
				set = function(_, value)
					C.db.profile.bars[barID].hotkey = value
					BARS:GetBar(barID):UpdateConfig()
					BARS:GetBar(barID):UpdateButtonConfig()
				end,
			},
			macro = {
				order = 13,
				type = "toggle",
				name = L["MACRO_TEXT"],
				get = function()
					return C.db.profile.bars[barID].macro
				end,
				set = function(_, value)
					C.db.profile.bars[barID].macro = value
					BARS:GetBar(barID):UpdateConfig()
					BARS:GetBar(barID):UpdateButtonConfig()
				end,
			},
			num = {
				order = 14,
				type = "range",
				name = L["NUM_BUTTONS"],
				min = 1, max = 12, step = 1,
				get = function()
					return C.db.profile.bars[barID].num
				end,
				set = function(_, value)
					C.db.profile.bars[barID].num = value
					BARS:GetBar(barID):Update()
				end,
			},
			per_row = {
				order = 15,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 12, step = 1,
				get = function()
					return C.db.profile.bars[barID].per_row
				end,
				set = function(_, value)
					C.db.profile.bars[barID].per_row = value
					BARS:GetBar(barID):Update()
				end,
			},
			spacing = {
				order = 16,
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 2,
				get = function()
					return C.db.profile.bars[barID].spacing
				end,
				set = function(_, value)
					C.db.profile.bars[barID].spacing = value
					BARS:GetBar(barID):Update()
				end,
			},
			size = {
				order = 17,
				type = "range",
				name = L["SIZE"],
				min = 18, max = 64, step = 1,
				get = function()
					return C.db.profile.bars[barID].size
				end,
				set = function(_, value)
					C.db.profile.bars[barID].size = value
					BARS:GetBar(barID):Update()
				end,
			},
			growth_dir = {
				order = 18,
				type = "select",
				name = L["GROWTH_DIR"],
				values = growth_dirs,
				get = function()
					return C.db.profile.bars[barID].x_growth.."_"..C.db.profile.bars[barID].y_growth
				end,
				set = function(_, value)
					C.db.profile.bars[barID].x_growth, C.db.profile.bars[barID].y_growth = s_split("_", value)
					BARS:GetBar(barID):Update()
				end,
			},
			flyout_dir = {
				order = 19,
				type = "select",
				name = L["FLYOUT_DIR"],
				values = flyout_dirs,
				get = function()
					return C.db.profile.bars[barID].flyout_dir
				end,
				set = function(_, value)
					C.db.profile.bars[barID].flyout_dir = value
					BARS:GetBar(barID):UpdateConfig()
					BARS:GetBar(barID):UpdateButtonConfig()
				end,
			},
			fading = getOptionsTable_Fading(barID, 30),
		},
	}

	if barID == "bar1" then
		temp.args.visible.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.reset.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.num.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.per_row.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.spacing.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.size.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.growth_dir.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.flyout_dir.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
	elseif barID == "bar6" then
		temp.args.grid.set = function(_, value)
			C.db.profile.bars[barID].grid = value
			BARS:GetBar(barID):UpdateButtons("UpdateGrid")
		end
		temp.args.hotkey.set = function(_, value)
			C.db.profile.bars[barID].hotkey = value
			BARS:GetBar(barID):UpdateButtons("UpdateHotKey")
		end
		temp.args.macro = nil
		temp.args.num.max = 10
		temp.args.per_row.max = 10
		temp.args.flyout_dir = nil
	elseif barID == "bar7" then
		temp.args.grid = nil
		temp.args.hotkey.set = function(_, value)
			C.db.profile.bars[barID].hotkey = value
			BARS:GetBar(barID):UpdateButtons("UpdateHotKey")
		end
		temp.args.macro = nil
		temp.args.num.max = 10
		temp.args.per_row.max = 10
		temp.args.flyout_dir = nil
	elseif barID == "pet_battle" then
		temp.args.visible = nil
		temp.args.reset.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.grid = nil
		temp.args.hotkey.set = function(_, value)
			C.db.profile.bars[barID].hotkey = value
			BARS:GetBar(barID):UpdateConfig()
			BARS:GetBar(barID):UpdateButtons("UpdateHotKey")
		end
		temp.args.macro = nil
		temp.args.num.max = 6
		temp.args.num.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.per_row.max = 6
		temp.args.per_row.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.spacing.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.size.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.growth_dir.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.flyout_dir = nil
	elseif barID == "extra" then
		temp.args.visible = nil
		temp.args.grid = nil
		temp.args.hotkey.set = function(_, value)
			C.db.profile.bars[barID].hotkey = value
			BARS:GetBar(barID):UpdateConfig()
			BARS:GetBar(barID):UpdateButtons("UpdateHotKey")
		end
		temp.args.macro = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
	elseif barID == "zone" then
		temp.args.visible = nil
		temp.args.grid = nil
		temp.args.hotkey = nil
		temp.args.macro = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
	elseif barID == "vehicle" then
		temp.args.visible = nil
		temp.args.grid = nil
		temp.args.hotkey = nil
		temp.args.macro = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
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
		temp.args.visible = nil
		temp.args.reset.disabled = function()
			return BARS:IsRestricted() or not BARS:HasBags()
		end
		temp.args.grid = nil
		temp.args.hotkey = nil
		temp.args.macro = nil
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
		temp.args.flyout_dir = nil
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
			lock = {
				order = 10,
				type = "toggle",
				name = L["LOCK_BUTTONS"],
				desc = L["LOCK_BUTTONS_DESC"],
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.lock
				end,
				set = function(_, value)
					C.db.profile.bars.lock = value
					BARS:UpdateBars("UpdateConfig")
					BARS:UpdateBars("UpdateButtonConfig")

					SetCVar("lockActionBars", value and 1 or 0)
				end,
			},
			rightclick_selfcast = {
				order = 11,
				type = "toggle",
				name = L["RCLICK_SELFCAST"],
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.rightclick_selfcast
				end,
				set = function(_, value)
					C.db.profile.bars.rightclick_selfcast = value
					BARS:UpdateBars("UpdateConfig")
					BARS:UpdateBars("UpdateButtonConfig")
				end,
			},
			click_on_down = {
				order = 12,
				type = "toggle",
				name = L["CAST_ON_KEY_DOWN"],
				desc = L["CAST_ON_KEY_DOWN_DESC"],
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.click_on_down
				end,
				set = function(_, value)
					C.db.profile.bars.click_on_down = value
					BARS:UpdateBars("UpdateConfig")
					BARS:UpdateBars("UpdateButtonConfig")
					BARS:UpdateBars("UpdateButtons", "Reset")
				end,
			},
			range_indicator = {
				order = 13,
				type = "select",
				name = L["OOR_INDICATOR"],
				values = button_indicators,
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.range_indicator
				end,
				set = function(_, value)
					C.db.profile.bars.range_indicator = value
					BARS:UpdateBars("UpdateConfig")
					BARS:UpdateBars("UpdateButtonConfig")
					BARS:UpdateBars("UpdateButtons", "Reset")
				end,
			},
			mana_indicator = {
				order = 14,
				type = "select",
				name = L["OOM_INDICATOR"],
				values = button_indicators,
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.mana_indicator
				end,
				set = function(_, value)
					C.db.profile.bars.mana_indicator = value
					BARS:UpdateBars("UpdateConfig")
					BARS:UpdateBars("UpdateButtonConfig")
				end,
			},
			desaturate_on_cd = {
				order = 15,
				type = "toggle",
				name = L["DESATURATE_ON_COOLDOWN"],
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.desaturate_on_cd
				end,
				set = function(_, value)
					C.db.profile.bars.desaturate_on_cd = value
					BARS:UpdateBars("UpdateConfig")
					BARS:UpdateBars("UpdateButtonConfig")
					BARS:UpdateBars("UpdateButtons", "Reset")
				end,
			},
			action_bar_1 = getOptionsTable_Bar("bar1", 1, L["BAR_1"]),
			action_bar_2 = getOptionsTable_Bar("bar2", 2, L["BAR_2"]),
			action_bar_3 = getOptionsTable_Bar("bar3", 3, L["BAR_3"]),
			action_bar_4 = getOptionsTable_Bar("bar4", 4, L["BAR_4"]),
			action_bar_5 = getOptionsTable_Bar("bar5", 5, L["BAR_5"]),
			action_bar_6 = getOptionsTable_Bar("bar6", 6, L["PET_BAR"]),
			action_bar_7 = getOptionsTable_Bar("bar7", 7, L["STANCE_BAR"]),
			pet_battle = getOptionsTable_Bar("pet_battle", 8, L["PET_BATTLE_BAR"]),
			extra = getOptionsTable_Bar("extra", 9, L["EXTRA_ACTION_BUTTON"]),
			zone = getOptionsTable_Bar("zone", 10, L["ZONE_ABILITY_BUTTON"]),
			vehicle = getOptionsTable_Bar("vehicle", 11, L["VEHICLE_EXIT_BUTTON"]),
			bags = getOptionsTable_Bar("bags", 14, L["BAGS"])
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
				disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end,
				func = function()
					CONFIG:CopySettings(D.profile.bars.micromenu, C.db.profile.bars.micromenu, {menu1 = true, menu2 = true})
					BARS:GetBar("menu1"):Update()
					BARS:GetBar("menu2"):Update()
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
				get = function(info)
					return C.db.profile.bars.micromenu.tooltip[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.bars.micromenu.tooltip[info[#info]] = value
					BARS:GetBar("menu1"):UpdateButtons("Update")
					BARS:GetBar("menu2"):UpdateButtons("Update")
				end,
				args = {
					character = {
						order = 1,
						type = "toggle",
						name = L["CHARACTER_BUTTON"],
						desc = L["CHARACTER_BUTTON_DESC"],

					},
					quest = {
						order = 2,
						type = "toggle",
						name = L["QUESTLOG_BUTTON"],
						desc = L["QUESTLOG_BUTTON_DESC"],
					},
					lfd = {
						order = 3,
						type = "toggle",
						name = L["DUNGEONS_BUTTON"],
						desc = L["DUNGEONS_BUTTON_DESC"],
					},
					ej = {
						order = 4,
						type = "toggle",
						name = L["ADVENTURE_JOURNAL"],
						desc = L["ADVENTURE_JOURNAL_DESC"],
					},
					main = {
						order = 5,
						type = "toggle",
						name = L["MAINMENU_BUTTON"],
						desc = L["MAINMENU_BUTTON_DESC"],
					},
				},
			},
			fading = getOptionsTable_Fading("micromenu", 20)
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
				disabled = function() return not BARS:HasXPBar() end,
				func = function()
					CONFIG:CopySettings(D.profile.bars.xpbar, C.db.profile.bars.xpbar, {point = true})
					BARS:GetBar("xpbar"):Update()
				end,
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
				disabled = function() return not BARS:HasXPBar() end,
				min = 530, max = 1912, step = 2,
				get = function()
					return C.db.profile.bars.xpbar.width
				end,
				set = function(_, value)
					C.db.profile.bars.xpbar.width = value
					BARS:GetBar("xpbar"):Update()
				end,
			},
			fading = getOptionsTable_Fading("xpbar", 20)
		},
	}
end
