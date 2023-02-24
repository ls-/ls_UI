local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
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

local function isFadingDisabled(info)
	return not C.db.profile.units[info[#info - 2]].fade.enabled
end

function CONFIG:CreateUnitFrameFadingOptions(order, unit)
	local temp = {
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
				name = L["COMBAT"],
				disabled = isFadingDisabled,
			},
			target = {
				order = inc(1),
				type = "toggle",
				name = L["TARGET"],
				disabled = isFadingDisabled,
			},
			health = {
				order = inc(1),
				type = "toggle",
				name = L["HEALTH"],
				desc = L["HEALTH_FADING_DESC"],
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

	if unit == "player" then
		temp.set = function(info, value)
			C.db.profile.units.player.fade[info[#info]] = value

			UNITFRAMES:For("player", "UpdateConfig")
			UNITFRAMES:For("player", "UpdateFading")
			UNITFRAMES:For("pet", "UpdateConfig")
			UNITFRAMES:For("pet", "UpdateFading")
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units.player.fade, C.db.profile.units.player.fade, {enabled = true})
			UNITFRAMES:For("player", "UpdateConfig")
			UNITFRAMES:For("player", "UpdateFading")
			UNITFRAMES:For("pet", "UpdateConfig")
			UNITFRAMES:For("pet", "UpdateFading")
		end
	elseif unit == "focus" then
		temp.set = function(info, value)
			C.db.profile.units.focus.fade[info[#info]] = value

			UNITFRAMES:For("focus", "UpdateConfig")
			UNITFRAMES:For("focus", "UpdateFading")
			UNITFRAMES:For("focustarget", "UpdateConfig")
			UNITFRAMES:For("focustarget", "UpdateFading")
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units.focus.fade, C.db.profile.units.focus.fade, {enabled = true})
			UNITFRAMES:For("focus", "UpdateConfig")
			UNITFRAMES:For("focus", "UpdateFading")
			UNITFRAMES:For("focustarget", "UpdateConfig")
			UNITFRAMES:For("focustarget", "UpdateFading")
		end
	elseif unit == "target" then
		temp.set = function(info, value)
			C.db.profile.units.target.fade[info[#info]] = value

			UNITFRAMES:For("target", "UpdateConfig")
			UNITFRAMES:For("target", "UpdateFading")
			UNITFRAMES:For("targettarget", "UpdateConfig")
			UNITFRAMES:For("targettarget", "UpdateFading")
		end

		temp.args.reset.func = function()
			CONFIG:CopySettings(D.profile.units.target.fade, C.db.profile.units.target.fade, {enabled = true})
			UNITFRAMES:For("target", "UpdateConfig")
			UNITFRAMES:For("target", "UpdateFading")
			UNITFRAMES:For("targettarget", "UpdateConfig")
			UNITFRAMES:For("targettarget", "UpdateFading")
		end
	end

	return temp
end
