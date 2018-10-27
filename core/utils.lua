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

local hex
do
	local rgb_hex_cache = {}

	function hex(r, g, b)
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
		return calcGradient(
			perc,
			color[1].r, color[1].g, color[1].b,
			color[2].r, color[2].g, color[2].b,
			color[3].r, color[3].g, color[3].b
		)
	end

	function E:GetGradientAsHex(perc, color)
		return hex(calcGradient(
			perc,
			color[1].r, color[1].g, color[1].b,
			color[2].r, color[2].g, color[2].b,
			color[3].r, color[3].g, color[3].b
		))
	end

	function E:GetRGB(color)
		return color.r, color.g, color.b
	end

	function E:GetRGBA(color, a)
		return color.r, color.g, color.b, a or color.a
	end

	function E:SetRGBA(color, r, g, b, a)
		if r > 1 or g > 1 or b > 1 then
			r, g, b = r / 255, g / 255, b / 255
		end

		color.r = r
		color.g = g
		color.b = b
		color.a = a
		color.hex = hex(r, g, b)

		return color
	end

	function E:SetRGB(color, r, g, b)
		return self:SetRGBA(color, r, g, b, 1)
	end

	function E:WrapText(color, text)
		return "|c" .. color.hex .. text .. "|r"
	end

	do
		local updater = CreateFrame("Frame")
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
	function E:GetUnitSelectionColor(unit)
		-- if UnitExists(unit) then
			if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
				return C.db.profile.colors.tapped
			else
				local r, g, b = UnitSelectionColor(unit)
				r = m_ceil(r * 255) * 65536 + m_ceil(g * 255) * 256 + m_ceil(b * 255)

				r = C.db.profile.colors.selection[r]
				if r then
					return r
				else
					r, g, b = UnitSelectionColor(unit)
					print("|cffff0000WARNING! |cffffd200UNKNOWN COLOUR:|r", r, g, b,
						"|c" .. hex(r / 255, g / 255, b / 255), UnitName(unit), "|r")
				end
			end
		-- end

		return C.db.profile.colors.selection[7]
	end

	function E:GetUnitClassColor(unit)
		if UnitPlayerControlled(unit) then
			local class = select(2, UnitClass(unit))
			if class then
				return C.db.global.colors.class[class]
			end
		end

		return C.db.profile.colors.disconnected
	end

	function E:GetUnitClassification(unit)
		if UnitExists(unit) then
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

		return L["UNKNOWN"]
	end

	-- GetRelativeDifficultyColor function in UIParent.lua
	function E:GetRelativeDifficultyColor(unitLevel, challengeLevel)
		local diff = challengeLevel - unitLevel
		if diff >= 5 then
			return C.db.profile.colors.difficulty.impossible
		elseif diff >= 3 then
			return C.db.profile.colors.difficulty.very_difficult
		elseif diff >= -4 then
			return C.db.profile.colors.difficulty.difficult
		elseif -diff <= GetQuestGreenRange() then
			return C.db.profile.colors.difficulty.standard
		else
			return C.db.profile.colors.difficulty.trivial
		end
	end

	function E:GetCreatureDifficultyColor(level)
		return self:GetRelativeDifficultyColor(UnitEffectiveLevel("player"), level > 0 and level or 199)
	end

	do
		local ARMOR_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
		local X2_WEAPON_SLOTS = {
			INVTYPE_2HWEAPON = true,
			INVTYPE_RANGEDRIGHT = true,
			INVTYPE_RANGED = true,
		}

		function E:GetUnitAverageItemLevel(unit)
			if UnitIsUnit(unit, "player") then
				return m_floor(select(2, GetAverageItemLevel()))
			else
				local isInspectSuccessful = true
				local total = 0

				-- Armour
				for _, id in next, ARMOR_SLOTS do
					local link = GetInventoryItemLink(unit, id)
					local cur

					if link then
						cur = GetDetailedItemLevelInfo(link)
						if cur and cur > 0 then
							total = total + cur
						end
					elseif GetInventoryItemTexture(unit, id) then
						isInspectSuccessful = false
					end
				end

				-- Main hand
				local link = GetInventoryItemLink(unit, 16)
				local mainItemLevel, mainQuality, mainEquipLoc, mainItemClass, mainItemSubClass, _ = 0

				if link then
					mainItemLevel = GetDetailedItemLevelInfo(link)
					_, _, mainQuality, _, _, _, _, _, mainEquipLoc, _, _, mainItemClass, mainItemSubClass = GetItemInfo(link)
				elseif GetInventoryItemTexture(unit, 16) then
					isInspectSuccessful = false
				end

				-- Off hand
				link = GetInventoryItemLink(unit, 17)
				local offItemLevel, offEquipLoc = 0

				if link then
					offItemLevel = GetDetailedItemLevelInfo(link)
					_, _, _, _, _, _, _, _, offEquipLoc = GetItemInfo(link)
				elseif GetInventoryItemTexture(unit, 17) then
					isInspectSuccessful = false
				end

				if mainQuality == 6 or (not offEquipLoc and X2_WEAPON_SLOTS[mainEquipLoc] and mainItemClass ~= 2 and mainItemSubClass ~= 19 and GetInspectSpecialization(unit) ~= 72) then
					mainItemLevel = m_max(mainItemLevel, offItemLevel)
					total = total + mainItemLevel * 2
				else
					total = total + mainItemLevel + offItemLevel
				end

				if total == 0 then
					isInspectSuccessful = false
				end

				-- print("|cffffd200" .. UnitName(unit) .. "|r", "total:", total, "cur:", m_floor(total / 16), isInspectSuccessful and "SUCCESS!" or "FAIL!")
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

function E:ForceHide(object, skipEvents)
	if not object then return end

	if object.UnregisterAllEvents then
		if not skipEvents then
			object:UnregisterAllEvents()
		end

		if object:GetName() then
			object.ignoreFramePositionManager = true
			object:SetAttribute("ignoreFramePositionManager", true)
			UIPARENT_MANAGED_FRAME_POSITIONS[object:GetName()] = nil
		end
	end

	object:Hide()
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
