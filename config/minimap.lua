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
			spacer_1 = {
				order = 9,
				type = "description",
				name = "",
				width = "full",
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
					MINIMAP:Update()
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
			zone_text = {
				order = 11,
				type = "group",
				name = L["ZONE_TEXT"],
				guiInline = true,
				get = function(info)
					return C.db.profile.minimap[E.UI_LAYOUT].zone_text[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.minimap[E.UI_LAYOUT].zone_text[info[#info]] = value
					MINIMAP:Update()
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
						name = L["UNIT_FRAME_BORDER"],
						disabled = function() return not MINIMAP:IsInit() or C.db.profile.minimap[E.UI_LAYOUT].zone_text.mode ~= 2 end,
					},
				},
			},
		},
	}
end
