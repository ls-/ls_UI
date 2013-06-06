local _, ns = ...
local cfg = ns.cfg
local L = ns.L
local mmenu_module = CreateFrame("Frame")

local function CreateMicroMenuButtons(index)
	_G["mmenu_module.btn"..index] = CreateFrame("Button", "new_MMenu"..index, UIParent)
end

local function SetMicroMenuPosition(f)
	_G["new_MMenu"..f]:SetSize(58, 40)
	if f == 1 then
		_G["new_MMenu"..f]:SetPoint("BOTTOM", -932, 12) -- -(602 + 58 * 5 + 5 * 8)
	elseif f == 7 then
		_G["new_MMenu"..f]:SetPoint("BOTTOM", 602, 12)
	else
		_G["new_MMenu"..f]:SetPoint("LEFT", _G["new_MMenu"..f-1], "RIGHT", 8, 0)
	end
	_G["new_MMenu"..f].tooltipText = ""
	_G["new_MMenu"..f]:RegisterForClicks("LeftButtonUp")
	_G["new_MMenu"..f]:RegisterEvent("UPDATE_BINDINGS")
	_G["new_MMenu"..f]:SetScale(0.66 * cfg.globals.scale)
end

local function SetMicroMenuStyle(f)
	_G["new_MMenu"..f].cover = _G["new_MMenu"..f]:CreateTexture(nil, "BACKGROUND")
	_G["new_MMenu"..f].cover:SetPoint("CENTER", 0, 0)
	_G["new_MMenu"..f].cover:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton")

	_G["new_MMenu"..f].cover = _G["new_MMenu"..f]:CreateTexture(nil, "ARTWORK", nil, -4)
	_G["new_MMenu"..f].cover:SetPoint("CENTER",0 ,0)
	_G["new_MMenu"..f].cover:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton_cover")

	_G["new_MMenu"..f].fill = _G["new_MMenu"..f]:CreateTexture(nil, "ARTWORK", nil, -6)
	_G["new_MMenu"..f].fill:SetPoint("CENTER",0 ,0)
	_G["new_MMenu"..f].fill:SetSize(36, 34)
	_G["new_MMenu"..f].fill:SetTexture(cfg.globals.textures.statusbar)
	_G["new_MMenu"..f].fill:SetVertexColor(unpack(cfg.globals.colors.infobar.black))
	
	_G["new_MMenu"..f]:SetHighlightTexture("Interface\\AddOns\\oUF_LS\\media\\microbutton_highlight")
	_G["new_MMenu"..f]:GetHighlightTexture():SetTexCoord(0, 1, 9 / 64, 55 / 64)

	_G["new_MMenu"..f].icon = _G["new_MMenu"..f]:CreateTexture(nil, "ARTWORK", nil, -5)
	_G["new_MMenu"..f].icon:SetPoint("CENTER",0 ,0)
	_G["new_MMenu"..f].icon:SetVertexColor(0.52, 0.46, 0.36)

	if f == 1 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\character")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
	elseif f == 2 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\spellbook")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
	elseif f == 3 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\talents")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
		_G["new_MMenu"..f]:RegisterEvent("PLAYER_LEVEL_UP")
	elseif f == 4 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\achievement")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
	elseif f == 5 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\quest")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
	elseif f == 6 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\guild")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLEGUILDTAB")
	elseif f == 7 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\pvp")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
		_G["new_MMenu"..f]:RegisterEvent("PLAYER_LEVEL_UP")
	elseif f == 8 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\lfg")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
		_G["new_MMenu"..f]:RegisterEvent("PLAYER_LEVEL_UP")
	elseif f == 9 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\pet")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEPETJOURNAL")
	elseif f == 10 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\ej")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
	elseif f == 11 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\mainmenu")
		_G["new_MMenu"..f].tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
	elseif f == 12 then
		_G["new_MMenu"..f].icon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\microicon\\help")
		_G["new_MMenu"..f].tooltipText = HELP_BUTTON
	end
end

local function mainmenu_click(self)
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

local function any_enter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 0)
	GameTooltip:AddLine(self.tooltipText, 1, 1, 1)
	GameTooltip:Show()
end

local function any_leave(self)
	GameTooltip:Hide()
end

local function any_event(self, event, ...)
	if event == "UPDATE_BINDINGS" then
		if self == new_MMenu1 then
			self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
		elseif self == new_MMenu2 then
			self.tooltipText = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
		elseif self == new_MMenu3 then
			self.tooltipText = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
		elseif self == new_MMenu4 then
			self.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
		elseif self == new_MMenu5 then
			self.tooltipText = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
		elseif self == new_MMenu6 then
			self.tooltipText = MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLEGUILDTAB")
		elseif self == new_MMenu7 then
			self.tooltipText = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
		elseif self == new_MMenu8 then
			self.tooltipText = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
		elseif self == new_MMenu9 then
			self.tooltipText = MicroButtonTooltipText(MOUNTS_AND_PETS, "TOGGLEPETJOURNAL")
		elseif self == new_MMenu10 then
			self.tooltipText = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")
		elseif self == new_MMenu11 then
			self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
		elseif self == new_MMenu12 then
			self.tooltipText = HELP_BUTTON
		end
	elseif event == "PLAYER_LEVEL_UP" and (self == new_MMenu3 or self == new_MMenu7 or self == new_MMenu8) then
		level = ...
		if level == 10 then
			self:Enable()
			self.fill:SetAlpha(1)
			self.icon:SetAlpha(1)
			self.cover:SetAlpha(1)
		end
	end
end

local function InitMicroMenuScripts()
	new_MMenu1:SetScript("OnClick", function() ToggleCharacter("PaperDollFrame") end)
	new_MMenu2:SetScript("OnClick", function() ToggleSpellBook(BOOKTYPE_SPELL) end)
	new_MMenu3:SetScript("OnClick", ToggleTalentFrame)
	new_MMenu4:SetScript("OnClick", function() ToggleAchievementFrame() end)
	new_MMenu5:SetScript("OnClick", function() ToggleFrame(QuestLogFrame) end)
	new_MMenu6:SetScript("OnClick", function() ToggleGuildFrame() end)
	new_MMenu7:SetScript("OnClick", function() TogglePVPFrame() end)
	new_MMenu8:SetScript("OnClick", function() ToggleLFDParentFrame() end)
	new_MMenu9:SetScript("OnClick", function() TogglePetJournal() end)
	new_MMenu10:SetScript("OnClick", function() ToggleEncounterJournal() end)
	new_MMenu11:SetScript("OnClick", mainmenu_click)
	new_MMenu12:SetScript("OnClick", ToggleHelpFrame)
	for i = 1, 12 do
		_G["new_MMenu"..i]:SetScript("OnEnter", any_enter)
		_G["new_MMenu"..i]:SetScript("OnLeave", any_leave)
		_G["new_MMenu"..i]:SetScript("OnEvent", any_event)
	end
end

local function InitMicroMenuParameters()
	for i = 1, 12 do
		CreateMicroMenuButtons(i)
		SetMicroMenuPosition(i)
		SetMicroMenuStyle(i)
	end	

	InitMicroMenuScripts()

	if UnitLevel("player") < 10 then
		new_MMenu3:Disable()
		new_MMenu3.fill:SetAlpha(0)
		new_MMenu3.icon:SetAlpha(0)
		new_MMenu3.cover:SetAlpha(0)

		new_MMenu7:Disable()
		new_MMenu7.fill:SetAlpha(0)
		new_MMenu7.icon:SetAlpha(0)
		new_MMenu7.cover:SetAlpha(0)

		new_MMenu8:Disable()
		new_MMenu8.fill:SetAlpha(0)
		new_MMenu8.icon:SetAlpha(0)
		new_MMenu8.cover:SetAlpha(0)
	else
		new_MMenu3:UnregisterEvent("PLAYER_LEVEL_UP")
		new_MMenu7:UnregisterEvent("PLAYER_LEVEL_UP")
		new_MMenu8:UnregisterEvent("PLAYER_LEVEL_UP")
	end

	TalentMicroButtonAlert:SetPoint("BOTTOM", "new_MMenu3", "TOP", 0, 12)
	CompanionsMicroButtonAlert:SetPoint("BOTTOM", "new_MMenu9", "TOP", 0, 12)

	if not AchievementMicroButton_Update then
		AchievementMicroButton_Update = function() return end
	end

	for _, f in pairs(MICRO_BUTTONS) do
		_G[f]:UnregisterAllEvents()
		_G[f]:EnableMouse(false)
		_G[f]:ClearAllPoints()
		_G[f]:Hide()
	end
end

mmenu_module:SetScript("OnEvent", function(self, event,...)
	if event == "PLAYER_LOGIN" then
		InitMicroMenuParameters()
	end
end)

mmenu_module:RegisterEvent("PLAYER_LOGIN")