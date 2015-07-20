local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D

local AT = E.AT
local FauxScrollFrame_Update, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_SetOffset, FauxScrollFrame_GetOffset =
	FauxScrollFrame_Update, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_SetOffset, FauxScrollFrame_GetOffset

local function CreateOptionsText(parent, size, text)
	local object = E:CreateFontString(parent, size, nil, true, nil, true)
	object:SetJustifyH("LEFT")
	object:SetJustifyV("MIDDLE")
	object:SetText(text)

	return object
end

local function AuraList_Update(frame)
	if not frame.buttons then return end

	local tab = frame.selectedTab
	local buttons = frame.buttons
	local offset = FauxScrollFrame_GetOffset(frame)
	local bufftable = C.auratracker[tostring(GetSpecialization() or 0)]["HELPFUL"]
	local debufftable = C.auratracker[tostring(GetSpecialization() or 0)]["HARMFUL"]

	for i = 1, #buttons do
		buttons[i]:Hide()
		buttons[i].Text:SetText("")
		buttons[i].Icon:SetTexture("")
		buttons[i].spellID = nil
		buttons[i]:SetChecked(false)
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
			local v = bufftable[i + offset]
			if v then
				local name, arg2, icon, arg4 = GetSpellInfo(v)
				buttons[i]:Show()
				buttons[i].Text:SetText(name)
				buttons[i].Icon:SetTexture(icon)
				buttons[i].spellID = v

				total = total + 1
			end
		end

		FauxScrollFrame_Update(frame, #bufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
	else
		frame.filter = "HARMFUL"
		local total = 0

		for i = 1, 8 do
			local v = debufftable[i + offset]
			if v then
				local name, arg2, icon, arg4 = GetSpellInfo(v)
				buttons[i]:Show()
				buttons[i].Text:SetText(name)
				buttons[i].Icon:SetTexture(icon)
				buttons[i].spellID = v

				total = total + 1
			end
		end

		FauxScrollFrame_Update(frame, #debufftable, total, 30, nil, nil, nil, nil, nil, nil, true)
	end

end

local function ATConfigPanel_OnShow(self)
	self.StatusLog:SetText("")

	AuraList_Update(self.AuraList)
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

function E:ATConfig_Initialize()
	local panel = CreateFrame("Frame", "ATConfigPanel")
	panel.name = "Aura Tracker"
	panel.parent = "oUF: |cff1a9fc0LS|r"
	panel:SetScript("OnShow", ATConfigPanel_OnShow)
	panel:Hide()

	InterfaceOptions_AddCategory(panel)

	local header1 = CreateOptionsText(panel, 16, "|cffffd100Aura Tracker|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local infotext1 = CreateOptionsText(panel, 10, "These options allow you to setup player aura tracking. |cffffd100You can track up to 12 auras at once.|r")
	infotext1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	local log1 = CreateOptionsText(panel, 10, "")
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	panel.StatusLog = log1

	--------------
	-- AURALIST --
	--------------

	local auralist = CreateFrame("ScrollFrame", "ATAuraList", panel, "FauxScrollFrameTemplate")
	auralist:SetSize(210, 266) -- 30 * 8 + 6 * 2 + 7 * 2
	auralist:SetPoint("TOPLEFT", infotext1, "TOPLEFT", 0, -40)
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
		text:SetVertexColor(1, 0.82, 0)
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
	end

	local bufftab = CreateFrame("Button", "ATAuraListTab1", auralist, "TabButtonTemplate")
	bufftab:SetID(1)
	bufftab:SetPoint("BOTTOMLEFT", auralist, "TOPLEFT", 8, -2)
	bufftab:SetScript("OnClick", AuraListTab_OnClick)
	auralist.BuffTab = bufftab

	local debufftab = CreateFrame("Button", "ATAuraListTab2", auralist, "TabButtonTemplate")
	debufftab:SetID(2)
	debufftab:SetPoint("LEFT", bufftab, "RIGHT", 0, 0)
	debufftab:SetScript("OnClick", AuraListTab_OnClick)
	auralist.DebuffTab = debufftab

	local addeditbox = CreateFrame("EditBox", "ATAuraListEditBox", auralist, "InputBoxInstructionsTemplate")
	addeditbox:SetSize(120, 22)
	addeditbox:SetAutoFocus(false)
	addeditbox:SetNumeric(true)
	addeditbox.Instructions:SetText("Enter Spell ID")
	addeditbox:SetPoint("TOPLEFT", auralist, "BOTTOMLEFT", 6, 0)
	addeditbox:SetScript("OnEnterPressed", AuraList_AddAura)
	auralist.AddEditBox = addeditbox

	local addbutton = CreateFrame("Button", "ATAuraListAddButton", auralist, "UIPanelButtonTemplate")
	addbutton:SetSize(82, 22)
	addbutton:SetText(ADD)
	addbutton:SetPoint("LEFT", addeditbox, "RIGHT", 2, 0)
	addbutton:SetScript("OnClick", AuraList_AddAura)
	auralist.AddButton = addbutton

	local delbutton = CreateFrame("Button", "ATAuraListDeleteButton", auralist, "UIPanelButtonTemplate")
	delbutton:SetSize(64, 22)
	delbutton:SetText(DELETE)
	delbutton:SetPoint("TOP", addeditbox, "BOTTOM", 0, -4)
	delbutton:SetPoint("RIGHT", auralist, "RIGHT", 0, 0)
	delbutton:SetPoint("LEFT", auralist, "LEFT", 0, 0)
	delbutton:SetScript("OnClick", AuraList_DeleteAura)

	PanelTemplates_SetNumTabs(auralist, 2)
	PanelTemplates_SetTab(auralist, 1)
end
