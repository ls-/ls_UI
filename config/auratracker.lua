local _, ns = ...
local E, C, PrC, M, L, P, D, PrD = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD
local AURATRACKER = P:GetModule("AuraTracker")
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)
local s_split = _G.string.split

--[[ luacheck: globals
	GameTooltip InCombatLockdown LibStub
]]

-- Mine
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

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

local FLAGS = {
	-- [""] = L["NONE"],
	["_Outline"] = L["OUTLINE"],
	["_Shadow"] = L["SHADOW"],
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

function CONFIG.CreateAuraTrackerPanel(_, order)
	C.options.args.auratracker = {
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
				E:UpdateBarLayout(AURATRACKER:GetTracker())
			end
		end,
		args = {
			enabled = {
				order = 1,
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
				order = 2,
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
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				disabled = isModuleDisabled,
				func = function()
					CONFIG:CopySettings(D.char.auratracker, PrC.db.profile.auratracker, {enabled = true, filter = true})
					AURATRACKER:Update()
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			num = {
				order = 10,
				type = "range",
				name = L["NUM_BUTTONS"],
				min = 1, max = 12, step = 1,
				disabled = isModuleDisabled,
			},
			per_row = {
				order = 11,
				type = "range",
				name = L["PER_ROW"],
				min = 1, max = 12, step = 1,
				disabled = isModuleDisabled,
			},
			spacing = {
				order = 12,
				type = "range",
				name = L["SPACING"],
				min = 4, max = 24, step = 2,
				disabled = isModuleDisabled,
			},
			size = {
				order = 13,
				type = "range",
				name = L["SIZE"],
				min = 24, max = 64, step = 1,
				disabled = isModuleDisabled,
			},
			growth_dir = {
				order = 14,
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
					E:UpdateBarLayout(AURATRACKER:GetTracker())
				end,
			},
			drag_key = {
				order = 15,
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
				order = 19,
				type = "description",
				name = " ",
			},
			type = {
				order = 20,
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
					debuff_type = {
						order = 1,
						type = "toggle",
						name = L["DEBUFF_TYPE"],
					},
					size = {
						order = 2,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					position = {
						order = 3,
						type = "select",
						name = L["POINT"],
						values = CONFIG.POINTS,
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			count = {
				order = 30,
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
						order = 1,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					h_alignment = {
						order = 4,
						type = "select",
						name = L["TEXT_HORIZ_ALIGNMENT"],
						values = CONFIG.H_ALIGNMENTS,
					},
					v_alignment = {
						order = 5,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = CONFIG.V_ALIGNMENTS,
					},
				},
			},
			spacer_4 = {
				order = 39,
				type = "description",
				name = " ",
			},
			cooldown = {
				order = 40,
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				disabled = isModuleDisabled,
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
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.char.auratracker.cooldown, PrC.db.profile.auratracker.cooldown)
							AURATRACKER:GetTracker():UpdateConfig()
							AURATRACKER:GetTracker():UpdateCooldownConfig()
						end,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
					},
					enabled = {
						order = 10,
						type = "toggle",
						name = L["SHOW"],
					},
					exp_threshold = {
						order = 11,
						type = "range",
						name = L["EXP_THRESHOLD"],
						min = 1, max = 10, step = 1,
						get = function()
							return PrC.db.profile.auratracker.cooldown.exp_threshold
						end,
						set = function(_, value)
							if PrC.db.profile.auratracker.cooldown.exp_threshold ~= value then
								PrC.db.profile.auratracker.cooldown.exp_threshold = value
								AURATRACKER:GetTracker():UpdateConfig()
								AURATRACKER:GetTracker():UpdateCooldownConfig()
							end
						end,
					},
					m_ss_threshold = {
						order = 12,
						type = "range",
						name = L["M_SS_THRESHOLD"],
						desc = L["M_SS_THRESHOLD_DESC"],
						min = 0, max = 3599, step = 1,
						softMin = 91,
						get = function()
							return PrC.db.profile.auratracker.cooldown.m_ss_threshold
						end,
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
						order = 13,
						type = "range",
						name = L["S_MS_THRESHOLD"],
						desc = L["S_MS_THRESHOLD_DESC"],
						min = 1, max = 10, step = 1,
						get = function()
							return PrC.db.profile.auratracker.cooldown.s_ms_threshold
						end,
						set = function(_, value)
							if PrC.db.profile.auratracker.cooldown.s_ms_threshold ~= value then
								PrC.db.profile.auratracker.cooldown.s_ms_threshold = value

								AURATRACKER:GetTracker():UpdateConfig()
								AURATRACKER:GetTracker():UpdateCooldownConfig()
							end
						end,
					},
					size = {
						order = 14,
						type = "range",
						name = L["SIZE"],
						min = 8, max = 48, step = 1,
					},
					v_alignment = {
						order = 15,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = V_ALIGNMENTS,
					},
				},
			},
			spacer_5 = {
				order = 49,
				type = "description",
				name = " ",
			},
			settings = {
				type = "execute",
				order = 50,
				name = L["FILTER_SETTINGS"],
				disabled = isModuleDisabled,
				func = function()
					AceConfigDialog:Close("ls_UI")
					GameTooltip:Hide()

					CONFIG:OpenAuraConfig(L["AURA_TRACKER"], nil, PrC.db.profile.auratracker.filter.HELPFUL, PrC.db.profile.auratracker.filter.HARMFUL, callback)
				end,
			},
		},
	}
end
