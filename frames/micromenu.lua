local _, ns = ...

ns.mbuttons = {}

local MICRO_BUTTON_LAYOUT = {
	["CharacterMicroButton"] = {
		point = {"BOTTOM", -392, 6},
		icon = "character",
	},
	["SpellbookMicroButton"] = {
		point = {"LEFT", "oUF_LSCharacterMicroButton", "RIGHT", 6, 0},
		icon = "spellbook",
	},
	["TalentMicroButton"] = {
		point = {"LEFT", "oUF_LSSpellbookMicroButton", "RIGHT", 6, 0},
		icon = "talents",
	},
	["AchievementMicroButton"] = {
		point = {"LEFT", "oUF_LSTalentMicroButton", "RIGHT", 6, 0},
		icon = "achievement",
	},
	["QuestLogMicroButton"] = {
		point = {"LEFT", "oUF_LSAchievementMicroButton", "RIGHT", 6, 0},
		icon = "quest",
	},
	["GuildMicroButton"] = {
		point = {"LEFT", "oUF_LSQuestLogMicroButton", "RIGHT", 6, 0},
		icon = "guild",
	},
	["PVPMicroButton"] = {
		point = {"BOTTOM", 232, 6},
		icon = "pvp",
	},
	["LFDMicroButton"] = {
		point = {"LEFT", "oUF_LSPVPMicroButton", "RIGHT", 6, 0},
		icon = "lfg",
	},
	["CompanionsMicroButton"] = {
		point = {"LEFT", "oUF_LSLFDMicroButton", "RIGHT", 6, 0},
		icon = "pet",
	},
	["EJMicroButton"] = {
		point = {"LEFT", "oUF_LSCompanionsMicroButton", "RIGHT", 6, 0},
		icon = "ej",
	},
	["StoreMicroButton"] = {
		point = {"LEFT", "oUF_LSEJMicroButton", "RIGHT", 6, 0},
		icon = "store",
	},
	["MainMenuMicroButton"] = {
		point = {"LEFT", "oUF_LSEJMicroButton", "RIGHT", 6, 0},
		icon = "mainmenu",
	},
	["HelpMicroButton"] = {
		point = {"LEFT", "oUF_LSMainMenuMicroButton", "RIGHT", 6, 0},
		icon = "help",
	},
}

local function UpdateMicroButtonState()
	local playerLevel = UnitLevel("player")
	local factionGroup = UnitFactionGroup("player")

	if factionGroup == "Neutral" then
		oUF_LSPVPMicroButton.factionGroup = factionGroup
		oUF_LSGuildMicroButton.factionGroup = factionGroup
		oUF_LSLFDMicroButton.factionGroup = factionGroup
	else
		oUF_LSPVPMicroButton.factionGroup = nil
		oUF_LSGuildMicroButton.factionGroup = nil
		oUF_LSLFDMicroButton.factionGroup = nil
	end

	if CharacterFrame and CharacterFrame:IsShown() then
		oUF_LSCharacterMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSCharacterMicroButton:SetButtonState("NORMAL")
	end

	if SpellBookFrame and SpellBookFrame:IsShown() then
		oUF_LSSpellbookMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSSpellbookMicroButton:SetButtonState("NORMAL")
	end

	if PlayerTalentFrame and PlayerTalentFrame:IsShown() then
		oUF_LSTalentMicroButton:SetButtonState("PUSHED", 1)
	else
		if playerLevel < 10 then
			oUF_LSTalentMicroButton:Disable()
		else
			oUF_LSTalentMicroButton:Enable()
			oUF_LSTalentMicroButton:SetButtonState("NORMAL")
		end
	end

	if AchievementFrame and AchievementFrame:IsShown() then
		oUF_LSAchievementMicroButton:SetButtonState("PUSHED", 1)
	else
		if (HasCompletedAnyAchievement() or IsInGuild()) and CanShowAchievementUI() then
			oUF_LSAchievementMicroButton:Enable()
			oUF_LSAchievementMicroButton:SetButtonState("NORMAL")
		else
			oUF_LSAchievementMicroButton:Disable()
		end
	end

	if QuestLogFrame and QuestLogFrame:IsShown() then
		oUF_LSQuestLogMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSQuestLogMicroButton:SetButtonState("NORMAL")
	end

	if IsTrialAccount() or factionGroup == "Neutral" then
		oUF_LSGuildMicroButton:Disable()
	elseif (GuildFrame and GuildFrame:IsShown()) or (LookingForGuildFrame and LookingForGuildFrame:IsShown()) then
		oUF_LSGuildMicroButton:Enable()
		oUF_LSGuildMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSGuildMicroButton:Enable()
		oUF_LSGuildMicroButton:SetButtonState("NORMAL")
		if IsInGuild() then
			oUF_LSGuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
		else
			oUF_LSGuildMicroButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
		end
	end

	if PVPUIFrame and PVPUIFrame:IsShown() then
		oUF_LSPVPMicroButton:SetButtonState("PUSHED", 1)
	else
		if playerLevel < oUF_LSPVPMicroButton.minLevel or factionGroup == "Neutral" then
			oUF_LSPVPMicroButton:Disable()
		else
			oUF_LSPVPMicroButton:Enable()
			oUF_LSPVPMicroButton:SetButtonState("NORMAL")
		end
	end

	if PVEFrame and PVEFrame:IsShown() then
		oUF_LSLFDMicroButton:SetButtonState("PUSHED", 1)
	else
		if playerLevel < oUF_LSLFDMicroButton.minLevel or factionGroup == "Neutral" then
			oUF_LSLFDMicroButton:Disable()
		else
			oUF_LSLFDMicroButton:Enable()
			oUF_LSLFDMicroButton:SetButtonState("NORMAL")
		end
	end

	if PetJournalParent and PetJournalParent:IsShown() then
		oUF_LSCompanionsMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSCompanionsMicroButton:SetButtonState("NORMAL")
	end

	if EncounterJournal and EncounterJournal:IsShown() then
		oUF_LSEJMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSEJMicroButton:SetButtonState("NORMAL")
	end

	if C_StorePublic.IsEnabled() then
		oUF_LSMainMenuMicroButton:SetPoint("LEFT", oUF_LSStoreMicroButton, "RIGHT", 6, 0);
		oUF_LSHelpMicroButton:Hide()
		oUF_LSStoreMicroButton:Show()
	else
		oUF_LSMainMenuMicroButton:SetPoint("LEFT", oUF_LSEJMicroButton, "RIGHT", 6, 0);
		oUF_LSHelpMicroButton:Show()
		oUF_LSStoreMicroButton:Hide()
	end

	if IsTrialAccount() then
		oUF_LSStoreMicroButton.disabledTooltip = ERR_GUILD_TRIAL_ACCOUNT
		oUF_LSStoreMicroButton:Disable()
	else
		oUF_LSStoreMicroButton.disabledTooltip = nil
		oUF_LSStoreMicroButton:Enable()
	end

	if StoreFrame and StoreFrame_IsShown() then
		oUF_LSStoreMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSStoreMicroButton:SetButtonState("NORMAL")
	end

	if (GameMenuFrame and GameMenuFrame:IsShown())
		or InterfaceOptionsFrame:IsShown()
		or (KeyBindingFrame and KeyBindingFrame:IsShown())
		or (MacroFrame and MacroFrame:IsShown()) then
		oUF_LSMainMenuMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSMainMenuMicroButton:SetButtonState("NORMAL")
	end

	if HelpFrame and HelpFrame:IsShown() then
		oUF_LSHelpMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_LSHelpMicroButton:SetButtonState("NORMAL")
	end
end

function oUF_LSMicroButton_OnEvent(self, event)
	local name = self:GetName()
	if event == "UPDATE_BINDINGS" then
		if name == "oUF_LSCharacterMicroButton" then
			self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
		elseif name == "oUF_LSSpellbookMicroButton" then
			self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
		elseif name == "oUF_LSTalentMicroButton" then
			self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
		elseif name == "oUF_LSAchievementMicroButton" then
			self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
		elseif name == "oUF_LSQuestLogMicroButton" then
			self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
		elseif name == "oUF_LSGuildMicroButton" then
			if IsInGuild() then
				self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
			else
				self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
			end
		elseif name == "oUF_LSPVPMicroButton" then
			self.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
		elseif name == "oUF_LSLFDMicroButton" then
			self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
		elseif name == "oUF_LSCompanionsMicroButton" then
			self.tooltipText = MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEPETJOURNAL")
		elseif name == "oUF_LSMainMenuMicroButton" then
			self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
		elseif name == "oUF_LSEJMicroButton" then
			self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
		elseif name == "oUF_LSStoreMicroButton" then
			self.tooltipText = BLIZZARD_STORE
		elseif name == "oUF_LSMainMenuMicroButton" then
			self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
		elseif name == "oUF_LSHelpMicroButton" then
			self.tooltipText = HELP_BUTTON
		end
	end
	UpdateMicroButtonState()
end

local function oUF_LSMicroButton_Initialize(mbutton, events, level, isBlizzConDriven, isTrialDriven)
	if events then
		for i = 1, #events do
			mbutton:RegisterEvent(events[i])
		end
	end

	if level then mbutton.minLevel = level end

	if isTrialDriven then
		if IsBlizzCon() then
			mbutton:Disable()
			mbutton:SetAlpha(0.5)
		end
	end

	if isTrialDriven then
		if IsTrialAccount() then
			mbutton:Disable()
			mbutton:SetAlpha(0.5)
			mbutton.disabledTooltip = ERR_RESTRICTED_ACCOUNT
		end
	end

end

local function oUF_LSMainMenuMicroButton_OnClick(self)
	if not GameMenuFrame:IsShown() then
		if VideoOptionsFrame:IsShown() then
			VideoOptionsFrameCancel:Click()
		elseif AudioOptionsFrame:IsShown() then
			AudioOptionsFrameCancel:Click()
		elseif InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrameCancel:Click()
		end
		CloseMenus()
		CloseAllWindows()
		PlaySound("igMainMenuOpen")
		ShowUIPanel(GameMenuFrame)
	else
		PlaySound("igMainMenuQuit")
		HideUIPanel(GameMenuFrame)
		MainMenuMicroButton_SetNormal()
	end
	oUF_LSMicroButton_OnEvent(self)
end

do
	for mb, mbdata in pairs(MICRO_BUTTON_LAYOUT) do
		local mbutton = CreateFrame("Button", "oUF_LS"..mb, UIParent, "oUF_LSMicroButtonTemplate")
		mbutton:SetFrameStrata("LOW")
		mbutton:SetFrameLevel(1)

		mbutton.icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\"..mbdata.icon)

		ns.mbuttons[mb] = mbutton
	end

	for mb, mbutton in pairs(ns.mbuttons) do
		mbutton:SetPoint(unpack(MICRO_BUTTON_LAYOUT[mb].point))
	end

	oUF_LSCharacterMicroButton:SetScript("OnClick", function(...) ToggleCharacter("PaperDollFrame") end)

	oUF_LSSpellbookMicroButton:SetScript("OnClick", function(...) ToggleFrame(SpellBookFrame) end)

	oUF_LSMicroButton_Initialize(oUF_LSTalentMicroButton, {"PLAYER_LEVEL_UP", "PLAYER_TALENT_UPDATE"}, 10, true)
	oUF_LSTalentMicroButton:SetScript("OnClick", function(...) ToggleTalentFrame() end)

	oUF_LSMicroButton_Initialize(oUF_LSAchievementMicroButton, {"RECEIVED_ACHIEVEMENT_LIST", "ACHIEVEMENT_EARNED"}, 10)
	oUF_LSAchievementMicroButton:SetScript("OnClick", function(...) ToggleAchievementFrame() end)

	oUF_LSQuestLogMicroButton:SetScript("OnClick", function(...) ToggleFrame(QuestLogFrame) end)

	oUF_LSMicroButton_Initialize(oUF_LSGuildMicroButton, {"PLAYER_GUILD_UPDATE", "NEUTRAL_FACTION_SELECT_RESULT"}, nil, true, true)
	oUF_LSGuildMicroButton:SetScript("OnClick", function(...) ToggleGuildFrame() end)

	oUF_LSMicroButton_Initialize(oUF_LSPVPMicroButton, {"NEUTRAL_FACTION_SELECT_RESULT"}, 10, true)
	oUF_LSPVPMicroButton:SetScript("OnClick", function(...) TogglePVPUI() end)

	oUF_LSMicroButton_Initialize(oUF_LSLFDMicroButton, {"PLAYER_LEVEL_UP"}, 15, true)
	oUF_LSLFDMicroButton:SetScript("OnClick", function(...) PVEFrame_ToggleFrame() end)

	oUF_LSCompanionsMicroButton:SetScript("OnClick", function(...) TogglePetJournal() end)

	oUF_LSMicroButton_Initialize(oUF_LSEJMicroButton, nil, 15, true)
	oUF_LSEJMicroButton:SetScript("OnClick", function(...) ToggleEncounterJournal() end)

	oUF_LSMicroButton_Initialize(oUF_LSStoreMicroButton, {"STORE_STATUS_CHANGED"})
	oUF_LSStoreMicroButton:SetScript("OnClick", function(...) ToggleStoreUI() end)

	oUF_LSMainMenuMicroButton:SetScript("OnClick", oUF_LSMainMenuMicroButton_OnClick)

	oUF_LSHelpMicroButton:SetScript("OnClick", function(...) ToggleHelpFrame() end)


	TalentMicroButtonAlert:SetPoint("BOTTOM", oUF_LSTalentMicroButton, "TOP", 0, 12)
	CompanionsMicroButtonAlert:SetPoint("BOTTOM", oUF_LSCompanionsMicroButton, "TOP", 0, 12)

	for _, f in pairs(MICRO_BUTTONS) do
		_G[f]:UnregisterAllEvents()
		_G[f]:SetParent(ns.hiddenParentFrame)
	end
	hooksecurefunc("UpdateMicroButtons", UpdateMicroButtonState)
end