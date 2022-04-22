local _, CONFIG = ...

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)
local UNITFRAMES = P:GetModule("UnitFrames")

local offsets = {"", "   ", "      "}
local function d(c, o, v)
	print(offsets[o].."|cff"..c..v.."|r")
end

local orders = {0, 0, 0}

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

function CONFIG:CreateUnitFrameRaidTargetPanel(order, unit)
	return {
		order = order,
		type = "group",
		name = L["RAID_ICON"],
		get = function(info)
			return C.db.profile.units[unit].raid_target[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].raid_target[info[#info]] ~= value then
				C.db.profile.units[unit].raid_target[info[#info]] = value

				UNITFRAMES:For(unit, "UpdateRaidTargetIndicator")
			end
		end,
		args = {
			enabled = {
				order = reset(1),
				type = "toggle",
				name = L["ENABLE"],
			},
			reset = {
				type = "execute",
				order = inc(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].raid_target, C.db.profile.units[unit].raid_target)
					UNITFRAMES:For(unit, "UpdateRaidTargetIndicator")
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			size = {
				order = inc(1),
				type = "range",
				name = L["SIZE"],
				min = 8, max = 64, step = 1,
				set = function(info, value)
					if C.db.profile.units[unit].raid_target[info[#info]] ~= value then
						C.db.profile.units[unit].raid_target[info[#info]] = value

						UNITFRAMES:For(unit, "For", "RaidTargetIndicator", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "RaidTargetIndicator", "UpdateSize")
					end
				end,
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			point = {
				order = inc(1),
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].raid_target.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].raid_target.point1[info[#info]] ~= value then
						C.db.profile.units[unit].raid_target.point1[info[#info]] = value

						UNITFRAMES:For(unit, "For", "RaidTargetIndicator", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "RaidTargetIndicator", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = reset(2),
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS,
					},
					rP = {
						order = inc(2),
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
					},
					x = {
						order = inc(2),
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = inc(2),
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
				},
			},
		},
	}
end

function CONFIG:CreateUnitFrameDebuffIconsPanel(order, unit)
	local ignoredAnchors = {
		["Health.Text"] = true,
		["Power"] = true,
		["Power.Text"] = true,
	}

	return {
		order = order,
		type = "group",
		name = L["DISPELLABLE_DEBUFF_ICONS"],
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = L["ENABLE"],
				get = function()
					return C.db.profile.units[unit].debuff.enabled
				end,
				set = function(_, value)
					if C.db.profile.units[unit].debuff.enabled ~= value then
						C.db.profile.units[unit].debuff.enabled = value

						UNITFRAMES:For(unit, "UpdateDebuffIndicator")
					end
				end,
			},
			reset = {
				type = "execute",
				order = 2,
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].debuff, C.db.profile.units[unit].debuff)
					UNITFRAMES:For(unit, "UpdateDebuffIndicator")
				end,
			},
			preview = {
				type = "execute",
				order = 3,
				name = L["PREVIEW"],
				func = function()
					UNITFRAMES:For(unit, "For", "DebuffIndicator", "Preview")
				end,
			},
			spacer_1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			point = {
				order = 10,
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].debuff.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].debuff.point1[info[#info]] ~= value then
						C.db.profile.units[unit].debuff.point1[info[#info]] = value

						UNITFRAMES:For(unit, "For", "DebuffIndicator", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "DebuffIndicator", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = 1,
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS,
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["ANCHOR"],
						values = CONFIG:GetRegionAnchors(ignoredAnchors),
					},
					rP = {
						order = 3,
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
					},
					x = {
						order = 4,
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
					},
					y = {
						order = 5,
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
					},
				},
			},
		},
	}
end

function CONFIG:CreateUnitFramePortraitPanel(order, unit)
	return {
		order = order,
		type = "group",
		name = L["PORTRAIT"],
		get = function(info)
			return C.db.profile.units[unit].portrait[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].portrait[info[#info]] ~= value then
				C.db.profile.units[unit].portrait[info[#info]] = value

				UNITFRAMES:For(unit, "UpdatePortrait")
				UNITFRAMES:For(unit, "UpdateClassPower")
				UNITFRAMES:For(unit, "UpdateRunes")
			end
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
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].portrait, C.db.profile.units[unit].portrait)
					UNITFRAMES:For(unit, "UpdatePortrait")
					UNITFRAMES:For(unit, "UpdateClassPower")
					UNITFRAMES:For(unit, "UpdateRunes")
				end,
			},
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			style = {
				order = inc(1),
				type = "select",
				name = L["STYLE"],
				values = CONFIG.PORTRAIT_STYLES,
			},
			position = {
				order = inc(1),
				type = "select",
				name = L["POSITION"],
				values = CONFIG.PORTRAIT_POSITIONS,
			},
		},
	}
end
