local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

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
local s_utf8sub = _G.string.utf8sub
local select = _G.select
local t_wipe = _G.table.wipe
local pcall = _G.pcall

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
	local SECOND_NUMBER_CAP = "%s.%d" .. _G.SECOND_NUMBER_CAP_NO_SPACE
	local FIRST_NUMBER_CAP = "%s.%d" .. _G.FIRST_NUMBER_CAP_NO_SPACE

	function E:FormatNumber(v)
		if v >= 1E6 then
			local i, f = m_modf(v / 1E6)
			return s_format(SECOND_NUMBER_CAP, BreakUpLargeNumbers(i), f * 10)
		elseif v >= 1E4 then
			local i, f = m_modf(v / 1E3)
			return s_format(FIRST_NUMBER_CAP, BreakUpLargeNumbers(i), f * 10)
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
	local rgb_hex_cache = {}

	local function hex(r, g, b)
		local key = r .. "-" .. g .. "-" .. b
		if rgb_hex_cache[key] then
			return rgb_hex_cache[key]
		end

		rgb_hex_cache[key] = s_format("ff%.2x%.2x%.2x", clamp(r) * 255, clamp(g) * 255, clamp(b) * 255)

		return rgb_hex_cache[key]
	end

	-- http://wow.gamepedia.com/ColorGradient
	local function calcGradient(perc, ...)
		local num = select("#", ...)

		if perc >= 1 then
			return select(-3, ...)
		elseif perc <= 0 then
			local r, g, b = ...
			return r, g, b
		end

		local i, relperc = m_modf(perc * (num / 3 - 1))
		local r1, g1, b1, r2, g2, b2 = select((i * 3) + 1, ...)

		return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
	end

	function E:GetGradientAsRGB(perc, color)
		if color[3] then
			return calcGradient(
				perc,
				color[1].r, color[1].g, color[1].b,
				color[2].r, color[2].g, color[2].b,
				color[3].r, color[3].g, color[3].b
			)
		else
			return calcGradient(
				perc,
				color[1].r, color[1].g, color[1].b,
				color[2].r, color[2].g, color[2].b
			)
		end
	end

	function E:GetGradientAsHex(perc, color)
		if color[3] then
			return hex(calcGradient(
				perc,
				color[1].r, color[1].g, color[1].b,
				color[2].r, color[2].g, color[2].b,
				color[3].r, color[3].g, color[3].b
			))
		else
			return hex(calcGradient(
				perc,
				color[1].r, color[1].g, color[1].b,
				color[2].r, color[2].g, color[2].b
			))
		end
	end

	function E:WrapTextInColorCode(color, text)
		return "|c" .. color.hex .. text .. "|r"
	end

	local color_proto = {}

	function color_proto:GetHex()
		return self.hex
	end

	-- override ColorMixin:GetRGBA
	function color_proto:GetRGBA(a)
		return self.r, self.g, self.b, a or self.a
	end

	-- override ColorMixin:SetRGBA
	function color_proto:SetRGBA(r, g, b, a)
		if r > 1 or g > 1 or b > 1 then
			r, g, b = r / 255, g / 255, b / 255
		end

		self.r = r
		self.g = g
		self.b = b
		self.a = a
		self.hex = hex(r, g, b)
	end

	-- override ColorMixin:WrapTextInColorCode
	function color_proto:WrapTextInColorCode(text)
		return "|c" .. self.hex .. text .. "|r"
	end

	function E:CreateColor(r, g, b, a)
		local color = Mixin({}, ColorMixin, color_proto)
		color:SetRGBA(r, g, b, a)

		return color
	end

	do
		local updater = CreateFrame("Frame", "LSColorSmoother")
		local objects = {}

		local function isCloseEnough(r, g, b, tR, tG, tB)
			return m_abs(r - tR) <= 0.05 and m_abs(g - tG) <= 0.05 and m_abs(b - tB) <= 0.05
		end

		local function onUpdate(self, elapsed)
			for object, target in next, objects do
				local r, g, b

				if isCloseEnough(object._r, object._g, object._b, target.r, target.g, target.b) then
					r, g, b = target.r, target.g, target.b
					objects[object] = nil

					if not next(object) then
						self:SetScript("OnUpdate", nil)
					end
				else
					-- 15 = 0.25 * 60
					r, g, b = calcGradient(15 * elapsed, object._r, object._g, object._b, target.r, target.g, target.b)
				end

				object:SetVertexColor_(r, g, b, target.a)
				object._r, object._g, object._b = r, g, b
			end
		end

		local function object_SetSmoothedVertexColor(self, r, g, b, a)
			self._r, self._g, self._b = self:GetVertexColor()

			if isCloseEnough(self._r, self._g, self._b, r, g, b) then
				self:SetVertexColor_(r, g, b, a)
			else
				objects[self] = {r = r, g = g, b = b, a = a}

				if not updater:GetScript("OnUpdate") then
					updater:SetScript("OnUpdate", onUpdate)
				end
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
	function E:GetUnitColor(unit, colorByClass, colorByReaction)
		if not UnitIsConnected(unit) then
			return C.db.global.colors.disconnected
		elseif not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
			return C.db.global.colors.tapped
		elseif colorByClass and UnitIsPlayer(unit) then
			return self:GetUnitClassColor(unit)
		elseif colorByReaction then
			return self:GetUnitReactionColor(unit)
		end

		return C.db.global.colors.reaction[4]
	end

	local selectionTypes = {
		[ 0] = 0,
		[ 1] = 1,
		[ 2] = 2,
		[ 3] = 3,
		[ 4] = 4,
		[ 5] = 5,
		[ 6] = 6,
		[ 7] = 7,
		[ 8] = 8,
		[ 9] = 9,
		-- [10] = 10, -- unavailable to players
		-- [11] = 11, -- unavailable to players
		[12] = 5,
		[13] = 13,
	}

	local function unitSelectionType(unit)
		if UnitThreatSituation("player", unit) then
			return 0
		else
			return selectionTypes[UnitSelectionType(unit, true)]
		end
	end

	-- loosely based on CompactUnitFrame_UpdateHealthColor
	function E:GetUnitColor_(unit, colorByClass, colorBySelection)
		if not UnitIsConnected(unit) or UnitIsDead(unit) then
			return C.db.global.colors.disconnected
		elseif not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
			return C.db.global.colors.tapped
		elseif colorByClass and UnitIsPlayer(unit) then
			return self:GetUnitClassColor(unit)
		elseif colorBySelection then
			return C.db.global.colors.selection[unitSelectionType(unit)] or C.db.global.colors.selection[2]
		else
			return C.db.global.colors.reaction[4]
		end
	end

	function E:GetUnitClassColor(unit)
		return C.db.global.colors.class[select(2, UnitClass(unit))] or C.db.global.colors.white
	end

	function E:GetUnitReactionColor(unit)
		if UnitThreatSituation("player", unit) then
			return C.db.global.colors.reaction[2]
		end

		return C.db.global.colors.reaction[UnitReaction(unit, "player")] or C.db.global.colors.reaction[4]
	end

	function E:GetUnitClassification(unit)
		local classification = UnitClassification(unit)
		if classification == "rare" then
			return "R"
		elseif classification == "rareelite" then
			return "R+"
		elseif classification == "elite" then
			return "+"
		elseif classification == "worldboss" then
			return "B"
		elseif classification == "minus" then
			return "-"
		end

		return ""
	end

	function E:GetUnitPVPStatus(unit)
		local faction = "Neutral"

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

				return true, faction
			end
		end

		return false, faction
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

		return _G.UNKNOWN
	end

	local function getDifficultyColor(difficulty)
		if difficulty == Enum.RelativeContentDifficulty.Trivial then
			return C.db.global.colors.difficulty.trivial
		elseif difficulty == Enum.RelativeContentDifficulty.Easy then
			return C.db.global.colors.difficulty.standard
		elseif difficulty == Enum.RelativeContentDifficulty.Fair then
			return C.db.global.colors.difficulty.difficult
		elseif difficulty == Enum.RelativeContentDifficulty.Difficult then
			return C.db.global.colors.difficulty.very_difficult
		elseif difficulty == Enum.RelativeContentDifficulty.Impossible then
			return C.db.global.colors.difficulty.impossible
		else
			return C.db.global.colors.difficulty.difficult
		end
	end

	function E:GetCreatureDifficultyColor(unit)
		return getDifficultyColor(C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit))
	end

	-- GetRelativeDifficultyColor function in UIParent.lua
	function E:GetRelativeDifficultyColor(unitLevel, challengeLevel)
		local diff = challengeLevel - unitLevel
		if diff >= 5 then
			return C.db.global.colors.difficulty.impossible
		elseif diff >= 3 then
			return C.db.global.colors.difficulty.very_difficult
		elseif diff >= -4 then
			return C.db.global.colors.difficulty.difficult
		elseif -diff <= UnitQuestTrivialLevelRange("player") then
			return C.db.global.colors.difficulty.standard
		else
			return C.db.global.colors.difficulty.trivial
		end
	end

	function E:GetUnitAverageItemLevel(unit)
		if UnitIsUnit(unit, "player") then
			return m_floor(select(2, GetAverageItemLevel()))
		else
			return C_PaperDollInfo.GetInspectItemLevel(unit)
		end
	end

	do
		local rosterInfo = {}

		local function updateUnitInfo(unit)
			if UnitExists(unit) then
				rosterInfo[UnitGUID(unit)] = UnitGroupRolesAssigned(unit)
			end
		end

		E:RegisterEvent("UNIT_NAME_UPDATE", updateUnitInfo)

		E:RegisterEvent("GROUP_ROSTER_UPDATE", function()
			t_wipe(rosterInfo)

			local prefix, num
			if IsInRaid() then
				prefix, num = "raid", GetNumGroupMembers()
			elseif IsInGroup() then
				prefix, num = "party", GetNumSubgroupMembers()
			end

			if prefix then
				for i = 1, num do
					updateUnitInfo(prefix .. i)
				end
			end
		end)

		E:RegisterEvent("GROUP_LEFT", function()
			t_wipe(rosterInfo)
		end)

		function E:GetRosterInfo()
			return rosterInfo
		end

		function E:IsUnitTank(unit)
			return rosterInfo[UnitGUID(unit)] == "TANK"
		end

		function E:IsUnitHealer(unit)
			return rosterInfo[UnitGUID(unit)] == "HEALER"
		end

		function E:IsUnitDamager(unit)
			return rosterInfo[UnitGUID(unit)] == "DAMAGER"
		end
	end

	function E:IsUnitBoss(unit)
		return unit and (UnitIsUnit(unit, "boss1") or UnitIsUnit(unit, "boss2") or UnitIsUnit(unit, "boss3") or UnitIsUnit(unit, "boss4") or UnitIsUnit(unit, "boss5"))
	end
end

---------------------
-- PLAYER SPECIFIC --
---------------------

do
	local dispelTypes = {}

	E:RegisterEvent("SPELLS_CHANGED", function()
		-- Enrage
		dispelTypes[""] = IsPlayerSpell(374346) -- Overawe (Evoker)
			or IsPlayerSpell(2908) -- Soothe (Druid)
			or IsPlayerSpell(19801) -- Tranquilizing Shot (Hunter)

		dispelTypes["Curse"] = IsPlayerSpell(374251) -- Cauterizing Flame (Evoker)
			or IsPlayerSpell(51886) -- Cleanse Spirit (Shaman)
			or IsPlayerSpell(392378) -- Improved Nature's Cure (Druid)
			or IsPlayerSpell(383016) -- Improved Purify Spirit (Shaman)
			or IsPlayerSpell(2782) -- Remove Corruption (Druid)
			or IsPlayerSpell(475) -- Remove Curse (Mage)

		dispelTypes["Disease"] = IsPlayerSpell(374251) -- Cauterizing Flame (Evoker)
			or IsPlayerSpell(213644) -- Cleanse Toxins (Paladin)
			or IsPlayerSpell(218164) -- Detox (Monk)
			or IsPlayerSpell(393024) -- Improved Cleanse (Paladin)
			or IsPlayerSpell(388874) -- Improved Detox (Monk)
			or IsPlayerSpell(390632) -- Improved Purify (Priest)
			or IsPlayerSpell(213634) -- Purify Disease (Priest)

		dispelTypes["Magic"] = IsPlayerSpell(4987) -- Cleanse (Paladin)
			or IsPlayerSpell(115450) -- Detox (Monk)
			or IsPlayerSpell(32375) -- Mass Dispel (Priest)
			or IsPlayerSpell(360823) -- Naturalize (Evoker)
			or IsPlayerSpell(88423) -- Nature's Cure (Druid)
			or IsPlayerSpell(527) -- Purify (Priest)
			or IsPlayerSpell(77130) -- Purify Spirit (Shaman)

		dispelTypes["Poison"] = IsPlayerSpell(374251) -- Cauterizing Flame (Evoker)
			or IsPlayerSpell(213644) -- Cleanse Toxins (Paladin)
			or IsPlayerSpell(218164) -- Detox (Monk)
			or IsPlayerSpell(393024) -- Improved Cleanse (Paladin)
			or IsPlayerSpell(388874) -- Improved Detox (Monk)
			or IsPlayerSpell(392378) -- Improved Nature's Cure (Druid)
			or IsPlayerSpell(360823) -- Naturalize (Evoker)
			or IsPlayerSpell(383013) -- Poison Cleansing Totem (Shaman)
			or IsPlayerSpell(2782) -- Remove Corruption (Druid)
	end)

	function E:IsDispellable(debuffType)
		return dispelTypes[debuffType]
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

			if not anchor then
				anchor = frame
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

function E:ForceHide(object, skipEvents)
	if not object then return end

	-- EditMode bs
	if object.HideBase then
		object:HideBase(true)
	else
		object:Hide(true)
	end

	if object.EnableMouse then
		object:EnableMouse(false)
	end

	if object.UnregisterAllEvents then
		if not skipEvents then
			object:UnregisterAllEvents()
		end

		object:SetAttribute("statehidden", true)
	end

	if object.SetUserPlaced then
		pcall(object.SetUserPlaced, object, true)
		pcall(object.SetDontSavePosition, object, true)
	end

	object:SetParent(self.HIDDEN_PARENT)
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

function E:GetTooltipPoint(frame)
	local quadrant = self:GetScreenQuadrant(frame)
	local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", 2, -2

	if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
		p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", 2, 2
	elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
		p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", -2, -2
	elseif quadrant == "BOTTOMRIGHT" then
		p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", -2, 2
	end

	return p, rP, x, y
end

-----------
-- ITEMS --
-----------

do
	local ENCHANT_LINE = Enum.TooltipDataLineType.ItemEnchantmentPermanent
	local ENCHANT_PATTERN = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.+)")
	local QUALITY_PATTERN = "|A.+|a"
	local GEM_LINE = Enum.TooltipDataLineType.GemSocket
	local GEM_TEMPLATE = "|T%s:0:0:0:0:64:64:4:60:4:60|t "
	local SOCKET_TEMPLATE = "|TInterface\\ItemSocketingFrame\\UI-EmptySocket-%s:0:0:0:0:64:64:4:60:4:60|t "

	local dataCache = {}
	local itemCache = {}

	function E:GetItemEnchantGemInfo(itemLink)
		if itemCache[itemLink] then
			return itemCache[itemLink].enchant, itemCache[itemLink].gem1, itemCache[itemLink].gem2, itemCache[itemLink].gem3
		end

		local data = C_TooltipInfo.GetHyperlink(itemLink, nil, nil, true)
		if not data then return "", "", "", "" end

		local enchant = ""
		local gems, idx = {"", "", ""}, 1
		for _, line in next, data.lines do
			if line.type == ENCHANT_LINE then
				enchant = line.leftText:match(ENCHANT_PATTERN)
				if enchant then
					enchant = enchant:gsub(QUALITY_PATTERN, "")
					if enchant then
						enchant = enchant:trim()
					end
				end
			elseif line.type == GEM_LINE then
				gems[idx] = line.gemIcon and GEM_TEMPLATE:format(line.gemIcon) or SOCKET_TEMPLATE:format(line.socketType)
				idx = idx + 1
			end
		end

		dataCache[data.dataInstanceID] = itemLink

		itemCache[itemLink] = {
			enchant = enchant,
			gem1 = gems[1],
			gem2 = gems[2],
			gem3 = gems[3],
		}

		return enchant, gems[1], gems[2], gems[3]
	end

	local wipeTimer

	local function wiper()
		t_wipe(dataCache)
	end

	E:RegisterEvent("TOOLTIP_DATA_UPDATE", function(dataInstanceID)
		local itemLink = dataCache[dataInstanceID]
		if itemLink then
			itemCache[itemLink] = nil
			dataCache[dataInstanceID] = nil

			if not wipeTimer then
				wipeTimer = C_Timer.NewTimer(5, wiper)
			else
				wipeTimer:Cancel()

				wipeTimer = C_Timer.NewTimer(5, wiper)
			end
		end
	end)
end

------------------
-- FONT STRINGS --
------------------

do
	local LSM = LibStub("LibSharedMedia-3.0")

	local function update(obj, f, s)
		s = s or select(2, obj:GetFont())
		if s <= 0 then
			s = 12 -- cooldowns' default font size is -1450 for some reason
		end

		obj:SetFont(LSM:Fetch("font", C.db.global.fonts[f].font), round(s), C.db.global.fonts[f].outline and "OUTLINE" or "")

		if C.db.global.fonts[f].shadow then
			obj:SetShadowOffset(1, -1)
		else
			obj:SetShadowOffset(0, 0)
		end
	end

	local objects = {}

	local proto = {}

	function proto:UpdateFont(s)
		local t = objects[self]
		if not t then return end

		update(self, t, s)
	end

	local module = {
		cooldown = {},
		unit = {},
		button = {},
		statusbar = {},
	}

	function module:Capture(obj, t)
		if obj:GetObjectType() ~= "FontString" then
			return
		elseif not self[t] then
			return
		elseif objects[obj] or self[t][obj] then
			return
		end

		Mixin(obj, proto)

		self[t][obj] = true
		objects[obj] = t
	end

	function module:Release(obj)
		for k in next, proto do
			obj[k] = nil
		end

		self[objects[obj]] = true
		objects[obj] = nil
	end

	function module:UpdateAll(t)
		if not self[t] then return end

		for obj in next, self[t] do
			update(obj, t)
		end
	end

	E.FontStrings = module
end

----------
-- MAPS --
----------

-- credit: elcius@WoWInterface
do
	local mapRects = {}
	local tempVec2D = CreateVector2D(0, 0)

	function E:GetPlayerMapPosition()
		tempVec2D.x, tempVec2D.y = UnitPosition("player")
		if not tempVec2D.x then return end

		local mapID = C_Map.GetBestMapForUnit("player")
		if not mapID then return end

		local mapRect = mapRects[mapID]
		if not mapRect then
			local _, pos1 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
			local _, pos2 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
			if not (pos1 and pos2) then return end

			mapRect = {pos1, pos2}
			mapRect[2]:Subtract(mapRect[1])

			mapRects[mapID] = mapRect
		end

		tempVec2D:Subtract(mapRect[1])

		return tempVec2D.y / mapRect[2].y * 100, tempVec2D.x / mapRect[2].x * 100
	end
end
