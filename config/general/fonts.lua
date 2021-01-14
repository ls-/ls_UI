local _, ns = ...
local E, C, M, L, P, D, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D, ns.oUF
local CONFIG = P:GetModule("Config")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
]]

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

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

function CONFIG:CreateGeneralFontsPanel(order)
	C.options.args.general.args.fonts = {
		order = order,
		type = "group",
		childGroups = "tree",
		name = L["FONTS"],
		get = function(info)
			return C.db.global.fonts[info[#info - 1]][info[#info]]
		end,
		set = function(info, value)
			if C.db.global.fonts[info[#info - 1]][info[#info]] ~= value then
				C.db.global.fonts[info[#info - 1]][info[#info]] = value

				E.FontStrings:UpdateAll(info[#info - 1])
			end
		end,
		args = {
			cooldown = {
				order = reset(1),
				type = "group",
				inline = true,
				name = "",
				args = {
					font = {
						order = reset(2),
						type = "select",
						name = L["COOLDOWNS"],
						dialogControl = "LSM30_Font",
						values = LSM:HashTable("font"),
						get = function()
							return LSM:IsValid("font", C.db.global.fonts.cooldown.font)
								and C.db.global.fonts.cooldown.font or LSM:GetDefault("font")
						end,
					},
					outline = {
						order = inc(2),
						type = "toggle",
						name = L["OUTLINE"],
					},
					shadow = {
						order = inc(2),
						type = "toggle",
						name = L["SHADOW"],
					},
				},
			},
			button = {
				order = inc(1),
				type = "group",
				inline = true,
				name = "",
				args = {
					font = {
						order = reset(2),
						type = "select",
						name = L["BUTTONS"],
						dialogControl = "LSM30_Font",
						values = LSM:HashTable("font"),
						get = function()
							return LSM:IsValid("font", C.db.global.fonts.button.font)
								and C.db.global.fonts.button.font or LSM:GetDefault("font")
						end,
					},
					outline = {
						order = inc(2),
						type = "toggle",
						name = L["OUTLINE"],
					},
					shadow = {
						order = inc(2),
						type = "toggle",
						name = L["SHADOW"],
					},
				},
			},
			unit = {
				order = inc(1),
				type = "group",
				inline = true,
				name = "",
				args = {
					font = {
						order = reset(2),
						type = "select",
						name = L["UNIT_FRAME"],
						dialogControl = "LSM30_Font",
						values = LSM:HashTable("font"),
						get = function()
							return LSM:IsValid("font", C.db.global.fonts.unit.font)
								and C.db.global.fonts.unit.font or LSM:GetDefault("font")
						end,
					},
					outline = {
						order = inc(2),
						type = "toggle",
						name = L["OUTLINE"],
					},
					shadow = {
						order = inc(2),
						type = "toggle",
						name = L["SHADOW"],
					},
				},
			},
			statusbar = {
				order = inc(1),
				type = "group",
				inline = true,
				name = "",
				args = {
					font = {
						order = reset(2),
						type = "select",
						name = L["PROGRESS_BARS"],
						dialogControl = "LSM30_Font",
						values = LSM:HashTable("font"),
						get = function()
							return LSM:IsValid("font", C.db.global.fonts.statusbar.font)
								and C.db.global.fonts.statusbar.font or LSM:GetDefault("font")
						end,
					},
					outline = {
						order = inc(2),
						type = "toggle",
						name = L["OUTLINE"],
					},
					shadow = {
						order = inc(2),
						type = "toggle",
						name = L["SHADOW"],
					},
				},
			},
		},
	}
end
