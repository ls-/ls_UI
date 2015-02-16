local _, ns = ...
local E = ns.E

E.MM = {}

local MM = E.MM

MM.Buttons = {}

local MICRO_BUTTON_LAYOUT = {
	["CharacterMicroButton"] = {
		point = {"LEFT", "lsMBHolderLeft", "LEFT", 3, 0},
		parent = "lsMBHolderLeft",
		icon = "character",
	},
	["SpellbookMicroButton"] = {
		point = {"LEFT", "lsCharacterMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderLeft",
		icon = "spellbook",
	},
	["TalentMicroButton"] = {
		point = {"LEFT", "lsSpellbookMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderLeft",
		icon = "talents",
	},
	["AchievementMicroButton"] = {
		point = {"LEFT", "lsTalentMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderLeft",
		icon = "achievement",
	},
	["QuestLogMicroButton"] = {
		point = {"LEFT", "lsAchievementMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderLeft",
		icon = "quest",
	},
	["GuildMicroButton"] = {
		point = {"LEFT", "lsMBHolderRight", "LEFT", 3, 0},
		parent = "lsMBHolderRight",
		icon = "guild",
	},
	["LFDMicroButton"] = {
		point = {"LEFT", "lsGuildMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderRight",
		icon = "lfg",
	},
	["CollectionsMicroButton"] = {
		point = {"LEFT", "lsLFDMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderRight",
		icon = "pet",
	},
	["EJMicroButton"] = {
		point = {"LEFT", "lsCollectionsMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderRight",
		icon = "ej",
	},
	["StoreMicroButton"] = {
		point = {"LEFT", "lsEJMicroButton", "RIGHT", 6, 0},
		parent = "lsMBHolderRight",
		icon = "store",
	},
}

local function UpdateMicroButtonState()
	local playerLevel = UnitLevel("player")
	local factionGroup = UnitFactionGroup("player")

	if factionGroup == "Neutral" then
		lsGuildMicroButton.factionGroup = factionGroup
		lsLFDMicroButton.factionGroup = factionGroup
	else
		lsGuildMicroButton.factionGroup = nil
		lsLFDMicroButton.factionGroup = nil
	end

	if CharacterFrame and CharacterFrame:IsShown() then
		lsCharacterMicroButton:SetButtonState("PUSHED", true)
	else
		lsCharacterMicroButton:SetButtonState("NORMAL")
	end

	if SpellBookFrame and SpellBookFrame:IsShown() then
		lsSpellbookMicroButton:SetButtonState("PUSHED", true)
	else
		lsSpellbookMicroButton:SetButtonState("NORMAL")
	end

	if PlayerTalentFrame and PlayerTalentFrame:IsShown() then
		lsTalentMicroButton:SetButtonState("PUSHED", true)
	else
		if playerLevel < 10 then
			lsTalentMicroButton:Disable()
		else
			lsTalentMicroButton:Enable()
			lsTalentMicroButton:SetButtonState("NORMAL")
		end
	end

	if AchievementFrame and AchievementFrame:IsShown() then
		lsAchievementMicroButton:SetButtonState("PUSHED", true)
	else
		if (HasCompletedAnyAchievement() or IsInGuild()) and CanShowAchievementUI() then
			lsAchievementMicroButton:Enable()
			lsAchievementMicroButton:SetButtonState("NORMAL")
		else
			lsAchievementMicroButton:Disable()
		end
	end

	if WorldMapFrame and WorldMapFrame:IsShown() then
		lsQuestLogMicroButton:SetButtonState("PUSHED", true)
	else
		lsQuestLogMicroButton:SetButtonState("NORMAL")
	end

	if IsTrialAccount() or (IsVeteranTrialAccount() and not IsInGuild()) or factionGroup == "Neutral" then
		lsGuildMicroButton:Disable()
	elseif (GuildFrame and GuildFrame:IsShown()) or (LookingForGuildFrame and LookingForGuildFrame:IsShown()) then
		lsGuildMicroButton:Enable()
		lsGuildMicroButton:SetButtonState("PUSHED", true)
	else
		lsGuildMicroButton:Enable()
		lsGuildMicroButton:SetButtonState("NORMAL")
		if IsInGuild() then
			lsGuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
		else
			lsGuildMicroButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
		end
	end

	if PVEFrame and PVEFrame:IsShown() then
		lsLFDMicroButton:SetButtonState("PUSHED", true)
	else
		if playerLevel < lsLFDMicroButton.minLevel or factionGroup == "Neutral" then
			lsLFDMicroButton:Disable()
		else
			lsLFDMicroButton:Enable()
			lsLFDMicroButton:SetButtonState("NORMAL")
		end
	end

	if CollectionsJournal and CollectionsJournal:IsShown() then
		lsCollectionsMicroButton:SetButtonState("PUSHED", true)
	else
		lsCollectionsMicroButton:SetButtonState("NORMAL")
	end

	if EncounterJournal and EncounterJournal:IsShown() then
		lsEJMicroButton:SetButtonState("PUSHED", true)
	else
		lsEJMicroButton:SetButtonState("NORMAL")
	end

	if GameLimitedMode_IsActive() then
		lsStoreMicroButton.disabledTooltip = GameLimitedMode_GetString("ERR_FEATURE_RESTRICTED")
		lsStoreMicroButton:Disable()
	elseif C_StorePublic.IsDisabledByParentalControls() then
		lsStoreMicroButton.disabledTooltip = BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS
		lsStoreMicroButton:Disable()
	else
		lsStoreMicroButton.disabledTooltip = nil
		lsStoreMicroButton:Enable()
	end

	if StoreFrame and StoreFrame_IsShown() then
		lsStoreMicroButton:SetButtonState("PUSHED", true)
	else
		lsStoreMicroButton:SetButtonState("NORMAL")
	end
end

local function MicroButton_OnEvent(self, event)
	local name = self:GetName()

	if event == "UPDATE_BINDINGS" or event == "CUSTOM_FORCE_UPDATE" then
		if name == "lsCharacterMicroButton" then
			self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
		elseif name == "lsSpellbookMicroButton" then
			self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
		elseif name == "lsTalentMicroButton" then
			self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
		elseif name == "lsAchievementMicroButton" then
			self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
		elseif name == "lsQuestLogMicroButton" then
			self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
		elseif name == "lsGuildMicroButton" then
			if IsInGuild() then
				self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
			else
				self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
			end
		elseif name == "lsLFDMicroButton" then
			self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLEGROUPFINDER")
		elseif name == "lsCollectionsMicroButton" then
			self.tooltipText = MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS")
		elseif name == "lsEJMicroButton" then
			self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
		elseif name == "lsStoreMicroButton" then
			self.tooltipText = BLIZZARD_STORE
		end
	end

	UpdateMicroButtonState()
end

local function InitializeMicroButton(self, events, level, isBlizzConDriven, isTrialDriven)
	if events then
		for i = 1, #events do
			self:RegisterEvent(events[i])
		end
	end

	if level then self.minLevel = level end

	if isTrialDriven then
		if IsTrialAccount() then
			self:Disable()
			self:SetAlpha(0.5)
			self.disabledTooltip = ERR_RESTRICTED_ACCOUNT
		end
	end
end

function MM:Initialize()
	local MM_CONFIG = ns.C.micromenu

	local holder1 = CreateFrame("Frame", "lsMBHolderLeft", UIParent)
	holder1:SetFrameStrata("LOW")
	holder1:SetFrameLevel(1)
	holder1:SetSize(18 * 5 + 6 * 5, 24 + 6)
	holder1:SetPoint(unpack(MM_CONFIG.holder1.point))

	local holder2 = CreateFrame("Frame", "lsMBHolderRight", UIParent)
	holder2:SetFrameStrata("LOW")
	holder2:SetFrameLevel(1)
	holder2:SetSize(18 * 5 + 6 * 5, 24 + 6)
	holder2:SetPoint(unpack(MM_CONFIG.holder2.point))

	for mb, data in next, MICRO_BUTTON_LAYOUT do
		local button = CreateFrame("Button", "ls"..mb, _G[data.parent], "lsMicroButtonTemplate")
		button:SetFrameStrata("LOW")
		button:SetFrameLevel(2)

		button.icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\"..data.icon)

		button.MicroButton_OnEvent = MicroButton_OnEvent

		MM.Buttons[mb] = button
	end

	lsCharacterMicroButton:SetScript("OnClick", function(...) ToggleCharacter("PaperDollFrame") end)

	lsSpellbookMicroButton:SetScript("OnClick", function(...) ToggleFrame(SpellBookFrame) end)

	InitializeMicroButton(lsTalentMicroButton, {"PLAYER_LEVEL_UP", "PLAYER_TALENT_UPDATE"}, 10, true)
	lsTalentMicroButton:SetScript("OnClick", function(...) ToggleTalentFrame() end)
	TalentMicroButtonAlert:SetPoint("BOTTOM", lsTalentMicroButton, "TOP", 0, 12)

	InitializeMicroButton(lsAchievementMicroButton, {"RECEIVED_ACHIEVEMENT_LIST", "ACHIEVEMENT_EARNED"}, 10)
	lsAchievementMicroButton:SetScript("OnClick", function(...) ToggleAchievementFrame() end)

	lsQuestLogMicroButton:SetScript("OnClick", function(...) ToggleQuestLog() end)

	InitializeMicroButton(lsGuildMicroButton, {"PLAYER_GUILD_UPDATE", "NEUTRAL_FACTION_SELECT_RESULT"}, nil, true, true)
	lsGuildMicroButton:SetScript("OnClick", function(...) ToggleGuildFrame() end)

	InitializeMicroButton(lsLFDMicroButton, nil, 10, true)
	lsLFDMicroButton:SetScript("OnClick", function(...) PVEFrame_ToggleFrame() end)
	LFDMicroButtonAlert:SetPoint("BOTTOM", lsLFDMicroButton, "TOP", 0, 12)

	lsCollectionsMicroButton:SetScript("OnClick", function(...) ToggleCollectionsJournal() end)
	CollectionsMicroButtonAlert:SetPoint("BOTTOM", lsCollectionsMicroButton, "TOP", 0, 12)

	InitializeMicroButton(lsEJMicroButton, nil, 15, true)
	lsEJMicroButton:SetScript("OnClick", function(...) ToggleEncounterJournal() end)

	InitializeMicroButton(lsStoreMicroButton, {"STORE_STATUS_CHANGED"})
	lsStoreMicroButton:SetScript("OnClick", function(...) ToggleStoreUI() end)

	for mb, button in next, MM.Buttons do
		button:SetPoint(unpack(MICRO_BUTTON_LAYOUT[mb].point))
		button:MicroButton_OnEvent("CUSTOM_FORCE_UPDATE")
	end

	for _, f in next, MICRO_BUTTONS do
		_G[f]:UnregisterAllEvents()
		_G[f]:SetParent(ns.M.hiddenParent)
	end

	hooksecurefunc("UpdateMicroButtons", UpdateMicroButtonState)
end
