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
local tostring = _G.tostring
local unpack = _G.unpack

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
	["LEFT_DOWN"] = L["LEFT_DOWN"],
	["LEFT_UP"] = L["LEFT_UP"],
	["RIGHT_DOWN"] = L["RIGHT_DOWN"],
	["RIGHT_UP"] = L["RIGHT_UP"],
}

local FLYOUT_DIRS = {
	["UP"] = L["UP"],
	["DOWN"] = L["DOWN"],
	["LEFT"] = L["LEFT"],
	["RIGHT"] = L["RIGHT"],
}

local INDICATORS = {
	["button"] = L["ICON"],
	["hotkey"] = L["KEYBIND_TEXT"],
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

local FORMATS = {
	["NUM"] = L["NUMERIC"],
	["NUM_PERC"] = L["NUMERIC_PERCENTAGE"]
}

local VISIBILITY = {
	[1] = L["ALWAYS_SHOW"],
	[2] = L["MOUSEOVER_SHOW"],
}

local MICRO_BARS = {
	["micromenu1"] = L["MAIN_BAR"],
	["micromenu2"] = L["ADDITIONAL_BAR"],
}

local CURRENCY_TABLE = {
	order = 10,
	type = "group",
	name = L["CURRENCY"],
	inline = true,
	get = function(info)
		return C.db.profile.bars.micromenu.buttons.inventory.currency[tonumber(info[#info])]
	end,
	set = function(info, value)
		C.db.profile.bars.micromenu.buttons.inventory.currency[tonumber(info[#info])] = value and value or nil
		BARS:UpdateButton("inventory", "Update")
	end,
	args = {}
}

local function updateCurrencyOptions()
	local options = C.options and C.options.args.bars and C.options.args.bars.args.micromenu.args.inventory.args.currency.args or CURRENCY_TABLE.args
	local listSize = GetCurrencyListSize()
	local name, isHeader, icon, link, id, _

	t_wipe(options)

	if listSize > 0 then
		for i = 1, listSize do
			name, isHeader, _, _, _, _, icon = GetCurrencyListInfo(i)
			if isHeader then
				options["header" .. i] = {
					order = i,
					type = "header",
					name = name,
				}
			else
				link = GetCurrencyListLink(i)
				if link then
					id = tonumber(link:match("currency:(%d+)") or "", nil)
					if id then
						options[tostring(id)] = {
							order = i,
							type = "toggle",
							name = name,
							image = icon,
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

local function isModuleDisabled()
	return not BARS:IsInit()
end

local function isXPBarDisabled()
	return not BARS:HasXPBar()
end

local function isXPBarDisabledOrRestricted()
	return BARS:IsRestricted() or not BARS:HasXPBar()
end

local function isModuleDisabledOrRestricted()
	return BARS:IsRestricted() or not BARS:IsInit()
end

local function isPetBattleBarDisabledOrRestricted()
	return BARS:IsRestricted() or not BARS:HasPetBattleBar()
end

local function getOptionsTable_Fading(order, barID)
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
		temp.disabled = isModuleDisabledOrRestricted
	elseif barID == "pet_battle" then
		temp.disabled = isPetBattleBarDisabledOrRestricted
	elseif barID == "micromenu" then
		temp.set = function(info, value)
			C.db.profile.bars[barID].fade[info[#info]] = value
			BARS:GetBar("micromenu1"):UpdateConfig()
			BARS:GetBar("micromenu1"):UpdateFading()
			BARS:GetBar("micromenu2"):UpdateConfig()
			BARS:GetBar("micromenu2"):UpdateFading()
		end
	elseif barID == "xpbar" then
		temp.disabled = isXPBarDisabledOrRestricted
	end

	return temp
end

local function getOptionsTable_Bar(barID, order, name)
	local temp = {
		order = order,
		type = "group",
		childGroups = "select",
		name = name,
		disabled = isModuleDisabled,
		get = function(info)
			return C.db.profile.bars[barID][info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.bars[barID][info[#info]] ~= value then
				C.db.profile.bars[barID][info[#info]] = value
				BARS:GetBar(barID):Update()
			end
		end,
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
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			visible = {
				order = 10,
				type = "toggle",
				name = L["SHOW"],
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
			},
			per_row = {
				order = 15,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 12, step = 1,
			},
			spacing = {
				order = 16,
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 2,
			},
			size = {
				order = 17,
				type = "range",
				name = L["SIZE"],
				min = 18, max = 64, step = 1,
			},
			growth_dir = {
				order = 18,
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.bars[barID].x_growth .. "_" .. C.db.profile.bars[barID].y_growth
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
				set = function(_, value)
					C.db.profile.bars[barID].flyout_dir = value
					BARS:GetBar(barID):UpdateConfig()
					BARS:GetBar(barID):UpdateButtonConfig()
				end,
			},
			spacer_2 = {
				order = 20,
				type = "description",
				name = " ",
			},
			hotkey = {
				order = 21,
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
							BARS:GetBar(barID):UpdateButtonConfig()
						end,
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
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
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
					flag = {
						order = 3,
						type = "select",
						name = L["FLAG"],
						values = FLAGS,
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
					flag = {
						order = 3,
						type = "select",
						name = L["FLAG"],
						values = FLAGS,
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
					return C.db.profile.bars[barID].cooldown.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.bars[barID].cooldown.text[info[#info]] ~= value then
						C.db.profile.bars[barID].cooldown.text[info[#info]] = value
						BARS:GetBar(barID):UpdateConfig()
						BARS:GetBar(barID):UpdateCooldownConfig()
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
					h_alignment = {
						order = 4,
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = H_ALIGNMENTS,
					},
					v_alignment = {
						order = 5,
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
			fading = getOptionsTable_Fading(60, barID),
		},
	}

	if barID == "bar1" then
		temp.args.reset.disabled = isModuleDisabledOrRestricted
		temp.args.visible.disabled = isModuleDisabledOrRestricted
		temp.args.num.disabled = isModuleDisabledOrRestricted
		temp.args.per_row.disabled = isModuleDisabledOrRestricted
		temp.args.spacing.disabled = isModuleDisabledOrRestricted
		temp.args.size.disabled = isModuleDisabledOrRestricted
		temp.args.growth_dir.disabled = isModuleDisabledOrRestricted
		temp.args.flyout_dir.disabled = isModuleDisabledOrRestricted
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
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
	elseif barID == "bar7" then
		temp.args.grid = nil
		temp.args.num.max = 10
		temp.args.per_row.max = 10
		temp.args.flyout_dir = nil
		temp.args.macro = nil
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
	elseif barID == "pet_battle" then
		temp.args.enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			disabled = function() return BARS:IsRestricted() end,
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
		}
		temp.args.reset.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.visible.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.grid = nil
		temp.args.num.max = 6
		temp.args.num.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.per_row.max = 6
		temp.args.per_row.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.spacing.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.size.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.growth_dir.disabled = isPetBattleBarDisabledOrRestricted
		temp.args.flyout_dir = nil
		temp.args.hotkey.disabled = function() return not BARS:HasPetBattleBar() end
		temp.args.macro = nil
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
		temp.args.cooldown = nil
		temp.args.spacer_6 = nil
	elseif barID == "extra" then
		temp.args.grid = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
		temp.args.spacer_2 = nil
		temp.args.macro = nil
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
	elseif barID == "zone" then
		temp.args.grid = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
		temp.args.spacer_2 = nil
		temp.args.hotkey = nil
		temp.args.spacer_3 = nil
		temp.args.macro = nil
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
	elseif barID == "vehicle" then
		temp.args.grid = nil
		temp.args.num = nil
		temp.args.per_row = nil
		temp.args.spacing = nil
		temp.args.growth_dir = nil
		temp.args.flyout_dir = nil
		temp.args.spacer_2 = nil
		temp.args.hotkey = nil
		temp.args.spacer_3 = nil
		temp.args.macro = nil
		temp.args.spacer_4 = nil
		temp.args.count = nil
		temp.args.spacer_5 = nil
		temp.args.cooldown = nil
		temp.args.spacer_6 = nil
	end

	return temp
end

function CONFIG.CreateActionBarsPanel(_, order)
	C.options.args.bars = {
		order = order,
		type = "group",
		name = L["ACTION_BARS"],
		childGroups = "tree",
		get = function(info)
			return C.db.profile.bars[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.bars[info[#info]] ~= value then
				C.db.profile.bars[info[#info]] = value
				BARS:UpdateBars("UpdateConfig")
				BARS:UpdateBars("UpdateButtonConfig")
			end
		end,
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
				end,
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
				end,
			},
			blizz_vehicle = {
				order = 3,
				type = "toggle",
				name = L["USE_BLIZZARD_VEHICLE_UI"],
				disabled = isModuleDisabledOrRestricted,
				set = function(_, value)
					C.db.profile.bars.blizz_vehicle = value

					if BARS:IsInit() then
						BARS:UpdateBlizzVehicle()
					end
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			lock = {
				order = 10,
				type = "toggle",
				name = L["LOCK_BUTTONS"],
				desc = L["LOCK_BUTTONS_DESC"],
				disabled = isModuleDisabled,
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
				disabled = isModuleDisabled,
			},
			click_on_down = {
				order = 12,
				type = "toggle",
				name = L["CAST_ON_KEY_DOWN"],
				desc = L["CAST_ON_KEY_DOWN_DESC"],
				disabled = isModuleDisabled,
				set = function(_, value)
					C.db.profile.bars.click_on_down = value
					BARS:UpdateBars("UpdateConfig")
					BARS:UpdateBars("UpdateButtonConfig")

					SetCVar("ActionButtonUseKeyDown", value and 1 or 0)
				end,
			},
			range_indicator = {
				order = 13,
				type = "select",
				name = L["OOR_INDICATOR"],
				values = INDICATORS,
				disabled = isModuleDisabled,
			},
			mana_indicator = {
				order = 14,
				type = "select",
				name = L["OOM_INDICATOR"],
				values = INDICATORS,
				disabled = isModuleDisabled,
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			desaturation = {
				order = 20,
				type = "group",
				name = L["DESATURATION"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.bars.desaturation[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.bars.desaturation[info[#info]] ~= value then
						C.db.profile.bars.desaturation[info[#info]] = value
						BARS:UpdateBars("UpdateConfig")
						BARS:UpdateBars("UpdateButtonConfig")
					end
				end,
				args = {
					cooldown = {
						order = 1,
						type = "toggle",
						name = L["ON_COOLDOWN"],
					},
					unusable = {
						order = 2,
						type = "toggle",
						name = L["UNUSABLE"],
					},
					mana = {
						order = 3,
						type = "toggle",
						name = L["OOM"],
					},
					range = {
						order = 4,
						type = "toggle",
						name = L["OOR"],
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			colors = {
				order = 30,
				type = "group",
				name = L["COLORS"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return unpack(C.db.profile.bars.colors[info[#info]])
				end,
				set = function(info, r, g, b)
					if r ~= nil then
						local color = C.db.profile.bars.colors[info[#info]]
						if color[1] ~= r or color[2] ~= g or color[3] ~= b then
							color[1], color[2], color[3] = r, g, b
							BARS:UpdateBars("UpdateConfig")
							BARS:UpdateBars("UpdateButtonConfig")
						end
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.bars.colors, C.db.profile.bars.colors)
							BARS:UpdateBars("UpdateConfig")
							BARS:UpdateBars("UpdateButtonConfig")
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					normal = {
						order = 10,
						type = "color",
						name = L["USABLE"],
					},
					unusable = {
						order = 11,
						type = "color",
						name = L["UNUSABLE"],
					},
					mana = {
						order = 12,
						type = "color",
						name = L["OOM"],
					},
					range = {
						order = 13,
						type = "color",
						name = L["OOR"],
					},
				},
			},
			spacer_4 = {
				order = 39,
				type = "description",
				name = " ",
			},
			cooldown = {
				order = 40,
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.bars.cooldown[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.bars.cooldown[info[#info]] ~= value then
						C.db.profile.bars.cooldown[info[#info]] = value
						BARS:UpdateBars("UpdateConfig")
						BARS:UpdateBars("UpdateCooldownConfig")
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.bars.cooldown, C.db.profile.bars.cooldown)
							BARS:UpdateBars("UpdateConfig")
							BARS:UpdateBars("UpdateCooldownConfig")
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
							if C.db.profile.bars.cooldown[info[#info]] ~= value then
								if value < info.option.softMin then
									value = info.option.min
								end

								C.db.profile.bars.cooldown[info[#info]] = value
								BARS:UpdateBars("UpdateConfig")
								BARS:UpdateBars("UpdateCooldownConfig")
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
							return unpack(C.db.profile.bars.cooldown.colors[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.bars.cooldown.colors[info[#info]]
								if color[1] ~= r or color[2] ~= g or color[3] ~= b then
									color[1], color[2], color[3] = r, g, b
									BARS:UpdateBars("UpdateConfig")
									BARS:UpdateBars("UpdateCooldownConfig")
								end
							end
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["ENABLE"],
								get = function()
									return C.db.profile.bars.cooldown.colors.enabled
								end,
								set = function(_, value)
									C.db.profile.bars.cooldown.colors.enabled = value
									BARS:UpdateBars("UpdateConfig")
									BARS:UpdateBars("UpdateCooldownConfig")
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
			action_bar_1 = getOptionsTable_Bar("bar1", 50, L["BAR_1"]),
			action_bar_2 = getOptionsTable_Bar("bar2", 60, L["BAR_2"]),
			action_bar_3 = getOptionsTable_Bar("bar3", 70, L["BAR_3"]),
			action_bar_4 = getOptionsTable_Bar("bar4", 80, L["BAR_4"]),
			action_bar_5 = getOptionsTable_Bar("bar5", 90, L["BAR_5"]),
			action_bar_6 = getOptionsTable_Bar("bar6", 100, L["PET_BAR"]),
			action_bar_7 = getOptionsTable_Bar("bar7", 110, L["STANCE_BAR"]),
			pet_battle = getOptionsTable_Bar("pet_battle", 120, L["PET_BATTLE_BAR"]),
			extra = getOptionsTable_Bar("extra", 130, L["EXTRA_ACTION_BUTTON"]),
			zone = getOptionsTable_Bar("zone", 140, L["ZONE_ABILITY_BUTTON"]),
			vehicle = getOptionsTable_Bar("vehicle", 150, L["VEHICLE_EXIT_BUTTON"]),
			micromenu = {
				order = 160,
				type = "group",
				name = L["MICRO_BUTTONS"],
				disabled = isModuleDisabled,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.bars.micromenu, C.db.profile.bars.micromenu, {currency = true, point = true})
							BARS:UpdateMicroMenu()
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					micromenu1 = {
						order = 10,
						type = "group",
						name = L["MAIN_BAR"],
						inline = true,
						args = {
							per_row = {
								order = 1,
								type = "range",
								name = L["PER_ROW"],
								min = 1, max = 13, step = 1,
								get = function()
									return C.db.profile.bars.micromenu.bars.micromenu1.per_row
								end,
								set = function(_, value)
									C.db.profile.bars.micromenu.bars.micromenu1.per_row = value
									BARS:GetBar("micromenu1"):Update()
								end,
							},
							growth_dir = {
								order = 2,
								type = "select",
								name = L["GROWTH_DIR"],
								values = GROWTH_DIRS,
								get = function()
									return C.db.profile.bars.micromenu.bars.micromenu1.x_growth .. "_" .. C.db.profile.bars.micromenu.bars.micromenu1.y_growth
								end,
								set = function(_, value)
									C.db.profile.bars.micromenu.bars.micromenu1.x_growth, C.db.profile.bars.micromenu.bars.micromenu1.y_growth = s_split("_", value)
									BARS:GetBar("micromenu1"):Update()
								end,
							},
						},
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					micromenu2 = {
						order = 20,
						type = "group",
						name = L["ADDITIONAL_BAR"],
						inline = true,
						args = {
							per_row = {
								order = 1,
								type = "range",
								name = L["PER_ROW"],
								min = 1, max = 13, step = 1,
								get = function()
									return C.db.profile.bars.micromenu.bars.micromenu2.per_row
								end,
								set = function(_, value)
									C.db.profile.bars.micromenu.bars.micromenu2.per_row = value
									BARS:GetBar("micromenu2"):Update()
								end,
							},
							growth_dir = {
								order = 2,
								type = "select",
								name = L["GROWTH_DIR"],
								values = GROWTH_DIRS,
								get = function()
									return C.db.profile.bars.micromenu.bars.micromenu2.x_growth .. "_" .. C.db.profile.bars.micromenu.bars.micromenu2.y_growth
								end,
								set = function(_, value)
									C.db.profile.bars.micromenu.bars.micromenu2.x_growth, C.db.profile.bars.micromenu.bars.micromenu2.y_growth = s_split("_", value)
									BARS:GetBar("micromenu2"):Update()
								end,
							},
						},
					},
					spacer_3 = {
						order = 29,
						type = "description",
						name = " ",
					},
					fading = getOptionsTable_Fading(30, "micromenu"),
					character = {
						order = 40,
						type = "group",
						name = CHARACTER_BUTTON,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							tooltip = {
								order = 2,
								type = "toggle",
								name = L["ENHANCED_TOOLTIPS"],
								desc = L["CHARACTER_BUTTON_DESC"],
							},
							parent = {
								order = 3,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					inventory = {
						order = 50,
						type = "group",
						name = L["INVENTORY_BUTTON"],
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							tooltip = {
								order = 2,
								type = "toggle",
								name = L["ENHANCED_TOOLTIPS"],
								desc = L["INVENTORY_BUTTON_DESC"],
							},
							bags = {
								order = 3,
								type = "toggle",
								name = L["BAG_SLOTS"],
								get = function()
									return C.db.profile.bars.micromenu.bars.bags.enabled
								end,
								set = function(_, value)
									C.db.profile.bars.micromenu.bars.bags.enabled = value
									BARS:UpdateMicroMenu()
								end,
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
							currency = CURRENCY_TABLE,
						},
					},
					spellbook = {
						order = 60,
						type = "group",
						name = SPELLBOOK_ABILITIES_BUTTON,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					talent = {
						order = 70,
						type = "group",
						name = TALENTS_BUTTON,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					achievement = {
						order = 80,
						type = "group",
						name = ACHIEVEMENT_BUTTON,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					quest = {
						order = 90,
						type = "group",
						name = QUESTLOG_BUTTON,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							tooltip = {
								order = 2,
								type = "toggle",
								name = L["ENHANCED_TOOLTIPS"],
								desc = L["QUESTLOG_BUTTON_DESC"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					guild = {
						order = 100,
						type = "group",
						name = GUILD_AND_COMMUNITIES,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					lfd = {
						order = 110,
						type = "group",
						name = DUNGEONS_BUTTON,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							tooltip = {
								order = 2,
								type = "toggle",
								name = L["ENHANCED_TOOLTIPS"],
								desc = L["DUNGEONS_BUTTON_DESC"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					collection = {
						order = 120,
						type = "group",
						name = COLLECTIONS,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					ej = {
						order = 130,
						type = "group",
						name = ADVENTURE_JOURNAL,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							tooltip = {
								order = 2,
								type = "toggle",
								name = L["ENHANCED_TOOLTIPS"],
								desc = L["ADVENTURE_JOURNAL_DESC"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					store = {
						order = 140,
						type = "group",
						name = BLIZZARD_STORE,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					main = {
						order = 150,
						type = "group",
						name = MAINMENU_BUTTON,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							tooltip = {
								order = 2,
								type = "toggle",
								name = L["ENHANCED_TOOLTIPS"],
								desc = L["MAINMENU_BUTTON_DESC"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
					help = {
						order = 160,
						type = "group",
						name = HELP_BUTTON,
						get = function(info)
							return C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
							BARS:UpdateButton(info[#info - 1], "Update")
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["SHOW"],
							},
							parent = {
								order = 4,
								type = "select",
								name = L["BAR"],
								values = MICRO_BARS,
								set = function(info, value)
									C.db.profile.bars.micromenu.buttons[info[#info - 1]][info[#info]] = value
									BARS:UpdateMicroMenu()
								end,
							},
						},
					},
				},
			},
			xpbar = {
				order = 170,
				type = "group",
				childGroups = "select",
				name = L["XP_BAR"],
				get = function(info)
					return C.db.profile.bars.xpbar[info[#info]]
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						disabled = isModuleDisabledOrRestricted,
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
						end,
					},
					reset = {
						type = "execute",
						order = 2,
						name = L["RESTORE_DEFAULTS"],
						disabled = isXPBarDisabledOrRestricted,
						func = function()
							CONFIG:CopySettings(D.profile.bars.xpbar, C.db.profile.bars.xpbar, {point = true})
							BARS:GetBar("xpbar"):Update()
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
						min = 530, max = 1900, step = 2,
						disabled = isXPBarDisabledOrRestricted,
						set = function(info, value)
							if C.db.profile.bars.xpbar[info[#info]] ~= value then
								C.db.profile.bars.xpbar[info[#info]] = value
								BARS:GetBar("xpbar"):UpdateConfig()
								BARS:GetBar("xpbar"):UpdateSize(value, C.db.profile.bars.xpbar.height)
							end
						end,
					},
					height = {
						order = 11,
						type = "range",
						name = L["HEIGHT"],
						min = 8, max = 32, step = 4,
						disabled = isXPBarDisabledOrRestricted,
						set = function(info, value)
							if C.db.profile.bars.xpbar[info[#info]] ~= value then
								C.db.profile.bars.xpbar[info[#info]] = value
								BARS:GetBar("xpbar"):UpdateConfig()
								BARS:GetBar("xpbar"):UpdateSize(C.db.profile.bars.xpbar.width, value)
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
						disabled = isXPBarDisabled,
						get = function(info)
							return C.db.profile.bars.xpbar.text[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.bars.xpbar.text[info[#info]] ~= value then
								C.db.profile.bars.xpbar.text[info[#info]] = value
								BARS:GetBar("xpbar"):UpdateConfig()
								BARS:GetBar("xpbar"):ForEach(
									"UpdateFont",
									C.db.profile.bars.xpbar.text.size,
									C.db.profile.bars.xpbar.text.flag)
								BARS:GetBar("xpbar"):ForEach("UpdateText")
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
							format = {
								order = 3,
								type = "select",
								name = L["FORMAT"],
								values = FORMATS,
								set = function(info, value)
									if C.db.profile.bars.xpbar.text[info[#info]] ~= value then
										C.db.profile.bars.xpbar.text[info[#info]] = value
										BARS:GetBar("xpbar"):UpdateConfig()
										BARS:GetBar("xpbar"):UpdateTextFormat(value)
										BARS:GetBar("xpbar"):ForEach("UpdateText")
									end
								end,
							},
							visibility = {
								order = 4,
								type = "select",
								name = L["VISIBILITY"],
								values = VISIBILITY,
								set = function(info, value)
									if C.db.profile.bars.xpbar.text[info[#info]] ~= value then
										C.db.profile.bars.xpbar.text[info[#info]] = value
										BARS:GetBar("xpbar"):UpdateConfig()
										BARS:GetBar("xpbar"):ForEach("LockText", value == 1)
									end
								end,
							},
						},
					},
					spacer_3 = {
						order = 29,
						type = "description",
						name = " ",
					},
					fading = getOptionsTable_Fading(30, "xpbar")
				},
			},
		},
	}
end
