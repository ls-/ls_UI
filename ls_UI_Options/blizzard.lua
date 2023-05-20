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
				name = L["ENABLE"],
				get = function()
					return PrC.db.profile.blizzard.enabled
				end,
				set = function(_, value)
					PrC.db.profile.blizzard.enabled = value

					if not BLIZZARD:IsInit() then
						if value then
							P:Call(BLIZZARD.Init, BLIZZARD)
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
				width = "full",
			},
			command_bar = {
				order = inc(1),
				type = "toggle",
				name = L["COMMAND_BAR"],
				disabled = isModuleDisabled,
				set = function(_, value)
					PrC.db.profile.blizzard.command_bar.enabled = value

					if not BLIZZARD:HasCommandBar() then
						if value then
							BLIZZARD:SetUpCommandBar()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end,
			},
			gm = {
				order = inc(1),
				type = "toggle",
				name = L["GM_FRAME"],
				disabled = isModuleDisabled,
				set = function(_, value)
					PrC.db.profile.blizzard.gm.enabled = value

					if not BLIZZARD:HasGMFrame() then
						if value then
							BLIZZARD:SetUpGMFrame()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end,
			},
			mail = {
				order = inc(1),
				type = "toggle",
				name = L["MAIL"],
				disabled = isModuleDisabled,
				set = function(_, value)
					PrC.db.profile.blizzard.mail.enabled = value

					if not BLIZZARD:HasMail() then
						if value then
							BLIZZARD:SetUpMail()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
						end
					end
				end,
			},
			vehicle_seat = {
				order = inc(1),
				type = "toggle",
				name = L["VEHICLE_SEAT_INDICATOR"],
				disabled = isModuleDisabled,
				set = function(_, value)
					PrC.db.profile.blizzard.vehicle_seat.enabled = value

					if not BLIZZARD:HasVehicleSeatFrame() then
						if value then
							BLIZZARD:SetUpVehicleSeatFrame()
						end
					else
						if not value then
							CONFIG:ShowStaticPopup("RELOAD_UI")
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
						name = L["ENABLE"],
						get = function()
							return PrC.db.profile.blizzard.character_frame.enabled
						end,
						set = function(_, value)
							PrC.db.profile.blizzard.character_frame.enabled = value

							if not BLIZZARD:HasCharacterFrame() then
								if value then
									BLIZZARD:SetUpCharacterFrame()
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
						order = inc(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.blizzard.character_frame, C.db.profile.blizzard.character_frame)

							BLIZZARD:UpadteCharacterFrame()
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					ilvl = {
						order = inc(2),
						type = "toggle",
						name = L["ILVL"],
					},
					enhancements = {
						order = inc(2),
						type = "toggle",
						name = L["ENCHANTS"],
					},
				},
			},
			digsite_bar = {
				order = inc(1),
				type = "group",
				name = L["DIGSITE_BAR"],
				disabled = isModuleDisabled,
				get = function(info)
					return C.db.profile.blizzard.digsite_bar[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.blizzard.digsite_bar[info[#info]] ~= value then
						C.db.profile.blizzard.digsite_bar[info[#info]] = value

						BLIZZARD:UpdateDigsiteBar()
					end
				end,
				args = {
					enabled = {
						order = reset(2),
						type = "toggle",
						name = L["ENABLE"],
						get = function()
							return PrC.db.profile.blizzard.digsite_bar.enabled
						end,
						set = function(_, value)
							PrC.db.profile.blizzard.digsite_bar.enabled = value

							if not BLIZZARD:HasDigsiteBar() then
								if value then
									BLIZZARD:SetUpDigsiteBar()
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
						order = inc(2),
						name = L["RESTORE_DEFAULTS"],
						confirm = CONFIG.ConfirmReset,
						func = function()
							CONFIG:CopySettings(D.profile.blizzard.digsite_bar, C.db.profile.blizzard.digsite_bar)

							BLIZZARD:UpdateDigsiteBar()
						end,
					},
					spacer_1 = {
						order = inc(2),
						type = "description",
						name = " ",
					},
					width = {
						order = inc(2),
						type = "range",
						name = L["WIDTH"],
						min = 128, max = 1024, step = 2,
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
						name = " ",
					},
					text = {
						order = inc(2),
						type = "group",
						name = L["TEXT"],
						inline = true,
						get = function(info)
							return C.db.profile.blizzard.digsite_bar[info[#info - 1]][info[#info]]
						end,
						set = function(info, value)
							if C.db.profile.blizzard.digsite_bar[info[#info - 1]][info[#info]] ~= value then
								C.db.profile.blizzard.digsite_bar[info[#info - 1]][info[#info]] = value

								BLIZZARD:UpdateDigsiteBar()
							end
						end,
						args = {
							size = {
								order = reset(3),
								type = "range",
								name = L["SIZE"],
								min = 8, max = 48, step = 1,
							},
						},
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
