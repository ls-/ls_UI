local _, ns = ...
local E, C, M, D = ns.E, ns.C, ns.M, ns.D
local CFG = E:GetModule("Config")
local UF = E:GetModule("UnitFrames")

local FauxScrollFrame_Update, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_SetOffset, FauxScrollFrame_GetOffset =
	FauxScrollFrame_Update, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_SetOffset, FauxScrollFrame_GetOffset
local PanelTemplates_SetNumTabs, PanelTemplates_Tab_OnClick, PanelTemplates_SetTab, PanelTemplates_TabResize =
	PanelTemplates_SetNumTabs, PanelTemplates_Tab_OnClick, PanelTemplates_SetTab, PanelTemplates_TabResize

local panel
local activeConfig
local sortedAuras = {}

local SUCCESS_TEXT = "|cff26a526Success!|r"
local WARNING_TEXT = "|cffffd100Warning!|r"
local ERROR_TEXT = "|cffe52626Error!|r"

local ENABLED_ICON_INLINE = "|TInterface\\Store\\Services:0:0:0:0:1024:1024:22:41:83:102|t"
local DISABLED_ICON_INLINE = "|TInterface\\Store\\Services:0:0:0:0:1024:1024:1:20:83:102|t"

local function SortAurasByName(a, b)
	return a.name < b.name or (a.name == b.name and a.id < b.id)
end

local function PrepareSortedAuraList(tbl)
	local aura

	wipe(sortedAuras)

	for id, filter in pairs(tbl) do
		local name, _, icon = GetSpellInfo(id)
		if name then
			aura = {
				id = id,
				name = name,
				icon = icon,
				filter = filter,
			}

			tinsert(sortedAuras, aura)
		end
	end

	sort(sortedAuras, SortAurasByName)

	return sortedAuras
end

local function LSUFAuraList_Update(frame)
	if not frame.buttons then return end

	local tab = frame.selectedTab
	local buttons = frame.buttons

	local button
	for i = 1, #buttons do
		button = buttons[i]

		button:Hide()
		button.Text:SetText("")
		button.Icon:SetTexture("")
		button.spellID = nil
		button.value = nil
		button.Bg:Hide()
	end

	if tab == 1  then
		if not activeConfig["HELPFUL"] then
			frame.AddEditBox:Disable()
			frame.AddButton:Disable()
			frame.MaskDial:Disable()
			frame.WipeButton:Disable()
		else
			frame.AddEditBox:Enable()
			frame.AddButton:Enable()
			frame.MaskDial:Enable()
			frame.WipeButton:Enable()

			local bufftable = activeConfig["HELPFUL"].auralist
			local offset = FauxScrollFrame_GetOffset(frame)
			local total = 0

			frame.config = bufftable
			frame.filter = "HELPFUL"

			bufftable = PrepareSortedAuraList(bufftable)

			local aura
			for i = 1, 10 do
				aura = bufftable[i + offset]
				button = buttons[i]

				if aura then
					button:Show()
					button.Text:SetText(aura.name)
					button.Icon:SetTexture(aura.icon)
					button.spellID = aura.id
					button.value = aura.filter

					button.Indicator:SetMask(aura.filter)

					if (i + offset)%2 == 0 then
						button.Bg:Show()
					end

					total = total + 1
				end
			end

			FauxScrollFrame_Update(frame, #bufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
		end
	else
		if not activeConfig["HARMFUL"] then
			frame.AddEditBox:Disable()
			frame.AddButton:Disable()
			frame.MaskDial:Disable()
			frame.WipeButton:Disable()
		else
			frame.AddEditBox:Enable()
			frame.AddButton:Enable()
			frame.MaskDial:Enable()
			frame.WipeButton:Enable()

			local debufftable = activeConfig["HARMFUL"].auralist
			local offset = FauxScrollFrame_GetOffset(frame)
			local total = 0

			frame.config = debufftable
			frame.filter = "HARMFUL"

			debufftable = PrepareSortedAuraList(debufftable)

			local aura
			for i = 1, 10 do
				aura = debufftable[i + offset]
				button = buttons[i]

				if aura then
					button:Show()
					button.Text:SetText(aura.name)
					button.Icon:SetTexture(aura.icon)
					button.spellID = aura.id
					button.value = aura.filter

					button.Indicator:SetMask(aura.filter)

					if (i + offset)%2 == 0 then
						button.Bg:Show()
					end

					total = total + 1
				end
			end

			FauxScrollFrame_Update(frame, #debufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
		end
	end
end

local function AuraList_AddAura(self, ...)
	local log = panel.StatusLog
	local auraList = panel.AuraList
	local spellID = tonumber(auraList.AddEditBox:GetText())

	if spellID and spellID > 2147483647 then return end

	local link = GetSpellLink(spellID)

	if link then
		if auraList.config[spellID] then
			log:SetText(ERROR_TEXT..link.." is already in the list.")
		else
			auraList.config[spellID] = auraList.MaskDial:GetMask()
			auraList:Update()

			auraList.AddEditBox:SetText("")

			log:SetText(SUCCESS_TEXT.." Added "..link..".")
		end
	end
end

local function AuraListEditBox_OnTextChanged(self, isUserInput)
	if isUserInput then
		local log = panel.StatusLog
		local spellID = tonumber(self:GetText())

		if spellID and spellID > 2147483647 then return end

		local link = GetSpellLink(spellID)

		if link then
			log:SetText("Found spell: "..link..".")
		else
			log:SetText("No spell found.")
		end
	end
end

local function LSUFAuraList_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 30, LSUFAuraList_Update)
end

local function LSUFAuraListTab_OnClick(self)
	local auraList = self:GetParent()

	FauxScrollFrame_SetOffset(auraList, 0)

	PanelTemplates_Tab_OnClick(self, auraList)

	LSUFAuraList_Update(auraList)
end

local function AuraButton_OnEnter(self)
	if not self.spellID then return end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetSpellByID(self.spellID)
	GameTooltip:Show()
end

local function AuraButton_OnLeave(self)
	GameTooltip:Hide()
end

local function UnitOptions_Refresh(newIndex)
	activeConfig = C.units[newIndex].auras

	panel.AuraList:Update()
	panel.UnitSelector:RefreshValue()
	panel.UnitSelector.Indicator:SetMask(activeConfig.enabled)
	panel.IncludeCastableBuffsMaskDial:SetMask(activeConfig.HELPFUL.include_castable)
	panel.ShowOnlyDispellableDebuffsMaskDial:SetMask(activeConfig.HARMFUL.show_only_dispellable)
end

local function UnitSelectorDropDown_OnClick(self)
	local newValue = self.value

	if newValue == panel.ConfigCopyDropDown:GetValue() then
		panel.ConfigCopyButton:Disable()
	else
		panel.ConfigCopyButton:Enable()
	end

	self.owner:SetValue(newValue)

	UnitOptions_Refresh(newValue)
end

local function UnitSelectorDropDown_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "Target"
	info.func = UnitSelectorDropDown_OnClick
	info.value = "target"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)

	info.text = "Focus"
	info.func = UnitSelectorDropDown_OnClick
	info.value = "focus"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end

local function ConfigCopyDropDown__OnClick(self)
	if self.value == panel.UnitSelector:GetValue() then
		panel.ConfigCopyButton:Disable()
	else
		panel.ConfigCopyButton:Enable()
	end

	self.owner:SetValue(self.value)
end

local function ConfigCopyDropDown_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "Target"
	info.func = ConfigCopyDropDown__OnClick
	info.value = "target"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)

	info.text = "Focus"
	info.func = ConfigCopyDropDown__OnClick
	info.value = "focus"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end

local function ConfigCopyButton_OnClick(self)
	local srcValue, destValue = panel.ConfigCopyDropDown:GetValue(), panel.UnitSelector:GetValue()

	E:ReplaceTable(C.units[srcValue].auras, C.units[destValue].auras)

	UnitOptions_Refresh(destValue)

	panel.StatusLog:SetText(SUCCESS_TEXT.." Copied "..srcValue.." data to "..destValue..".")
end

local function UFAurasConfigPanel_OnShow(self)
	self.AuraList:Update()
	self.UnitSelector:RefreshValue()
	self.UnitSelector.Indicator:SetMask(activeConfig.enabled)
	self.IncludeCastableBuffsMaskDial:SetMask(activeConfig.HELPFUL.include_castable)
	self.ShowOnlyDispellableDebuffsMaskDial:SetMask(activeConfig.HARMFUL.show_only_dispellable)
	self.ConfigCopyButton:Disable()
	self.StatusLog:SetText("")
end

local function UnitDropDownMaskDialIndicator_OnMouseUp(self)
	activeConfig.enabled = self:GetParent():GetMask()
end

local function AuraButtonMaskDialIndicator_OnMouseUp(self)
	panel.AuraList.config[self:GetParent():GetParent().spellID] = self:GetParent():GetMask()
end

local function IncludeCastableBuffsMaskDialIndicator_OnMouseUp(self)
	activeConfig.HELPFUL.include_castable = self:GetParent():GetMask()
end

local function ShowOnlyDispellableDebuffsMaskDialIndicator_OnMouseUp(self)
	activeConfig.HARMFUL.show_only_dispellable = self:GetParent():GetMask()
end

local function WipeButton_OnClick(self)
	wipe(panel.AuraList.config)

	panel.AuraList:Update()
	panel.StatusLog:SetText(SUCCESS_TEXT.." Wiped aura list.")
end

local function WipeButton_Enable(self)
	getmetatable(self).__index.Enable(self)

	if self.Icon then
		self.Icon:SetDesaturated(false)
	end
end

local function WipeButton_Disable(self)
	getmetatable(self).__index.Disable(self)

	if self.Icon then
		self.Icon:SetDesaturated(true)
	end
end

local function DeleteAuraButton_OnClick(self)
	local spellID = self:GetParent().spellID

	panel.StatusLog:SetText(SUCCESS_TEXT.." Removed "..GetSpellLink(spellID)..".")
	panel.AuraList.config[spellID] = nil
	panel.AuraList:Update()
end

local function EditUnitButton_OnClick(self)
	ToggleDropDownMenu(1, nil, self.DropDown, self)
end

local function SmallButton_OnEnter(self)
	self.Icon:SetAlpha(1)
end

local function SmallButton_OnLeave(self)
	self.Icon:SetAlpha(0.5)
end

function CFG:UFAuras_Initialize()
	activeConfig = C.units.target.auras

	panel = CreateFrame("Frame", "LSUFAurasConfigPanel", InterfaceOptionsFramePanelContainer)
	panel.name = "Buffs and Debuffs"
	panel.parent = "oUF: |cff1a9fc0LS|r"
	panel:HookScript("OnShow", UFAurasConfigPanel_OnShow)
	panel:Hide()

	local header1 = CFG:CreateTextLabel(panel, 16, "|cffffd100Buffs and Debuffs|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local infoText1 = CFG:CreateTextLabel(panel, 10, "These options allow you to control how buffs and debuffs are displayed on unit frames.")
	infoText1:SetHeight(32)
	infoText1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	local unitSelector = CFG:CreateDropDownMenu(panel, "UnitSelectorDropDown", "Unit Frame", UnitSelectorDropDown_Initialize)
	unitSelector:SetPoint("TOPLEFT", infoText1, "BOTTOMLEFT", -8, -18)
	UIDropDownMenu_SetWidth(unitSelector, 160)
	unitSelector:SetValue("target")
	panel.UnitSelector = unitSelector

	local indicator = CFG:CreateMaskDial(unitSelector, "MaskDial")
	indicator:SetFrameLevel(unitSelector:GetFrameLevel() + 1)
	indicator:SetPoint("LEFT", unitSelector, "LEFT", 24, 2)
	for i = 1, #indicator do
		indicator[i]:SetScript("OnMouseUp", UnitDropDownMaskDialIndicator_OnMouseUp)
	end
	unitSelector.Indicator = indicator

	local auraList = CreateFrame("ScrollFrame", "LSUFAuraList", panel, "FauxScrollFrameTemplate")
	auraList:SetSize(210, 330) -- 30 * 10 + 6 * 2 + 9 * 2
	auraList:SetPoint("TOPLEFT", unitSelector, "BOTTOMLEFT", 8, -40) -- 8 + 32 (default offset + tab height)
	auraList:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, tileSize = 0,
		edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	auraList:SetBackdropColor(0, 0, 0, 1)
	auraList:SetBackdropBorderColor(0.6, 0.6, 0.6)
	auraList:SetScript("OnVerticalScroll", LSUFAuraList_OnVerticalScroll)
	auraList.Update = LSUFAuraList_Update
	panel.AuraList = auraList

	local scrollbar = auraList.ScrollBar
	scrollbar:ClearAllPoints()
	scrollbar:SetPoint("TOPRIGHT", auraList,"TOPRIGHT", -6, -22)
	scrollbar:SetPoint("BOTTOMRIGHT", auraList,"BOTTOMRIGHT", -6, 22)

	auraList.buttons = {}
	for i = 1, 12 do
		local button = CreateFrame("Button", "$parentButton"..i, auraList)
		button.type = "Button"
		button:SetHeight(30)
		button:EnableMouse(true)
		button:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue", "ADD")
		button:SetScript("OnEnter", AuraButton_OnEnter)
		button:SetScript("OnLeave", AuraButton_OnLeave)
		tinsert(auraList.buttons, button)

		local iconholder = CreateFrame("Frame", "$parentIconHolder", button)
		iconholder:SetSize(24, 24)
		iconholder:SetPoint("LEFT", 3, 0)
		E:CreateBorder(iconholder)

		button.Icon = E:UpdateIcon(iconholder)

		local text = E:CreateFontString(button, 12, "$parentLabel", true)
		text:SetJustifyH("LEFT")
		text:SetPoint("TOPLEFT", iconholder, "TOPRIGHT", 4, 2)
		text:SetPoint("RIGHT", button, "RIGHT", -4, 0)
		button.Text = text

		local indicator = CFG:CreateMaskDial(button, "MaskDial")
		indicator:SetFrameLevel(button:GetFrameLevel() + 4)
		indicator:SetPoint("BOTTOMLEFT", iconholder, "BOTTOMRIGHT", 4, -2)
		for i = 1, #indicator do
			indicator[i]:SetScript("OnMouseUp", AuraButtonMaskDialIndicator_OnMouseUp)
		end
		button.Indicator = indicator

		local deleteButton = CreateFrame("Button", "$parentDeleteButton", button)
		deleteButton:SetSize(16, 16)
		deleteButton:SetPoint("BOTTOMRIGHT", 0, 0)
		deleteButton:SetScript("OnClick", DeleteAuraButton_OnClick)
		deleteButton:SetScript("OnEnter", SmallButton_OnEnter)
		deleteButton:SetScript("OnLeave", SmallButton_OnLeave)
		button.DeleteButton = deleteButton

		local icon = deleteButton:CreateTexture(nil, "ARTWORK")
		icon:SetTexture("Interface\\Buttons\\UI-StopButton")
		icon:SetDesaturated(true)
		icon:SetVertexColor(0.9, 0.15, 0.15)
		icon:SetAlpha(0.5)
		icon:SetPoint("TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", -1, 1)
		deleteButton.Icon = icon

		local bg = button:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.15, 0.15, 0.15)
		button.Bg = bg

		if i == 1 then
			button:SetPoint("TOPLEFT", 6, -6)
		else
			button:SetPoint("TOPLEFT", auraList.buttons[i - 1], "BOTTOMLEFT", 0, -2)
		end

		button:SetPoint("RIGHT", scrollbar, "LEFT", -2, -6)
	end

	local wipeButton = E:CreateButton(auraList, "$parentWipeButton")
	wipeButton:SetSize(24, 24)
	wipeButton:SetPoint("TOPLEFT", auraList, "TOPRIGHT", 1, -14)
	wipeButton.Icon:SetTexture("Interface\\ICONS\\INV_Pet_Broom")
	wipeButton:SetScript("OnClick", WipeButton_OnClick)
	wipeButton.Enable = WipeButton_Enable
	wipeButton.Disable = WipeButton_Disable
	auraList.WipeButton = wipeButton

	local wipeButtonBG = wipeButton:CreateTexture(nil, "BACKGROUND", nil, -8)
	wipeButtonBG:SetSize(50, 50)
	wipeButtonBG:SetPoint("LEFT", -3, -4)
	wipeButtonBG:SetTexture("Interface\\SPELLBOOK\\SpellBook-SkillLineTab")

	local buffTab = CreateFrame("Button", "LSUFAuraListTab1", auraList, "TabButtonTemplate")
	buffTab.type = "Button"
	buffTab:SetID(1)
	buffTab:SetText("Buffs")
	buffTab:SetPoint("BOTTOMLEFT", auraList, "TOPLEFT", 8, -2)
	buffTab:SetScript("OnClick", LSUFAuraListTab_OnClick)
	auraList.BuffTab = buffTab

	local debuffTab = CreateFrame("Button", "LSUFAuraListTab2", auraList, "TabButtonTemplate")
	debuffTab.type = "Button"
	debuffTab:SetID(2)
	debuffTab:SetText("Debuffs")
	debuffTab:SetPoint("LEFT", buffTab, "RIGHT", 0, 0)
	debuffTab:SetScript("OnClick", LSUFAuraListTab_OnClick)
	auraList.DebuffTab = debuffTab

	PanelTemplates_TabResize(buffTab, 0)
	PanelTemplates_TabResize(debuffTab, 0)
	PanelTemplates_SetNumTabs(auraList, 2)
	PanelTemplates_SetTab(auraList, 1)

	local addEditBox = CreateFrame("EditBox", "ATAuraListEditBox", auraList, "InputBoxInstructionsTemplate")
	addEditBox.type = "EditBox"
	addEditBox:SetSize(120, 22)
	addEditBox:SetAutoFocus(false)
	addEditBox:SetNumeric(true)
	addEditBox.Instructions:SetText("Enter Spell ID")
	addEditBox:SetPoint("TOPLEFT", auraList, "BOTTOMLEFT", 6, 0)
	addEditBox:SetScript("OnEnterPressed", AuraList_AddAura)
	addEditBox:HookScript("OnTextChanged", AuraListEditBox_OnTextChanged)
	auraList.AddEditBox = addEditBox

	local addButton = CreateFrame("Button", "ATAuraListAddButton", auraList, "UIPanelButtonTemplate")
	addButton.type = "Button"
	addButton:SetSize(82, 22)
	addButton:SetText(ADD)
	addButton:SetPoint("LEFT", addEditBox, "RIGHT", 2, 0)
	addButton:SetScript("OnClick", AuraList_AddAura)
	auraList.AddButton = addButton

	local maskLabel = CFG:CreateTextLabel(auraList, 12, "Mask:")
	maskLabel:SetPoint("TOPLEFT", addEditBox, "BOTTOMLEFT", -4, -2)
	maskLabel:SetVertexColor(1, 0.82, 0)

	local maskDial = CFG:CreateMaskDial(auraList, "AddAuraMaskDial")
	maskDial:SetPoint("LEFT", maskLabel, "RIGHT", 2, -1)
	maskDial.Text = maskLabel
	auraList.MaskDial = maskDial

	local configCopyDropDown = CFG:CreateDropDownMenu(panel, "ConfigCopyDropDown", "Copy Config From", ConfigCopyDropDown_Initialize)
	configCopyDropDown:SetValue("target")
	configCopyDropDown:SetPoint("LEFT", panel, "CENTER", 6, 0)
	configCopyDropDown:SetPoint("TOP", infoText1, "BOTTOM", 0, -18)
	UIDropDownMenu_SetWidth(configCopyDropDown, 160)
	panel.ConfigCopyDropDown = configCopyDropDown

	local configCopyButton = CreateFrame("Button", "$parentConfigCopyButton", panel, "UIPanelButtonTemplate")
	configCopyButton:SetText("Copy")
	configCopyButton:SetWidth(configCopyButton:GetTextWidth() + 18)
	configCopyButton:SetPoint("LEFT", configCopyDropDown, "RIGHT", -15, 3)
	configCopyButton:SetScript("OnClick", ConfigCopyButton_OnClick)
	panel.ConfigCopyButton = configCopyButton

	local friendlyOptionsBG = panel:CreateTexture("$parentFriendlyOptionBG", "BACKGROUND")
	friendlyOptionsBG:SetColorTexture(0.3, 0.3, 0.3, 0.3)
	friendlyOptionsBG:SetHeight(62)
	friendlyOptionsBG:SetPoint("TOP", configCopyDropDown, "BOTTOM", 0, -40)
	friendlyOptionsBG:SetPoint("LEFT", panel, "CENTER", 14, 0)
	friendlyOptionsBG:SetPoint("RIGHT", -16, 0)

	local friendlyOptionsLabel = CFG:CreateTextLabel(panel, 12, "Friendly Filter Settings:")
	friendlyOptionsLabel:SetPoint("TOPLEFT", friendlyOptionsBG, "TOPLEFT", 6, -6)
	friendlyOptionsLabel:SetVertexColor(1, 0.82, 0)

	local includeCastableBuffsLabel = CFG:CreateTextLabel(panel, 12, "Include Castable Buffs")
	includeCastableBuffsLabel:SetPoint("TOPLEFT", friendlyOptionsLabel, "BOTTOMLEFT", 0, -6)

	local includeCastableBuffsDial = CFG:CreateMaskDial(panel, "IncludeCastableBuffsMaskDial")
	includeCastableBuffsDial:SetPoint("TOP", friendlyOptionsLabel, "BOTTOM", 0, -7)
	includeCastableBuffsDial:SetPoint("RIGHT", friendlyOptionsBG, "RIGHT", -6, 0)
	includeCastableBuffsDial.Text = includeCastableBuffsLabel
	for i = 1, #includeCastableBuffsDial do
		includeCastableBuffsDial[i]:SetScript("OnMouseUp", IncludeCastableBuffsMaskDialIndicator_OnMouseUp)
	end
	panel.IncludeCastableBuffsMaskDial = includeCastableBuffsDial

	local showOnlyDispellableDebuffsLabel = CFG:CreateTextLabel(panel, 12, "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|tShow |cffffd100Only|r Dispellable Debuffs")
	showOnlyDispellableDebuffsLabel:SetPoint("TOPLEFT", includeCastableBuffsLabel, "BOTTOMLEFT", 0, -6)

	local showOnlyDispellableDebuffsDial = CFG:CreateMaskDial(panel, "ShowOnlyDispellableDebuffsMaskDial")
	showOnlyDispellableDebuffsDial:SetPoint("TOPRIGHT", includeCastableBuffsDial, "BOTTOMRIGHT", 0, -4)
	showOnlyDispellableDebuffsDial.Text = showOnlyDispellableDebuffsLabel
	for i = 1, #showOnlyDispellableDebuffsDial do
		showOnlyDispellableDebuffsDial[i]:SetScript("OnMouseUp", ShowOnlyDispellableDebuffsMaskDialIndicator_OnMouseUp)
	end
	panel.ShowOnlyDispellableDebuffsMaskDial = showOnlyDispellableDebuffsDial

	local log1 = CFG:CreateStatusLog(panel)
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	log1:SetWidth(512)
	panel.StatusLog = log1

	CFG:AddCatergory(panel)
end
