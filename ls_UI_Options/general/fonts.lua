-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Libs
local LSM = LibStub("LibSharedMedia-3.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF, CONFIG = unpack(ls_UI)

local orders = {0, 0, 0}

local function reset(order)
	orders[order] = 1
	return orders[order]
end

local function inc(order)
	orders[order] = orders[order] + 1
	return orders[order]
end

local function getOptions(order, name)
	local temp = {
		order = order,
		type = "group",
		inline = true,
		name = "",
		args = {
			font = {
				order = reset(2),
				type = "select",
				name = name,
				width = 1.25,
				dialogControl = "LSM30_Font",
				values = LSM:HashTable("font"),
				get = function(info)
					return LSM:IsValid("font", C.db.global.fonts[info[#info - 1]].font)
						and C.db.global.fonts[info[#info - 1]].font or LSM:GetDefault("font")
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
	}

	return temp
end

function CONFIG:GetFontsOptions(order)
	self.options.args.general.args.fonts = {
		order = order,
		type = "group",
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
			cooldown = getOptions(reset(1), L["COOLDOWNS"]),
			spacer_1 = CONFIG:CreateSpacer(inc(1)),
			button = getOptions(inc(1), L["BUTTONS"]),
			spacer_2 = CONFIG:CreateSpacer(inc(1)),
			unit = getOptions(inc(1), L["UNIT_FRAME"]),
			spacer_3 = CONFIG:CreateSpacer(inc(1)),
			statusbar = getOptions(inc(1), L["PROGRESS_BARS"]),
		},
	}
end
