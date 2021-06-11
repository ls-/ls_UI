local _, ns = ...
local E, C, M, L, P, D, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D, ns.oUF
local CONFIG = P:GetModule("Config")
local UNITFRAMES = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local offsets = {"", "   ", "      "}
local function d(c, o, v)
	print(offsets[o].."|cff"..c..v.."|r")
end

local orders = {0}

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

local function isFadingDisabled(info)
	return not C.db.profile.units[info[#info - 2]].fade.enabled
end

function CONFIG:CreateUnitFrameFadingPanel(order, unit)
	return {
		order = order,
		type = "group",
		name = L["FADING"],
		get = function(info)
			return C.db.profile.units[unit].fade[info[#info]]
		end,
		set = function(info, value)
			C.db.profile.units[unit].fade[info[#info]] = value
			UNITFRAMES:For(unit, "UpdateConfig")
			UNITFRAMES:For(unit, "UpdateFading")
		end,
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
			},
			reset = {
				order = inc(1),
				type = "execute",
				name = L["RESTORE_DEFAULTS"],
				disabled = isFadingDisabled,
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].fade, C.db.profile.units[unit].fade, {enabled = true})
					UNITFRAMES:For(unit, "UpdateConfig")
					UNITFRAMES:For(unit, "UpdateFading")
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			combat = {
				order = inc(1),
				type = "toggle",
				name = L["OOC"],
				disabled = isFadingDisabled,
			},
			target = {
				order = inc(1),
				type = "toggle",
				name = L["TARGET"],
				disabled = isFadingDisabled,
			},
			in_duration = {
				order = inc(1),
				type = "range",
				name = L["FADE_IN_DURATION"],
				disabled = isFadingDisabled,
				min = 0.05, max = 1, step = 0.05,
			},
			out_delay = {
				order = inc(1),
				type = "range",
				name = L["FADE_OUT_DELAY"],
				disabled = isFadingDisabled,
				min = 0, max = 2, step = 0.05,
			},
			out_duration = {
				order = inc(1),
				type = "range",
				name = L["FADE_OUT_DURATION"],
				disabled = isFadingDisabled,
				min = 0.05, max = 1, step = 0.05,
			},
			min_alpha = {
				order = inc(1),
				type = "range",
				name = L["MIN_ALPHA"],
				disabled = isFadingDisabled,
				min = 0, max = 1, step = 0.05,
			},
			max_alpha = {
				order = inc(1),
				type = "range",
				name = L["MAX_ALPHA"],
				disabled = isFadingDisabled,
				min = 0, max = 1, step = 0.05
			},
		},
	}
end
