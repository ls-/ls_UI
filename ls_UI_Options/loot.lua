local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
local LOOT = P:GetModule("Loot")

function CONFIG.CreateLootPanel(_, order)
	CONFIG.options.args.loot = {
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
