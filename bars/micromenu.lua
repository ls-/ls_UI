local ERR_GUILD_TRIAL_ACCOUNT = ERR_GUILD_TRIAL_ACCOUNT
local BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS = BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS
local MICRO_BUTTONS = MICRO_BUTTONS

local hidenParentFrame = CreateFrame("Frame")
hidenParentFrame:Hide()

local function UpdateMicroButtonState()
	local playerLevel = UnitLevel("player")
	local factionGroup = UnitFactionGroup("player")

	if factionGroup == "Neutral" then
		oUF_PVPMicroButton.factionGroup = factionGroup
		oUF_GuildMicroButton.factionGroup = factionGroup
		oUF_LFDMicroButton.factionGroup = factionGroup
	else
		oUF_PVPMicroButton.factionGroup = nil
		oUF_GuildMicroButton.factionGroup = nil
		oUF_LFDMicroButton.factionGroup = nil
	end

	if CharacterFrame and CharacterFrame:IsShown() then
		oUF_CharacterMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_CharacterMicroButton:SetButtonState("NORMAL")
	end

	if SpellBookFrame and SpellBookFrame:IsShown() then
		oUF_SpellBookMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_SpellBookMicroButton:SetButtonState("NORMAL")
	end

	if PlayerTalentFrame and PlayerTalentFrame:IsShown() then
		oUF_TalentMicroButton:SetButtonState("PUSHED", 1)
	else
		if playerLevel < 10 then
			oUF_TalentMicroButton:Disable()
		else
			oUF_TalentMicroButton:Enable()
			oUF_TalentMicroButton:SetButtonState("NORMAL")
		end
	end

	if AchievementFrame and AchievementFrame:IsShown() then
		oUF_AchievementMicroButton:SetButtonState("PUSHED", 1)
	else
		if (HasCompletedAnyAchievement() or IsInGuild()) and CanShowAchievementUI() then
			oUF_AchievementMicroButton:Enable()
			oUF_AchievementMicroButton:SetButtonState("NORMAL")
		else
			oUF_AchievementMicroButton:Disable()
		end
	end

	if QuestLogFrame and QuestLogFrame:IsShown() then
		oUF_QuestLogMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_QuestLogMicroButton:SetButtonState("NORMAL")
	end

	if IsTrialAccount() or factionGroup == "Neutral" then
		oUF_GuildMicroButton:Disable()
	elseif (GuildFrame and GuildFrame:IsShown()) or (LookingForGuildFrame and LookingForGuildFrame:IsShown()) then
		oUF_GuildMicroButton:Enable()
		oUF_GuildMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_GuildMicroButton:Enable()
		oUF_GuildMicroButton:SetButtonState("NORMAL")
		if IsInGuild() then
			oUF_GuildMicroButton.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
		else
			oUF_GuildMicroButton.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
		end
	end

	if PVPUIFrame and PVPUIFrame:IsShown() then
		oUF_PVPMicroButton:SetButtonState("PUSHED", 1)
	else
		if playerLevel < oUF_PVPMicroButton.minLevel or factionGroup == "Neutral" then
			oUF_PVPMicroButton:Disable()
		else
			oUF_PVPMicroButton:Enable()
			oUF_PVPMicroButton:SetButtonState("NORMAL")
		end
	end

	if PVEFrame and PVEFrame:IsShown() then
		oUF_LFDMicroButton:SetButtonState("PUSHED", 1)
	else
		if playerLevel < oUF_LFDMicroButton.minLevel or factionGroup == "Neutral" then
			oUF_LFDMicroButton:Disable()
		else
			oUF_LFDMicroButton:Enable()
			oUF_LFDMicroButton:SetButtonState("NORMAL")
		end
	end
	
	if PetJournalParent and PetJournalParent:IsShown() then
		oUF_CompanionsMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_CompanionsMicroButton:SetButtonState("NORMAL")
	end

	if EncounterJournal and EncounterJournal:IsShown() then
		oUF_EJMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_EJMicroButton:SetButtonState("NORMAL")
	end

	if C_StorePublic.IsEnabled() then
		oUF_MainMenuMicroButton:SetPoint("LEFT", oUF_StoreMicroButton, "RIGHT", 6, 0);
		oUF_HelpMicroButton:Hide()
		oUF_StoreMicroButton:Show()
	else
		oUF_MainMenuMicroButton:SetPoint("LEFT", oUF_EJMicroButton, "RIGHT", 6, 0);
		oUF_HelpMicroButton:Show()
		oUF_StoreMicroButton:Hide()
	end

	if IsTrialAccount() then
		oUF_StoreMicroButton.disabledTooltip = ERR_GUILD_TRIAL_ACCOUNT
		oUF_StoreMicroButton:Disable()
	else
		oUF_StoreMicroButton.disabledTooltip = nil
		oUF_StoreMicroButton:Enable()
	end

	if StoreFrame and StoreFrame_IsShown() then
		oUF_StoreMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_StoreMicroButton:SetButtonState("NORMAL")
	end

	if (GameMenuFrame and GameMenuFrame:IsShown())
		or InterfaceOptionsFrame:IsShown()
		or (KeyBindingFrame and KeyBindingFrame:IsShown())
		or (MacroFrame and MacroFrame:IsShown()) then
		oUF_MainMenuMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_MainMenuMicroButton:SetButtonState("NORMAL")
	end

	if HelpFrame and HelpFrame:IsShown() then
		oUF_HelpMicroButton:SetButtonState("PUSHED", 1)
	else
		oUF_HelpMicroButton:SetButtonState("NORMAL")
	end
end

function oUF_MicroButton_Event(self, event)
	local name = self:GetName()
	if event == "UPDATE_BINDINGS" then
		if name == "oUF_CharacterMicroButton" then
			self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
		elseif name == "oUF_SpellBookMicroButton" then
			self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
		elseif name == "oUF_TalentMicroButton" then
			self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
		elseif name == "oUF_AchievementMicroButton" then
			self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
		elseif name == "oUF_QuestLogMicroButton" then
			self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
		elseif name == "oUF_GuildMicroButton" then
			if IsInGuild() then
				self.tooltipText = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
			else
				self.tooltipText = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
			end
		elseif name == "oUF_PVPMicroButton" then
			self.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
		elseif name == "oUF_LFDMicroButton" then
			self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
		elseif name == "oUF_CompanionsMicroButton" then
			self.tooltipText = MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEPETJOURNAL")
		elseif name == "oUF_MainMenuMicroButton" then
			self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
		elseif name == "oUF_EJMicroButton" then
			self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
		elseif name == "oUF_StoreMicroButton" then
			self.tooltipText = BLIZZARD_STORE
		elseif name == "oUF_MainMenuMicroButton" then
			self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
		elseif name == "oUF_HelpMicroButton" then
			self.tooltipText = HELP_BUTTON
		end
	end
	UpdateMicroButtonState()
end

do
	TalentMicroButtonAlert:SetPoint("BOTTOM", oUF_TalentMicroButton, "TOP", 0, 12)
	CompanionsMicroButtonAlert:SetPoint("BOTTOM", oUF_CompanionsMicroButton, "TOP", 0, 12)
	if not AchievementMicroButton_Update then
		AchievementMicroButton_Update = function() return end
	end
	for _, f in pairs(MICRO_BUTTONS) do
		_G[f]:UnregisterAllEvents()
		_G[f]:SetParent(hidenParentFrame)
	end
end