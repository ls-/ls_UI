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

function CONFIG:CreateUnitFrameRaidTargetOptions(order, unit)
	local function isRaidTargetDisabled()
		return not C.db.profile.units[unit].raid_target.enabled
	end

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
				name = L["RESET_TO_DEFAULT"],
				disabled = isRaidTargetDisabled,
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].raid_target, C.db.profile.units[unit].raid_target)

					UNITFRAMES:For(unit, "UpdateRaidTargetIndicator")
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			size = {
				order = inc(1),
				type = "range",
				name = L["SIZE"],
				min = 8, max = 64, step = 1,
				disabled = isRaidTargetDisabled,
				set = function(info, value)
					if C.db.profile.units[unit].raid_target[info[#info]] ~= value then
						C.db.profile.units[unit].raid_target[info[#info]] = value

						UNITFRAMES:For(unit, "For", "RaidTargetIndicator", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "RaidTargetIndicator", "UpdateSize")
					end
				end,
			},
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			point = {
				order = inc(1),
				type = "group",
				name = "",
				inline = true,
				disabled = isRaidTargetDisabled,
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

function CONFIG:CreateUnitFrameDebuffIconsOptions(order, unit)
	local ignoredAnchors = {
		["Health.Text"] = true,
		["Power"] = true,
		["Power.Text"] = true,
	}

	local function areDebuffIconsDisabled()
		return not C.db.profile.units[unit].debuff.enabled
	end

	return {
		order = order,
		type = "group",
		name = L["DISPELLABLE_DEBUFF_ICONS"],
		args = {
			enabled = {
				order = reset(1),
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
				order = inc(1),
				name = L["RESET_TO_DEFAULT"],
				disabled = areDebuffIconsDisabled,
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].debuff, C.db.profile.units[unit].debuff)

					UNITFRAMES:For(unit, "UpdateDebuffIndicator")
				end,
			},
			preview = {
				type = "execute",
				order = inc(1),
				name = L["PREVIEW"],
				disabled = areDebuffIconsDisabled,
				func = function()
					UNITFRAMES:For(unit, "For", "DebuffIndicator", "Preview")
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			point = {
				order = inc(1),
				type = "group",
				name = "",
				inline = true,
				disabled = areDebuffIconsDisabled,
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
						order = reset(2),
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS,
					},
					anchor = {
						order = inc(2),
						type = "select",
						name = L["ANCHOR"],
						values = CONFIG:GetRegionAnchors(ignoredAnchors),
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

local PORTRAIT_STYLES = {
	["2D"] = "2D",
	["3D"] = "3D",
	["Class"] = L["CLASS"],
}

local PORTRAIT_POSITIONS = {
	["Left"] = L["LEFT"],
	["Right"] = L["RIGHT"],
}

function CONFIG:CreateUnitFramePortraitOptions(order, unit)
	local function isPortraitDisabled()
		return not C.db.profile.units[unit].portrait.enabled
	end

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
				name = L["RESET_TO_DEFAULT"],
				disabled = isPortraitDisabled,
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].portrait, C.db.profile.units[unit].portrait)

					UNITFRAMES:For(unit, "UpdatePortrait")
					UNITFRAMES:For(unit, "UpdateClassPower")
					UNITFRAMES:For(unit, "UpdateRunes")
				end,
			},
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			style = {
				order = inc(1),
				type = "select",
				name = L["STYLE"],
				values = PORTRAIT_STYLES,
				disabled = isPortraitDisabled,
			},
			position = {
				order = inc(1),
				type = "select",
				name = L["POSITION"],
				values = PORTRAIT_POSITIONS,
				disabled = isPortraitDisabled,
			},
			scale = {
				type = "range",
				name = L["SCALE"],
				min = 1, max = 4, step = 0.01, bigStep = 0.1,
				isPercent = true,
				disabled = isPortraitDisabled,
				hidden = function()
					return C.db.profile.units[unit].portrait.style ~= "3D"
				end,
			},
		},
	}
end
