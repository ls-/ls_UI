local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local LOOT = P:GetModule("Loot")

-- Lua
local _G = getfenv(0)

function CONFIG.CreateLootPanel(_, order)
	C.options.args.loot = {
		order = order,
		type = "group",
		name = L["LOOT"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return PrC.db.profile.loot.enabled
				end,
				set = function(_, value)
					PrC.db.profile.loot.enabled = value

					if not LOOT:IsInit() then
						if value then
							P:Call(LOOT.Init, LOOT)
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
		},
	}
end
