local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF

-- Lua
local _G = _G
local select = select

-- Mine
E.HIDDEN_PARENT = CreateFrame("Frame", "LSHiddenParent")
E.HIDDEN_PARENT:Hide()

E.NOA = E:CreateAnimationGroup()
E.NOOP = function() end

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

oUF.colors.power["ARCANE_CHARGES"] = {29 / 255, 124 / 255, 226 / 255}
oUF.colors.power["COMBO_POINTS"] = {229 / 255, 76 / 255, 38 / 255}
oUF.colors.power["ENERGY"] = {255 / 255, 206 / 255, 13 / 255}
oUF.colors.power["INSANITY"] = {158 / 255, 6 / 255, 227 / 255}
oUF.colors.power["MANA"] = {13 / 255, 140 / 255, 255 / 255}
oUF.colors.power["RUNES"] = {106 / 255, 184 / 255, 247 / 255}
oUF.colors.power["SOUL_SHARDS"] = {175 / 255, 110 / 255, 255 / 255}

local colors = E:CopyTable(oUF.colors, {})

colors.power["ARCANE_CHARGES_GLOW"] = {19 / 255, 239 / 255, 237 / 255}
colors.power["CHI_GLOW"] = {168 / 255, 255 / 255, 181 / 255}
colors.power["COMBO_POINTS_GLOW"] = {242 / 255, 133 / 255, 28 / 255}
colors.power["HOLY_POWER_GLOW"] = {249 / 255, 213 / 255, 145 / 255}
colors.power["RUNES_GLOW"] = {95 / 255, 251 / 255, 238 / 255}
colors.power["SOUL_SHARDS_GLOW"] = {254 / 255, 97 / 255, 255 / 255}
colors.power["STAGGER"] = {0.52, 1, 0.52, 1, 0.98, 0.72, 1, 0.42, 0.42}

colors.icon = {
	oom	= {0.5, 0.5, 1, 0.65},
	nu	= {0.4, 0.4, 0.4, 0.65},
	oor	= {0.8, 0.1, 0.1, 0.65},
}

colors.experience = {0.11, 0.75, 0.95}
colors.artifact = {0.901, 0.8, 0.601}
colors.honor = {1.0, 0.24, 0}

colors.healprediction = {
	["myheal"] = {0, 0.827, 0.765},
	["otherheal"] = {0.0, 0.631, 0.557},
	["healabsorb"] = {0.9, 0.1, 0.3},
	["damageabsorb"] = {0.85, 0.85, 0.9},
}

colors.blue = {0.41, 0.8, 0.94}
colors.darkgray = {0.15, 0.15, 0.15}
colors.darkmagenta = {0.545, 0, 0.545}
colors.dodgerblue = {0.12, 0.56, 1}
colors.gray = {0.6, 0.6, 0.6}
colors.green = {0.15, 0.65, 0.15}
colors.indigo = {0.36, 0.46, 0.8}
colors.jade = {0, 0.66, 0.42}
colors.lightgray = {0.85, 0.85, 0.85}
colors.orange = {0.9, 0.4, 0.1}
colors.red = {0.9, 0.15, 0.15}
colors.yellow = {0.9, 0.65, 0.15}

colors.gradient = {
	["GYR"] = {0.15, 0.65, 0.15, 0.9, 0.65, 0.15, 0.9, 0.15, 0.15},
	["RYG"] = {0.9, 0.15, 0.15, 0.9, 0.65, 0.15, 0.15, 0.65, 0.15},
}

colors.threat = {}
for i = 1, 4 do
	colors.threat[i] = {GetThreatStatusColor(i - 1)}
end

M.colors = colors

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

E.SCREEN_WIDTH = E:Round(UIParent:GetRight())
E.SCREEN_HEIGHT = E:Round(UIParent:GetTop())
E.SCREEN_CENTER_X, E.SCREEN_CENTER_Y = UIParent:GetCenter()
E.SCREEN_CENTER_X, E.SCREEN_CENTER_Y = E:Round(E.SCREEN_CENTER_X), E:Round(E.SCREEN_CENTER_Y)


E.PLAYER_CLASS = select(2, UnitClass("player"))

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
