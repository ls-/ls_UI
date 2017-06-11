local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CFG = P:GetModule("Config")
local MINIMAP = P:GetModule("Minimap")

-- Lua
local _G = getfenv(0)

-- Mine
local ZONE_TEXT_MODES = {
	[0] = L["HIDE"],
	[1] = L["MOUSEOVER_SHOW"],
	[2] = L["ALWAYS_SHOW"],
}

function CFG:CreateMinimapPanel(order)
	C.options.args.minimap = {
		order = order,
		type = "group",
		name = L["MINIMAP"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.minimap.enabled
				end,
				set = function(_, value)
					C.db.char.minimap.enabled = value

					if not MINIMAP:IsInit() then
						if value then
							MINIMAP:Init()
						end
					else
						if not value then
							CFG:ShowStaticPopup("RELOAD_UI")
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
			zone_text = {
				order = 10,
				type = "select",
				name = L["ZONE_TEXT"],
				disabled = function() return not MINIMAP:IsInit() end,
				values = ZONE_TEXT_MODES,
				get = function()
					return C.db.profile.minimap[E.UI_LAYOUT].zone_text.mode
				end,
				set = function(_, value)
					C.db.profile.minimap[E.UI_LAYOUT].zone_text.mode = value
					MINIMAP:Update()
				end,
			},
		},
	}
end
