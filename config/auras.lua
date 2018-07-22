local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local AURAS = P:GetModule("Auras")
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)
local s_split = _G.string.split

-- Mine
local function GetOptionsTable_Aura(filter, order, name)
	local temp = {
		order = order,
		type = "group",
		name = name,
		disabled = function() return not AURAS:IsInit() end,
		get = function(info)
			return C.db.profile.auras[filter][info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.auras[filter][info[#info]] ~= value then
				C.db.profile.auras[filter][info[#info]] = value
				AURAS:UpdateHeader(filter)
			end
		end,
		args = {
			reset = {
				type = "execute",
				order = 1,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.auras[filter], C.db.profile.auras[filter], {point = true})
					AURAS:UpdateHeader(filter)
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
			},
			num_rows = {
				order = 10,
				type = "range",
				name = L["ROWS"],
				min = 1, max = 40, step = 1,
			},
			per_row = {
				order = 11,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 40, step = 1,
			},
			spacing = {
				order = 12,
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 2,
			},
			size = {
				order = 13,
				type = "range",
				name = L["SIZE"],
				min = 24, max = 64, step = 1,
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
					return C.db.profile.auras[filter].x_growth .. "_" .. C.db.profile.auras[filter].y_growth
				end,
				set = function(_, value)
					C.db.profile.auras[filter].x_growth, C.db.profile.auras[filter].y_growth = s_split("_", value)
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
			},
			sort_dir = {
				order = 16,
				type = "select",
				name = L["SORT_DIR"],
				values = {
					["+"] = L["ASCENDING"],
					["-"] = L["DESCENDING"],
				},
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
			},
		},
	}

	if filter == "TOTEM" then
		temp.args.num_rows = nil
		temp.args.sep_own = nil
		temp.args.sort_dir = nil
		temp.args.sort_method = nil

		temp.args.num = {
			order = 10,
			type = "range",
			name = L["NUM_BUTTONS"],
			min = 1, max = 4, step = 1,
		}
	end

	return temp
end

function CONFIG.CreateAurasPanel(_, order)
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
							CONFIG:ShowStaticPopup("RELOAD_UI")
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
					CONFIG:CopySettings(D.profile.auras, C.db.profile.auras, {point = true})
					AURAS:Update()
				end,
			},
			buffs = GetOptionsTable_Aura("HELPFUL", 10, L["BUFFS"]),
			debuffs = GetOptionsTable_Aura("HARMFUL", 11, L["DEBUFFS"]),
			totems = GetOptionsTable_Aura("TOTEM", 12, L["TOTEMS"]),
		},
	}
end
