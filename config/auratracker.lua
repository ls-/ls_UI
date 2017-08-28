local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local AURATRACKER = P:GetModule("AuraTracker")
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)
local s_split = _G.string.split

-- Mine
local GROWTH_DIRS = {
	LEFT_DOWN = L["LEFT_DOWN"],
	LEFT_UP = L["LEFT_UP"],
	RIGHT_DOWN = L["RIGHT_DOWN"],
	RIGHT_UP = L["RIGHT_UP"],
}

local DRAG_KEYS = {
	[1] = _G.ALT_KEY,
	[2] = _G.CTRL_KEY,
	[3] = _G.SHIFT_KEY,
	[4] = _G.NONE_KEY,
}

local DRAG_KEY_VALUES = {
	[1] = "ALT",
	[2] = "CTRL",
	[3] = "SHIFT",
	[4] = "NONE",
}

local DRAG_KEY_INDICES = {
	ALT = 1,
	CTRL = 2,
	SHIFT = 3,
	NONE = 4,
}

local function Update()
	AURATRACKER:Update()
end

function CONFIG.CreateAuraTrackerPanel(_, order)
	C.options.args.auratracker = {
		order = order,
		type = "group",
		name = L["AURA_TRACKER"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.auratracker.enabled
				end,
				set = function(_, value)
					C.db.char.auratracker.enabled = value

					if AURATRACKER:IsInit() then
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if value then
							AURATRACKER:Init()
						end
					end
				end
			},
			locked = {
				order = 2,
				type = "toggle",
				name = L["LOCK"],
				disabled = function() return not AURATRACKER:IsInit() end,
				get = function()
					return C.db.char.auratracker.locked
				end,
				set = function(_, value)
					C.db.char.auratracker.locked = value
					AURATRACKER:Update()
				end
			},
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				disabled = function() return not AURATRACKER:IsInit() end,
				func = function()
					CONFIG:CopySettings(D.char.auratracker, C.db.char.auratracker, {enabled = true, filter = true})
					AURATRACKER:Update()
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
				disabled = function() return not AURATRACKER:IsInit() end,
				get = function()
					return C.db.char.auratracker.num
				end,
				set = function(_, value)
					C.db.char.auratracker.num = value
					AURATRACKER:Update()
				end,
			},
			per_row = {
				order = 11,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 12, step = 1,
				disabled = function() return not AURATRACKER:IsInit() end,
				get = function()
					return C.db.char.auratracker.per_row
				end,
				set = function(_, value)
					C.db.char.auratracker.per_row = value
					AURATRACKER:Update()
				end,
			},
			spacing = {
				order = 12,
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 2,
				disabled = function() return not AURATRACKER:IsInit() end,
				get = function()
					return C.db.char.auratracker.spacing
				end,
				set = function(_, value)
					C.db.char.auratracker.spacing = value
					AURATRACKER:Update()
				end,
			},
			size = {
				order = 13,
				type = "range",
				name = L["SIZE"],
				min = 18, max = 64, step = 1,
				disabled = function() return not AURATRACKER:IsInit() end,
				get = function()
					return C.db.char.auratracker.size
				end,
				set = function(_, value)
					C.db.char.auratracker.size = value
					AURATRACKER:Update()
				end,
			},
			growth_dir = {
				order = 14,
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				disabled = function() return not AURATRACKER:IsInit() end,
				get = function()
					return C.db.char.auratracker.x_growth.."_"..C.db.char.auratracker.y_growth
				end,
				set = function(_, value)
					C.db.char.auratracker.x_growth, C.db.char.auratracker.y_growth = s_split("_", value)
					AURATRACKER:Update()
				end,
			},
			drag_key = {
					order = 15,
					type = "select",
					name = L["DRAG_KEY"],
					values = DRAG_KEYS,
					disabled = function() return not AURATRACKER:IsInit() end,
					get = function()
						return DRAG_KEY_INDICES[C.db.char.auratracker.drag_key]
					end,
					set = function(_, value)
						C.db.char.auratracker.drag_key = DRAG_KEY_VALUES[value]
					end,
				},
			spacer2 = {
				order = 19,
				type = "description",
				name = "",
			},
			settings = {
				type = "execute",
				order = 20,
				name = L["FILTER_SETTINGS"],
				disabled = function() return not AURATRACKER:IsInit() end,
				func = function()
					CONFIG:OpenAuraConfig(L["AURA_TRACKER"], C.db.char.auratracker.filter, {1, 2}, {3}, Update)
				end,
			},
		},
	}
end
