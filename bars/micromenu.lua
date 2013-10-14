local _, ns = ...
local cfg = ns.cfg
local L = ns.L
local mmenu_module = CreateFrame("Frame")

local function CreateMicroMenuButtons(index)
	_G["mmenu_module.btn"..index] = CreateFrame("Button", "new_MicroMenu"..index, UIParent)
end

local function SetMicroMenuPosition(f)
	_G["new_MicroMenu"..f]:SetSize(26, 26)
	if f == 1 then
		_G["new_MicroMenu"..f]:SetPoint("BOTTOM", -422, 6) -- -(262 + 26 * 5 + 5 * 6)
	elseif f == 7 then
		_G["new_MicroMenu"..f]:SetPoint("BOTTOM", 262, 6)
	elseif f == 13 then
		_G["new_MicroMenu"..f]:SetPoint("LEFT", _G["new_MicroMenu10"], "RIGHT", 6, 0)
		_G["new_MicroMenu"..f]:Hide()
	else
		_G["new_MicroMenu"..f]:SetPoint("LEFT", _G["new_MicroMenu"..f-1], "RIGHT", 6, 0)
	end
	_G["new_MicroMenu"..f].tooltipText = ""
	_G["new_MicroMenu"..f]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	_G["new_MicroMenu"..f]:RegisterEvent("UPDATE_BINDINGS")
	_G["new_MicroMenu"..f]:SetScale(cfg.globals.scale)
end

local function SetMicroMenuStyle(f)
	_G["new_MicroMenu"..f].bg = _G["new_MicroMenu"..f]:CreateTexture(nil, "BACKGROUND")
	_G["new_MicroMenu"..f].bg:SetPoint("CENTER", 0, 0)
	_G["new_MicroMenu"..f].bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton")

	_G["new_MicroMenu"..f].cover = _G["new_MicroMenu"..f]:CreateTexture(nil, "ARTWORK", nil, -4)
	_G["new_MicroMenu"..f].cover:SetPoint("CENTER",0 ,0)
	_G["new_MicroMenu"..f].cover:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton_cover")

	_G["new_MicroMenu"..f].fill = _G["new_MicroMenu"..f]:CreateTexture(nil, "ARTWORK", nil, -6)
	_G["new_MicroMenu"..f].fill:SetPoint("CENTER",0 ,0)
	_G["new_MicroMenu"..f].fill:SetSize(20, 20)
	
	_G["new_MicroMenu"..f]:SetHighlightTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton_highlight")
	_G["new_MicroMenu"..f]:GetHighlightTexture():SetTexCoord(3 / 32, 29 / 32, 3 / 32, 29 / 32)
	_G["new_MicroMenu"..f]:SetPushedTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton_pushed")
	_G["new_MicroMenu"..f]:GetPushedTexture():SetTexCoord(3 / 32, 29 / 32, 3 / 32, 29 / 32)

	_G["new_MicroMenu"..f].icon = _G["new_MicroMenu"..f]:CreateTexture(nil, "ARTWORK", nil, -5)
	_G["new_MicroMenu"..f].icon:SetPoint("CENTER",0 ,0)
	_G["new_MicroMenu"..f].icon:SetSize(20, 20)
	_G["new_MicroMenu"..f].icon:SetVertexColor(0.52, 0.46, 0.36)

	if f == 1 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\character")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
	elseif f == 2 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\spellbook")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
	elseif f == 3 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\talents")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
	elseif f == 4 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\achievement")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
	elseif f == 5 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\quest")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
	elseif f == 6 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\guild")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLEGUILDTAB")
	elseif f == 7 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\pvp")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
	elseif f == 8 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\lfg")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
	elseif f == 9 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\pet")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEPETJOURNAL")
	elseif f == 10 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\ej")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
	elseif f == 11 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\help")
		_G["new_MicroMenu"..f].tooltipText = HELP_BUTTON
	elseif f == 12 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\mainmenu")
		_G["new_MicroMenu"..f].tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
	elseif f == 13 then
		_G["new_MicroMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\store")
		_G["new_MicroMenu"..f].tooltipText = BLIZZARD_STORE
		_G["new_MicroMenu"..f]:RegisterEvent("STORE_STATUS_CHANGED")
	end
end

local function MainMenuOnClick(self)
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
end

local function UpdatePushedState()
	if CharacterFrame and CharacterFrame:IsShown() then
		new_MicroMenu1:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu1:SetButtonState("NORMAL")
	end

	if SpellBookFrame and SpellBookFrame:IsShown() then
		new_MicroMenu2:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu2:SetButtonState("NORMAL")
	end

	if PlayerTalentFrame and PlayerTalentFrame:IsShown() then
		new_MicroMenu3:SetButtonState("PUSHED", 1)
	else
		if UnitLevel("player") < 10 then
			new_MicroMenu3:Disable()
			new_MicroMenu3:SetAlpha(0.5)
		else
			new_MicroMenu3:Enable()
			new_MicroMenu3:SetAlpha(1)
			new_MicroMenu3:SetButtonState("NORMAL")
		end
	end

	if AchievementFrame and AchievementFrame:IsShown() then
		new_MicroMenu4:SetButtonState("PUSHED", 1)
	else
		if (HasCompletedAnyAchievement() or IsInGuild()) and CanShowAchievementUI() then
			new_MicroMenu4:Enable()
			new_MicroMenu4:SetAlpha(1)
			new_MicroMenu4:SetButtonState("NORMAL")
		else
			new_MicroMenu4:Disable()
			new_MicroMenu6:SetAlpha(0.5)
		end
	end

	if QuestLogFrame and QuestLogFrame:IsShown() then
		new_MicroMenu5:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu5:SetButtonState("NORMAL")
	end

	if IsTrialAccount() or UnitFactionGroup("player") == "Neutral" then
		new_MicroMenu6:Disable()
		new_MicroMenu6:SetAlpha(0.5)
	elseif (GuildFrame and GuildFrame:IsShown()) or (LookingForGuildFrame and LookingForGuildFrame:IsShown()) then
		new_MicroMenu6:Enable()
		new_MicroMenu6:SetAlpha(1)
		new_MicroMenu6:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu6:Enable()
		new_MicroMenu6:SetAlpha(1)
		new_MicroMenu6:SetButtonState("NORMAL")
	end

	if PVPUIFrame and PVPUIFrame:IsShown() then
		new_MicroMenu7:SetButtonState("PUSHED", 1)
	else
		if UnitLevel("player") < SHOW_PVP_LEVEL or UnitFactionGroup("player") == "Neutral" then
			new_MicroMenu7:Disable()
			new_MicroMenu7:SetAlpha(0.5)
		else
			new_MicroMenu7:Enable()
			new_MicroMenu7:SetAlpha(1)
			new_MicroMenu7:SetButtonState("NORMAL")
		end
	end

	if PVEFrame and PVEFrame:IsShown() then
		new_MicroMenu8:SetButtonState("PUSHED", 1)
	else
		if UnitLevel("player") < SHOW_LFD_LEVEL or UnitFactionGroup("player") == "Neutral" then
			new_MicroMenu8:Disable()
			new_MicroMenu8:SetAlpha(0.5)
		else
			new_MicroMenu8:Enable()
			new_MicroMenu8:SetAlpha(1)
			new_MicroMenu8:SetButtonState("NORMAL")
		end
	end
	
	if PetJournalParent and PetJournalParent:IsShown() then
		new_MicroMenu9:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu9:SetButtonState("NORMAL")
	end

	if  EncounterJournal and EncounterJournal:IsShown() then
		new_MicroMenu10:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu10:SetButtonState("NORMAL")
	end

	if HelpFrame and HelpFrame:IsShown() then
		new_MicroMenu11:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu11:SetButtonState("NORMAL")
	end

	if (GameMenuFrame and GameMenuFrame:IsShown())
		or InterfaceOptionsFrame:IsShown()
		or (KeyBindingFrame and KeyBindingFrame:IsShown())
		or (MacroFrame and MacroFrame:IsShown()) then
		new_MicroMenu12:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu12:SetButtonState("NORMAL")
	end

	if StoreFrame and StoreFrame_IsShown() then
		new_MicroMenu13:SetButtonState("PUSHED", 1)
	else
		new_MicroMenu13:SetButtonState("NORMAL")
	end

	if C_StorePublic.IsEnabled() then
		new_MicroMenu11:Hide()
		new_MicroMenu13:Show()
	else
		new_MicroMenu11:Show()
		new_MicroMenu13:Hide()
	end

	if IsTrialAccount() then
		new_MicroMenu13:Disable()
		new_MicroMenu13:SetAlpha(0.5)
	else
		new_MicroMenu13:Enable()
		new_MicroMenu13:SetAlpha(1)
	end
end

local function AnyOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 0)
	GameTooltip:AddLine(self.tooltipText, 1, 1, 1)
	GameTooltip:Show()
end

local function AnyOnLeave(self)
	GameTooltip:Hide()
end

local function AnyOnEvent(self, event, ...)
	print(event)
	if event == "UPDATE_BINDINGS" then
		if self == new_MicroMenu1 then
			self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
		elseif self == new_MicroMenu2 then
			self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
		elseif self == new_MicroMenu3 then
			self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
		elseif self == new_MicroMenu4 then
			self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
		elseif self == new_MicroMenu5 then
			self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
		elseif self == new_MicroMenu6 then
			self.tooltipText = MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLEGUILDTAB")
		elseif self == new_MicroMenu7 then
			self.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
		elseif self == new_MicroMenu8 then
			self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
		elseif self == new_MicroMenu9 then
			self.tooltipText = MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEPETJOURNAL")
		elseif self == new_MicroMenu10 then
			self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
		elseif self == new_MicroMenu11 then
			self.tooltipText = HELP_BUTTON
		elseif self == new_MicroMenu12 then
			self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
		elseif self == new_MicroMenu13 then
			self.tooltipText = BLIZZARD_STORE
		end
	elseif event == "STORE_STATUS_CHANGED" and self == new_MicroMenu13 then
		UpdatePushedState()
	end
end

local function InitMicroMenuScripts()
	new_MicroMenu1:SetScript("OnClick", function() ToggleCharacter("PaperDollFrame") end)
	new_MicroMenu2:SetScript("OnClick", function() ToggleSpellBook(BOOKTYPE_SPELL) end)
	new_MicroMenu3:SetScript("OnClick", ToggleTalentFrame)
	new_MicroMenu4:SetScript("OnClick", function() ToggleAchievementFrame() end)
	new_MicroMenu5:SetScript("OnClick", function() ToggleFrame(QuestLogFrame) end)
	new_MicroMenu6:SetScript("OnClick", function() ToggleGuildFrame() end)
	new_MicroMenu7:SetScript("OnClick", function() TogglePVPUI() end)
	new_MicroMenu8:SetScript("OnClick", function() ToggleLFDParentFrame() end)
	new_MicroMenu9:SetScript("OnClick", function() TogglePetJournal() end)
	new_MicroMenu10:SetScript("OnClick", function() ToggleEncounterJournal() end)
	new_MicroMenu11:SetScript("OnClick", ToggleHelpFrame)
	new_MicroMenu12:SetScript("OnClick", MainMenuOnClick)
	new_MicroMenu13:SetScript("OnClick", ToggleStoreUI)
	for i = 1, 13 do
		_G["new_MicroMenu"..i]:SetScript("OnEnter", AnyOnEnter)
		_G["new_MicroMenu"..i]:SetScript("OnLeave", AnyOnLeave)
		_G["new_MicroMenu"..i]:SetScript("OnEvent", AnyOnEvent)
	end
end

local function InitMicroMenuParameters()
	for i = 1, 13 do
		CreateMicroMenuButtons(i)
		SetMicroMenuPosition(i)
		SetMicroMenuStyle(i)
	end	

	InitMicroMenuScripts()

	TalentMicroButtonAlert:SetPoint("BOTTOM", "new_MicroMenu3", "TOP", 0, 12)
	CompanionsMicroButtonAlert:SetPoint("BOTTOM", "new_MicroMenu9", "TOP", 0, 12)

	if not AchievementMicroButton_Update then
		AchievementMicroButton_Update = function() return end
	end

	for _, f in pairs(MICRO_BUTTONS) do
		_G[f]:UnregisterAllEvents()
		_G[f]:EnableMouse(false)
		_G[f]:ClearAllPoints()
		_G[f]:Hide()
	end

	local function MicroButtonHooky() for _, f in pairs(MICRO_BUTTONS) do if _G[f]:IsShown() then _G[f]:Hide() end end end

	hooksecurefunc("UpdateMicroButtons", MicroButtonHooky)
	hooksecurefunc("UpdateMicroButtons", UpdatePushedState)
end

mmenu_module:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		InitMicroMenuParameters()
	end
end)

mmenu_module:RegisterEvent("PLAYER_LOGIN")