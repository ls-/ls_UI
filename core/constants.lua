local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF

M.font = STANDARD_TEXT_FONT

M.HiddenParent = CreateFrame("Frame", "LSHiddenParent")
M.HiddenParent:Hide()

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

oUF.colors.power["MANA"] = {0.15, 0.75, 0.95}
oUF.colors.power["FOCUS"] = {1, 0.5, 0.25}
oUF.colors.power["ENERGY"] = {0.9, 0.65, 0.15}
oUF.colors.power["CHI"] = {0.4, 0.95, 0.62}
oUF.colors.power["RUNIC_POWER"] = {0.4, 0.65, 1}
oUF.colors.power["SOUL_SHARDS"] = {0.5, 0.3, 0.75}
oUF.colors.power["ECLIPSE"] = {
	negative = {0.3, 0.52, 0.9},
	positive = {1, 0.5, 0.25},
}
oUF.colors.power["HOLY_POWER"] = {0.95, 0.9, 0.25}

local colors = E:CopyTable(oUF.colors, {})

colors.power["SHADOW_ORBS"] = {0.85, 0.2, 0.7}
colors.power["COMBO_POINTS"] = {0.9, 0.3, 0.15}
colors.power["TOTEMS"] = {
	[1] = {0.3, 0.8, 0.16},
	[2] = {0.8, 0.29, 0.13},
	[3] = {0.22, 0.67, 0.8},
	[4] = {0.65, 0.22, 1},
}
colors.power["STAGGER"] = {0.52, 1, 0.52, 1, 0.98, 0.72, 1, 0.42, 0.42}

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
	["damageabsorb"] = {0.85, 0.85, 0.9},
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
colors.dodgerblue = {0.12, 0.56, 1}
colors.jade = {0, 0.66, 0.42}

colors.gradient = {
	["GYR"] = {0.15, 0.65, 0.15, 0.9, 0.65, 0.15, 0.9, 0.15, 0.15},
	["RYG"] = {0.9, 0.15, 0.15, 0.9, 0.65, 0.15, 0.15, 0.65, 0.15},
}

colors.threat = {}
for i = 1, 3 do
	colors.threat[i] = {GetThreatStatusColor(i)}
end

M.colors = colors

local textures = {
	inlineicons = {
		["QUEST"] = "|TInterface\\AddOns\\oUF_LS\\media\\icons:14:14:0:0:128:64:82:100:22:40|t",
		["TANK"] = "|TInterface\\AddOns\\oUF_LS\\media\\icons:14:14:0:0:128:64:62:80:2:20|t",
		["HEALER"] = "|TInterface\\AddOns\\oUF_LS\\media\\icons:14:14:0:0:128:64:42:60:2:20|t",
		["DAMAGER"] = "|TInterface\\AddOns\\oUF_LS\\media\\icons:14:14:0:0:128:64:22:40:2:20|t",
		["LEADER"] = "|TInterface\\AddOns\\oUF_LS\\media\\icons:14:14:0:0:128:64:2:20:2:20|t",
		["ALLIANCE"] = "|TInterface\\AddOns\\oUF_LS\\media\\icons:14:14:0:0:128:64:22:40:22:40|t",
		["HORDE"] = "|TInterface\\AddOns\\oUF_LS\\media\\icons:14:14:0:0:128:64:2:20:22:40|t",
		["FFA"] = "|TInterface\\AddOns\\oUF_LS\\media\\icons:14:14:0:0:128:64:42:60:22:40|t",
	},
	button = {
		normal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal",
		normalmetal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal_bronze",
		highlight = "Interface\\AddOns\\oUF_LS\\media\\button\\highlight",
		pushed = "Interface\\AddOns\\oUF_LS\\media\\button\\pushed",
		checked = "Interface\\AddOns\\oUF_LS\\media\\button\\checked",
		flash = "Interface\\AddOns\\oUF_LS\\media\\button\\flash",
	},
}

M.textures = textures
