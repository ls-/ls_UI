-- Lua
local _G = getfenv(0)
local s_split = _G.string.split
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
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

local function isModuleDisabled()
	return not BARS:IsInit()
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
					BARS:For("micromenu", "UpdateButtonList")
					BARS:For("micromenu", "UpdateLayout")
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
	return {
		order = order,
		type = "group",
		name = L["MICRO_BUTTONS"],
		disabled = isModuleDisabled,
		args = {
			reset = {
				type = "execute",
				order = reset(1),
				name = L["RESET_TO_DEFAULT"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.bars.micromenu, C.db.profile.bars.micromenu, {point = true})

					BARS:UpdateMicroMenu()
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			restricted = {
				order = inc(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["USE_BLIZZARD_MICRO_MENU"]),
				get = function()
					return PrC.db.profile.bars.micromenu.blizz_enabled
				end,
				set = function(_, value)
					PrC.db.profile.bars.micromenu.blizz_enabled = value

					if BARS:IsInit() then
						CONFIG:AskToReloadUI("micromenu.blizz_enabled")
					end
				end,
			},
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			per_row = {
				order = inc(1),
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 12, step = 1,
				get = function()
					return C.db.profile.bars.micromenu.per_row
				end,
				set = function(_, value)
					C.db.profile.bars.micromenu.per_row = value

					BARS:For("micromenu", "UpdateConfig")
					BARS:For("micromenu", "UpdateLayout")
				end,
			},
			growth_dir = {
				order = inc(1),
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				get = function()
					return C.db.profile.bars.micromenu.x_growth .. "_" .. C.db.profile.bars.micromenu.y_growth
				end,
				set = function(_, value)
					C.db.profile.bars.micromenu.x_growth, C.db.profile.bars.micromenu.y_growth = s_split("_", value)

					BARS:For("micromenu", "UpdateConfig")
					BARS:For("micromenu", "UpdateLayout")
				end,
			},
			helptips = {
				order = inc(1),
				type = "toggle",
				name = L["NOTIFICATIONS"],
				get = function()
					return C.db.profile.bars.micromenu.helptips
				end,
				set = function(_, value)
					C.db.profile.bars.micromenu.helptips = value

					if not value then
						BARS:HideHelpTips()
					end
				end,
			},
			spacer_3 = CONFIG:CreateSpacer(inc(1)),
			fading = CONFIG:CreateBarFadingOptions(inc(1), "micromenu"),
			character = getMicroButtonOptions(inc(1), "character", CHARACTER_BUTTON),
			spellbook = getMicroButtonOptions(inc(1), "spellbook", PROFESSIONS_BUTTON),
			talent = getMicroButtonOptions(inc(1), "talent", PLAYERSPELLS_BUTTON),
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
