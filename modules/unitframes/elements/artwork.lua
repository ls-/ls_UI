local _, ns = ...
local M = ns.M

M.frame_textures = {
	shared = {
		corner_rare_left = {
			size = {19, 38},
			coords = {0 / 512, 19 / 512, 66 / 256, 104 / 256},
		},
		corner_rare_mid = {
			size = {36, 36},
			coords = {19 / 512, 55 / 512, 67 / 256, 103 / 256},
		},
		corner_rare_right = {
			size = {19, 38},
			coords = {55 / 512, 74 / 512, 66 / 256, 104 / 256},
		},
		corner_elite_left = {
			size = {21, 42},
			coords = {74 / 512, 95 / 512, 66 / 256, 108 / 256},
		},
		corner_elite_right = {
			size = {21, 42},
			coords = {95 / 512, 116 / 512, 66 / 256, 108 / 256},
		},
		-- inside_left = {
		-- 	size = {14, 26},
		-- 	coords = {116 / 512, 130 / 512, 66 / 256, 92 / 256},
		-- },
		-- inside_right = {
		-- 	size = {14, 26},
		-- 	coords = {130 / 512, 144 / 512, 66 / 256, 92 / 256},
		-- },
	},
	long = {
		-- bg = {
		-- 	size = {204, 36},
		-- 	coords = {0 / 512, 204 / 512, 0 / 256, 36 / 256},
		-- },
		-- threat_glow = {
		-- 	size = {103, 30},
		-- 	coords = {0 / 512, 103 / 512, 36 / 256, 66 / 256},
		-- },
		-- debuff_glow = {
		-- 	size = {103, 30},
		-- 	coords = {103 / 512, 206 / 512, 36 / 256, 66 / 256},
		-- },
		fg_copper = {
			size = {200, 30},
			coords = {206 / 512, 406 / 512, 30 / 256, 60 / 256},
		},
		fg_copper_elite = {
			size = {202, 35},
			coords = {206 / 512, 408 / 512, 95 / 256, 130 / 256},
		},
		fg_silver = {
			size = {200, 30},
			coords = {206 / 512, 406 / 512, 0 / 256, 30 / 256},
		},
		fg_silver_elite = {
			size = {202, 35},
			coords = {206 / 512, 408 / 512, 60 / 256, 95 / 256},
		},
	},
	short = {
		-- bg = {
		-- 	size = {110, 36},
		-- 	coords = {0 / 512, 110 / 512, 130 / 256, 166 / 256},
		-- },
		-- threat_glow = {
		-- 	size = {56, 30},
		-- 	coords = {0 / 512, 56 / 512, 166 / 256, 196 / 256},
		-- },
		-- debuff_glow = {
		-- 	size = {56, 30},
		-- 	coords = {56 / 512, 112 / 512, 166 / 256, 196 / 256},
		-- },
		fg_copper = {
			size = {106, 30},
			coords = {112 / 512, 218 / 512, 160 / 256, 190 / 256},
		},
		fg_copper_elite = {
			size = {108, 35},
			coords = {218 / 512, 326 / 512, 165 / 256, 200 / 256},
		},
		fg_silver = {
			size = {106, 30},
			coords = {112 / 512, 218 / 512, 130 / 256, 160 / 256},
		},
		fg_silver_elite = {
			size = {108, 35},
			coords = {218 / 512, 326 / 512, 130 / 256, 165 / 256},
		},
	},
}
