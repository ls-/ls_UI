-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
local TOOLTIPS = P:GetModule("Tooltips")

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local function isModuleDisabled()
	return not TOOLTIPS:IsInit()
end

function CONFIG:GetTooltipsOptions(order)
	self.options.args.tooltips = {
		order = order,
		type = "group",
		name = L["TOOLTIPS"],
		get = function(info)
			return C.db.profile.tooltips[info[#info]]
		end,
		set = function(info, value)
			C.db.profile.tooltips[info[#info]] = value
		end,
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["ENABLE"]),
				get = function()
					return PrC.db.profile.tooltips.enabled
				end,
				set = function(_, value)
					PrC.db.profile.tooltips.enabled = value

					if TOOLTIPS:IsInit() then
						CONFIG:AskToReloadUI("tooltips.enabled", value)
					else
						if value then
							P:Call(TOOLTIPS.Init, TOOLTIPS)
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
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			title = {
				order = inc(1),
				type = "toggle",
				name = L["PLAYER_TITLE"],
				disabled = isModuleDisabled,
			},
			target = {
				order = inc(1),
				type = "toggle",
				name = L["TARGET_INFO"],
				desc = L["TARGET_INFO_DESC"],
				disabled = isModuleDisabled,
			},
			inspect = {
				order = inc(1),
				type = "toggle",
				name = L["INSPECT_INFO"],
				desc = L["INSPECT_INFO_DESC"],
				disabled = isModuleDisabled,
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
			},
			count = {
				order = inc(1),
				type = "toggle",
				name = L["ITEM_COUNT"],
				desc = L["ITEM_COUNT_DESC"],
				disabled = isModuleDisabled,
			},
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			spacer_3 = CONFIG:CreateSpacer(inc(1)),
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
					spacer_1 = CONFIG:CreateSpacer(inc(2)),
					height = {
						order = inc(2),
						type = "range",
						name = L["HEIGHT"],
						min = 8, max = 32, step = 1, bigStep = 2,
					},
					spacer_2 = CONFIG:CreateSpacer(inc(2)),
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
