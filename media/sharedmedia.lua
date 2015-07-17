local _, ns = ...
local M = ns.M

M.hiddenParent = CreateFrame("Frame")
M.hiddenParent:Hide()

M["font"] = STANDARD_TEXT_FONT

M["textures"] = {
	statusbar = "Interface\\AddOns\\oUF_LS\\media\\statusbar",
	button = {
		normal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal",
		normalmetal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal_bronze",
		highlight = "Interface\\AddOns\\oUF_LS\\media\\button\\highlight",
		pushed = "Interface\\AddOns\\oUF_LS\\media\\button\\pushed",
		checked = "Interface\\AddOns\\oUF_LS\\media\\button\\checked",
		flash = "Interface\\AddOns\\oUF_LS\\media\\button\\flash",
	},
}

M["colors"] = {
	exp = {
		normal = {0.11, 0.75, 0.95, 1},
		rested = {0.1, 0.4, 1, 0.7},
		bg = {0.25, 0.4, 0.35, 0.5},
	},
	classpower = {
		["CHI"] = {0, 1, 0.59},
		["SOULSHARD"] = {0.4, 0.28, 0.76},
		["HOLYPOWER"] = {0.97, 0.89, 0.47},
		["SHADOWORB"] = {0.85, 0.2, 0.7},
		["COMBO"] = {0.9, 0.3, 0.15},
		["EMBER"] = {0.9, 0.4, 0.1},
		["FULL"] = {1, 0.1, 0.15},
		["GLOW"] = {1, 0.45, 0.27},
	},
	totem = {
		[1] = {0.3, 0.8, 0.16},
		[2] = {0.8, 0.29, 0.13},
		[3] = {0.22, 0.67, 0.8},
		[4] = {0.65, 0.22, 1},
	},
	eclipse = {
		["moon"] = {0.21, 0.65, 0.95},
		["sun"] = {1, 0.5, 0.25},
	},
	icon = {
		oom	= {0.5, 0.5, 1, 0.65},
		nu	= {0.4, 0.4, 0.4, 0.65},
		oor	= {0.8, 0.1, 0.1, 0.65},
	},
	button = {
		normal = {0.57, 0.52, 0.55},
		equiped = {0, 0.8, 0},
	},
	reaction = {
		[1] = {0.9, 0.15, 0.15},
		[2] = {0.9, 0.15, 0.15},
		[3] = {0.85, 0.27, 0},
		[4] = {1, 0.80, 0.10},
		[5] = {0.15, 0.65, 0.15},
		[6] = {0.15, 0.65, 0.15},
		[7] = {0.15, 0.65, 0.15},
		[8] = {0.15, 0.65, 0.15},
	},
	power = {
		["MANA"] = {0.11, 0.75, 0.95},
		["FOCUS"] = {1, 0.5, 0.25},
		["ENERGY"] = {0.9, 0.65, 0.15},
		["RUNES"]  = {0.5, 0.5, 0.5},
		["RUNIC_POWER"] = {0.4, 0.65, 0.95},
		["SOUL_SHARDS"] = {0.5, 0.32, 0.5},
		["HOLY_POWER"] = {0.95, 0.90, 0.25},
	},
	health = {0.15, 0.65, 0.15},
	black = {0.15, 0.15, 0.15},
	red = {0.9, 0.15, 0.15},
	green = {0.15, 0.65, 0.15},
	blue = {0.41, 0.8, 0.94},
	yellow = {0.9, 0.65, 0.15},
}
