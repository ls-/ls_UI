local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local MINIMAP = P:GetModule("Minimap")

-- Lua
local _G = getfenv(0)

-- Mine
local MODES = {
	[0] = L["HIDE"],
	[1] = L["MOUSEOVER_SHOW"],
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

function CONFIG.CreateMinimapPanel(_, order)
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
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				func = function()
					CONFIG:CopySettings(D.profile.minimap[E.UI_LAYOUT], C.db.profile.minimap[E.UI_LAYOUT], {["point"] = true})
					CONFIG:CopySettings(D.profile.minimap.color, C.db.profile.minimap.color)
					MINIMAP:Update()
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			clock = {
				order = 10,
				type = "group",
				name = L["CLOCK"],
				guiInline = true,
				get = function(info)
					return C.db.profile.minimap[E.UI_LAYOUT].clock[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap[E.UI_LAYOUT].clock[info[#info]] = value
					MINIMAP:GetMinimap():UpdateConfig()
					MINIMAP:GetMinimap():UpdateClock()
				end,
				disabled = function() return not MINIMAP:IsInit() end,
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
						values = POSITIONS,
					},
				},
			},
			spacer_2 = {
				order = 19,
				type = "description",
				name = " ",
			},
			zone_text = {
				order = 20,
				type = "group",
				name = L["ZONE_TEXT"],
				guiInline = true,
				get = function(info)
					return C.db.profile.minimap[E.UI_LAYOUT].zone_text[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap[E.UI_LAYOUT].zone_text[info[#info]] = value
					MINIMAP:GetMinimap():UpdateConfig()
					MINIMAP:GetMinimap():UpdateZone()
				end,
				disabled = function() return not MINIMAP:IsInit() end,
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
						values = POSITIONS,
					},
					border = {
						order = 3,
						type = "toggle",
						name = L["BORDER"],
						disabled = function() return not MINIMAP:IsInit() or C.db.profile.minimap[E.UI_LAYOUT].zone_text.mode ~= 2 end,
					},
				},
			},
			spacer_3 = {
				order = 29,
				type = "description",
				name = " ",
			},
			flag = {
				order = 30,
				type = "group",
				name = L["DIFFICULTY_FLAG"],
				guiInline = true,
				get = function(info)
					return C.db.profile.minimap[E.UI_LAYOUT].flag[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap[E.UI_LAYOUT].flag[info[#info]] = value
					MINIMAP:GetMinimap():UpdateConfig()
					MINIMAP:GetMinimap():UpdateFlag()
				end,
				disabled = function() return not MINIMAP:IsInit() end,
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
							MINIMAP:GetMinimap():UpdateConfig()
							MINIMAP:GetMinimap():UpdateBorder()
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
							MINIMAP:GetMinimap():UpdateConfig()
							MINIMAP:GetMinimap():UpdateZoneText()
						end,
					},
				},
			},
		},
	}
end
