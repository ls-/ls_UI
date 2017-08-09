local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local assert = _G.assert
local b_and = _G.bit.band
local b_not = _G.bit.bnot
local b_or = _G.bit.bor
local b_xor = _G.bit.bxor
local m_abs = _G.math.abs
local m_floor = _G.math.floor
local m_max = _G.math.max
local m_min = _G.math.min
local m_modf = _G.math.modf
local next = _G.next
local s_format = _G.string.format
local s_split = _G.string.split
local s_sub = _G.string.sub
local s_utf8sub = _G.string.utf8sub
local select = _G.select
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

-- Blizz
local FrameDeltaLerp = _G.FrameDeltaLerp
local GetTickTime = _G.GetTickTime
local Saturate = _G.Saturate
local FIRST_NUMBER_CAP_NO_SPACE = _G.FIRST_NUMBER_CAP_NO_SPACE
local SECOND_NUMBER_CAP_NO_SPACE = _G.SECOND_NUMBER_CAP_NO_SPACE

-- Mine
local DAY_ONELETTER_ABBR = _G.DAY_ONELETTER_ABBR:gsub("[ .]", "")
local HOUR_ONELETTER_ABBR = _G.HOUR_ONELETTER_ABBR:gsub("[ .]", "")
local MINUTE_ONELETTER_ABBR = _G.MINUTE_ONELETTER_ABBR:gsub("[ .]", "")
local SECOND_ONELETTER_ABBR = _G.SECOND_ONELETTER_ABBR:gsub("[ .]", "")
local INSPECT_ARMOR_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
local argcheck = P.argcheck

------------
-- TABLES --
------------

local function CopyTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in next, src do
		if type(v) == "table" then
			dest[k] = CopyTable(v, dest[k])
		else
			dest[k] = v
		end
	end

	return dest
end

local function UpdateTable(src, dest)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in next, src do
		if type(v) == "table" then
			dest[k] = UpdateTable(v, dest[k])
		else
			if dest[k] == nil then
				dest[k] = v
			end
		end
	end

	return dest
end

local function DiffTable(src , dest)
	if type(dest) ~= "table" then
		return {}
	end

	if type(src) ~= "table" then
		return dest
	end

	for k, v in next, dest do
		if type(v) == "table" then
			if not next(DiffTable(src[k], v)) then
				dest[k] = nil
			end
		elseif v == src[k] then
			dest[k] = nil
		end
	end

	return dest
end

local function IsEqualTable(a, b)
	for k, v in next, a do
		if type(v) == "table" and type(b[k]) == "table" then
			if not IsEqualTable(v, b[k]) then
				return false
			end
		else
			if v ~= b[k] then
				return false
			end
		end
	end

	for k, v in next, b do
		if type(v) == "table" and type(a[k]) == "table" then
			if not IsEqualTable(v, a[k]) then
				return false
			end
		else
			if v ~= a[k] then
				return false
			end
		end
	end

	return true
end

local function IsEqual(a, b)
	if type(a) ~= type(b) then
		return false
	end

	if type(a) == "table" then
		return IsEqualTable(a, b)
	else
		return a == b
	end
end

function E:CopyTable(...)
	return CopyTable(...)
end

function E:UpdateTable(...)
	return UpdateTable(...)
end

function E:DiffTable(...)
	return DiffTable(...)
end

function E:IsEqualTable(...)
	return IsEqual(...)
end

-----------
-- MATHS --
-----------

local function Clamp(v, min, max)
	return m_min(max or 1, m_max(min or 0, v))
end

local function Round(v)
	return m_floor(v + 0.5)
end

function E:Clamp(v, ...)
	return v and Clamp(v, ...) or nil
end

function E:Round(v)
	return v and Round(v) or nil
end

function E:NumberToPerc(v1, v2)
	return (v1 and v2) and v1 / v2 * 100 or nil
end

function E:NumberFormat(v, mod)
	v = m_abs(v)

	if v >= 1E6 then
		return s_format("%."..(mod or 0).."f"..SECOND_NUMBER_CAP_NO_SPACE, v / 1E6)
	elseif v >= 1E4 then
		return s_format("%."..(mod or 0).."f"..FIRST_NUMBER_CAP_NO_SPACE, v / 1E3)
	else
		return v
	end
end

function E:TimeFormat(v)
	if v >= 86400 then
		return Round(v / 86400), "|cffe5e5e5", DAY_ONELETTER_ABBR
	elseif v >= 3600 then
		return Round(v / 3600), "|cffe5e5e5", HOUR_ONELETTER_ABBR
	elseif v >= 60 then
		return Round(v / 60), "|cffe5e5e5", MINUTE_ONELETTER_ABBR
	elseif v >= 30 then
		return Round(v), "|cffe5e5e5", SECOND_ONELETTER_ABBR
	elseif v >= 10 then
		return Round(v), "|cffffbf19", SECOND_ONELETTER_ABBR
	elseif v >= 5 then
		return Round(v), "|cffe51919", SECOND_ONELETTER_ABBR
	elseif v >= 0 then
		return tonumber(s_format("%.1f", v)), "|cffe51919", "%.1f"
	else
		return 0
	end
end

-------------
-- COLOURS --
-------------

local adjustment_cache = {}

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

		return Clamp(HueToRGB(v1, v2, h + 1 / 3)), Clamp(HueToRGB(v1, v2, h)), Clamp(HueToRGB(v1, v2, h - 1 / 3))
	end
end

local function RGBToHEX(r, g, b)
	return s_format("%02x%02x%02x", Clamp(r) * 255, Clamp(g) * 255, Clamp(b) * 255)
end

local function HEXToRGB(hex)
	local rhex, ghex, bhex = tonumber(s_sub(hex, 1, 2), 16), tonumber(s_sub(hex, 3, 4), 16), tonumber(s_sub(hex, 5, 6), 16)

	return tonumber(s_format("%.3f", rhex / 255)), tonumber(s_format("%.3f", ghex / 255)), tonumber(s_format("%.3f", bhex / 255))
end

local function AdjustColor(r, g, b, perc)
	local key = r.."-"..g.."-"..b

	if not adjustment_cache[perc] then
		adjustment_cache[perc] = {}
	else
		if adjustment_cache[perc][key] then
			return unpack(adjustment_cache[perc][key])
		end
	end

	local h, s, l = RGBToHSL(r, g, b)
	r, g, b = HSLToRGB(h, s, Clamp(l + perc))

	adjustment_cache[perc][key] = {r, g, b}

	return r, g, b
end

-- http://wow.gamepedia.com/ColorGradient
local function CalcGradient(colorTable, perc)
	local num = #colorTable

	if perc >= 1 then
		return colorTable[num - 2], colorTable[num - 1], colorTable[num]
	elseif perc <= 0 then
		return colorTable[1], colorTable[2], colorTable[3]
	end

	local i, relperc = m_modf(perc * (num / 3 - 1))
	local r1, g1, b1, r2, g2, b2 = colorTable[i * 3 + 1], colorTable[i * 3 + 2], colorTable[i * 3 + 3], colorTable[i * 3 + 4], colorTable[i * 3 + 5],colorTable[i * 3 + 6]

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc, 1
end

local function GetColorHEX(self, adjustment)
	if adjustment and adjustment ~= 0 then
		return RGBToHEX(AdjustColor(self.r, self.g, self.b, adjustment))
	else
		return self.hex
	end
end

local function GetColorRGB(self, adjustment)
	if adjustment and adjustment ~= 0 then
		return AdjustColor(self.r, self.g, self.b, adjustment)
	else
		return self.r, self.g, self.b
	end
end

local function GetColorRGBA(self, alpha, adjustment)
	if adjustment and adjustment ~= 0 then
		local r, g, b = AdjustColor(self.r, self.g, self.b, adjustment)

		return r, g, b, alpha or self.a
	else
		return self.r, self.g, self.b, alpha or self.a
	end
end

local function GetColorRGBHEX(self, adjustment)
	if adjustment and adjustment ~= 0 then
		local r, g, b = AdjustColor(self.r, self.g, self.b, adjustment)

		return r, g, b, RGBToHEX(r, g, b)
	else
		return self.r, self.g, self.b, self.hex
	end
end

local function WrapTextInColorCode(self, text, adjustment)
	return s_format("|cff%s%s|r", GetColorHEX(self, adjustment), text)
end

local function GetGradientHEX(self, perc, adjustment)
	if adjustment and adjustment ~= 0 then
		local r, g, b = CalcGradient(self, perc)

		return RGBToHEX(AdjustColor(r, g, b, adjustment))
	else
		return RGBToHEX(CalcGradient(self, perc))
	end
end

local function GetGradientRGB(self, perc, adjustment)
	local r, g, b = CalcGradient(self, perc)

	if adjustment and adjustment ~= 0 then
		r, g, b = AdjustColor(r, g, b, adjustment)
	end

	return r, g, b
end

local function GetGradientRGBA(self, perc, alpha, adjustment)
	local r, g, b, a = CalcGradient(self, perc)

	if adjustment and adjustment ~= 0 then
		r, g, b = AdjustColor(r, g, b, adjustment)
	end

	return r, g, b, alpha or a
end

local function GetGradientRGBHEX(self, perc, adjustment)
	local r, g, b = CalcGradient(self, perc)

	if adjustment and adjustment ~= 0 then
		r, g, b = AdjustColor(r, g, b, adjustment)
	end

	return r, g, b, RGBToHEX(r, g, b)
end

local function WrapTextInGradientCode(self, perc, text, adjustment)
	return s_format("|cff%s%s|r", GetGradientHEX(self, perc, adjustment), text)
end

function E:CreateColor(r, g, b, a)
	r, g, b, a = r or 1, g or 1, b or 1, a or 1

	if r > 1 or g > 1 or b > 1 then
		r, g, b = r / 255, g / 255, b / 255
	end

	local color = {r = r, g = g, b = b, a = a, hex = RGBToHEX(r, g, b)}

	color.GetHEX = GetColorHEX
	color.GetRGB = GetColorRGB
	color.GetRGBA = GetColorRGBA
	color.GetRGBHEX = GetColorRGBHEX
	color.WrapText = WrapTextInColorCode

	return color
end

function E:CreateColorTable(...)
	local params = {...}
	local num = #params

	assert((num == 9 or num == 3), s_format("Invalid number of arguments in 'E:CreateColorTable' ('3' or '9' expected, got '%s')", num))

	if num == 3 then
		local temp = {}

		for i = 1, #params do
			for k = 1, #params[i] do
				temp[3 * (i - 1) + k] = params[i][k]
			end
		end

		params = temp
	end

	for i = 1, 9 do
		argcheck(i, params[i], "number")
	end

	params.GetHEX = GetGradientHEX
	params.GetRGB = GetGradientRGB
	params.GetRGBA = GetGradientRGBA
	params.GetRGBHEX = GetGradientRGBHEX
	params.WrapText = WrapTextInGradientCode

	return params
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
		return AdjustColor(r, g, b, perc)
	else
		return r, g, b
	end
end

local vc_objects = {}

local function ProcessSmoothColors()
	for object, target in next, vc_objects do
		local r, g, b = CalcGradient({object._r, object._g, object._b, target.r, target.g, target.b}, Saturate(0.1 * GetTickTime() * 60.0))

		if m_abs(r - target.r) <= 0.05
			and m_abs(g - target.g) <= 0.05
			and m_abs(b - target.b) <= 0.05 then
			r, g, b = target.r, target.g, target.b
			vc_objects[object] = nil
		end

		object:SetVertexColor(r, g, b)
		object._r, object._g, object._b = r, g, b
	end
end

_G.C_Timer.NewTicker(0, ProcessSmoothColors)

function E:SetSmoothedVertexColor(object, r, g, b)
	if not object.GetVertexColor then return end

	object._r, object._g, object._b = object:GetVertexColor()
	vc_objects[object] = {r = r, g = g, b = b}
end

-----------------
-- STATUS BARS --
-----------------

local sb_objects = {}

local function IsCloseEnough(new, target, range)
	if range > 0 then
		return m_abs((new - target) / range) <= 0.001
	end

	return true
end

local function ProcessSmoothStatusBars()
	for object, target in next, sb_objects do
		local new = FrameDeltaLerp(object._value, target, 0.25)

		if IsCloseEnough(new, target, object._max - object._min) then
			new = target
			sb_objects[object] = nil
		end

		object:SetValue_(new)
		object._value = new
	end
end

_G.C_Timer.NewTicker(0, ProcessSmoothStatusBars)

local function SetSmoothedValue(self, value)
	self._value = self:GetValue()
	sb_objects[self] = Clamp(value, self._min, self._max)
end

local function SetSmoothedMinMaxValues(self, min, max)
	self:SetMinMaxValues_(min, max)

	if self._max and self._max ~= max then
		local target = sb_objects[self]
		local cur = self._value
		local ratio = 1

		if max ~= 0 and self._max and self._max ~= 0 then
			ratio = max / (self._max or max)
		end

		if target then
			sb_objects[self] = target * ratio
		end

		if cur then
			self:SetValue_(cur * ratio)
		end
	end

	self._min = min
	self._max = max
end

function E:SmoothBar(bar)
	-- reset the bar
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)

	bar.SetValue_ = bar.SetValue
	bar.SetMinMaxValues_ = bar.SetMinMaxValues
	bar.SetValue = SetSmoothedValue
	bar.SetMinMaxValues = SetSmoothedMinMaxValues
end

----------
-- BITS --
----------

function E:CheckFlag(mask, ...)
	local flag = b_or(...)
	return b_and(mask, flag) == flag
end

function E:ToggleFlag(mask, ...)
	return b_xor(mask, ...)
end

function E:EnableFlag(mask, ...)
	return b_or(mask, ...)
end

function E:DisableFlag(mask, filter)
	return b_and(mask, b_not(filter))
end

-----------
-- UNITS --
-----------

local function GetUnitPVPHostilityColor(unit)
	if unit and _G.UnitExists(unit) then
		if _G.UnitPlayerControlled(unit) then
			if _G.UnitIsPVP(unit) then
				if _G.UnitCanAttack(unit, "player") then
					-- Hostile
					return M.COLORS.REACTION[2]
				elseif _G.UnitCanAttack("player", unit) then
					-- Not hostile, but can be attacked
					return M.COLORS.REACTION[4]
				elseif _G.UnitCanAssist("player", unit) then
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

local function GetUnitClassColor(unit)
	if unit and _G.UnitExists(unit) and _G.UnitIsPlayer(unit) then
		return M.COLORS.CLASS[select(2, _G.UnitClass(unit))]
	end
end

local function GetUnitReactionColor(unit)
	if unit and _G.UnitExists(unit) then
		return M.COLORS.REACTION[_G.UnitReaction(unit, "player")]
	end
end

local function GetUnitTappedColor(unit)
	if unit and _G.UnitExists(unit) and not _G.UnitPlayerControlled(unit) and _G.UnitIsTapDenied(unit) then
		return M.COLORS.TAPPED
	end
end

local function GetUnitDisconnectedColor(unit)
	if unit and _G.UnitExists(unit) and not _G.UnitIsConnected(unit) then
		return M.COLORS.DISCONNECTED
	end
end

function E:GetUnitClassColor(unit)
	return GetUnitClassColor(unit) or M.COLORS.DISCONNECTED
end

function E:GetUnitReactionColor(unit)
	return GetUnitReactionColor(unit) or M.COLORS.REACTION[4]
end

function E:GetUnitColor(unit, cPvPHostility, cClass)
	local color

	color = GetUnitDisconnectedColor(unit)

	if not color and cPvPHostility then
		color = GetUnitPVPHostilityColor(unit)
	end

	if not color and cClass then
		color = GetUnitClassColor(unit)
	end

	if not color then
		color = GetUnitTappedColor(unit)
	end

	if not color then
		color = GetUnitReactionColor(unit)
	end

	return color or M.COLORS.REACTION[4]
end

function E:GetUnitClassification(unit)
	if unit and _G.UnitExists(unit) then
		local c = _G.UnitClassification(unit)

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

	if unit and _G.UnitExists(unit) then
		faction = _G.UnitFactionGroup(unit)

		if _G.UnitIsPVPFreeForAll(unit) then
			return true, "FFA"
		elseif _G.UnitIsPVP(unit) and faction and faction ~= "Neutral" then
			if _G.UnitIsMercenary(unit) then
				if faction == "Horde" then
					faction = "Alliance"
				elseif faction == "Alliance" then
					faction = "Horde"
				end
			end

			return true, string.upper(faction or "NEUTRAL")
		end
	end

	return false, string.upper(faction or "NEUTRAL")
end

function E:GetUnitSpecializationInfo(unit)
	if unit and _G.UnitExists(unit) then
		local isPlayer = _G.UnitIsUnit(unit, "player")
		local specID = isPlayer and _G.GetSpecialization() or _G.GetInspectSpecialization(unit)

		if specID and specID > 0 then
			if isPlayer then
				local _, name = _G.GetSpecializationInfo(specID)

				return name
			else
				local _, name = _G.GetSpecializationInfoByID(specID)

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
	elseif -diff <= _G.GetQuestGreenRange() then
		return M.COLORS.DIFFICULTY.STANDARD
	else
		return M.COLORS.DIFFICULTY.TRIVIAL
	end
end

function E:GetCreatureDifficultyColor(level)
	return self:GetRelativeDifficultyColor(_G.UnitEffectiveLevel("player"), level > 0 and level or 199)
end

function E:GetUnitAverageItemLevel(unit)
	if _G.UnitIsUnit(unit, "player") then
		return m_floor(select(2, _G.GetAverageItemLevel()))
	else
		local isInspectSuccessful = true
		local total = 0

		-- Armour
		for _, id in next, INSPECT_ARMOR_SLOTS do
			local link = _G.GetInventoryItemLink(unit, id)
			local texture = _G.GetInventoryItemTexture(unit, id)

			if link then
				local cur = _G.GetDetailedItemLevelInfo(link)

				if cur and cur > 0 then
					total = total + cur
				end
			elseif texture then
				isInspectSuccessful = false
			end
		end

		-- Main hand
		local link = _G.GetInventoryItemLink(unit, 16)
		local texture = _G.GetInventoryItemTexture(unit, 16)
		local mainItemLevel, mainQuality, mainEquipLoc, _

		if link then
			mainItemLevel = _G.GetDetailedItemLevelInfo(link)
			_, _, mainQuality, _, _, _, _, _, mainEquipLoc = _G.GetItemInfo(link)
		elseif texture then
			isInspectSuccessful = false
		end

		-- Off hand
		link = _G.GetInventoryItemLink(unit, 17)
		texture = _G.GetInventoryItemTexture(unit, 17)
		local offItemLevel, offEquipLoc

		if link then
			offItemLevel = _G.GetDetailedItemLevelInfo(link)
			_, _, _, _, _, _, _, _, offEquipLoc = _G.GetItemInfo(link)
		elseif texture then
			isInspectSuccessful = false
		end

		if mainQuality == 6 or (mainEquipLoc == "INVTYPE_2HWEAPON" and not offEquipLoc and _G.GetInspectSpecialization(unit) ~= 72) then
			total = total + mainItemLevel * 2
		else
			total = total + (mainItemLevel or 0) + (offItemLevel or 0)
		end

		-- print("total:", total, "cur:", m_floor(total / 16), isInspectSuccessful and "SUCCESS!" or "FAIL!")
		return isInspectSuccessful and m_floor(total / 16) or nil
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
				dispelTypes.Disease = _G.IsPlayerSpell(4987) or _G.IsPlayerSpell(213644) or nil -- Cleanse or Cleanse Toxins
				dispelTypes.Magic = _G.IsPlayerSpell(4987) or nil -- Cleanse
				dispelTypes.Poison = dispelTypes.Disease
			elseif E.PLAYER_CLASS == "SHAMAN" then
				dispelTypes.Curse = _G.IsPlayerSpell(51886) or _G.IsPlayerSpell(77130) or nil -- Cleanse Spirit or Purify Spirit
				dispelTypes.Magic = _G.IsPlayerSpell(77130) or nil -- Purify Spirit
			elseif E.PLAYER_CLASS == "DRUID" then
				dispelTypes.Curse = _G.IsPlayerSpell(2782) or _G.IsPlayerSpell(88423) or nil -- Remove Corruption or Nature's Cure
				dispelTypes.Magic = _G.IsPlayerSpell(88423) or nil -- Nature's Cure
				dispelTypes.Poison = dispelTypes.Curse
			elseif E.PLAYER_CLASS == "PRIEST"then
				dispelTypes.Disease = _G.IsPlayerSpell(527) or nil -- Purify
				dispelTypes.Magic = _G.IsPlayerSpell(527) or _G.IsPlayerSpell(32375) or nil -- Purify or Mass Dispel
			elseif E.PLAYER_CLASS == "MONK" then
				dispelTypes.Disease = _G.IsPlayerSpell(115450) or nil -- Detox
				dispelTypes.Magic = dispelTypes.Disease
				dispelTypes.Poison = dispelTypes.Disease
			end
		end
	end)

	function E:GetDispelTypes()
		return dispelTypesByClass[E.PLAYER_CLASS]
	end

	function E:IsDispellable(debuffType)
		if not dispelTypesByClass[E.PLAYER_CLASS] then return end

		return dispelTypesByClass[E.PLAYER_CLASS][debuffType]
	end
end

function E:GetPlayerSpecFlag()
	return E.PLAYER_SPEC_FLAGS[_G.GetSpecialization()]
end

function E:GetPlayerRole()
	local _, _, _, _, _, role = _G.GetSpecializationInfo(_G.GetSpecialization())

	return role or "DAMAGER"
end

-------------------------
-- FONT STRINGS & TEXT --
-------------------------

function E:ResetFontStringHeight(object)
	if not object.SetText then return end

	object:SetText("+-1234567890/|\\*")
	object:SetHeight(object:GetStringHeight())
	object:SetText(nil)
end

function E:TruncateString(v, length)
	return s_utf8sub(v, 1, length)
end

----------
-- MISC --
----------

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
