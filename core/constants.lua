local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF

-- Lua
local _G = _G
local string = _G.string
local pairs = _G.pairs
local select = _G.select
local type = _G.type
local unpack = _G.unpack

-- Mine
local hidden = _G.CreateFrame("Frame", nil, _G.UIParent)
hidden:Hide()
E.HIDDEN_PARENT = hidden

E.NOA = hidden:CreateAnimationGroup()
E.NOOP = function() end

local COLORS = {
	CLASS = {},
	DIFFICULTY = {},
	POWER = {},
	REACTION = {},
	THREAT = {},
}

------------------------
-- BASE COLOURS START --
------------------------

COLORS.BLACK = E:CreateColor(0, 0, 0)
COLORS.BLIZZ_YELLOW = E:CreateColor(255, 210, 0) -- Blizzard Normal Colour
COLORS.BLUE = E:CreateColor(23, 152, 251) -- Munsell 5PB 6/14 (#1798fb)
COLORS.DARK_GRAY = E:CreateColor(59, 58, 58) -- Munsell N2 (#3b3a3a)
COLORS.DARK_RED = E:CreateColor(140, 29, 30) -- Munsell 7.5R 3/10 (#8c1d1e)
COLORS.DARK_BLUE = E:CreateColor(32, 98, 165) -- Munsell 5PB 4/10 (#2062a5)
COLORS.GRAY = E:CreateColor(136, 137, 135) -- Munsell N5 (#888987)
COLORS.GREEN = E:CreateColor(46, 172, 52) -- Munsell 10GY 6/12 (#2eac34)
COLORS.INDIGO = E:CreateColor(148, 137, 228) -- Munsell 10PB 6/12 (#9489e4)
COLORS.LIGHT_BLUE = E:CreateColor(0.41, 0.8, 0.94) -- Blizzard Sanctuary Colour
COLORS.LIGHT_GRAY = E:CreateColor(202, 202, 202) -- Munsell N8 (#cacaca)
COLORS.LIGHT_GREEN = E:CreateColor(110, 228, 99) -- Munsell 10GY 8/12 (#6ee463)
COLORS.ORANGE = E:CreateColor(230, 118, 47) -- Munsell 2.5YR 6/12 (#e6762f)
COLORS.PURPLE = E:CreateColor(120, 76, 164) -- Munsell 2.5P 4/12 (#784ca4)
COLORS.RED = E:CreateColor(220, 68, 54) -- Munsell 7.5R 5/14 (#dc4436)
COLORS.WHITE = E:CreateColor(255, 255, 255)
COLORS.YELLOW = E:CreateColor(255, 183, 60) -- Munsell 7.5YR 8/12 (#ffb73c)

COLORS.GYR = E:CreateColorTable({COLORS.GREEN:GetRGB()}, {COLORS.YELLOW:GetRGB()}, {COLORS.RED:GetRGB()})
COLORS.RYG = E:CreateColorTable({COLORS.RED:GetRGB()}, {COLORS.YELLOW:GetRGB()}, {COLORS.GREEN:GetRGB()})

----------------------
-- BASE COLOURS END --
----------------------

oUF.colors.health = {COLORS.GREEN:GetRGB()}
oUF.colors.disconnected = {COLORS.GRAY:GetRGB()}
oUF.colors.tapped = {COLORS.GRAY:GetRGB()}

oUF.colors.reaction = {
	[1] = {COLORS.RED:GetRGB()},
	[2] = {COLORS.RED:GetRGB()},
	[3] = {COLORS.ORANGE:GetRGB()},
	[4] = {COLORS.YELLOW:GetRGB()},
	[5] = {COLORS.GREEN:GetRGB()},
	[6] = {COLORS.GREEN:GetRGB()},
	[7] = {COLORS.GREEN:GetRGB()},
	[8] = {COLORS.GREEN:GetRGB()},
}

oUF.colors.power.ARCANE_CHARGES = {38 / 255, 125 / 255, 206 / 255} -- Munsell 5PB 5/12 (#267dce)
oUF.colors.power.COMBO_POINTS = {215 / 255, 77 / 255, 18 / 255} -- Munsell 10R 5/14 (#d74d12)
oUF.colors.power.ENERGY = {251 / 255, 195 / 255, 10 / 255} -- Munsell 2.5Y 8/12 (#fbc30a)
oUF.colors.power.INSANITY = {125 / 255, 70 / 255, 174 / 255} -- Munsell 2.5P 4/14 (#7d46ae)
oUF.colors.power.MANA = {COLORS.BLUE:GetRGB()}
oUF.colors.power.RUNES = {94 / 255, 183 / 255, 248 / 255} -- Munsell 2.5PB 7/10 (#5eb7f8)
oUF.colors.power.SOUL_SHARDS = {149 / 255, 99 / 255, 202 / 255} -- Munsell 2.5P 5/14 (#9563ca)

for k, color in pairs(oUF.colors.power) do
	if type(color[1]) ~= "table" then
		COLORS.POWER[k] = E:CreateColor(color[1], color[2], color[3])
	else
		COLORS.POWER[k] = E:CreateColorTable(unpack(color))
	end
end

for k, color in pairs(oUF.colors.reaction) do
	COLORS.REACTION[k] = E:CreateColor(color[1], color[2], color[3])
end

for k, color in pairs(oUF.colors.class) do
	COLORS.CLASS[k] = E:CreateColor(color[1], color[2], color[3])
end

for i = 1, 4 do
	COLORS.THREAT[i] = E:CreateColor(_G.GetThreatStatusColor(i - 1))
end

for k, v in pairs(_G.QuestDifficultyColors) do
	if k ~= "header" then
		COLORS.DIFFICULTY[string.upper(k)] = E:CreateColor(v.r, v.g, v.b)
	end
end

COLORS.POWER.GLOW = {
	ARCANE_CHARGES = E:CreateColor(19, 239, 237),
	CHI = E:CreateColor(168, 255, 181),
	COMBO_POINTS = E:CreateColor(242, 133, 28),
	HOLY_POWER = E:CreateColor(249, 213, 145),
	RUNES = E:CreateColor(95, 251, 238),
	SOUL_SHARDS = E:CreateColor(254, 97, 255)
}

COLORS.BUTTON_ICON = {
	N = COLORS.WHITE, -- normal
	OOM = COLORS.DARK_BLUE, -- out of mana
	OOR = COLORS.DARK_RED, -- out of range
}

COLORS.HEALPREDICTION = {
	MY_HEAL = E:CreateColor(41, 142, 48), -- Munsell 510GY 5/10 (#298e30)
	OTHER_HEAL = E:CreateColor(63, 164, 155), -- Munsell 10GY 4/8 (#227029)
	HEAL_ABSORB = COLORS.DARK_RED,
	DAMAGE_ABSORB = E:CreateColor(186, 204, 229), -- Munsell 5PB 8/4 (#bacce5)
}

COLORS.FACTION = {
	ALLIANCE = E:CreateColor(0.29, 0.33, 0.91), -- Blizzard Alliance Colour
	HORDE = E:CreateColor(0.90, 0.05, 0.07), -- Blizzard Horde Color
	NEUTRAL = COLORS.WHITE,
}

COLORS.DISCONNECTED = COLORS.GRAY
COLORS.HEALTH = COLORS.GREEN
COLORS.TAPPED = COLORS.GRAY

COLORS.ARTIFACT = E:CreateColor(230, 204, 128) -- Blizzard Artefact Colour
COLORS.HONOR = COLORS.RED
COLORS.XP = COLORS.BLUE

M.COLORS = COLORS

local textures = {
	icons = {
		-- first line
		["LEADER"] = {1 / 128, 17 / 128, 1 / 128, 17 / 128},
		["DAMAGER"] = {18 / 128, 34 / 128, 1 / 128, 17 / 128},
		["HEALER"] = {35 / 128, 51 / 128, 1 / 128, 17 / 128},
		["TANK"] = {52 / 128, 68 / 128, 1 / 128, 17 / 128},
		["RESTING"] = {69 / 128, 85 / 128, 1 / 128, 17 / 128},
		["COMBAT"] = {86 / 128, 102 / 128, 1 / 128, 17 / 128},
		["HORDE"] = {103 / 128, 119 / 128, 1 / 128, 17 / 128},
		-- second line
		["ALLIANCE"] = {1 / 128, 17 / 128, 18 / 128, 34 / 128},
		["FFA"] = {18 / 128, 34 / 128, 18 / 128, 34 / 128},
		["PHASE"] = {35 / 128, 51 / 128, 18 / 128, 34 / 128},
		["QUEST"] = {52 / 128, 68 / 128, 18 / 128, 34 / 128},
		["SHEEP"] = {69 / 128, 85 / 128, 18 / 128, 34 / 128},
		-- ["TEMP"] = {86 / 128, 102 / 128, 18 / 128, 34 / 128},
		-- ["TEMP"] = {103 / 128, 119 / 128, 18 / 128, 34 / 128},
		-- third line
		-- ["TEMP"] = {1 / 128, 17 / 128, 35 / 128, 51 / 128},
		-- ["TEMP"] = {18 / 128, 34 / 128, 35 / 128, 51 / 128},
		-- ["TEMP"] = {35 / 128, 51 / 128, 35 / 128, 51 / 128},
		-- ["TEMP"] = {52 / 128, 68 / 128, 35 / 128, 51 / 128},
		-- ["TEMP"] = {69 / 128, 85 / 128, 35 / 128, 51 / 128},
		-- ["TEMP"] = {86 / 128, 102 / 128, 35 / 128, 51 / 128},
		-- ["TEMP"] = {103 / 128, 119 / 128, 35 / 128, 51 / 128},
		-- fourth line
		-- ["TEMP"] = {1 / 128, 17 / 128, 52 / 128, 68 / 128},
		-- ["TEMP"] = {18 / 128, 34 / 128, 52 / 128, 68 / 128},
		-- ["TEMP"] = {35 / 128, 51 / 128, 52 / 128, 68 / 128},
		-- ["TEMP"] = {52 / 128, 68 / 128, 52 / 128, 68 / 128},
		-- ["TEMP"] = {69 / 128, 85 / 128, 52 / 128, 68 / 128},
		-- ["TEMP"] = {86 / 128, 102 / 128, 52 / 128, 68 / 128},
		-- ["TEMP"] = {103 / 128, 119 / 128, 52 / 128, 68 / 128},
		-- fifth line
		-- ["TEMP"] = {1 / 128, 17 / 128, 69 / 128, 85 / 128},
		-- ["TEMP"] = {18 / 128, 34 / 128, 69 / 128, 85 / 128},
		-- ["TEMP"] = {35 / 128, 51 / 128, 69 / 128, 85 / 128},
		-- ["TEMP"] = {52 / 128, 68 / 128, 69 / 128, 85 / 128},
		-- ["TEMP"] = {69 / 128, 85 / 128, 69 / 128, 85 / 128},
		-- ["TEMP"] = {86 / 128, 102 / 128, 69 / 128, 85 / 128},
		-- ["TEMP"] = {103 / 128, 119 / 128, 69 / 128, 85 / 128},
		-- sixth line
		["WARRIOR"] = {1 / 128, 17 / 128, 86 / 128, 102 / 128},
		["MAGE"] = {18 / 128, 34 / 128, 86 / 128, 102 / 128},
		["ROGUE"] = {35 / 128, 51 / 128, 86 / 128, 102 / 128},
		["DRUID"] = {52 / 128, 68 / 128, 86 / 128, 102 / 128},
		["HUNTER"] = {69 / 128, 85 / 128, 86 / 128, 102 / 128},
		["SHAMAN"] = {86 / 128, 102 / 128, 86 / 128, 102 / 128},
		["PRIEST"] = {103 / 128, 119 / 128, 86 / 128, 102 / 128},
		-- seventh line
		["WARLOCK"] = {1 / 128, 17 / 128, 103 / 128, 119 / 128},
		["PALADIN"] = {18 / 128, 34 / 128, 103 / 128, 119 / 128},
		["DEATHKNIGHT"] = {35 / 128, 51 / 128, 103 / 128, 119 / 128},
		["MONK"] = {52 / 128, 68 / 128, 103 / 128, 119 / 128},
		["DEMONHUNTER"] = {69 / 128, 85 / 128, 103 / 128, 119 / 128},
		-- ["TEMP"] = {86 / 128, 102 / 128, 103 / 128, 119 / 128},
		-- ["TEMP"] = {103 / 128, 119 / 128, 103 / 128, 119 / 128},
	},
	inlineicons = {
		-- first line
		["LEADER"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:1:17:1:17|t",
		["DAMAGER"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:18:34:1:17|t",
		["HEALER"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:35:51:1:17|t",
		["TANK"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:52:68:1:17|t",
		["RESTING"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:69:85:1:17|t",
		["COMBAT"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:86:102:1:17|t",
		["HORDE"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:103:119:1:17|t",
		-- second line
		["ALLIANCE"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:1:17:18:34|t",
		["FFA"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:18:34:18:34|t",
		["PHASE"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:35:51:18:34|t",
		["QUEST"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:52:68:18:34|t",
		["SHEEP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:69:85:18:34|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:86:102:18:34|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:103:119:18:34|t",
		-- third line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:1:17:35:51|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:18:34:35:51|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:35:51:35:51|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:52:68:35:51|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:69:85:35:51|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:86:102:35:51|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:103:119:35:51|t",
		-- fourth line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:1:17:52:68|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:18:34:52:68|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:35:51:52:68|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:52:68:52:68|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:69:85:52:68|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:86:102:52:68|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:103:119:52:68|t",
		-- fifth line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:1:17:69:85|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:18:34:69:85|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:35:51:69:85|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:52:68:69:85|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:69:85:69:85|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:86:102:69:85|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:103:119:69:85|t",
		-- sixth line
		["WARRIOR"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:1:17:86:102|t",
		["MAGE"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:18:34:86:102|t",
		["ROGUE"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:35:51:86:102|t",
		["DRUID"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:52:68:86:102|t",
		["HUNTER"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:69:85:86:102|t",
		["SHAMAN"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:86:102:86:102|t",
		["PRIEST"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:103:119:86:102|t",
		-- seventh line
		["WARLOCK"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:1:17:103:119|t",
		["PALADIN"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:18:34:103:119|t",
		["DEATHKNIGHT"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:35:51:103:119|t",
		["MONK"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:52:68:103:119|t",
		["DEMONHUNTER"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:69:85:103:119|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:86:102:103:119|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\icons:%d:%d:0:0:128:128:103:119:103:119|t",
	},
}

M.textures = textures

E.OMNICC = select(4, _G.GetAddOnInfo("OmniCC"))

E.SCREEN_WIDTH = E:Round(_G.UIParent:GetRight())
E.SCREEN_HEIGHT = E:Round(_G.UIParent:GetTop())

E.PLAYER_CLASS = select(2, _G.UnitClass("player"))

E.PLAYER_SPEC_FLAGS = {
	-- [-1] = 0x00000000, -- none
	-- [0] = 0x00000000, -- all
	[1] = 0x00000001, -- 1st
	[2] = 0x00000002, -- 2nd
	[3] = 0x00000004, -- 3rd
	[4] = 0x00000008, -- 4th
}

-- Everything that's not available at ADDON_LOADED goes here
function E:UpdateConstants()
	for i = 1, _G.GetNumSpecializations() do
		E.PLAYER_SPEC_FLAGS[0] = E:AddFilterToMask(E.PLAYER_SPEC_FLAGS[0] or 0, E.PLAYER_SPEC_FLAGS[i])
	end

	E.PLAYER_GUID = _G.UnitGUID("player")
end
