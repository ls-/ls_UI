local _, ns = ...

ns.mbuttons = {}

local MICRO_BUTTON_LAYOUT = {
	["CharacterMicroButton"] = {
		point = {"BOTTOM", -318, 8},
		icon = "character",
	},
	["SpellbookMicroButton"] = {
		point = {"LEFT", "lsCharacterMicroButton", "RIGHT", 6, 0},
		icon = "spellbook",
	},
	["TalentMicroButton"] = {
		point = {"LEFT", "lsSpellbookMicroButton", "RIGHT", 6, 0},
		icon = "talents",
	},
	["AchievementMicroButton"] = {
		point = {"LEFT", "lsTalentMicroButton", "RIGHT", 6, 0},
		icon = "achievement",
	},
	["QuestLogMicroButton"] = {
		point = {"LEFT", "lsAchievementMicroButton", "RIGHT", 6, 0},
		icon = "quest",
	},
	["GuildMicroButton"] = {
		point = {"BOTTOM", 220, 8},
		icon = "guild",
	},
	["LFDMicroButton"] = {
		point = {"LEFT", "lsGuildMicroButton", "RIGHT", 6, 0},
		icon = "lfg",
	},
	["CompanionsMicroButton"] = {
		point = {"LEFT", "lsLFDMicroButton", "RIGHT", 6, 0},
		icon = "pet",
	},
	["EJMicroButton"] = {
		point = {"LEFT", "lsCompanionsMicroButton", "RIGHT", 6, 0},
		icon = "ej",
	},
	["StoreMicroButton"] = {
		point = {"LEFT", "lsEJMicroButton", "RIGHT", 6, 0},
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

	if IsTrialAccount() or factionGroup == "Neutral" then
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

	if PetJournalParent and PetJournalParent:IsShown() then
		lsCompanionsMicroButton:SetButtonState("PUSHED", true)
	else
		lsCompanionsMicroButton:SetButtonState("NORMAL")
	end

	if EncounterJournal and EncounterJournal:IsShown() then
		lsEJMicroButton:SetButtonState("PUSHED", true)
	else
		lsEJMicroButton:SetButtonState("NORMAL")
	end

	if IsTrialAccount() then
		lsStoreMicroButton.disabledTooltip = ERR_GUILD_TRIAL_ACCOUNT
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

local function lsMicroButton_OnEvent(self, event)
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
		elseif name == "lsCompanionsMicroButton" then
			self.tooltipText = MicroButtonTooltipText(COLLECTIONS, "TOGGLECOLLECTIONS")
		elseif name == "lsEJMicroButton" then
			self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
		elseif name == "lsStoreMicroButton" then
			self.tooltipText = BLIZZARD_STORE
		end
	end

	UpdateMicroButtonState()
end

local function lsMicroButton_Initialize(mbutton, events, level, isBlizzConDriven, isTrialDriven)
	if events then
		for i = 1, #events do
			mbutton:RegisterEvent(events[i])
		end
	end

	if level then mbutton.minLevel = level end

	if isTrialDriven then
		if IsTrialAccount() then
			mbutton:Disable()
			mbutton:SetAlpha(0.5)
			mbutton.disabledTooltip = ERR_RESTRICTED_ACCOUNT
		end
	end
end

function ns.lsMicroMenu_Initialize()
	for mb, mbdata in next, MICRO_BUTTON_LAYOUT do
		local mbutton = CreateFrame("Button", "ls"..mb, UIParent, "lsMicroButtonTemplate")
		mbutton:SetFrameStrata("LOW")
		mbutton:SetFrameLevel(1)

		mbutton.icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\"..mbdata.icon)

		mbutton.lsMicroButton_OnEvent = lsMicroButton_OnEvent

		ns.mbuttons[mb] = mbutton
	end

	lsCharacterMicroButton:SetScript("OnClick", function(...) ToggleCharacter("PaperDollFrame") end)

	lsSpellbookMicroButton:SetScript("OnClick", function(...) ToggleFrame(SpellBookFrame) end)

	lsMicroButton_Initialize(lsTalentMicroButton, {"PLAYER_LEVEL_UP", "PLAYER_TALENT_UPDATE"}, 10, true)
	lsTalentMicroButton:SetScript("OnClick", function(...) ToggleTalentFrame() end)
	TalentMicroButtonAlert:SetPoint("BOTTOM", lsTalentMicroButton, "TOP", 0, 12)

	lsMicroButton_Initialize(lsAchievementMicroButton, {"RECEIVED_ACHIEVEMENT_LIST", "ACHIEVEMENT_EARNED"}, 10)
	lsAchievementMicroButton:SetScript("OnClick", function(...) ToggleAchievementFrame() end)

	lsQuestLogMicroButton:SetScript("OnClick", function(...) ToggleQuestLog() end)

	lsMicroButton_Initialize(lsGuildMicroButton, {"PLAYER_GUILD_UPDATE", "NEUTRAL_FACTION_SELECT_RESULT"}, nil, true, true)
	lsGuildMicroButton:SetScript("OnClick", function(...) ToggleGuildFrame() end)

	lsMicroButton_Initialize(lsLFDMicroButton, nil, 10, true)
	lsLFDMicroButton:SetScript("OnClick", function(...) PVEFrame_ToggleFrame() end)
	LFDMicroButtonAlert:SetPoint("BOTTOM", lsLFDMicroButton, "TOP", 0, 12)

	lsCompanionsMicroButton:SetScript("OnClick", function(...) TogglePetJournal() end)
	CompanionsMicroButtonAlert:SetPoint("BOTTOM", lsCompanionsMicroButton, "TOP", 0, 12)
	CollectionsMicroButtonAlert:SetPoint("BOTTOM", lsCompanionsMicroButton, "TOP", 0, 12)
	ToyBoxMicroButtonAlert:SetPoint("BOTTOM", lsCompanionsMicroButton, "TOP", 0, 12)

	lsMicroButton_Initialize(lsEJMicroButton, nil, 15, true)
	lsEJMicroButton:SetScript("OnClick", function(...) ToggleEncounterJournal() end)

	lsMicroButton_Initialize(lsStoreMicroButton, {"STORE_STATUS_CHANGED"})
	lsStoreMicroButton:SetScript("OnClick", function(...) ToggleStoreUI() end)

	for mb, mbutton in next, ns.mbuttons do
		mbutton:SetPoint(unpack(MICRO_BUTTON_LAYOUT[mb].point))
		mbutton:lsMicroButton_OnEvent("CUSTOM_FORCE_UPDATE")
	end

	for _, f in next, MICRO_BUTTONS do
		_G[f]:UnregisterAllEvents()
		_G[f]:SetParent(ns.hiddenParentFrame)
	end

	hooksecurefunc("UpdateMicroButtons", UpdateMicroButtonState)
end
