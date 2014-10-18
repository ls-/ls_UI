local _, ns = ...

ns.hiddenParentFrame = CreateFrame("Frame")
ns.hiddenParentFrame:Hide()

ns.M = {
	font = STANDARD_TEXT_FONT,
	textures = {
		statusbar = "Interface\\AddOns\\oUF_LS\\media\\statusbar",
		button = {
			normal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal",
			normalmetal = "Interface\\AddOns\\oUF_LS\\media\\button\\normal_bronze",
			highlight = "Interface\\AddOns\\oUF_LS\\media\\button\\highlight",
			pushed = "Interface\\AddOns\\oUF_LS\\media\\button\\pushed",
			checked = "Interface\\AddOns\\oUF_LS\\media\\button\\checked",
			flash = "Interface\\AddOns\\oUF_LS\\media\\button\\flash",
		},
		cpower = {
			["total1"] = {
				["cpower1"] = {
					size = {62, 130},
					point = {"CENTER", 1, 0},
					glowcoord = {16 / 512, 82 / 512, 60 / 256, 196 / 256},
					glowpoint = {"CENTER", -0.5, 0},
				},
			},
			["total2"] = {
				["cpower1"] = {
					size = {63, 63},
					point = {"CENTER", 1, -35},
					glowcoord = {102 / 512, 168 / 512, 130 / 256, 196 / 256},
					glowpoint = {"CENTER", 1, -35},
				},
				["cpower2"] = {
					size = {63, 63},
					point = {"CENTER", 1, 35},
					glowcoord = {102 / 512, 168 / 512, 60 / 256, 126 / 256},
					glowpoint = {"CENTER", 1, 35},
				},
			},
			["total3"] = {
				["cpower1"] = {
					size = {64, 32},
					point = {"CENTER", 8, -49},
					glowcoord = {200 / 512, 253 / 512, 160 / 256, 196 / 256},
					glowpoint = {"CENTER", 7, -50},
				},
				["cpower2"] = {
					size = {30, 55},
					point = {"CENTER", -23, 0},
					glowcoord = {186 / 512, 204 / 512, 98 / 256, 158 / 256},
					glowpoint = {"CENTER", -24, 0},
				},
				["cpower3"] = {
					size = {64, 32},
					point = {"CENTER", 8, 49},
					glowcoord = {200 / 512, 253 / 512, 60 / 256, 96 / 256},
					glowpoint = {"CENTER", 7, 50},
				},
			},
			["total4"] = {
				["cpower1"] = {
					size = {43, 23},
					point = {"CENTER", 14, -54.5},
					glowcoord = {297 / 512, 338 / 512, 171 / 256, 196 / 256},
					glowpoint = {"CENTER", 13, -55.5},
				},
				["cpower2"] = {
					size = {40, 38},
					point = {"CENTER", -19, -23},
					glowcoord = {272 / 512, 297 / 512, 130 / 256, 171/ 256},
					glowpoint = {"CENTER", -19, -23},
				},
				["cpower3"] = {
					size = {40, 38},
					point = {"CENTER", -19, 23},
					glowcoord = {272 / 512, 297 / 512, 85 / 256, 126 / 256},
					glowpoint = {"CENTER", -19, 23},
				},
				["cpower4"] = {
					size = {43, 23},
					point = {"CENTER", 14, 54.5},
					glowcoord = {297 / 512, 338 / 512, 60 / 256, 85 / 256},
					glowpoint = {"CENTER", 13, 55.5},
				},
			},
			["total5"] = {
				["cpower1"] = {
					size = {31, 16},
					point = {"CENTER", 18, -57.5},
					glowcoord = {390 / 512, 423 / 512, 176 / 256, 196 / 256},
					glowpoint = {"CENTER", 17, -58},
				},
				["cpower2"] = {
					size = {30, 27},
					point = {"CENTER", -12, -36},
					glowcoord = {363 / 512, 389 / 512, 148 / 256, 179 / 256},
					glowpoint = {"CENTER", -13, -36},
				},
				["cpower3"] = {
					size = {16, 32},
					point = {"CENTER", -26, 0},
					glowcoord = {356 / 512, 371 / 512, 111 / 256, 145 / 256},
					glowpoint = {"CENTER", -25, 0},
				},
				["cpower4"] = {
					size = {30, 27},
					point = {"CENTER", -12, 36},
					glowcoord = {363 / 512, 389 / 512, 77 / 256, 108 / 256},
					glowpoint = {"CENTER", -13, 36},
				},
				["cpower5"] = {
					size = {31, 16},
					point = {"CENTER", 18, 57.5},
					glowcoord = {390 / 512, 423 / 512, 60 / 256, 80 / 256},
					glowpoint = {"CENTER", 17, 58},
				},
			},
			["total6"] = {
				["cpower1"] = {
					size = {30, 15},
					point = {"CENTER", 20, -59},
					glowcoord = {480 / 512, 508 / 512, 179 / 256, 196 / 256},
					glowpoint = {"CENTER", 19.5, -59.5},
				},
				["cpower2"] = {
					size = {20, 20},
					point = {"CENTER", -7, -43},
					glowcoord = {455 / 512, 479/ 512, 160 / 256, 183 / 256},
					glowpoint = {"CENTER", -7, -43.5},
				},
				["cpower3"] = {
					size = {24, 24},
					point = {"CENTER", -23, -16},
					glowcoord = {442 / 512, 459/ 512, 130 / 256, 158 / 256},
					glowpoint = {"CENTER", -23, -16.5},
				},
				["cpower4"] = {
					size = {24, 24},
					point = {"CENTER", -23, 16},
					glowcoord = {442 / 512, 459 / 512, 98 / 256, 126 / 256},
					glowpoint = {"CENTER", -23, 16.5},
				},
				["cpower5"] = {
					size = {20, 20},
					point = {"CENTER", -7, 43},
					glowcoord = {455 / 512, 479/ 512, 73 / 256, 96 / 256},
					glowpoint = {"CENTER", -7, 43.5},
				},
				["cpower6"] = {
					size = {30, 15},
					point = {"CENTER", 20, 59},
					glowcoord = {480 / 512, 508 / 512, 60 / 256, 77 / 256},
					glowpoint = {"CENTER", 19.5, 59.5},
				},
			},
		},
	},
	colors = {
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
			["COMBO"] = {0.92, 0.62, 0.13},
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
		infobar = {
			black = {0.15, 0.15, 0.15},
			red = {0.9, 0.1, 0.1},
			green = {0.15, 0.65, 0.15},
			blue = {0.41, 0.8, 0.94},
			yellow = {1, 0.75, 0.1},
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
			["ENERGY"] = {1, 0.75, 0.1},
			["RUNES"]  = {0.5, 0.5, 0.5},
			["RUNIC_POWER"] = {0.4, 0.65, 0.95},
			["SOUL_SHARDS"] = {0.5, 0.32, 0.5},
			["HOLY_POWER"] = {0.95, 0.90, 0.25},
		},
		health = {0.15, 0.65, 0.15},
	},
}