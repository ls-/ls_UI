local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Tooltips")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local type = _G.type
local s_format = _G.string.format

-- Blizz
local C_ArtifactUI_GetPowerInfo = _G.C_ArtifactUI.GetPowerInfo
local C_PetJournal_GetPetTeamAverageLevel = _G.C_PetJournal.GetPetTeamAverageLevel
local C_Timer_After = _G.C_Timer.After
local C_TradeSkillUI_GetRecipeReagentItemLink = _G.C_TradeSkillUI.GetRecipeReagentItemLink
local CanInspect = _G.CanInspect
local GetAuctionItemInfo = _G.GetAuctionItemInfo
local GetBackpackCurrencyInfo = _G.GetBackpackCurrencyInfo
local GetCurrencyListLink = _G.GetCurrencyListLink
local GetGuildInfo = _G.GetGuildInfo
local GetItemCount = _G.GetItemCount
local GetLFGDungeonRewardLink = _G.GetLFGDungeonRewardLink
local GetLFGDungeonShortageRewardLink = _G.GetLFGDungeonShortageRewardLink
local GetLootRollItemLink = _G.GetLootRollItemLink
local GetLootSlotLink = _G.GetLootSlotLink
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMouseFocus = _G.GetMouseFocus
local GetTime = _G.GetTime
local IsShiftKeyDown = _G.IsShiftKeyDown
local ItemRefTooltip = _G.ItemRefTooltip
local NotifyInspect = _G.NotifyInspect
local UnitAura = _G.UnitAura
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitBattlePetType = _G.UnitBattlePetType
local UnitClass = _G.UnitClass
local UnitCreatureType = _G.UnitCreatureType
local UnitEffectiveLevel = _G.UnitEffectiveLevel
local UnitExists = _G.UnitExists
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitGUID = _G.UnitGUID
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsAFK = _G.UnitIsAFK
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsDND = _G.UnitIsDND
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsQuestBoss = _G.UnitIsQuestBoss
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPVPName = _G.UnitPVPName
local UnitRace = _G.UnitRace
local UnitRealmRelationship = _G.UnitRealmRelationship

--[[ luacheck: globals
	CreateFrame GameTooltip GameTooltipStatusBar LSTooltipAnchor UIParent
]]

-- Mine
local inspectGUIDCache = {}
local isInit = false
local lastGUID

local AFK = "[".._G.AFK.."] "
local DND = "[".._G.DND.."] "
local GUILD_TEMPLATE = _G.GUILD_TEMPLATE:format("|cff%s%s", "|r%s")
local ID = "|cffffd100".._G.ID..":|r %d"
local ITEM_LEVEL = "|cffffd100".._G.ITEM_LEVEL_ABBR..":|r |cff%s%s|r"
local SPECIALIZATION = "|cffffd100".._G.SPECIALIZATION..":|r |cff%s%s|r"
local TARGET = "|cffffd100".._G.TARGET..":|r %s"
local TOTAL = "|cffffd100".._G.TOTAL..":|r %d"
local PLAYER_TEMPLATE = "|cff%s%s|r (|cff%s".._G.PLAYER.."|r)"

local TEXTS_TO_REMOVE = {
	[_G.FACTION_ALLIANCE] = true,
	[_G.FACTION_HORDE] = true,
	[_G.PVP] = true,
}

local function AddGenericInfo(tooltip, id)
	if not (id and C.db.profile.tooltips.id) then return end

	local name = tooltip:GetName()
	local textLeft = ID:format(id)

	for i = 2, tooltip:NumLines() do
		local text = _G[name.."TextLeft"..i]:GetText()

		if text and text:match(textLeft) then
			return
		end
	end

	tooltip:AddLine(" ")
	tooltip:AddLine(textLeft, 1, 1, 1)
	tooltip:Show()
end

local function AddSpellInfo(tooltip, id, caster)
	if not (id and C.db.profile.tooltips.id) then return end

	local name = tooltip:GetName()
	local textLeft = ID:format(id)

	for i = 1, tooltip:NumLines() do
		local text = _G[name.."TextLeft"..i]:GetText()

		if text and text:match(textLeft) then
			return
		end
	end

	tooltip:AddLine(" ")

	if caster and type(caster) == "string" then
		local color = E:GetUnitReactionColor(caster)

		if UnitIsPlayer(caster) then
			color = E:GetUnitClassColor(caster)
		end

		tooltip:AddDoubleLine(textLeft, UnitName(caster), 1, 1, 1, color:GetRGB())
	else
		tooltip:AddLine(textLeft, 1, 1, 1)
	end

	tooltip:Show()
end

local function AddItemInfo(tooltip, id, showQuantity)
	if not id then return end

	local name = tooltip:GetName()
	local textLeft, textRight

	if C.db.profile.tooltips.id then
		textLeft = ID:format(id)

		for i = 2, tooltip:NumLines() do
			local text = _G[name.."TextLeft"..i]:GetText()

			if text and text:match(textLeft) then
				return
			end
		end
	end

	if showQuantity and C.db.profile.tooltips.count then
		textRight = TOTAL:format(GetItemCount(id, true))

		for i = 2, tooltip:NumLines() do
			local text = _G[name.."TextRight"..i]:GetText()

			if text and text:match(textRight) then
				return
			end
		end
	end

	if textLeft or textRight then
		tooltip:AddLine(" ")
		tooltip:AddDoubleLine(textLeft or " ", textRight or " ", 1, 1, 1, 1, 1, 1)
		tooltip:Show()
	end
end

local function ValidateLink(link)
	if not link then return end

	link = link:match("|H(.+)|h.+|h") or link

	if link:match("^%w+:(%d+)") then
		return link
	end

	return
end

local function HandleLink(tooltip, link, showExtraInfo)
	link = ValidateLink(link)

	if not link then return end

	local linkType, id = link:match("^(%w+):(%d+)")

	if linkType == "item" then
		AddItemInfo(tooltip, id, showExtraInfo)
	else
		AddGenericInfo(tooltip, id)
	end
end

-- Moves trash lines to the bottom
local function CleanUp(tooltip)
	local num = tooltip:NumLines()

	if not num or num <= 1 then return end

	for i = num, 2, -1 do
		local line = _G["GameTooltipTextLeft"..i]
		local text = line:GetText()

		if TEXTS_TO_REMOVE[text] then
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

		if lineText and lineText:match(text) then
			return line
		end
	end

	return nil
end

local function GetTooltipUnit(tooltip)
	local _, unit = tooltip:GetUnit()

	if not unit then
		local frameID = GetMouseFocus()

		if frameID and frameID.GetAttribute then
			unit = frameID:GetAttribute("unit")
		end
	end

	return unit
end

local function INSPECT_READY(unitGUID)
	if lastGUID ~= unitGUID then return end

	if UnitExists("mouseover") then
		local specName = E:GetUnitSpecializationInfo("mouseover")
		local itemLevel = E:GetUnitAverageItemLevel("mouseover")

		inspectGUIDCache[unitGUID] = {
			time = GetTime(),
			specName = specName,
			itemLevel = itemLevel
		}

		GameTooltip:SetUnit("mouseover")
	end

	lastGUID = nil

	E:UnregisterEvent("INSPECT_READY", INSPECT_READY)
end

local function AddInspectInfo(tooltip, unit, classColorHEX, numTries)
	if not CanInspect(unit) or numTries > 2 then	return end

	local unitGUID = UnitGUID(unit)

	if unitGUID == E.PLAYER_GUID then
		tooltip:AddLine(SPECIALIZATION:format(classColorHEX, E:GetUnitSpecializationInfo(unit)), 1, 1, 1)
		tooltip:AddLine(ITEM_LEVEL:format(M.COLORS.WHITE:GetHEX(), E:GetUnitAverageItemLevel(unit)), 1, 1, 1)
	elseif inspectGUIDCache[unitGUID] then
		local specName = inspectGUIDCache[unitGUID].specName
		local itemLevel = inspectGUIDCache[unitGUID].itemLevel
		itemLevel = itemLevel == 0 and nil or itemLevel

		if not (specName and itemLevel) or GetTime() - inspectGUIDCache[unitGUID].time > 120 then
			inspectGUIDCache[unitGUID] = nil

			return C_Timer_After(0.25, function() AddInspectInfo(tooltip, unit, classColorHEX, numTries + 1) end)
		end

		tooltip:AddLine(SPECIALIZATION:format(classColorHEX, specName), 1, 1, 1)
		tooltip:AddLine(ITEM_LEVEL:format(M.COLORS.WHITE:GetHEX(), itemLevel), 1, 1, 1)
	elseif unitGUID ~= lastGUID then
		lastGUID = unitGUID

		NotifyInspect(unit)

		E:RegisterEvent("INSPECT_READY", INSPECT_READY)

		if numTries == 0 then
			tooltip:AddLine(SPECIALIZATION:format(M.COLORS.RED:GetHEX(), L["RETRIEVING_DATA"]), 1, 1, 1)
			tooltip:AddLine(ITEM_LEVEL:format(M.COLORS.RED:GetHEX(), L["RETRIEVING_DATA"]), 1, 1, 1)
		end
	end
end

local function Tooltip_SetArtifactPowerByID(self, powerID)
	if self:IsForbidden() then return end

	local info = C_ArtifactUI.GetPowerInfo(powerID)

	AddSpellInfo(self, info.spellID)
end

local function Tooltip_SetAuctionItem(self, aucType, index)
	if self:IsForbidden() then return end

	local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, id = GetAuctionItemInfo(aucType, index)

	AddItemInfo(self, id, true)
end

local function Tooltip_SetBackpackToken(self, index)
	if self:IsForbidden() then return end

	local _, _, _, id = GetBackpackCurrencyInfo(index)

	AddGenericInfo(self, id)
end

local function Tooltip_SetCurrencyToken(self, index)
	if self:IsForbidden() then return end

	local link = GetCurrencyListLink(index)

	HandleLink(self, link)
end

local function Tooltip_SetHyperlink(self, link)
	if self:IsForbidden() then return end

	HandleLink(self, link, true)
end

local function Tooltip_SetItem(self)
	if self:IsForbidden() then return end

	local _, link = self:GetItem()

	HandleLink(self, link, true)
end

local function Tooltip_SetLFGDungeonReward(self, dungeonID, rewardID)
	if self:IsForbidden() then return end

	local link = GetLFGDungeonRewardLink(dungeonID, rewardID)

	HandleLink(self, link)
end

local function Tooltip_SetLFGDungeonShortageReward(self, dungeonID, rewardArg, rewardID)
	if self:IsForbidden() then return end

	local link = GetLFGDungeonShortageRewardLink(dungeonID, rewardArg, rewardID)

	HandleLink(self, link)
end

local function Tooltip_SetLoot(self, index)
	if self:IsForbidden() then return end

	local link = GetLootSlotLink(index)

	HandleLink(self, link, true)
end

local function Tooltip_SetLootRollItem(self, rollID)
	if self:IsForbidden() then return end

	local link = GetLootRollItemLink(rollID)

	HandleLink(self, link, true)
end

local function Tooltip_SetMerchantItem(self, index)
	if self:IsForbidden() then return end

	local link = GetMerchantItemLink(index)

	HandleLink(self, link, true)
end

local function Tooltip_SetQuest(self)
	if self:IsForbidden() then return end

	if not (self.questID and GameTooltip:IsOwned(self)) then return end

	AddGenericInfo(GameTooltip, self.questID)
end

local function Tooltip_SetRecipeReagentItem(self, recipeID, reagentIndex)
	if self:IsForbidden() then return end

	local link = C_TradeSkillUI.GetRecipeReagentItemLink(recipeID, reagentIndex)

	HandleLink(self, link, true)
end

local function Tooltip_SetSpell(self)
	if self:IsForbidden() then return end

	local _, _, id = self:GetSpell()

	AddSpellInfo(self, id)
end

local function Tooltip_SetSpellOrItem(self)
	if self:IsForbidden() then return end

	local _, _, id = self:GetSpell()

	if id then
		AddSpellInfo(self, id)
	else
		local _, link = self:GetItem()

		HandleLink(self, link, true)
	end
end

local function Tooltip_SetUnitAura(self, unit, index, filter)
	if self:IsForbidden() then return end

	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

	AddSpellInfo(self, id, caster)
end

local function Tooltip_SetUnit(self)
	if self:IsForbidden() then return end

	local unit = getTooltipUnit(self)
	if not (unit and UnitExists(unit)) then return end

	local config = C.db.profile.tooltips
	local nameColor = E:GetUnitColor(unit, true)
	local scaledLevel = UnitEffectiveLevel(unit)
	local difficultyColor = E:GetCreatureDifficultyColor(scaledLevel)
	local isPVPReady, pvpFaction = E:GetUnitPVPStatus(unit)
	local isShiftKeyDown = config.inspect and IsShiftKeyDown() or false

	if UnitIsPlayer(unit) then
		local name, realm = UnitName(unit)
		name = config.title and UnitPVPName(unit) or name
		local guildName, guildRankName , _, guildRealm = GetGuildInfo(unit)
		local class = UnitClass(unit)
		local afkFlag = ""
		local status = ""
		local offset = 2

		if realm and realm ~= "" then
			if isShiftKeyDown then
				name = s_format("%s|cff%s-%s|r", name, M.COLORS.GRAY:GetHEX(), realm)
			else
				if UnitRealmRelationship(unit) ~= LE_REALM_RELATION_VIRTUAL then
					name = name..L["FOREIGN_SERVER_LABEL"]
				end
			end
		end

		if UnitIsAFK(unit) then
			afkFlag = AFK
		elseif UnitIsDND(unit) then
			afkFlag = DND
		end

		GameTooltipTextLeft1:SetFormattedText("|cff%s%s|r|cff%s%s|r", M.COLORS.GRAY:GetHEX(), afkFlag, nameColor:GetHEX(), name)

		if UnitInParty(unit) or UnitInRaid(unit) then
			local role = UnitGroupRolesAssigned(unit)

			if UnitIsGroupLeader(unit) then
				status = status..M.textures.inlineicons["LEADER"]:format(13, 13)
			end

			if role and role ~= "NONE" then
				status = status..M.textures.inlineicons[role]:format(13, 13)
			end
		end

		if isPVPReady then
			status = status..M.textures.inlineicons[pvpFaction]:format(13, 13)
		end

		if status ~= "" then
			GameTooltipTextRight1:SetText(status)
			GameTooltipTextRight1:Show()
		end

		if guildName then
			offset = 3

			if isShiftKeyDown then
				local hex = M.COLORS.GRAY:GetHEX()

				if guildRealm then
					guildName = s_format("%s|cff%s-%s|r", guildName, hex, guildRealm)
				end

				if guildRankName then
					guildName = GUILD_TEMPLATE:format(hex, guildRankName, guildName)
				end
			end

			GameTooltipTextLeft2:SetText(guildName)
		end

		local levelLine = GetLineByText(self, scaledLevel > 0 and scaledLevel or "%?%?", offset)

		if levelLine then
			local level = UnitLevel(unit)
			local race = UnitRace(unit)
			local classColor = E:GetUnitClassColor(unit)

			level = scaledLevel > 0 and (scaledLevel ~= level and scaledLevel.." ("..level..")" or scaledLevel) or "??"

			levelLine:SetFormattedText("|cff%s%s|r %s |cff%s%s|r", difficultyColor:GetHEX(), level, race, classColor:GetHEX(), class)

			if isShiftKeyDown and type(level) == "number" and level > 10 then
				AddInspectInfo(self, unit, classColor:GetHEX(), 0)
			end
		end
	else
		local name = UnitName(unit) or L["UNKNOWN"]
		local isPet = UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)
		local status = ""
		scaledLevel = isPet and UnitBattlePetLevel(unit) or scaledLevel

		GameTooltipTextLeft1:SetFormattedText("|cff%s%s|r", nameColor:GetHEX(), name)

		if UnitIsQuestBoss(unit) then
			status = status..s_format(M.textures.inlineicons["QUEST"], 13, 13)
		end

		if isPVPReady then
			status = status..s_format(M.textures.inlineicons[pvpFaction], 13, 13)
		end

		if status ~= "" then
			GameTooltipTextRight1:SetText(status)
			GameTooltipTextRight1:Show()
		end

		local line = GetLineByText(self, scaledLevel > 0 and scaledLevel or "%?%?", 2)

		if line then
			local level = UnitLevel(unit)
			local classification = E:GetUnitClassification(unit)
			local creatureType = UnitCreatureType(unit)

			level = scaledLevel > 0 and (scaledLevel ~= level and scaledLevel.." ("..level..")" or scaledLevel) or "??"

			if isPet then
				local teamLevel = C_PetJournal_GetPetTeamAverageLevel()
				local petType = _G["BATTLE_PET_NAME_"..UnitBattlePetType(unit)]

				if teamLevel then
					difficultyColor = E:GetRelativeDifficultyColor(teamLevel, scaledLevel)
				else
					difficultyColor = E:GetCreatureDifficultyColor(scaledLevel)
				end

				creatureType = (creatureType or L["PET"])..(petType and ", "..petType or "")
			end

			line:SetFormattedText("|cff%s%s%s|r %s", difficultyColor:GetHEX(), level, classification, creatureType or "")
		end
	end

	local unitTarget = unit.."target"

	if config.target and UnitExists(unitTarget) then
		local name = UnitName(unitTarget)

		if UnitIsPlayer(unitTarget) then
			name = PLAYER_TEMPLATE:format(E:GetUnitClassColor(unitTarget):GetHEX(), name, E:GetUnitColor(unitTarget, true):GetHEX())
		else
			name = s_format("|cff%s%s|r", E:GetUnitColor(unitTarget):GetHEX(), name)
		end

		self:AddLine(TARGET:format(name), 1, 1, 1)
	end

	if GameTooltipStatusBar:IsShown() then
		self:SetMinimumWidth(128)
		self:AddLine("--")

		CleanUp(self)

		local line = GetLineByText(self, "%-%-", 2)

		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint("TOPLEFT", line, "TOPLEFT", 0, -2)
		GameTooltipStatusBar:SetPoint("RIGHT", self, "RIGHT", -10, 0)
		GameTooltipStatusBar:SetStatusBarColor(E:GetUnitReactionColor(unit):GetRGB())

	else
		CleanUp(self)
	end

	self:Show()
end

local function MODIFIER_STATE_CHANGED(key)
	if UnitExists("mouseover") and (key == "LSHIFT" or key == "RSHIFT") then
		GameTooltip:SetUnit("mouseover")
	end
end

local function setDefaultAnchor(self, parent)
	if self:IsForbidden() then return end
	if self:GetAnchorType() ~= "ANCHOR_NONE" then return end

	if parent then
		if C.db.profile.tooltips.anchor_cursor then
			self:SetOwner(parent, "ANCHOR_CURSOR")
			return
		else
			self:SetOwner(parent, "ANCHOR_NONE")
		end
	end

	local _, anchor = self:GetPoint()
	if not anchor or anchor == UIParent or anchor == LSTooltipAnchor then
		local quadrant = E:GetScreenQuadrant(LSTooltipAnchor)
		local p = "BOTTOMRIGHT"

		if quadrant == "TOPRIGHT" or quadrant == "TOP" then
			p = "TOPRIGHT"
		elseif quadrant == "BOTTOMLEFT" or quadrant == "LEFT" then
			p = "BOTTOMLEFT"
		elseif quadrant == "TOPLEFT"  then
			p = "TOPLEFT"
		end

		self:ClearAllPoints()
		self:SetPoint(p, "LSTooltipAnchor", p, 0, 0)
	end
end

local function tooltip_AddStatusBar(self, _, max, value)
	for _, child in next, {self:GetChildren()} do
		if child ~= GameTooltipStatusBar and child:GetObjectType() == "StatusBar" then
			if not child.handled then
				E:HandleStatusBar(child)
				E:SetStatusBarSkin(child, "HORIZONTAL-GLASS")
				child:SetHeight(10)
			end

			-- theoretically, there should be only 1 bar visible
			if value < max then
				child:SetStatusBarColor(M.COLORS.YELLOW:GetRGB())
			else
				child:SetStatusBarColor(M.COLORS.GREEN:GetRGB())
			end
		end
	end
end

local function tooltipBar_OnShow(self)
	local tooltip = self:GetParent()

	if tooltip:NumLines() == 0 or getLineByText(tooltip, "%-%-", 2) then return end

	tooltip:SetMinimumWidth(128)
	tooltip:AddLine("--")

	cleanUp(tooltip)

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", getLineByText(tooltip, "%-%-", 2), "TOPLEFT", 0, -2)
	self:SetPoint("RIGHT", tooltip, "RIGHT", -10, 0)
	self:SetStatusBarColor(E:GetUnitReactionColor(getTooltipUnit(tooltip)):GetRGB())

	tooltip:Show()
end

local function tooltipBar_OnValueChanged(self, value)
	if not value then return end

	local _, max = self:GetMinMaxValues()

	if max == 1 then
		self.Text:Hide()
	else
		self.Text:Show()
		self.Text:SetFormattedText("%s / %s", E:NumberFormat(value, 1), E:NumberFormat(max, 1))
	end
end

function MODULE.IsInit()
	return isInit
end

function MODULE:Init()
	if not isInit and C.db.char.tooltips.enabled then
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
		hooksecurefunc("QuestMapLogTitleButton_OnEnter", Tooltip_SetQuest)

		-- Units
		GameTooltip:HookScript("OnTooltipSetUnit", Tooltip_SetUnit)

		-- Other
		hooksecurefunc(GameTooltip, "SetHyperlink", Tooltip_SetHyperlink)
		hooksecurefunc(ItemRefTooltip, "SetHyperlink", Tooltip_SetHyperlink)
		hooksecurefunc(GameTooltip, "SetAction", Tooltip_SetSpellOrItem)
		hooksecurefunc(GameTooltip, "SetRecipeResultItem", Tooltip_SetSpellOrItem)
		hooksecurefunc(GameTooltip, "SetLFGDungeonReward", Tooltip_SetLFGDungeonReward)
		hooksecurefunc(GameTooltip, "SetLFGDungeonShortageReward", Tooltip_SetLFGDungeonShortageReward)

		-- Anchor
		local point = C.db.profile.tooltips.point

		local anchor = CreateFrame("Frame", "LSTooltipAnchor", UIParent)
		anchor:SetSize(64, 64)
		anchor:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(anchor)

		hooksecurefunc("GameTooltip_SetDefaultAnchor", setDefaultAnchor)

		-- Status Bars
		E:HandleStatusBar(GameTooltipStatusBar)
		E:SetStatusBarSkin(GameTooltipStatusBar, "HORIZONTAL-GLASS")
		GameTooltipStatusBar:SetHeight(10)
		GameTooltipStatusBar:SetScript("OnShow", tooltipBar_OnShow)
		GameTooltipStatusBar:SetScript("OnValueChanged", tooltipBar_OnValueChanged)

		hooksecurefunc("GameTooltip_AddStatusBar", tooltip_AddStatusBar)

		isInit = true

		self:Update()
	end
end

function MODULE.Update()
	if isInit then
		local config = C.db.profile.tooltips

		if config.inspect then
			E:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
		else
			E:UnregisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)
		end
	end
end
