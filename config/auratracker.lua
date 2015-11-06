local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D
local CFG = E.CFG
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
	local auralist = self:GetParent()

	FauxScrollFrame_SetOffset(auralist, 0)

	PanelTemplates_Tab_OnClick(self, auralist)

	AuraList_Update(auralist)
end

local function AuraList_AddAura(self)
	local auralist = self:GetParent()
	local spellID = auralist.AddEditBox:GetText()

	if spellID and spellID ~= "" then
		local result, msg = AT:AddToList(auralist.filter, tonumber(spellID))

		auralist:GetParent().StatusLog:SetText(msg)

		if result then
			auralist.AddEditBox:SetText("")
			auralist.AddEditBox:ClearFocus()

			AuraList_Update(auralist)
		end
	end
end

local function AuraList_DeleteAura(self, ...)
	local auralist = self:GetParent()
	local buttons = auralist.buttons
	local offset = FauxScrollFrame_GetOffset(auralist)

	for i =1, #buttons do
		local button = buttons[i]

		if button:IsVisible() and button:GetChecked() then
			local _, msg = AT:RemoveFromList(auralist.filter, button.spellID)

			auralist:GetParent().StatusLog:SetText(msg)
		end
	end

	if offset > 0 then
		FauxScrollFrame_SetOffset(auralist, offset - 1)
	end

	AuraList_Update(auralist)
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

	CFG.ToggleDependantControls(parent.ATToggle, not AT:IsRunning())

	parent.StatusLog:SetText(msg)
end

function CFG:AT_Initialize()
	local panel = CreateFrame("Frame", "ATConfigPanel")
	panel.name = "Aura Tracker"
	panel.parent = "oUF: |cff1a9fc0LS|r"
	panel:HookScript("OnShow", ATConfigPanel_OnShow)
	panel:Hide()

	InterfaceOptions_AddCategory(panel)

	panel.settings = {
		auratracker = {},
	}

	local header1 = CFG:CreateTextLabel(panel, 16, "|cffffd100Aura Tracker|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local attoggle = CFG:CreateCheckButton(panel, "Toggle", nil, "Switches Aura Tracker module on or off")
	attoggle:HookScript("OnClick", ATToggle_OnClick)
	attoggle:SetPoint("TOPRIGHT", -16, -16)
	panel.ATToggle = attoggle
	panel.settings.auratracker.enabled = attoggle

	local infotext1 = CFG:CreateTextLabel(panel, 10, "These options allow you to setup player aura tracking. |cffffd100You can track up to 12 auras at once.|r\nWhilst in combat, please, use |cffffd100/atbuff|r and |cffffd100/atdebuff|r commands to add auras to the list.")
	infotext1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	local log1 = CFG:CreateTextLabel(panel, 10, "")
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	panel.StatusLog = log1

	local auralist = CreateFrame("ScrollFrame", "ATAuraList", panel, "FauxScrollFrameTemplate")
	auralist:SetSize(210, 266) -- 30 * 8 + 6 * 2 + 7 * 2
	auralist:SetPoint("TOPLEFT", infotext1, "TOPLEFT", 0, -62)
	auralist:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, tileSize = 0,
		edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	auralist:SetBackdropColor(0, 0, 0, 1)
	auralist:SetBackdropBorderColor(0.6, 0.6, 0.6)
	auralist:SetScript("OnVerticalScroll", AuraList_OnVerticalScroll)
	panel.AuraList = auralist

	local scrollbar = auralist.ScrollBar
	scrollbar:ClearAllPoints()
	scrollbar:SetPoint("TOPRIGHT", auralist,"TOPRIGHT", -6, -22)
	scrollbar:SetPoint("BOTTOMRIGHT", auralist,"BOTTOMRIGHT", -6, 22)

	auralist.buttons = {}

	for i = 1, 8 do
		local button = CreateFrame("CheckButton", auralist:GetName().."Button"..i, auralist)
		button.type = "Button"
		button:SetHeight(30)
		button:EnableMouse(true)
		button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")
		button:SetCheckedTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
		button:GetCheckedTexture():SetVertexColor(0.9, 0.5, 0,1)
		button:SetScript("OnEnter", AuraButton_OnEnter)
		button:SetScript("OnLeave", AuraButton_OnLeave)
		tinsert(auralist.buttons, button)

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
			button:SetPoint("TOPLEFT", auralist.buttons[i-1], "BOTTOMLEFT", 0, -2)
		end

		button:SetPoint("RIGHT", scrollbar, "LEFT", 0, -6)

		CFG:SetupControlDependency(attoggle, button)
	end

	local bufftab = CreateFrame("Button", "ATAuraListTab1", auralist, "TabButtonTemplate")
	bufftab.type = "Button"
	bufftab:SetID(1)
	bufftab:SetPoint("BOTTOMLEFT", auralist, "TOPLEFT", 8, -2)
	bufftab:SetScript("OnClick", AuraListTab_OnClick)
	auralist.BuffTab = bufftab
	CFG:SetupControlDependency(attoggle, bufftab)

	local debufftab = CreateFrame("Button", "ATAuraListTab2", auralist, "TabButtonTemplate")
	debufftab.type = "Button"
	debufftab:SetID(2)
	debufftab:SetPoint("LEFT", bufftab, "RIGHT", 0, 0)
	debufftab:SetScript("OnClick", AuraListTab_OnClick)
	auralist.DebuffTab = debufftab
	CFG:SetupControlDependency(attoggle, debufftab)

	local addeditbox = CreateFrame("EditBox", "ATAuraListEditBox", auralist, "InputBoxInstructionsTemplate")
	addeditbox.type = "EditBox"
	addeditbox:SetSize(120, 22)
	addeditbox:SetAutoFocus(false)
	addeditbox:SetNumeric(true)
	addeditbox.Instructions:SetText("Enter Spell ID")
	addeditbox:SetPoint("TOPLEFT", auralist, "BOTTOMLEFT", 6, 0)
	addeditbox:SetScript("OnEnterPressed", AuraList_AddAura)
	CFG:SetupControlDependency(attoggle, addeditbox)
	auralist.AddEditBox = addeditbox

	local addbutton = CreateFrame("Button", "ATAuraListAddButton", auralist, "UIPanelButtonTemplate")
	addbutton.type = "Button"
	addbutton:SetSize(82, 22)
	addbutton:SetText(ADD)
	addbutton:SetPoint("LEFT", addeditbox, "RIGHT", 2, 0)
	addbutton:SetScript("OnClick", AuraList_AddAura)
	auralist.AddButton = addbutton
	CFG:SetupControlDependency(attoggle, addbutton)

	local delbutton = CreateFrame("Button", "ATAuraListDeleteButton", auralist, "UIPanelButtonTemplate")
	delbutton.type = "Button"
	delbutton:SetSize(64, 22)
	delbutton:SetText(DELETE)
	delbutton:SetPoint("TOP", addeditbox, "BOTTOM", 0, -4)
	delbutton:SetPoint("RIGHT", auralist, "RIGHT", 0, 0)
	delbutton:SetPoint("LEFT", auralist, "LEFT", 0, 0)
	delbutton:SetScript("OnClick", AuraList_DeleteAura)
	auralist.DeleteButton = delbutton
	CFG:SetupControlDependency(attoggle, delbutton)

	PanelTemplates_SetNumTabs(auralist, 2)
	PanelTemplates_SetTab(auralist, 1)

	local locktoggle = CFG:CreateCheckButton(panel, "MovementToggle", LOCK_FRAME)
	locktoggle:SetPoint("TOPLEFT", delbutton, "BOTTOMLEFT", 0, -8)
	locktoggle:HookScript("OnClick", LockToggle_OnClick)
	panel.settings.auratracker.locked = locktoggle
	CFG:SetupControlDependency(attoggle, locktoggle)

	local growthdropdown = CFG:CreateDropDownMenu(panel, "DirectionDropDown", "Growth direction", "GrowthDirectionDropDownMenu_Initialize")
	growthdropdown:SetPoint("TOPLEFT", locktoggle, "BOTTOMLEFT", -13, -24)
	panel.GrowthDirectionDropDownMenu = growthdropdown
	panel.settings.auratracker.direction = growthdropdown
	CFG:SetupControlDependency(attoggle, growthdropdown)

	panel.okay = function() CFG:OptionsPanelOkay(panel) end
	panel.cancel = function() CFG:OptionsPanelOkay(panel) end
	panel.refresh = function() CFG:OptionsPanelRefresh(panel) end
	panel.default = function() CFG:OptionsPanelDefault(panel) end
end
