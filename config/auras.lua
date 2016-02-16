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
	local button, aura
	local offset = FauxScrollFrame_GetOffset(frame)
	local spec = GetSpecialization() or 0
	local bufftable = activeConfig["HELPFUL"].auralist
	local debufftable = activeConfig["HARMFUL"].auralist

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
		frame.config = bufftable
		frame.filter = "HELPFUL"
		local total = 0

		bufftable = PrepareSortedAuraList(bufftable)

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
	else
	-- 	frame.filter = "HARMFUL"
	-- 	local total = 0

	-- 	for i = 1, 8 do
	-- 		value = debufftable[i + offset]
	-- 		button = buttons[i]

	-- 		if value then
	-- 			local name, _, icon = GetSpellInfo(value)
	-- 			button:Show()
	-- 			button.Text:SetText(name)
	-- 			button.Icon:SetTexture(icon)
	-- 			button.spellID = value

	-- 			total = total + 1
	-- 		end
		-- end

	-- 	FauxScrollFrame_Update(frame, #debufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
	end
end

local function AuraList_AddAura(self, ...)
	local auraList = panel.AuraList
	local spellID = auraList.AddEditBox:GetText()

	print(auraList.MaskDial:GetMask())
end

local function AuraListEditBox_OnTextChanged(self, isUserInput)
	if isUserInput then
		local log = panel.StatusLog
		local spellID = self:GetText()
		local name = GetSpellInfo(spellID)

		if name then
			log:SetText("Found spell: \""..name.."\".")
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

local function UnitSelectorDropDown_OnClick(self)
	print(self.value)
end

local function UnitSelectorDropDown_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "Target"
	info.func = UnitSelectorDropDown_OnClick
	info.value = "target"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end

local function UFAurasConfigPanel_OnShow(self)
	self.AuraList:Update()

	self.UnitSelector.Indicator:SetMask(C.units.target.auras.enabled)
end

local function UnitDropDownMaskDialIndicator_OnMouseUp(self)
	C.units.target.auras.enabled = self:GetParent():GetMask()
end

local function AuraButtonMaskDialIndicator_OnMouseUp(self)
	panel.AuraList.config[self:GetParent():GetParent().spellID] = self:GetParent():GetMask()
end

local function DeleteAuraButton_OnClick(self)
	print("will delete ID:", self:GetParent().spellID)
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

	panel.settings = {
		units = {
			target = {
				auras = {},
			},
		},
	}

	local header1 = CFG:CreateTextLabel(panel, 16, "|cffffd100Buffs and Debuffs|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local infoText1 = CFG:CreateTextLabel(panel, 10, "Something something unit frames something something auras.")
	infoText1:SetHeight(32)
	infoText1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	local unitSelector = CFG:CreateDropDownMenu(panel, "UnitSelectorDropDown", nil, UnitSelectorDropDown_Initialize)
	unitSelector:SetPoint("TOPLEFT", infoText1, "BOTTOMLEFT", -18, -6)
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
	auraList:SetPoint("TOPLEFT", unitSelector, "BOTTOMLEFT", 18, -40) -- 8 + 32 (default offset + tab height)
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
		E:CreateBorder(iconholder, 6)

		button.Icon = E:UpdateIcon(iconholder)

		local text = button:CreateFontString(nil, "ARTWORK", "LS12Font")
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
		bg:SetTexture(0.15, 0.15, 0.15)
		button.Bg = bg

		if i == 1 then
			button:SetPoint("TOPLEFT", 6, -6)
		else
			button:SetPoint("TOPLEFT", auraList.buttons[i - 1], "BOTTOMLEFT", 0, -2)
		end

		button:SetPoint("RIGHT", scrollbar, "LEFT", -2, -6)
	end

	local buffTab = CreateFrame("Button", "LSUFAuraListTab1", auraList, "TabButtonTemplate")
	buffTab.type = "Button"
	buffTab:SetID(1)
	buffTab:SetText("Buffs")
	buffTab:SetPoint("BOTTOMLEFT", auraList, "TOPLEFT", 8, -2)
	buffTab:SetScript("OnClick", LSUFAuraListTab_OnClick)
	auraList.BuffTab = buffTab
	-- CFG:SetupControlDependency(atToggle, buffTab)

	local debuffTab = CreateFrame("Button", "LSUFAuraListTab2", auraList, "TabButtonTemplate")
	debuffTab.type = "Button"
	debuffTab:SetID(2)
	debuffTab:SetText("Debuffs")
	debuffTab:SetPoint("LEFT", buffTab, "RIGHT", 0, 0)
	debuffTab:SetScript("OnClick", LSUFAuraListTab_OnClick)
	auraList.DebuffTab = debuffTab
	-- CFG:SetupControlDependency(atToggle, debuffTab).

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
	-- CFG:SetupControlDependency(atToggle, addEditBox)
	auraList.AddEditBox = addEditBox

	local addButton = CreateFrame("Button", "ATAuraListAddButton", auraList, "UIPanelButtonTemplate")
	addButton.type = "Button"
	addButton:SetSize(82, 22)
	addButton:SetText(ADD)
	addButton:SetPoint("LEFT", addEditBox, "RIGHT", 2, 0)
	addButton:SetScript("OnClick", AuraList_AddAura)
	auraList.AddButton = addButton

	local maskDial = CFG:CreateMaskDial(auraList, "AddAuraMaskDial")
	maskDial:SetPoint("TOPLEFT", addEditBox, "BOTTOMLEFT", 0, -4)
	auraList.MaskDial = maskDial

	local log1 = CFG:CreateTextLabel(panel, 10, "")
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	log1:SetText("################################################################")
	panel.StatusLog = log1

	local reloadButton = CFG:CreateReloadUIButton(panel)
	reloadButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)

	CFG:AddCatergory(panel)
end
