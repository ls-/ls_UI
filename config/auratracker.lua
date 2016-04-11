local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D
local CFG = E:GetModule("Config")
local AT = E:GetModule("AuraTracker")

-- Lua
local _G = _G
local pairs = pairs
local getmetatable = getmetatable
local tsort, tinsert, twipe = table.sort, table.insert, table.wipe
local tostring, tonumber = tostring, tonumber

-- Bliz
local GameTooltip = GameTooltip
local GetSpellInfo = GetSpellInfo

-- Mine
local panel
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
	twipe(sortedAuras)

	for id, filter in pairs(tbl) do
		local name, _, icon = GetSpellInfo(id)
		if name then
			tinsert(sortedAuras, {id = id, name = name, icon = icon, filter = filter})
		end
	end

	tsort(sortedAuras, SortAurasByName)

	return sortedAuras
end

local function AuraList_Update(frame)
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
		if not C.auratracker["HELPFUL"] then
			frame.AddEditBox:Disable()
			frame.AddButton:Disable()
			frame.MaskDial:Disable()
			frame.WipeButton:Disable()
		else
			frame.AddEditBox:Enable()
			frame.AddButton:Enable()
			frame.MaskDial:Enable()
			frame.WipeButton:Enable()

			local bufftable = C.auratracker["HELPFUL"]
			local offset = _G.FauxScrollFrame_GetOffset(frame)
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

			_G.FauxScrollFrame_Update(frame, #bufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
		end
	else
		if not C.auratracker["HARMFUL"] then
			frame.AddEditBox:Disable()
			frame.AddButton:Disable()
			frame.MaskDial:Disable()
			frame.WipeButton:Disable()
		else
			frame.AddEditBox:Enable()
			frame.AddButton:Enable()
			frame.MaskDial:Enable()
			frame.WipeButton:Enable()

			local debufftable = C.auratracker["HARMFUL"]
			local offset = _G.FauxScrollFrame_GetOffset(frame)
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

			_G.FauxScrollFrame_Update(frame, #debufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
		end
	end
end

local function ATConfigPanel_OnShow(self)
	self.AuraList:Update()
	self.StatusLog:SetText("")
end

local function AuraButtonMaskDialIndicator_OnMouseUp(self)
	panel.AuraList.config[self:GetParent():GetParent().spellID] = self:GetParent():GetMask()

	AT:ForceUpdate()
end

local function AuraListTab_OnClick(self)
	local auraList = self:GetParent()

	_G.FauxScrollFrame_SetOffset(auraList, 0)

	_G.PanelTemplates_Tab_OnClick(self, auraList)

	AuraList_Update(auraList)
end

local function AuraList_AddAura(self)
	local auraList = panel.AuraList
	local spellID = tonumber(auraList.AddEditBox:GetText())

	if spellID and spellID > 2147483647 then return end

	local link = _G.GetSpellLink(spellID)

	if link then
		if auraList.config[spellID] then
			panel.StatusLog:SetText(ERROR_TEXT..link.." is already in the list.")
		else
			auraList.config[spellID] = auraList.MaskDial:GetMask()
			auraList.AddEditBox:SetText("")
			auraList:Update()

			AT:ForceUpdate()

			panel.StatusLog:SetText(SUCCESS_TEXT.." Added "..link..".")
		end
	end
end

local function AuraList_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 30, AuraList_Update)
end

local function AuraListEditBox_OnTextChanged(self, isUserInput)
	if isUserInput then
		local spellID = tonumber(self:GetText())

		if spellID and spellID > 2147483647 then return end

		local link = _G.GetSpellLink(spellID)

		if link then
			panel.StatusLog:SetText("Found spell: "..link..".")
		else
			panel.StatusLog:SetText("No spell found.")
		end
	end
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
	if not self:GetChecked() then
		AT:ShowHeader()
	else
		AT:HideHeader()
	end
end

local function ATToggle_OnClick(self)
	local result, msg

	if not self:GetChecked() then
		result, msg = AT:Disable()
	else
		result, msg = AT:Enable()
	end

	panel.StatusLog:SetText(msg)
end

local function GrowthDirectionDropDownMenu_OnClick(self)
	self.owner:SetValue(self.value)
end

local function WipeButton_OnClick(self)
	twipe(panel.AuraList.config)

	panel.StatusLog:SetText(SUCCESS_TEXT.." Wiped aura list.")
	panel.AuraList:Update()

	AT:ForceUpdate()
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

	panel.StatusLog:SetText(SUCCESS_TEXT.." Removed ".._G.GetSpellLink(spellID)..".")
	panel.AuraList.config[spellID] = nil
	panel.AuraList:Update()

	AT:ForceUpdate()
end

local function SmallButton_OnEnter(self)
	self.Icon:SetAlpha(1)
end

local function SmallButton_OnLeave(self)
	self.Icon:SetAlpha(0.5)
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

local function ATButtonSettingsApplyButton_OnClick(self)
	E:UpdateBarLayout(AT:GetAuraTracker(), panel.ButtonSizeSlider:GetValue(), panel.ButtonSpacingSlider:GetValue(), panel.GrowthDirectionDropDownMenu:GetValue())
	E:UpdateMoverSize(AT:GetAuraTracker())

	E:ApplySettings(panel.settings.auratracker, C.auratracker)
end

function CFG:AT_Initialize()
	panel = _G.CreateFrame("Frame", "LSATConfigPanel", _G.InterfaceOptionsFramePanelContainer)
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

	local infoText1 = CFG:CreateTextLabel(panel, 10, "These options allow you to setup player aura tracking.")
	infoText1:SetHeight(32)
	infoText1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)
	infoText1:SetPoint("RIGHT", -16, 0)

	local auraList = _G.CreateFrame("ScrollFrame", "ATAuraList", panel, "FauxScrollFrameTemplate")
	auraList:SetSize(210, 330) -- 30 * 10 + 6 * 2 + 9 * 2
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
	auraList.Update = AuraList_Update
	panel.AuraList = auraList

	local scrollbar = auraList.ScrollBar
	scrollbar:ClearAllPoints()
	scrollbar:SetPoint("TOPRIGHT", auraList,"TOPRIGHT", -6, -22)
	scrollbar:SetPoint("BOTTOMRIGHT", auraList,"BOTTOMRIGHT", -6, 22)

	auraList.buttons = {}

	for i = 1, 12 do
		local button = _G.CreateFrame("CheckButton", "$parentButton"..i, auraList)
		button.type = "Button"
		button:SetHeight(30)
		button:EnableMouse(true)
		button:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue", "ADD")
		button:SetScript("OnEnter", AuraButton_OnEnter)
		button:SetScript("OnLeave", AuraButton_OnLeave)
		tinsert(auraList.buttons, button)

		local iconholder = _G.CreateFrame("Frame", "$parentIconHolder", button)
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

		local deleteButton = _G.CreateFrame("Button", "$parentDeleteButton", button)
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
		bg:SetTexture(0.15, 0.15, 0.15)
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

	local buffTab = _G.CreateFrame("Button", "ATAuraListTab1", auraList, "TabButtonTemplate")
	buffTab.type = "Button"
	buffTab:SetID(1)
	buffTab:SetText("Buffs")
	buffTab:SetPoint("BOTTOMLEFT", auraList, "TOPLEFT", 8, -2)
	buffTab:SetScript("OnClick", AuraListTab_OnClick)
	auraList.BuffTab = buffTab

	local debuffTab = _G.CreateFrame("Button", "ATAuraListTab2", auraList, "TabButtonTemplate")
	debuffTab.type = "Button"
	debuffTab:SetID(2)
	debuffTab:SetText("Debuffs")
	debuffTab:SetPoint("LEFT", buffTab, "RIGHT", 0, 0)
	debuffTab:SetScript("OnClick", AuraListTab_OnClick)
	auraList.DebuffTab = debuffTab

	_G.PanelTemplates_TabResize(buffTab, 0)
	_G.PanelTemplates_TabResize(debuffTab, 0)
	_G.PanelTemplates_SetNumTabs(auraList, 2)
	_G.PanelTemplates_SetTab(auraList, 1)

	local addEditBox = _G.CreateFrame("EditBox", "ATAuraListEditBox", auraList, "InputBoxInstructionsTemplate")
	addEditBox.type = "EditBox"
	addEditBox:SetSize(120, 22)
	addEditBox:SetAutoFocus(false)
	addEditBox:SetNumeric(true)
	addEditBox.Instructions:SetText("Enter Spell ID")
	addEditBox:SetPoint("TOPLEFT", auraList, "BOTTOMLEFT", 6, 0)
	addEditBox:SetScript("OnEnterPressed", AuraList_AddAura)
	addEditBox:HookScript("OnTextChanged", AuraListEditBox_OnTextChanged)
	auraList.AddEditBox = addEditBox

	local addButton = _G.CreateFrame("Button", "ATAuraListAddButton", auraList, "UIPanelButtonTemplate")
	addButton.type = "Button"
	addButton:SetSize(82, 22)
	addButton:SetText(_G.ADD)
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

	local barOptionsBG = panel:CreateTexture("$parentFriendlyOptionBG", "BACKGROUND")
	barOptionsBG:SetTexture(0.3, 0.3, 0.3, 0.3)
	barOptionsBG:SetHeight(144)
	barOptionsBG:SetPoint("TOP", infoText1, "BOTTOM", 0, -18)
	barOptionsBG:SetPoint("LEFT", panel, "CENTER", 14, 0)
	barOptionsBG:SetPoint("RIGHT", -16, 0)

	local buttonSizeSlider = CFG:CreateSlider(panel, "$parentButtonSizeSlider", "Button size", 32, 48)
	buttonSizeSlider:SetPoint("TOPLEFT", barOptionsBG, "TOPLEFT", 16, -16)
	panel.ButtonSizeSlider = buttonSizeSlider
	panel.settings.auratracker.button_size = buttonSizeSlider

	local buttonSpacingSlider = CFG:CreateSlider(panel, "$parentButtonSpacingSlider", "Button spacing", 2, 12)
	buttonSpacingSlider:SetPoint("TOPLEFT", buttonSizeSlider, "BOTTOMLEFT", 0, -25)
	panel.ButtonSpacingSlider = buttonSpacingSlider
	panel.settings.auratracker.button_gap = buttonSpacingSlider

	local growthDropdown = CFG:CreateDropDownMenu(panel, "DirectionDropDown", "Growth direction", GrowthDirectionDropDownMenu_Initialize)
	growthDropdown:SetPoint("TOPLEFT", buttonSpacingSlider, "BOTTOMLEFT", -18, -32)
	panel.GrowthDirectionDropDownMenu = growthDropdown
	panel.settings.auratracker.direction = growthDropdown

	local applyButton = _G.CreateFrame("Button", "BarSelectorApplyButton", panel, "UIPanelButtonTemplate")
	applyButton.type = "Button"
	applyButton:SetSize(82, 22)
	applyButton:SetText(_G.APPLY)
	applyButton:SetPoint("TOPRIGHT", barOptionsBG, "TOPRIGHT", -8, -8)
	applyButton:SetScript("OnClick", ATButtonSettingsApplyButton_OnClick)

	local lockToggle = CFG:CreateCheckButton(panel, "MovementToggle", _G.LOCK_FRAME)
	lockToggle:SetPoint("TOPLEFT", barOptionsBG, "BOTTOMLEFT", -2, -8)
	lockToggle:HookScript("OnClick", LockToggle_OnClick)
	panel.settings.auratracker.locked = lockToggle

	local log1 = CFG:CreateStatusLog(panel)
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	log1:SetWidth(512)
	panel.StatusLog = log1

	local reloadButton = CFG:CreateReloadUIButton(panel)
	reloadButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)

	CFG:AddCatergory(panel)
end
