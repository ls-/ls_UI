local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local assert = _G.assert
local m_abs = _G.math.abs
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local m_max = _G.math.max
local m_min = _G.math.min
local m_modf = _G.math.modf
local next = _G.next
local s_format = _G.string.format
local s_split = _G.string.split
local s_sub = _G.string.sub
local s_upper = _G.string.upper
local s_utf8sub = _G.string.utf8sub
local select = _G.select
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

-- Blizz
local GetTickTime = _G.GetTickTime

-- Mine
-----------
-- MATHS --
-----------

local function clamp(v, min, max)
	return m_min(max or 1, m_max(min or 0, v))
end

local function round(v)
	return m_floor(v + 0.5)
end

function E:Clamp(v, ...)
	return v and clamp(v, ...) or nil
end

function E:Round(v)
	return v and round(v) or nil
end

function E:NumberToPerc(v1, v2)
	return (v1 and v2) and v1 / v2 * 100 or nil
end

do
	local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
	local SECOND_NUMBER_CAP_NO_SPACE = _G.SECOND_NUMBER_CAP_NO_SPACE
	local FIRST_NUMBER_CAP_NO_SPACE = _G.FIRST_NUMBER_CAP_NO_SPACE

	function E:NumberFormat(v, mod)
		if v >= 1E6 then
			local i, f = m_modf(v / 1E6)

			if mod and mod > 0 then
				return s_format("%s.%d"..SECOND_NUMBER_CAP_NO_SPACE, BreakUpLargeNumbers(i), f * 10 ^ mod)
			else
				return s_format("%s"..SECOND_NUMBER_CAP_NO_SPACE, BreakUpLargeNumbers(i))
			end
		elseif v >= 1E4 then
			local i, f = m_modf(v / 1E3)

			if mod and mod > 0 then
				return s_format("%s.%d"..FIRST_NUMBER_CAP_NO_SPACE, BreakUpLargeNumbers(i), f * 10 ^ mod)
			else
				return s_format("%s"..FIRST_NUMBER_CAP_NO_SPACE, BreakUpLargeNumbers(i))
			end
		elseif v >= 0 then
			return BreakUpLargeNumbers(v)
		else
			return 0
		end
	end
end

do
	local D_D_ABBR = _G.DAY_ONELETTER_ABBR:gsub("[ .]", "")
	local D_H_ABBR = _G.HOUR_ONELETTER_ABBR:gsub("[ .]", "")
	local D_M_ABBR = _G.MINUTE_ONELETTER_ABBR:gsub("[ .]", "")
	local D_S_ABBR = _G.SECOND_ONELETTER_ABBR:gsub("[ .]", "")
	local D_MS_ABBR = "%d" .. _G.MILLISECONDS_ABBR

	local F_D_ABBR = D_D_ABBR:gsub("%%d", "%%.1f")
	local F_H_ABBR = D_H_ABBR:gsub("%%d", "%%.1f")
	local F_M_ABBR = D_M_ABBR:gsub("%%d", "%%.1f")
	local F_S_ABBR = D_S_ABBR:gsub("%%d", "%%.1f")
	local F_MS_ABBR = "%.1f" .. _G.MILLISECONDS_ABBR

	local X_XX_FORMAT = "%d:%02d"
	local D = "%d"
	local F = "%.1f"

	function E:TimeFormat(v)
		if v >= 86400 then
			return s_format(D_D_ABBR, round(v / 86400)), "e5e5e5"
		elseif v >= 3600 then
			return s_format(D_H_ABBR, round(v / 3600)), "e5e5e5"
		elseif v >= 60 then
			return s_format(D_M_ABBR, round(v / 60)), "e5e5e5"
		elseif v >= 5 then
			return s_format(D_S_ABBR, round(v)), v >= 30 and "e5e5e5" or v >= 10 and "ffbf19" or "e51919"
		elseif v >= 0 then
			return s_format("%.1f", v), "e51919"
		else
			return 0
		end
	end

	function E:SecondsToTime(v, format)
		if format == "abbr" then
			if v >= 86400 then
				return m_ceil(v / 86400), nil, D_D_ABBR
			elseif v >= 3600 then
				return m_ceil(v / 3600), nil, D_H_ABBR
			elseif v >= 60 then
				return m_ceil(v / 60), nil, D_M_ABBR
			elseif v >= 1 then
				return m_ceil(v / 1), nil, D_S_ABBR
			else
				return m_ceil(v / 0.001), nil, D_MS_ABBR
			end
		elseif format == "x:xx" then
			if v >= 86400 then
				return m_floor(v / 86400), m_floor(v % 86400 / 3600), X_XX_FORMAT
			elseif v >= 3600 then
				return m_floor(v / 3600), m_floor(v % 3600 / 60), X_XX_FORMAT
			elseif v >= 60 then
				return m_floor(v / 60), m_floor(v % 60 / 1), X_XX_FORMAT
			elseif v >= 1 then
				return m_floor(v / 1), m_floor(v % 1 / 0.001), X_XX_FORMAT
			else
				return 0, m_floor(v / 0.001), X_XX_FORMAT
			end
		elseif format == "frac" then
			if v >= 86400 then
				return v / 86400, nil, F
			elseif v >= 3600 then
				return v / 3600, nil, F
			elseif v >= 60 then
				return v / 60, nil, F
			else
				return v, nil, F
			end
		elseif format == "frac-abbr" then
			if v >= 86400 then
				return v / 86400, nil, F_D_ABBR
			elseif v >= 3600 then
				return v / 3600, nil, F_H_ABBR
			elseif v >= 60 then
				return v / 60, nil, F_M_ABBR
			elseif v >= 1 then
				return v, nil, F_S_ABBR
			else
				return v, nil, F_MS_ABBR
			end
		else
			if v >= 86400 then
				return m_ceil(v / 86400), nil, D
			elseif v >= 3600 then
				return m_ceil(v / 3600), nil, D
			elseif v >= 60 then
				return m_ceil(v / 60), nil, D
			elseif v >= 1 then
				return m_ceil(v), nil, D
			else
				return v, nil, F
			end
		end
	end
end

-------------
-- COLOURS --
-------------

do
	local adjustment_cache = {}
	local rgb_hex_cache = {}
	local hex_rgb_cache = {}

	-- http://marcocorvi.altervista.org/games/imgpr/rgb-hsl.htm
	local function RGBToHSL(r, g, b)
		local max = m_max(r, g, b)
		local min = m_min(r, g, b)
		local l = (max + min) / 2
		local h, s

		if max == min then
			h, s = 0, 0
		else
			local d = max - min

			if max == r then
				h = 60 * (g - b) / d
			elseif max == g then
				h = 60 * (b - r) / d + 120
			else
				h = 60 * (r - g) / d + 240
			end

			s = l < 0.5 and d / (2 * l) or d / (2 - 2 * l)
		end

		return h % 360, s, l
	end

	local function HueToRGB(v1, v2, v3)
		if v3 < 0 then
			v3 = v3 + 1
		elseif v3 > 1 then
			v3 = v3 - 1
		end

		if v3 < 1 / 6 then
			return v1 + (v2 - v1) * 6 * v3
		elseif v3< 1 / 2 then
			return v2
		elseif v3 < 2 / 3 then
			return v1 + (v2 - v1) * (2 / 3 - v3) * 6
		end

		return v1
	end

	local function HSLToRGB(h, s, l)
		if s == 0 then
			return l, l, l
		else
			local v2 = l < 0.5 and l * (1 + s) or l + s - l * s
			local v1 = 2 * l - v2
			h = h / 360

			return clamp(HueToRGB(v1, v2, h + 1 / 3)), clamp(HueToRGB(v1, v2, h)), clamp(HueToRGB(v1, v2, h - 1 / 3))
		end
	end

	local function RGBToHEX(r, g, b)
		local key = r.."-"..g.."-"..b

		if rgb_hex_cache[key] then
			return rgb_hex_cache[key]
		end

		rgb_hex_cache[key] = s_format("%02x%02x%02x", clamp(r) * 255, clamp(g) * 255, clamp(b) * 255)

		return rgb_hex_cache[key]
	end

	local function HEXToRGB(hex)
		if hex_rgb_cache[hex] then
			return unpack(hex_rgb_cache[hex])
		end

		local r, g, b = tonumber(s_sub(hex, 1, 2), 16), tonumber(s_sub(hex, 3, 4), 16), tonumber(s_sub(hex, 5, 6), 16)
		r, g, b = tonumber(s_format("%.3f", r / 255)), tonumber(s_format("%.3f", g / 255)), tonumber(s_format("%.3f", b / 255))

		hex_rgb_cache[hex] = {r, g, b}

		return r, g, b
	end

	local function adjustColor(r, g, b, perc)
		local key = r.."-"..g.."-"..b

		if not adjustment_cache[perc] then
			adjustment_cache[perc] = {}
		else
			if adjustment_cache[perc][key] then
				return unpack(adjustment_cache[perc][key])
			end
		end

		local h, s, l = RGBToHSL(r, g, b)
		r, g, b = HSLToRGB(h, s, clamp(l + perc))

		adjustment_cache[perc][key] = {r, g, b}

		return r, g, b
	end

	-- http://wow.gamepedia.com/ColorGradient
	local function calcGradient(perc, ...)
		local num = select("#", ...)

		if num == 1 then
			local colorTable = ...
			num = #colorTable

			if perc >= 1 then
				return colorTable[num - 2], colorTable[num - 1], colorTable[num]
			elseif perc <= 0 then
				return colorTable[1], colorTable[2], colorTable[3]
			end

			local i, relperc = m_modf(perc * (num / 3 - 1))
			local r1, g1, b1, r2, g2, b2 = colorTable[i * 3 + 1], colorTable[i * 3 + 2], colorTable[i * 3 + 3], colorTable[i * 3 + 4], colorTable[i * 3 + 5],colorTable[i * 3 + 6]

			return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
		else
			if perc >= 1 then
				return select(num - 2, ...)
			elseif perc <= 0 then
				local r, g, b = ...
				return r, g, b
			end

			local i, relperc = m_modf(perc * (num / 3- 1))
			local r1, g1, b1, r2, g2, b2 = select((i * 3) + 1, ...)

			return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
		end
	end

	function E:RGBToHEX(r, g, b)
		if type(r) == "table" then
			if r.r then
				r, g, b = r.r, r.g, r.b
			else
				r, g, b = unpack(r)
			end
		end

		return RGBToHEX(r, g, b)
	end

	function E:HEXToRGB(hex)
		return HEXToRGB(hex)
	end

	function E:AdjustColor(r, g, b, perc)
		if type(r) == "table" then
			if r.r then
				r, g, b = r.r, r.g, r.b
			else
				r, g, b = unpack(r)
			end
		end

		if r > 1 or g > 1 or b > 1 then
			r, g, b = r / 255, g / 255, b / 255
		end

		if perc and perc ~= 0 then
			return adjustColor(r, g, b, perc)
		else
			return r, g, b
		end
	end

	-- E:CreateColor
	do
		local function getHEX(self, adjustment)
			if adjustment and adjustment ~= 0 then
				return RGBToHEX(adjustColor(self.r, self.g, self.b, adjustment))
			else
				return self.hex
			end
		end

		local function getRGB(self, adjustment)
			if adjustment and adjustment ~= 0 then
				return adjustColor(self.r, self.g, self.b, adjustment)
			else
				return self.r, self.g, self.b
			end
		end

		local function getRGBA(self, alpha, adjustment)
			if adjustment and adjustment ~= 0 then
				local r, g, b = adjustColor(self.r, self.g, self.b, adjustment)

				return r, g, b, alpha or self.a
			else
				return self.r, self.g, self.b, alpha or self.a
			end
		end

		local function getRGBHEX(self, adjustment)
			if adjustment and adjustment ~= 0 then
				local r, g, b = adjustColor(self.r, self.g, self.b, adjustment)

				return r, g, b, RGBToHEX(r, g, b)
			else
				return self.r, self.g, self.b, self.hex
			end
		end

		local function wrapText(self, text, adjustment)
			return s_format("|cff%s%s|r", getHEX(self, adjustment), text)
		end

		function E:CreateColor(r, g, b, a)
			r, g, b, a = r or 1, g or 1, b or 1, a or 1

			if r > 1 or g > 1 or b > 1 then
				r, g, b = r / 255, g / 255, b / 255
			end

			local color = {r = r, g = g, b = b, a = a, hex = RGBToHEX(r, g, b)}

			color.GetHEX = getHEX
			color.GetRGB = getRGB
			color.GetRGBA = getRGBA
			color.GetRGBHEX = getRGBHEX
			color.WrapText = wrapText

			return color
		end
	end

	-- E:CreateColorTable
	do
		local function getHEX(self, perc, adjustment)
			if adjustment and adjustment ~= 0 then
				local r, g, b = calcGradient(perc, self)

				return RGBToHEX(adjustColor(r, g, b, adjustment))
			else
				return RGBToHEX(calcGradient(perc, self))
			end
		end

		local function getRGB(self, perc, adjustment)
			local r, g, b = calcGradient(perc, self)

			if adjustment and adjustment ~= 0 then
				r, g, b = adjustColor(r, g, b, adjustment)
			end

			return r, g, b
		end

		local function getRGBA(self, perc, alpha, adjustment)
			local r, g, b = calcGradient(perc, self)

			if adjustment and adjustment ~= 0 then
				r, g, b = adjustColor(r, g, b, adjustment)
			end

			return r, g, b, alpha or 1
		end

		local function getRGBHEX(self, perc, adjustment)
			local r, g, b = calcGradient(perc, self)

			if adjustment and adjustment ~= 0 then
				r, g, b = adjustColor(r, g, b, adjustment)
			end

			return r, g, b, RGBToHEX(r, g, b)
		end

		local function wrapText(self, perc, text, adjustment)
			return s_format("|cff%s%s|r", getHEX(self, perc, adjustment), text)
		end

		function E:CreateColorTable(...)
			local params = {...}
			local num = #params

			assert((num == 9 or num == 3), s_format("Invalid number of arguments to 'E:CreateColorTable' method, expected '3' or '9', got '%s'", num))

			if num == 3 then
				local temp = {}

				for i = 1, #params do
					for k = 1, #params[i] do
						temp[3 * (i - 1) + k] = params[i][k]
					end
				end

				params = temp
			end

			params.GetHEX = getHEX
			params.GetRGB = getRGB
			params.GetRGBA = getRGBA
			params.GetRGBHEX = getRGBHEX
			params.WrapText = wrapText

			return params
		end
	end

	do
		local objects = {}

		local function isCloseEnough(r, g, b, tR, tG, tB)
			return m_abs(r - tR) <= 0.05 and m_abs(g - tG) <= 0.05 and m_abs(b - tB) <= 0.05
		end

		C_Timer.NewTicker(0, function()
			for object, target in next, objects do
				local r, g, b = calcGradient(clamp(0.25 * GetTickTime() * 60.0), object._r, object._g, object._b, target.r, target.g, target.b)

				if isCloseEnough(object._r, object._g, object._b, target.r, target.g, target.b) then
					r, g, b = target.r, target.g, target.b
					objects[object] = nil
				end

				object:SetVertexColor_(r, g, b, target.a)
				object._r, object._g, object._b = r, g, b
			end
		end)

		local function object_SetSmoothedVertexColor(self, r, g, b, a)
			self._r, self._g, self._b = self:GetVertexColor()

			if isCloseEnough(self._r, self._g, self._b, r, g, b) then
				self:SetVertexColor_(r, g, b, a)
			else
				objects[self] = {r = r, g = g, b = b, a = a}
			end
		end

		function E:SetSmoothedVertexColor(object, r, g, b, a)
			if not object.GetVertexColor then return end

			if not object.SetVertexColor_ then
				object.SetVertexColor_ = object.SetVertexColor
				object.SetVertexColor = object_SetSmoothedVertexColor
			end

			object:SetVertexColor(r, g, b, a)
		end

		function E:SmoothColor(object)
			if not object.GetVertexColor then return end

			object.SetVertexColor_ = object.SetVertexColor
			object.SetVertexColor = object_SetSmoothedVertexColor
		end
	end
end

-----------
-- UNITS --
-----------

do
	local function getUnitPVPHostilityColor(unit)
		if UnitExists(unit) then
			if UnitPlayerControlled(unit) then
				if UnitIsPVP(unit) then
					if UnitCanAttack(unit, "player") then
						-- Hostile
						return M.COLORS.REACTION[2]
					elseif UnitCanAttack("player", unit) then
						-- Not hostile, but can be attacked
						return M.COLORS.REACTION[4]
					elseif UnitCanAssist("player", unit) then
						-- Friendly
						return M.COLORS.REACTION[6]
					end
				else
					-- Unattackable
					return M.COLORS.BLUE
				end
			end
		end
	end

	local function getUnitClassColor(unit)
		if UnitExists(unit) and UnitIsPlayer(unit) then
			return M.COLORS.CLASS[select(2, UnitClass(unit))]
		end
	end

	local function getUnitReactionColor(unit)
		if UnitExists(unit) then
			return M.COLORS.REACTION[UnitReaction(unit, "player")]
		end
	end

	local function getUnitTappedColor(unit)
		if UnitExists(unit) and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
			return M.COLORS.TAPPED
		end
	end

	local function getUnitDisconnectedColor(unit)
		if UnitExists(unit) and not UnitIsConnected(unit) then
			return M.COLORS.DISCONNECTED
		end
	end

	function E:GetUnitClassColor(unit)
		return getUnitClassColor(unit) or M.COLORS.DISCONNECTED
	end

	function E:GetUnitReactionColor(unit)
		return getUnitReactionColor(unit) or M.COLORS.REACTION[4]
	end

	function E:GetUnitColor(unit, checkPvPHostility, checkClass)
		local color

		color = getUnitDisconnectedColor(unit)

		if not color and checkPvPHostility then
			color = getUnitPVPHostilityColor(unit)
		end

		if not color and checkClass then
			color = getUnitClassColor(unit)
		end

		if not color then
			color = getUnitTappedColor(unit)
		end

		if not color then
			color = getUnitReactionColor(unit)
		end

		return color or M.COLORS.REACTION[4]
	end

	function E:GetUnitClassification(unit)
		if UnitExists(unit) then
			local c = UnitClassification(unit)

			if c == "rare" then
				return "R"
			elseif c == "rareelite" then
				return "R+"
			elseif c == "elite" then
				return "+"
			elseif c == "worldboss" then
				return "B"
			elseif c == "minus" then
				return "-"
			end
		end

		return ""
	end

	function E:GetUnitPVPStatus(unit)
		local faction

		if UnitExists(unit) then
			faction = UnitFactionGroup(unit)

			if UnitIsPVPFreeForAll(unit) then
				return true, "FFA"
			elseif UnitIsPVP(unit) and faction and faction ~= "Neutral" then
				if UnitIsMercenary(unit) then
					if faction == "Horde" then
						faction = "Alliance"
					elseif faction == "Alliance" then
						faction = "Horde"
					end
				end

				return true, s_upper(faction or "NEUTRAL")
			end
		end

		return false, s_upper(faction or "NEUTRAL")
	end

	function E:GetUnitSpecializationInfo(unit)
		if UnitExists(unit) then
			local isPlayer = UnitIsUnit(unit, "player")
			local specID = isPlayer and GetSpecialization() or GetInspectSpecialization(unit)

			if specID and specID > 0 then
				if isPlayer then
					local _, name = GetSpecializationInfo(specID)

					return name
				else
					local _, name = GetSpecializationInfoByID(specID)

					return name
				end
			end
		end

		return L["UNKNOWN"]
	end

	-- XXX: GetRelativeDifficultyColor function in UIParent.lua
	function E:GetRelativeDifficultyColor(unitLevel, challengeLevel)
		local diff = challengeLevel - unitLevel

		if diff >= 5 then
			return M.COLORS.DIFFICULTY.IMPOSSIBLE
		elseif diff >= 3 then
			return M.COLORS.DIFFICULTY.VERYDIFFICULT
		elseif diff >= -4 then
			return M.COLORS.DIFFICULTY.DIFFICULT
		elseif -diff <= GetQuestGreenRange() then
			return M.COLORS.DIFFICULTY.STANDARD
		else
			return M.COLORS.DIFFICULTY.TRIVIAL
		end
	end

	function E:GetCreatureDifficultyColor(level)
		return self:GetRelativeDifficultyColor(UnitEffectiveLevel("player"), level > 0 and level or 199)
	end

	do
		local ARMOR_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}

		function E:GetUnitAverageItemLevel(unit)
			if UnitIsUnit(unit, "player") then
				return m_floor(select(2, GetAverageItemLevel()))
			else
				local isInspectSuccessful = true
				local total = 0

				-- Armour
				for _, id in next, ARMOR_SLOTS do
					local link = GetInventoryItemLink(unit, id)
					local texture = GetInventoryItemTexture(unit, id)

					if link then
						local cur = GetDetailedItemLevelInfo(link)

						if cur and cur > 0 then
							total = total + cur
						end
					elseif texture then
						isInspectSuccessful = false
					end
				end

				-- Main hand
				local link = GetInventoryItemLink(unit, 16)
				local texture = GetInventoryItemTexture(unit, 16)
				local mainItemLevel, mainQuality, mainEquipLoc, _ = 0

				if link then
					mainItemLevel = GetDetailedItemLevelInfo(link)
					_, _, mainQuality, _, _, _, _, _, mainEquipLoc = GetItemInfo(link)
				elseif texture then
					isInspectSuccessful = false
				end

				-- Off hand
				link = GetInventoryItemLink(unit, 17)
				texture = GetInventoryItemTexture(unit, 17)
				local offItemLevel, offEquipLoc = 0

				if link then
					offItemLevel = GetDetailedItemLevelInfo(link)
					_, _, _, _, _, _, _, _, offEquipLoc = GetItemInfo(link)
				elseif texture then
					isInspectSuccessful = false
				end

				if mainQuality == 6 or (mainEquipLoc == "INVTYPE_2HWEAPON" and not offEquipLoc and GetInspectSpecialization(unit) ~= 72) then
					mainItemLevel = m_max(mainItemLevel, offItemLevel)
					total = total + mainItemLevel * 2
				else
					total = total + mainItemLevel + offItemLevel
				end

				-- print("total:", total, "cur:", m_floor(total / 16), isInspectSuccessful and "SUCCESS!" or "FAIL!")
				return isInspectSuccessful and m_floor(total / 16) or nil
			end
		end
	end
end

---------------------
-- PLAYER SPECIFIC --
---------------------

do
	local dispelTypesByClass = {
		PALADIN = {},
		SHAMAN = {},
		DRUID = {},
		PRIEST = {},
		MONK = {},
	}

	E:RegisterEvent("SPELLS_CHANGED", function()
		local dispelTypes = dispelTypesByClass[E.PLAYER_CLASS]

		if dispelTypes then
			if E.PLAYER_CLASS == "PALADIN" then
				dispelTypes.Disease = IsPlayerSpell(4987) or IsPlayerSpell(213644) or nil -- Cleanse or Cleanse Toxins
				dispelTypes.Magic = IsPlayerSpell(4987) or nil -- Cleanse
				dispelTypes.Poison = dispelTypes.Disease
			elseif E.PLAYER_CLASS == "SHAMAN" then
				dispelTypes.Curse = IsPlayerSpell(51886) or IsPlayerSpell(77130) or nil -- Cleanse Spirit or Purify Spirit
				dispelTypes.Magic = IsPlayerSpell(77130) or nil -- Purify Spirit
			elseif E.PLAYER_CLASS == "DRUID" then
				dispelTypes.Curse = IsPlayerSpell(2782) or IsPlayerSpell(88423) or nil -- Remove Corruption or Nature's Cure
				dispelTypes.Magic = IsPlayerSpell(88423) or nil -- Nature's Cure
				dispelTypes.Poison = dispelTypes.Curse
			elseif E.PLAYER_CLASS == "PRIEST"then
				dispelTypes.Disease = IsPlayerSpell(527) or nil -- Purify
				dispelTypes.Magic = IsPlayerSpell(527) or IsPlayerSpell(32375) or nil -- Purify or Mass Dispel
			elseif E.PLAYER_CLASS == "MONK" then
				dispelTypes.Disease = IsPlayerSpell(115450) or nil -- Detox
				dispelTypes.Magic = dispelTypes.Disease
				dispelTypes.Poison = dispelTypes.Disease
			end
		end
	end)

	function E:GetDispelTypes()
		return dispelTypesByClass[E.PLAYER_CLASS]
	end

	function E:IsDispellable(debuffType)
		return dispelTypesByClass[E.PLAYER_CLASS] and dispelTypesByClass[E.PLAYER_CLASS][debuffType] or nil
	end
end

-------------------------
-- FONT STRINGS & TEXT --
-------------------------

function E:TruncateString(v, length)
	return s_utf8sub(v, 1, length)
end

------------------------
-- POINTS AND ANCHORS --
------------------------

function E:ResolveAnchorPoint(frame, children)
	if not frame then
		children = {s_split(".", children)}

		local anchor = _G[children[1]]

		assert(anchor, "Invalid anchor: "..children[1]..".")

		for i = 2, #children do
			anchor = anchor[children[i]]
		end

		return anchor
	else
		if not children or children == "" then
			return frame
		else
			local anchor = frame

			children = {s_split(".", children)}

			for i = 1, #children do
				anchor = anchor[children[i]]
			end

			return anchor
		end
	end
end

function E:CalcSegmentsSizes(totalSize, spacing, numSegs)
	local totalSizeWoGaps = totalSize - spacing * (numSegs - 1)
	local segSize = totalSizeWoGaps / numSegs
	local result = {}

	if segSize % 1 == 0 then
		for i = 1, numSegs do
			result[i] = segSize
		end
	else
		local numOddSegs = numSegs % 2 == 0 and 2 or 1
		local numNormalSegs = numSegs - numOddSegs
		segSize = round(segSize)

		for i = 1, numNormalSegs / 2 do
			result[i] = segSize
		end

		for i = numSegs - numNormalSegs / 2 + 1, numSegs do
			result[i] = segSize
		end

		segSize = (totalSizeWoGaps - segSize * numNormalSegs) / numOddSegs

		for i = 1, numOddSegs do
			result[numNormalSegs / 2 + i] = segSize
		end
	end

	return result
end

function E:ForceShow(object)
	if not object then return end

	object:Show()

	object.Hide = object.Show
end

function E:ForceHide(object, skipEvents, doNotHide)
	if not object then return end

	if not skipEvents and object.UnregisterAllEvents then
		object:UnregisterAllEvents()

		if object:GetName() then
			UIPARENT_MANAGED_FRAME_POSITIONS[object:GetName()] = nil
		end
	end

	if not doNotHide then
		object:Hide()
	end

	object:SetParent(self.HIDDEN_PARENT)
end

function E:GetCoords(object)
	local p, anchor, rP, x, y = object:GetPoint()

	if not x then
		return p, anchor, rP, x, y
	else
		return p, anchor and anchor:GetName() or "UIParent", rP, round(x), round(y)
	end
end

function E:GetScreenQuadrant(frame)
	local x, y

	if frame == "cursor" then
		x, y = GetCursorPosition()
		x = x / UIParent:GetEffectiveScale()
		y = y / UIParent:GetEffectiveScale()
	else
		x, y = frame:GetCenter()
	end

	if not (x and y) then
		return "UNKNOWN"
	end

	local screenWidth = UIParent:GetRight()
	local screenHeight = UIParent:GetTop()
	local screenLeft = screenWidth / 3
	local screenRight = screenWidth * 2 / 3

	if y >= screenHeight * 2 / 3 then
		if x <= screenLeft then
			return "TOPLEFT"
		elseif x >= screenRight then
			return "TOPRIGHT"
		else
			return "TOP"
		end
	elseif y <= screenHeight / 3 then
		if x <= screenLeft then
			return "BOTTOMLEFT"
		elseif x >= screenRight then
			return "BOTTOMRIGHT"
		else
			return "BOTTOM"
		end
	else
		if x <= screenLeft then
			return "LEFT"
		elseif x >= screenRight then
			return "RIGHT"
		else
			return "CENTER"
		end
	end
end
