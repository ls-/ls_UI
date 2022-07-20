local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local s_split = _G.string.split
local unpack = _G.unpack
local tonumber = _G.tonumber
local t_wipe = _G.table.wipe

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
local BARS = P:GetModule("Bars")

local orders = {}

local function reset(order, v)
	orders[order] = v or 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local GROWTH_DIRS = {
	["LEFT_DOWN"] = L["LEFT_DOWN"],
	["LEFT_UP"] = L["LEFT_UP"],
	["RIGHT_DOWN"] = L["RIGHT_DOWN"],
	["RIGHT_UP"] = L["RIGHT_UP"],
}

local currencyOptionTables = {}

local function updateCurrencyOptions()
	local options = CONFIG.options.args.bars.args.micromenu.args.inventory.args.currency.args
	local listSize = C_CurrencyInfo.GetCurrencyListSize()
	local info, id, link

	t_wipe(options)

	if listSize > 0 then
		for i = 1, listSize do
			info = C_CurrencyInfo.GetCurrencyListInfo(i)
			if info.isHeader then
				id = info.name:gsub("%s", ""):lower()
				if not currencyOptionTables[id] then
					currencyOptionTables[id] = {
						type = "header",
						name = info.name,
					}
				end
			else
				link = C_CurrencyInfo.GetCurrencyListLink(i)
				if link then
					id = link:match("currency:(%d+)")
					if id then
						if not currencyOptionTables[id] then
							currencyOptionTables[id] = {
								type = "toggle",
								name = info.name,
								image = info.iconFileID,
							}
						end
					end
				end
			end

			if id then
				currencyOptionTables[id].order = i

				options[id] = currencyOptionTables[id]
			end
		end
	else
		if not currencyOptionTables.error then
			currencyOptionTables.error = {
				order = 1,
				type = "description",
				name = L["NOTHING_TO_SHOW"],
			}
		end

		options.error = currencyOptionTables.error
	end
end

local function isModuleDisabled()
	return not BARS:IsInit()
end

local function getMicroButtonAnchorToggle(order, id, name)
	return {
		order = order,
		type = "toggle",
		name = name,
		get = function(info)
			return C.db.profile.bars.micromenu.buttons[id].parent == info[#info - 1]
		end,
		set = function(info)
			C.db.profile.bars.micromenu.buttons[id].parent = info[#info - 1]

			BARS:ForMicroButton(id, "Update")
			BARS:ForBar("micromenu1", "UpdateButtonList")
			BARS:ForBar("micromenu1", "UpdateLayout")
			BARS:ForBar("micromenu2", "UpdateButtonList")
			BARS:ForBar("micromenu2", "UpdateLayout")
		end,
	}
end

local function getMicroBarOptions(order, id, name)
	return {
		order = order,
		type = "group",
		name = name,
		inline = true,
		args = {
			character = getMicroButtonAnchorToggle(reset(2), "character", CHARACTER_BUTTON),
			inventory = getMicroButtonAnchorToggle(inc(2), "inventory", L["INVENTORY_BUTTON"]),
			spellbook = getMicroButtonAnchorToggle(inc(2), "spellbook", SPELLBOOK_ABILITIES_BUTTON),
			talent = getMicroButtonAnchorToggle(inc(2), "talent", TALENTS_BUTTON),
			achievement = getMicroButtonAnchorToggle(inc(2), "achievement", ACHIEVEMENT_BUTTON),
			quest = getMicroButtonAnchorToggle(inc(2), "quest", QUESTLOG_BUTTON),
			guild = getMicroButtonAnchorToggle(inc(2), "guild", GUILD_AND_COMMUNITIES),
			lfd = getMicroButtonAnchorToggle(inc(2), "lfd", DUNGEONS_BUTTON),
			collection = getMicroButtonAnchorToggle(inc(2), "collection", COLLECTIONS),
			ej = getMicroButtonAnchorToggle(inc(2), "ej", ADVENTURE_JOURNAL),
			store = getMicroButtonAnchorToggle(inc(2), "store", BLIZZARD_STORE),
			main = getMicroButtonAnchorToggle(inc(2), "main", MAINMENU_BUTTON),
			help = getMicroButtonAnchorToggle(inc(2), "help", HELP_BUTTON),
			spacer_1 = {
				order = inc(2),
				type = "description",
				name = " ",
			},
			per_row = {
				order = inc(2),
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 13, step = 1,
				get = function()
					return C.db.profile.bars.micromenu.bars[id].per_row
				end,
				set = function(_, value)
					C.db.profile.bars.micromenu.bars[id].per_row = value

					BARS:GetBar(id):UpdateConfig()
					BARS:GetBar(id):UpdateLayout()
				end,
			},
			growth_dir = {
				order = inc(2),
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.bars.micromenu.bars[id].x_growth .. "_" .. C.db.profile.bars.micromenu.bars[id].y_growth
				end,
				set = function(_, value)
					C.db.profile.bars.micromenu.bars[id].x_growth, C.db.profile.bars.micromenu.bars[id].y_growth = s_split("_", value)

					BARS:GetBar(id):UpdateConfig()
					BARS:GetBar(id):UpdateLayout()
				end,
			},
		},
	}
end

local function getMicroButtonOptions(order, id, name)
	local temp = {
		order = order,
		type = "group",
		name = name,
		get = function(info)
			return C.db.profile.bars.micromenu.buttons[id][info[#info]]
		end,
		set = function(info, value)
			C.db.profile.bars.micromenu.buttons[id][info[#info]] = value

			BARS:ForMicroButton(id, "Update")
		end,
		args = {
			enabled = {
				order = reset(2),
				type = "toggle",
				name = L["SHOW"],
				set = function(_, value)
					C.db.profile.bars.micromenu.buttons[id].enabled = value

					BARS:ForMicroButton(id, "Update")
					BARS:ForBar(C.db.profile.bars.micromenu.buttons[id].parent, "UpdateButtonList")
					BARS:ForBar(C.db.profile.bars.micromenu.buttons[id].parent, "UpdateLayout")
				end,
			},
		},
	}

	if id == "character" then
		temp.args.tooltip = {
			order = inc(2),
			type = "toggle",
			name = L["ENHANCED_TOOLTIPS"],
			desc = L["CHARACTER_BUTTON_DESC"],
		}
	elseif id == "inventory" then
		temp.args.tooltip = {
			order = inc(2),
			type = "toggle",
			name = L["ENHANCED_TOOLTIPS"],
			desc = L["INVENTORY_BUTTON_DESC"],
		}
		temp.args.bags = {
			order = inc(2),
			type = "toggle",
			name = L["BAG_SLOTS"],
			get = function()
				return C.db.profile.bars.micromenu.bars.bags.enabled
			end,
			set = function(_, value)
				C.db.profile.bars.micromenu.bars.bags.enabled = value

				BARS:ForMicroButton("inventory", "UpdateSlots")
			end,
		}
		temp.args.spacer_1 = {
			order = inc(2),
			type = "description",
			name = " ",
		}
		temp.args.currency = {
			order = inc(2),
			type = "group",
			name = L["CURRENCY"],
			inline = true,
			get = function(info)
				return C.db.profile.bars.micromenu.buttons.inventory.currency[tonumber(info[#info])]
			end,
			set = function(info, value)
				C.db.profile.bars.micromenu.buttons.inventory.currency[tonumber(info[#info])] = value and value or nil

				BARS:ForMicroButton("inventory", "Update")
			end,
			args = {},
		}
	elseif id == "quest" then
		temp.args.tooltip = {
			order = inc(2),
			type = "toggle",
			name = L["ENHANCED_TOOLTIPS"],
			desc = L["QUESTLOG_BUTTON_DESC"],
		}
	elseif id == "lfd" then
		temp.args.tooltip = {
			order = inc(2),
			type = "toggle",
			name = L["ENHANCED_TOOLTIPS"],
			desc = L["DUNGEONS_BUTTON_DESC"],
		}
	elseif id == "ej" then
		temp.args.tooltip = {
			order = inc(2),
			type = "toggle",
			name = L["ENHANCED_TOOLTIPS"],
			desc = L["ADVENTURE_JOURNAL_DESC"],
		}
	elseif id == "main" then
		temp.args.tooltip = {
			order = inc(2),
			type = "toggle",
			name = L["ENHANCED_TOOLTIPS"],
			desc = L["MAINMENU_BUTTON_DESC"],
		}
	end

	return temp
end

function CONFIG:CreateMicroMenuOptions(order)
	self:AddCallback(function()
		updateCurrencyOptions()

		E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateCurrencyOptions)
	end)

	return {
		order = order,
		type = "group",
		name = L["MICRO_BUTTONS"],
		disabled = isModuleDisabled,
		args = {
			reset = {
				type = "execute",
				order = reset(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.bars.micromenu, C.db.profile.bars.micromenu, {currency = true, point = true})
					BARS:UpdateMicroMenu()
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			micromenu1 = getMicroBarOptions(inc(1), "micromenu1", L["MAIN_BAR"]),
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			micromenu2 = getMicroBarOptions(inc(1), "micromenu2", L["ADDITIONAL_BAR"]),
			spacer_3 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			fading = CONFIG:CreateBarFadingOptions(inc(1), "micromenu"),
			character = getMicroButtonOptions(inc(1), "character", CHARACTER_BUTTON),
			inventory = getMicroButtonOptions(inc(1), "inventory", L["INVENTORY_BUTTON"]),
			spellbook = getMicroButtonOptions(inc(1), "spellbook", SPELLBOOK_ABILITIES_BUTTON),
			talent = getMicroButtonOptions(inc(1), "talent", TALENTS_BUTTON),
			achievement = getMicroButtonOptions(inc(1), "achievement", ACHIEVEMENT_BUTTON),
			quest = getMicroButtonOptions(inc(1), "quest", QUESTLOG_BUTTON),
			guild = getMicroButtonOptions(inc(1), "guild", GUILD_AND_COMMUNITIES),
			lfd = getMicroButtonOptions(inc(1), "lfd", DUNGEONS_BUTTON),
			collection = getMicroButtonOptions(inc(1), "collection", COLLECTIONS),
			ej = getMicroButtonOptions(inc(1), "ej", ADVENTURE_JOURNAL),
			store = getMicroButtonOptions(inc(1), "store", BLIZZARD_STORE),
			main = getMicroButtonOptions(inc(1), "main", MAINMENU_BUTTON),
			help = getMicroButtonOptions(inc(1), "help", HELP_BUTTON),
		},
	}
end
