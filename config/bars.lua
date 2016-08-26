local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D
local CFG = E:GetModule("Config")
local BARS = E:GetModule("Bars")

-- Lua
local _G = _G

-- Mine
local SUCCESS_TEXT = "|cff26a526Success!|r "
local WARNING_TEXT = "|cffffd100Warning!|r "
local ERROR_TEXT = "|cffe52626Error!|r "
local panel

local BAR_NAMES = {
	[1] = "Main Action Bar",
	[2] = "Action Bar 1",
	[3] = "Action Bar 2",
	[4] = "Action Bar 3",
	[5] = "Action Bar 4",
	[6] = "Pet Action Bar",
	[7] = "Stance Bar",
}

local BAR_GROUPS = {
	bar1 = {"LSMainMenuBar", "LSPetBattleBar"},
	bar2 = {"LSMultiBarBottomLeftBar"},
	bar3 = {"LSMultiBarBottomRightBar"},
	bar4 = {"LSMultiBarLeftBar"},
	bar5 = {"LSMultiBarRightBar"},
	bar6 = {"LSPetActionBar"},
	bar7 = {"LSStanceBar"},
	bags = {"LSBagBar"},
}

local function LSBarsConfigPanel_OnShow(self)
	if _G.InCombatLockdown() then
		self.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	self.StatusLog:SetText("")

	CFG:ToggleDependantControls(self.BarsToggle)
end

local function LSBarsToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if _G.InCombatLockdown() then
		self:SetChecked(not self:GetChecked())

		parent.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	if not self:GetChecked() then
		msg = "|cff26a526Success!|r Bar module will be disabled on next UI reload."
	else
		if BARS:IsEnabled() then
			msg = "|cffe56619Warning!|r Bar module is already enabled."
		else
			msg = "|cff26a526Success!|r Bar module will be enabled on next UI reload."
		end
	end

	parent.StatusLog:SetText(msg)
end

----------
-- BARS --
----------

local function BarToggle_OnClick(self)
	local checked = self:GetValue()

	local result, name, state = BARS:ToggleBar(self.bar, checked and "Show" or "Hide")

	-- XXX: Makes more sense for a user
	name = self.Text:GetText()

	if result then
		panel.StatusLog:SetText(SUCCESS_TEXT..name.." is "..(state and "shown" or "hidden").." now.")
	else
		panel.StatusLog:SetText(WARNING_TEXT..name.." will be "..(state and "shown" or "hidden")..", when you leave combat.")
	end
end

-------------
-- BUTTONS --
-------------

local function ButtonsOptions_Refresh(oldIndex, newIndex)
	local config = C.bars[oldIndex]
	local settings = panel.settings.bars[oldIndex]

	E:ApplySettings(settings, config)

	wipe(settings)

	config = C.bars[newIndex]
	settings = panel.settings.bars[newIndex]

	settings.button_size = panel.ButtonSizeSlider
	settings.button_gap = panel.ButtonSpacingSlider
	settings.direction = panel.GrowthDirectionDropDownMenu

	E:FetchSettings(settings, config)

	panel.GrowthDirectionDropDownMenu:RefreshValue()
end

local function BarSelectorDropDown_OnClick(self)
	local oldValue = self.owner:GetValue()

	self.owner:SetValue(self.value)

	ButtonsOptions_Refresh(oldValue, self.value)
end

local function BarSelectorDropDown_Initialize(self, ...)
	local info = _G.UIDropDownMenu_CreateInfo()

	for i = 1, 7 do
		info.text = BAR_NAMES[i]
		info.func = BarSelectorDropDown_OnClick
		info.value = "bar"..i
		info.owner = self
		info.checked = nil
		_G.UIDropDownMenu_AddButton(info)
	end

	info.text = "Bag Bar"
	info.func = BarSelectorDropDown_OnClick
	info.value = "bags"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)
end

local function RestrictedBarSelectorDropDown_Initialize(self, ...)
	local info = _G.UIDropDownMenu_CreateInfo()

	for i = 2, 7 do
		info.text = BAR_NAMES[i]
		info.func = BarSelectorDropDown_OnClick
		info.value = "bar"..i
		info.owner = self
		info.checked = nil
		_G.UIDropDownMenu_AddButton(info)
	end
end

local function ModeToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if _G.InCombatLockdown() then
		self:SetChecked(not self:GetChecked())
	end

	if not self:GetChecked() then
		msg = "|cff26a526Success!|r Restricted mode will be disabled on next UI reload."
	else
		if BARS:IsInRestrictedMode() then
			msg = "|cffe56619Warning!|r Restricted mode is already enabled."
		else
			msg = "|cff26a526Success!|r Restricted mode will be enabled on next UI reload."
		end
	end

	parent.BarSelectorDropDown.initialize = self:GetChecked() and RestrictedBarSelectorDropDown_Initialize or BarSelectorDropDown_Initialize
	parent.BarSelectorDropDown:RefreshValue()

	ButtonsOptions_Refresh(parent.BarSelectorDropDown.oldValue, parent.BarSelectorDropDown.value)

	parent.StatusLog:SetText(msg)
end

local function ButtonMacroNameToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if not self:GetChecked() then
		result, msg = BARS:HideMacroNameText()
	else
		result, msg = BARS:ShowMacroNameText()
	end

	parent.StatusLog:SetText(msg)
end

local function ButtonHotKeyToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if not self:GetChecked() then
		result, msg = BARS:HideHotKeyText()
	else
		result, msg = BARS:ShowHotKeyText()
	end

	parent.StatusLog:SetText(msg)
end

local function LSBagsToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if _G.InCombatLockdown() then
		self:SetChecked(not self:GetChecked())

		parent.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	if not self:GetChecked() then
		msg = "|cff26a526Success!|r Bag sub-module will be disabled on next UI reload."
	else
		result, msg = BARS:EnableBags()
	end

	parent.StatusLog:SetText(msg)
end

local function GrowthDirectionDropDownMenu_OnClick(self)
	self.owner:SetValue(self.value)
end

local function GrowthDirectionDropDownMenu_Initialize(self, ...)
	local info = _G.UIDropDownMenu_CreateInfo()
	info.text = "Right"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "RIGHT"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)

	info.text = "Left"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "LEFT"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)

	info.text = "Up"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "UP"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)

	info.text = "Down"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "DOWN"
	info.owner = self
	info.checked = nil
	_G.UIDropDownMenu_AddButton(info)
end

local function BarSelectorApplyButton_OnClick(self)
	local parent = self:GetParent()

	if _G.InCombatLockdown() then
		parent.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	local bar = parent.BarSelectorDropDown:GetValue()
	local growthDirection = parent.GrowthDirectionDropDownMenu:GetValue()
	local gap = parent.ButtonSpacingSlider:GetValue()
	local size = parent.ButtonSizeSlider:GetValue()

	for _, v in next, BAR_GROUPS[bar] do
		E:UpdateBarLayout(_G[v], size, gap, growthDirection)
		E:UpdateMoverSize(_G[v])
	end

	E:ApplySettings(parent.settings.bars[bar], C.bars[bar])
end

local function OpenBarConfigPanel(self)
	InterfaceOptionsFrame_OpenToCategory(panel)
end

function CFG:B_Initialize()
	panel = _G.CreateFrame("Frame", "LSBarsConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = "Bars"
	panel.parent = "|cff1a9fc0ls:|r UI"
	panel:HookScript("OnShow", LSBarsConfigPanel_OnShow)
	panel:Hide()

	panel.settings = {
		bars = {
			bar1 = {},
			bar2 = {},
			bar3 = {},
			bar4 = {},
			bar5 = {},
			bar6 = {},
			bar7 = {},
			extra = {},
			vehicle = {},
			micromenu = {},
			bags = {},
		},
	}

	local header1 = CFG:CreateTextLabel(panel, 16, "|cffffd100Bars|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local barsToggle = CFG:CreateCheckButton(panel, "BarsToggle", nil, "Switches bars module on or off")
	barsToggle:HookScript("OnClick", LSBarsToggle_OnClickHook)
	barsToggle:SetPoint("TOPRIGHT", -16, -14)
	panel.BarsToggle = barsToggle
	panel.settings.bars.enabled = barsToggle
	CFG:SetupController(panel, barsToggle)

	local modeToggle = CFG:CreateCheckButton(panel, "BarModeToggle", "Restricted mode", "Enables main action bar artwork, animations and dynamic resizing.\n\n|cffe52626You won't be able to move micro menu, main action and bag bars around!|r")
	modeToggle:SetPoint("RIGHT", barsToggle, "LEFT", -8, 0)
	modeToggle.Text:ClearAllPoints()
	modeToggle.Text:SetPoint("RIGHT", modeToggle, "LEFT", -2, 1)
	modeToggle:HookScript("OnClick", ModeToggle_OnClickHook)
	panel.ModeToggle = modeToggle
	panel.settings.bars.restricted = modeToggle
	CFG:SetupControlDependency(barsToggle, modeToggle)

	local infoText1 = CFG:CreateTextLabel(panel, 10, "Action bars, bags and stuff.")
	infoText1:SetHeight(32)
	infoText1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	local nameToggle = CFG:CreateCheckButton(panel, "ButtonMacroNameToggle", "Macro text")
	nameToggle:SetPoint("TOPLEFT", infoText1, "BOTTOMLEFT", -2, -8)
	nameToggle:HookScript("OnClick", ButtonMacroNameToggle_OnClickHook)
	panel.settings.bars.show_name = nameToggle
	CFG:SetupControlDependency(barsToggle, nameToggle)

	local hotkeyToggle = CFG:CreateCheckButton(panel, "ButtonHotKeyToggle", "Binding text")
	hotkeyToggle:SetPoint("LEFT", nameToggle, "RIGHT", 110, 0)
	hotkeyToggle:HookScript("OnClick", ButtonHotKeyToggle_OnClickHook)
	panel.settings.bars.show_hotkey = hotkeyToggle
	CFG:SetupControlDependency(barsToggle, hotkeyToggle)

	local divider = CFG:CreateDivider(panel, "Bars")
	divider:SetPoint("TOP", nameToggle, "BOTTOM", 0, -12)

	local button1 = CFG:CreateCheckButton(panel, "ActionBar1Toggle", "Action Bar 1", "Default ".._G.SHOW_MULTIBAR1_TEXT..".")
	button1:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 4, -8)
	button1:HookScript("OnClick", BarToggle_OnClick)
	button1.bar = "LSMultiBarBottomLeftBar"
	panel.settings.bars.bar2.enabled = button1
	CFG:SetupControlDependency(barsToggle, button1)

	local button2 = CFG:CreateCheckButton(panel, "ActionBar2Toggle", "Action Bar 2", "Default ".._G.SHOW_MULTIBAR2_TEXT..".")
	button2:SetPoint("LEFT", button1, "RIGHT", 110, 0)
	button2:HookScript("OnClick", BarToggle_OnClick)
	button2.bar = "LSMultiBarBottomRightBar"
	panel.settings.bars.bar3.enabled = button2
	CFG:SetupControlDependency(barsToggle, button2)

	local button3 = CFG:CreateCheckButton(panel, "ActionBar3Toggle", "Action Bar 3", "Default ".._G.SHOW_MULTIBAR3_TEXT..".")
	button3:SetPoint("LEFT", button2, "RIGHT", 110, 0)
	button3:HookScript("OnClick", BarToggle_OnClick)
	button3.bar = "LSMultiBarLeftBar"
	panel.settings.bars.bar4.enabled = button3
	CFG:SetupControlDependency(barsToggle, button3)

	local button4 = CFG:CreateCheckButton(panel, "ActionBar4Toggle", "Action Bar 4", "Default ".._G.SHOW_MULTIBAR4_TEXT..".")
	button4:SetPoint("LEFT", button3, "RIGHT", 110, 0)
	button4:HookScript("OnClick", BarToggle_OnClick)
	button4.bar = "LSMultiBarRightBar"
	panel.settings.bars.bar5.enabled = button4
	CFG:SetupControlDependency(barsToggle, button4)

	local button5 = CFG:CreateCheckButton(panel, "PetBarToggle", "Pet Action Bar")
	button5:SetPoint("TOPLEFT", button1, "BOTTOMLEFT", 0, -8)
	button5:HookScript("OnClick", BarToggle_OnClick)
	button5.bar = "LSPetActionBar"
	panel.settings.bars.bar6.enabled = button5
	CFG:SetupControlDependency(barsToggle, button5)

	local button6 = CFG:CreateCheckButton(panel, "StanceBarToggle", "Stance Bar")
	button6:SetPoint("LEFT", button5, "RIGHT", 110, 0)
	button6:HookScript("OnClick", BarToggle_OnClick)
	button6.bar = "LSStanceBar"
	panel.settings.bars.bar7.enabled = button6
	CFG:SetupControlDependency(barsToggle, button6)

	divider = CFG:CreateDivider(panel, "Buttons")
	divider:SetPoint("TOP", button5, "BOTTOM", 0, -12)

	local barSelector = CFG:CreateDropDownMenu(panel, "BarSelectorDropDown", nil, C.bars.restricted and RestrictedBarSelectorDropDown_Initialize or BarSelectorDropDown_Initialize)
	barSelector:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", -11, -12)
	barSelector:SetValue(C.bars.restricted and "bar2" or "bar1")
	panel.BarSelectorDropDown = barSelector
	CFG:SetupControlDependency(barsToggle, barSelector)

	local applyButton = _G.CreateFrame("Button", "BarSelectorApplyButton", panel, "UIPanelButtonTemplate")
	applyButton.type = "Button"
	applyButton:SetSize(82, 22)
	applyButton:SetText(_G.APPLY)
	applyButton:SetPoint("LEFT", _G[barSelector:GetName().."Right"], "RIGHT", -14, 2)
	applyButton:SetScript("OnClick", BarSelectorApplyButton_OnClick)
	panel.BarSelectorApplyButton = applyButton
	CFG:SetupControlDependency(barsToggle, applyButton)

	local barOptionsBG = panel:CreateTexture("$parentBarOptionBG", "BACKGROUND")
	barOptionsBG:SetColorTexture(0.3, 0.3, 0.3, 0.3)
	barOptionsBG:SetSize(192, 144)
	barOptionsBG:SetPoint("TOP", barSelector, "BOTTOM", 0, -8)
	barOptionsBG:SetPoint("LEFT", barSelector, "LEFT", 19, 0)
	barOptionsBG:SetPoint("RIGHT", applyButton, "RIGHT", -2, 0)

	local buttonSizeSlider = CFG:CreateSlider(panel, "$parentButtonSizeSlider", "Button size", 2, 24, 48)
	buttonSizeSlider:SetPoint("TOPLEFT", barOptionsBG, "TOPLEFT", 16, -16)
	panel.ButtonSizeSlider = buttonSizeSlider
	panel.settings.bars.bar2.button_size = buttonSizeSlider
	CFG:SetupControlDependency(barsToggle, buttonSizeSlider)

	local buttonSpacingSlider = CFG:CreateSlider(panel, "$parentButtonSpacingSlider", "Button spacing", 2, 2, 12)
	buttonSpacingSlider:SetPoint("TOPLEFT", buttonSizeSlider, "BOTTOMLEFT", 0, -25)
	panel.ButtonSpacingSlider = buttonSpacingSlider
	panel.settings.bars.bar2.button_gap = buttonSpacingSlider
	CFG:SetupControlDependency(barsToggle, buttonSpacingSlider)

	local growthDropdown = CFG:CreateDropDownMenu(panel, "DirectionDropDown", "Growth direction", GrowthDirectionDropDownMenu_Initialize)
	growthDropdown:SetPoint("TOPLEFT", buttonSpacingSlider, "BOTTOMLEFT", -18, -32)
	panel.GrowthDirectionDropDownMenu = growthDropdown
	panel.settings.bars.bar2.direction = growthDropdown
	CFG:SetupControlDependency(barsToggle, growthDropdown)

	divider = CFG:CreateDivider(panel, "Additional Features")
	divider:SetPoint("TOP", barOptionsBG, "BOTTOM", 0, -12)

	local bagsToggle = CFG:CreateCheckButton(panel, "BagsToggle", "Bags")
	bagsToggle:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 16, -8)
	bagsToggle:HookScript("OnClick", LSBagsToggle_OnClickHook)
	panel.settings.bars.bags.enabled = bagsToggle
	CFG:SetupControlDependency(barsToggle, bagsToggle)

	local log1 = CFG:CreateTextLabel(panel, 10, "")
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	panel.StatusLog = log1

	local reloadButton = CFG:CreateReloadUIButton(panel)
	reloadButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)

	CFG:AddCatergory(panel)

	--------------------
	-- BLIZZ SETTINGS --
	--------------------

	_G.SetActionBarToggles(0, 0, 0, 0)
	_G.MultiActionBar_Update()

	_G.InterfaceOptionsActionBarsPanelBottomLeft:SetChecked(true)
	_G.InterfaceOptionsActionBarsPanelBottomLeft:Click()
	_G.InterfaceOptionsActionBarsPanelBottomLeft:Disable()

	_G.InterfaceOptionsActionBarsPanelBottomRight:SetChecked(true)
	_G.InterfaceOptionsActionBarsPanelBottomRight:Click()
	_G.InterfaceOptionsActionBarsPanelBottomRight:Disable()

	_G.InterfaceOptionsActionBarsPanelRightTwo:SetChecked(true)
	_G.InterfaceOptionsActionBarsPanelRightTwo:Click()
	_G.InterfaceOptionsActionBarsPanelRightTwo:Disable()

	_G.InterfaceOptionsActionBarsPanelRight:SetChecked(true)
	_G.InterfaceOptionsActionBarsPanelRight:Click()
	_G.InterfaceOptionsActionBarsPanelRight:Disable()

	local infoButton = CFG:CreateInfoButton(_G.InterfaceOptionsActionBarsPanel, "LSBarsInfo", "To enable or disable additional action bars, please, see |cff1a9fc0ls:|r UI config.")
	infoButton:SetPoint("LEFT", "InterfaceOptionsActionBarsPanelBottomLeftText", "RIGHT", 6, 0)

	local openConfigButtonb = CFG:CreateConfigButton(_G.InterfaceOptionsActionBarsPanel, "OpenLSBarsConfigButton", "Open Config", OpenBarConfigPanel)
	openConfigButtonb:SetPoint("LEFT", infoButton, "RIGHT", 6, 0)
end
