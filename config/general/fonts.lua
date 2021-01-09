local _, ns = ...
local E, C, M, L, P, D, oUF = ns.E, ns.C, ns.M, ns.L, ns.P, ns.D, ns.oUF
local AURAS = P:GetModule("Auras")
local BARS = P:GetModule("Bars")
local BLIZZARD = P:GetModule("Blizzard")
local CONFIG = P:GetModule("Config")
local FILTERS = P:GetModule("Filters")
local MINIMAP = P:GetModule("Minimap")
local UNITFRAMES = P:GetModule("UnitFrames")
local AURATRACKER = P:GetModule("AuraTracker")

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
		args = {
			cooldown = {
				order = reset(1),
				type = "group",
				inline = true,
				name = "",
				set = function(info, value)
					if C.db.global.fonts.cooldown[info[#info]] ~= value then
						C.db.global.fonts.cooldown[info[#info]] = value

						E.Cooldowns:ForEach("UpdateConfig")
						E.Cooldowns:ForEach("UpdateFont")
					end
				end,
				args = {
					font = {
						order = reset(2),
						type = "select",
						name = L["COOLDOWN"],
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
			buttons = {
				order = inc(1),
				type = "group",
				inline = true,
				name = "",
				set = function(info, value)
					if C.db.global.fonts.buttons[info[#info]] ~= value then
						C.db.global.fonts.buttons[info[#info]] = value

						BARS:ForBar("bar1", "UpdateConfig")
						BARS:ForBar("bar2", "UpdateConfig")
						BARS:ForBar("bar3", "UpdateConfig")
						BARS:ForBar("bar4", "UpdateConfig")
						BARS:ForBar("bar5", "UpdateConfig")
						BARS:ForBar("bar6", "UpdateConfig")
						BARS:ForBar("bar7", "UpdateConfig")
						BARS:ForBar("pet_battle", "UpdateConfig")
						BARS:ForBar("extra", "UpdateConfig")
						-- BARS:ForBar("xpbar", "UpdateConfig")

						BARS:ForEach("ForEach", "UpdateCountFont")
						BARS:ForEach("ForEach", "UpdateHotKeyFont")
						BARS:ForEach("ForEach", "UpdateMacroFont")
						-- BARS:ForBar("xpbar", "UpdateFont")

						AURAS:ForEach("UpdateConfig")
						AURAS:ForEach("ForEach", "UpdateCountFont")

						AURATRACKER:GetTracker():UpdateConfig()
						AURATRACKER:GetTracker():UpdateCountFont()
					end
				end,
				args = {
					font = {
						order = reset(2),
						type = "select",
						name = L["BUTTONS"],
						dialogControl = "LSM30_Font",
						values = LSM:HashTable("font"),
						get = function()
							return LSM:IsValid("font", C.db.global.fonts.buttons.font)
								and C.db.global.fonts.buttons.font or LSM:GetDefault("font")
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
			units = {
				order = inc(1),
				type = "group",
				inline = true,
				name = "",
				set = function(info, value)
					if C.db.global.fonts.units[info[#info]] ~= value then
						C.db.global.fonts.units[info[#info]] = value

						UNITFRAMES:ForEach("ForElement", "Health", "UpdateConfig")
						UNITFRAMES:ForEach("ForElement", "Health", "UpdateFonts")
						UNITFRAMES:ForEach("ForElement", "HealthPrediction", "UpdateConfig")
						UNITFRAMES:ForEach("ForElement", "HealthPrediction", "UpdateFonts")
						UNITFRAMES:ForEach("ForElement", "Power", "UpdateConfig")
						UNITFRAMES:ForEach("ForElement", "Power", "UpdateFonts")
						UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateConfig")
						UNITFRAMES:ForEach("ForElement", "AlternativePower", "UpdateFonts")
						UNITFRAMES:ForEach("ForElement", "Castbar", "UpdateConfig")
						UNITFRAMES:ForEach("ForElement", "Castbar", "UpdateFonts")
						UNITFRAMES:ForEach("ForElement", "Name", "UpdateConfig")
						UNITFRAMES:ForEach("ForElement", "Name", "UpdateFonts")
					end
				end,
				args = {
					font = {
						order = reset(2),
						type = "select",
						name = L["UNIT_FRAME"],
						dialogControl = "LSM30_Font",
						values = LSM:HashTable("font"),
						get = function()
							return LSM:IsValid("font", C.db.global.fonts.units.font)
								and C.db.global.fonts.units.font or LSM:GetDefault("font")
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
			statusbars = {
				order = inc(1),
				type = "group",
				inline = true,
				name = "",
				set = function(info, value)
					if C.db.global.fonts.statusbars[info[#info]] ~= value then
						C.db.global.fonts.statusbars[info[#info]] = value
					end
				end,
				args = {
					font = {
						order = reset(2),
						type = "select",
						name = L["STATUSBAR_BARS"],
						dialogControl = "LSM30_Font",
						values = LSM:HashTable("font"),
						get = function()
							return LSM:IsValid("font", C.db.global.fonts.statusbars.font)
								and C.db.global.fonts.statusbars.font or LSM:GetDefault("font")
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
