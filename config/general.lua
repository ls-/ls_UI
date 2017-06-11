local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CFG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)

-- Mine
local ui_layouts = {
	ls = L["ORBS"],
	traditional = L["CLASSIC"]
}

function CFG:CreateGeneralPanel(order)
	C.options.args.general = {
		order = order,
		type = "group",
		name = L["GENERAL"],
		args = {
			layout = {
				order = 1,
				type = "select",
				name = L["UI_LAYOUT"],
				desc = L["UI_LAYOUT_DESC"],
				values = ui_layouts,
				get = function()
					return C.db.char.layout
				end,
				set = function(_, value)
					C.db.char.layout = value

					if E.UI_LAYOUT ~= value then
						CFG:ShowStaticPopup("RELOAD_UI")
					end
				end,
			},
		},
	}
end
