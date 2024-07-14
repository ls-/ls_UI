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
	return {
		order = order,
		type = "select",
		name = name,
		width = 1.25,
		dialogControl = "LSM30_Statusbar",
		values = LSM:HashTable("statusbar"),
	}
end

function CONFIG:GetTexturesOptions(order)
	self.options.args.general.args.textures = {
		order = order,
		type = "group",
		name = L["TEXTURES"],
		get = function(info)
			return LSM:IsValid("statusbar", C.db.global.textures.statusbar[info[#info]])
				and C.db.global.textures.statusbar[info[#info]] or LSM:GetDefault("statusbar")
		end,
		set = function(info, value)
			if C.db.global.textures.statusbar[info[#info]] ~= value then
				C.db.global.textures.statusbar[info[#info]] = value

				E.StatusBars:UpdateAll(info[#info])
			end
		end,
		args = {
			health = getOptions(reset(1), L["HEALTH"]),
			spacer_1 = {
				order = inc(1),
				type = "description",
				name = "",
			},
			castbar = getOptions(inc(1), L["CASTBAR"]),
			spacer_2 = {
				order = inc(1),
				type = "description",
				name = "",
			},
			power = getOptions(inc(1), L["POWER"]),
			spacer_3 = {
				order = inc(1),
				type = "description",
				name = "",
			},
			xpbar = getOptions(inc(1), L["XP_BAR"]),
			spacer_4 = {
				order = inc(1),
				type = "description",
				name = "",
			},
			other = getOptions(inc(1), L["OTHER"]),
		},
	}
end
