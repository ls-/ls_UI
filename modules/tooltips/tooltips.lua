local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

E.TT = {}

local TT = E.TT
local COLORS = M.colors
local INLINE_ICONS = M.textures.inlineicons

local LE_REALM_RELATION_VIRTUAL, INTERACTIVE_SERVER_LABEL, FOREIGN_SERVER_LABEL, CHAT_FLAG_AFK, CHAT_FLAG_DND =
	LE_REALM_RELATION_VIRTUAL, INTERACTIVE_SERVER_LABEL, FOREIGN_SERVER_LABEL, CHAT_FLAG_AFK, CHAT_FLAG_DND
local PET = PET

local find, match = strfind, strmatch
local unpack, tcontains = unpack, tContains
local min = min

local GameTooltip, GameTooltipStatusBar, GameTooltipTextLeft1, GameTooltipTextRight1 = GameTooltip, GameTooltipStatusBar, GameTooltipTextLeft1, GameTooltipTextRight1

local GetPetTeamAverageLevel = C_PetJournal.GetPetTeamAverageLevel
local IsShiftKeyDown, GetMouseFocus, GetGuildInfo = IsShiftKeyDown, GetMouseFocus, GetGuildInfo
local UnitInParty, UnitInRaid = UnitInParty, UnitInRaid
local UnitIsAFK, UnitIsDND, UnitIsGroupLeader, UnitIsPlayer, UnitIsWildBattlePet, UnitIsBattlePetCompanion =
	UnitIsAFK, UnitIsDND, UnitIsGroupLeader, UnitIsPlayer, UnitIsWildBattlePet, UnitIsBattlePetCompanion
local UnitBattlePetLevel, UnitClass, UnitCreatureType, UnitEffectiveLevel, UnitExists, UnitGroupRolesAssigned, UnitName, UnitPVPName, UnitRace, UnitRealmRelationship =
	UnitBattlePetLevel, UnitClass, UnitCreatureType, UnitEffectiveLevel, UnitExists, UnitGroupRolesAssigned, UnitName, UnitPVPName, UnitRace, UnitRealmRelationship

local function CleanLines(self, offset, set)
	local numLines = self:NumLines()
	local offset = min(offset, numLines)
	local lastHidden

	for i = numLines, offset, -1 do
		local line = _G["GameTooltipTextLeft"..i]
		local lineText = line:GetText()

		if tcontains(set, lineText) then
			for j = i, numLines do
				_G["GameTooltipTextLeft"..j]:SetText(_G["GameTooltipTextLeft"..j + 1]:GetText())

				if not _G["GameTooltipTextLeft"..j + 1]:IsShown() then
					_G["GameTooltipTextLeft"..j]:Hide()

					lastHidden = j
					break
				end
			end
		end
	end

	return lastHidden or offset
end

local function GetAvailableLine(self, offset)
	local numLines = self:NumLines()
	local offset = min(offset, numLines)
	local availableLine

	for i = offset, numLines do
		local line = _G["GameTooltipTextLeft"..i]
		local lineText = line:GetText()

		if not lineText and not line:IsShown() then
			line:SetText(" ")
			line:Show()

			return line, min(i + 1, numLines)
		end
	end

	if not availableLine then
		self:AddLine(" ")

		return _G["GameTooltipTextLeft"..numLines + 1], numLines + 1
	end
end

local function GameTooltip_AuraTooltipHook(self, unit, index, filter)
	local _, _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

	if not id then return end

	self:AddLine(" ")

	if caster then
		local name = UnitName(caster)
		local color

		if UnitIsPlayer(caster) then
			color = E:GetUnitClassColor(caster)
		else
			color = E:GetUnitReactionColor(caster)
		end

		self:AddDoubleLine("|cffffd100"..ID..":|r "..id, name, 1, 1 , 1, color.r, color.g, color.b)
	else
		self:AddLine("|cffffd100"..ID..":|r "..id, 1, 1, 1)
	end

	self:Show()
end

local function GameTooltip_OnEventHook(self, event, ...)
	local key = ...
	if (key == "LSHIFT" or key == "RSHIFT") and UnitExists("mouseover") then
		self:SetUnit("mouseover")
	end
end

local function GameTooltip_ItemTooltipHook(self)
	local _, link = self:GetItem()

	if not link then return end

	local total = GetItemCount(link, true)
	local _, _, id = find(link, "item:(%d+)")

	if id == "0" then return end

	for i = 1, self:NumLines() do
		if find(_G["GameTooltipTextLeft"..i]:GetText(), "|cffffd100"..ID..":|r "..id) then
			return
		end
	end

	self:AddLine(" ")
	self:AddDoubleLine("|cffffd100"..ID..":|r "..id, "|cffffd100"..TOTAL..":|r "..total, 1, 1, 1, 1, 1, 1)
	self:Show()
end

local function GameTooltip_SpellTooltipHook(self)
	local _, _, id = self:GetSpell()

	if not id then return end

	for i = 1, self:NumLines() do
		if find(_G["GameTooltipTextLeft"..i]:GetText(), "|cffffd100"..ID..":|r "..id) then
			return
		end
	end

	self:AddLine(" ")
	self:AddLine("|cffffd100"..ID..":|r "..id, 1, 1, 1)
	self:Show()
end

local function GetLevelLine(self, level, offset)
	local numLines = self:NumLines()
	local offset = min(offset, numLines)

	for i = offset, numLines do
		local line = _G["GameTooltipTextLeft"..i]
		local lineText = line:GetText()

		if lineText and find(lineText, level) then
			return line, i + 1
		end
	end

	return nil, offset
end

local PET_TOOLTIP_CLASS_PATTERN = gsub(TOOLTIP_WILDBATTLEPET_LEVEL_CLASS, "%%s", "(.+)")
local function GetPetClass(lineText)
	local _, petClass = match(lineText, PET_TOOLTIP_CLASS_PATTERN)

	return petClass
end

local function GameTooltip_UnitTooltipHook(self)
	local _, unit = self:GetUnit()

	if not unit then
		local frameID = GetMouseFocus()
		if frameID and frameID:GetAttribute("unit") then
			unit = frameID:GetAttribute("unit")
		end

		if not unit or not UnitExists(unit) then
			return
		end
	end

	local level = UnitEffectiveLevel(unit)
	local isShiftKeyDown = IsShiftKeyDown()
	local reactionColor = E:GetUnitReactionColor(unit)
	local difficultyColor = E:GetCreatureDifficultyColor(level)
	local nameColor = E:GetSmartReactionColor(unit)
	local isPVPReady, pvpFaction = E:GetUnitPVPStatus(unit)
	local availableLine
	local levelLine
	local offset = 2

	CleanLines(self, offset, {PVP, FACTION_ALLIANCE, FACTION_HORDE})

	if UnitIsPlayer(unit) then
		local name, realm = UnitName(unit)
		local pvpName = UnitPVPName(unit)
		local guildName, _, _, guildRealm = GetGuildInfo(unit)
		local isInGroup = UnitInParty(unit) or UnitInRaid(unit)

		name = pvpName or name

		if realm and realm ~= "" then
			local relationship = UnitRealmRelationship(unit)

			if isShiftKeyDown then
				name = name.."-"..realm
			else
				if relationship == LE_REALM_RELATION_VIRTUAL then
					name = name..INTERACTIVE_SERVER_LABEL
				else
					name = name..FOREIGN_SERVER_LABEL
				end
			end
		end

		local afkFlag = ""
		if UnitIsAFK(unit) then
			afkFlag = CHAT_FLAG_AFK
		elseif UnitIsDND(unit) then
			afkFlag = CHAT_FLAG_DND
		end

		GameTooltipTextLeft1:SetFormattedText("|cff999999%s|r|cff%s%s|r", afkFlag, nameColor.hex, name)

		local statusInfo = ""
		if isInGroup then
			local role = UnitGroupRolesAssigned(unit)

			if UnitIsGroupLeader(unit) then
				statusInfo = statusInfo..INLINE_ICONS["LEADER"]
			end

			if role and role ~= "NONE" then
				statusInfo = statusInfo..INLINE_ICONS[role]
			end
		end

		if isPVPReady then
			statusInfo = statusInfo..INLINE_ICONS[pvpFaction]
		end

		if statusInfo ~= "" then
			GameTooltipTextRight1:SetText(statusInfo)
			GameTooltipTextRight1:Show()
		end

		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end

			GameTooltipTextLeft2:SetText(guildName)

			offset = 3
		end

		levelLine, offset = GetLevelLine(self, level > 0 and level or "%?%?", offset)
		if levelLine then
			local actualLevel = UnitLevel(unit)
			local race = UnitRace(unit)
			local classColor = E:GetUnitClassColor(unit)
			local classDisplayName = UnitClass(unit)

			levelLine:SetFormattedText("|cff%s%s|r %s |cff%s%s|r", difficultyColor.hex,
				level > 0 and (level ~= actualLevel and level.." ("..actualLevel..")" or level) or "??",
				race, classColor.hex, classDisplayName)
		end
	else
		local name = UnitName(unit)
		local isPet = UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)

		GameTooltipTextLeft1:SetFormattedText("|cff%s%s|r", nameColor.hex, name)

		local statusInfo = ""
		if UnitIsQuestBoss(unit) then
			statusInfo = statusInfo..INLINE_ICONS["QUEST"]
		end

		if isPVPReady then
			statusInfo = statusInfo..INLINE_ICONS[pvpFaction]
		end

		if statusInfo ~= "" then
			GameTooltipTextRight1:SetText(statusInfo)
			GameTooltipTextRight1:Show()
		end

		level = isPet and UnitBattlePetLevel(unit) or level

		levelLine, offset = GetLevelLine(self, level > 0 and level or "%?%?", offset)
		if levelLine then
			local actualLevel = UnitLevel(unit)
			local classification = E:GetUnitClassification(unit)
			local creatureType = UnitCreatureType(unit) or ""
			local petClass = ""

			if isPet then
				local teamLevel = GetPetTeamAverageLevel()
				creatureType = creatureType == "" and PET or creatureType

				if teamLevel then
					difficultyColor.hex = E:RGBToHEX(GetRelativeDifficultyColor(teamLevel, level))
				else
					difficultyColor.hex = E:RGBToHEX(GetCreatureDifficultyColor(level))
				end

				petClass = ", "..GetPetClass(levelLine:GetText())
			end

			levelLine:SetFormattedText("|cff%s%s%s|r %s%s", difficultyColor.hex,
				level > 0 and ((level ~= actualLevel and not isPet) and level.." ("..actualLevel..")" or level) or "??",
				classification, creatureType, petClass)
		end
	end

	local unitTarget = unit.."target"
	if UnitExists(unitTarget) then
		nameColor = E:GetSmartReactionColor(unitTarget)

		availableLine, offset = GetAvailableLine(self, offset)
		availableLine:SetFormattedText("|cffffd100%s: |r|cff%s%s|r", TARGET, nameColor.hex, UnitName(unitTarget))
	end

	if GameTooltipStatusBar:IsShown() then
		availableLine, offset = GetAvailableLine(self, offset)

		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint("LEFT", availableLine, "LEFT", 0, -2)
		GameTooltipStatusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0)
		GameTooltipStatusBar:SetStatusBarColor(reactionColor.r, reactionColor.g, reactionColor.b)

		self:SetMinimumWidth(140)
	end
end

local function GameTooltipStatusBar_OnValueChangedHook(self, value)
	if not value then return end

	local _, unit = self:GetParent():GetUnit()
	if not unit then
		local frameID = GetMouseFocus()
		if frameID and frameID:GetAttribute("unit") then
			unit = frameID:GetAttribute("unit")
		end
	end

	local _, max = self:GetMinMaxValues()
	if max == 1 then
		self.Text:Hide()
	else
		self.Text:Show()

		if value == 0 or (unit and UnitIsDeadOrGhost(unit)) then
			self.Text:SetText(DEAD)
		else
			self.Text:SetText(E:NumberFormat(value, 1).." / "..E:NumberFormat(max, 1))
		end
	end

	local reactionColor = E:GetUnitReactionColor(unit)
	self:SetStatusBarColor(reactionColor.r, reactionColor.g, reactionColor.b)
end

local function AddTooltipStatusBar(self, num)
	local bar
	for i = 1, num do
		bar = E:CreateStatusBar(self, "GameTooltipStatusBar"..i, 0, "12")
		bar:SetStatusBarColor(unpack(COLORS.green))
		E:CreateBorder(bar, 8)
		bar:SetBorderColor(unpack(COLORS.gray))
	end

	self.numStatusBars, self.shownStatusBars = num, 0
end

function TT:Initialize()
	hooksecurefunc(GameTooltip, "SetUnitAura", GameTooltip_AuraTooltipHook)
	hooksecurefunc(GameTooltip, "SetUnitBuff", GameTooltip_AuraTooltipHook)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", GameTooltip_AuraTooltipHook)

	GameTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:HookScript("OnEvent", GameTooltip_OnEventHook)
	GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_ItemTooltipHook)
	GameTooltip:HookScript("OnTooltipSetSpell", GameTooltip_SpellTooltipHook)
	GameTooltip:HookScript("OnTooltipSetUnit", GameTooltip_UnitTooltipHook)

	AddTooltipStatusBar(GameTooltip, 6)

	E:HandleStatusBar(GameTooltipStatusBar, nil, "12")
	E:CreateBorder(GameTooltipStatusBar, 8)
	GameTooltipStatusBar:SetBorderColor(unpack(COLORS.gray))
	GameTooltipStatusBar:HookScript("OnValueChanged", GameTooltipStatusBar_OnValueChangedHook)
end
