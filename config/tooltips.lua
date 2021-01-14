local _, ns = ...
local E, C, M, L, P, D = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D
local CONFIG = P:GetModule("Config")
local TOOLTIPS = P:GetModule("Tooltips")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
]]

-- Mine
local offsets = {"", "   ", "      "}
local function d(c, o, v)
	print(offsets[o].."|cff"..c..v.."|r")
end

local orders = {0, 0}

local function reset(order)
	orders[order] = 1
	-- d("d20000", order, orders[order])
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	-- d("00d200", order, orders[order])
	return orders[order]
end

local function isModuleDisabled()
	return not TOOLTIPS:IsInit()
end

function CONFIG:CreateTooltipsPanel(order)
	C.options.args.tooltips = {
		order = order,
		type = "group",
		name = L["TOOLTIPS"],
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.char.tooltips.enabled
				end,
				set = function(_, value)
					C.db.char.tooltips.enabled = value

					if not TOOLTIPS:IsInit() then
						if value then
							P:Call(TOOLTIPS.Init, TOOLTIPS)
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
				order = inc(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				disabled = isModuleDisabled,
				func = function()
					CONFIG:CopySettings(D.profile.tooltips, C.db.profile.tooltips)

					TOOLTIPS:Update()
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = "",
				width = "full",
			},
			title = {
				order = inc(1),
				type = "toggle",
				name = L["PLAYER_TITLE"],
				disabled = isModuleDisabled,
				get = function()
					return C.db.profile.tooltips.title
				end,
				set = function(_, value)
					C.db.profile.tooltips.title = value
				end,
			},
			target = {
				order = inc(1),
				type = "toggle",
				name = L["TARGET_INFO"],
				desc = L["TARGET_INFO_DESC"],
				disabled = isModuleDisabled,
				get = function()
					return C.db.profile.tooltips.target
				end,
				set = function(_, value)
					C.db.profile.tooltips.target = value
				end,
			},
			inspect = {
				order = inc(1),
				type = "toggle",
				name = L["INSPECT_INFO"],
				desc = L["INSPECT_INFO_DESC"],
				disabled = isModuleDisabled,
				get = function()
					return C.db.profile.tooltips.inspect
				end,
				set = function(_, value)
					C.db.profile.tooltips.inspect = value

					TOOLTIPS:Update()
				end,
			},
			id = {
				order = inc(1),
				type = "toggle",
				name = L["TOOLTIP_IDS"],
				disabled = isModuleDisabled,
				get = function()
					return C.db.profile.tooltips.id
				end,
				set = function(_, value)
					C.db.profile.tooltips.id = value
				end,
			},
			count = {
				order = inc(1),
				type = "toggle",
				name = L["ITEM_COUNT"],
				desc = L["ITEM_COUNT_DESC"],
				disabled = isModuleDisabled,
				get = function()
					return C.db.profile.tooltips.count
				end,
				set = function(_, value)
					C.db.profile.tooltips.count = value
				end,
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = "",
				width = "full",
			},
			anchor_cursor = {
				order = inc(1),
				type = "toggle",
				name = L["ANCHOR_TO_CURSOR"],
				disabled = isModuleDisabled,
				get = function()
					return C.db.profile.tooltips.anchor_cursor
				end,
				set = function(_, value)
					C.db.profile.tooltips.anchor_cursor = value
				end,
			},
			spacer_3 = {
				order = inc(1),
				type = "description",
				name = "",
				width = "full",
			},
			health = {
				order = inc(1),
				type = "group",
				inline = true,
				name = L["HEALTH"],
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.tooltips.health[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.tooltips.health[info[#info]] ~= value then
						C.db.profile.tooltips.health[info[#info]] = value

						TOOLTIPS:Update()
					end
				end,
				args = {
					reset = {
						type = "execute",
						order = reset(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.tooltips.health, C.db.profile.tooltips.health)

							TOOLTIPS:Update()
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = "",
						width = "full",
					},
					height = {
						order = inc(2),
						type = "range",
						name = L["HEIGHT"],
						min = 8, max = 32, step = 4,
					},
					spacer_2 = {
						order = inc(2),
						type = "description",
						name = "",
						width = "full",
					},
					text = {
						order = inc(2),
						type = "group",
						name = L["TEXT"],
						inline = true,
						get = function(info)
							return C.db.profile.tooltips.health.text[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.tooltips.health.text[info[#info]] ~= value then
								C.db.profile.tooltips.health.text[info[#info]] = value

								TOOLTIPS:Update()
							end
						end,
						args = {
							size = {
								order = 1,
								type = "range",
								name = L["SIZE"],
								min = 8, max = 32, step = 1,
							},
						},
					},
				},
			},
		},
	}
end
