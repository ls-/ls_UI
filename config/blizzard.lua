local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local BLIZZARD = P:GetModule("Blizzard")
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)

-- Mine
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

function CONFIG.CreateBlizzardPanel(_, order)
	C.options.args.blizzard = {
		order = order,
		type = "group",
		name = L["BLIZZARD"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.blizzard.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.enabled = value

					if not BLIZZARD:IsInit() then
						if value then
							BLIZZARD:Init()
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
			command_bar = {
				order = 10,
				type = "toggle",
				name = L["COMMAND_BAR"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.command_bar.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.command_bar.enabled = value

					if not BLIZZARD:HasCommandBar() then
						if value then
							BLIZZARD:SetUpCommandBar()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			digsite_bar = {
				order = 11,
				type = "toggle",
				name = L["DIGSITE_BAR"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.digsite_bar.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.digsite_bar.enabled = value

					if not BLIZZARD:HasDigsiteBar() then
						if value then
							BLIZZARD:SetUpDigsiteBar()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			durability = {
				order = 12,
				type = "toggle",
				name = L["DURABILITY_FRAME"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.durability.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.durability.enabled = value

					if not BLIZZARD:HasDurabilityFrame() then
						if value then
							BLIZZARD:SetUpDurabilityFrame()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			gm = {
				order = 13,
				type = "toggle",
				name = L["GM_FRAME"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.gm.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.gm.enabled = value

					if not BLIZZARD:HasGMFrame() then
						if value then
							BLIZZARD:SetUpGMFrame()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			npe = {
				order = 14,
				type = "toggle",
				name = L["NPE_FRAME"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.npe.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.npe.enabled = value

					if not BLIZZARD:HasGMFrame() then
						if value then
							BLIZZARD:SetUpGMFrame()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			player_alt_power_bar = {
				order = 15,
				type = "toggle",
				name = L["ALT_POWER_BAR"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.player_alt_power_bar.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.player_alt_power_bar.enabled = value

					if not BLIZZARD:HasAltPowerBar() then
						if value then
							BLIZZARD:SetUpAltPowerBar()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			talking_head = {
				order = 16,
				type = "toggle",
				name = L["TALKING_HEAD_FRAME"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.talking_head.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.talking_head.enabled = value

					if not BLIZZARD:HasTalkingHead() then
						if value then
							BLIZZARD:SetUpTalkingHead()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			timer = {
				order = 17,
				type = "toggle",
				name = L["MIRROR_TIMER"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.timer.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.timer.enabled = value

					if not BLIZZARD:HasMirrorTimer() then
						if value then
							BLIZZARD:SetUpMirrorTimer()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			vehicle = {
				order = 18,
				type = "toggle",
				name = L["VEHICLE_SEAT_INDICATOR"],
				disabled = function() return not BLIZZARD:IsInit() end,
				get = function()
					return C.db.char.blizzard.vehicle.enabled
				end,
				set = function(_, value)
					C.db.char.blizzard.vehicle.enabled = value

					if not BLIZZARD:HasVehicleSeatFrame() then
						if value then
							BLIZZARD:SetUpVehicleSeatFrame()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end
			},
			objective_tracker = {
				type = "group",
				name = L["OBJECTIVE_TRACKER"],
				guiInline = true,
				disabled = function() return not BLIZZARD:IsInit() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return C.db.char.blizzard.objective_tracker.enabled
						end,
						set = function(_, value)
							C.db.char.blizzard.objective_tracker.enabled = value

							if not BLIZZARD:HasObjectiveTracker() then
								if value then
									BLIZZARD:SetUpObjectiveTracker()
								end
							else
								if not value then
									CONFIG:ShowStaticPopup("RELOAD_UI")
								end
							end
						end
					},
					height = {
						order = 2,
						type = "range",
						name = L["HEIGHT"],
						disabled = function() return not BLIZZARD:HasObjectiveTracker() end,
						min = 400, max = 1000, step = 2,
						get = function()
							return C.db.profile.blizzard.objective_tracker.height
						end,
						set = function(_, value)
							C.db.profile.blizzard.objective_tracker.height = value
							BLIZZARD:UpdateObjectiveTracker()
						end,
					},
					drag_key = {
						order = 3,
						type = "select",
						name = L["DRAG_KEY"],
						values = DRAG_KEYS,
						get = function()
							return DRAG_KEY_INDICES[C.db.profile.blizzard.objective_tracker.drag_key]
						end,
						set = function(_, value)
							C.db.profile.blizzard.objective_tracker.drag_key = DRAG_KEY_VALUES[value]
						end,
					},
				},
			},
		},
	}
end
