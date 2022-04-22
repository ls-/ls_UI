local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
local MINIMAP = P:GetModule("Minimap")

local MODES = {
	[0] = L["HIDE"],
	[1] = L["SHOW_ON_MOUSEOVER"],
	[2] = L["ALWAYS_SHOW"],
}

local POSITIONS = {
	[0] = L["TOP"],
	[1] = L["BOTTOM"],
}

local FLAG_POSITIONS = {
	[0] = L["ZONE_TEXT"],
	[1] = L["CLOCK"],
	[2] = L["BOTTOM"],
}

local function isModuleDisabled()
	return not MINIMAP:IsInit()
end

local function isMinimapSquare()
	return MINIMAP:IsInit() and MINIMAP:IsSquare()
end

local function isMinimapRound()
	return MINIMAP:IsInit() and not MINIMAP:IsSquare()
end

local function isFadingDisabled()
	return not (MINIMAP:IsInit() and C.db.profile.minimap.fade.enabled)
end

local function isButtonCollectionDisabled()
	return not (MINIMAP:IsInit() and C.db.profile.minimap.collect.enabled)
end

function CONFIG.CreateMinimapPanel(_, order)
	CONFIG.options.args.minimap = {
		order = order,
		type = "group",
		name = L["MINIMAP"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return PrC.db.profile.minimap.enabled
				end,
				set = function(_, value)
					PrC.db.profile.minimap.enabled = value

					if not MINIMAP:IsInit() then
						if value then
							P:Call(MINIMAP.Init, MINIMAP)
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end,
			},
			square = {
				order = 2,
				type = "toggle",
				name = L["SQUARE_MINIMAP"],
				get = function()
					return PrC.db.profile.minimap[E.UI_LAYOUT].square
				end,
				set = function(_, value)
					PrC.db.profile.minimap[E.UI_LAYOUT].square = value

					if MINIMAP:IsInit() then
						CONFIG:ShowStaticPopup("RELOAD_UI")
					end
				end,
			},
			reset = {
				type = "execute",
				order = 8,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				disabled = isModuleDisabled,
				func = function()
					CONFIG:CopySettings(D.profile.minimap[E.UI_LAYOUT], C.db.profile.minimap[E.UI_LAYOUT], {["point"] = true})
					CONFIG:CopySettings(D.profile.minimap.buttons, C.db.profile.minimap.buttons)
					CONFIG:CopySettings(D.profile.minimap.collect, C.db.profile.minimap.collect)
					CONFIG:CopySettings(D.profile.minimap.color, C.db.profile.minimap.color)

					MINIMAP:Update()
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			size = {
				order = 10,
				type = "range",
				name = L["SIZE"],
				hidden = isMinimapRound,
				disabled = isModuleDisabled,
				min = 146, max = 292, step = 2,
				get = function()
					return C.db.profile.minimap[E.UI_LAYOUT].size
				end,
				set = function(info, value)
					if C.db.profile.minimap[E.UI_LAYOUT].size ~= value then
						C.db.profile.minimap[E.UI_LAYOUT].size = value

						Minimap:UpdateConfig()
						Minimap:UpdateSize()
						Minimap:UpdateButtons()
					end
				end,
			},
			scale = {
				order = 10,
				type = "select",
				name = L["SIZE"],
				hidden = isMinimapSquare,
				disabled = isModuleDisabled,
				values = {
					[100] = "100%",
					[125] = "125%",
					[150] = "150%",
				},
				get = function()
					return C.db.profile.minimap[E.UI_LAYOUT].scale
				end,
				set = function(info, value)
					if C.db.profile.minimap[E.UI_LAYOUT].scale ~= value then
						C.db.profile.minimap[E.UI_LAYOUT].scale = value

						Minimap:UpdateConfig()
						Minimap:UpdateSize()
						Minimap:UpdateButtons()
					end
				end,
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			clock = {
				order = 20,
				type = "group",
				name = L["CLOCK"],
				guiInline = true,
				hidden = isMinimapSquare,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.minimap[E.UI_LAYOUT].clock[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap[E.UI_LAYOUT].clock[info[#info]] = value
					Minimap:UpdateConfig()
					Minimap:UpdateClock()
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["SHOW"],
					},
					position = {
						order = 2,
						type = "select",
						name = L["POSITION"],
						values = POSITIONS,
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
				hidden = isMinimapSquare,
			},
			zone_text = {
				order = 30,
				type = "group",
				name = L["ZONE_TEXT"],
				guiInline = true,
				hidden = isMinimapSquare,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.minimap[E.UI_LAYOUT].zone_text[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap[E.UI_LAYOUT].zone_text[info[#info]] = value
					Minimap:UpdateConfig()
					Minimap:UpdateZone()
				end,
				args = {
					mode = {
						order = 1,
						type = "select",
						name = L["VISIBILITY"],
						values = MODES,
					},
					border = {
						order = 2,
						type = "toggle",
						name = L["BORDER"],
						disabled = function() return not MINIMAP:IsInit() or C.db.profile.minimap[E.UI_LAYOUT].zone_text.mode ~= 2 end,
					},
				},
			},
			spacer_4 = {
				order = 39,
				type = "description",
				name = " ",
				hidden = isMinimapSquare,
			},
			flag = {
				order = 40,
				type = "group",
				name = L["DIFFICULTY_FLAG"],
				guiInline = true,
				hidden = isMinimapSquare,
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.minimap[E.UI_LAYOUT].flag[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap[E.UI_LAYOUT].flag[info[#info]] = value
					Minimap:UpdateConfig()
					Minimap:UpdateFlag()
				end,
				args = {
					mode = {
						order = 1,
						type = "select",
						name = L["VISIBILITY"],
						values = MODES,
					},
					position = {
						order = 2,
						type = "select",
						name = L["POSITION"],
						values = FLAG_POSITIONS,
					},
				},
			},
			spacer_5 = {
				order = 49,
				type = "description",
				name = " ",
				hidden = isMinimapSquare,
			},
			colors = {
				order = 50,
				type = "group",
				name = L["COLORS"],
				inline = true,
				disabled = isModuleDisabled,
				args = {
					border = {
						order = 1,
						type = "toggle",
						name = L["BORDER"],
						get = function()
							return C.db.profile.minimap.color.border
						end,
						set = function(_, value)
							C.db.profile.minimap.color.border = value
							Minimap:UpdateConfig()
							Minimap:UpdateBorderColor()
						end,
					},
					zone_text = {
						order = 2,
						type = "toggle",
						name = L["ZONE_TEXT"],
						get = function()
							return C.db.profile.minimap.color.zone_text
						end,
						set = function(_, value)
							C.db.profile.minimap.color.zone_text = value
							Minimap:UpdateConfig()
							Minimap:UpdateZoneColor()
						end,
					},
				},
			},
			spacer_6 = {
				order = 59,
				type = "description",
				name = " ",
			},
			fadeing = {
				order = 60,
				type = "group",
				name = L["FADING"],
				inline = true,
				get = function(info)
					return C.db.profile.minimap.fade[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap.fade[info[#info]] = value

					Minimap:UpdateConfig()
					Minimap:UpdateFading()
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						disabled = isModuleDisabled,
					},
					reset = {
						order = 2,
						type = "execute",
						name = L["RESTORE_DEFAULTS"],
						disabled = isFadingDisabled,
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.minimap.fade, C.db.profile.minimap.fade, {enabled = true})

							Minimap:UpdateConfig()
							Minimap:UpdateFading()
						end,
					},
					spacer_1 = {
						order = 3,
						type = "description",
						name = " ",
					},
					combat = {
						order = 4,
						type = "toggle",
						name = L["COMBAT"],
						disabled = isFadingDisabled,
					},
					target = {
						order = 5,
						type = "toggle",
						name = L["TARGET"],
						disabled = isFadingDisabled,
					},
					in_duration = {
						order = 6,
						type = "range",
						name = L["FADE_IN_DURATION"],
						disabled = isFadingDisabled,
						min = 0.05, max = 1, step = 0.05,
					},
					out_delay = {
						order = 7,
						type = "range",
						name = L["FADE_OUT_DELAY"],
						disabled = isFadingDisabled,
						min = 0, max = 2, step = 0.05,
					},
					out_duration = {
						order = 8,
						type = "range",
						name = L["FADE_OUT_DURATION"],
						disabled = isFadingDisabled,
						min = 0.05, max = 1, step = 0.05,
					},
					min_alpha = {
						order = 9,
						type = "range",
						name = L["MIN_ALPHA"],
						disabled = isFadingDisabled,
						min = 0, max = 1, step = 0.05,
					},
					max_alpha = {
						order = 10,
						type = "range",
						name = L["MAX_ALPHA"],
						disabled = isFadingDisabled,
						min = 0, max = 1, step = 0.05
					},
				},
			},
			spacer_7 = {
				order = 69,
				type = "description",
				name = " ",
			},
			collect = {
				order = 70,
				type = "group",
				name = L["COLLECT_BUTTONS"],
				inline = true,
				get = function(info)
					return C.db.profile.minimap.collect[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap.collect[info[#info]] = value
					Minimap:UpdateConfig()
					Minimap:UpdateButtons()
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["ENABLE"],
						disabled = isModuleDisabled,
					},
					tooltip = {
						order = 2,
						type = "toggle",
						name = L["SHOW_TOOLTIP"],
						disabled = isButtonCollectionDisabled,
					},
					spacer_1 = {
						order = 9,
						type = "description",
						name = " ",
						disabled = isButtonCollectionDisabled,
					},
					calendar = {
						order = 10,
						type = "toggle",
						name = L["CALENDAR"],
						disabled = isButtonCollectionDisabled,
					},
					garrison = {
						order = 11,
						type = "toggle",
						name = L["GARRISON"],
						disabled = isButtonCollectionDisabled,
					},
					mail = {
						order = 12,
						type = "toggle",
						name = L["MAIL"],
						disabled = isButtonCollectionDisabled,
					},
					queue = {
						order = 13,
						type = "toggle",
						name = L["QUEUE"],
						disabled = isButtonCollectionDisabled,
					},
					tracking = {
						order = 14,
						type = "toggle",
						name = L["TRACKING"],
						disabled = isButtonCollectionDisabled,
					},
				},
			},
		},
	}
end
