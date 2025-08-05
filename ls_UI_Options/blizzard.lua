-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
local BLIZZARD = P:GetModule("Blizzard")

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
	return not BLIZZARD:IsInit()
end

local function areEnchantsDisabled()
	return not (BLIZZARD:IsInit() and C.db.profile.blizzard.character_frame.enhancements)
end

function CONFIG:CreateBlizzardOptions(order)
	self.options.args.blizzard = {
		order = order,
		type = "group",
		name = L["BLIZZARD"],
		childGroups = "tab",
		get = function(info)
			return PrC.db.profile.blizzard[info[#info]].enabled
		end,
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["ENABLE"]),
				get = function()
					return PrC.db.profile.blizzard.enabled
				end,
				set = function(_, value)
					PrC.db.profile.blizzard.enabled = value

					if BLIZZARD:IsInit() then
						CONFIG:AskToReloadUI("blizzard.enabled", value)
					else
						if value then
							P:Call(BLIZZARD.Init, BLIZZARD)
						end
					end
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			command_bar = {
				order = inc(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["COMMAND_BAR"]),
				disabled = isModuleDisabled,
				set = function(_, value)
					PrC.db.profile.blizzard.command_bar.enabled = value

					if BLIZZARD:HasCommandBar() then
						CONFIG:AskToReloadUI("command_bar.enabled", value)
					else
						if value then
							BLIZZARD:SetUpCommandBar()
						end
					end
				end,
			},
			gm = {
				order = inc(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["GM_FRAME"]),
				disabled = isModuleDisabled,
				set = function(_, value)
					PrC.db.profile.blizzard.gm.enabled = value

					if BLIZZARD:HasGMFrame() then
						CONFIG:AskToReloadUI("gm.enabled", value)
					else
						if value then
							BLIZZARD:SetUpGMFrame()
						end
					end
				end,
			},
			mail = {
				order = inc(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["MAIL"]),
				disabled = isModuleDisabled,
				set = function(_, value)
					PrC.db.profile.blizzard.mail.enabled = value

					if BLIZZARD:HasMail() then
						CONFIG:AskToReloadUI("mail.enabled", value)
					else
						if value then
							BLIZZARD:SetUpMail()
						end
					end
				end,
			},
			suggest_frame = {
				order = inc(1),
				type = "toggle",
				name = CONFIG:ColorPrivateSetting(L["ADVENTURE_GUIDE"]),
				disabled = isModuleDisabled,
				set = function(_, value)
					PrC.db.profile.blizzard.suggest_frame.enabled = value

					if BLIZZARD:HasMail() then
						CONFIG:AskToReloadUI("suggest_frame.enabled", value)
					else
						if value then
							BLIZZARD:SetUpSuggestFrame()
						end
					end
				end,
			},
			character_frame = {
				order = inc(1),
				type = "group",
				name = L["CHARACTER_FRAME"],
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.blizzard.character_frame[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.blizzard.character_frame[info[#info]] ~= value then
						C.db.profile.blizzard.character_frame[info[#info]] = value

						BLIZZARD:UpadteCharacterFrame()
					end
				end,
				args = {
					enabled = {
						order = reset(2),
						type = "toggle",
						name = CONFIG:ColorPrivateSetting(L["ENABLE"]),
						get = function()
							return PrC.db.profile.blizzard.character_frame.enabled
						end,
						set = function(_, value)
							PrC.db.profile.blizzard.character_frame.enabled = value

							if BLIZZARD:HasCharacterFrame() then
								CONFIG:AskToReloadUI("character_frame.enabled", value)
							else
								if value then
									BLIZZARD:SetUpCharacterFrame()
								end
							end
						end,
					},
					reset = {
						type = "execute",
						order = inc(2),
						name = L["RESET_TO_DEFAULT"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.blizzard.character_frame, C.db.profile.blizzard.character_frame)

							BLIZZARD:UpadteCharacterFrame()
						end,
					},
					spacer_1 = CONFIG:CreateSpacer(inc(2)),
					ilvl = {
						order = inc(2),
						type = "toggle",
						name = L["ILVL"],
					},
					upgrade = {
						order = inc(2),
						type = "toggle",
						name = L["UPGRADE_LEVEL"],
					},
					enhancements = {
						order = inc(2),
						type = "toggle",
						name = L["ENCHANTS"],
					},
					spacer_2 = CONFIG:CreateSpacer(inc(2)),
					missing_enhancements = {
						order = inc(2),
						type = "group",
						inline = true,
						name = L["MISSING_ENCHANTS"],
						disabled = areEnchantsDisabled,
						get = function(info)
							return C.db.profile.blizzard.character_frame.missing_enhancements[info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.blizzard.character_frame.missing_enhancements[info[#info]] ~= value then
								C.db.profile.blizzard.character_frame.missing_enhancements[info[#info]] = value

								BLIZZARD:UpadteCharacterFrame()
							end
						end,
						args = {
							head = {
								order = reset(3),
								type = "toggle",
								name = HEADSLOT,
								width = 1.25,
							},
							hands = {
								order = inc(3),
								type = "toggle",
								name = HANDSSLOT,
								width = 1.25,
							},
							spacer_1 = CONFIG:CreateSpacerNoHeight(inc(3)),
							neck = {
								order = inc(3),
								type = "toggle",
								name = NECKSLOT,
								width = 1.25,
							},
							waist = {
								order = inc(3),
								type = "toggle",
								name = WAISTSLOT,
								width = 1.25,
							},
							spacer_2 = CONFIG:CreateSpacerNoHeight(inc(3)),
							shoulder = {
								order = inc(3),
								type = "toggle",
								name = SHOULDERSLOT,
								width = 1.25,
							},
							legs = {
								order = inc(3),
								type = "toggle",
								name = LEGSSLOT,
								width = 1.25,
							},
							spacer_3 = CONFIG:CreateSpacerNoHeight(inc(3)),
							back = {
								order = inc(3),
								type = "toggle",
								name = BACKSLOT,
								width = 1.25,
							},
							feet = {
								order = inc(3),
								type = "toggle",
								name = FEETSLOT,
								width = 1.25,
							},
							spacer_4 = CONFIG:CreateSpacerNoHeight(inc(3)),
							chest = {
								order = inc(3),
								type = "toggle",
								name = CHESTSLOT,
								width = 1.25,
							},
							finger = {
								order = inc(3),
								type = "toggle",
								name = FINGER0SLOT,
								width = 1.25,
							},
							spacer_5 = CONFIG:CreateSpacerNoHeight(inc(3)),
							wrist = {
								order = inc(3),
								type = "toggle",
								name = WRISTSLOT,
								width = 1.25,
							},
							trinket = {
								order = inc(3),
								type = "toggle",
								name = TRINKET0SLOT,
								width = 1.25,
							},
							spacer_6 = CONFIG:CreateSpacerNoHeight(inc(3)),
							main_hand = {
								order = inc(3),
								type = "toggle",
								name = MAINHANDSLOT,
								width = 1.25,
							},
							secondary_hand = {
								order = inc(3),
								type = "toggle",
								name = SECONDARYHANDSLOT,
								width = 1.25,
							},
						},
					},
				},
			},
			inspect_frame = {
				order = inc(1),
				type = "group",
				name = L["INSPECT_FRAME"],
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.blizzard.inspect_frame[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.blizzard.inspect_frame[info[#info]] ~= value then
						C.db.profile.blizzard.inspect_frame[info[#info]] = value

						BLIZZARD:UpadteInspectFrame()
					end
				end,
				args = {
					enabled = {
						order = reset(2),
						type = "toggle",
						name = CONFIG:ColorPrivateSetting(L["ENABLE"]),
						get = function()
							return PrC.db.profile.blizzard.inspect_frame.enabled
						end,
						set = function(_, value)
							PrC.db.profile.blizzard.inspect_frame.enabled = value

							if BLIZZARD:HasInspectFrame() then
								CONFIG:AskToReloadUI("inspect_frame.enabled", value)
							else
								if value then
									BLIZZARD:SetUpInspectFrame()
								end
							end
						end,
					},
					reset = {
						type = "execute",
						order = inc(2),
						name = L["RESET_TO_DEFAULT"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.blizzard.inspect_frame, C.db.profile.blizzard.inspect_frame)

							BLIZZARD:UpadteInspectFrame()
						end,
					},
					spacer_1 = CONFIG:CreateSpacer(inc(2)),
					ilvl = {
						order = inc(2),
						type = "toggle",
						name = L["ILVL"],
					},
					upgrade = {
						order = inc(2),
						type = "toggle",
						name = L["UPGRADE_LEVEL"],
					},
					enhancements = {
						order = inc(2),
						type = "toggle",
						name = L["ENCHANTS"],
					},
				},
			},
			game_menu = {
				order = inc(1),
				type = "group",
				name = L["GAME_MENU"],
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.blizzard.game_menu[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.blizzard.game_menu[info[#info]] = value
				end,
				args = {
					scale = {
						order = reset(2),
						type = "range",
						name = L["SCALE"],
						min = 0.5, max = 1, step = 0.01, bigStep = 0.05,
						isPercent = true,
					},
				},
			},
			talking_head = {
				order = inc(1),
				type = "group",
				name = L["TALKING_HEAD"],
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.blizzard.talking_head[info[#info]]
				end,
				set = function(info, value)
					C.db.profile.blizzard.talking_head[info[#info]] = value
				end,
				args = {
					hide = {
						order = reset(2),
						type = "toggle",
						name = L["HIDE"],
					},
				},
			},
		},
	}
end
