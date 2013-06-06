local _, ns = ...
local cfg = CreateFrame("Frame")

cfg.globals = {
	scale = 1, -- global scale
	textures = {
		statusbar = "Interface\\AddOns\\oUF_LS\\media\\statusbar",
		button_normal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal",
		button_highlight = "Interface\\AddOns\\oUF_LS\\media\\button\\highlight",
		button_pushed = "Interface\\AddOns\\oUF_LS\\media\\button\\pushed",
		button_checked = "Interface\\AddOns\\oUF_LS\\media\\button\\checked",
	},
	backdrop = {
		bgFile		= "", 
		edgeFile	= "Interface\\AddOns\\oUF_LS\\media\\button\\outer_shadow",
		tile		= true,
		tileSize	= 32, 
		edgeSize	= 4, 
		insets		= { left = 6, right	= 6, top = 6, bottom = 6 },
	}, 
	colors = {
		reaction = {
			[1] = { 0.9, 0.15, 0.15 },
			[2] = { 0.9, 0.15, 0.15 },
			[3] = { 0.85, 0.27, 0 },
			[4] = { 1, 0.80, 0.10 },
			[5] = { 0.15, 0.65, 0.15 },
			[6] = { 0.15, 0.65, 0.15 },
			[7] = { 0.15, 0.65, 0.15 },
			[8] = { 0.15, 0.65, 0.15 },
		},
		power = {
			["MANA"] 		= { 0.11, 0.75, 0.95 },
			["RAGE"] 		= { 1, 0, 0 },
			["FOCUS"] 		= { 1, 0.5, 0.25 },
			["ENERGY"] 		= { 1, 0.75, 0.1 },
			["UNUSED"] 		= {},
			["RUNES"] 		= { 0.5, 0.5, 0.5 },
			["RUNIC_POWER"] = { 0.4, 0.65, 0.95 },
			["SOUL_SHARDS"] = { 0.5, 0.32, 0.5 },
			["ECLIPSE"] 	= { nil,nil,nil},
			["HOLY_POWER"] 	= { 0.95, 0.90, 0.25 },
			["AMMOSLOT"] 	= { 0.8, 0.6, 0 },
			["FUEL"]		= { 0, 0.55, 0.5 },
		},
		classpower = {
			["CHI"] 		= { 0, 1, 0.59 },
			["SOULSHARD"] 	= { 0.4, 0.28, 0.76 },
			["HOLYPOWER"]	= { 1, 0.96, 0.41 },
			["SHADOWORB"]	= { 0.85, 0.2, 0.7 },
			["COMBO"]		= { 0.9, 0.75, 0.3 },
			["EMBER"]		= { 0.9, 0.4, 0.1 },
			["FULL"]		= { 1, 0.1, 0.15 },
		},
		health = { 
			normal	= { 0.15, 0.65, 0.15 },
			alt 	= { 0.9, 0.1, 0.1 },
		},
		castbar = {
			bar	= {0.15, 0.15, 0.15 },
			bg	= {0.96, 0.7, 0 },
		},
		totem = {
			[1] = {0.3, 0.8, 0.16 },
			[2] = {0.8, 0.29, 0.13 },
			[3] = {0.22, 0.67, 0.8 },
			[4] = {0.65, 0.22, 1 },
		},
		eclipse = {
			["moon"]	= { 0.21, 0.65, 0.95 },
			["sun"]		= { 1, 0.5, 0.25 },
		},
		btnstate = {
			normal	= { 0.37, 0.3, 0.3 },
			equiped	= { 0.1, 0.5, 0.1 },
		},
		infobar	= {
			black	= { 0.15, 0.15, 0.15 },
			red		= { 0.9, 0.1, 0.1 },
			green	= { 0.15, 0.65, 0.15 },
			blue	= { 0.41, 0.8, 0.94 }, 
			yellow	= { 1, 0.75, 0.1},
		},
		icon = {
			oom	= { 0.5, 0.5, 1 },
			nu	= { 0.4, 0.4, 0.4 },
			oor	= { 0.8, 0.1, 0.1 },
		},
	},
}
cfg.units = {
	player = {
		pos = { "BOTTOM", "UIParent", "BOTTOM", -306 , 65 },
		icons = {
			resting = { 32, "CENTER", 55, 82 },
			pvp = { 42, "CENTER", -55, 82 },
			leader = { 32, "TOP", 0, 40, "Interface\\AddOns\\oUF_LS\\media\\icon_leader" },
		},
		castbar = {
			fontsize = 12,
			latency = true,
			pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 265 },
		},
		cpower = {
			totems	= true,
			runes	= true,
			eclipse	= true,
			combo	= true,
			fury	= true,
			embers	= true,
			shards	= true,
			orbs	= true,
			chi		= true,
			holy	= true,
			["cpower1"] = {
				["size1"] = { 64, 132 },
				["pos1"] = { "CENTER", 1, 0 },
				["pos1glow"] = { "CENTER", 1, 0 },

				["size2"] = { 63, 63 },
				["pos2"] = { "CENTER", 1, -35 },

				["size3"] = { 68, 34 },
				["pos3"] = { "CENTER", 8, -50 },

				["size4"] = { 48, 24 },
				["pos4"] = { "CENTER", 13, -56 },
				["pos4glow"] = { "CENTER", 14, -55 },

				["size5"] = { 36, 18 },
				["pos5"] = { "CENTER", 17, -58 },

				["size6"] = { 30, 15 },
				["pos6"] = { "CENTER", 20, -59 },
			},
			["cpower2"] = {
				["size2"] = { 63, 63 },
				["pos2"] = { "CENTER", 1, 35 },

				["size3"] = { 55, 55 },
				["pos3"] = { "CENTER", -24, 0 },

				["size4"] = { 38, 38 },
				["pos4"] = { "CENTER", -19, -23 },
				["pos4glow"] = { "CENTER", -19, -22 },

				["size5"] = { 27, 27 },
				["pos5"] = { "CENTER", -13, -36 },

				["size6"] = { 20, 20 },
				["pos6"] = { "CENTER", -7, -43 },
				},
			["cpower3"] = {
				["size3"] = { 68, 34 },
				["pos3"] = { "CENTER", 8, 50 },

				["size4"] = { 38, 38 },
				["pos4"] = { "CENTER", -19, 23 },
				["pos4glow"] = { "CENTER", -19, 22 },

				["size5"] = { 32, 32 },
				["pos5"] = { "CENTER", -26, 0 },

				["size6"] = { 24, 24 },
				["pos6"] = { "CENTER", -23, -16 },
			},
			["cpower4"] = {
				["size4"] = { 48, 24 },
				["pos4"] = { "CENTER", 13, 56 },
				["pos4glow"] = { "CENTER", 14, 55 },

				["size5"] = { 27, 27 },
				["pos5"] = { "CENTER", -13, 36 },

				["size6"] = { 24, 24 },
				["pos6"] = { "CENTER", -23, 16 },
			},
			["cpower5"] = {
				["size5"] = { 36, 18 },
				["pos5"] = { "CENTER", 17, 58 },

				["size6"] = { 20, 20 },
				["pos6"] = { "CENTER", -7, 43 },
			},
			["cpower6"] = {
				["size6"] = { 30, 15 },
				["pos6"] = { "CENTER", 20, 59 },
			},
		},

	},
	pet = {
		pos = { "CENTER", "oUF_LSPlayer", "CENTER", -96, 0 },
		auras = {
			size = 20,
			spacing = 3,
			onlyShowPlayerBuffs = false,
			showStealableBuffs = true,
			onlyShowPlayerDebuffs = true,
			showDebuffType = true,
			debuffs = {
				pos = { "BOTTOMRIGHT", "TOPLEFT", 0, -20},
				initialAnchor = "BOTTOMRIGHT",
				growthx = "LEFT",
				growthy = "UP",
				num = 4,
				rows = 1,
				columns = 4,
			},
		},
	},
	target = {
		pos = {"BOTTOM", "UIParent", "BOTTOM", 0, 330 },
		power	= true,
		long	= true,
		threat	= true,
		class	= true,
		icons = {
			pvp = { 42, "BOTTOM", -110, -34 },
			leader = { 32, "BOTTOM",84, -22, "Interface\\AddOns\\oUF_LS\\media\\icon_leader" },
			quest = { 32, "TOPLEFT", 7, 34, "Interface\\AddOns\\oUF_LS\\media\\icon_quest" },
			role = { 20, "BOTTOM",112, -16, "Interface\\AddOns\\oUF_LS\\media\\icon_lfd_role" },
		},
		auras = {
			size = 26,
			spacing = 5,
			onlyShowPlayerBuffs = false,
			showStealableBuffs = true,
			onlyShowPlayerDebuffs = false,
			showDebuffType = false,
			buffs = {
				pos = { "BOTTOMLEFT", "TOPRIGHT", -10, 22 },
				initialAnchor = "BOTTOMLEFT",
				growthx = "RIGHT",
				growthy = "UP",
				num = 24,
				rows = 3,
				columns = 8,
			},
			debuffs = {
				pos = { "TOPLEFT", "BOTTOMRIGHT", -10, -6 },
				initialAnchor = "TOPLEFT",
				growthx = "RIGHT",
				growthy = "DOWN",
				num = 24,
				rows = 3,
				columns = 8,
			},
		},
		castbar = {
			fontsize = 12,
			pos = { "BOTTOM", "oUF_LSTarget", "TOP", 0, 75 },
		},
	},
	targettarget = {
		pos = { "LEFT", "oUF_LSTarget", "RIGHT", 12, 0 },
	},
	focus = {
		pos = { "RIGHT", "oUF_LSTarget", "LEFT", -12, 0 },
		auras = {
			show = true,
			size = 26,
			spacing = 5,
			onlyShowPlayerBuffs = false,
			showStealableBuffs = true,
			onlyShowPlayerDebuffs = true,
			showDebuffType = false,
			buffs = {
				pos = { "TOPLEFT", "CENTER", 5, -30 },
				initialAnchor = "TOPLEFT",
				growthx = "RIGHT",
				growthy = "DOWN",
				num = 4,
				rows = 2,
				columns = 2,
			},
			debuffs = {
				pos = { "TOPRIGHT", "CENTER", -5, -30 },
				initialAnchor = "TOPRIGHT",
				growthx = "LEFT",
				growthy = "DOWN",
				num = 4,
				rows = 2,
				columns = 2,
			},
		},
		castbar = {
			show = true,
			fontsize = 10,
			pos = { "TOP", "oUF_LSFocus", "TOP",0, 50 },
		},
	},
	focustarget = {
		pos = { "RIGHT", "oUF_LSFocus", "LEFT", -12, 0 },
	},
	party = {
		power = true,
		pos = {"TOPLEFT", "CompactRaidFrameManager", "TOPRIGHT", 6,	0 },
		attributes = {"showPlayer", true, "showParty", true, "showRaid", false, "point", "BOTTOM", "yOffset", 36},
		icons = {
			leader = { 32, "BOTTOM", -70, -16, "Interface\\AddOns\\oUF_LS\\media\\icon_leader" },
			role = { 20, "BOTTOM", 70, -12, "Interface\\AddOns\\oUF_LS\\media\\icon_lfd_role" },
		},
		auras = {
			show = true,
			size = 20,
			spacing = 4,
			showDebuffType = false,
			debuffs = {
				pos = { "TOPLEFT", "BOTTOMLEFT", 30, 3 },
				initialAnchor = "TOPLEFT",
				growthx = "RIGHT",
				growthy = "DOWN",
				num = 4,
				rows = 1,
				columns = 4,
			},
		},
	},
	boss1 = {
		power = true,
		threat = true,
		pos = {"TOPRIGHT", "UIParent", "TOPRIGHT", -84, -240 },
	},	
	boss2 = {
		power = true,
		threat = true,
		pos = {"TOPLEFT", "oUF_LSBoss1", "BOTTOMLEFT", 0, -16 },
	},
	boss3 = {
		power = true,
		threat = true,
		pos = {"TOPLEFT", "oUF_LSBoss1", "BOTTOMLEFT", 0, -16 },
	},
	boss4 = {
		power = true,
		threat = true,
		pos = {"TOPLEFT", "oUF_LSBoss1", "BOTTOMLEFT", 0, -16 },
	},
	boss5 = {
		power = true,
		threat = true,
		pos = {"TOPLEFT", "oUF_LSBoss1", "BOTTOMLEFT", 0, -16 },
	},
}
cfg.minimap = {
	iconsize = 32,
	elemets = {
		[1] = { "Minimap",						"BOTTOM",	"UIParent",	"BOTTOM",	306,	65	},
		[2] = { "MiniMapTracking",				"CENTER",	"Minimap",	"CENTER",	72,		30	},
		[3] = { "GameTimeFrame",				"CENTER",	"Minimap",	"CENTER",	55,		55	},
		[4] = { "MiniMapInstanceDifficulty",	"BOTTOM",	"Minimap",	"BOTTOM",	-1,		-38	},
		[5] = { "GuildInstanceDifficulty",		"BOTTOM",	"Minimap",	"BOTTOM",	-6,		-38	},
		[6] = {	"QueueStatusMinimapButton",		"CENTER",	"Minimap",	"CENTER",	55,		-55	},
	}, 
}
cfg.bottomline = {
	pos = { "BOTTOM", 0, 0 },
	expbar = {
		colors = {
			experience = { 0.51, 0.8, 0.7, 1 },
			rested = { 0.98, 0.6, 0.03, 1 },
			bg = { 0.25, 0.4, 0.35, 0.3 },
		},
	},
}
cfg.bars = {
	["bar1"] = { --MAINMENU
		pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 31 },
	},
	["bar2"] = { --BOTTOMLEFT
		pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 80 },
	},
	["bar3"] = { --BOTTOMRIGHT
		pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 114 },
	},
	["bar4"] = { --SIDERIGHT
		pos = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -6, 502 },
	},
	["bar5"] = { --SIDELEFT
		pos = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -40, 502 },
	},
	["add"] = { --PET
		["WARRIOR"] = 2,
		["PALADIN"] = 2,
		["HUNTER"] = 1,
		["ROGUE"] = 1,
		["PRIEST"] = 1,
		["DEATHKNIGHT"] = 2,
		["SHAMAN"] = 1,
		["MAGE"] = 1,
		["WARLOCK"] = 1,
		["MONK"] = 2,
		["DRUID"] = 2,
		["pet1"] = { "BOTTOM", "UIParent", "BOTTOM", 0, 148 },
		["pet2"] = { "BOTTOM", "UIParent", "BOTTOM", 0, 182 },
		["stance1"] = { "BOTTOM", "UIParent", "BOTTOM", 0, 182 },
		["stance2"] = { "BOTTOM", "UIParent", "BOTTOM", 0, 148 },
	},
	["bar9"] = { --OVERRIDE/VEHICLE
		pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 31 },
	},
	["bar10"] = { --PETBATTLE
		pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 31 },
	},
	bags = {
		pos1 = { "LEFT", "InfoBar5", "BOTTOM", -44, -20 },
		pos2 = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -36, 6 },
	},
	vehicle = {
		pos = { "BOTTOM", "oUF_LSPlayer", "BOTTOM", -46, -45 },
	},
	extrabar = {
		pos = { "BOTTOM", "UIParent", "BOTTOM", 0 , 190 },
	},
}
cfg.buttons = {
	buttonsize = 30,
	buttonspacing = 4,
}
cfg.buffs = {
	size = 30,
	["pos1"] = { "TOPRIGHT", "UIParent", "TOPRIGHT", -6, -60 }, 
	["pos2"] = { "TOPRIGHT", "UIParent", "TOPRIGHT", -6, -180 }, 
	rowspacing = 4,
	colspacing = 4,
	buffsperrow = 16,
}
cfg.infobars = {
	["sizelong"] = { 192, 54 },
	["sizeshort"] = { 104, 54 },
	["filllong"] = { 172, 36 },
	["fillshort"] = { 84, 36 },
	text = {
		pos1 = { "LEFT", 16, 0 },
		pos2 = { "RIGHT", -16, 0 },
	},
	["ibar1"] = {

		ftype = "long",
		pos = { "TOPLEFT", "UIParent", "TOPLEFT", 6, -5 },
	},
	["ibar2"] = {
		ftype = "short",
		pos = { "LEFT", "RIGHT", 74 },
	},
	["ibar3"] = {
		ftype = "short",
		pos = { "LEFT", "RIGHT", 6 },
	},
	["ibar4"] = {
		ftype = "short",
		pos = { "LEFT", "RIGHT", 6 },
	},
	["ibar5"] = {
		ftype = "short",
		pos = { "LEFT", "RIGHT", 74 },
	},
	["ibar6"] = {
		ftype = "short",
		pos = { "TOPRIGHT", "UIParent", "TOPRIGHT", -6, -5 },
	},
	["ibar7"] = {
		ftype = "short",
		pos = { "RIGHT", "LEFT", -6 },
	},
}

cfg.playerclass = select(2, UnitClass("player"))

cfg.font = "Interface\\AddOns\\oUF_LS\\media\\fonts\\PTSB.ttf"

ns.cfg = cfg