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

function CONFIG:CreateUnitFrameNameOptions(order, unit)
	local function isSecondaryAnchorDisabled()
		return C.db.profile.units[unit].name.point2.p == ""
	end

	return {
		order = order,
		type = "group",
		name = L["NAME"],
		get = function(info)
			return C.db.profile.units[unit].name[info[#info]]
		end,
		set = function(info, value)
			if C.db.profile.units[unit].name[info[#info]] ~= value then
				C.db.profile.units[unit].name[info[#info]] = value

				UNITFRAMES:For(unit, "For", "Name", "UpdateConfig")
				UNITFRAMES:For(unit, "For", "Name", "UpdateFonts")
			end
		end,
		args = {
			reset = {
				type = "execute",
				order = reset(1),
				name = L["RESTORE_DEFAULTS"],
				confirm = CONFIG.ConfirmReset,
				func = function()
					CONFIG:CopySettings(D.profile.units[unit].name, C.db.profile.units[unit].name)
					UNITFRAMES:For(unit, "UpdateName")
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
				min = 8, max = 48, step = 1,
			},
			h_alignment = {
				order = inc(1),
				type = "select",
				name = L["TEXT_HORIZ_ALIGNMENT"],
				values = CONFIG.H_ALIGNMENTS,
			},
			v_alignment = {
				order = inc(1),
				type = "select",
				name = L["TEXT_VERT_ALIGNMENT"],
				values = CONFIG.V_ALIGNMENTS,
				disabled = isSecondaryAnchorDisabled,
			},
			word_wrap = {
				order = inc(1),
				type = "toggle",
				name = L["WORD_WRAP"],
			},
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			point1 = {
				order = inc(1),
				type = "group",
				name = "",
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].name.point1[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].name.point1[info[#info]] ~= value then
						C.db.profile.units[unit].name.point1[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Name", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Name", "UpdatePoints")
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
						values = CONFIG:GetRegionAnchors(),
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
			spacer_3 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			point2 = {
				order = inc(1),
				type = "group",
				name = L["SECOND_ANCHOR"],
				inline = true,
				get = function(info)
					return C.db.profile.units[unit].name.point2[info[#info]]
				end,
				set = function(info, value)
					if C.db.profile.units[unit].name.point2[info[#info]] ~= value then
						C.db.profile.units[unit].name.point2[info[#info]] = value

						UNITFRAMES:For(unit, "For", "Name", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Name", "UpdatePoints")
					end
				end,
				args = {
					p = {
						order = reset(2),
						type = "select",
						name = L["POINT"],
						desc = L["POINT_DESC"],
						values = CONFIG.POINTS_EXT,
					},
					anchor = {
						order = inc(2),
						type = "select",
						name = L["ANCHOR"],
						values = CONFIG:GetRegionAnchors(),
						disabled = isSecondaryAnchorDisabled,
					},
					rP = {
						order = inc(2),
						type = "select",
						name = L["RELATIVE_POINT"],
						desc = L["RELATIVE_POINT_DESC"],
						values = CONFIG.POINTS,
						disabled = isSecondaryAnchorDisabled,
					},
					x = {
						order = inc(2),
						type = "range",
						name = L["X_OFFSET"],
						min = -128, max = 128, step = 1,
						disabled = isSecondaryAnchorDisabled,
					},
					y = {
						order = inc(2),
						type = "range",
						name = L["Y_OFFSET"],
						min = -128, max = 128, step = 1,
						disabled = isSecondaryAnchorDisabled,
					},
				},
			},
			spacer_4 = {
				order = inc(1),
				type = "description",
				name = " ",
			},
			tag = {
				order = inc(1),
				type = "input",
				width = "full",
				name = L["FORMAT"],
				desc = L["NAME_FORMAT_DESC"],
				get = function()
					return C.db.profile.units[unit].name.tag:gsub("\124", "\124\124")
				end,
				set = function(_, value)
					value = value:gsub("\124\124+", "\124")
					if C.db.profile.units[unit].name.tag ~= value then
						C.db.profile.units[unit].name.tag = value

						UNITFRAMES:For(unit, "For", "Name", "UpdateConfig")
						UNITFRAMES:For(unit, "For", "Name", "UpdateTags")
					end
				end,
			},
		},
	}
end
