local _, ns = ...
local E, D, PrD = ns.E, ns.D, ns.PrD

-- Lua
local _G = getfenv(0)

-- Mine
local defaultFont = LibStub("LibSharedMedia-3.0"):GetDefault("font")

local function rgb(r, g, b)
	return E:CreateColor(r, g, b)
end

D.global = {
	colors = {
		red = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
		green = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
		blue = rgb(38, 125, 206), -- #267DCE (5PB 5/12)
		yellow = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
		gray = rgb(136, 137, 135), -- #888987 (N5)
		light_gray = rgb(202, 202, 202), -- #CACACA (N8)
		dark_gray = rgb(59, 58, 58), -- #3B3A3A (N2)
		black = rgb(0, 0, 0), -- #000000
		white = rgb(255, 255, 255), -- #FFFFFF
		orange = rgb(230, 118, 47), -- #E6762F (2.5YR 6/12)
		class = {
			HUNTER = rgb(170, 211, 114), -- #AAD372 (Blizzard Colour)
			WARLOCK = rgb(135, 135, 237), -- #8787ED (Blizzard Colour)
			PRIEST = rgb(255, 255, 255), -- #FFFFFF (Blizzard Colour)
			PALADIN = rgb(244, 140, 186), -- #F48CBA (Blizzard Colour)
			MAGE = rgb(63, 198, 234), -- #3FC6EA (Blizzard Colour)
			ROGUE = rgb(255, 244, 104), -- #FFF468 (Blizzard Colour)
			DRUID = rgb(255, 124, 10), -- #FF7C0A (Blizzard Colour)
			SHAMAN = rgb(0, 112, 221), -- #0070DD (Blizzard Colour)
			WARRIOR = rgb(198, 155, 109), -- #C69B6D (Blizzard Colour)
			DEATHKNIGHT = rgb(196, 30, 58), -- #C41E3A (Blizzard Colour)
			MONK = rgb(0, 255, 150), -- #00FF96 (Blizzard Colour)
			DEMONHUNTER = rgb(163, 48, 201), -- #A330C9 (Blizzard Colour)
			EVOKER = rgb(51, 147, 127), -- #33937f (Blizzard Colour)
		},
		threat = {
			[1] = rgb(175, 175, 175), -- #AFAFAF (Blizzard Colour)
			[2] = rgb(254, 254, 118), -- #FEFE76 (Blizzard Colour)
			[3] = rgb(254, 152, 0), -- #FE9800 (Blizzard Colour)
			[4] = rgb(254, 0, 0), -- #FE0000 (Blizzard Colour)
		},
		quality = {
			[0] = rgb(157, 157, 157), -- #9D9D9D (Blizzard Colour)
			[1] = rgb(255, 255, 255), -- #FFFFFF (Blizzard Colour)
			[2] = rgb(30, 255, 0), -- #1EFF00 (Blizzard Colour)
			[3] = rgb(0, 112, 221), -- #0070DD (Blizzard Colour)
			[4] = rgb(163, 53, 238), -- #A334EE (Blizzard Colour)
			[5] = rgb(255, 128, 0), -- #FF8000 (Blizzard Colour)
			[6] = rgb(230, 204, 128), -- #E6CC80 (Blizzard Colour)
			[7] = rgb(0, 204, 255), -- #00CCFF (Blizzard Colour)
			[8] = rgb(0, 204, 255), -- #00CCFF (Blizzard Colour)
		},
		gyr = {
			[1] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			[2] = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			[3] = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
		},
		ryg = {
			[1] = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			[2] = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			[3] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
		},
		button = {
			normal = rgb(255, 255, 255), -- #FFFFFF
			unusable = rgb(181, 182, 181), -- #B5B6B5 (N7)
			mana = rgb(32, 98, 165), -- #2062A5 (5PB 4/10)
			range = rgb(140, 29, 30), -- #8C1D1E (7.5R 3/10)
			equipped = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
		},
		castbar = {
			casting = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			empowering = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			channeling = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			failed = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			notinterruptible = rgb(136, 137, 135), -- #888987 (N5)
		},
		cooldown = {
			expiration = rgb(240, 32, 30), -- #F0201E (7.5R 5/18)
			second = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			minute = rgb(255, 255, 255), -- #FFFFFF
			hour = rgb(255, 255, 255), -- #FFFFFF
			day = rgb(255, 255, 255), -- #FFFFFF
		},
		disconnected = rgb(136, 137, 135), -- #888987 (N5)
		tapped = rgb(163, 162, 162), -- #A3A2A2 (N6)
		health = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
		power = {
			MANA = rgb(69, 155, 218), -- #459BDA (2.5PB 6/10)
			RAGE = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			FOCUS = rgb(230, 118, 47), -- #E6762F (2.5YR 6/12)
			ENERGY = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			COMBO_POINTS = rgb(215, 77, 18), -- #D74D12 (10R 5/14)
			COMBO_POINTS_CHARGED = rgb(62, 169, 126), -- #3EA97E (Comp to #D74D12)
			RUNES = rgb(99, 185, 228), -- #63B9E4 (10B 7/8)
			RUNIC_POWER = rgb(60, 190, 219), -- #3CBEDB (5B 7/8)
			SOUL_SHARDS = rgb(149, 99, 202), -- #9563CA (2.5P 5/14)
			LUNAR_POWER = rgb(72, 152, 235), -- #4898EB (5PB 6/12)
			HOLY_POWER = rgb(238, 234, 140), -- #EEEA8C (10Y 9/6)
			ALTERNATE = rgb(149, 134, 242), -- #9586F2 (10PB 6/14)
			MAELSTROM = rgb(38, 125, 206), -- #267DCE (5PB 5/12)
			INSANITY = rgb(125, 70, 174), -- #7D46AE (2.5P 4/14)
			CHI = rgb(108, 254, 214), -- #6CFED6 (10G 9/6)
			ARCANE_CHARGES = rgb(28, 129, 191), -- #1C81BF (2.5PB 5/10)
			FURY = rgb(187, 57, 231), -- #BB39E7 (5P 5/22)
			PAIN = rgb(243, 157, 28), -- #F39D1C (7.5YR 7/12)
			AMMOSLOT = rgb(217, 169, 35), -- #D9A923 (2.5Y 7/10)
			FUEL = rgb(42, 137, 122), -- #2A897A (2.5BG 5/6)
			STAGGER = {
				-- low
				[1] = rgb(111, 255, 99), -- #6FFF63 (10GY 9/14)
				-- medium
				[2] = rgb(229, 237, 142), -- #E5ED8E (2.5GY 9/6)
				-- high
				[3] = rgb(211, 77, 81), -- #D34D51 (5R 5/12)
			},
			ESSENCE = rgb(79, 188, 225), -- #4FBCE1 (7.5B 7/8)
		},
		reaction = {
			-- hated
			[1] = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			-- hostile
			[2] = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			-- unfriendly
			[3] = rgb(230, 118, 47), -- #E6762F (2.5YR 6/12)
			-- neutral
			[4] = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			-- friendly
			[5] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- honored
			[6] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- revered
			[7] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- exalted
			[8] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- renown, fake
			[9] = rgb(0, 191, 243), -- #00BFF3 (Blizzard Colour)
		},
		selection = {
			-- hostile
			[ 0] = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			-- unfriendly
			[ 1] = rgb(230, 118, 47), -- #E6762F (2.5YR 6/12)
			-- neutral
			[ 2] = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			-- friendly
			[ 3] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- player_simple
			[ 4] = rgb(0, 0, 255), -- #0000FF (Blizzard Colour)
			-- player_extended
			[ 5] = rgb(96, 96, 255), -- #6060FF (Blizzard Colour)
			-- party
			[ 6] = rgb(170, 170, 255), -- #AAAAFF (Blizzard Colour)
			-- party_pvp
			[ 7] = rgb(170, 255, 170), -- #AAFFAA (Blizzard Colour)
			-- friend
			[ 8] = rgb(83, 201, 255), -- #53C9FF (Blizzard Colour)
			-- dead
			[ 9] = rgb(136, 137, 135), -- #888987 (N5)
			-- commentator_team_1, unavailable to players
			-- [10] = {},
			-- commentator_team_2, unavailable to players
			-- [11] = {},
			-- self, buggy
			-- [12] = {},
			-- battleground_friendly_pvp
			[13] = rgb(0, 153, 0), -- #009900 (Blizzard Colour)
		},
		difficulty = {
			impossible = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			very_difficult = rgb(230, 118, 47), -- #E6762F (2.5YR 6/12)
			difficult = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			standard = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			trivial = rgb(136, 137, 135), -- #888987 (N5)
		},
		faction = {
			-- Alliance = rgb(74, 84, 232), -- #4A54E8 (Blizzard Colour)
			Alliance = rgb(64, 84, 202), -- #4054CA (7.5PB 4/16)
			-- Horde = rgb(230, 13, 18), -- #E60D12 (Blizzard Colour)
			Horde = rgb(231, 53, 42), -- #E7352A (7.5R 5/16)
			Neutral = rgb(233, 232, 231) -- #E9E8E7 (N9)
		},
		honor = rgb(255, 77, 35), -- #FF4D23 (Blizzard Colour)
		xp = {
			-- rested
			[1] = rgb(0, 99, 224), -- #0063E0 (Blizzard Colour)
			-- normal
			[2] = rgb(147.9, 0.0, 140.25), -- #94008C (Blizzard Colour)
		},
		prediction = {
			my_heal = rgb(20, 228, 187), -- #14E4BB (10G 8/10)
			other_heal = rgb(11, 169, 139), -- #0BA98B (10G 6/8)
			damage_absorb = rgb(53, 187, 244), -- #35BBF4 (10B 7/10)
			heal_absorb = rgb(178, 50, 43), -- #B2322B (7.5R 4/12)
			power_cost = rgb(120, 181, 231), -- #78B5E7 (2.5PB 7/8)
		},
		zone = {
			contested = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			friendly = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			hostile = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			sanctuary = rgb(80, 219, 249), -- #50DBF9 (5B 8/8)
			-- sanctuary = rgb(104, 204, 239) -- #68CCEF (Blizzard Colour)
		},
		debuff = {
			None = rgb(204, 0, 0), -- #CC0000 (Blizzard Colour)
			Magic = rgb(51, 153, 255), -- #3399FF (Blizzard Colour)
			Curse = rgb(153, 0, 255), -- #9900FF (Blizzard Colour)
			Disease = rgb(153, 102, 0), -- #996600 (Blizzard Colour)
			Poison = rgb(0, 153, 0), -- #009900 (Blizzard Colour)
		},
		buff = {
			["Enchant"] = rgb(123, 44, 181), -- #7B2CB5 (Blizzard Colour)
			-- enrage
			[""] = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
		},
		rune = {
			-- blood
			[1] = rgb(255, 63, 58), -- #FF3F3A
			-- frost
			[2] = rgb(36, 149, 154), -- #24959A (Split comp to #FF3F3A at 30°)
			-- unholy
			[3] = rgb(174, 237, 54), -- #B0EF37 (Split comp to #FF3F3A at 30°)
		},
	},
	fonts = {
		cooldown = {
			font = defaultFont,
			outline = true,
			shadow = false,
		},
		unit = {
			font = defaultFont,
			outline = false,
			shadow = true,
		},
		button = {
			font = defaultFont,
			outline = true,
			shadow = false,
		},
		statusbar = {
			font = defaultFont,
			outline =  false,
			shadow = true,
		},
		blizzard = {},
	},
	tags = {
		["ls:absorb:damage"] = {
			events = "UNIT_ABSORB_AMOUNT_CHANGED",
			func = "function(unit)\n  local absorb = UnitGetTotalAbsorbs(unit) or 0\n  return absorb > 0 and _VARS.E:FormatNumber(absorb) or \" \"\nend",
		},
		["ls:absorb:heal"] = {
			events = "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
			func = "function(unit)\n  local absorb = UnitGetTotalHealAbsorbs(unit) or 0\n  return absorb > 0 and _VARS.E:FormatNumber(absorb) or \" \"\nend",
		},
		["ls:altpower:cur"] = {
			events = "UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER",
			func = "function(unit)\n  if GetUnitPowerBarInfo(unit) then\n    return _VARS.E:FormatNumber(UnitPower(unit, ALTERNATE_POWER_INDEX))\n  end\n\n  return \"\"\nend",
		},
		["ls:altpower:cur-max"] = {
			events = "UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER",
			func = "function(unit)\n  if GetUnitPowerBarInfo(unit) then\n    local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)\n    if cur == max then\n      return _VARS.E:FormatNumber(cur)\n    else\n      return string.format(\"%s - %s\", _VARS.E:FormatNumber(cur), _VARS.E:FormatNumber(max))\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:altpower:cur-perc"] = {
			events = "UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER",
			func = "function(unit)\n  if GetUnitPowerBarInfo(unit) then\n    local cur, max = UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)\n    if cur == max then\n      return _VARS.E:FormatNumber(cur)\n    else\n      return string.format(\"%s - %.1f%%\", _VARS.E:FormatNumber(cur), _VARS.E:NumberToPerc(cur, max))\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:altpower:max"] = {
			events = "UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER",
			func = "function(unit)\n  if GetUnitPowerBarInfo(unit) then\n    return _VARS.E:FormatNumber(UnitPowerMax(unit, ALTERNATE_POWER_INDEX))\n  end\n\n  return \"\"\nend",
		},
		["ls:altpower:perc"] = {
			events = "UNIT_POWER_BAR_SHOW UNIT_POWER_BAR_HIDE UNIT_POWER_UPDATE UNIT_MAXPOWER",
			func = "function(unit)\n  if GetUnitPowerBarInfo(unit) then\n    return string.format(\"%.1f%%\", _VARS.E:NumberToPerc(UnitPower(unit, ALTERNATE_POWER_INDEX), UnitPowerMax(unit, ALTERNATE_POWER_INDEX)))\n  end\n\n  return \"\"\nend",
		},
		["ls:classicon"] = {
			events = "UNIT_CLASSIFICATION_CHANGED",
			func = "function(unit)\n  if UnitIsPlayer(unit) then\n    local _, class = UnitClass(unit)\n    if class then\n      return _VARS.INLINE_ICONS[class]:format(0, 0)\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:color:absorb-damage"] = {
			func = "function()\n  return \"|c\" .. _VARS.COLORS.prediction.damage_absorb.hex\nend",
		},
		["ls:color:absorb-heal"] = {
			func = "function()\n  return \"|c\" .. _VARS.COLORS.prediction.heal_absorb.hex\nend",
		},
		["ls:color:altpower"] = {
			func = "function()\n  return \"|c\" .. _VARS.POWER_COLORS.ALTERNATE.hex\nend",
		},
		["ls:color:class"] = {
			func = "function(unit)\n  if UnitIsPlayer(unit) then\n    local _, class = UnitClass(unit)\n    if class then\n      return \"|c\" .. _VARS.CLASS_COLORS[class].hex\n    end\n  end\n\n  return \"|cffffffff\"\nend", events = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE",
		},
		["ls:color:difficulty"] = {
			events = "UNIT_LEVEL PLAYER_LEVEL_UP",
			func = "function(unit)\n  return \"|c\" .. _VARS.E:GetCreatureDifficultyColor(unit):GetHex()\nend",
		},
		["ls:color:power"] = {
			func = "function(unit)\n  local type, _, r, g, b = UnitPowerType(unit)\n  if not r then\n    return \"|c\" .. _VARS.POWER_COLORS[type].hex\n  else\n    if r > 1 or g > 1 or b > 1 then\n      r, g, b = r / 255, g / 255, b / 255\n    end\n\n    return Hex(r, g, b)\n  end\nend",
		},
		["ls:color:reaction"] = {
			events = "UNIT_FACTION UNIT_NAME_UPDATE",
			func = "function(unit)\n  local reaction = UnitReaction(unit, 'player')\n  if reaction then\n    return \"|c\" .. _VARS.REACTION_COLORS[reaction].hex\n  end\n\n  return \"|cffffffff\"\nend",
		},
		["ls:color:threat"] = {
			events = "UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE",
			func = "function(unit, realUnit)\n  local status = UnitThreatSituation(\"player\", realUnit or unit)\n  if status then\n    return \"|c\" .. _VARS.COLORS.threat[status + 1].hex\n  end\nend",
		},
		["ls:combatresticon"] = {
			events = "PLAYER_UPDATE_RESTING PLAYER_REGEN_DISABLED PLAYER_REGEN_ENABLED",
			func = "function()\n  if UnitAffectingCombat(\"player\") then\n    return _VARS.INLINE_ICONS[\"COMBAT\"]:format(0, 0)\n  elseif IsResting() then\n    return _VARS.INLINE_ICONS[\"RESTING\"]:format(0, 0)\n  end\n\n  return \"\"\nend",
		},
		["ls:debuffs"] = {
			events = "UNIT_AURA",
			func = "function(unit)\n  if not UnitCanAssist(\"player\", unit) then\n    return \"\"\n  end\n\n  local hasDebuff = {Curse = false, Disease = false, Magic = false, Poison = false}\n  local status = \"\"\n\n  for i = 1, 40 do\n    local name, _, _, type = UnitDebuff(unit, i, \"RAID\")\n    if not name then\n      break\n    end\n\n    if _VARS.E:IsDispellable(type) and not hasDebuff[type] then\n      status = status .. _VARS.INLINE_AURA_ICONS[type]\n      hasDebuff[type] = true\n    end\n  end\n\n  return status\nend",
		},
		["ls:health:cur"] = {
			events = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
			func = "function(unit)\n  if not UnitIsConnected(unit) then\n    return _VARS.L[\"OFFLINE\"]\n  elseif UnitIsDeadOrGhost(unit) then\n    return _VARS.L[\"DEAD\"]\n  else\n    return _VARS.E:FormatNumber(UnitHealth(unit))\n  end\nend",
		},
		["ls:health:cur-perc"] = {
			events = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
			func = "function(unit)\n  if not UnitIsConnected(unit) then\n    return _VARS.L[\"OFFLINE\"]\n  elseif UnitIsDeadOrGhost(unit) then\n    return _VARS.L[\"DEAD\"]\n  else\n    local cur, max = UnitHealth(unit), UnitHealthMax(unit)\n    if cur == max then\n      return _VARS.E:FormatNumber(cur)\n    else\n      return string.format(\"%s - %.1f%%\", _VARS.E:FormatNumber(cur), _VARS.E:NumberToPerc(cur, max))\n    end\n  end\nend",
		},
		["ls:health:deficit"] = {
			events = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
			func = "function(unit)\n  if not UnitIsConnected(unit) then\n    return _VARS.L[\"OFFLINE\"]\n  elseif UnitIsDeadOrGhost(unit) then\n    return _VARS.L[\"DEAD\"]\n  else\n    local cur, max = UnitHealth(unit), UnitHealthMax(unit)\n    if max and cur ~= max then\n      return string.format(\"-%s\", _VARS.E:FormatNumber(max - cur))\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:health:perc"] = {
			events = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED",
			func = "function(unit)\n  if not UnitIsConnected(unit) then\n    return _VARS.L[\"OFFLINE\"]\n  elseif UnitIsDeadOrGhost(unit) then\n    return _VARS.L[\"DEAD\"]\n  else\n    return string.format(\"%.1f%%\", _VARS.E:NumberToPerc(UnitHealth(unit), UnitHealthMax(unit)))\n  end\nend",
		},
		["ls:leadericon"] = {
			events = "PARTY_LEADER_CHANGED GROUP_ROSTER_UPDATE",
			func = "function(unit)\n  if (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit) then\n    return _VARS.INLINE_ICONS[\"LEADER\"]:format(0, 0)\n  end\n\n  return \"\"\nend",
		},
		["ls:level"] = {
			events = "UNIT_LEVEL PLAYER_LEVEL_UP",
			func = "function(unit)\n  local level\n\n  if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then\n    level = UnitBattlePetLevel(unit)\n  else\n    level = UnitLevel(unit)\n  end\n\n  return level > 0 and level or \"??\"\nend",
		},
		["ls:level:effective"] = {
			events = "UNIT_LEVEL PLAYER_LEVEL_UP",
			func = "function(unit)\n  local level\n\n  if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then\n    level = UnitBattlePetLevel(unit)\n  else\n    level = UnitEffectiveLevel(unit)\n  end\n\n  return level > 0 and level or \"??\"\nend",
		},
		["ls:lfdroleicon"] = {
			events = "GROUP_ROSTER_UPDATE",
			func = "function(unit)\n  local role = UnitGroupRolesAssigned(unit)\n  if role and role ~= \"NONE\" then\n    return _VARS.INLINE_ICONS[role]:format(0, 0)\n  end\n\n  return \"\"\nend",
		},
		["ls:name"] = {
			events = "UNIT_NAME_UPDATE",
			func = "function(unit, _, len)\n  local name = UnitName(unit) or \"\"\n  len = tonumber(len)\n  if len then\n    name = _VARS.E:TruncateString(name, len)\n  end\n  \n  return name\nend",
		},
		["ls:npc:type"] = {
			events = "UNIT_CLASSIFICATION_CHANGED UNIT_NAME_UPDATE",
			func = "function(unit)\n  local classification = UnitClassification(unit)\n  if classification == \"rare\" then\n    return \"R\"\n  elseif classification == \"rareelite\" then\n    return \"R+\"\n  elseif classification == \"elite\" then\n    return \"+\"\n  elseif classification == \"worldboss\" then\n    return \"B\"\n  elseif classification == \"minus\" then\n    return \"-\"\n  end\n\n  return \"\"\nend",
		},
		["ls:phaseicon"] = {
			events = "UNIT_PHASE",
			func = "function(unit)\n  local phaseReason = UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitPhaseReason(unit)\n  if phaseReason then\n    if phaseReason == Enum.PhaseReason.Phasing then\n      return _VARS.INLINE_ICONS.PHASE:format(0, 0)\n    elseif phaseReason == Enum.PhaseReason.Sharding then\n      return _VARS.INLINE_ICONS.SHARD:format(0, 0)\n    elseif phaseReason == Enum.PhaseReason.WarMode then\n      return _VARS.INLINE_ICONS.WM:format(0, 0)\n    elseif phaseReason == Enum.PhaseReason.ChromieTime then\n      return _VARS.INLINE_ICONS.CHROMIE:format(0, 0)\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:player:class"] = {
			events = "UNIT_CLASSIFICATION_CHANGED",
			func = "function(unit)\n  if UnitIsPlayer(unit) then\n    local class = UnitClass(unit)\n    if class then\n      return class\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:power:cur"] = {
			events = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER",
			func = "function(unit)\n  if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then\n    local type = UnitPowerType(unit)\n    local max = UnitPowerMax(unit, type)\n    if max and max ~= 0 then\n      return _VARS.E:FormatNumber(UnitPower(unit, type))\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:power:cur-max"] = {
			events = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER",
			func = "function(unit)\n  if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then\n    local type = UnitPowerType(unit)\n    local max = UnitPowerMax(unit, type)\n    if max and max ~= 0 then\n      local cur = UnitPower(unit, type)\n      if cur == max or cur == 0 then\n        return _VARS.E:FormatNumber(cur)\n      else\n        return string.format(\"%s - %s\", _VARS.E:FormatNumber(cur), _VARS.E:FormatNumber(max))\n      end\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:power:cur-perc"] = {
			events = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER",
			func = "function(unit)\n  if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then\n    local type = UnitPowerType(unit)\n    local max = UnitPowerMax(unit, type)\n    if max and max ~= 0 then\n      local cur = UnitPower(unit, type)\n      if cur == 0 or cur == max then\n        return _VARS.E:FormatNumber(cur)\n      else\n        return string.format(\"%s - %.1f%%\", _VARS.E:FormatNumber(cur), _VARS.E:NumberToPerc(cur, max))\n      end\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:power:deficit"] = {
			events = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER",
			func = "function(unit)\n  if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then\n    local type = UnitPowerType(unit)\n    local cur, max = UnitPower(unit, type), UnitPowerMax(unit, type)\n    if max and cur ~= max then\n      return string.format(\"-%s\", _VARS.E:FormatNumber(max - cur))\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:power:max"] = {
			events = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER",
			func = "function(unit)\n  if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then\n    local type = UnitPowerType(unit)\n    local max = UnitPowerMax(unit, type)\n    if max and max ~= 0 then\n      return _VARS.E:FormatNumber(max)\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:power:perc"] = {
			events = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_CONNECTION PLAYER_FLAGS_CHANGED UNIT_DISPLAYPOWER",
			func = "function(unit)\n  if UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) then\n    local type = UnitPowerType(unit)\n    local max = UnitPowerMax(unit, type)\n    if max and max ~= 0 then\n      return string.format(\"%.1f%%\", _VARS.E:NumberToPerc(UnitPower(unit, type), max))\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:pvptimer"] = {
			func = "function()\n  if IsPVPTimerRunning() then\n    local remain = GetPVPTimer() / 1000\n    if remain >= 1 then\n      local time1, time2, format\n\n      if remain >= 60 then\n        time1, time2, format = _VARS.E:SecondsToTime(remain, \"x:xx\")\n      else\n        time1, time2, format = _VARS.E:SecondsToTime(remain)\n      end\n\n      return format:format(time1, time2)\n    end\n  end\nend",
		},
		["ls:questicon"] = {
			events = "UNIT_CLASSIFICATION_CHANGED",
			func = "function(unit)\n  if UnitIsQuestBoss(unit) then\n    return _VARS.INLINE_ICONS[\"QUEST\"]:format(0, 0)\n  end\n\n  return \"\"\nend",
		},
		["ls:server"] = {
			events = "UNIT_NAME_UPDATE",
			func = "function(unit)\n  local _, realm = UnitName(unit)\n  if realm and realm ~= \"\" then\n    local relationship = UnitRealmRelationship(unit)\n    if relationship ~= LE_REALM_RELATION_VIRTUAL then\n      return _VARS.L[\"FOREIGN_SERVER_LABEL\"]\n    end\n  end\n\n  return \"\"\nend",
		},
		["ls:threat"] = {
			events = "UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE",
			func = "function(unit, realUnit, output)\n  local _, status, scaledPercentage, rawPercentage = UnitDetailedThreatSituation(\"player\", realUnit or unit)\n  if status then\n    if output == \"raw\" then\n      return string.format(\"%d\", rawPercentage)\n    else\n      return string.format(\"%d\", scaledPercentage)\n    end\n  end\nend",
		},
		["ls:sheepicon"] = {
			events = "UNIT_CLASSIFICATION_CHANGED",
			vars = "{\n  [\"Beast\"] = true,\n  [\"Bestia\"] = true,\n  [\"Bête\"] = true,\n  [\"Fera\"] = true,\n  [\"Humanoid\"] = true,\n  [\"Humanoide\"] = true,\n  [\"Humanoïde\"] = true,\n  [\"Umanoide\"] = true,\n  [\"Wildtier\"] = true,\n  [\"Гуманоид\"] = true,\n  [\"Животное\"] = true,\n  [\"야수\"] = true,\n  [\"인간형\"] = true,\n  [\"人型生物\"] = true,\n  [\"人形生物\"] = true,\n  [\"野兽\"] = true,\n  [\"野獸\"] = true,\n}",
			func = "function(unit)\n  if (_VARS.E.PLAYER_CLASS == \"MAGE\" or _VARS.E.PLAYER_CLASS == \"SHAMAN\")\n    and UnitCanAttack(\"player\", unit) and (UnitIsPlayer(unit) or _VARS[\"ls:sheepicon\"][UnitCreatureType(unit)]) then\n    return _VARS.INLINE_ICONS[\"SHEEP\"]:format(0, 0)\n  end\n\n  return \"\"\nend",
		},
		["nl"] = {
			func = "function()\n  return \"\\n\"\nend",
		},
	},
	tag_vars = {
		["E"] = "ls_UI[1]",
		["M"] = "ls_UI[2]",
		["L"] = "ls_UI[3]",
		["C"] = "ls_UI[4]",
		["INLINE_ICONS"] = "ls_UI[2].textures.icons_inline",
		["INLINE_AURA_ICONS"] = "ls_UI[2].textures.aura_icons_inline",
		["COLORS"] = "ls_UI[4].db.global.colors",
		["CLASS_COLORS"] = "ls_UI[4].db.global.colors.class",
		["POWER_COLORS"] = "ls_UI[4].db.global.colors.power",
		["REACTION_COLORS"] = "ls_UI[4].db.global.colors.reaction",
	},
	aura_filters = {
		["Blacklist"] = {
			state = false,
			[  8326] = true, -- Ghost
			[ 26013] = true, -- Deserter
			[ 39953] = true, -- A'dal's Song of Battle
			[ 57819] = true, -- Argent Champion
			[ 57820] = true, -- Ebon Champion
			[ 57821] = true, -- Champion of the Kirin Tor
			[ 71041] = true, -- Dungeon Deserter
			[ 72968] = true, -- Precious's Ribbon
			[ 85612] = true, -- Fiona's Lucky Charm
			[ 85613] = true, -- Gidwin's Weapon Oil
			[ 85614] = true, -- Tarenar's Talisman
			[ 85615] = true, -- Pamela's Doll
			[ 85616] = true, -- Vex'tul's Armbands
			[ 85617] = true, -- Argus' Journal
			[ 85618] = true, -- Rimblat's Stone
			[ 85619] = true, -- Beezil's Cog
			[ 93337] = true, -- Champion of Ramkahen
			[ 93339] = true, -- Champion of the Earthen Ring
			[ 93341] = true, -- Champion of the Guardians of Hyjal
			[ 93347] = true, -- Champion of Therazane
			[ 93368] = true, -- Champion of the Wildhammer Clan
			[ 93795] = true, -- Stormwind Champion
			[ 93805] = true, -- Ironforge Champion
			[ 93806] = true, -- Darnassus Champion
			[ 93811] = true, -- Exodar Champion
			[ 93816] = true, -- Gilneas Champion
			[ 93821] = true, -- Gnomeregan Champion
			[ 93825] = true, -- Orgrimmar Champion
			[ 93827] = true, -- Darkspear Champion
			[ 93828] = true, -- Silvermoon Champion
			[ 93830] = true, -- Bilgewater Champion
			[ 94158] = true, -- Champion of the Dragonmaw Clan
			[ 94462] = true, -- Undercity Champion
			[ 94463] = true, -- Thunder Bluff Champion
			[ 97340] = true, -- Guild Champion
			[ 97341] = true, -- Guild Champion
			[126434] = true, -- Tushui Champion
			[126436] = true, -- Huojin Champion
			[143625] = true, -- Brawling Champion
			[170616] = true, -- Pet Deserter
			[182957] = true, -- Treasures of Stormheim
			[182958] = true, -- Treasures of Azsuna
			[185719] = true, -- Treasures of Val'sharah
			[186401] = true, -- Sign of the Skirmisher
			[186403] = true, -- Sign of Battle
			[186404] = true, -- Sign of the Emissary
			[186406] = true, -- Sign of the Critter
			[188741] = true, -- Treasures of Highmountain
			[199416] = true, -- Treasures of Suramar
			[225787] = true, -- Sign of the Warrior
			[225788] = true, -- Sign of the Emissary
			[227723] = true, -- Mana Divining Stone
			[231115] = true, -- Treasures of Broken Shore
			[233641] = true, -- Legionfall Commander
			[237137] = true, -- Knowledgeable
			[237139] = true, -- Power Overwhelming
			[239966] = true, -- War Effort
			[239967] = true, -- Seal Your Fate
			[239968] = true, -- Fate Smiles Upon You
			[239969] = true, -- Netherstorm
			[240979] = true, -- Reputable
			[240980] = true, -- Light As a Feather
			[240985] = true, -- Reinforced Reins
			[240986] = true, -- Worthy Champions
			[240987] = true, -- Well Prepared
			[240989] = true, -- Heavily Augmented
			[245686] = true, -- Fashionable!
			[264408] = true, -- Soldier of the Horde
			[264420] = true, -- Soldier of the Alliance
			[269083] = true, -- Enlisted
			[335148] = true, -- Sign of the Twisting Nether
			[335149] = true, -- Sign of the Scourge
			[335150] = true, -- Sign of the Destroyer
			[335151] = true, -- Sign of the Mists
			[335152] = true, -- Sign of Iron
			[359082] = true, -- Sign of the Legion
			[397734] = true, -- Word of a Worthy Ally
		},
		["M+ Affixes"] = {
			state = true,
			-- GENERAL BUFFS
			[178658] = true, -- Raging (Enrage)
			[209859] = true, -- Bolster (Bolster)
			[226510] = true, -- Sanguine (Sanguine Ichor)
			[343502] = true, -- Inspiring (Inspiring Presence)
			-- GENERAL DEBUFFS
			[209858] = true, -- Necrotic (Necrotic Wound)
			[226512] = true, -- Sanguine (Sanguine Ichor)
			[240443] = true, -- Bursting (Burst)
			[240559] = true, -- Grievous (Grievous Wound)
			-- DRAGONFLIGHT SEASON 1
			[396364] = true, -- Thundering (Mark of Wind)
			[396369] = true, -- Thundering (Mark of Lightning)
			[396411] = true, -- Thundering (Primal Overload)
			-- DRAGONFLIGHT SEASON 2
			[408556] = true, -- Entangling (Entangled)
			[408805] = true, -- Incorporeal (Destabilize)
			[409465] = true, -- Afflicted (Cursed Spirit)
			[409470] = true, -- Afflicted (Poisoned Spirit)
			[409472] = true, -- Afflicted (Diseased Spirit)
		},
	},
	textures = {
		statusbar = {
			horiz = "LS",
			vert = "LS",
		},
	},
}

D.profile = {
	units = {
		cooldown = {
			exp_threshold = 5, -- [1; 10]
			m_ss_threshold = 600, -- [91; 3599]
			s_ms_threshold = 5, -- [1; 10]
			swipe = {
				enabled = true,
				reversed = true,
			},
		},
		inlay = {
			alpha = 0.4,
		},
		change = {
			smooth = true,
		},
		player = {
			enabled = true,
			width = 250,
			height = 52,
			mirror_widgets = true,
			point = {"BOTTOM", "UIParent", "BOTTOM", -286, 198},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = true,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			insets = {
				t_size = 0.25,
				b_size = 0.25,
			},
			health = {
				enabled = true,
				color = {
					class = false,
					reaction = false,
				},
				text = {
					tag = "[ls:health:cur]",
					size = 13,
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 4,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
				},
			},
			power = {
				enabled = true,
				text = {
					tag = "",
					size = 11,
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "LEFT",
						anchor = "Power",
						rP = "LEFT",
						x = 4,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
				},
			},
			class_power = {
				enabled = true,
				prediction = {
					enabled = true,
				},
				runes = {
					color_by_spec = true,
					sort_order = "none",
				},
			},
			castbar = {
				enabled = true,
				blizz_enabled = false,
				latency = true,
				detached = true,
				width_override = 226,
				height = 12,
				icon = {
					position = "LEFT", -- "RIGHT", "NONE"
				},
				text = {
					size = 12,
				},
				point1 = {
					p = "BOTTOM",
					anchor = "",
					detached_anchor = "UIParent",
					rP = "BOTTOM",
					x = 0,
					y = 190,
				},
			},
			portrait = {
				enabled = false,
				style = "2D", -- "3D", "Class"
				position = "Left", -- "Right"
			},
			name = {
				size = 13,
				tag = "",
				h_alignment = "CENTER",
				v_alignment = "MIDDLE",
				word_wrap = false,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "CENTER",
					x = 0,
					y = 0,
				},
				point2 = {
					p = "",
					anchor = "",
					rP = "CENTER",
					x = 0,
					y = 0,
				},
			},
			raid_target = {
				enabled = true,
				size = 24,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "TOP",
					x = 0,
					y = 6,
				},
			},
			pvp = {
				enabled = true,
			},
			debuff = {
				enabled = true,
				point1 = {
					p = "CENTER",
					anchor = "Health",
					rP = "CENTER",
					x = 0,
					y = 0,
				},
			},
			status = {
				enabled = true,
			},
			threat = {
				enabled = true,
			},
			auras = {
				enabled = false,
				rows = 4,
				per_row = 8,
				width = 0,
				height = 0,
				x_growth = "RIGHT",
				y_growth = "UP",
				disable_mouse = false,
				count = {
					size = 10,
					h_alignment = "RIGHT",
					v_alignment = "TOP",
				},
				cooldown = {
					text = {
						enabled = true,
						size = 10,
						v_alignment = "BOTTOM",
					},
				},
				type = {
					enabled = true,
					size = 12,
					position = "TOPLEFT",
				},
				filter = {
					custom = {
						["Blacklist"] = true,
						["M+ Affixes"] = true,
					},
					friendly = {
						buff = {
							boss = true,
							tank = true,
							healer = true,
							mount = true,
							selfcast = true,
							selfcast_permanent = true,
							misc = false,
						},
						debuff = {
							boss = true,
							tank = true,
							healer = true,
							selfcast = true,
							selfcast_permanent = true,
							dispellable = true,
							misc = false,
						},
					},
				},
				point1 = {
					p = "BOTTOMLEFT",
					anchor = "",
					rP = "TOPLEFT",
					x = -1,
					y = 7,
				},
			},
			border = {
				color = {
					class = false,
					reaction = false,
				},
			},
			custom_texts = {},
		},
		pet = {
			enabled = true,
			width = 114,
			height = 28,
			point = {"BOTTOMRIGHT", "LSPlayerFrame", "BOTTOMLEFT", -12, 0},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			insets = {
				t_size = 0.25,
				b_size = 0.25,
			},
			health = {
				enabled = true,
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "[ls:health:cur]",
					size = 13,
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 4,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
				},
			},
			power = {
				enabled = true,
				text = {
					tag = "",
					size = 11,
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "LEFT",
						anchor = "Power",
						rP = "LEFT",
						x = 4,
						y = 0,
					},
				},
			},
			castbar = {
				enabled = true,
				latency = true,
				detached = true,
				width_override = 200,
				height = 12,
				icon = {
					position = "LEFT", -- "RIGHT", "NONE"
				},
				text = {
					size = 12,
				},
				point1 = {
					p = "BOTTOM",
					anchor = "",
					detached_anchor = "UIParent",
					rP = "BOTTOM",
					x = 0,
					y = 208,
				},
			},
			portrait = {
				enabled = false,
				style = "2D", -- "3D", "Class"
				position = "Left", -- "Right"
			},
			name = {
				size = 13,
				tag = "",
				h_alignment = "CENTER",
				v_alignment = "MIDDLE",
				word_wrap = false,
				point1 = {
					p = "CENTER",
					anchor = "Health",
					rP = "CENTER",
					x = 0,
					y = 0,
				},
				point2 = {
					p = "",
					anchor = "",
					rP = "CENTER",
					x = 0,
					y = 0,
				},
			},
			raid_target = {
				enabled = true,
				size = 24,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "TOP",
					x = 0,
					y = 6,
				},
			},
			debuff = {
				enabled = true,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "CENTER",
					x = 0,
					y = 0,
				},
			},
			threat = {
				enabled = true,
			},
			auras = {
				enabled = false,
				rows = 1,
				per_row = 4,
				width = 0,
				height = 0,
				x_growth = "RIGHT",
				y_growth = "UP",
				disable_mouse = false,
				count = {
					size = 10,
					h_alignment = "RIGHT",
					v_alignment = "TOP",
				},
				cooldown = {
					text = {
						enabled = true,
						size = 10,
						v_alignment = "BOTTOM",
					},
				},
				type = {
					enabled = true,
					size = 12,
					position = "TOPLEFT",
				},
				filter = {
					custom = {
						["Blacklist"] = true,
						["M+ Affixes"] = true,
					},
					friendly = {
						buff = {
							boss = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							misc = false,
						},
						debuff = {
							boss = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							dispellable = true,
							misc = false,
						},
					},
				},
				point1 = {
					p = "BOTTOMLEFT",
					anchor = "",
					rP = "TOPLEFT",
					x = -1,
					y = 7,
				},
			},
			border = {
				color = {
					class = false,
					reaction = false,
				},
			},
			custom_texts = {},
		},
		target = {
			enabled = true,
			width = 250,
			height = 52,
			mirror_widgets = false,
			point = {"BOTTOM", "UIParent", "BOTTOM", 286, 198},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			insets = {
				t_size = 0.25,
				b_size = 0.25,
			},
			health = {
				enabled = true,
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "[ls:health:cur-perc]",
					size = 13,
					h_alignment = "RIGHT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "RIGHT",
						anchor = "Health",
						rP = "RIGHT",
						x = -4,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
				},
			},
			power = {
				enabled = true,
				text = {
					tag = "",
					size = 11,
					h_alignment = "RIGHT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "RIGHT",
						anchor = "Power",
						rP = "RIGHT",
						x = -4,
						y = 0,
					},
				},
			},
			castbar = {
				enabled = true,
				latency = false,
				detached = false,
				width_override = 0,
				height = 12,
				icon = {
					position = "LEFT", -- "RIGHT", "NONE"
				},
				text = {
					size = 12,
				},
				point1 = {
					p = "TOPLEFT",
					anchor = "",
					detached_anchor = "FRAME",
					rP = "BOTTOMLEFT",
					x = 0,
					y = -6,
				},
			},
			portrait = {
				enabled = false,
				style = "2D", -- "3D", "Class"
				position = "Left", -- "Right"
			},
			name = {
				size = 13,
				tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
				h_alignment = "LEFT",
				v_alignment = "MIDDLE",
				word_wrap = false,
				point1 = {
					p = "LEFT",
					anchor = "Health",
					rP = "LEFT",
					x = 4,
					y = 0,
				},
				point2 = {
					p = "RIGHT",
					anchor = "Health.Text",
					rP = "LEFT",
					x = -2,
					y = 0,
				},
			},
			raid_target = {
				enabled = true,
				size = 24,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "TOP",
					x = 0,
					y = 6,
				},
			},
			pvp = {
				enabled = true,
			},
			debuff = {
				enabled = true,
				point1 = {
					p = "TOPRIGHT",
					anchor = "Health",
					rP = "TOPRIGHT",
					x = -2,
					y = -2,
				},
			},
			status = {
				enabled = true,
			},
			threat = {
				enabled = true,
				feedback_unit = "player",
			},
			auras = {
				enabled = true,
				rows = 4,
				per_row = 8,
				width = 0,
				height = 0,
				x_growth = "RIGHT",
				y_growth = "UP",
				disable_mouse = false,
				count = {
					size = 10,
					h_alignment = "RIGHT",
					v_alignment = "TOP",
				},
				cooldown = {
					text = {
						enabled = true,
						size = 10,
						v_alignment = "BOTTOM",
					},
				},
				type = {
					enabled = true,
					size = 12,
					position = "TOPLEFT",
				},
				filter = {
					custom = {
						["Blacklist"] = true,
						["M+ Affixes"] = true,
					},
					friendly = {
						buff = {
							boss = true,
							tank = true,
							healer = true,
							mount = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							misc = false,
						},
						debuff = {
							boss = true,
							tank = true,
							healer = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							dispellable = true,
							misc = false,
						},
					},
					enemy = {
						buff = {
							boss = true,
							tank = true,
							healer = true,
							mount = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							dispellable = true,
							misc = false,
						},
						debuff = {
							boss = true,
							tank = true,
							healer = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							misc = false,
						},
					},
				},
				point1 = {
					p = "BOTTOMLEFT",
					anchor = "",
					rP = "TOPLEFT",
					x = -1,
					y = 7,
				},
			},
			border = {
				color = {
					class = false,
					reaction = false,
				},
			},
			custom_texts = {},
		},
		targettarget = {
			enabled = true,
			width = 114,
			height = 28,
			point = {"BOTTOMLEFT", "LSTargetFrame", "BOTTOMRIGHT", 12, 0},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			insets = {
				t_size = 0.25,
				b_size = 0.25,
			},
			health = {
				enabled = true,
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "",
					size = 13,
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
				},
			},
			power = {
				enabled = false,
				text = {
					tag = "",
					size = 11,
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
				},
			},
			portrait = {
				enabled = false,
				style = "2D", -- "3D", "Class"
				position = "Left", -- "Right"
			},
			name = {
				size = 13,
				tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
				h_alignment = "CENTER",
				v_alignment = "MIDDLE",
				word_wrap = false,
				point1 = {
					p = "TOPLEFT",
					anchor = "Health",
					rP = "TOPLEFT",
					x = 2,
					y = -2,
				},
				point2 = {
					p = "BOTTOMRIGHT",
					anchor = "Health",
					rP = "BOTTOMRIGHT",
					x = -2,
					y = 2,
				},
			},
			raid_target = {
				enabled = true,
				size = 24,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "TOP",
					x = 0,
					y = 6,
				},
			},
			status = {
				enabled = true,
			},
			threat = {
				enabled = false,
				feedback_unit = "target",
			},
			border = {
				color = {
					class = false,
					reaction = false,
				},
			},
		},
		focus = {
			enabled = true,
			width = 250,
			height = 52,
			mirror_widgets = false,
			point = {"BOTTOM", "UIParent", "BOTTOM", 286, 418},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			insets = {
				t_size = 0.25,
				b_size = 0.25,
			},
			health = {
				enabled = true,
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "[ls:health:cur-perc]",
					size = 13,
					h_alignment = "RIGHT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "RIGHT",
						anchor = "Health",
						rP = "RIGHT",
						x = -4,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
				},
			},
			power = {
				enabled = true,
				text = {
					tag = "",
					size = 11,
					h_alignment = "RIGHT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "RIGHT",
						anchor = "Power",
						rP = "RIGHT",
						x = -4,
						y = 0,
					},
				},
			},
			castbar = {
				enabled = true,
				latency = false,
				detached = false,
				width_override = 0,
				height = 12,
				icon = {
					position = "LEFT", -- "RIGHT", "NONE"
				},
				text = {
					size = 12,
				},
				point1 = {
					p = "TOPRIGHT",
					anchor = "",
					detached_anchor = "FRAME",
					rP = "BOTTOMRIGHT",
					x = 0,
					y = -6,
				},
			},
			portrait = {
				enabled = false,
				style = "2D", -- "3D", "Class"
				position = "Left", -- "Right"
			},
			name = {
				size = 13,
				tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
				h_alignment = "LEFT",
				v_alignment = "MIDDLE",
				word_wrap = false,
				point1 = {
					p = "LEFT",
					anchor = "Health",
					rP = "LEFT",
					x = 4,
					y = 0,
				},
				point2 = {
					p = "RIGHT",
					anchor = "Health.Text",
					rP = "LEFT",
					x = -2,
					y = 0,
				},
			},
			raid_target = {
				enabled = true,
				size = 24,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "TOP",
					x = 0,
					y = 6,
				},
			},
			pvp = {
				enabled = true,
			},
			debuff = {
				enabled = true,
				point1 = {
					p = "TOPLEFT",
					anchor = "Health",
					rP = "TOPLEFT",
					x = 2,
					y = -2,
				},
			},
			status = {
				enabled = true,
			},
			threat = {
				enabled = true,
				feedback_unit = "player",
			},
			auras = {
				enabled = true,
				rows = 4,
				per_row = 8,
				width = 0,
				height = 0,
				x_growth = "RIGHT",
				y_growth = "UP",
				disable_mouse = false,
				count = {
					size = 10,
					h_alignment = "RIGHT",
					v_alignment = "TOP",
				},
				cooldown = {
					text = {
						enabled = true,
						size = 10,
						v_alignment = "BOTTOM",
					},
				},
				type = {
					enabled = true,
					size = 12,
					position = "TOPLEFT",
				},
				filter = {
					custom = {
						["Blacklist"] = true,
						["M+ Affixes"] = true,
					},
					friendly = {
						buff = {
							boss = true,
							tank = true,
							healer = true,
							mount = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							misc = false,
						},
						debuff = {
							boss = true,
							tank = true,
							healer = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							dispellable = true,
							misc = false,
						},
					},
					enemy = {
						buff = {
							boss = true,
							tank = true,
							healer = true,
							mount = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							dispellable = true,
							misc = false,
						},
						debuff = {
							boss = true,
							tank = true,
							healer = true,
							selfcast = true,
							selfcast_permanent = true,
							player = true,
							player_permanent = true,
							misc = false,
						},
					},
				},
				point1 = {
					p = "BOTTOMLEFT",
					anchor = "",
					rP = "TOPLEFT",
					x = -1,
					y = 7,
				},
			},
			border = {
				color = {
					class = false,
					reaction = false,
				},
			},
			custom_texts = {},
		},
		focustarget = {
			enabled = true,
			width = 114,
			height = 28,
			point = {"BOTTOMLEFT", "LSFocusFrame", "BOTTOMRIGHT", 12, 0},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			insets = {
				t_size = 0.25,
				b_size = 0.25,
			},
			health = {
				enabled = true,
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "",
					size = 13,
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
				},
			},
			power = {
				enabled = false,
				text = {
					tag = "",
					size = 11,
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					point1 = {
						p = "CENTER",
						anchor = "",
						rP = "CENTER",
						x = 0,
						y = 0,
					},
				},
			},
			portrait = {
				enabled = false,
				style = "2D", -- "3D", "Class"
				position = "Left", -- "Right"
			},
			name = {
				size = 13,
				tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
				h_alignment = "CENTER",
				v_alignment = "MIDDLE",
				word_wrap = false,
				point1 = {
					p = "TOPLEFT",
					anchor = "Health",
					rP = "TOPLEFT",
					x = 2,
					y = -2,
				},
				point2 = {
					p = "BOTTOMRIGHT",
					anchor = "Health",
					rP = "BOTTOMRIGHT",
					x = -2,
					y = 2,
				},
			},
			raid_target = {
				enabled = true,
				size = 24,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "TOP",
					x = 0,
					y = 6,
				},
			},
			status = {
				enabled = true,
			},
			threat = {
				enabled = false,
				feedback_unit = "focus",
			},
			border = {
				color = {
					class = false,
					reaction = false,
				},
			},
		},
		boss = {
			enabled = true,
			width = 188,
			height = 52,
			spacing = 28,
			x_growth = "LEFT",
			y_growth = "DOWN",
			per_row = 1,
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -82, -268},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			insets = {
				t_size = 0.25,
				b_size = 0.25,
			},
			health = {
				enabled = true,
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "[ls:health:perc]",
					size = 13,
					h_alignment = "RIGHT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "RIGHT",
						anchor = "Health",
						rP = "RIGHT",
						x = -2,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
				},
			},
			power = {
				enabled = true,
				text = {
					tag = "",
					size = 11,
					h_alignment = "RIGHT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "RIGHT",
						anchor = "Power",
						rP = "RIGHT",
						x = -2,
						y = 0,
					},
				},
			},
			alt_power = {
				enabled = true,
				text = {
					tag = "",
					size = 11,
					h_alignment = "RIGHT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "RIGHT",
						anchor = "AlternativePower",
						rP = "RIGHT",
						x = -2,
						y = 0,
					},
				},
			},
			castbar = {
				enabled = true,
				latency = false,
				detached = false,
				width_override = 0,
				height = 12,
				icon = {
					position = "LEFT", -- "RIGHT", "NONE"
				},
				text = {
					size = 12,
				},
				point1 = {
					p = "TOPLEFT",
					anchor = "",
					detached_anchor = "FRAME",
					rP = "BOTTOMLEFT",
					x = 0,
					y = -6,
				},
			},
			portrait = {
				enabled = false,
				style = "2D", -- "3D", "Class"
				position = "Left", -- "Right"
			},
			name = {
				size = 13,
				tag = "[ls:name]",
				h_alignment = "LEFT",
				v_alignment = "MIDDLE",
				word_wrap = false,
				point1 = {
					p = "LEFT",
					anchor = "Health",
					rP = "LEFT",
					x = 2,
					y = 0,
				},
				point2 = {
					p = "RIGHT",
					anchor = "Health.Text",
					rP = "LEFT",
					x = -2,
					y = 0,
				},
			},
			raid_target = {
				enabled = true,
				size = 24,
				point1 = {
					p = "CENTER",
					anchor = "",
					rP = "TOP",
					x = 0,
					y = 6,
				},
			},
			debuff = {
				enabled = true,
				point1 = {
					p = "CENTER",
					anchor = "Health",
					rP = "CENTER",
					x = 0,
					y = 0,
				},
			},
			threat = {
				enabled = true,
				feedback_unit = "player",
			},
			auras = {
				enabled = true,
				rows = 2,
				per_row = 3,
				width = 25,
				height = 0,
				x_growth = "LEFT",
				y_growth = "DOWN",
				disable_mouse = false,
				count = {
					size = 10,
					h_alignment = "RIGHT",
					v_alignment = "TOP",
				},
				cooldown = {
					text = {
						enabled = true,
						size = 10,
						v_alignment = "BOTTOM",
					},
				},
				type = {
					enabled = true,
					size = 12,
					position = "TOPLEFT",
				},
				filter = {
					custom = {
						["Blacklist"] = true,
						["M+ Affixes"] = true,
					},
					friendly = {
						buff = {
							boss = true,
							tank = true,
							healer = true,
							player = false,
							player_permanent = false,
							misc = false,
						},
						debuff = {
							boss = true,
							tank = true,
							healer = true,
							player = false,
							player_permanent = false,
							dispellable = false,
							misc = false,
						},
					},
					enemy = {
						buff = {
							boss = true,
							tank = true,
							healer = true,
							player = false,
							player_permanent = false,
							dispellable = false,
							misc = false,
						},
						debuff = {
							boss = true,
							tank = true,
							healer = true,
							player = false,
							player_permanent = false,
							misc = false,
						},
					},
				},
				point1 = {
					p = "TOPRIGHT",
					anchor = "",
					rP = "TOPLEFT",
					x = -7,
					y = 1,
				},
			},
			border = {
				color = {
					class = false,
					reaction = false,
				},
			},
			custom_texts = {},
		},
	},
	minimap = {
		scale = 100, -- 100, 125, 150
		shape = "round", -- "round", "square"
		flip = false,
		rotate = false,
		auto_zoom = 5,
		color = {
			border = false,
		},
		coords = {
			enabled = false,
			background = true,
			point = {"TOP", "Minimap", "BOTTOM", 0, -8},
		},
		flag = {
			enabled = true,
			tooltip = false,
		},
		fade = {
			enabled = false,
			combat = false,
			target = false,
			health = false,
			out_delay = 0.75,
			out_duration = 0.15,
			in_duration = 0.15,
			min_alpha = 0.2,
			max_alpha = 1,
		},
		point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -4, -4},
	},
	bars = {
		mana_indicator = "button", -- hotkey
		range_indicator = "button", -- hotkey
		lock = true,
		rightclick_selfcast = false,
		blizz_vehicle = false,
		endcaps = {
			visibility = "BOTH", -- "LEFT", "RIGHT", "NONE"
			type = "AUTO", -- "ALLIANCE", "HORDE", "NEUTRAL"
		},
		cooldown = {
			exp_threshold = 5,
			m_ss_threshold = 120, -- [91; 3599]
			s_ms_threshold = 5, -- [1; 10]
			swipe = {
				enabled = true,
				reversed = false,
			},
		},
		desaturation = {
			unusable = true,
		},
		bar1 = { -- MainMenuBar
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[petbattle] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			macro = {
				enabled = true,
				size = 12,
				point = {"BOTTOM", 0, 0},
				h_alignment = "CENTER",
			},
			count = {
				enabled = true,
				size = 12,
				point = {"BOTTOMRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 0, 20},
		},
		bar2 = { -- MultiBarBottomLeft
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			macro = {
				enabled = true,
				size = 12,
				point = {"BOTTOM", 0, 0},
				h_alignment = "CENTER",
			},
			count = {
				enabled = true,
				size = 12,
				point = {"BOTTOMRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 0, 55},
		},
		bar3 = { -- MultiBarBottomRight
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			macro = {
				enabled = true,
				size = 12,
				point = {"BOTTOM", 0, 0},
				h_alignment = "CENTER",
			},
			count = {
				enabled = true,
				size = 12,
				point = {"BOTTOMRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 0, 91},
		},
		bar4 = { -- MultiBarLeft
			flyout_dir = "LEFT",
			grid = false,
			num = 12,
			per_row = 1,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "LEFT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			macro = {
				enabled = true,
				size = 12,
				point = {"BOTTOM", 0, 0},
				h_alignment = "CENTER",
			},
			count = {
				enabled = true,
				size = 12,
				point = {"BOTTOMRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {"RIGHT", "UIParent", "RIGHT", -40, 0},
		},
		bar5 = { -- MultiBarRight
			flyout_dir = "LEFT",
			grid = false,
			num = 12,
			per_row = 1,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "LEFT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			macro = {
				enabled = true,
				size = 12,
				point = {"BOTTOM", 0, 0},
				h_alignment = "CENTER",
			},
			count = {
				enabled = true,
				size = 12,
				point = {"BOTTOMRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {"RIGHT", "UIParent", "RIGHT", -4, 0},
		},
		bar6 = { -- MultiBar5
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = false,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			macro = {
				enabled = true,
				size = 12,
				point = {"BOTTOM", 0, 0},
				h_alignment = "CENTER",
			},
			count = {
				enabled = true,
				size = 12,
				point = {"BOTTOMRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", -282, 320},
		},
		bar7 = { -- MultiBar6
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = false,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			macro = {
				enabled = true,
				size = 12,
				point = {"BOTTOM", 0, 0},
				h_alignment = "CENTER",
			},
			count = {
				enabled = true,
				size = 12,
				point = {"BOTTOMRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", -282, 356},
		},
		bar8 = { -- MultiBar7
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = false,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			macro = {
				enabled = true,
				size = 12,
				point = {"BOTTOM", 0, 0},
				h_alignment = "CENTER",
			},
			count = {
				enabled = true,
				size = 12,
				point = {"BOTTOMRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", -282, 392},
		},
		pet = {
			flyout_dir = "UP",
			grid = false,
			num = 10,
			per_row = 10,
			width = 24,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[pet,nopetbattle,novehicleui,nooverridebar,nopossessbar] show; hide",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 10,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 10,
					v_alignment = "MIDDLE",
				},
			},
		},
		stance = {
			flyout_dir = "UP",
			num = 10,
			per_row = 10,
			width = 24,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 10,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 10,
					v_alignment = "MIDDLE",
				},
			},
		},
		pet_battle = {
			num = 6,
			per_row = 6,
			width = 32,
			height = 0,
			spacing = 4,
			scale = 1,
			visibility = "[petbattle] show; hide",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 0, 20},
		},
		extra = { -- ExtraAction
			width = 40,
			height = 0,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			artwork = false,
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 14,
				point = {"TOPRIGHT", 2, 0},
				h_alignment = "RIGHT",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 14,
					v_alignment = "MIDDLE",
				},
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", -94, 250},
		},
		zone = { -- ZoneAbility
			width = 40,
			height = 0,
			scale = 1,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			artwork = false,
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 14,
					v_alignment = "MIDDLE",
				},
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 94, 250},
		},
		vehicle = { -- LeaveVehicle
			width = 40,
			height = 0,
			visible = true,
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 168, 134},
		},
		bag = {
			visible = true,
			tooltip = true,
			currency = {},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			point = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -4, 36},
		},
		micromenu = {
			visible = true,
			num = 13,
			per_row = 13,
			width = 18,
			height = 24,
			spacing = 2,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			helptips = true,
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			buttons = {
				character = {
					enabled = true,
					tooltip = true,
				},
				spellbook = {
					enabled = true,
				},
				talent = {
					enabled = true,
				},
				achievement = {
					enabled = true,
				},
				quest = {
					enabled = true,
					tooltip = true,
				},
				guild = {
					enabled = true,
				},
				lfd = {
					enabled = true,
					tooltip = true,
				},
				collection = {
					enabled = true,
				},
				ej = {
					enabled = true,
					tooltip = true,
				},
				store = {
					enabled = false,
				},
				main = {
					enabled = true,
					tooltip = true,
				},
				help = {
					enabled = false,
				},
			},
			point = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -4, 4},
		},
		xpbar = {
			visible = true,
			width = 594,
			height = 12,
			text = {
				size = 12,
				format = "NUM", -- "NUM_PERC"
				visibility = 2, -- 1 - always, 2 - mouseover
			},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				health = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_duration = 0.15,
				min_alpha = 0.2,
				max_alpha = 1,
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 0, 4},
		},
	},
	auras = {
		cooldown = {
			exp_threshold = 5, -- [1; 10]
			m_ss_threshold = 600, -- [91; 3599]
			s_ms_threshold = 5, -- [1; 10]
			swipe = {
				enabled = false,
				reversed = true,
			},
		},
		HELPFUL = {
			width = 32,
			height = 0,
			spacing = 4,
			x_growth = "LEFT",
			y_growth = "DOWN",
			per_row = 16,
			num_rows = 2,
			sep_own = 0,
			sort_method = "INDEX",
			sort_dir = "+",
			count = {
				enabled = true,
				size = 12,
				h_alignment = "RIGHT",
				v_alignment = "TOP",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "BOTTOM",
				},
			},
			type = {
				enabled = false,
				size = 12,
				position = "TOPLEFT",
			},
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -250, -4},
		},
		HARMFUL = {
			width = 32,
			height = 0,
			spacing = 4,
			x_growth = "LEFT",
			y_growth = "DOWN",
			per_row = 16,
			num_rows = 1,
			sep_own = 0,
			sort_method = "INDEX",
			sort_dir = "+",
			count = {
				enabled = true,
				size = 12,
				h_alignment = "RIGHT",
				v_alignment = "TOP",
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "BOTTOM",
				},
			},
			type = {
				enabled = true,
				size = 12,
				position = "TOPLEFT",
			},
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -250, -114},
		},
		TOTEM = {
			num = 4,
			width = 32,
			height = 0,
			spacing = 4,
			x_growth = "LEFT",
			y_growth = "DOWN",
			per_row = 4,
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "BOTTOM",
				},
			},
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -250, -150},
		},
	},
	tooltips = {
		id = true,
		count = true,
		title = true,
		target = true,
		inspect = true,
		health = {
			height = 12,
			text = {
				size = 11,
			},
		},
	},
	blizzard = {
		character_frame = {
			ilvl = true,
			enhancements = true,
		},
		gm = {
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -250, -240},
		},
		talking_head = {
			hide = false,
		},
	},
	movers = {},
}

PrD.profile = {
	auras = {
		enabled = true,
	},
	auratracker = {
		enabled = false,
		locked = false,
		num = 12,
		width = 38,
		height = 0,
		spacing = 4,
		per_row = 12,
		x_growth = "RIGHT",
		y_growth = "DOWN",
		drag_key = "NONE",
		count = {
			size = 12,
			h_alignment = "RIGHT",
			v_alignment = "TOP",
		},
		cooldown = {
			exp_threshold = 5, -- [1; 10]
			m_ss_threshold = 0, -- [91; 3599]
			s_ms_threshold = 5, -- [1; 10]
			swipe = {
				enabled = true,
				reversed = true,
			},
			text = {
				enabled = true,
				size = 12,
				h_alignment = "CENTER",
				v_alignment = "BOTTOM",
			},
		},
		type = {
			enabled = true,
			size = 12,
			position = "TOPLEFT",
		},
		filter = {
			HELPFUL = {},
			HARMFUL = {},
			ALL = {},
		},
	},
	bars = {
		enabled = true,
		restricted = true,
		micromenu = {
			blizz_enabled = false,
		},
		pet_battle = {
			enabled = false,
		},
		xpbar = {
			enabled = true,
		},
	},
	blizzard = {
		enabled = true,
		character_frame = { -- CharacterFrame
			enabled = true,
		},
		command_bar = { -- OrderHallCommandBar
			enabled = true
		},
		gm = { -- TicketStatusFrame
			enabled = true
		},
		mail = {
			enabled = false,
		},
	},
	minimap = {
		enabled = true,
	},
	tooltips = {
		enabled = true,
	},
	units = {
		enabled = true,
		player = {
			enabled = true,
		},
		target = {
			enabled = true,
		},
		focus = {
			enabled = true,
		},
		boss = {
			enabled = true,
		},
	},
	loot = {
		enabled = true,
	},
}
