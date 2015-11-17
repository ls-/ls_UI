local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D
local CFG = E:GetModule("Config")
local AT = E:GetModule("AuraTracker")

local FauxScrollFrame_Update, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_SetOffset, FauxScrollFrame_GetOffset =
	FauxScrollFrame_Update, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_SetOffset, FauxScrollFrame_GetOffset
local PanelTemplates_SetNumTabs, PanelTemplates_Tab_OnClick, PanelTemplates_SetTab, PanelTemplates_TabResize =
	PanelTemplates_SetNumTabs, PanelTemplates_Tab_OnClick, PanelTemplates_SetTab, PanelTemplates_TabResize
local tostring, tonumber, tinsert = tostring, tonumber, tinsert

local function AuraList_Update(frame)
	if not frame.buttons then return end

	local tab = frame.selectedTab
	local buttons = frame.buttons
	local button, value
	local offset = FauxScrollFrame_GetOffset(frame)
	local spec = AT.Spec or tostring(GetSpecialization() or 0)
	local bufftable = C.auratracker[spec]["HELPFUL"]
	local debufftable = C.auratracker[spec]["HARMFUL"]

	for i = 1, #buttons do
		button = buttons[i]

		button:Hide()
		button.Text:SetText("")
		button.Icon:SetTexture("")
		button.spellID = nil
		button:SetChecked(false)
	end

	frame.BuffTab:SetText("Buffs ("..#bufftable..")")
	PanelTemplates_TabResize(frame.BuffTab, 0)

	frame.DebuffTab:SetText("Debuffs ("..#debufftable..")")
	PanelTemplates_TabResize(frame.DebuffTab, 0)

	if #bufftable + #debufftable >= 12 then
		frame.AddEditBox:Disable()
		frame.AddButton:Disable()
	else
		frame.AddEditBox:Enable()
		frame.AddButton:Enable()
	end

	if tab == 1  then
		frame.filter = "HELPFUL"
		local total = 0

		for i = 1, 8 do
			value = bufftable[i + offset]
			button = buttons[i]

			if value then
				local name, _, icon = GetSpellInfo(value)
				button:Show()
				button.Text:SetText(name)
				button.Icon:SetTexture(icon)
				button.spellID = value

				total = total + 1
			end
		end

		FauxScrollFrame_Update(frame, #bufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
	else
		frame.filter = "HARMFUL"
		local total = 0

		for i = 1, 8 do
			value = debufftable[i + offset]
			button = buttons[i]

			if value then
				local name, _, icon = GetSpellInfo(value)
				button:Show()
				button.Text:SetText(name)
				button.Icon:SetTexture(icon)
				button.spellID = value

				total = total + 1
			end
		end

		FauxScrollFrame_Update(frame, #debufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
	end

end

local function ATConfigPanel_OnShow(self)
	if InCombatLockdown() then
		self.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	AuraList_Update(self.AuraList)

	self.StatusLog:SetText("")

	CFG.ToggleDependantControls(self.ATToggle, not AT:IsRunning())
end

local function AuraListTab_OnClick(self)
	local auraList = self:GetParent()

	FauxScrollFrame_SetOffset(auraList, 0)

	PanelTemplates_Tab_OnClick(self, auraList)

	AuraList_Update(auraList)
end

local function AuraList_AddAura(self)
	local auraList = self:GetParent()
	local spellID = auraList.AddEditBox:GetText()

	if spellID and spellID ~= "" then
		local result, msg = AT:AddToList(auraList.filter, tonumber(spellID))

		auraList:GetParent().StatusLog:SetText(msg)

		if result then
			auraList.AddEditBox:SetText("")
			auraList.AddEditBox:ClearFocus()

			AuraList_Update(auraList)
		end
	end
end

local function AuraList_DeleteAura(self, ...)
	local auraList = self:GetParent()
	local buttons = auraList.buttons
	local offset = FauxScrollFrame_GetOffset(auraList)

	for i =1, #buttons do
		local button = buttons[i]

		if button:IsVisible() and button:GetChecked() then
			local _, msg = AT:RemoveFromList(auraList.filter, button.spellID)

			auraList:GetParent().StatusLog:SetText(msg)
		end
	end

	if offset > 0 then
		FauxScrollFrame_SetOffset(auraList, offset - 1)
	end

	AuraList_Update(auraList)
end

local function AuraList_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 30, AuraList_Update)
end

local function AuraButton_OnEnter(self)
	if not self.spellID then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetSpellByID(self.spellID)
	GameTooltip:Show()
end

local function AuraButton_OnLeave(self)
	GameTooltip:Hide()
end

local function LockToggle_OnClick(self)
	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())
		self:GetParent().StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")
		return
	end

	if not self:GetChecked() then
		AT.Header:Show()
	else
		AT.Header:Hide()
	end
end

local function ATToggle_OnClick(self)
	local result, msg
	local parent = self:GetParent()

	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())
	end

	if not self:GetChecked() then
		result, msg = AT:Disable()
	else
		result, msg = AT:Enable()
	end

	CFG.ToggleDependantControls(self, not AT:IsRunning())

	parent.StatusLog:SetText(msg)
end

function CFG:AT_Initialize()
	local panel = CreateFrame("Frame", "LSATConfigPanel", InterfaceOptionsFramePanelContainer)
	panel.name = "Aura Tracker"
	panel.parent = "oUF: |cff1a9fc0LS|r"
	panel:HookScript("OnShow", ATConfigPanel_OnShow)
	panel:Hide()

	panel.settings = {
		auratracker = {},
	}

	local header1 = CFG:CreateTextLabel(panel, 16, "|cffffd100Aura Tracker|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local atToggle = CFG:CreateCheckButton(panel, "ATToggle", nil, "Switches aura tracker module on or off")
	atToggle:HookScript("OnClick", ATToggle_OnClick)
	atToggle:SetPoint("TOPRIGHT", -16, -14)
	panel.ATToggle = atToggle
	panel.settings.auratracker.enabled = atToggle

	local infoText1 = CFG:CreateTextLabel(panel, 10, "These options allow you to setup player aura tracking. |cffffd100You can track up to 12 auras at once.|r\nWhilst in combat, please, use |cffffd100/atbuff|r and |cffffd100/atdebuff|r commands to add auras to the list.")
	infoText1:SetHeight(32)
	infoText1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)
	infoText1:SetPoint("RIGHT", -16, 0)

	local log1 = CFG:CreateTextLabel(panel, 10, "")
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	panel.StatusLog = log1

	local auraList = CreateFrame("ScrollFrame", "ATAuraList", panel, "FauxScrollFrameTemplate")
	auraList:SetSize(210, 266) -- 30 * 8 + 6 * 2 + 7 * 2
	auraList:SetPoint("TOPLEFT", infoText1, "BOTTOMLEFT", 0, -40) -- 8 + 32 (default offset + tab height)
	auraList:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, tileSize = 0,
		edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	auraList:SetBackdropColor(0, 0, 0, 1)
	auraList:SetBackdropBorderColor(0.6, 0.6, 0.6)
	auraList:SetScript("OnVerticalScroll", AuraList_OnVerticalScroll)
	panel.AuraList = auraList

	local scrollbar = auraList.ScrollBar
	scrollbar:ClearAllPoints()
	scrollbar:SetPoint("TOPRIGHT", auraList,"TOPRIGHT", -6, -22)
	scrollbar:SetPoint("BOTTOMRIGHT", auraList,"BOTTOMRIGHT", -6, 22)

	auraList.buttons = {}

	for i = 1, 8 do
		local button = CreateFrame("CheckButton", auraList:GetName().."Button"..i, auraList)
		button.type = "Button"
		button:SetHeight(30)
		button:EnableMouse(true)
		button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
		button:SetCheckedTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
		button:GetCheckedTexture():SetVertexColor(0.9, 0.5, 0,1)
		button:SetScript("OnEnter", AuraButton_OnEnter)
		button:SetScript("OnLeave", AuraButton_OnLeave)
		tinsert(auraList.buttons, button)

		local iconholder = CreateFrame("Frame", nil, button)
		iconholder:SetSize(24, 24)
		iconholder:SetPoint("LEFT", 8, 0)
		E:CreateBorder(iconholder, 8)

		local icon = iconholder:CreateTexture()
		E:TweakIcon(icon)
		button.Icon = icon

		local text = button:CreateFontString(nil, "ARTWORK", "LS12Font")
		text:SetJustifyH("LEFT")
		text:SetMaxLines(2)
		text:SetPoint("LEFT", iconholder, "RIGHT", 4, 0)
		text:SetPoint("RIGHT", button, "RIGHT", -4, 0)
		button.Text = text

		if i == 1 then
			button:SetPoint("TOPLEFT", 0, -6)
		else
			button:SetPoint("TOPLEFT", auraList.buttons[i-1], "BOTTOMLEFT", 0, -2)
		end

		button:SetPoint("RIGHT", scrollbar, "LEFT", 0, -6)

		CFG:SetupControlDependency(atToggle, button)
	end

	local buffTab = CreateFrame("Button", "ATAuraListTab1", auraList, "TabButtonTemplate")
	buffTab.type = "Button"
	buffTab:SetID(1)
	buffTab:SetPoint("BOTTOMLEFT", auraList, "TOPLEFT", 8, -2)
	buffTab:SetScript("OnClick", AuraListTab_OnClick)
	auraList.BuffTab = buffTab
	CFG:SetupControlDependency(atToggle, buffTab)

	print(buffTab:GetHeight())

	local debuffTab = CreateFrame("Button", "ATAuraListTab2", auraList, "TabButtonTemplate")
	debuffTab.type = "Button"
	debuffTab:SetID(2)
	debuffTab:SetPoint("LEFT", buffTab, "RIGHT", 0, 0)
	debuffTab:SetScript("OnClick", AuraListTab_OnClick)
	auraList.DebuffTab = debuffTab
	CFG:SetupControlDependency(atToggle, debuffTab)

	local addEditBox = CreateFrame("EditBox", "ATAuraListEditBox", auraList, "InputBoxInstructionsTemplate")
	addEditBox.type = "EditBox"
	addEditBox:SetSize(120, 22)
	addEditBox:SetAutoFocus(false)
	addEditBox:SetNumeric(true)
	addEditBox.Instructions:SetText("Enter Spell ID")
	addEditBox:SetPoint("TOPLEFT", auraList, "BOTTOMLEFT", 6, 0)
	addEditBox:SetScript("OnEnterPressed", AuraList_AddAura)
	CFG:SetupControlDependency(atToggle, addEditBox)
	auraList.AddEditBox = addEditBox

	local addButton = CreateFrame("Button", "ATAuraListAddButton", auraList, "UIPanelButtonTemplate")
	addButton.type = "Button"
	addButton:SetSize(82, 22)
	addButton:SetText(ADD)
	addButton:SetPoint("LEFT", addEditBox, "RIGHT", 2, 0)
	addButton:SetScript("OnClick", AuraList_AddAura)
	auraList.AddButton = addButton
	CFG:SetupControlDependency(atToggle, addButton)

	local delButton = CreateFrame("Button", "ATAuraListDeleteButton", auraList, "UIPanelButtonTemplate")
	delButton.type = "Button"
	delButton:SetSize(64, 22)
	delButton:SetText(DELETE)
	delButton:SetPoint("TOP", addEditBox, "BOTTOM", 0, -4)
	delButton:SetPoint("RIGHT", auraList, "RIGHT", 0, 0)
	delButton:SetPoint("LEFT", auraList, "LEFT", 0, 0)
	delButton:SetScript("OnClick", AuraList_DeleteAura)
	auraList.DeleteButton = delButton
	CFG:SetupControlDependency(atToggle, delButton)

	PanelTemplates_SetNumTabs(auraList, 2)
	PanelTemplates_SetTab(auraList, 1)

	local lockToggle = CFG:CreateCheckButton(panel, "MovementToggle", LOCK_FRAME)
	lockToggle:SetPoint("TOPLEFT", delButton, "BOTTOMLEFT", -2, -8)
	lockToggle:HookScript("OnClick", LockToggle_OnClick)
	panel.settings.auratracker.locked = lockToggle
	CFG:SetupControlDependency(atToggle, lockToggle)

	local growthDropdown = CFG:CreateDropDownMenu(panel, "DirectionDropDown", "Growth direction", "GrowthDirectionDropDownMenu_Initialize")
	growthDropdown:SetPoint("TOPLEFT", lockToggle, "BOTTOMLEFT", -11, -24)
	panel.GrowthDirectionDropDownMenu = growthDropdown
	panel.settings.auratracker.direction = growthDropdown
	CFG:SetupControlDependency(atToggle, growthDropdown)

	panel.okay = function() CFG:OptionsPanelOkay(panel) end
	panel.cancel = function() CFG:OptionsPanelOkay(panel) end
	panel.refresh = function() CFG:OptionsPanelRefresh(panel) end
	panel.default = function() CFG:OptionsPanelDefault(panel) end

	InterfaceOptions_AddCategory(panel)
end
