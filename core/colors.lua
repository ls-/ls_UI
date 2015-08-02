local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF

oUF.colors.health = {0.15, 0.65, 0.15}

oUF.colors.reaction = {
	[1] = {0.9, 0.15, 0.15},
	[2] = {0.9, 0.15, 0.15},
	[3] = {0.85, 0.27, 0},
	[4] = {0.9, 0.65, 0.15},
	[5] = {0.15, 0.65, 0.15},
	[6] = {0.15, 0.65, 0.15},
	[7] = {0.15, 0.65, 0.15},
	[8] = {0.15, 0.65, 0.15},
}

oUF.colors.power = {
	["MANA"] = {0.11, 0.75, 0.95},
	["FOCUS"] = {1, 0.5, 0.25},
	["ENERGY"] = {0.9, 0.65, 0.15},
	["RUNES"]  = {0.5, 0.5, 0.5},
	["RUNIC_POWER"] = {0.4, 0.65, 0.95},
	["SOUL_SHARDS"] = {0.5, 0.32, 0.5},
	["HOLY_POWER"] = {0.95, 0.90, 0.25},
}

local colors = E:CopyTable(oUF.colors, {})

colors.classpower = {
	["CHI"] = {0, 1, 0.59},
	["SOULSHARD"] = {0.4, 0.28, 0.76},
	["HOLYPOWER"] = {0.97, 0.89, 0.47},
	["SHADOWORB"] = {0.85, 0.2, 0.7},
	["COMBO"] = {0.9, 0.3, 0.15},
	["EMBER"] = {0.9, 0.4, 0.1},
	["FULL"] = {1, 0.1, 0.15},
	["GLOW"] = {1, 0.45, 0.27},
	["ECLIPSE"] = {
		["MOON"] = {0.21, 0.65, 0.95},
		["SUN"] = {1, 0.5, 0.25},
	},
	["TOTEM"] = {
		[1] = {0.3, 0.8, 0.16},
		[2] = {0.8, 0.29, 0.13},
		[3] = {0.22, 0.67, 0.8},
		[4] = {0.65, 0.22, 1},
	},
}

colors.icon = {
	oom	= {0.5, 0.5, 1, 0.65},
	nu	= {0.4, 0.4, 0.4, 0.65},
	oor	= {0.8, 0.1, 0.1, 0.65},
}

colors.experience = {0.11, 0.75, 0.95}

colors.healprediction = {
	["myheal"] = {0, 0.827, 0.765},
	["otherheal"] = {0.0, 0.631, 0.557},
	["healabsorb"] = {0.9, 0.1, 0.3},
	["damageabsorb"] = {0, 0.7, 0.95},
}

colors.red = {0.9, 0.15, 0.15}
colors.green = {0.15, 0.65, 0.15}
colors.blue = {0.41, 0.8, 0.94}
colors.yellow = {0.9, 0.65, 0.15}
colors.lightgray = {0.85, 0.85, 0.85}
colors.gray = {0.6, 0.6, 0.6}
colors.darkgray = {0.15, 0.15, 0.15}
colors.indigo = {0.36, 0.46, 0.8}
colors.orange = {0.9, 0.4, 0.1}

colors.gradient = {
	["GYR"] = {0.15, 0.65, 0.15, 0.9, 0.65, 0.15, 0.9, 0.15, 0.15},
	["RYG"] = {0.9, 0.15, 0.15, 0.9, 0.65, 0.15, 0.15, 0.65, 0.15},
}

colors.threat = {}
for i = 1, 3 do
	colors.threat[i] = {GetThreatStatusColor(i)}
end

M.colors = colors
