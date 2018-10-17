local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local AURATRACKER = P:GetModule("AuraTracker")
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)
local s_split = _G.string.split
local unpack = _G.unpack

-- Mine
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

local H_ALIGNMENTS = {
	["CENTER"] = "CENTER",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
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

local function updateCallback()
	AURATRACKER:GetTracker():UpdateConfig()
	AURATRACKER:GetTracker():Update()
end

function CONFIG.CreateAuraTrackerPanel(_, order)
	C.options.args.auratracker = {
		order = order,
		type = "group",
		name = L["AURA_TRACKER"],
		get = function(info)
			return C.db.char.auratracker[info[#info]]
		end,
		set = function(info, value)
			if C.db.char.auratracker[info[#info]] ~= value then
				C.db.char.auratracker[info[#info]] = value
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
				end,
			},
			locked = {
				order = 2,
				type = "toggle",
				name = L["LOCK"],
				disabled = isModuleDisabled,
				set = function(info, value)
					if C.db.char.auratracker[info[#info]] ~= value then
						C.db.char.auratracker[info[#info]] = value
						AURATRACKER:GetTracker():UpdateConfig()
						AURATRACKER:GetTracker():UpdateLock()
					end
				end,
			},
			reset = {
				type = "execute",
				order = 3,
				name = L["RESTORE_DEFAULTS"],
				disabled = isModuleDisabled,
				func = function()
					CONFIG:CopySettings(D.char.auratracker, C.db.char.auratracker, {enabled = true, filter = true})
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
					return C.db.char.auratracker.x_growth .. "_" .. C.db.char.auratracker.y_growth
				end,
				set = function(_, value)
					C.db.char.auratracker.x_growth, C.db.char.auratracker.y_growth = s_split("_", value)
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
					return DRAG_KEY_INDICES[C.db.char.auratracker.drag_key]
				end,
				set = function(_, value)
					C.db.char.auratracker.drag_key = DRAG_KEY_VALUES[value]
				end,
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			count = {
				order = 20,
				type = "group",
				name = L["COUNT_TEXT"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.char.auratracker.count[info[#info]]
				end,
				set = function(info, value)
					if C.db.char.auratracker.count[info[#info]] ~= value then
						C.db.char.auratracker.count[info[#info]] = value
						AURATRACKER:GetTracker():UpdateConfig()
						AURATRACKER:GetTracker():UpdateButtons("UpdateCountFont")
					end
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
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			cooldown = {
				order = 30,
				type = "group",
				name = L["COOLDOWN_TEXT"],
				inline = true,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.char.auratracker.cooldown.text[info[#info]]
				end,
				set = function(info, value)
					if C.db.char.auratracker.cooldown.text[info[#info]] ~= value then
						C.db.char.auratracker.cooldown.text[info[#info]] = value
						AURATRACKER:GetTracker():UpdateConfig()
						AURATRACKER:GetTracker():UpdateCooldownConfig()
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = 1,
						name = L["RESTORE_DEFAULTS"],
						func = function()
							CONFIG:CopySettings(D.char.auratracker.cooldown, C.db.char.auratracker.cooldown)
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
						desc = L["EXP_THRESHOLD_DESC"],
						min = 1, max = 10, step = 1,
						get = function()
							return C.db.char.auratracker.cooldown.exp_threshold
						end,
						set = function(_, value)
							if C.db.char.auratracker.cooldown.exp_threshold ~= value then
								C.db.char.auratracker.cooldown.exp_threshold = value
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
							return C.db.char.auratracker.cooldown.m_ss_threshold
						end,
						set = function(info, value)
							if C.db.char.auratracker.cooldown.m_ss_threshold ~= value then
								if value < info.option.softMin then
									value = info.option.min
								end

								C.db.char.auratracker.cooldown.m_ss_threshold = value
								AURATRACKER:GetTracker():UpdateConfig()
								AURATRACKER:GetTracker():UpdateCooldownConfig()
							end
						end,
					},
					size = {
						order = 13,
						type = "range",
						name = L["SIZE"],
						min = 10, max = 20, step = 2,
					},
					flag = {
						order = 14,
						type = "select",
						name = L["FLAG"],
						values = FLAGS,
					},
					v_alignment = {
						order = 15,
						type = "select",
						name = L["TEXT_VERT_ALIGNMENT"],
						values = V_ALIGNMENTS,
					},
					spacer_2 = {
						order = 19,
						type = "description",
						name = " ",
					},
					colors = {
						order = 20,
						type = "group",
						name = L["COLORS"],
						inline = true,
						get = function(info)
							return unpack(C.db.char.auratracker.cooldown.colors[info[#info]])
						end,
						set = function(info, r, g, b)
							if r ~= nil then
								local color = C.db.char.auratracker.cooldown.colors[info[#info]]
								if color[1] ~= r or color[2] ~= g or color[3] ~= b then
									color[1], color[2], color[3] = r, g, b
									AURATRACKER:GetTracker():UpdateConfig()
									AURATRACKER:GetTracker():UpdateCooldownConfig()
								end
							end
						end,
						args = {
							enabled = {
								order = 1,
								type = "toggle",
								name = L["ENABLE"],
								get = function()
									return C.db.char.auratracker.cooldown.colors.enabled
								end,
								set = function(_, value)
									C.db.char.auratracker.cooldown.colors.enabled = value
									AURATRACKER:GetTracker():UpdateConfig()
									AURATRACKER:GetTracker():UpdateCooldownConfig()
								end,
							},
							expiration = {
								order = 2,
								type = "color",
								name = L["EXPIRATION"],
							},
							second = {
								order = 3,
								type = "color",
								name = L["SECONDS"],
							},
							minute = {
								order = 4,
								type = "color",
								name = L["MINUTES"],
							},
							hour = {
								order = 5,
								type = "color",
								name = L["HOURS"],
							},
							day = {
								order = 6,
								type = "color",
								name = L["DAYS"],
							},
						},
					},
				},
			},
			spacer_4 = {
				order = 39,
				type = "description",
				name = " ",
			},
			settings = {
				type = "execute",
				order = 40,
				name = L["FILTER_SETTINGS"],
				disabled = isModuleDisabled,
				func = function()
					CONFIG:OpenAuraConfig(L["AURA_TRACKER"], C.db.char.auratracker.filter, {1, 2}, {3}, updateCallback)
				end,
			},
		},
	}
end
