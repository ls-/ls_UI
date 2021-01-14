local _, ns = ...
local E, D = ns.E, ns.D

-- Lua
local _G = getfenv(0)

-- Mine
local defaultFont = LibStub("LibSharedMedia-3.0"):GetDefault("font")

local function rgb(r, g, b)
	return E:SetRGB({}, r, g, b)
end

D.global = {
	colors = {
		red = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
		green = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
		blue = rgb(38, 125, 206), -- #267DCE (5PB 5/12)
		yellow = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
		gray = rgb(136, 137, 135), -- #888987 (N5)
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
			unusable = rgb(107, 108, 107), -- #6B6C6B (N4)
			mana = rgb(32, 98, 165), -- #2062A5 (5PB 4/10)
			range = rgb(140, 29, 30), -- #8C1D1E (7.5R 3/10)
		},
		castbar = {
			casting = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
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
		gain = rgb(120, 225, 107), -- #78E16B (10GY 8/12)
		loss = rgb(140, 29, 30), -- #8C1D1E (7.5R 3/10)
		power = {
			MANA = rgb(69, 155, 218), -- #459BDA (2.5PB 6/10)
			RAGE = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			FOCUS = rgb(230, 118, 47), -- #E6762F (2.5YR 6/12)
			ENERGY = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			COMBO_POINTS = rgb(215, 77, 18), -- #D74D12 (10R 5/14)
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
		artifact = rgb(217, 202, 146), -- #D9CA92 (5Y 8/4)
		-- artifact = rgb(230, 204, 153), -- #E6CC99 (Blizzard Colour)
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
			Enchant = rgb(123, 44, 181), -- #7B2CB5 (Blizzard Colour)
		},
		rune = {
			-- blood
			[1] = rgb(247, 65, 57), -- #F74139 (Blizzard Colour)
			-- frost
			[2] = rgb(148, 203, 247), -- #94CBF7 (Blizzard Colour)
			-- unholy
			[3] = rgb(173, 235, 66), -- #ADEB42 (Blizzard Colour)
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
			func = "function(unit)\n  return \"|c\" .. _VARS.E:GetCreatureDifficultyColor(UnitEffectiveLevel(unit)).hex\nend",
		},
		["ls:color:power"] = {
			func = "function(unit)\n  local type, _, r, g, b = UnitPowerType(unit)\n  if not r then\n    return \"|c\" .. _VARS.POWER_COLORS[type].hex\n  else\n    if r > 1 or g > 1 or b > 1 then\n      r, g, b = r / 255, g / 255, b / 255\n    end\n\n    return Hex(r, g, b)\n  end\nend",
		},
		["ls:color:reaction"] = {
			events = "UNIT_FACTION UNIT_NAME_UPDATE",
			func = "function(unit)\n  local reaction = UnitReaction(unit, 'player')\n  if reaction then\n    return \"|c\" .. _VARS.REACTION_COLORS[reaction].hex\n  end\n\n  return \"|cffffffff\"\nend",
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
			func = "function(unit)\n  return UnitName(unit) or \"\"\nend",
		},
		["ls:name:10"] = {
			events = "UNIT_NAME_UPDATE",
			func = "function(unit)\n  local name = UnitName(unit) or \"\"\n  return name ~= \"\" and _VARS.E:TruncateString(name, 10) or name\nend",
		},
		["ls:name:15"] = {
			events = "UNIT_NAME_UPDATE",
			func = "function(unit)\n  local name = UnitName(unit) or \"\"\n  return name ~= \"\" and _VARS.E:TruncateString(name, 15) or name\nend",
		},
		["ls:name:20"] = {
			events = "UNIT_NAME_UPDATE",
			func = "function(unit)\n  local name = UnitName(unit) or \"\"\n  return name ~= \"\" and _VARS.E:TruncateString(name, 20) or name\nend",
		},
		["ls:name:5"] = {
			events = "UNIT_NAME_UPDATE",
			func = "function(unit)\n  local name = UnitName(unit) or \"\"\n  return name ~= \"\" and _VARS.E:TruncateString(name, 5) or name\nend",
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
		["C"] = "ls_UI[3]",
		["L"] = "ls_UI[4]",
		["INLINE_ICONS"] = "ls_UI[2].textures.icons_inline",
		["INLINE_AURA_ICONS"] = "ls_UI[2].textures.aura_icons_inline",
		["COLORS"] = "ls_UI[3].db.global.colors",
		["CLASS_COLORS"] = "ls_UI[3].db.global.colors.class",
		["POWER_COLORS"] = "ls_UI[3].db.global.colors.power",
		["REACTION_COLORS"] = "ls_UI[3].db.global.colors.reaction",
	},
	aura_filters = {
		["Blacklist"] = {
			is_init = false,
		},
		["M+ Affixes"] = {
			is_init = false,
		},
	},
}

D.profile = {
	units = {
		cooldown = {
			exp_threshold = 5, -- [1; 10]
			m_ss_threshold = 600, -- [91; 3599]
		},
		ls = {
			player = {
				enabled = true,
				width = 166,
				height = 166,
				point = {
					ls = {"BOTTOM", "UIParent", "BOTTOM", -312, 74},
					traditional = {"BOTTOM", "UIParent", "BOTTOM", -286, 198},
				},
				health = {
					enabled = true,
					change_threshold = 0.001,
					orientation = "VERTICAL",
					color = {
						class = false,
						reaction = false,
					},
					text = {
						tag = "[ls:health:cur]",
						size = 16,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "BOTTOM",
							anchor = "", -- frame[anchor] or "" if anchor is frame itself
							rP = "CENTER",
							x = 0,
							y = 1,
						},
					},
					prediction = {
						enabled = true,
						absorb_text = {
							tag = "[ls:color:absorb-damage][ls:absorb:damage]|r",
							size = 12,
							h_alignment = "CENTER",
							v_alignment = "MIDDLE",
							point1 = {
								p = "BOTTOM",
								anchor = "Health.Text",
								rP = "TOP",
								x = 0,
								y = 2,
							},
						},
						heal_absorb_text = {
							tag = "[ls:color:absorb-heal][ls:absorb:heal]|r",
							size = 12,
							h_alignment = "CENTER",
							v_alignment = "MIDDLE",
							point1 = {
								p = "BOTTOM",
								anchor = "Health.Text",
								rP = "TOP",
								x = 0,
								y = 16,
							},
						},
					},
				},
				power = {
					enabled = true,
					change_threshold = 0.01,
					orientation = "VERTICAL",
					text = {
						tag = "[ls:color:power][ls:power:cur]|r",
						size = 14,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "TOP",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = -1,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				class_power = {
					enabled = true,
					change_threshold = 0.01,
					orientation = "VERTICAL",
					prediction = {
						enabled = true,
					},
					runes = {
						color_by_spec = true,
						sort_order = "none",
					}
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
						y = 190,
					},
				},
				name = {
					size = 12,
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
						y = -6,
					},
				},
				pvp = {
					enabled = true,
					point1 = {
						p = "TOP",
						anchor = "TextureParent",
						rP = "BOTTOM",
						x = 0,
						y = 10,
					},
				},
				debuff = {
					enabled = true,
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 0,
						y = 0,
					},
				},
				threat = {
					enabled = true,
				},
				border = {
					color = {
						class = false,
						reaction = false,
					},
				},
			},
			pet = {
				enabled = true,
				width = 42,
				height = 134,
				point = {
					ls = {"RIGHT", "LSPlayerFrame", "LEFT", -2, 0},
					traditional = {"RIGHT", "LSPlayerFrame", "LEFT", -2, 0},
				},
				health = {
					enabled = true,
					change_threshold = 0.001,
					orientation = "VERTICAL",
					color = {
						class = false,
						reaction = true,
					},
					text = {
						tag = "[ls:health:cur]",
						size = 12,
						h_alignment = "RIGHT",
						v_alignment = "MIDDLE",
						point1 = {
							p = "BOTTOMRIGHT",
							anchor = "",
							rP = "BOTTOMLEFT",
							x = 8,
							y = 26,
						},
					},
					prediction = {
						enabled = true,
						absorb_text = {
							tag = "",
							size = 10,
							h_alignment = "CENTER",
							v_alignment = "MIDDLE",
							point1 = {
								p = "CENTER",
								anchor = "Health",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
						heal_absorb_text = {
							tag = "",
							size = 10,
							h_alignment = "CENTER",
							v_alignment = "MIDDLE",
							point1 = {
								p = "CENTER",
								anchor = "Health",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
					},
				},
				power = {
					enabled = true,
					change_threshold = 0.01,
					orientation = "VERTICAL",
					text = {
						tag = "[ls:color:power][ls:power:cur]|r",
						size = 12,
						h_alignment = "RIGHT",
						v_alignment = "MIDDLE",
						point1 = {
							p = "BOTTOMRIGHT",
							anchor = "",
							rP = "BOTTOMLEFT",
							x = 8,
							y = 14,
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
						anchor = "LSPlayerFrameCastbarHolder",
						detached_anchor = "LSPlayerFrameCastbarHolder",
						rP = "TOP",
						x = 0,
						y = 6,
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
			},
		},
		traditional = {
			player = {
				enabled = true,
				width = 250,
				height = 52,
				point = {
					ls = {"BOTTOM", "UIParent", "BOTTOM", -312, 74},
					traditional = {"BOTTOM", "UIParent", "BOTTOM", -286, 198},
				},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					enabled = true,
					change_threshold = 0.001,
					orientation = "HORIZONTAL",
					color = {
						class = false,
						reaction = true,
					},
					text = {
						tag = "[ls:health:cur]",
						size = 12,
						h_alignment = "LEFT",
						v_alignment = "MIDDLE",
						point1 = {
							p = "LEFT",
							anchor = "Health",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
						absorb_text = {
							tag = "[ls:color:absorb-damage][ls:absorb:damage]|r",
							size = 10,
							h_alignment = "RIGHT",
							v_alignment = "MIDDLE",
							point1 = {
								p = "BOTTOMRIGHT",
								anchor = "Health",
								rP = "RIGHT",
								x = -2,
								y = 1,
							},
						},
						heal_absorb_text = {
							tag = "[ls:color:absorb-heal][ls:absorb:heal]|r",
							size = 10,
							h_alignment = "RIGHT",
							v_alignment = "MIDDLE",
							point1 = {
								p = "TOPRIGHT",
								anchor = "Health",
								rP = "RIGHT",
								x = -2,
								y = -1,
							},
						},
					},
				},
				power = {
					enabled = true,
					change_threshold = 0.01,
					orientation = "HORIZONTAL",
					text = {
						tag = "[ls:power:cur-max]",
						size = 12,
						h_alignment = "LEFT",
						v_alignment = "MIDDLE",
						point1 = {
							p = "LEFT",
							anchor = "Power",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
					},
				},
				class_power = {
					enabled = true,
					change_threshold = 0.01,
					orientation = "HORIZONTAL",
					prediction = {
						enabled = true,
					},
					runes = {
						color_by_spec = true,
						sort_order = "none",
					}
				},
				castbar = {
					enabled = true,
					latency = true,
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
					style = "2D", -- "3D"
					position = "Left", -- "Right"
				},
				name = {
					size = 12,
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
					point1 = {
						p = "TOPLEFT",
						anchor = "TextureParent",
						rP = "BOTTOMLEFT",
						x = 8,
						y = -2,
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
				},
				auras = {
					enabled = false,
					rows = 4,
					per_row = 8,
					size_override = 0,
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
						size = 12,
						position = "TOPLEFT",
						debuff_type = false,
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
			},
			pet = {
				enabled = true,
				width = 112,
				height = 28,
				point = {
					ls = {"BOTTOMRIGHT", "LSPlayerFrame", "BOTTOMLEFT", -12, 0},
					traditional = {"BOTTOMRIGHT", "LSPlayerFrame", "BOTTOMLEFT", -12, 0},
				},
				insets = {
					t_height = 12,
					b_height = 12,
				},
				health = {
					enabled = true,
					change_threshold = 0.001,
					orientation = "HORIZONTAL",
					color = {
						class = false,
						reaction = true,
					},
					text = {
						tag = "[ls:health:cur]",
						size = 12,
						h_alignment = "LEFT",
						v_alignment = "MIDDLE",
						point1 = {
							p = "LEFT",
							anchor = "Health",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
					prediction = {
						enabled = true,
						absorb_text = {
							tag = "",
							size = 10,
							h_alignment = "CENTER",
							v_alignment = "MIDDLE",
							point1 = {
								p = "CENTER",
								anchor = "Health",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
						heal_absorb_text = {
							tag = "",
							size = 10,
							h_alignment = "CENTER",
							v_alignment = "MIDDLE",
							point1 = {
								p = "CENTER",
								anchor = "Health",
								rP = "CENTER",
								x = 0,
								y = 0,
							},
						},
					},
				},
				power = {
					enabled = true,
					change_threshold = 0.01,
					orientation = "HORIZONTAL",
					text = {
						tag = "[ls:color:power][ls:power:cur]|r",
						size = 12,
						h_alignment = "LEFT",
						v_alignment = "MIDDLE",
						point1 = {
							p = "LEFT",
							anchor = "Power",
							rP = "LEFT",
							x = 2,
							y = 0,
						},
					},
				},
				castbar = {
					enabled = true,
					latency = true,
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
					style = "2D", -- "3D"
					position = "Left", -- "Right"
				},
				name = {
					size = 12,
					tag = "",
					h_alignment = "CENTER",
					v_alignment = "MIDDLE",
					word_wrap = false,
					point1 = {
						p = "CENTER",
						anchor = "Health",
						rP = "CENTER",
						x = 2,
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
				border = {
					color = {
						class = false,
						reaction = false,
					},
				},
			},
		},
		target = {
			enabled = true,
			width = 250,
			height = 52,
			point = {
				ls = {"BOTTOM", "UIParent", "BOTTOM", 286, 336},
				traditional = {"BOTTOM", "UIParent", "BOTTOM", 286, 198},
			},
			insets = {
				t_height = 12,
				b_height = 12,
			},
			health = {
				enabled = true,
				change_threshold = 0.001,
				orientation = "HORIZONTAL",
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "[ls:health:cur-perc]",
					size = 12,
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
					absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
					heal_absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
			},
			power = {
				enabled = true,
				change_threshold = 0.01,
				orientation = "HORIZONTAL",
				text = {
					tag = "[ls:power:cur-max]",
					size = 12,
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
				style = "2D", -- "3D"
				position = "Left", -- "Right"
			},
			name = {
				size = 12,
				tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
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
			pvp = {
				enabled = true,
				point1 = {
					p = "TOPRIGHT",
					anchor = "TextureParent",
					rP = "BOTTOMRIGHT",
					x = -8,
					y = -2,
				},
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
			threat = {
				enabled = true,
				feedback_unit = "player",
			},
			auras = {
				enabled = true,
				rows = 4,
				per_row = 8,
				size_override = 0,
				x_growth = "RIGHT",
				y_growth = "UP",
				disable_mouse = false,
				count = {
					size = 10,
					outline = true,
					shadow = false,
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
					size = 12,
					position = "TOPLEFT",
					debuff_type = false,
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
		},
		targettarget = {
			enabled = true,
			width = 112,
			height = 28,
			point = {
				ls = {"BOTTOMLEFT", "LSTargetFrame", "BOTTOMRIGHT", 12, 0},
				traditional = {"BOTTOMLEFT", "LSTargetFrame", "BOTTOMRIGHT", 12, 0},
			},
			insets = {
				t_height = 12,
				b_height = 12,
			},
			health = {
				enabled = true,
				change_threshold = 0.001,
				orientation = "HORIZONTAL",
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "",
					size = 12,
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
					absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
					heal_absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
			},
			power = {
				enabled = false,
				change_threshold = 0.01,
				orientation = "HORIZONTAL",
				text = {
					tag = "",
					size = 12,
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
				style = "2D", -- "3D"
				position = "Left", -- "Right"
			},
			name = {
				size = 12,
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
			point = {
				ls = {"BOTTOM", "UIParent", "BOTTOM", -286, 336},
				traditional = {"BOTTOM", "UIParent", "BOTTOM", 286, 418},
			},
			insets = {
				t_height = 12,
				b_height = 12,
			},
			health = {
				enabled = true,
				change_threshold = 0.001,
				orientation = "HORIZONTAL",
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "[ls:health:cur-perc]",
					size = 12,
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "LEFT",
						anchor = "Health",
						rP = "LEFT",
						x = 2,
						y = 0,
					},
				},
				prediction = {
					enabled = true,
					absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
					heal_absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
			},
			power = {
				enabled = true,
				change_threshold = 0.01,
				orientation = "HORIZONTAL",
				text = {
					tag = "[ls:power:cur-max]",
					size = 12,
					h_alignment = "LEFT",
					v_alignment = "MIDDLE",
					point1 = {
						p = "LEFT",
						anchor = "Power",
						rP = "LEFT",
						x = 2,
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
				style = "2D", -- "3D"
				position = "Left", -- "Right"
			},
			name = {
				size = 12,
				tag = "[ls:color:difficulty][ls:level:effective][ls:npc:type]|r [ls:name][ls:server]",
				h_alignment = "RIGHT",
				v_alignment = "MIDDLE",
				word_wrap = false,
				point1 = {
					p = "RIGHT",
					anchor = "Health",
					rP = "RIGHT",
					x = -2,
					y = 0,
				},
				point2 = {
					p = "LEFT",
					anchor = "Health.Text",
					rP = "RIGHT",
					x = 2,
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
				point1 = {
					p = "TOPLEFT",
					anchor = "TextureParent",
					rP = "BOTTOMLEFT",
					x = 8,
					y = -2,
				},
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
			threat = {
				enabled = true,
				feedback_unit = "player",
			},
			auras = {
				enabled = true,
				rows = 4,
				per_row = 8,
				size_override = 0,
				x_growth = "RIGHT",
				y_growth = "UP",
				disable_mouse = false,
				count = {
					size = 10,
					outline = true,
					shadow = false,
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
					size = 12,
					position = "TOPLEFT",
					debuff_type = false,
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
		},
		focustarget = {
			enabled = true,
			width = 112,
			height = 28,
			point = {
				ls = {"BOTTOMRIGHT", "LSFocusFrame", "BOTTOMLEFT", -12, 0},
				traditional = {"BOTTOMLEFT", "LSFocusFrame", "BOTTOMRIGHT", 12, 0},
			},
			insets = {
				t_height = 12,
				b_height = 12,
			},
			health = {
				enabled = true,
				change_threshold = 0.001,
				orientation = "HORIZONTAL",
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "",
					size = 12,
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
					absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
					heal_absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
			},
			power = {
				enabled = false,
				change_threshold = 0.01,
				orientation = "HORIZONTAL",
				text = {
					tag = "",
					size = 12,
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
				style = "2D", -- "3D"
				position = "Left", -- "Right"
			},
			name = {
				size = 12,
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
			point = {
				ls = {"TOPRIGHT", "UIParent", "TOPRIGHT", -82, -268},
				traditional = {"TOPRIGHT", "UIParent", "TOPRIGHT", -82, -268},
			},
			insets = {
				t_height = 12,
				b_height = 12,
			},
			health = {
				enabled = true,
				change_threshold = 0.001,
				orientation = "HORIZONTAL",
				color = {
					class = false,
					reaction = true,
				},
				text = {
					tag = "[ls:health:perc]",
					size = 12,
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
					absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
					heal_absorb_text = {
						tag = "",
						size = 10,
						h_alignment = "CENTER",
						v_alignment = "MIDDLE",
						point1 = {
							p = "CENTER",
							anchor = "Health",
							rP = "CENTER",
							x = 0,
							y = 0,
						},
					},
				},
			},
			power = {
				enabled = true,
				change_threshold = 0.01,
				orientation = "HORIZONTAL",
				text = {
					tag = "[ls:power:cur-perc]",
					size = 12,
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
				change_threshold = 0.01,
				orientation = "HORIZONTAL",
				text = {
					tag = "[ls:altpower:cur-perc]",
					size = 12,
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
				style = "2D", -- "3D"
				position = "Left", -- "Right"
			},
			name = {
				size = 12,
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
				size_override = 25,
				x_growth = "LEFT",
				y_growth = "DOWN",
				disable_mouse = false,
				count = {
					size = 10,
					outline = true,
					shadow = false,
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
					size = 12,
					position = "TOPLEFT",
					debuff_type = false,
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
		},
	},
	minimap = {
		size = 146,
		collect = {
			enabled = true,
			tooltip = true,
			calendar = false,
			garrison = false,
			mail = false,
			queue = false,
			tracking = false,
		},
		ls = {
			zone_text = {
				mode = 1, -- 0 - hide, 1 - mouseover, 2 - show
				border = false,
			},
			clock = {
				enabled = true,
				position = 0, -- 0 - top, 1 - bottom
			},
			flag = {
				mode = 2, -- 0 - hide, 1 - mouseover, 2 - show
				position = 2, -- 0 - zone text, 1 - clock, 2 - bottom
			},
			point = {"BOTTOM", "UIParent", "BOTTOM", 312, 74},
		},
		traditional = {
			zone_text = {
				mode = 2,
				border = true,
			},
			clock = {
				enabled = true,
				position = 1,
			},
			flag = {
				mode = 2,
				position = 0,
			},
			point = {"TOPRIGHT", "UIParent", "TOPRIGHT", -18, -7},
		},
		buttons = {
			LSMinimapButtonCollection = 0,
			MiniMapTrackingButton = 22.5,
			GameTimeFrame = 45,
			MiniMapMailFrame = 135,
			GarrisonLandingPageMinimapButton = 210,
			QueueStatusMinimapButton = 320,
		},
		color = {
			border = false,
			zone_text = true,
		},
	},
	bars = {
		mana_indicator = "button", -- hotkey
		range_indicator = "button", -- hotkey
		lock = true, -- watch: LOCK_ACTIONBAR
		rightclick_selfcast = false,
		click_on_down = false,
		blizz_vehicle = false,
		cooldown = {
			exp_threshold = 5,
			m_ss_threshold = 120, -- [91; 3599]
		},
		desaturation = {
			unusable = true,
			mana = true,
			range = true,
		},
		bar1 = { -- MainMenuBar
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			size = 32,
			spacing = 4,
			visibility = "[petbattle] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
			},
			macro = {
				enabled = true,
				size = 12,
			},
			count = {
				enabled = true,
				size = 12,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {
				ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 20},
				traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 20},
			},
		},
		bar2 = { -- MultiBarBottomLeft
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			size = 32,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
			},
			macro = {
				enabled = true,
				size = 12,
			},
			count = {
				enabled = true,
				size = 12,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {
				ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 56},
				traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 56},
			},
		},
		bar3 = { -- MultiBarBottomRight
			flyout_dir = "UP",
			grid = false,
			num = 12,
			per_row = 12,
			size = 32,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
			},
			macro = {
				enabled = true,
				size = 12,
			},
			count = {
				enabled = true,
				size = 12,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {
				ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 92},
				traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 92},
			},
		},
		bar4 = { -- MultiBarLeft
			flyout_dir = "LEFT",
			grid = false,
			num = 12,
			per_row = 1,
			size = 32,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "LEFT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
			},
			macro = {
				enabled = true,
				size = 12,
			},
			count = {
				enabled = true,
				size = 12,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {
				ls = {p = "RIGHT", anchor = "UIParent", rP = "RIGHT", x = -40, y = 0},
				traditional = {p = "RIGHT", anchor = "UIParent", rP = "RIGHT", x = -40, y = 0},
			},
		},
		bar5 = { -- MultiBarRight
			flyout_dir = "LEFT",
			grid = false,
			num = 12,
			per_row = 1,
			size = 32,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "LEFT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
			},
			macro = {
				enabled = true,
				size = 12,
			},
			count = {
				enabled = true,
				size = 12,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 12,
					v_alignment = "MIDDLE",
				},
			},
			point = {
				ls = {p = "RIGHT", anchor = "UIParent", rP = "RIGHT", x = -4, y = 0},
				traditional = {p = "RIGHT", anchor = "UIParent", rP = "RIGHT", x = -4, y = 0},
			},
		},
		bar6 = { --PetAction
			flyout_dir = "UP",
			grid = false,
			num = 10,
			per_row = 10,
			size = 24,
			spacing = 4,
			visibility = "[pet,nopetbattle,novehicleui,nooverridebar,nopossessbar] show; hide",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 10,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 10,
					v_alignment = "MIDDLE",
				},
			},
		},
		bar7 = { -- Stance
			flyout_dir = "UP",
			num = 10,
			per_row = 10,
			size = 24,
			spacing = 4,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 10,
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
			size = 32,
			spacing = 4,
			visibility = "[petbattle] show; hide",
			visible = true,
			x_growth = "RIGHT",
			y_growth = "DOWN",
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 12,
			},
			point = {
				ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 20},
				traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 20},
			},
		},
		extra = { -- ExtraAction
			size = 40,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			hotkey = {
				enabled = true,
				size = 14,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 14,
					v_alignment = "MIDDLE",
				},
			},
			point = {
				ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = -94, y = 250},
				traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = -94, y = 250},
			},
		},
		zone = { -- ZoneAbility
			size = 40,
			visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
			visible = true,
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			cooldown = {
				text = {
					enabled = true,
					size = 14,
					v_alignment = "MIDDLE",
				},
			},
			point = {
				ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 94, y = 250},
				traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 94, y = 250},
			},
		},
		vehicle = { -- LeaveVehicle
			size = 40,
			visible = true,
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			point = {
				ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 168, y = 134},
				traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 168, y = 134},
			},
		},
		micromenu = {
			visible = true,
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
			bars = {
				micromenu1 = {
					enabled = true,
					num = 13,
					per_row = 13,
					width = 18,
					height = 24,
					spacing = 4,
					x_growth = "RIGHT",
					y_growth = "DOWN",
					point = {
						ls = {p = "BOTTOMRIGHT", anchor = "UIParent", rP = "BOTTOMRIGHT", x = -4, y = 4},
						traditional = {p = "BOTTOMRIGHT", anchor = "UIParent", rP = "BOTTOMRIGHT", x = -4, y = 4},
					},
				},
				micromenu2 = {
					enabled = true,
					num = 13,
					per_row = 13,
					width = 18,
					height = 24,
					spacing = 4,
					x_growth = "RIGHT",
					y_growth = "DOWN",
				},
				bags = {
					enabled = true,
					num = 4,
					per_row = 4,
					x_growth = "RIGHT",
					y_growth = "DOWN",
					size = 32,
					spacing = 4,
					point = {
						ls = {p = "BOTTOMRIGHT", anchor = "UIParent", rP = "BOTTOMRIGHT", x = -4, y = 32},
						traditional = {p = "BOTTOMRIGHT", anchor = "UIParent", rP = "BOTTOMRIGHT", x = -4, y = 32},
					},
				},
			},
			buttons = {
				character = {
					enabled = true,
					parent = "micromenu1",
					tooltip = false,
				},
				inventory = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
					currency = {},
				},
				spellbook = {
					enabled = true,
					parent = "micromenu1",
				},
				talent = {
					enabled = true,
					parent = "micromenu1",
				},
				achievement = {
					enabled = true,
					parent = "micromenu1",
				},
				quest = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
				},
				guild = {
					enabled = true,
					parent = "micromenu1",
				},
				lfd = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
				},
				collection = {
					enabled = true,
					parent = "micromenu1",
				},
				ej = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
				},
				store = {
					enabled = false,
					parent = "micromenu1",
				},
				main = {
					enabled = true,
					parent = "micromenu1",
					tooltip = true,
				},
				help = {
					enabled = false,
					parent = "micromenu1",
				},
			},
		},
		xpbar = {
			visible = true,
			width = 594,
			height = 12,
			text = {
				size = 10,
				format = "NUM", -- "NUM_PERC"
				visibility = 2, -- 1 - always, 2 - mouseover
			},
			point = {
				ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 4},
				traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 4},
			},
			fade = {
				enabled = false,
				out_delay = 0.75,
				out_duration = 0.15,
				in_delay = 0,
				in_duration = 0.15,
				min_alpha = 0,
				max_alpha = 1,
			},
		},
	},
	auras = {
		cooldown = {
			exp_threshold = 5, -- [1; 10]
			m_ss_threshold = 600, -- [91; 3599]
		},
		HELPFUL = {
			size = 32,
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
				size = 12,
				position = "TOPLEFT",
				debuff_type = false,
			},
			point = {
				ls = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -6,
					y = -6,
				},
				traditional = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -184,
					y = -6,
				},
			},
		},
		HARMFUL = {
			size = 32,
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
				size = 12,
				position = "TOPLEFT",
				debuff_type = false,
			},
			point = {
				ls = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -6,
					y = -114,
				},
				traditional = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -184,
					y = -114,
				},
			},
		},
		TOTEM = {
			num = 4,
			size = 32,
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
			point = {
				ls = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -4,
					y = -148,
				},
				traditional = {
					p = "TOPRIGHT",
					anchor = "UIParent",
					rP = "TOPRIGHT",
					x = -182,
					y = -148,
				},
			},
		},
	},
	tooltips = {
		id = true,
		count = true,
		title = true,
		target = true,
		inspect = true,
		anchor_cursor = false,
		health = {
			height = 12,
			text = {
				size = 12,
			},
		},
		point = {
			p = "BOTTOMRIGHT",
			anchor = "UIParent",
			rP = "BOTTOMRIGHT",
			x = -76,
			y = 126,
		},
	},
	blizzard = {
		castbar = { -- CastingBarFrame, PetCastingBarFrame
			width = 200,
			height = 12,
			icon = {
				position = "LEFT", -- "RIGHT", "NONE"
			},
			text = {
				font = defaultFont,
				size = 12,
				outline = false,
				shadow = true,
			},
			show_pet = -1, -- -1 - auto, 0 - false, 1 - true
			latency = true,
		},
		character_frame = {
			ilvl = true,
			enhancements = true,
		},
		digsite_bar = { -- ArcheologyDigsiteProgressBar
			width = 200,
			height = 12,
			text = {
				size = 12,
			},
		},
		timer = { -- MirrorTimer*, TimerTrackerTimer*
			width = 200,
			height = 12,
			text = {
				size = 12,
			},
		},
		objective_tracker = { -- ObjectiveTrackerFrame
			height = 600,
			drag_key = "NONE"
		},
		talking_head = {
			hide = false,
		},
	},
	movers = {
		ls = {},
		traditional = {},
	},
}

D.char = {
	layout = "ls", -- or "traditional"
	auras = {
		enabled = true,
	},
	auratracker = {
		enabled = false,
		locked = false,
		num = 12,
		size = 32,
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
			text = {
				enabled = true,
				size = 12,
				h_alignment = "CENTER",
				v_alignment = "BOTTOM",
			},
		},
		type = {
			size = 12,
			position = "TOPLEFT",
			debuff_type = false,
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
		pet_battle = {
			enabled = false,
		},
		xpbar = {
			enabled = true,
		},
	},
	blizzard = {
		enabled = true,
		castbar = { -- CastingBarFrame
			enabled = true
		},
		character_frame = { -- CharacterFrame
			enabled = true,
		},
		command_bar = { -- OrderHallCommandBar
			enabled = true
		},
		digsite_bar = { -- ArcheologyDigsiteProgressBar
			enabled = true,
		},
		durability = { -- DurabilityFrame
			enabled = true
		},
		gm = { -- TicketStatusFrame
			enabled = true
		},
		mail = {
			enabled = false,
		},
		objective_tracker = { -- ObjectiveTrackerFrame
			enabled = true,
		},
		player_alt_power_bar = { -- PlayerPowerBarAlt
			enabled = true
		},
		talking_head = { -- TalkingHeadFrame
			enabled = true
		},
		timer = { -- MirrorTimer*, TimerTrackerTimer*
			enabled = true
		},
		vehicle = { -- VehicleSeatIndicator
			enabled = true
		},
	},
	minimap = {
		enabled = true,
		ls = {
			square = false,
		},
		traditional = {
			square = true,
		},
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
