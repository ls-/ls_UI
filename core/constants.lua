local addon, ns = ...
local E, M, oUF = ns.E, ns.M, ns.oUF

-- Lua
local _G = getfenv(0)
local string = _G.string
local pairs = _G.pairs
local select = _G.select
local type = _G.type
local unpack = _G.unpack

-- Mine
local hidden = _G.CreateFrame("Frame", nil, UIParent)
hidden:Hide()
E.HIDDEN_PARENT = hidden

E.NOA = hidden:CreateAnimationGroup()
E.NOOP = function() end

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
	icons_inline = {
		-- first line
		["LEADER"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:1:33:1:33|t",
		["DAMAGER"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:34:66:1:33|t",
		["HEALER"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:67:99:1:33|t",
		["TANK"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:100:132:1:33|t",
		["RESTING"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:133:165:1:33|t",
		["COMBAT"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:166:198:1:33|t",
		["HORDE"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:199:231:1:33|t",
		-- second line
		["ALLIANCE"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:1:33:34:66|t",
		["FFA"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:34:66:34:66|t",
		["PHASE"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:67:99:34:66|t",
		["PHASE_WM"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:100:132:34:66|t",
		["QUEST"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:133:165:34:66|t",
		["SHEEP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:166:198:34:66|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:199:231:34:66|t",
		-- third line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:1:33:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:34:66:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:67:99:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:100:132:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:133:165:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:166:198:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:199:231:67:99|t",
		-- fourth line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:1:33:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:34:66:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:67:99:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:100:132:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:133:165:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:166:198:100:132|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:199:231:100:132|t",
		-- fifth line
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:1:33:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:34:66:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:67:99:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:100:132:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:133:165:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:166:198:133:165|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:199:231:133:165|t",
		-- sixth line
		["WARRIOR"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:1:33:166:198|t",
		["MAGE"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:34:66:166:198|t",
		["ROGUE"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:67:99:166:198|t",
		["DRUID"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:100:132:166:198|t",
		["HUNTER"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:133:165:166:198|t",
		["SHAMAN"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:166:198:166:198|t",
		["PRIEST"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:199:231:166:198|t",
		-- seventh line
		["WARLOCK"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:1:33:199:231|t",
		["PALADIN"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:34:66:199:231|t",
		["DEATHKNIGHT"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:67:99:199:231|t",
		["MONK"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:100:132:199:231|t",
		["DEMONHUNTER"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:133:165:199:231|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:166:198:199:231|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-icons:%.2f:%.2f:0:0:256:256:199:231:199:231|t",
	},
	aura_icons = {
		-- line #1
		["Buff"] = {1 / 128, 33 / 128, 1 / 128, 33 / 128},
		["Debuff"] = {34 / 128, 66 / 128, 1 / 128, 33 / 128},
		["Curse"] = {67 / 128, 99 / 128, 1 / 128, 33 / 128},
		-- line #2
		["Disease"] = {1 / 128, 33 / 128, 34 / 128, 66 / 128},
		["Magic"] = {34 / 128, 66 / 128, 34 / 128, 66 / 128},
		["Poison"] = {67 / 128, 99 / 128, 34 / 128, 66 / 128},
		-- line #3
		[""] = {1 / 128, 33 / 128, 67 / 128, 99 / 128}, -- Enrage
		-- ["TEMP"] = {34 / 128, 66 / 128, 67 / 128, 99 / 128},
		-- ["TEMP"] = {67 / 128, 99 / 128, 67 / 128, 99 / 128},
	},
	aura_icons_inline = {
		-- line #1
		["Buff"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:1:33:1:33|t",
		["Debuff"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:34:66:1:33|t",
		["Curse"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:67:99:1:33|t",
		-- line #2
		["Disease"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:1:33:34:66|t",
		["Magic"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:34:66:34:66|t",
		["Poison"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:67:99:34:66|t",
		-- line #3
		[""] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:1:33:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:34:66:67:99|t",
		-- ["TEMP"] = "|TInterface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons:0:0:0:0:128:128:67:99:67:99|t",

	}
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

E.SCREEN_HEIGHT = E:Round(UIParent:GetTop())
E.SCREEN_WIDTH = E:Round(UIParent:GetRight())
E.SCREEN_SCALE = UIParent:GetScale()

E.VER = {
	string = _G.GetAddOnMetadata(addon, "Version")
}
E.VER.number = tonumber(E.VER.string:gsub("%D", ""), nil)

local function UpdateScreenConstants()
	E.SCREEN_HEIGHT = E:Round(UIParent:GetTop())
	E.SCREEN_WIDTH = E:Round(UIParent:GetRight())
	E.SCREEN_SCALE = UIParent:GetScale()
end

E.NAME_REALM = _G.UnitName("player") .. " - " .. _G.GetRealmName()

E:RegisterEvent("DISPLAY_SIZE_CHANGED", UpdateScreenConstants)
E:RegisterEvent("UI_SCALE_CHANGED", UpdateScreenConstants)

-- Everything that's not available at ADDON_LOADED goes here
function E:UpdateConstants()
	E.PLAYER_GUID = _G.UnitGUID("player")
end
