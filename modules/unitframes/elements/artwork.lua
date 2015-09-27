local _, ns = ...
local E, M = ns. E, ns.M

M.frame_textures = {
	-- atlas = "Interface\\AddOns\\oUF_LS\\media\\statusbar",
	shared = {
		corner_rare_left = {
			size = {19, 38},
			coords = {0 / 512, 19 / 512, 66 / 512, 104 / 512},
		},
		corner_rare_mid = {
			size = {36, 36},
			coords = {19 / 512, 55 / 512, 67 / 512, 103 / 512},
		},
		corner_rare_right = {
			size = {19, 38},
			coords = {55 / 512, 74 / 512, 66 / 512, 104 / 512},
		},
		corner_elite_left = {
			size = {21, 42},
			coords = {74 / 512, 95 / 512, 66 / 512, 108 / 512},
		},
		corner_elite_right = {
			size = {21, 42},
			coords = {95 / 512, 116 / 512, 66 / 512, 108 / 512},
		},
		inside_left = {
			size = {14, 26},
			coords = {116 / 512, 130 / 512, 66 / 512, 92 / 512},
		},
		inside_right = {
			size = {14, 26},
			coords = {130 / 512, 144 / 512, 66 / 512, 92 / 512},
		},
		power_cap_silver_left = {
			size = {12, 10},
			coords = {408 / 512, 420 / 512, 20 / 512, 30 / 512},
		},
		power_cap_silver_right = {
			size = {12, 10},
			coords = {420 / 512, 432 / 512, 20 / 512, 30 / 512},
		},
		power_cap_copper_left = {
			size = {12, 10},
			coords = {408 / 512, 420 / 512, 30 / 512, 40 / 512},
		},
		power_cap_copper_right = {
			size = {12, 10},
			coords = {420 / 512, 432 / 512, 30 / 512, 40 / 512},
		},
		power_mid = {
			size = {8, 8},
			coords = {410 / 512, 418 / 512, 40 / 512, 48 / 512},
		},
	},
	long = {
		bg = {
			size = {204, 36},
			coords = {0 / 512, 204 / 512, 0 / 512, 36 / 512},
		},
		threat_glow = {
			size = {103, 30},
			coords = {0 / 512, 103 / 512, 36 / 512, 66 / 512},
		},
		debuff_glow = {
			size = {103, 30},
			coords = {103 / 512, 206 / 512, 36 / 512, 66 / 512},
		},
		fg_copper = {
			size = {200, 30},
			coords = {206 / 512, 406 / 512, 30 / 512, 60 / 512},
		},
		fg_copper_elite = {
			size = {202, 35},
			coords = {206 / 512, 408 / 512, 95 / 512, 130 / 512},
		},
		fg_silver = {
			size = {200, 30},
			coords = {206 / 512, 406 / 512, 0 / 512, 30 / 512},
		},
		fg_silver_elite = {
			size = {202, 35},
			coords = {206 / 512, 408 / 512, 60 / 512, 95 / 512},
		},
	},
	short = {},
}
