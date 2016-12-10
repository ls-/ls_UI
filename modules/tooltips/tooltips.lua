local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local TOOLTIPS = P:AddModule("Tooltips")

-- Lua
local _G = _G
local string = _G.string
local hooksecurefunc = _G.hooksecurefunc
local type = _G.type

-- Blizz
local GameTooltip = _G.GameTooltip
local GameTooltipStatusBar = _G.GameTooltipStatusBar

-- Mine
local AFK = "[".._G.AFK.."] "
local DND = "[".._G.DND.."] "
local GUILD_TEMPLATE = string.format(_G.GUILD_TEMPLATE, "|cff%s%s", "|r%s")
local ID = "|cffffd100".._G.ID..":|r %d"
local ITEM_LEVEL = "|cffffd100".._G.ITEM_LEVEL_ABBR..":|r |cff%s%s|r"
local SPECIALIZATION = "|cffffd100".._G.SPECIALIZATION..":|r |cff%s%s|r"
local TARGET = "|cffffd100".._G.TARGET..":|r %s"
local TOTAL = "|cffffd100".._G.TOTAL..":|r %d"
local PLAYER_TEMPLATE = "|cff%s%s|r (|cff%s".._G.PLAYER.."|r)"
local inspectGUIDCache = {}
local isInit = false
local lastGUID

-----------
-- UTILS --
-----------

local function AddGenericInfo(tooltip, id)
	if not (id and C.tooltips.show_id) then return end

	local name = tooltip:GetName()
	local textLeft = string.format(ID, id)

	for i = 2, tooltip:NumLines() do
		local text = _G[name.."TextLeft"..i]:GetText()

		if text and string.match(text, textLeft) then
			return
		end
	end

	tooltip:AddLine(" ")
	tooltip:AddLine(textLeft, 1, 1, 1)
	tooltip:Show()
end

local function AddSpellInfo(tooltip, id, caster)
	if not (id and C.tooltips.show_id) then return end

	local name = tooltip:GetName()
	local textLeft = string.format(ID, id)

	for i = 1, tooltip:NumLines() do
		local text = _G[name.."TextLeft"..i]:GetText()

		if text and string.match(text, textLeft) then
			return
		end
	end

	tooltip:AddLine(" ")

	if caster and type(caster) == "string" then
		local color = E:GetUnitReactionColor(caster)

		if _G.UnitIsPlayer(caster) then
			color = E:GetUnitClassColor(caster)
		end

		tooltip:AddDoubleLine(textLeft, _G.UnitName(caster), 1, 1, 1, color:GetRGB())
	else
		tooltip:AddLine(textLeft, 1, 1, 1)
	end

	tooltip:Show()
end

local function AddItemInfo(tooltip, id, showQuantity)
	if not (id and C.tooltips.show_id) then return end

	local name = tooltip:GetName()
	local textLeft = string.format(ID, id)

	for i = 2, tooltip:NumLines() do
		local text = _G[name.."TextLeft"..i]:GetText()

		if text and string.match(text, textLeft) then
			return
		end
	end

	tooltip:AddLine(" ")

	if showQuantity then
		tooltip:AddDoubleLine(textLeft, string.format(TOTAL, _G.GetItemCount(id, true)), 1, 1, 1, 1, 1, 1)
	else
		tooltip:AddLine(textLeft, 1, 1, 1)
	end

	tooltip:Show()
end

local function ValidateLink(link)
	if not link then return end

	link = string.match(link, "|H(.+)|h.+|h") or link

	if string.match(link, "^%w+:(%d+)") then
		return link
	end

	return
end

local function HandleLink(tooltip, link, showExtraInfo)
	link = ValidateLink(link)

	if not link then return end

	local linkType, id = string.match(link, "^(%w+):(%d+)")

	if linkType == "item" then
		AddItemInfo(tooltip, id, showExtraInfo)
	else
		AddGenericInfo(tooltip, id)
	end
end

-- XXX: Moves trash lines to the bottom
local function CleanUp(tooltip)
	local num = tooltip:NumLines()

	if not num or num <= 1 then return end

	for i = num, 2, -1 do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line:GetText()

		if text == _G.PVP or text == _G.FACTION_ALLIANCE or text == _G.FACTION_HORDE then
			for j = i, num do
				local curLine = _G["GameTooltipTextLeft"..j]
				local nextLine = _G["GameTooltipTextLeft"..(j + 1)]

				if nextLine:IsShown() then
					curLine:SetText(nextLine:GetText())
					curLine:SetTextColor(nextLine:GetTextColor())
				else
					curLine:Hide()
				end
			end
		end
	end
end

local function GetLineByText(tooltip, text, offset)
	for i = offset, tooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		local lineText = line:GetText()

		if lineText and string.match(lineText, text) then
			return line
		end
	end

	return nil
end

local function GetTooltipUnit(tooltip)
	local _, unit = tooltip:GetUnit()

	if not unit then
		local frameID = _G.GetMouseFocus()

		if frameID and frameID.GetAttribute then
			unit = frameID:GetAttribute("unit")
		end
	end

	return unit
end

-- XXX: iLvl is disabled till 7.1
local function INSPECT_READY(unitGUID)
	if lastGUID ~= unitGUID then return end

	if _G.UnitExists("mouseover") then
		local specName = E:GetUnitSpecializationInfo("mouseover")
		local itemLevel = E:GetUnitAverageItemLevel("mouseover")

		inspectGUIDCache[unitGUID] = {
			time = _G.GetTime(),
			specName = specName,
			itemLevel = itemLevel
		}

		GameTooltip:SetUnit("mouseover")
	end

	lastGUID = nil

	E:UnregisterEvent("INSPECT_READY", INSPECT_READY)
end

local function AddInspectInfo(tooltip, unit, classColorHEX, numTries)
	if not _G.CanInspect(unit) or numTries > 2 then	return end

	local unitGUID = _G.UnitGUID(unit)

	if unitGUID == E.PLAYER_GUID then
		tooltip:AddLine(string.format(SPECIALIZATION, classColorHEX, E:GetUnitSpecializationInfo(unit)), 1, 1, 1)
		tooltip:AddLine(string.format(ITEM_LEVEL, M.COLORS.WHITE:GetHEX(), E:GetUnitAverageItemLevel(unit)), 1, 1, 1)
	elseif inspectGUIDCache[unitGUID] then
		local specName = inspectGUIDCache[unitGUID].specName
		local itemLevel = inspectGUIDCache[unitGUID].itemLevel

		if not (specName and itemLevel) or _G.GetTime() - inspectGUIDCache[unitGUID].time > 120 then
			inspectGUIDCache[unitGUID] = nil

			return _G.C_Timer.After(0.25, function() AddInspectInfo(tooltip, unit, classColorHEX, numTries + 1) end)
		end

		tooltip:AddLine(string.format(SPECIALIZATION, classColorHEX, specName), 1, 1, 1)
		tooltip:AddLine(string.format(ITEM_LEVEL, M.COLORS.WHITE:GetHEX(), itemLevel), 1, 1, 1)
	elseif unitGUID ~= lastGUID then
		lastGUID = unitGUID

		_G.NotifyInspect(unit)

		E:RegisterEvent("INSPECT_READY", INSPECT_READY)

		if numTries == 0 then
			tooltip:AddLine(string.format(SPECIALIZATION, M.COLORS.RED:GetHEX(), _G.RETRIEVING_DATA), 1, 1, 1)
			tooltip:AddLine(string.format(ITEM_LEVEL, M.COLORS.RED:GetHEX(), _G.RETRIEVING_DATA), 1, 1, 1)
		end
	end
end

--------------
-- HANDLERS --
--------------

local function Tooltip_SetArtifactPowerByID(self, powerID)
	local id = _G.C_ArtifactUI.GetPowerInfo(powerID)

	AddSpellInfo(self, id)
end

local function Tooltip_SetAuctionItem(self, aucType, index)
	local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, id = _G.GetAuctionItemInfo(aucType, index)

	AddItemInfo(self, id, true)
end

local function Tooltip_SetBackpackToken(self, index)
	local _, _, _, id = _G.GetBackpackCurrencyInfo(index)

	AddGenericInfo(self, id)
end

local function Tooltip_SetCurrencyToken(self, index)
	local link = _G.GetCurrencyListLink(index)

	HandleLink(self, link)
end

local function Tooltip_SetHyperlink(self, link)
	HandleLink(self, link, true)
end

local function Tooltip_SetItem(self)
	local _, link = self:GetItem()

	HandleLink(self, link, true)
end

local function Tooltip_SetLFGDungeonReward(self, dungeonID, rewardID)
	local link = _G.GetLFGDungeonRewardLink(dungeonID, rewardID)

	HandleLink(self, link)
end

local function Tooltip_SetLFGDungeonShortageReward(self, dungeonID, rewardArg, rewardID)
	local link = _G.GetLFGDungeonShortageRewardLink(dungeonID, rewardArg, rewardID)

	HandleLink(self, link)
end

local function Tooltip_SetLoot(self, index)
	local link = _G.GetLootSlotLink(index)

	HandleLink(self, link, true)
end

local function Tooltip_SetLootRollItem(self, rollID)
	local link = _G.GetLootRollItemLink(rollID)

	HandleLink(self, link, true)
end

local function Tooltip_SetMerchantItem(self, index)
	local link = _G.GetMerchantItemLink(index)

	HandleLink(self, link, true)
end

local function Tooltip_SetQuest(self)
	if not (self.questID and GameTooltip:IsOwned(self)) then return end

	AddGenericInfo(GameTooltip, self.questID)
end

local function Tooltip_SetRecipeReagentItem(self, recipeID, reagentIndex)
	local link = _G.C_TradeSkillUI.GetRecipeReagentItemLink(recipeID, reagentIndex)

	HandleLink(self, link, true)
end

local function Tooltip_SetSpell(self)
	local _, _, id = self:GetSpell()

	AddSpellInfo(self, id)
end

local function Tooltip_SetSpellOrItem(self)
	local _, _, id = self:GetSpell()

	if id then
		AddSpellInfo(self, id)
	else
		local _, link = self:GetItem()

		HandleLink(self, link, true)
	end
end

local function Tooltip_SetUnitAura(self, unit, index, filter)
	local _, _, _, _, _, _, _, caster, _, _, id = _G.UnitAura(unit, index, filter)

	AddSpellInfo(self, id, caster)
end

local function Tooltip_SetUnit(self)
	local unit = GetTooltipUnit(self)

	if not (unit and _G.UnitExists(unit)) then return end

	local name = _G.UnitPVPName(unit) or _G.UNKNOWN
	local effectiveLevel = _G.UnitEffectiveLevel(unit)
	local nameColor = E:GetUnitColor(
		unit,
		C.tooltips.unit.name_color_pvp_hostility,
		C.tooltips.unit.name_color_class,
		C.tooltips.unit.name_color_tapping,
		C.tooltips.unit.name_color_reaction)
	local difficultyColor = E:GetCreatureDifficultyColor(effectiveLevel)
	local isPVPReady, pvpFaction = E:GetUnitPVPStatus(unit)
	local isShiftKeyDown = _G.IsShiftKeyDown()

	if _G.UnitIsPlayer(unit) then
		local _, realm = _G.UnitName(unit)
		local guildName, guildRankName , _, guildRealm = _G.GetGuildInfo(unit)
		local afkFlag = ""
		local status = ""
		local offset = 2

		if realm and realm ~= "" then
			if isShiftKeyDown then
				name = string.format("%s|cff%s-%s|r", name, M.COLORS.GRAY:GetHEX(), realm)
			else
				if _G.UnitRealmRelationship(unit) ~= _G.LE_REALM_RELATION_VIRTUAL then
					name = name.._G.FOREIGN_SERVER_LABEL
				end
			end
		end

		if _G.UnitIsAFK(unit) then
			afkFlag = AFK
		elseif _G.UnitIsDND(unit) then
			afkFlag = DND
		end

		_G.GameTooltipTextLeft1:SetFormattedText("|cff%s%s|r|cff%s%s|r", M.COLORS.GRAY:GetHEX(), afkFlag, nameColor:GetHEX(), name)

		if _G.UnitInParty(unit) or _G.UnitInRaid(unit) then
			local role = _G.UnitGroupRolesAssigned(unit)

			if _G.UnitIsGroupLeader(unit) then
				status = status..string.format(M.textures.inlineicons["LEADER"], 13, 13)
			end

			if role and role ~= "NONE" then
				status = status..string.format(M.textures.inlineicons[role], 13, 13)
			end
		end

		if isPVPReady then
			status = status..string.format(M.textures.inlineicons[pvpFaction], 13, 13)
		end

		if status ~= "" then
			_G.GameTooltipTextRight1:SetText(status)
			_G.GameTooltipTextRight1:Show()
		end

		if guildName then
			offset = 3

			if isShiftKeyDown then
				if guildRealm then
					guildName = string.format("%s|cff%s-%s|r", guildName, M.COLORS.GRAY:GetHEX(), guildRealm)
				end

				if guildRankName then
					guildName = string.format(GUILD_TEMPLATE, M.COLORS.GRAY:GetHEX(), guildRankName, guildName)
				end

			end

			_G.GameTooltipTextLeft2:SetText(guildName)
		end

		local levelLine = GetLineByText(self, effectiveLevel > 0 and effectiveLevel or "%?%?", offset)

		if levelLine then
			local level = _G.UnitLevel(unit)
			local race = _G.UnitRace(unit)
			local class = _G.UnitClass(unit)
			local classColor = E:GetUnitClassColor(unit)

			level = effectiveLevel > 0 and (effectiveLevel ~= level and effectiveLevel.." ("..level..")" or effectiveLevel) or "??"

			levelLine:SetFormattedText("|cff%s%s|r %s |cff%s%s|r", difficultyColor:GetHEX(), level, race, classColor:GetHEX(), class)

			if isShiftKeyDown and type(level) == "number" and level > 10  then
				AddInspectInfo(self, unit, classColor:GetHEX(), 0)
			end
		end
	else
		local isPet = _G.UnitIsWildBattlePet(unit) or _G.UnitIsBattlePetCompanion(unit)
		local status = ""
		effectiveLevel = isPet and _G.UnitBattlePetLevel(unit) or effectiveLevel

		_G.GameTooltipTextLeft1:SetFormattedText("|cff%s%s|r", nameColor:GetHEX(), name)

		if _G.UnitIsQuestBoss(unit) then
			status = status..string.format(M.textures.inlineicons["QUEST"], 13, 13)
		end

		if isPVPReady then
			status = status..string.format(M.textures.inlineicons[pvpFaction], 13, 13)
		end

		if status ~= "" then
			_G.GameTooltipTextRight1:SetText(status)
			_G.GameTooltipTextRight1:Show()
		end

		local line = GetLineByText(self, effectiveLevel > 0 and effectiveLevel or "%?%?", 2)

		if line then
			local level = _G.UnitLevel(unit)
			local classification = E:GetUnitClassification(unit)
			local creatureType = _G.UnitCreatureType(unit)

			level = effectiveLevel > 0 and (effectiveLevel ~= level and effectiveLevel.." ("..level..")" or effectiveLevel) or "??"

			if isPet then
				local teamLevel = _G.C_PetJournal.GetPetTeamAverageLevel()
				local petType = _G["BATTLE_PET_NAME_".._G.UnitBattlePetType(unit)]

				if teamLevel then
					difficultyColor = E:GetRelativeDifficultyColor(teamLevel, effectiveLevel)
				else
					difficultyColor = E:GetCreatureDifficultyColor(effectiveLevel)
				end

				creatureType = (creatureType or _G.PET)..(petType and ", "..petType or "")
			end

			line:SetFormattedText("|cff%s%s%s|r %s", difficultyColor:GetHEX(), level, classification, creatureType or "")
		end
	end

	local unitTarget = unit.."target"

	if _G.UnitExists(unitTarget) then
		name = _G.UnitName(unitTarget)

		if _G.UnitIsPlayer(unitTarget) then
 			name = string.format(PLAYER_TEMPLATE, E:GetUnitClassColor(unitTarget):GetHEX(), name, E:GetUnitColor(unitTarget, true):GetHEX())
		else
			name = string.format("|cff%s%s|r", E:GetUnitColor(unitTarget, false, false, true, true):GetHEX(), name)
		end

		self:AddLine(string.format(TARGET, name), 1, 1, 1)
	end

	if GameTooltipStatusBar:IsShown() then
		self:SetMinimumWidth(128)
		self:AddLine("--")

		CleanUp(self)

		local line = GetLineByText(self, "%-%-", 2)

		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint("TOPLEFT", line, "TOPLEFT", 0, -2)
		GameTooltipStatusBar:SetPoint("RIGHT", self, "RIGHT", -10, 0)
		GameTooltipStatusBar:SetStatusBarColor(E:GetUnitReactionColor(GetTooltipUnit(self)):GetRGB())

	else
		CleanUp(self)
	end

	self:Show()
end

-----------------
-- INITIALISER --
-----------------

function TOOLTIPS:IsInit()
	return isInit
end

function TOOLTIPS:Init()
	if C.tooltips.enabled then
		-- XXX: It's done the way it's done for a reason

		-- Spells
		GameTooltip:HookScript("OnTooltipSetSpell", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetMountBySpellID", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetPetAction", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetPvpTalent", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetQuestLogRewardSpell", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetQuestRewardSpell", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetShapeshift", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetSpellBookItem", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetSpellByID", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetTalent", Tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetTrainerService", Tooltip_SetSpell)

		hooksecurefunc(GameTooltip, "SetUnitAura", Tooltip_SetUnitAura)
		hooksecurefunc(GameTooltip, "SetUnitBuff", Tooltip_SetUnitAura)
		hooksecurefunc(GameTooltip, "SetUnitDebuff", Tooltip_SetUnitAura)

		hooksecurefunc(GameTooltip, "SetArtifactPowerByID", Tooltip_SetArtifactPowerByID)

		-- Items
		GameTooltip:HookScript("OnTooltipSetItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetAuctionSellItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetBagItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetBuybackItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetExistingSocketGem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetGuildBankItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetHeirloomByItemID", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetInboxItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetInventoryItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetInventoryItemByID", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetItemByID", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetMerchantCostItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetQuestItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetQuestLogItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetQuestLogSpecialItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetSendMailItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetSocketedItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetSocketGem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetTradePlayerItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetTradeTargetItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetTransmogrifyItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetUpgradeItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetVoidDepositItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetVoidItem", Tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetVoidWithdrawalItem", Tooltip_SetItem)

		hooksecurefunc(GameTooltip, "SetAuctionItem", Tooltip_SetAuctionItem)
		hooksecurefunc(GameTooltip, "SetLootItem", Tooltip_SetLoot)
		hooksecurefunc(GameTooltip, "SetLootRollItem", Tooltip_SetLootRollItem)
		hooksecurefunc(GameTooltip, "SetMerchantItem", Tooltip_SetMerchantItem)
		hooksecurefunc(GameTooltip, "SetRecipeReagentItem", Tooltip_SetRecipeReagentItem)
		hooksecurefunc(GameTooltip, "SetToyByItemID", AddItemInfo)

		-- Currencies
		hooksecurefunc(GameTooltip, "SetBackpackToken", Tooltip_SetBackpackToken)
		hooksecurefunc(GameTooltip, "SetCurrencyToken", Tooltip_SetCurrencyToken)

		hooksecurefunc(GameTooltip, "SetCurrencyByID", AddGenericInfo)
		hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", AddGenericInfo)

		hooksecurefunc(GameTooltip, "SetLootCurrency", Tooltip_SetLoot)

		-- Quests
		local hookedQuestTitleButtons = {}

		hooksecurefunc("QuestLogQuests_GetTitleButton", function(index)
			local button = _G.QuestMapFrame.QuestsFrame.Contents.Titles[index]

			if not hookedQuestTitleButtons[button] then
				button:HookScript("OnEnter", Tooltip_SetQuest)

				hookedQuestTitleButtons[button] = true
			end
		end)

		hooksecurefunc("QuestMapLogTitleButton_OnEnter", Tooltip_SetQuest)

		-- Units
		GameTooltip:HookScript("OnTooltipSetUnit", Tooltip_SetUnit)

		-- Other
		hooksecurefunc(GameTooltip, "SetHyperlink", Tooltip_SetHyperlink)
		hooksecurefunc(_G.ItemRefTooltip, "SetHyperlink", Tooltip_SetHyperlink)

		hooksecurefunc(GameTooltip, "SetAction", Tooltip_SetSpellOrItem)
		hooksecurefunc(GameTooltip, "SetRecipeResultItem", Tooltip_SetSpellOrItem)

		hooksecurefunc(GameTooltip, "SetLFGDungeonReward", Tooltip_SetLFGDungeonReward)
		hooksecurefunc(GameTooltip, "SetLFGDungeonShortageReward", Tooltip_SetLFGDungeonShortageReward)

		-- Status bars
		for i = 1, 6 do
			E:AddTooltipStatusBar(GameTooltip, i)
		end

		local function GameTooltipStatusBar_OnValueChanged(bar, value)
			if not value then return end

			local _, max = bar:GetMinMaxValues()

			if max == 1 then
				bar.Text:Hide()
			else
				bar.Text:Show()
				bar.Text:SetText(E:NumberFormat(value, 1).." / "..E:NumberFormat(max, 1))
			end
		end

		local function GameTooltipStatusBar_OnShow(bar)
			local tooltip = bar:GetParent()

			if tooltip:NumLines() == 0 or GetLineByText(tooltip, "%-%-", 2) then return end

			tooltip:SetMinimumWidth(128)
			tooltip:AddLine("--")

			CleanUp(tooltip)

			local line = GetLineByText(tooltip, "%-%-", 2)

			bar:ClearAllPoints()
			bar:SetPoint("TOPLEFT", line, "TOPLEFT", 0, -2)
			bar:SetPoint("RIGHT", tooltip, "RIGHT", -10, 0)
			bar:SetStatusBarColor(E:GetUnitReactionColor(GetTooltipUnit(tooltip)):GetRGB())
		end

		E:HandleStatusBar(GameTooltipStatusBar)
		GameTooltipStatusBar:SetHeight(10)
		GameTooltipStatusBar:SetScript("OnShow", GameTooltipStatusBar_OnShow)
		GameTooltipStatusBar:SetScript("OnValueChanged", GameTooltipStatusBar_OnValueChanged)

		-- Misc
		local function MODIFIER_STATE_CHANGED(key)
			if _G.UnitExists("mouseover") and (key == "LSHIFT" or key == "RSHIFT") then
				GameTooltip:SetUnit("mouseover")
			end
		end

		E:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)

		-- Finalise
		isInit = true

		return true
	end
end
