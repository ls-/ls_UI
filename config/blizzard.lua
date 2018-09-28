local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local BLIZZARD = P:GetModule("Blizzard")
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

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
	["ALT"] = 1,
	["CTRL"] = 2,
	["SHIFT"] = 3,
	["NONE"] = 4,
}

local CASTBAR_ICON_POSITIONS = {
	["LEFT"] = L["LEFT"],
	["RIGHT"] = L["RIGHT"],
}

local SHOW_PET_OPTIONS = {
	[-1] = L["AUTO"],
	[ 0] = L["HIDE"],
	[ 1] = L["SHOW"],
}

local FLAGS = {
	-- [""] = L["NONE"],
	["_Outline"] = L["OUTLINE"],
	["_Shadow"] = L["SHADOW"],
}

local function isModuleDisabled()
	return not BLIZZARD:IsInit()
end

function CONFIG.CreateBlizzardPanel(_, order)
	C.options.args.blizzard = {
		order = order,
		type = "group",
		name = L["BLIZZARD"],
		childGroups = "tab",
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
				name = " ",
				width = "full",
			},
			command_bar = {
				order = 10,
				type = "toggle",
				name = L["COMMAND_BAR"],
				disabled = isModuleDisabled,
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
			durability = {
				order = 11,
				type = "toggle",
				name = L["DURABILITY_FRAME"],
				disabled = isModuleDisabled,
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
				order = 12,
				type = "toggle",
				name = L["GM_FRAME"],
				disabled = isModuleDisabled,
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
				order = 13,
				type = "toggle",
				name = L["NPE_FRAME"],
				disabled = isModuleDisabled,
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
				order = 14,
				type = "toggle",
				name = L["ALT_POWER_BAR"],
				disabled = isModuleDisabled,
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
				order = 15,
				type = "toggle",
				name = L["TALKING_HEAD_FRAME"],
				disabled = isModuleDisabled,
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
			vehicle = {
				order = 16,
				type = "toggle",
				name = L["VEHICLE_SEAT_INDICATOR"],
				disabled = isModuleDisabled,
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
			castbar = {
				order = 17,
				type = "group",
				name = L["CASTBAR"],
				disabled = function()
					return not BLIZZARD:IsInit() or P:GetModule("UnitFrames"):HasPlayerFrame()
				end,
				get = function(info)
					return C.db.profile.blizzard[info[#info - 1]][info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.blizzard[info[#info - 1]][info[#info]] ~= value then
						C.db.profile.blizzard[info[#info - 1]][info[#info]] = value
						BLIZZARD:UpdateCastBars()
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return C.db.char.blizzard.castbar.enabled
						end,
						set = function(_, value)
							C.db.char.blizzard.castbar.enabled = value

							if not BLIZZARD:HasCastBars() then
								if value then
									BLIZZARD:SetUpCastBars()
								end
							else
								if not value then
									CONFIG:ShowStaticPopup("RELOAD_UI")
								end
							end
						end
					},
					show_pet = {
						order = 2,
						type = "select",
						name = L["PET_CAST_BAR"],
						values = SHOW_PET_OPTIONS,
					},
					reset = {
						type = "execute",
						order = 3,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.blizzard.castbar, C.db.profile.blizzard.castbar)
							BLIZZARD:UpdateCastBars()
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					width = {
						order = 11,
						type = "range",
						name = L["WIDTH"],
						min = 96, max = 1024, step = 2,
					},
					height = {
						order = 12,
						type = "range",
						name = L["HEIGHT"],
						min = 8, max = 32, step = 4,
					},
					latency = {
						order = 14,
						type = "toggle",
						name = L["LATENCY"],
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					icon = {
						order = 20,
						type = "group",
						name = L["ICON"],
						inline = true,
						get = function(info)
							return C.db.profile.blizzard.castbar[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.blizzard.castbar[info[#info - 1]][info[#info]] = value
							BLIZZARD:UpdateCastBars()
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["ENABLE"],
							},
							position = {
								order = 2,
								type = "select",
								name = L["POSITION"],
								values = CASTBAR_ICON_POSITIONS,
							},
						},
					},
					spacer_3 = {
						order = 29,
						type = "description",
						name = " ",
					},
					text = {
						order = 30,
						type = "group",
						name = L["TEXT"],
						inline = true,
						get = function(info)
							return C.db.profile.blizzard.castbar[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.blizzard.castbar[info[#info - 1]][info[#info]] = value
							BLIZZARD:UpdateCastBars()
						end,
						args = {
							size = {
								order = 1,
								type = "range",
								name = L["SIZE"],
								min = 10, max = 20, step = 2,
							},
							flag = {
								order = 2,
								type = "select",
								name = L["FLAG"],
								values = FLAGS,
							},
						},
					},
					spacer_4 = {
						order = 39,
						type = "description",
						name = " ",
					},
					colors = {
						order = 40,
						type = "group",
						name = L["COLORS"],
						inline = true,
						get = function(info)
							return unpack(C.db.profile.blizzard.castbar.colors[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.profile.blizzard.castbar.colors[info[#info]]
								if color[1] ~= r or color[2] ~= g or color[3] ~= b then
									color[1], color[2], color[3] = r, g, b
									BLIZZARD:UpdateCastBars()
								end
							end
						end,
						args = {
							reset = {
								type = "execute",
								order = 1,
								name = L["RESTORE_DEFAULTS"],
								func = function()
									CONFIG:CopySettings(D.profile.blizzard.castbar.colors, C.db.profile.blizzard.castbar.colors)
									BLIZZARD:UpdateCastBars()
								end,
							},
							spacer_1 = {
								order = 9,
								type = "description",
								name = " ",
							},
							casting = {
								order = 10,
								type = "color",
								name = L["SPELL_CAST"],
							},
							channeling = {
								order = 11,
								type = "color",
								name = L["SPELL_CHANNELED"],
							},
							failed = {
								order = 12,
								type = "color",
								name = L["SPELL_FAILED"],
							},
							notinterruptible = {
								order = 13,
								type = "color",
								name = L["SPELL_UNINTERRUPTIBLE"],
							},
						},
					},
				},
			},
			digsite_bar = {
				order = 18,
				type = "group",
				name = L["DIGSITE_BAR"],
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.blizzard[info[#info - 1]][info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.blizzard[info[#info - 1]][info[#info]] ~= value then
						C.db.profile.blizzard[info[#info - 1]][info[#info]] = value
						BLIZZARD:UpdateDigsiteBar()
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
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
					reset = {
						type = "execute",
						order = 2,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.blizzard.digsite_bar, C.db.profile.blizzard.digsite_bar)
							BLIZZARD:UpdateDigsiteBar()
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					width = {
						order = 11,
						type = "range",
						name = L["WIDTH"],
						min = 128, max = 1024, step = 2,
					},
					height = {
						order = 12,
						type = "range",
						name = L["HEIGHT"],
						min = 8, max = 32, step = 4,
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					text = {
						order = 20,
						type = "group",
						name = L["TEXT"],
						inline = true,
						get = function(info)
							return C.db.profile.blizzard.digsite_bar[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.blizzard.digsite_bar[info[#info - 1]][info[#info]] = value
							BLIZZARD:UpdateDigsiteBar()
						end,
						args = {
							size = {
								order = 1,
								type = "range",
								name = L["SIZE"],
								min = 10, max = 20, step = 2,
							},
							flag = {
								order = 2,
								type = "select",
								name = L["FLAG"],
								values = FLAGS,
							},
						},
					},
				},
			},
			timer = {
				order = 19,
				type = "group",
				name = L["MIRROR_TIMER"],
				desc = L["MIRROR_TIMER_DESC"],
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.blizzard[info[#info - 1]][info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.blizzard[info[#info - 1]][info[#info]] ~= value then
						C.db.profile.blizzard[info[#info - 1]][info[#info]] = value
						BLIZZARD:UpdateMirrorTimers()
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return C.db.char.blizzard.timer.enabled
						end,
						set = function(_, value)
							C.db.char.blizzard.timer.enabled = value

							if not BLIZZARD:HasMirrorTimer() then
								if value then
									BLIZZARD:SetUpMirrorTimers()
								end
							else
								if not value then
									CONFIG:ShowStaticPopup("RELOAD_UI")
								end
							end
						end
					},
					reset = {
						type = "execute",
						order = 2,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.blizzard.timer, C.db.profile.blizzard.timer)
							BLIZZARD:UpdateMirrorTimers()
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					width = {
						order = 11,
						type = "range",
						name = L["WIDTH"],
						min = 128, max = 1024, step = 2,
					},
					height = {
						order = 12,
						type = "range",
						name = L["HEIGHT"],
						min = 8, max = 32, step = 4,
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					text = {
						order = 20,
						type = "group",
						name = L["TEXT"],
						inline = true,
						get = function(info)
							return C.db.profile.blizzard.timer[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							C.db.profile.blizzard.timer[info[#info - 1]][info[#info]] = value
							BLIZZARD:UpdateMirrorTimers()
						end,
						args = {
							size = {
								order = 1,
								type = "range",
								name = L["SIZE"],
								min = 10, max = 20, step = 2,
							},
							flag = {
								order = 2,
								type = "select",
								name = L["FLAG"],
								values = FLAGS,
							},
						},
					},
				},
			},
			objective_tracker = {
				order = 20,
				type = "group",
				name = L["OBJECTIVE_TRACKER"],
				disabled = isModuleDisabled,
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
					reset = {
						type = "execute",
						order = 2,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.profile.blizzard.objective_tracker, C.db.profile.blizzard.objective_tracker)
							BLIZZARD:UpdateObjectiveTracker()
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					height = {
						order = 10,
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
						order = 11,
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
