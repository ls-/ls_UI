local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

E.TT = {}

local TT = E.TT
local COLORS = M.colors

local find, match, unpack = strfind, strmatch, unpack

local GameTooltip, GameTooltipStatusBar = GameTooltip, GameTooltipStatusBar

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
	for i = offset, self:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]

		if find(line:GetText(), level) then
			return line, i
		end
	end
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

	if UnitIsPlayer(unit) then
		local name, realm = UnitName(unit)
		local relationship = UnitRealmRelationship(unit)
		local pvpName = UnitPVPName(unit)
		local guildName, _, _, guildRealm = GetGuildInfo(unit)
		local classDisplayName = UnitClass(unit)
		local classColor = E:GetUnitClassColor(unit)

		name = pvpName or name

		if realm and realm ~= "" then
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

		if UnitIsAFK(unit) then
			name = CHAT_FLAG_AFK..name
		elseif UnitIsDND(unit) then
			name = CHAT_FLAG_DND..name
		end

		GameTooltipTextLeft1:SetFormattedText("|cff%s%s|r", nameColor.hex, name)

		local Offset = 2
		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName.."-"..guildRealm
			end

			GameTooltipTextLeft2:SetText(guildName)

			Offset = 3
		end

		local levelLine, levelLineIndex = GetLevelLine(self, level > 0 and level or "%?%?", Offset)

		if levelLine then
			local race = UnitRace(unit)

			levelLine:SetFormattedText("|cff%s%s|r %s |cff%s%s|r", difficultyColor.hex, level > 0 and level or "??", race, classColor.hex, classDisplayName)
		end
	else
		local name = UnitName(unit)
		local isPet = UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)

		GameTooltipTextLeft1:SetFormattedText("|cff%s%s|r", nameColor.hex, name)

		level = isPet and UnitBattlePetLevel(unit) or level

		local levelLine, levelLineIndex = GetLevelLine(self, level > 0 and level or "%?%?", 2)
		if levelLine then
			local creatureType = UnitCreatureType(unit) or ""
			local classification = E:GetUnitClassification(unit)
			local petClass = ""

			if isPet then
				local teamLevel = C_PetJournal.GetPetTeamAverageLevel()
				level = UnitBattlePetLevel(unit)
				if teamLevel then
					difficultyColor.hex = E:RGBToHEX(GetRelativeDifficultyColor(teamLevel, level))
				else
					difficultyColor.hex = E:RGBToHEX(GetCreatureDifficultyColor(level))
				end

				petClass = ", "..GetPetClass(levelLine:GetText())
			end

			levelLine:SetFormattedText("|cff%s%s%s|r %s%s", difficultyColor.hex, level > 0 and level or "??", classification, creatureType, petClass)
		end

	end

	local unitTarget = unit.."target"
	if UnitExists(unitTarget) then
		nameColor = E:GetSmartReactionColor(unitTarget)

		GameTooltip:AddLine("|cffffd100"..TARGET..": |r"..UnitName(unitTarget), nameColor.r, nameColor.g, nameColor.b)
	end

	if GameTooltipStatusBar:IsShown() then
		self:AddLine(" ")
		self:SetMinimumWidth(140)
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint("LEFT", self:GetName().."TextLeft"..self:NumLines(), "LEFT", 0, -2)
		GameTooltipStatusBar:SetPoint("RIGHT", self, "RIGHT", -9, 0)
		GameTooltipStatusBar:SetStatusBarColor(reactionColor.r, reactionColor.g, reactionColor.b)
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
