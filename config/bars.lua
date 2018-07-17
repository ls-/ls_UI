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

--[[ luacheck: globals
	ACHIEVEMENT_BUTTON ADVENTURE_JOURNAL BLIZZARD_STORE CHARACTER_BUTTON COLLECTIONS DUNGEONS_BUTTON
	GUILD_AND_COMMUNITIES HELP_BUTTON MAINMENU_BUTTON QUESTLOG_BUTTON SPELLBOOK_ABILITIES_BUTTON TALENTS_BUTTON

	SetCVar
]]

-- Blizz
local GetCurrencyListInfo = _G.GetCurrencyListInfo
local GetCurrencyListLink = _G.GetCurrencyListLink
local GetCurrencyListSize = _G.GetCurrencyListSize

-- Mine
local GROWTH_DIRS = {
	LEFT_DOWN = L["LEFT_DOWN"],
	LEFT_UP = L["LEFT_UP"],
	RIGHT_DOWN = L["RIGHT_DOWN"],
	RIGHT_UP = L["RIGHT_UP"],
}

local FLYOUT_DIRS = {
	UP = L["UP"],
	DOWN = L["DOWN"],
	LEFT = L["LEFT"],
	RIGHT = L["RIGHT"],
}

local BUTTON_INDICATORS = {
	button = L["ICON"],
	hotkey = L["KEYBIND_TEXT"],
}

local FONT_FLAGS = {
	[""] = L["NONE"],
	["Outline"] = L["OUTLINE"],
	["Shadow"] = L["SHADOW"],
}

local CURRENCY_TABLE = {
	order = 10,
	type = "group",
	name = L["CURRENCY"],
	inline = true,
	args = {}
}

local function updateCurrencyOptions()
	local options = C.options and C.options.args.bars and C.options.args.bars.args.micromenu.args.inventory.args.currency.args or CURRENCY_TABLE.args
	local listSize = GetCurrencyListSize()
	local name, isHeader, icon, link, _

	t_wipe(options)

	if listSize > 0 then
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
								return C.db.profile.bars.micromenu.buttons.inventory.currency[id]
							end,
							set = function(_, value)
								C.db.profile.bars.micromenu.buttons.inventory.currency[id] = value and value or nil
							end,
						}
					end
				end
			end
		end
	else
		options.error = {
			order = 1,
			type = "description",
			name = L["NOTHING_TO_SHOW"],
		}
	end
end

E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateCurrencyOptions)
hooksecurefunc("TokenFrame_Update", updateCurrencyOptions)

local function getOptionsTable_Fading(barID, order)
	local temp = {
		order = order,
		type = "group",
		name = L["FADING"],
		inline = true,
		get = function(info)
			return C.db.profile.bars[barID].fade[info[#info]]
		end,
		set = function(info, value)
			C.db.profile.bars[barID].fade[info[#info]] = value
			BARS:GetBar(barID):UpdateConfig()
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
				min = 0.05, max = 1, step = 0.05,
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
				min = 0.05, max = 1, step = 0.05,
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
				name = L["MAX_ALPHA"],
				min = 0, max = 1, step = 0.05
			},
		},
	}

	if barID == "bar1" then
		temp.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
	elseif barID == "pet_battle" then
		temp.disabled = function() return BARS:IsRestricted() or not BARS:HasPetBattleBar() end
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
				order = 9,
				type = "description",
				name = "",
			},
			visible = {
				order = 10,
				type = "toggle",
				name = L["SHOW"],
				get = function()
					return C.db.profile.bars[barID].visible
				end,
				set = function(_, value)
					C.db.profile.bars[barID].visible = value
					BARS:GetBar(barID):UpdateConfig()
					BARS:GetBar(barID):UpdateFading()
					BARS:GetBar(barID):UpdateVisibility()
				end
			},
			grid = {
				order = 11,
				type = "toggle",
				name = L["BUTTON_GRID"],
				get = function()
					return C.db.profile.bars[barID].grid
				end,
				set = function(_, value)
					C.db.profile.bars[barID].grid = value
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
				values = GROWTH_DIRS,
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
				values = FLYOUT_DIRS,
				get = function()
					return C.db.profile.bars[barID].flyout_dir
				end,
				set = function(_, value)
					C.db.profile.bars[barID].flyout_dir = value
					BARS:GetBar(barID):UpdateConfig()
					BARS:GetBar(barID):UpdateButtonConfig()
				end,
			},
			hotkey = {
				order = 20,
				type = "group",
				name = L["KEYBIND_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.bars[barID].hotkey[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.bars[barID].hotkey[info[#info]] ~= value then
						C.db.profile.bars[barID].hotkey[info[#info]] = value
						BARS:GetBar(barID):UpdateConfig()
						BARS:GetBar(barID):UpdateButtons("UpdateHotKeyFont")
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return C.db.profile.bars[barID].hotkey.enabled
						end,
						set = function(_, value)
							C.db.profile.bars[barID].hotkey.enabled = value
							BARS:GetBar(barID):UpdateConfig()
							BARS:GetBar(barID):UpdateButtons("UpdateHotKey")
						end,
					},
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 10, max = 20, step = 2,
					},
					-- flag = {
					-- 	order = 3,
					-- 	type = "select",
					-- 	name = L["FLAG"],
					-- 	values = FONT_FLAGS,
					-- },
				},
			},
			macro = {
				order = 30,
				type = "group",
				name = L["MACRO_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.bars[barID].macro[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.bars[barID].macro[info[#info]] ~= value then
						C.db.profile.bars[barID].macro[info[#info]] = value
						BARS:GetBar(barID):UpdateConfig()
						BARS:GetBar(barID):UpdateButtons("UpdateMacroFont")
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return C.db.profile.bars[barID].macro.enabled
						end,
						set = function(_, value)
							C.db.profile.bars[barID].macro.enabled = value
							BARS:GetBar(barID):UpdateConfig()
							BARS:GetBar(barID):UpdateButtonConfig()
						end,
					},
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 10, max = 20, step = 2,
					},
					-- flag = {
					-- 	order = 3,
					-- 	type = "select",
					-- 	name = L["FLAG"],
					-- 	values = FONT_FLAGS,
					-- },
				},
			},
			count = {
				order = 40,
				type = "group",
				name = L["COUNT_TEXT"],
				inline = true,
				get = function(info)
					return C.db.profile.bars[barID].count[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.bars[barID].count[info[#info]] ~= value then
						C.db.profile.bars[barID].count[info[#info]] = value
						BARS:GetBar(barID):UpdateConfig()
						BARS:GetBar(barID):UpdateButtons("UpdateCountFont")
					end
				end,
				args = {
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 10, max = 20, step = 2,
					},
					-- flag = {
					-- 	order = 3,
					-- 	type = "select",
					-- 	name = L["FLAG"],
					-- 	values = FONT_FLAGS,
					-- },
				},
			},
			fading = getOptionsTable_Fading(barID, 50),
		},
	}

	if barID == "bar1" then
		temp.args.reset.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.visible.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.num.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.per_row.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.spacing.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.size.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.growth_dir.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.flyout_dir.disabled = function() return BARS:IsRestricted() or not BARS:IsInit() end
		temp.args.hotkey.args.enabled.set = function(_, value)
			C.db.profile.bars[barID].hotkey.enabled = value
			BARS:GetBar(barID):UpdateConfig()
			BARS:GetBar(barID):UpdateButtonConfig()
		end
	elseif barID == "bar6" then
		temp.args.grid.set = function(_, value)
			C.db.profile.bars[barID].grid = value
			BARS:GetBar(barID):UpdateConfig()
			BARS:GetBar(barID):UpdateButtons("UpdateGrid")
		end
		temp.args.num.max = 10
		temp.args.per_row.max = 10
		temp.args.flyout_dir = nil
		temp.args.macro = nil
		temp.args.count = nil
	elseif barID == "bar7" then
		temp.args.grid = nil
		temp.args.num.max = 10
		temp.args.per_row.max = 10
		temp.args.flyout_dir = nil
		temp.args.macro = nil
		temp.args.count = nil
	elseif barID == "pet_battle" then
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
					if BARS:HasPetBattleBar() then
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if BARS:IsRestricted() then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						else
							if value then
								BARS:CreatePetBattleBar()
							end
						end
					end
				end
			end,
			disabled = function() return BARS:IsRestricted() end,
		}
		temp.args.reset.disabled = function() return BARS:IsRestricted() or not BARS:HasPetBattleBar() end
		temp.args.visible.disabled = function() return BARS:IsRestricted() or not BARS:HasPetBattleBar() end
		temp.args.grid = nil
		temp.args.num.max = 6
		temp.args.num.disabled = function() return BARS:IsRestricted() or not BARS:HasPetBattleBar() end
		temp.args.per_row.max = 6
		temp.args.per_row.disabled = function() return BARS:IsRestricted() or not BARS:HasPetBattleBar() end
		temp.args.spacing.disabled = function() return BARS:IsRestricted() or not BARS:HasPetBattleBar() end
		temp.args.size.disabled = function() return BARS:IsRestricted() or not BARS:HasPetBattleBar() end
		temp.args.growth_dir.disabled = function() return BARS:IsRestricted() or not BARS:HasPetBattleBar() end
		temp.args.flyout_dir = nil
		temp.args.hotkey.disabled = function() return not BARS:HasPetBattleBar() end
		temp.args.macro = nil
		temp.args.count = nil
	elseif barID == "extra" then
		temp.args.grid = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
		temp.args.macro = nil
		temp.args.count = nil
	elseif barID == "zone" then
		temp.args.grid = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
		temp.args.hotkey = nil
		temp.args.macro = nil
		temp.args.count = nil
	elseif barID == "vehicle" then
		temp.args.grid = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
		temp.args.hotkey = nil
		temp.args.macro = nil
		temp.args.count = nil
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
			blizz_vehicle = {
				order = 3,
				type = "toggle",
				name = L["USE_BLIZZARD_VEHICLE_UI"],
				disabled = function() return not BARS:IsInit() or BARS:IsRestricted() end,
				get = function()
					return C.db.profile.bars.blizz_vehicle
				end,
				set = function(_, value)
					C.db.profile.bars.blizz_vehicle = value

					if BARS:IsInit() then
						BARS:UpdateBlizzVehicle()
					end
				end
			},
			spacer1 = {
				order = 9,
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

					SetCVar("ActionButtonUseKeyDown", value and 1 or 0)
				end,
			},
			range_indicator = {
				order = 13,
				type = "select",
				name = L["OOR_INDICATOR"],
				values = BUTTON_INDICATORS,
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
				values = BUTTON_INDICATORS,
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
			draw_bling = {
				order = 15,
				type = "toggle",
				name = L["DRAW_COOLDOWN_BLING"],
				desc = L["DRAW_COOLDOWN_BLING_DESC"],
				disabled = function() return not BARS:IsInit() end,
				get = function()
					return C.db.profile.bars.draw_bling
				end,
				set = function(_, value)
					C.db.profile.bars.draw_bling = value
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
		},
	}

	C.options.args.bars.args.micromenu = {
		order = 12,
		type = "group",
		childGroups = "tab",
		name = L["MICRO_BUTTONS"],
		disabled = function() return not BARS:IsInit() end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.bars.micromenu, C.db.profile.bars.micromenu, {currency = true, point = true})
					BARS:GetBar("micromenu"):Update()
				end,
			},
			spacer1 = {
				order = 9,
				type = "description",
				name = "",
			},
			per_row = {
				order = 10,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 13, step = 1,
				get = function()
					return C.db.profile.bars.micromenu.per_row
				end,
				set = function(_, value)
					C.db.profile.bars.micromenu.per_row = value
					BARS:GetBar("micromenu"):Update()
				end,
			},
			growth_dir = {
				order = 11,
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.bars.micromenu.x_growth.."_"..C.db.profile.bars.micromenu.y_growth
				end,
				set = function(_, value)
					C.db.profile.bars.micromenu.x_growth, C.db.profile.bars.micromenu.y_growth = s_split("_", value)
					BARS:GetBar("micromenu"):Update()
				end,
			},
			character = {
				order = 12,
				type = "group",
				name = CHARACTER_BUTTON,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
					tooltip = {
						order = 2,
						type = "toggle",
						name = L["ENHANCED_TOOLTIPS"],
						desc = L["CHARACTER_BUTTON_DESC"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):UpdateButtons("Update")
						end,
					},
				},
			},
			inventory = {
				order = 13,
				type = "group",
				name = L["INVENTORY_BUTTON"],
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
					tooltip = {
						order = 2,
						type = "toggle",
						name = L["ENHANCED_TOOLTIPS"],
						desc = L["INVENTORY_BUTTON_DESC"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):UpdateButtons("Update")
						end,
					},
					bags = {
						order = 2,
						type = "toggle",
						name = L["BAG_SLOTS"],
						get = function()
							return C.db.profile.bars.micromenu.bags.enabled
						end,
						set = function(_, value)
							C.db.profile.bars.micromenu.bags.enabled = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
					currency = CURRENCY_TABLE,
				},
			},
			spellbook = {
				order = 14,
				type = "group",
				name = SPELLBOOK_ABILITIES_BUTTON,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
				},
			},
			talent = {
				order = 15,
				type = "group",
				name = TALENTS_BUTTON,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
				},
			},
			achievement = {
				order = 16,
				type = "group",
				name = ACHIEVEMENT_BUTTON,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
				},
			},
			quest = {
				order = 17,
				type = "group",
				name = QUESTLOG_BUTTON,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
					tooltip = {
						order = 2,
						type = "toggle",
						name = L["ENHANCED_TOOLTIPS"],
						desc = L["QUESTLOG_BUTTON_DESC"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):UpdateButtons("Update")
						end,
					},
				},
			},
			guild = {
				order = 18,
				type = "group",
				name = GUILD_AND_COMMUNITIES,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
				},
			},
			lfd = {
				order = 19,
				type = "group",
				name = DUNGEONS_BUTTON,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
					tooltip = {
						order = 2,
						type = "toggle",
						name = L["ENHANCED_TOOLTIPS"],
						desc = L["DUNGEONS_BUTTON_DESC"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):UpdateButtons("Update")
						end,
					},
				},
			},
			collection = {
				order = 20,
				type = "group",
				name = COLLECTIONS,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
				},
			},
			ej = {
				order = 21,
				type = "group",
				name = ADVENTURE_JOURNAL,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
					tooltip = {
						order = 2,
						type = "toggle",
						name = L["ENHANCED_TOOLTIPS"],
						desc = L["ADVENTURE_JOURNAL_DESC"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):UpdateButtons("Update")
						end,
					},
				},
			},
			store = {
				order = 22,
				type = "group",
				name = BLIZZARD_STORE,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
				},
			},
			main = {
				order = 23,
				type = "group",
				name = MAINMENU_BUTTON,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
					tooltip = {
						order = 2,
						type = "toggle",
						name = L["ENHANCED_TOOLTIPS"],
						desc = L["MAINMENU_BUTTON_DESC"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):UpdateButtons("Update")
						end,
					},
				},
			},
			help = {
				order = 24,
				type = "group",
				name = HELP_BUTTON,
				get = function(info)
					return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:GetBar("micromenu"):Update()
						end,
					},
				},
			},
			fading = getOptionsTable_Fading("micromenu", 30),
		},
	}

	C.options.args.bars.args.xpbar = {
		order = 13,
		type = "group",
		childGroups = "select",
		name = L["XP_BAR"],
		get = function(info)
			return C.db.profile.bars.xpbar[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.bars.xpbar[info[#info]] ~= value then
				C.db.profile.bars.xpbar[info[#info]] = value
				BARS:GetBar("xpbar"):Update()
			end
		end,
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
				min = 530, max = 1900, step = 2,
			},
			height = {
				order = 11,
				type = "range",
				name = L["HEIGHT"],
				disabled = function() return not BARS:HasXPBar() end,
				min = 8, max = 32, step = 4,
			},
			fading = getOptionsTable_Fading("xpbar", 20)
		},
	}
end
