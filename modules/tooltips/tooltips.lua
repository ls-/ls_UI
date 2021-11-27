local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Tooltips")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local s_format = _G.string.format
local s_upper = _G.string.upper
local type = _G.type

-- Blizz
local C_ArtifactUI = _G.C_ArtifactUI
local C_CurrencyInfo = _G.C_CurrencyInfo
local C_PetJournal = _G.C_PetJournal
local C_Timer = _G.C_Timer
local C_TradeSkillUI = _G.C_TradeSkillUI
local CanInspect = _G.CanInspect
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
local ShowBossFrameWhenUninteractable = _G.ShowBossFrameWhenUninteractable
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
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDND = _G.UnitIsDND
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsQuestBoss = _G.UnitIsQuestBoss
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPhaseReason = _G.UnitPhaseReason
local UnitPVPName = _G.UnitPVPName
local UnitRace = _G.UnitRace
local UnitRealmRelationship = _G.UnitRealmRelationship

--[[ luacheck: globals
	CreateFrame Enum GameTooltip GameTooltipStatusBar GameTooltipTextLeft1
	GameTooltipTextLeft2 GameTooltipTextRight1 LSTooltipAnchor UIParent

	LE_REALM_RELATION_VIRTUAL
]]

-- Mine
local isInit = false

local AFK = "[" .. _G.AFK .. "] "
local DND = "[" .. _G.DND .. "] "
local GUILD_TEMPLATE = _G.GUILD_TEMPLATE:format("|c%s%s", "|r%s")
local ID = "|cffffd100" .. _G.ID .. ":|r %d"
local ITEM_LEVEL = "|cffffd100" .. _G.ITEM_LEVEL_ABBR .. ":|r |cffffffff%s|r"
local SPECIALIZATION = "|cffffd100" .. _G.SPECIALIZATION .. ":|r |cffffffff%s|r"
local TARGET = "|cffffd100" .. _G.TARGET .. ":|r %s"
local TOTAL = "|cffffd100" .. _G.TOTAL .. ":|r %d"
local PLAYER_TEMPLATE = "|c%s%s|r (|c%s" .. _G.PLAYER .. "|r)"

local TEXTS_TO_REMOVE = {
	[_G.FACTION_ALLIANCE] = true,
	[_G.FACTION_HORDE] = true,
	[_G.PVP] = true,
}

local PHASE_ICONS = {
	[Enum.PhaseReason.Phasing] = M.textures.icons_inline.PHASE,
	[Enum.PhaseReason.Sharding] = M.textures.icons_inline.SHARD,
	[Enum.PhaseReason.WarMode] = M.textures.icons_inline.WM,
	[Enum.PhaseReason.ChromieTime] = M.textures.icons_inline.CHROMIE,
}

local function addGenericInfo(tooltip, id)
	if not (id and C.db.profile.tooltips.id) then return end

	local name = tooltip:GetName()
	local textLeft = ID:format(id)

	for i = 2, tooltip:NumLines() do
		local text = _G[name .. "TextLeft" .. i]:GetText()

		if text and text:match(textLeft) then
			return
		end
	end

	tooltip:AddLine(" ")
	tooltip:AddLine(textLeft, 1, 1, 1)
	tooltip:Show()
end

local function addSpellInfo(tooltip, id, caster)
	if not (id and C.db.profile.tooltips.id) then return end

	local name = tooltip:GetName()
	local textLeft = ID:format(id)

	for i = 1, tooltip:NumLines() do
		local text = _G[name .. "TextLeft" .. i]:GetText()

		if text and text:match(textLeft) then
			return
		end
	end

	tooltip:AddLine(" ")

	if caster and type(caster) == "string" then
		tooltip:AddDoubleLine(textLeft, UnitName(caster), 1, 1, 1, E:GetRGB(E:GetUnitColor(caster, true, true)))
	else
		tooltip:AddLine(textLeft, 1, 1, 1)
	end

	tooltip:Show()
end

local function addItemInfo(tooltip, id, showQuantity)
	if not id then return end

	local name = tooltip:GetName()
	local textLeft, textRight

	if C.db.profile.tooltips.id then
		textLeft = ID:format(id)

		for i = 2, tooltip:NumLines() do
			local text = _G[name .. "TextLeft" .. i]:GetText()

			if text and text:match(textLeft) then
				return
			end
		end
	end

	if showQuantity and C.db.profile.tooltips.count then
		textRight = TOTAL:format(GetItemCount(id, true))

		for i = 2, tooltip:NumLines() do
			local text = _G[name .. "TextRight" .. i]:GetText()

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

local function validateLink(link)
	if not link then return end

	link = link:match("|H(.+)|h.+|h") or link

	if link:match("^%w+:(%d+)") then
		return link
	end

	return
end

local function handleLink(tooltip, link, showExtraInfo)
	link = validateLink(link)

	if not link then return end

	local linkType, id = link:match("^(%w+):(%d+)")

	if linkType == "item" then
		addItemInfo(tooltip, id, showExtraInfo)
	else
		addGenericInfo(tooltip, id)
	end
end

-- Moves trash lines to the bottom
local function cleanUp(tooltip)
	local num = tooltip:NumLines()

	if not num or num <= 1 then return end

	for i = num, 2, -1 do
		local line = _G["GameTooltipTextLeft" .. i]
		local text = line:GetText()

		if TEXTS_TO_REMOVE[text] then
			for j = i, num do
				local curLeft, curRight = _G["GameTooltipTextLeft" .. j], _G["GameTooltipTextRight" .. j]
				local nextLeft, nextRight = _G["GameTooltipTextLeft" .. (j + 1)], _G["GameTooltipTextRight" .. (j + 1)]

				if (nextLeft:IsShown() or nextRight:IsShown()) then
					curLeft:SetText(nextLeft:GetText())
					curLeft:SetTextColor(nextLeft:GetTextColor())
					curLeft:SetShown(nextLeft:IsShown())

					curRight:SetText(nextRight:GetText())
					curRight:SetTextColor(nextRight:GetTextColor())
					curRight:SetShown(nextRight:IsShown())
				else
					curLeft:SetText()
					curLeft:Hide()

					curRight:SetText()
					curRight:Hide()
				end
			end
		end
	end
end

local function getLineByText(tooltip, text, offset)
	for i = offset, tooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		local lineText = line:GetText()

		if lineText and lineText:match(text) then
			return line
		end
	end

	return nil
end

local function getTooltipUnit(tooltip)
	local _, unit = tooltip:GetUnit()

	if not unit then
		local frameID = GetMouseFocus()

		if frameID and frameID.GetAttribute then
			unit = frameID:GetAttribute("unit")
		end

		if unit and not (UnitExists(unit) or ShowBossFrameWhenUninteractable(unit)) then
			unit = nil
		end
	end

	return unit
end

local inspectGUIDCache = {}
local lastGUID

local function INSPECT_READY(unitGUID)
	if UnitExists("mouseover") and UnitGUID("mouseover") == unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = {}
		end

		inspectGUIDCache[unitGUID].time = GetTime()
		inspectGUIDCache[unitGUID].specName = E:GetUnitSpecializationInfo("mouseover")
		inspectGUIDCache[unitGUID].itemLevel = E:GetUnitAverageItemLevel("mouseover")

		GameTooltip:SetUnit("mouseover")
	end

	E:UnregisterEvent("INSPECT_READY", INSPECT_READY)
end

local function addInspectInfo(tooltip, unit, numTries)
	if not CanInspect(unit, true) or numTries > 3 then return end

	local unitGUID = UnitGUID(unit)
	if unitGUID == E.PLAYER_GUID then
		tooltip:AddLine(SPECIALIZATION:format(E:GetUnitSpecializationInfo(unit)), 1, 1, 1)
		tooltip:AddLine(ITEM_LEVEL:format(E:GetUnitAverageItemLevel(unit)), 1, 1, 1)
	elseif inspectGUIDCache[unitGUID] and inspectGUIDCache[unitGUID].time then
		if not (inspectGUIDCache[unitGUID].specName and inspectGUIDCache[unitGUID].itemLevel) or GetTime() - inspectGUIDCache[unitGUID].time > 120 then
			inspectGUIDCache[unitGUID].time = nil
			inspectGUIDCache[unitGUID].specName = nil
			inspectGUIDCache[unitGUID].itemLevel = nil

			return C_Timer.After(0.33, function()
				addInspectInfo(tooltip, unit, numTries + 1)
			end)
		end

		tooltip:AddLine(SPECIALIZATION:format(inspectGUIDCache[unitGUID].specName), 1, 1, 1)
		tooltip:AddLine(ITEM_LEVEL:format(inspectGUIDCache[unitGUID].itemLevel), 1, 1, 1)
	else
		if lastGUID ~= unitGUID then
			lastGUID = unitGUID

			NotifyInspect(unit)
			E:RegisterEvent("INSPECT_READY", INSPECT_READY)
		else
			lastGUID = nil

			INSPECT_READY(unitGUID)
		end

	end
end

local function tooltip_SetArtifactPowerByID(self, powerID)
	if self:IsForbidden() then return end

	local info = C_ArtifactUI.GetPowerInfo(powerID)

	addSpellInfo(self, info.spellID)
end

local function tooltip_SetBackpackToken(self, index)
	if self:IsForbidden() then return end

	local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)

	addGenericInfo(self, info.currencyTypesID)
end

local function tooltip_SetCurrencyToken(self, index)
	if self:IsForbidden() then return end

	local link = C_CurrencyInfo.GetCurrencyListLink(index)

	handleLink(self, link)
end

local function tooltip_SetHyperlink(self, link)
	if self:IsForbidden() then return end

	handleLink(self, link, true)
end

local function tooltip_SetItem(self)
	if self:IsForbidden() then return end

	local _, link = self:GetItem()

	handleLink(self, link, true)
end

local function tooltip_SetLFGDungeonReward(self, dungeonID, rewardID)
	if self:IsForbidden() then return end

	local link = GetLFGDungeonRewardLink(dungeonID, rewardID)

	handleLink(self, link)
end

local function tooltip_SetLFGDungeonShortageReward(self, dungeonID, rewardArg, rewardID)
	if self:IsForbidden() then return end

	local link = GetLFGDungeonShortageRewardLink(dungeonID, rewardArg, rewardID)

	handleLink(self, link)
end

local function tooltip_SetLoot(self, index)
	if self:IsForbidden() then return end

	local link = GetLootSlotLink(index)

	handleLink(self, link, true)
end

local function tooltip_SetLootRollItem(self, rollID)
	if self:IsForbidden() then return end

	local link = GetLootRollItemLink(rollID)

	handleLink(self, link, true)
end

local function tooltip_SetMerchantItem(self, index)
	if self:IsForbidden() then return end

	local link = GetMerchantItemLink(index)

	handleLink(self, link, true)
end

local function tooltip_SetQuest(self)
	if self:IsForbidden() then return end

	if not (self.questID and GameTooltip:IsOwned(self)) then return end

	addGenericInfo(GameTooltip, self.questID)
end

local function tooltip_SetRecipeReagentItem(self, recipeID, reagentIndex)
	if self:IsForbidden() then return end

	local link = C_TradeSkillUI.GetRecipeReagentItemLink(recipeID, reagentIndex)

	handleLink(self, link, true)
end

local function tooltip_SetSpell(self)
	if self:IsForbidden() then return end

	local _, id = self:GetSpell()

	addSpellInfo(self, id)
end

local function tooltip_SetSpellOrItem(self)
	if self:IsForbidden() then return end

	local _, linkOrId = self:GetSpell()

	if linkOrId then
		addSpellInfo(self, linkOrId)
	else
		_, linkOrId = self:GetItem()

		handleLink(self, linkOrId, true)
	end
end

local function tooltip_SetUnitAura(self, unit, index, filter)
	if self:IsForbidden() then return end

	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

	addSpellInfo(self, id, caster)
end

local function tooltip_SetUnit(self)
	if self:IsForbidden() then return end

	local unit = getTooltipUnit(self)
	if not unit then return end

	local nameColor = E:GetUnitColor(unit, nil, true)
	local scaledLevel = UnitEffectiveLevel(unit)
	local difficultyColor = E:GetCreatureDifficultyColor(scaledLevel)
	local isPVPReady, pvpFaction = E:GetUnitPVPStatus(unit)
	local isShiftKeyDown = IsShiftKeyDown()
	local lineOffset = 2

	if UnitIsPlayer(unit) then
		local name, realm = UnitName(unit)
		name = C.db.profile.tooltips.title and UnitPVPName(unit) or name

		if realm and realm ~= "" then
			if isShiftKeyDown then
				name = s_format("%s|c%s-%s|r", name, C.db.global.colors.gray.hex, realm)
			elseif UnitRealmRelationship(unit) ~= LE_REALM_RELATION_VIRTUAL then
				name = name .. L["FOREIGN_SERVER_LABEL"]
			end
		end

		GameTooltipTextLeft1:SetFormattedText(
			"|c%s%s|r|c%s%s|r",
			C.db.global.colors.gray.hex,
			UnitIsAFK(unit) and AFK or UnitIsDND(unit) and DND or "",
			nameColor.hex,
			name
		)

		-- status
		local status = ""

		GameTooltipTextRight1:SetText(M.textures.icons_inline["SHEEP"]:format(16, 16))
		local size = GameTooltipTextRight1:GetStringHeight()
		size = 16 * 16 / size

		if UnitInParty(unit) or UnitInRaid(unit) then
			if UnitIsGroupLeader(unit) then
				status = status .. M.textures.icons_inline["LEADER"]:format(size, size)
			end

			local role = UnitGroupRolesAssigned(unit)
			if role and role ~= "NONE" then
				status = status .. M.textures.icons_inline[role]:format(size, size)
			end
		end

		if UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitPhaseReason(unit) then
			status = status .. PHASE_ICONS[UnitPhaseReason(unit)]:format(size, size)
		end

		if isPVPReady then
			status = status .. M.textures.icons_inline[s_upper(pvpFaction)]:format(size, size)
		end

		if status ~= "" then
			GameTooltipTextRight1:SetText(status)
			GameTooltipTextRight1:Show()
		else
			GameTooltipTextRight1:SetText(nil)
		end

		-- guild info
		local guildName, guildRankName , _, guildRealm = GetGuildInfo(unit)
		if guildName then
			lineOffset = 3

			if isShiftKeyDown then
				if guildRealm then
					guildName = s_format("%s|c%s-%s|r", guildName, C.db.global.colors.gray.hex, guildRealm)
				end

				if guildRankName then
					guildName = GUILD_TEMPLATE:format(C.db.global.colors.gray.hex, guildRankName, guildName)
				end
			end

			GameTooltipTextLeft2:SetText(guildName)
		end

		local levelLine = getLineByText(self, scaledLevel > 0 and scaledLevel or "%?%?", lineOffset)
		if levelLine then
			local level = UnitLevel(unit)
			local classColor = E:GetUnitClassColor(unit)

			levelLine:SetFormattedText(
				"|c%s%s|r %s |c%s%s|r",
				difficultyColor.hex,
				scaledLevel > 0 and (scaledLevel ~= level and scaledLevel .. " (" .. level .. ")" or scaledLevel) or "??",
				UnitRace(unit),
				classColor.hex,
				UnitClass(unit)
			)

			if C.db.profile.tooltips.inspect and isShiftKeyDown and level > 10 then
				addInspectInfo(self, unit, 0)
			end
		end
	elseif UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", nameColor.hex, UnitName(unit) or L["UNKNOWN"])

		scaledLevel = UnitBattlePetLevel(unit)

		local levelLine = getLineByText(self, scaledLevel > 0 and scaledLevel or "%?%?", lineOffset)
		if levelLine then
			local petType = _G["BATTLE_PET_NAME_" .. UnitBattlePetType(unit)]

			local teamLevel = C_PetJournal.GetPetTeamAverageLevel()
			if teamLevel then
				difficultyColor = E:GetRelativeDifficultyColor(teamLevel, scaledLevel)
			else
				difficultyColor = E:GetCreatureDifficultyColor(scaledLevel)
			end

			levelLine:SetFormattedText(
				"|c%s%s|r %s",
				difficultyColor.hex,
				scaledLevel > 0 and scaledLevel or "??",
				(UnitCreatureType(unit) or L["PET"]) .. (petType and ", " .. petType or "")
			)
		end
	else
		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", nameColor.hex, UnitName(unit) or L["UNKNOWN"])

		-- status
		local status = ""

		GameTooltipTextRight1:SetText(M.textures.icons_inline["SHEEP"]:format(16, 16))
		local size = GameTooltipTextRight1:GetStringHeight()
		size = 16 * 16 / size

		if UnitIsQuestBoss(unit) then
			status = status .. s_format(M.textures.icons_inline["QUEST"], size, size)
		end

		if isPVPReady then
			status = status .. s_format(M.textures.icons_inline[s_upper(pvpFaction)], size, size)
		end

		if status ~= "" then
			GameTooltipTextRight1:SetText(status)
			GameTooltipTextRight1:Show()
		else
			GameTooltipTextRight1:SetText(nil)
		end

		local levelLine = getLineByText(self, scaledLevel > 0 and scaledLevel or "%?%?", lineOffset)
		if levelLine then
			local level = UnitLevel(unit)

			levelLine:SetFormattedText(
				"|c%s%s%s|r %s",
				difficultyColor.hex,
				scaledLevel > 0 and (scaledLevel ~= level and scaledLevel .. " (" .. level .. ")" or scaledLevel) or "??",
				E:GetUnitClassification(unit),
				UnitCreatureType(unit) or ""
			)
		end
	end

	if C.db.profile.tooltips.target then
		local unitTarget = unit .. "target"
		if UnitExists(unitTarget) then
			local name = UnitName(unitTarget)

			if UnitIsPlayer(unitTarget) then
				name = PLAYER_TEMPLATE:format(
					E:GetUnitClassColor(unitTarget).hex,
					name,
					E:GetUnitReactionColor(unitTarget).hex
				)
			else
				name = s_format("|c%s%s|r", E:GetUnitColor(unitTarget, nil, true).hex, name)
			end

			self:AddLine(TARGET:format(name), 1, 1, 1)
		end
	end

	cleanUp(self)
end

local function MODIFIER_STATE_CHANGED(key)
	if UnitExists("mouseover") and (key == "LSHIFT" or key == "RSHIFT") then
		GameTooltip:SetUnit("mouseover")
	end
end

local function tooltip_SetDefaultAnchor(self, parent)
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
		elseif quadrant == "TOPLEFT" then
			p = "TOPLEFT"
		end

		self:ClearAllPoints()
		self:SetPoint(p, "LSTooltipAnchor", p, 0, 0)
	end
end

local function tooltip_AddStatusBar(self, _, max, value)
	if self:IsForbidden() then return end

	for _, child in next, {self:GetChildren()} do
		if child ~= GameTooltipStatusBar and child:GetObjectType() == "StatusBar" then
			if not child.handled then
				E:HandleStatusBar(child)
				E:SetStatusBarSkin(child, "HORIZONTAL-GLASS")
				child:SetHeight(10)
			end

			-- theoretically, there should be only 1 bar visible
			if value < max then
				child:SetStatusBarColor(E:GetRGB(C.db.global.colors.yellow))
			else
				child:SetStatusBarColor(E:GetRGB(C.db.global.colors.green))
			end
		end
	end
end

local function tooltipBar_Hook(self)
	if self:IsForbidden() or self:GetParent():IsForbidden() then return end

	local _, max = self:GetMinMaxValues()
	if max == 1 then
		self.Text:Hide()
	else
		local value = self:GetValue()

		self.Text:Show()
		self.Text:SetFormattedText("%s / %s", E:FormatNumber(value), E:FormatNumber(max))

		self:GetParent():SetMinimumWidth(self.Text:GetStringWidth() + 32)
	end

	self:SetStatusBarColor(E:GetRGB(C.db.global.colors.health))
end

function MODULE.IsInit()
	return isInit
end

function MODULE:Init()
	if not isInit and PrC.db.profile.tooltips.enabled then
		-- Spells
		GameTooltip:HookScript("OnTooltipSetSpell", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetMountBySpellID", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetPetAction", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetPvpTalent", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetQuestLogRewardSpell", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetQuestRewardSpell", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetShapeshift", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetSpellBookItem", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetSpellByID", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetTalent", tooltip_SetSpell)
		-- hooksecurefunc(GameTooltip, "SetTrainerService", tooltip_SetSpell)

		hooksecurefunc(GameTooltip, "SetUnitAura", tooltip_SetUnitAura)
		hooksecurefunc(GameTooltip, "SetUnitBuff", tooltip_SetUnitAura)
		hooksecurefunc(GameTooltip, "SetUnitDebuff", tooltip_SetUnitAura)
		hooksecurefunc(GameTooltip, "SetArtifactPowerByID", tooltip_SetArtifactPowerByID)

		-- Items
		GameTooltip:HookScript("OnTooltipSetItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetAuctionSellItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetBagItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetBuybackItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetExistingSocketGem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetGuildBankItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetHeirloomByItemID", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetInboxItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetInventoryItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetInventoryItemByID", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetItemByID", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetMerchantCostItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetQuestItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetQuestLogItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetQuestLogSpecialItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetSendMailItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetSocketedItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetSocketGem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetTradePlayerItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetTradeTargetItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetTransmogrifyItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetUpgradeItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetVoidDepositItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetVoidItem", tooltip_SetItem)
		-- hooksecurefunc(GameTooltip, "SetVoidWithdrawalItem", tooltip_SetItem)

		hooksecurefunc(GameTooltip, "SetLootItem", tooltip_SetLoot)
		hooksecurefunc(GameTooltip, "SetLootRollItem", tooltip_SetLootRollItem)
		hooksecurefunc(GameTooltip, "SetMerchantItem", tooltip_SetMerchantItem)
		hooksecurefunc(GameTooltip, "SetRecipeReagentItem", tooltip_SetRecipeReagentItem)
		hooksecurefunc(GameTooltip, "SetToyByItemID", addItemInfo)

		-- Currencies
		hooksecurefunc(GameTooltip, "SetBackpackToken", tooltip_SetBackpackToken)
		hooksecurefunc(GameTooltip, "SetCurrencyToken", tooltip_SetCurrencyToken)
		hooksecurefunc(GameTooltip, "SetCurrencyByID", addGenericInfo)
		hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", addGenericInfo)
		hooksecurefunc(GameTooltip, "SetLootCurrency", tooltip_SetLoot)

		-- Quests
		hooksecurefunc("QuestMapLogTitleButton_OnEnter", tooltip_SetQuest)

		-- Units
		GameTooltip:HookScript("OnTooltipSetUnit", tooltip_SetUnit)

		-- Other
		hooksecurefunc(GameTooltip, "SetHyperlink", tooltip_SetHyperlink)
		hooksecurefunc(ItemRefTooltip, "SetHyperlink", tooltip_SetHyperlink)
		hooksecurefunc(GameTooltip, "SetAction", tooltip_SetSpellOrItem)
		hooksecurefunc(GameTooltip, "SetRecipeResultItem", tooltip_SetSpellOrItem)
		hooksecurefunc(GameTooltip, "SetLFGDungeonReward", tooltip_SetLFGDungeonReward)
		hooksecurefunc(GameTooltip, "SetLFGDungeonShortageReward", tooltip_SetLFGDungeonShortageReward)

		-- Anchor
		local point = C.db.profile.tooltips.point[E.UI_LAYOUT]

		local anchor = CreateFrame("Frame", "LSTooltipAnchor", UIParent)
		anchor:SetSize(64, 64)
		anchor:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(anchor)

		hooksecurefunc("GameTooltip_SetDefaultAnchor", tooltip_SetDefaultAnchor)

		-- Status Bars
		E:HandleStatusBar(GameTooltipStatusBar)
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 8, -2)
		GameTooltipStatusBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -8, -2)
		GameTooltipStatusBar:HookScript("OnShow", tooltipBar_Hook)
		GameTooltipStatusBar:HookScript("OnValueChanged", tooltipBar_Hook)

		hooksecurefunc("GameTooltip_AddStatusBar", tooltip_AddStatusBar)

		E:RegisterEvent("MODIFIER_STATE_CHANGED", MODIFIER_STATE_CHANGED)

		isInit = true

		self:Update()
	end
end

function MODULE:Update()
	if isInit then
		GameTooltipStatusBar:SetHeight(C.db.profile.tooltips.health.height)
		E:SetStatusBarSkin(GameTooltipStatusBar, "HORIZONTAL-" .. C.db.profile.tooltips.health.height)

		GameTooltipStatusBar.Text:UpdateFont(C.db.profile.tooltips.health.text.size)
	end
end
