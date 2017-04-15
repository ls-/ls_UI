local _, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF

-- Lua
local _G = getfenv(0)
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
	ITEM_QUALITY = {},
}

------------------------
-- BASE COLOURS START --
------------------------

COLORS.BLACK = E:CreateColor(0, 0, 0)
COLORS.BLIZZ_YELLOW = E:CreateColor(255, 210, 0) -- Blizzard Normal Colour
COLORS.BLUE = E:CreateColor(21, 155, 243) -- Munsell 2.5PB 6/12 (#159BF3)
COLORS.DARK_BLUE = E:CreateColor(38, 97, 172) -- Munsell 5PB 4/10 (#2661ac)
COLORS.DARK_GRAY = E:CreateColor(52, 48, 51) -- Munsell N 2 (#343033)
COLORS.DARK_RED = E:CreateColor(141, 28, 33) -- Munsell 7.5R 3/10 (#8d1c21)
COLORS.GRAY = E:CreateColor(125, 122, 125) -- Munsell N 5 (#7d7a7d)
COLORS.GREEN = E:CreateColor(60, 170, 59) -- Munsell 10GY 6/12 (#3caa3b)
COLORS.INDIGO = E:CreateColor(151, 135, 237) -- Munsell 10PB 6/12 (#9787ed)
COLORS.LIGHT_BLUE = E:CreateColor(0.41, 0.8, 0.94) -- Blizzard Sanctuary Colour
COLORS.LIGHT_GRAY = E:CreateColor(205, 201, 205) -- Munsell N 8 (#cdc9cd)
COLORS.LIGHT_GREEN = E:CreateColor(120, 225, 107) -- Munsell 10GY 8/12 (#78e16b)
COLORS.ORANGE = E:CreateColor(232, 116, 52) -- Munsell 2.5YR 6/12 (#e87434)
COLORS.PURPLE = E:CreateColor(122, 75, 170) -- Munsell 2.5P 4/12 (#7a4baa)
COLORS.RED = E:CreateColor(222, 67, 58) -- Munsell 7.5R 5/14 (#de433a)
COLORS.WHITE = E:CreateColor(255, 255, 255)
COLORS.YELLOW = E:CreateColor(250, 193, 74) -- Munsell 2.5Y 8/10 (#fac14a)

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

oUF.colors.power.ARCANE_CHARGES = {46 / 255, 124 / 255, 214 / 255} -- Munsell 5PB 5/12 (#2e7cd6)
oUF.colors.power.COMBO_POINTS = {216 / 255, 75 / 255, 24 / 255} -- Munsell 10R 5/14 (#d84b18)
oUF.colors.power.ENERGY = {COLORS.YELLOW:GetRGB()}
oUF.colors.power.INSANITY = {126 / 255, 69 / 255, 180 / 255} -- Munsell 2.5P 4/14 (#7e45b4)
oUF.colors.power.MANA = {COLORS.BLUE:GetRGB()}
oUF.colors.power.RUNES = {107 / 255, 183 / 255, 238 / 255} -- Munsell 10B 7/8 (#6bb7ee)
oUF.colors.power.SOUL_SHARDS = {150 / 255, 97 / 255, 210 / 255} -- Munsell 2.5P 5/14 (#9661d2)

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

for k, color in pairs(_G.ITEM_QUALITY_COLORS) do
	COLORS.ITEM_QUALITY[k + 1] = E:CreateColor(color.r, color.g, color.b)
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
	MY_HEAL = E:CreateColor(52, 140, 53), -- Munsell 10GY 5/10 (#348c35)
	OTHER_HEAL = E:CreateColor(42, 111, 45), -- Munsell 10GY 4/8 (#2a6f2d)
	HEAL_ABSORB = COLORS.DARK_RED,
	DAMAGE_ABSORB = E:CreateColor(190, 201, 239), -- Munsell 5PB 8/4 (#bec9ef)
}

COLORS.FACTION = {
	ALLIANCE = E:CreateColor(74, 89, 184), -- Munsell 7.5PB 4/12 (#4a59b8)
	HORDE = E:CreateColor(218, 41, 28), -- Munsell 7.5R 5/16 (#e8332e)
	NEUTRAL = COLORS.WHITE,
}

COLORS.DISCONNECTED = COLORS.GRAY
COLORS.HEALTH = COLORS.GREEN
COLORS.TAPPED = COLORS.GRAY

COLORS.ARTIFACT = E:CreateColor(230, 204, 128) -- Blizzard Artefact Colour (#e6cc80)
COLORS.HONOR = COLORS.RED
COLORS.XP = COLORS.BLUE

M.COLORS = COLORS

local textures = {
	icons = {
		-- first line
		["LEADER"] = {1 / 256, 33 / 256, 1 / 256, 33 / 256},
		["DAMAGER"] = {34 / 256, 66 / 256, 1 / 256, 33 / 256},
		["HEALER"] = {67 / 256, 99 / 256, 1 / 256, 33 / 256},
		["TANK"] = {100 / 256, 132 / 256, 1 / 256, 33 / 256},
		["RESTING"] = {133 / 256, 165 / 256, 1 / 256, 33 / 256},
		["COMBAT"] = {166 / 256, 198 / 256, 1 / 256, 33 / 256},
		["HORDE"] = {199 / 256, 231 / 256, 1 / 256, 33 / 256},
		-- second line
		["ALLIANCE"] = {1 / 256, 33 / 256, 34 / 256, 66 / 256},
		["FFA"] = {34 / 256, 66 / 256, 34 / 256, 66 / 256},
		["PHASE"] = {67 / 256, 99 / 256, 34 / 256, 66 / 256},
		["QUEST"] = {100 / 256, 132 / 256, 34 / 256, 66 / 256},
		["SHEEP"] = {133 / 256, 165 / 256, 34 / 256, 66 / 256},
		-- ["TEMP"] = {166 / 256, 198 / 256, 34 / 256, 66 / 256},
		-- ["TEMP"] = {199 / 256, 231 / 256, 34 / 256, 66 / 256},
		-- third line
		-- ["TEMP"] = {1 / 256, 33 / 256, 67 / 256, 99 / 256},
		-- ["TEMP"] = {34 / 256, 66 / 256, 67 / 256, 99 / 256},
		-- ["TEMP"] = {67 / 256, 99 / 256, 67 / 256, 99 / 256},
		-- ["TEMP"] = {100 / 256, 132 / 256, 67 / 256, 99 / 256},
		-- ["TEMP"] = {133 / 256, 165 / 256, 67 / 256, 99 / 256},
		-- ["TEMP"] = {166 / 256, 198 / 256, 67 / 256, 99 / 256},
		-- ["TEMP"] = {199 / 256, 231 / 256, 67 / 256, 99 / 256},
		-- fourth line
		-- ["TEMP"] = {1 / 256, 33 / 256, 100 / 256, 132 / 256},
		-- ["TEMP"] = {34 / 256, 66 / 256, 100 / 256, 132 / 256},
		-- ["TEMP"] = {67 / 256, 99 / 256, 100 / 256, 132 / 256},
		-- ["TEMP"] = {100 / 256, 132 / 256, 100 / 256, 132 / 256},
		-- ["TEMP"] = {133 / 256, 165 / 256, 100 / 256, 132 / 256},
		-- ["TEMP"] = {166 / 256, 198 / 256, 100 / 256, 132 / 256},
		-- ["TEMP"] = {199 / 256, 231 / 256, 100 / 256, 132 / 256},
		-- fifth line
		-- ["TEMP"] = {1 / 256, 33 / 256, 133 / 256, 165 / 256},
		-- ["TEMP"] = {34 / 256, 66 / 256, 133 / 256, 165 / 256},
		-- ["TEMP"] = {67 / 256, 99 / 256, 133 / 256, 165 / 256},
		-- ["TEMP"] = {100 / 256, 132 / 256, 133 / 256, 165 / 256},
		-- ["TEMP"] = {133 / 256, 165 / 256, 133 / 256, 165 / 256},
		-- ["TEMP"] = {166 / 256, 198 / 256, 133 / 256, 165 / 256},
		-- ["TEMP"] = {199 / 256, 231 / 256, 133 / 256, 165 / 256},
		-- sixth line
		["WARRIOR"] = {1 / 256, 33 / 256, 166 / 256, 198 / 256},
		["MAGE"] = {34 / 256, 66 / 256, 166 / 256, 198 / 256},
		["ROGUE"] = {67 / 256, 99 / 256, 166 / 256, 198 / 256},
		["DRUID"] = {100 / 256, 132 / 256, 166 / 256, 198 / 256},
		["HUNTER"] = {133 / 256, 165 / 256, 166 / 256, 198 / 256},
		["SHAMAN"] = {166 / 256, 198 / 256, 166 / 256, 198 / 256},
		["PRIEST"] = {199 / 256, 231 / 256, 166 / 256, 198 / 256},
		-- seventh line
		["WARLOCK"] = {1 / 256, 33 / 256, 199 / 256, 231 / 256},
		["PALADIN"] = {34 / 256, 66 / 256, 199 / 256, 231 / 256},
		["DEATHKNIGHT"] = {67 / 256, 99 / 256, 199 / 256, 231 / 256},
		["MONK"] = {100 / 256, 132 / 256, 199 / 256, 231 / 256},
		["DEMONHUNTER"] = {133 / 256, 165 / 256, 199 / 256, 231 / 256},
		-- ["TEMP"] = {166 / 256, 198 / 256, 199 / 256, 231 / 256},
		-- ["TEMP"] = {199 / 256, 231 / 256, 199 / 256, 231 / 256},
	},
	inlineicons = {
		-- first line
		["LEADER"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:1:33:1:33|t",
		["DAMAGER"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:34:66:1:33|t",
		["HEALER"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:67:99:1:33|t",
		["TANK"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:100:132:1:33|t",
		["RESTING"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:133:165:1:33|t",
		["COMBAT"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:166:198:1:33|t",
		["HORDE"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:199:231:1:33|t",
		-- second line
		["ALLIANCE"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:1:33:34:66|t",
		["FFA"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:34:66:34:66|t",
		["PHASE"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:67:99:34:66|t",
		["QUEST"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:100:132:34:66|t",
		["SHEEP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:133:165:34:66|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:166:198:34:66|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:199:231:34:66|t",
		-- third line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:1:33:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:34:66:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:67:99:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:100:132:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:133:165:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:166:198:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:199:231:67:99|t",
		-- fourth line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:1:33:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:34:66:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:67:99:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:100:132:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:133:165:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:166:198:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:199:231:100:132|t",
		-- fifth line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:1:33:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:34:66:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:67:99:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:100:132:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:133:165:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:166:198:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:199:231:133:165|t",
		-- sixth line
		["WARRIOR"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:1:33:166:198|t",
		["MAGE"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:34:66:166:198|t",
		["ROGUE"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:67:99:166:198|t",
		["DRUID"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:100:132:166:198|t",
		["HUNTER"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:133:165:166:198|t",
		["SHAMAN"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:166:198:166:198|t",
		["PRIEST"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:199:231:166:198|t",
		-- seventh line
		["WARLOCK"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:1:33:199:231|t",
		["PALADIN"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:34:66:199:231|t",
		["DEATHKNIGHT"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:67:99:199:231|t",
		["MONK"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:100:132:199:231|t",
		["DEMONHUNTER"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:133:165:199:231|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:166:198:199:231|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\media\\unit-frame-icons:%d:%d:0:0:256:256:199:231:199:231|t",
	},
}

M.textures = textures

E.OMNICC = select(4, _G.GetAddOnInfo("OmniCC"))

E.PLAYER_CLASS = select(2, _G.UnitClass("player"))
E.PLAYER_SPEC_FLAGS = {
	-- [-1] = 0x00000000, -- none
	-- [0] = 0x00000000, -- all
	[1] = 0x00000001, -- 1st
	[2] = 0x00000002, -- 2nd
	[3] = 0x00000004, -- 3rd
	[4] = 0x00000008, -- 4th
}

E.SCREEN_HEIGHT = E:Round(_G.UIParent:GetTop())
E.SCREEN_WIDTH = E:Round(_G.UIParent:GetRight())
E.SCREEN_SCALE = _G.UIParent:GetScale()

local function UpdateScreenConstants()
	E.SCREEN_HEIGHT = E:Round(_G.UIParent:GetTop())
	E.SCREEN_WIDTH = E:Round(_G.UIParent:GetRight())
	E.SCREEN_SCALE = _G.UIParent:GetScale()
end

E:RegisterEvent("DISPLAY_SIZE_CHANGED", UpdateScreenConstants)
E:RegisterEvent("UI_SCALE_CHANGED", UpdateScreenConstants)

-- Everything that's not available at ADDON_LOADED goes here
function E:UpdateConstants()
	E.PLAYER_SPEC_FLAGS[0] = 0

	for i = 1, _G.GetNumSpecializations() do
		E.PLAYER_SPEC_FLAGS[0] = E:EnableFlag(E.PLAYER_SPEC_FLAGS[0], E.PLAYER_SPEC_FLAGS[i])
	end

	E.PLAYER_GUID = _G.UnitGUID("player")
end

do
	local mixin = {}

	function mixin:SetVertexColor(r, g, b, a)
		self.Fill:SetVertexColor(r, g, b, a or 1)
		self.FillScroll1:SetVertexColor(r, g, b, a or 1)
		self.FillScroll2:SetVertexColor(r, g, b, a or 1)
	end

	function mixin:GetVertexColor()
		return self.Fill:GetVertexColor()
	end

	function mixin:SetThickness(thickness)
		self.Fill:SetThickness(thickness)
		self.FillScroll1:SetThickness(thickness)
		self.FillScroll2:SetThickness(thickness)
	end

	function mixin:SetOrientation(flag)
		if flag == "HORIZONTAL" then
			self.orientation = flag

			self.Fill:SetStartPoint("LEFT", self)
			self.FillScroll1:SetStartPoint("LEFT", self)
			self.FillScroll2:SetStartPoint("LEFT", self)

			self.Fill:SetEndPoint("RIGHT", self)
			self.FillScroll1:SetEndPoint("RIGHT", self)
			self.FillScroll2:SetEndPoint("RIGHT", self)
		else
			self.orientation = "VERTICAL"

			self.Fill:SetStartPoint("BOTTOM", self)
			self.FillScroll1:SetStartPoint("BOTTOM", self)
			self.FillScroll2:SetStartPoint("BOTTOM", self)

			self.Fill:SetEndPoint("TOP", self)
			self.FillScroll1:SetEndPoint("TOP", self)
			self.FillScroll2:SetEndPoint("TOP", self)
		end
	end

	function mixin:OnLoad()
		self:SetOrientation("HORIZONTAL")
		self:SetThickness(16 * E.SCREEN_SCALE)
		self:RegisterEvent("DISPLAY_SIZE_CHANGED")
		self:RegisterEvent("UI_SCALE_CHANGED")
	end

	function mixin:OnEvent()
		self:SetThickness(16 * E.SCREEN_SCALE)
	end

	function mixin:AdjustTiling()
		self.tileAmount = self.orientation == "HORIZONTAL" and self:GetWidth() / 128 or self:GetHeight() / 128

		self.Fill:SetTexCoord(0, self.tileAmount, 0, 1)
		self.FillScroll1:SetTexCoord(0, self.tileAmount, 0, 1)
		self.FillScroll2:SetTexCoord(0, self.tileAmount, 0, 1)
	end

	LSUILineMixin = mixin
end
