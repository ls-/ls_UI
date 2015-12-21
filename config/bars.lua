local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D
local CFG = E:GetModule("Config")
local B = E:GetModule("Bars")

local BAR_NAMES = {
	[1] = "Main Action Bar",
	[2] = "Bottom Bar 1",
	[3] = "Bottom Bar 2",
	[4] = "Side Bar Left",
	[5] = "Side Bar Right",
	[6] = "Pet Action Bar",
	[7] = "Stance Bar",
}

local BARS = {
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
	if InCombatLockdown() then
		self.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	self.StatusLog:SetText("")

	CFG:ToggleDependantControls(self.BarsToggle)
	CFG:ToggleDependantControls(self.ModeToggle)
end

local function LSBarsToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())

		parent.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	if not self:GetChecked() then
		msg = "|cff26a526Success!|r Bar module will be disabled on next UI reload."
	else
		if B:IsEnabled() then
			msg = "|cffe56619Warning!|r Bar module is already enabled."
		else
			msg = "|cff26a526Success!|r Bar module will be enabled on next UI reload."
		end
	end

	CFG:ToggleDependantControls(self)

	parent.StatusLog:SetText(msg)
end

local function BarOptions_Refresh(oldIndex, newIndex)
	local config = C.bars[oldIndex]
	local settings = LSBarsConfigPanel.settings.bars[oldIndex]

	E:ApplySettings(settings, config)

	wipe(settings)

	config = C.bars[newIndex]
	settings = LSBarsConfigPanel.settings.bars[newIndex]

	settings.button_size = LSBarsConfigPanel.ButtonSizeSlider
	settings.button_gap = LSBarsConfigPanel.ButtonSpacingSlider
	settings.direction = LSBarsConfigPanel.GrowthDirectionDropDownMenu

	E:FetchSettings(settings, config)

	LSBarsConfigPanel.GrowthDirectionDropDownMenu:RefreshValue()
end

local function BarSelectorDropDown_OnClick(self)
	local oldValue = self.owner:GetValue()

	self.owner:SetValue(self.value)

	BarOptions_Refresh(oldValue, self.value)
end

local function BarSelectorDropDown_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()

	for i = 1, 7 do
		info.text = BAR_NAMES[i]
		info.func = BarSelectorDropDown_OnClick
		info.value = "bar"..i
		info.owner = self
		info.checked = nil
		UIDropDownMenu_AddButton(info)
	end

	info.text = "Bag Bar"
	info.func = BarSelectorDropDown_OnClick
	info.value = "bags"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end

local function RestrictedBarSelectorDropDown_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()

	for i = 2, 7 do
		info.text = BAR_NAMES[i]
		info.func = BarSelectorDropDown_OnClick
		info.value = "bar"..i
		info.owner = self
		info.checked = nil
		UIDropDownMenu_AddButton(info)
	end
end

local function ModeToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())
	end

	if not self:GetChecked() then
		msg = "|cff26a526Success!|r Restricted mode will be disabled on next UI reload."
	else
		if B:IsInRestrictedMode() then
			msg = "|cffe56619Warning!|r Restricted mode is already enabled."
		else
			msg = "|cff26a526Success!|r Restricted mode will be enabled on next UI reload."
		end
	end

	CFG:ToggleDependantControls(self)

	parent.BarSelectorDropDown.initialize = self:GetChecked() and RestrictedBarSelectorDropDown_Initialize or BarSelectorDropDown_Initialize
	parent.BarSelectorDropDown:RefreshValue()

	BarOptions_Refresh(parent.BarSelectorDropDown.oldValue, parent.BarSelectorDropDown.value)

	parent.StatusLog:SetText(msg)
end

function ButtonMacroNameToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())

		parent.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	if not self:GetChecked() then
		result, msg = B:HideMacroNameText()
	else
		result, msg = B:ShowMacroNameText()
	end

	parent.StatusLog:SetText(msg)
end

function ButtonHotKeyToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())

		parent.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	if not self:GetChecked() then
		result, msg = B:HideHotKeyText()
	else
		result, msg = B:ShowHotKeyText()
	end

	parent.StatusLog:SetText(msg)
end

local function LSBagsToggle_OnClickHook(self)
	local result, msg
	local parent = self:GetParent()

	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())

		parent.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	if not self:GetChecked() then
		msg = "|cff26a526Success!|r Bag sub-module will be disabled on next UI reload."
	else
		result, msg = B:EnableBags()
	end

	parent.StatusLog:SetText(msg)
end

local function GrowthDirectionDropDownMenu_OnClick(self)
	self.owner:SetValue(self.value)
end

local function GrowthDirectionDropDownMenu_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Right"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "RIGHT"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)

	info.text = "Left"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "LEFT"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)

	info.text = "Up"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "UP"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)

	info.text = "Down"
	info.func = GrowthDirectionDropDownMenu_OnClick
	info.value = "DOWN"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end

local function BarSelectorApplyButton_OnClick(self)
	local parent = self:GetParent()

	if InCombatLockdown() then
		parent.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	local bar = parent.BarSelectorDropDown:GetValue()
	local growthDirection = parent.GrowthDirectionDropDownMenu:GetValue()
	local gap = parent.ButtonSpacingSlider:GetValue()
	local size = parent.ButtonSizeSlider:GetValue()

	for _, v in next, BARS[bar] do
		E:UpdateBarLayout(_G[v], size, gap, growthDirection)
		E:UpdateMoverSize(_G[v])
	end

	E:ApplySettings(parent.settings.bars[bar], C.bars[bar])
end

function CFG:B_Initialize()
	local panel = CreateFrame("Frame", "LSBarsConfigPanel", InterfaceOptionsFramePanelContainer)
	panel.name = "Bars"
	panel.parent = "oUF: |cff1a9fc0LS|r"
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

	local modeToggle = CFG:CreateCheckButton(panel, "BarModeToggle", "Restricted mode", "Enables main action bar artwork, animations\nand dynamic resizing.\n\n|cffe52626You won't be able to move micro menu,\nmain action and bag bars around!|r")
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

	local divider1 = CFG:CreateDivider(panel, "Button Options")
	divider1:SetPoint("TOP", nameToggle, "BOTTOM", 0, -8)

	local barSelector = CFG:CreateDropDownMenu(panel, "BarSelectorDropDown", nil, C.bars.restricted and RestrictedBarSelectorDropDown_Initialize or BarSelectorDropDown_Initialize)
	barSelector:SetPoint("TOPLEFT", divider1, "BOTTOMLEFT", -11, -12)
	barSelector:SetValue(C.bars.restricted and "bar2" or "bar1")
	panel.BarSelectorDropDown = barSelector
	CFG:SetupControlDependency(barsToggle, barSelector)

	local applyButton = CreateFrame("Button", "BarSelectorApplyButton", panel, "UIPanelButtonTemplate")
	applyButton.type = "Button"
	applyButton:SetSize(82, 22)
	applyButton:SetText(APPLY)
	applyButton:SetPoint("LEFT", _G[barSelector:GetName().."Right"], "RIGHT", -14, 2)
	applyButton:SetScript("OnClick", BarSelectorApplyButton_OnClick)
	panel.BarSelectorApplyButton = applyButton
	CFG:SetupControlDependency(barsToggle, applyButton)

	local barOptionsBG = panel:CreateTexture("$parentBarOptionBG", "BACKGROUND")
	barOptionsBG:SetTexture(0.3, 0.3, 0.3, 0.3)
	barOptionsBG:SetSize(192, 144)
	barOptionsBG:SetPoint("TOP", barSelector, "BOTTOM", 0, -8)
	barOptionsBG:SetPoint("LEFT", barSelector, "LEFT", 19, 0)
	barOptionsBG:SetPoint("RIGHT", applyButton, "RIGHT", -2, 0)

	local buttonSizeSlider = CFG:CreateSlider(panel, "$parentButtonSizeSlider", "Button size", 24, 48)
	buttonSizeSlider:SetPoint("TOPLEFT", barOptionsBG, "TOPLEFT", 16, -16)
	panel.ButtonSizeSlider = buttonSizeSlider
	panel.settings.bars.bar2.button_size = buttonSizeSlider
	CFG:SetupControlDependency(barsToggle, buttonSizeSlider)

	local buttonSpacingSlider = CFG:CreateSlider(panel, "$parentButtonSpacingSlider", "Button spacing", 2, 12)
	buttonSpacingSlider:SetPoint("TOPLEFT", buttonSizeSlider, "BOTTOMLEFT", 0, -25)
	panel.ButtonSpacingSlider = buttonSpacingSlider
	panel.settings.bars.bar2.button_gap = buttonSpacingSlider
	CFG:SetupControlDependency(barsToggle, buttonSpacingSlider)

	local growthDropdown = CFG:CreateDropDownMenu(panel, "DirectionDropDown", "Growth direction", GrowthDirectionDropDownMenu_Initialize)
	growthDropdown:SetPoint("TOPLEFT", buttonSpacingSlider, "BOTTOMLEFT", -18, -32)
	panel.GrowthDirectionDropDownMenu = growthDropdown
	panel.settings.bars.bar2.direction = growthDropdown
	CFG:SetupControlDependency(barsToggle, growthDropdown)

	local divider2 = CFG:CreateDivider(panel, "Additional Features")
	divider2:SetPoint("TOP", barOptionsBG, "BOTTOM", 0, -8)

	local bagsToggle = CFG:CreateCheckButton(panel, "BagsToggle", "Bags")
	bagsToggle:SetPoint("TOPLEFT", divider2, "BOTTOMLEFT", 16, -8)
	bagsToggle:HookScript("OnClick", LSBagsToggle_OnClickHook)
	panel.settings.bars.bags.enabled = bagsToggle
	CFG:SetupControlDependency(barsToggle, bagsToggle)

	local log1 = CFG:CreateTextLabel(panel, 10, "")
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	panel.StatusLog = log1

	local reloadButton = CFG:CreateReloadUIButton(panel)
	reloadButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)

	CFG:AddCatergory(panel)
end
