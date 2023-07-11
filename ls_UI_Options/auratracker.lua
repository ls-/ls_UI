-- Lua
local _G = getfenv(0)
local s_split = _G.string.split
local unpack = _G.unpack

-- Libs
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
local AURATRACKER = P:GetModule("AuraTracker")

local orders = {}

local function reset(order)
	orders[order] = 1
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

local V_ALIGNMENTS = {
	["BOTTOM"] = "BOTTOM",
	["MIDDLE"] = "MIDDLE",
	["TOP"] = "TOP",
}

local function isModuleDisabled()
	return not AURATRACKER:IsInit()
end

local function callback()
	AURATRACKER:GetTracker():UpdateConfig()
	AURATRACKER:GetTracker():Update()

	if not InCombatLockdown() then
		AceConfigDialog:Open("ls_UI")
		AceConfigDialog:SelectGroup("ls_UI", "auratracker")
	end
end

function CONFIG:CreateAuraTrackerOptions(order)
	self.options.args.auratracker = {
		order = order,
		type = "group",
		name = L["AURA_TRACKER"],
		get = function(info)
			return PrC.db.profile.auratracker[info[#info]]
		end,
		set = function(info, value)
			if PrC.db.profile.auratracker[info[#info]] ~= value then
				PrC.db.profile.auratracker[info[#info]] = value
				AURATRACKER:GetTracker():UpdateConfig()
				AURATRACKER:GetTracker():UpdateLayout()
			end
		end,
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return PrC.db.profile.auratracker.enabled
				end,
				set = function(_, value)
					PrC.db.profile.auratracker.enabled = value

					if AURATRACKER:IsInit() then
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					else
						if value then
							P:Call(AURATRACKER.Init, AURATRACKER)
						end
					end
				end,
			},
			locked = {
				order = inc(1),
				type = "toggle",
				name = L["LOCK"],
				disabled = isModuleDisabled,
				set = function(info, value)
					if PrC.db.profile.auratracker[info[#info]] ~= value then
						PrC.db.profile.auratracker[info[#info]] = value

						AURATRACKER:GetTracker():UpdateConfig()
						AURATRACKER:GetTracker():UpdateLock()
					end
				end,
			},
			settings = {
				order = inc(1),
				type = "execute",
				name = L["FILTER_SETTINGS"],
				disabled = isModuleDisabled,
				func = function()
					AceConfigDialog:Close("ls_UI")
					GameTooltip:Hide()

					CONFIG:OpenAuraConfig(L["AURA_TRACKER"], nil, PrC.db.profile.auratracker.filter.HELPFUL, PrC.db.profile.auratracker.filter.HARMFUL, callback)
				end,
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				disabled = isModuleDisabled,
				func = function()
					CONFIG:CopySettings(PrD.profile.auratracker, PrC.db.profile.auratracker, {enabled = true, filter = true})

					AURATRACKER:Update()
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			num = {
				order = inc(1),
				type = "range",
				name = L["NUM_BUTTONS"],
				min = 1, max = 12, step = 1,
				disabled = isModuleDisabled,
			},
			per_row = {
				order = inc(1),
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 12, step = 1,
				disabled = isModuleDisabled,
			},
			spacing = {
				order = inc(1),
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 1,
				disabled = isModuleDisabled,
			},
			width = {
				order = inc(1),
				type = "range",
				name = L["WIDTH"],
				min = 16, max = 64, step = 1,
				disabled = isModuleDisabled,
			},
			height = {
				order = inc(1),
				type = "range",
				name = L["HEIGHT"],
				desc = L["HEIGHT_OVERRIDE_DESC"],
				min = 0, max = 64, step = 1,
				softMin = 16,
				disabled = isModuleDisabled,
				set = function(info, value)
					if PrC.db.profile.auratracker.height ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end
					end

					PrC.db.profile.auratracker.height = value

					AURATRACKER:GetTracker():UpdateConfig()
					AURATRACKER:GetTracker():UpdateLayout()
				end,
			},
			growth_dir = {
				order = inc(1),
				type = "select",
				name = L["GROWTH_DIR"],
				values = GROWTH_DIRS,
				disabled = isModuleDisabled,
				get = function()
					return PrC.db.profile.auratracker.x_growth .. "_" .. PrC.db.profile.auratracker.y_growth
				end,
				set = function(_, value)
					PrC.db.profile.auratracker.x_growth, PrC.db.profile.auratracker.y_growth = s_split("_", value)

					AURATRACKER:GetTracker():UpdateConfig()
					AURATRACKER:GetTracker():UpdateLayout()
				end,
			},
			drag_key = {
				order = inc(1),
				type = "select",
				name = L["DRAG_KEY"],
				values = DRAG_KEYS,
				disabled = isModuleDisabled,
				get = function()
					return DRAG_KEY_INDICES[PrC.db.profile.auratracker.drag_key]
				end,
				set = function(_, value)
					PrC.db.profile.auratracker.drag_key = DRAG_KEY_VALUES[value]
				end,
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			type = {
				order = inc(1),
				type = "group",
				name = L["AURA_TYPE"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return PrC.db.profile.auratracker.type[info[#info]]
				end,
				set = function(info, value)
					if PrC.db.profile.auratracker.type[info[#info]] ~= value then
						PrC.db.profile.auratracker.type[info[#info]] = value

						AURATRACKER:GetTracker():UpdateConfig()
						AURATRACKER:GetTracker():UpdateAuraTypeIcons()
					end
				end,
				args = {
					enabled = {
						order = reset(2),
						type = "toggle",
						name = L["SHOW"],
					},
					size = {
						order = inc(2),
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					position = {
						order = inc(2),
						type = "select",
						name = L["POINT"],
						values = CONFIG.POINTS,
					},
				},
			},
			spacer_3 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			count = {
				order = inc(1),
				type = "group",
				name = L["COUNT_TEXT"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return PrC.db.profile.auratracker.count[info[#info]]
				end,
				set = function(info, value)
					if PrC.db.profile.auratracker.count[info[#info]] ~= value then
						PrC.db.profile.auratracker.count[info[#info]] = value

						AURATRACKER:GetTracker():UpdateConfig()
						AURATRACKER:GetTracker():UpdateCountFont()
					end
				end,
				args = {
					size = {
						order = reset(2),
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					h_alignment = {
						order = inc(2),
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = CONFIG.H_ALIGNMENTS,
					},
					v_alignment = {
						order = inc(2),
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = CONFIG.V_ALIGNMENTS,
					},
				},
			},
			spacer_4 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			cooldown = {
				order = inc(1),
				type = "group",
				name = L["COOLDOWN"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return PrC.db.profile.auratracker.cooldown[info[#info]]
				end,
				set = function(info, value)
					if PrC.db.profile.auratracker.cooldown[info[#info]] ~= value then
						PrC.db.profile.auratracker.cooldown[info[#info]] = value

						AURATRACKER:GetTracker():UpdateConfig()
						AURATRACKER:GetTracker():UpdateCooldownConfig()
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(PrD.profile.auratracker.cooldown, PrC.db.profile.auratracker.cooldown)

							AURATRACKER:GetTracker():UpdateConfig()
							AURATRACKER:GetTracker():UpdateCooldownConfig()
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					exp_threshold = {
						order = inc(2),
						type = "range",
						name = L["EXP_THRESHOLD"],
						min = 1, max = 10, step = 1,
					},
					m_ss_threshold = {
						order = inc(2),
						type = "range",
						name = L["M_SS_THRESHOLD"],
						desc = L["M_SS_THRESHOLD_DESC"],
						min = 0, max = 3599, step = 1,
						softMin = 91,
						set = function(info, value)
							if PrC.db.profile.auratracker.cooldown.m_ss_threshold ~= value then
								if value < info.option.softMin then
									value = info.option.min
								end

								PrC.db.profile.auratracker.cooldown.m_ss_threshold = value

								AURATRACKER:GetTracker():UpdateConfig()
								AURATRACKER:GetTracker():UpdateCooldownConfig()
							end
						end,
					},
					s_ms_threshold = {
						order = inc(2),
						type = "range",
						name = L["S_MS_THRESHOLD"],
						desc = L["S_MS_THRESHOLD_DESC"],
						min = 1, max = 10, step = 1,
					},
					spacer_2 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					swipe = {
						order = inc(2),
						type = "group",
						name = L["COOLDOWN_SWIPE"],
						inline = true,
						get = function(info)
							return PrC.db.profile.auratracker.cooldown.swipe[info[#info]]
						end,
						set = function(info, value)
							if PrC.db.profile.auratracker.cooldown.swipe[info[#info]] ~= value then
								PrC.db.profile.auratracker.cooldown.swipe[info[#info]] = value

								AURATRACKER:GetTracker():UpdateConfig()
								AURATRACKER:GetTracker():UpdateCooldownConfig()
							end
						end,
						args = {
							enabled = {
								order = reset(3),
								type = "toggle",
								name = L["SHOW"],
							},
							reversed = {
								order = inc(3),
								type = "toggle",
								disabled = function()
									return not AURATRACKER:IsInit() or (AURATRACKER:IsInit() and not PrC.db.profile.auratracker.cooldown.swipe.enabled)
								end,
								name = L["REVERSE"],
							},
						},
					},
					spacer_3 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					text = {
						order = inc(2),
						type = "group",
						name = L["TEXT"],
						inline = true,
						get = function(info)
							return PrC.db.profile.auratracker.cooldown.text[info[#info]]
						end,
						set = function(info, value)
							if PrC.db.profile.auratracker.cooldown.text[info[#info]] ~= value then
								PrC.db.profile.auratracker.cooldown.text[info[#info]] = value

								AURATRACKER:GetTracker():UpdateConfig()
								AURATRACKER:GetTracker():UpdateCooldownConfig()
							end
						end,
						args = {
							enabled = {
								order = reset(3),
								type = "toggle",
								name = L["SHOW"],
							},
							size = {
								order = inc(3),
								type = "range",
								name = L["SIZE"],
								min = 8, max = 48, step = 1,
							},
							v_alignment = {
								order = inc(3),
								type = "select",
								name = L["TEXT_VERT_ALIGNMENT"],
								values = V_ALIGNMENTS,
							},
						},
					},
				},
			},
		},
	}
end
