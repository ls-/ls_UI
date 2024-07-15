-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)
local UNITFRAMES = P:GetModule("UnitFrames")

local orders = {}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local ICON_POSITIONS = {
	["NONE"] = L["NONE"],
	["LEFT"] = L["LEFT"],
	["RIGHT"] = L["RIGHT"],
}

function CONFIG:CreateUnitFrameCastbarOptions(order, unit)
	local temp = {
		order = order,
		type = "group",
		name = L["CASTBAR"],
		get = function(info)
			return C.db.profile.units[unit].castbar[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].castbar[info[#info]] ~= value then
				C.db.profile.units[unit].castbar[info[#info]] = value

				UNITFRAMES:For(unit, "UpdateCastbar")
			end
		end,
		args = {
			blizz_enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE_BLIZZARD_CASTBAR"],
				get = function()
					return C.db.profile.units[unit].castbar.blizz_enabled
				end,
				set = function(_, value)
					C.db.profile.units[unit].castbar.blizz_enabled = value

					UNITFRAMES:UpdateBlizzCastbars()
				end,
				disabled = function()
					return C.db.profile.units[unit].castbar.enabled
				end,
			},
			enabled = {
				order = inc(1),
				type = "toggle",
				name = L["ENABLE"],
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESET_TO_DEFAULT"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].castbar, C.db.profile.units[unit].castbar)

					UNITFRAMES:For(unit, "UpdateCastbar")
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			latency = {
				order = inc(1),
				type = "toggle",
				name = L["LATENCY"],
				set = function(_, value)
					if C.db.profile.units[unit].castbar.latency ~= value then
						C.db.profile.units[unit].castbar.latency = value

						UNITFRAMES:For(unit, "For", "Castbar", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Castbar", "UpdateLatency")
					end
				end,
			},
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			detached = {
				order = inc(1),
				type = "toggle",
				name = L["DETACH_FROM_FRAME"],
			},
			width_override = {
				order = inc(1),
				type = "range",
				name = L["WIDTH_OVERRIDE"],
				desc = L["WIDTH_OVERRIDE_DESC"],
				min = 0, max = 1024, step = 2,
				softMin = 96,
				disabled = function()
					return not C.db.profile.units[unit].castbar.detached
				end,
				set = function(info, value)
					if C.db.profile.units[unit].castbar.width_override ~= value then
						if value < info.option.softMin then
							value = info.option.min
						end

						C.db.profile.units[unit].castbar.width_override = value

						UNITFRAMES:For(unit, "For", "Castbar", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Castbar", "UpdateSize")
					end
				end,
			},
			height = {
				order = inc(1),
				type = "range",
				name = L["HEIGHT"],
				min = 8, max = 32, step = 1, bigStep = 2,
				set = function(_, value)
					if C.db.profile.units[unit].castbar.height ~= value then
						C.db.profile.units[unit].castbar.height = value

						UNITFRAMES:For(unit, "For", "Castbar", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Castbar", "UpdateSize")
						UNITFRAMES:For(unit, "For", "Castbar", "UpdateIcon")
					end
				end,
			},
			icon = {
				order = inc(1),
				type = "select",
				name = L["ICON"],
				values = ICON_POSITIONS,
				get = function()
					return C.db.profile.units[unit].castbar.icon.position
				end,
				set = function(_, value)
					if C.db.profile.units[unit].castbar.icon.position ~= value then
						C.db.profile.units[unit].castbar.icon.position = value

						UNITFRAMES:For(unit, "For", "Castbar", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Castbar", "UpdateIcon")
					end
				end,
			},
			text = {
				order = inc(1),
				type = "range",
				name = L["BAR_TEXT"],
				min = 8, max = 32, step = 1,
				get = function()
					return C.db.profile.units[unit].castbar.text.size
				end,
				set = function(_, value)
					if C.db.profile.units[unit].castbar.text.size ~= value then
						C.db.profile.units[unit].castbar.text.size = value

						UNITFRAMES:For(unit, "For", "Castbar", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Castbar", "UpdateFonts")
					end
				end,
			},
		},
	}

	if unit ~= "player" then
		temp.args.blizz_enabled = nil
		temp.args.latency = nil
		temp.args.spacer_2 = nil
	end

	return temp
end
