local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local TOOLTIPS = P:GetModule("Tooltips")

-- Lua
local _G = getfenv(0)

function CONFIG.CreateTooltipsPanel(_, order)
	C.options.args.tooltips = {
		order = order,
		type = "group",
		name = L["TOOLTIPS"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.tooltips.enabled
				end,
				set = function(_, value)
					C.db.char.tooltips.enabled = value

					if not TOOLTIPS:IsInit() then
						if value then
							P:Call(TOOLTIPS.Init, TOOLTIPS)
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
				width = "full",
			},
			title = {
				order = 10,
				type = "toggle",
				name = L["PLAYER_TITLE"],
				get = function()
					return C.db.profile.tooltips.title
				end,
				set = function(_, value)
					C.db.profile.tooltips.title = value
				end
			},
			target = {
				order = 11,
				type = "toggle",
				name = L["TARGET_INFO"],
				desc = L["TARGET_INFO_DESC"],
				get = function()
					return C.db.profile.tooltips.target
				end,
				set = function(_, value)
					C.db.profile.tooltips.target = value
				end
			},
			inspect = {
				order = 12,
				type = "toggle",
				name = L["INSPECT_INFO"],
				desc = L["INSPECT_INFO_DESC"],
				get = function()
					return C.db.profile.tooltips.inspect
				end,
				set = function(_, value)
					C.db.profile.tooltips.inspect = value
					TOOLTIPS:Update()
				end
			},
			id = {
				order = 13,
				type = "toggle",
				name = L["TOOLTIP_IDS"],
				get = function()
					return C.db.profile.tooltips.id
				end,
				set = function(_, value)
					C.db.profile.tooltips.id = value
				end
			},
			count = {
				order = 14,
				type = "toggle",
				name = L["ITEM_COUNT"],
				desc = L["ITEM_COUNT_DESC"],
				get = function()
					return C.db.profile.tooltips.count
				end,
				set = function(_, value)
					C.db.profile.tooltips.count = value
				end
			},
			spacer_2 = {
				order = 20,
				type = "description",
				name = "",
				width = "full",
			},
			anchor_cursor = {
				order = 21,
				type = "toggle",
				name = L["ANCHOR_TO_CURSOR"],
				get = function()
					return C.db.profile.tooltips.anchor_cursor
				end,
				set = function(_, value)
					C.db.profile.tooltips.anchor_cursor = value
				end
			},
		},
	}
end
