local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local TT = E:AddModule("Tooltips", true)

-- Lua
local _G = _G
local unpack = unpack
local strformat, strmatch, strgsub, strfind = string.format, string.match, string.gsub, string.find
local tcontains = tContains

-- Blizz
local GameTooltip = GameTooltip
local GameTooltipStatusBar = GameTooltipStatusBar

-- Mine
local INLINE_ICONS = M.textures.inlineicons
local SPECIALIZATION = "|cffffd100"..SPECIALIZATION..":|r |cff%s%s|r"
local ITEM_LEVEL = "|cffffd100"..ITEM_LEVEL_ABBR..":|r %d"
local TARGET = "|cffffd100"..TARGET..":|r |cff%s%s|r"
local ID = "|cffffd100"..ID..":|r %d"
local TOTAL = "|cffffd100"..TOTAL..":|r %d"
local PET_CLASS_PATTERN = strgsub(TOOLTIP_WILDBATTLEPET_LEVEL_CLASS, "%%s", "(.+)")
local LINES_TO_REMOVE = {PVP, FACTION_ALLIANCE, FACTION_HORDE}
local lastGUID
local inspectGUIDCache = {}

local function CleanLines(self)
	local numLines = self:NumLines()
	if numLines ~= 1 then
		for i = numLines, 2, -1 do
			local line = _G["GameTooltipTextLeft"..i]
			local lineText = line:GetText()

			if tcontains(LINES_TO_REMOVE, lineText) then
				line:SetText(nil)
				line:Hide()
			end
		end
	end
end

local function GetAvailableLine(tooltip)
	local numLines = tooltip:NumLines()
	if numLines ~= 1 then
		for i = 2, numLines do
			local line = _G["GameTooltipTextLeft"..i]
			local lineText = line:GetText()

			if not lineText and not line:IsShown() then
				line:SetText(" ")
				line:SetTextColor(1, 1, 1)
				line:Show()

				return line
			end
		end
	end

	tooltip:AddLine(" ", 1, 1, 1)

	return _G["GameTooltipTextLeft"..numLines + 1]
end

-- might need it in the future
-- local function GetAvailableDoubleLine(tooltip)
-- 	local numLines = tooltip:NumLines()
-- 	if numLines ~= 1 then
-- 		for i = 2, numLines do
-- 			local lineLeft, lineRight = _G["GameTooltipTextLeft"..i], _G["GameTooltipTextRight"..i]
-- 			local lineLeftText = lineLeft:GetText()

-- 			if not lineLeftText and not lineLeft:IsShown() then
-- 				lineLeft:SetText(" ")
-- 				lineLeft:SetTextColor(1, 1, 1)
-- 				lineLeft:Show()
-- 				lineRight:SetText(" ")
-- 				lineRight:SetTextColor(1, 1, 1)
-- 				lineRight:Show()

-- 				return lineLeft, lineRight
-- 			end
-- 		end
-- 	end

-- 	tooltip:AddDoubleLine(" ", " ", 1, 1, 1, 1, 1, 1)

-- 	return _G["GameTooltipTextLeft"..numLines + 1], _G["GameTooltipTextRight"..numLines + 1]
-- end

local function GameTooltip_AuraTooltipHook(self, unit, index, filter)
	local _, _, _, _, _, _, _, caster, _, _, id = _G.UnitAura(unit, index, filter)

	if not id then return end

	self:AddLine(" ")

	if caster then
		local name = _G.UnitName(caster)
		local color

		if _G.UnitIsPlayer(caster) then
			color = E:GetUnitClassColor(caster)
		else
			color = E:GetUnitReactionColor(caster)
		end

		self:AddDoubleLine(strformat(ID, id), name, 1, 1 , 1, color.r, color.g, color.b)
	else
		self:AddLine(strformat(ID, id), 1, 1, 1)
	end

	self:Show()
end

local function GameTooltip_ItemTooltipHook(self)
	local _, link = self:GetItem()

	if not link then return end

	local total = _G.GetItemCount(link, true)
	local _, _, id = strfind(link, "item:(%d+)")

	if not id then return end

	for i = 2, self:NumLines() do
		if strfind(_G["GameTooltipTextLeft"..i]:GetText(), strformat(ID, id)) then
			return
		end
	end

	self:AddLine(" ")
	self:AddDoubleLine(strformat(ID, id), strformat(TOTAL, total), 1, 1, 1, 1, 1, 1)
	self:Show()
end

local function GameTooltip_SpellTooltipHook(self)
	local _, _, id = self:GetSpell()

	if not id then return end

	for i = 1, self:NumLines() do
		if strfind(_G["GameTooltipTextLeft"..i]:GetText(), strformat(ID, id)) then
			return
		end
	end

	self:AddLine(" ")
	self:AddLine(strformat(ID, id), 1, 1, 1)
	self:Show()
end

local function GetLevelLine(self, level)
	local numLines = self:NumLines()
	if numLines ~= 1 then
		for i = 2, numLines do
			local line = _G["GameTooltipTextLeft"..i]
			local lineText = line:GetText()
			if lineText and strfind(lineText, level) then
				return line
			end
		end
	end

	return nil
end

local function GetPetClass(lineText)
	local _, petClass = strmatch(lineText, PET_CLASS_PATTERN)

	return petClass
end

local function ShowInspectInfo(unit, classColorHEX, numTries)
	if not _G.CanInspect(unit) or numTries > 1 then	return end

	local unitGUID = _G.UnitGUID(unit)
	if unitGUID == E.PLAYER_GUID then
		local line = GetAvailableLine(GameTooltip)
		line:SetFormattedText(SPECIALIZATION, classColorHEX, E:GetUnitSpecializationInfo(unit))

		line = GetAvailableLine(GameTooltip)
		line:SetFormattedText(ITEM_LEVEL, E:GetUnitAverageItemLevel(unit))
	elseif inspectGUIDCache[unitGUID] then
		local specName = inspectGUIDCache[unitGUID].specName
		local itemLevel = inspectGUIDCache[unitGUID].itemLevel

		if (_G.GetTime() - inspectGUIDCache[unitGUID].time) > 900 or not specName or not itemLevel then
			inspectGUIDCache[unitGUID] = nil

			return ShowInspectInfo(unit, classColorHEX, numTries + 1)
		end

		local line = GetAvailableLine(GameTooltip)
		line:SetFormattedText(SPECIALIZATION, classColorHEX, specName)

		line = GetAvailableLine(GameTooltip)
		line:SetFormattedText(ITEM_LEVEL, itemLevel)
	else
		lastGUID = unitGUID

		_G.NotifyInspect(unit)

		TT:RegisterEvent("INSPECT_READY")
	end
end

local function GameTooltip_UnitTooltipHook(self)
	local _, unit = self:GetUnit()

	if not unit then
		local frameID = _G.GetMouseFocus()
		if frameID and frameID:GetAttribute("unit") then
			unit = frameID:GetAttribute("unit")
		end

		if not unit or not _G.UnitExists(unit) then
			return
		end
	end

	local name, realm = _G.UnitName(unit)
	local level = _G.UnitEffectiveLevel(unit)
	local nameColor = E:GetSmartReactionColor(unit)
	local reactionColor = E:GetUnitReactionColor(unit)
	local difficultyColor = E:GetCreatureDifficultyColor(level)
	local isPVPReady, pvpFaction = E:GetUnitPVPStatus(unit)
	local isShiftKeyDown = _G.IsShiftKeyDown()

	CleanLines(self)

	if _G.UnitIsPlayer(unit) then
		local pvpName = _G.UnitPVPName(unit)
		local guildName, _, _, guildRealm = _G.GetGuildInfo(unit)
		local isInGroup = _G.UnitInParty(unit) or _G.UnitInRaid(unit)

		name = pvpName or name

		if realm and realm ~= "" then
			local relationship = _G.UnitRealmRelationship(unit)

			if isShiftKeyDown then
				name = name.."-"..realm
			else
				if relationship == _G.LE_REALM_RELATION_VIRTUAL then
					name = name.._G.INTERACTIVE_SERVER_LABEL
				else
					name = name.._G.FOREIGN_SERVER_LABEL
				end
			end
		end

		local afkFlag = ""
		if _G.UnitIsAFK(unit) then
			afkFlag = _G.CHAT_FLAG_AFK
		elseif _G.UnitIsDND(unit) then
			afkFlag = _G.CHAT_FLAG_DND
		end

		_G.GameTooltipTextLeft1:SetFormattedText("|cff999999%s|r|cff%s%s|r", afkFlag, nameColor.hex, name)

		local statusInfo = ""
		if isInGroup then
			local role = _G.UnitGroupRolesAssigned(unit)

			if _G.UnitIsGroupLeader(unit) then
				statusInfo = statusInfo..strformat(INLINE_ICONS["LEADER"], 13, 13)
			end

			if role and role ~= "NONE" then
				statusInfo = statusInfo..strformat(INLINE_ICONS[role], 13, 13)
			end
		end

		if isPVPReady then
			statusInfo = statusInfo..strformat(INLINE_ICONS[pvpFaction], 13, 13)
		end

		if statusInfo ~= "" then
			_G.GameTooltipTextRight1:SetText(statusInfo)
			_G.GameTooltipTextRight1:Show()
		end

		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end

			_G.GameTooltipTextLeft2:SetText(guildName)

		end

		local levelLine = GetLevelLine(self, level > 0 and level or "%?%?")
		if levelLine then
			local actualLevel = _G.UnitLevel(unit)
			local race = _G.UnitRace(unit)
			local classColor = E:GetUnitClassColor(unit)
			local classDisplayName = _G.UnitClass(unit)

			levelLine:SetFormattedText("|cff%s%s|r %s |cff%s%s|r", difficultyColor.hex,
				level > 0 and (level ~= actualLevel and level.." ("..actualLevel..")" or level) or "??",
				race, classColor.hex, classDisplayName)

			if level > 10 and isShiftKeyDown then
				ShowInspectInfo(unit, classColor.hex, 0)
			end
		end
	else
		local isPet = _G.UnitIsWildBattlePet(unit) or _G.UnitIsBattlePetCompanion(unit)

		_G.GameTooltipTextLeft1:SetFormattedText("|cff%s%s|r", nameColor.hex, name)

		local statusInfo = ""
		if _G.UnitIsQuestBoss(unit) then
			statusInfo = statusInfo..strformat(INLINE_ICONS["QUEST"], 13, 13)
		end

		if isPVPReady then
			statusInfo = statusInfo..strformat(INLINE_ICONS[pvpFaction], 13, 13)
		end

		if statusInfo ~= "" then
			_G.GameTooltipTextRight1:SetText(statusInfo)
			_G.GameTooltipTextRight1:Show()
		end

		level = isPet and _G.UnitBattlePetLevel(unit) or level

		local levelLine = GetLevelLine(self, level > 0 and level or "%?%?")
		if levelLine then
			local actualLevel = _G.UnitLevel(unit)
			local classification = E:GetUnitClassification(unit)
			local creatureType = _G.UnitCreatureType(unit) or ""
			local petClass = ""

			if isPet then
				local teamLevel = _G.C_PetJournal.GetPetTeamAverageLevel()
				creatureType = creatureType == "" and _G.PET or creatureType

				if teamLevel then
					difficultyColor.hex = E:RGBToHEX(_G.GetRelativeDifficultyColor(teamLevel, level))
				else
					difficultyColor.hex = E:RGBToHEX(_G.GetCreatureDifficultyColor(level))
				end

				petClass = ", "..GetPetClass(levelLine:GetText())
			end

			levelLine:SetFormattedText("|cff%s%s%s|r %s%s", difficultyColor.hex,
				level > 0 and ((level ~= actualLevel and not isPet) and level.." ("..actualLevel..")" or level) or "??",
				classification, creatureType, petClass)
		end
	end

	local unitTarget = unit.."target"
	if _G.UnitExists(unitTarget) then
		nameColor = E:GetSmartReactionColor(unitTarget)

		local line = GetAvailableLine(self)
		line:SetFormattedText(TARGET, nameColor.hex, _G.UnitName(unitTarget))
	end

	if GameTooltipStatusBar:IsShown() then
		GameTooltipStatusBar:SetStatusBarColor(reactionColor.r, reactionColor.g, reactionColor.b)

		self:SetMinimumWidth(140)
	end
end

local function GameTooltipStatusBar_OnValueChangedHook(self, value)
	if not value then return end

	local _, unit = self:GetParent():GetUnit()
	if not unit then
		local frameID = _G.GetMouseFocus()

		if frameID and frameID:GetAttribute("unit") then
			unit = frameID:GetAttribute("unit")
		end
	end

	local _, max = self:GetMinMaxValues()
	if max == 1 then
		self.Text:Hide()
	else
		self.Text:Show()

		if value == 0 or (unit and _G.UnitIsDeadOrGhost(unit)) then
			self.Text:SetText(_G.DEAD)
		else
			self.Text:SetText(E:NumberFormat(value, 1).." / "..E:NumberFormat(max, 1))
		end
	end

	local reactionColor = E:GetUnitReactionColor(unit)
	self:SetStatusBarColor(reactionColor.r, reactionColor.g, reactionColor.b)
end

function TT:MODIFIER_STATE_CHANGED(key)
	if (key == "LSHIFT" or key == "RSHIFT") and _G.UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end

function TT:INSPECT_READY(unitGUID)
	if lastGUID ~= unitGUID then return end

	if _G.UnitExists("mouseover") then
		local specName = E:GetUnitSpecializationInfo("mouseover")
		local itemLevel = E:GetUnitAverageItemLevel("mouseover")

		if itemLevel or specName then
			inspectGUIDCache[unitGUID] = {
				time = _G.GetTime(),
				specName = specName,
				itemLevel = itemLevel,
			}

			GameTooltip:SetUnit("mouseover")
		end
	end

	TT:UnregisterEvent("INSPECT_READY")
end

function TT:Initialize()
	if C.tooltips.enabled then
		_G.hooksecurefunc(GameTooltip, "SetUnitAura", GameTooltip_AuraTooltipHook)
		_G.hooksecurefunc(GameTooltip, "SetUnitBuff", GameTooltip_AuraTooltipHook)
		_G.hooksecurefunc(GameTooltip, "SetUnitDebuff", GameTooltip_AuraTooltipHook)

		GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_ItemTooltipHook)
		GameTooltip:HookScript("OnTooltipSetSpell", GameTooltip_SpellTooltipHook)
		GameTooltip:HookScript("OnTooltipSetUnit", GameTooltip_UnitTooltipHook)

		for i = 1, 6 do
			E:AddTooltipStatusBar(GameTooltip, i)
		end

		E:HandleStatusBar(GameTooltipStatusBar)
		E:CreateBorder(GameTooltipStatusBar)
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 3, -2)
		GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -3, -2)
		GameTooltipStatusBar:HookScript("OnValueChanged", GameTooltipStatusBar_OnValueChangedHook)
		GameTooltipStatusBar.Text:SetFontObject("LS10Font_Shadow")
		GameTooltipStatusBar.Text:SetDrawLayer("OVERLAY") -- FIXME

		TT:RegisterEvent("MODIFIER_STATE_CHANGED")
	end
end
