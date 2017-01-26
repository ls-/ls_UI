local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:AddModule("Config")

-- Lua
local _G = _G
local string = _G.string
local table = _G.table
local getmetatable = _G.getmetatable
local pairs = _G.pairs
local tonumber = _G.tonumber

-- Mine
local function RegisterControlForRefresh(panel, control)
	if not panel or not control then
		return
	end

	panel.controls = panel.controls or {}
	table.insert(panel.controls, control)
end

-- Panel
local activePanel

do
	local panels = {}

	local function OnShow(self)
		activePanel = self

		self.Log:SetText("")
	end

	local function OptionsPanelRefresh(panel)
		for _, control in pairs(panel.controls) do
			if control.RefreshValue then
				control:RefreshValue()
			end
		end
	end

	local function OnHyperlinkEnter(self, _, link)
		_G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
		_G.GameTooltip:SetHyperlink(link)
		_G.GameTooltip:Show()
	end

	local function OnHyperlinkLeave()
		_G.GameTooltip:Hide()
	end

	function CFG:AddPanel(panel)
		panel.refresh = OptionsPanelRefresh

		panel:SetScript("OnShow", OnShow)

		local anchorToggle = self:CreateButton(panel, "MoversToggle", L["TOGGLE_ANCHORS"], E.ToggleAllMovers)
		anchorToggle:SetPoint("TOPRIGHT", -16, -16)

		local reloadButton = self:CreateButton(panel, "ReloadUIButton", L["RELOADUI"], _G.ReloadUI)
		reloadButton:SetPoint("RIGHT", anchorToggle, "LEFT", -16, 0)

		local log = _G.CreateFrame("SimpleHTML", "$parentLog", panel)
		log:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
		log:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)
		log:SetHeight(20)
		log:SetFontObject("LS10Font")
		log:SetJustifyH("LEFT")
		log:SetJustifyV("TOP")
		log:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)
		log:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
		panel.Log = log

		_G.InterfaceOptions_AddCategory(panel, true)
		table.insert(panels, panel)
	end
end

-- Divider
function CFG:CreateDivider(panel, text)
	local object = panel:CreateTexture(nil, "ARTWORK")
	object:SetHeight(4)
	object:SetPoint("LEFT", 10, 0)
	object:SetPoint("RIGHT", -10, 0)
	object:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
	object:SetTexCoord(0, 1, 0.0625, 0.65625)
	object:SetAlpha(0.5)

	local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	label:SetWordWrap(false)
	label:SetPoint("LEFT", object, "LEFT", 12, 1)
	label:SetPoint("RIGHT", object, "RIGHT", -12, 1)
	label:SetText(text)
	object.Text = label

	return object
end

-- Check Button
do
	local function OnClick(self)
		self:SetValue(self:GetChecked())
	end

	local function OnEnter(self)
		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		_G.GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
		_G.GameTooltip:Show()
	end

	local function OnLeave()
		_G.GameTooltip:Hide()
	end

	function CFG:CreateCheckButton(panel, data)
		local object = _G.CreateFrame("CheckButton", data.name, data.parent, "InterfaceOptionsCheckButtonTemplate")
		object:SetHitRectInsets(0, 0, 0, 0)
		object.type = "Button"
		object.GetValue = data.get
		object.SetValue = data.set
		object.RefreshValue = data.refresh
		object:SetScript("OnClick", data.click or OnClick)
		object.Text:SetText(data.text)

		if data.tooltip_text then
			object.tooltipText = data.tooltip_text
			object:SetScript("OnEnter", OnEnter)
			object:SetScript("OnLeave", OnLeave)
		end

		RegisterControlForRefresh(panel, object)

		return object
	end
end

-- Button
function CFG:CreateButton(panel, name, text, func)
	local object = _G.CreateFrame("Button", "$parent"..name, panel, "UIPanelButtonTemplate")
	object.type = "Button"
	object:SetText(text)
	object:SetWidth(object:GetTextWidth() + 18)
	object:SetScript("OnClick", func)

	return object
end

-- Dial
do
	local function OnShow(self)
		for i = 1, 4 do
			if i > _G.GetNumSpecializations() then
				self[i]:Hide()
				self[i] = nil
			end
		end

		self:SetSize(#self * 14 + (#self - 1) * 2, 14)
		self:SetScript("OnShow", nil)
	end

	local function CalcValue(self)
		local value = 0x00000000

		for i = 1, #self do
			local button = self[i]

			if button:IsPositive() then
				value = E:AddFilterToMask(value, button.value)
			end
		end

		return value
	end

	local function RefreshValue(self)
		local value = self:GetValue()

		for i = 1, #self do
			local button = self[i]

			if E:IsFilterApplied(value, E.PLAYER_SPEC_FLAGS[i]) then
				button:SetButtonState("NORMAL", true) -- positive
			else
				button:SetButtonState("PUSHED", true) -- negative
			end
		end
	end

	local function Enable(self)
		for i = 1, #self do
			self[i]:Enable()
		end

		self.Text:SetVertexColor(1, 0.82, 0)
	end

	local function Disable(self)
		for i = 1, #self do
			self[i]:Disable()
		end

		self.Text:SetVertexColor(0.5, 0.5, 0.5)
	end

	local function Indicator_OnMouseDown(self)
		if not self:IsEnabled() then return end

		if self:GetButtonState() == "NORMAL" then
			self:SetButtonState("PUSHED", true)
		else
			self:SetButtonState("NORMAL", true)
		end
	end

	local function Indicator_OnEnter(self)
		local _, name = _G.GetSpecializationInfo(self:GetID())

		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -4, -4)
		_G.GameTooltip:AddLine(name)
		_G.GameTooltip:Show()
	end

	local function Indicator_OnLeave()
		_G.GameTooltip:Hide()
	end

	local function Indicator_IsPositive(self)
		return self:GetButtonState() == "NORMAL" and true or false
	end

	local function Indicator_Enable(self)
		getmetatable(self).__index.Enable(self)

		self:GetNormalTexture():SetDesaturated(false)
		self:GetPushedTexture():SetDesaturated(false)
	end

	local function Indicator_Disable(self)
		getmetatable(self).__index.Disable(self)

		self:GetNormalTexture():SetDesaturated(true)
		self:GetPushedTexture():SetDesaturated(true)
	end

	function CFG:CreateMaskDial(panel, data)
		local object = _G.CreateFrame("Frame", data.name, panel)
		object:SetSize(14, 14)
		object:EnableMouse(true)
		object:SetScript("OnShow", OnShow)
		object.GetValue = data.get
		object.SetValue = data.set
		object.CalcValue = CalcValue
		object.RefreshValue = RefreshValue
		object.Enable = Enable
		object.Disable = Disable

		for i = 1, 4 do
			local button = _G.CreateFrame("Button", "$parentSpecIndicator"..i, object)
			button:SetSize(14, 14)
			button:SetID(i)
			button:SetNormalTexture("Interface\\Store\\Services")
			button:GetNormalTexture():SetTexCoord(0.02148438, 0.04003906, 0.08105469, 0.09960938)
			button:SetPushedTexture("Interface\\Store\\Services")
			button:GetPushedTexture():SetTexCoord(0.00097656, 0.01953125, 0.08105469, 0.09960938)
			button:SetScript("OnMouseDown", Indicator_OnMouseDown)
			button:SetScript("OnEnter", Indicator_OnEnter)
			button:SetScript("OnLeave", Indicator_OnLeave)
			button.IsPositive = Indicator_IsPositive
			button.Enable = Indicator_Enable
			button.Disable = Indicator_Disable
			button.value = E.PLAYER_SPEC_FLAGS[i]
			object[i] = button

			if i == 1 then
				button:SetPoint("TOPLEFT", 0, 0)
			else
				button:SetPoint("LEFT", object[i - 1], "RIGHT", 2, 0)
			end
		end

		RegisterControlForRefresh(panel, object)

		return object
	end
end

-- Tabbed Frame
do
	local function Tab_OnClick(self)
		_G.PanelTemplates_SetTab(self:GetParent(), self:GetID())

		self:GetParent():SetValue(self:GetID())
		self:GetParent():RefreshValue()
	end

	local function Tab_OnEnter(self)
		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -4, -4)
		_G.GameTooltip:AddLine(self.tooltipText)
		_G.GameTooltip:Show()
	end

	local function Tab_OnLeave()
		_G.GameTooltip:Hide()
	end

	function CFG:CreateTabbedFrame(panel, data)
		local object = _G.CreateFrame("Frame", data.name, data.parent)
		object:SetBackdrop({
			bgFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 16,
			edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		object:SetBackdropColor(0, 0, 0, 1)
		object:SetBackdropBorderColor(0.6, 0.6, 0.6)
		object.GetValue = data.get
		object.SetValue = data.set
		object.RefreshValue = data.refresh

		object.tabs = {}

		for i = 1, #data.tabs do
			local tab = _G.CreateFrame("Button", "$parentTab"..i, object, "TabButtonTemplate")
			tab:SetID(i)
			tab:SetText(data.tabs[i].text)
			tab:SetScript("OnClick", Tab_OnClick)
			tab:SetScript("OnEnter", Tab_OnEnter)
			tab:SetScript("OnLeave", Tab_OnLeave)
			tab.tooltipText = data.tabs[i].tooltip_text
			object.tabs[i] = tab

			_G.PanelTemplates_TabResize(tab, 0, 82)

		end

		for i = 1, #object.tabs do
			if i == 1 then
				object.tabs[i]:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 8, -2)
			else
				object.tabs[i]:SetPoint("LEFT", object.tabs[i - 1], "RIGHT", 0, 0)
			end
		end

		_G.PanelTemplates_SetNumTabs(object, #data.tabs)

		RegisterControlForRefresh(panel, object)

		return object
	end
end

-- Aura List
do
	local activeAuraList

	local function AuraList_OnShow(self)
		activeAuraList = self
	end

	local function AuraList_OnVerticalScroll(self, offset)
		_G.FauxScrollFrame_OnVerticalScroll(self, offset, 30, self.RefreshValue)
	end

	local function Tab_OnClick(self)
		_G.PanelTemplates_SetTab(self:GetParent(), self:GetID())

		self:GetParent():SetValue(self:GetID())
		self:GetParent():RefreshValue()
	end

	local function AddAura()
		local spellID = tonumber(activeAuraList.AddEditBox:GetText())
		local mask = activeAuraList.MaskDial:GetValue()

		if not (spellID and mask) then return end

		local link = _G.GetSpellLink(spellID)

		if link then
			if activeAuraList.table[spellID] then
				activePanel.Log:SetText(string.format(L["LOG_ITEM_ADDED_ERR"], link))
			else
				activeAuraList.AddEditBox:SetText("")

				activeAuraList.table[spellID] = mask
				activeAuraList:RefreshValue()

				activePanel.Log:SetText(string.format(L["LOG_ITEM_ADDED"], link))
			end
		end
	end

	local function RemoveAura(self)
		local spellID = self:GetParent().spellID

		activeAuraList.table[spellID] = nil
		activeAuraList:RefreshValue()
	end

	local function EditBox_OnTextChanged(self, isUserInput)
		if isUserInput then
			local spellID = tonumber(self:GetText())

			if not spellID or spellID > 2147483647 then
				return self:SetText("")
			end

			local link = _G.GetSpellLink(spellID)

			if link then
				activePanel.Log:SetText(string.format(L["LOG_FOUND_ITEM"], link))
			else
				activePanel.Log:SetText(L["LOG_NOTHING_FOUND"])
			end
		end
	end

	local function AuraButton_OnEnter(self)
		if not self.spellID then return end

		_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		_G.GameTooltip:SetSpellByID(self.spellID)
		_G.GameTooltip:Show()
	end

	local function AuraButton_OnLeave()
		_G.GameTooltip:Hide()
	end

	local function Indicator_OnMouseUp(self)
		self:GetParent():SetValue(self:GetParent():CalcValue())
	end

	local function DeleteButton_OnEnter(self)
		self.Icon:SetAlpha(1)
	end

	local function DeleteButton_OnLeave(self)
		self.Icon:SetAlpha(0.5)
	end

	function CFG:CreateAuraList(panel, lData, lIndicatorData, bIndicatorData)
		local object = _G.CreateFrame("ScrollFrame", "$parentAuraList", panel, "FauxScrollFrameTemplate")
		object:SetSize(210, 330) -- 30 * 10 + 6 * 2 + 9 * 2
		object:SetBackdrop({
			bgFile = "Interface\\BUTTONS\\WHITE8X8",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 16,
			edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		object:SetBackdropColor(0, 0, 0, 1)
		object:SetBackdropBorderColor(0.6, 0.6, 0.6)
		object:SetScript("OnShow", AuraList_OnShow)
		object:SetScript("OnVerticalScroll", AuraList_OnVerticalScroll)
		object.GetValue = lData.get
		object.SetValue = lData.set
		object.RefreshValue = lData.refresh

		object.ScrollBar:ClearAllPoints()
		object.ScrollBar:SetPoint("TOPRIGHT", object,"TOPRIGHT", -6, -22)
		object.ScrollBar:SetPoint("BOTTOMRIGHT", object,"BOTTOMRIGHT", -6, 22)

		local buffTab = _G.CreateFrame("Button", "$parentTab1", object, "TabButtonTemplate")
		buffTab.type = "Button"
		buffTab:SetID(1)
		buffTab:SetText(L["BUFFS"])
		buffTab:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 8, -2)
		buffTab:SetScript("OnClick", Tab_OnClick)
		object.BuffTab = buffTab

		local debuffTab = _G.CreateFrame("Button", "$parentTab2", object, "TabButtonTemplate")
		debuffTab.type = "Button"
		debuffTab:SetID(2)
		debuffTab:SetText(L["DEBUFFS"])
		debuffTab:SetPoint("LEFT", buffTab, "RIGHT", 0, 0)
		debuffTab:SetScript("OnClick", Tab_OnClick)
		object.DebuffTab = debuffTab

		_G.PanelTemplates_TabResize(buffTab, 0)
		_G.PanelTemplates_TabResize(debuffTab, 0)
		_G.PanelTemplates_SetNumTabs(object, 2)
		_G.PanelTemplates_SetTab(object, 1)

		local addEditBox = _G.CreateFrame("EditBox", "$parentEditBox", object, "InputBoxInstructionsTemplate")
		addEditBox.type = "EditBox"
		addEditBox:SetSize(120, 22)
		addEditBox:SetAutoFocus(false)
		addEditBox:SetNumeric(true)
		addEditBox.Instructions:SetText("Enter Spell ID")
		addEditBox:SetPoint("TOPLEFT", object, "BOTTOMLEFT", 6, 0)
		addEditBox:SetScript("OnEnterPressed", AddAura)
		addEditBox:HookScript("OnTextChanged", EditBox_OnTextChanged)
		object.AddEditBox = addEditBox

		local addButton = _G.CreateFrame("Button", "$parentAddButton", object, "UIPanelButtonTemplate")
		addButton.type = "Button"
		addButton:SetSize(82, 22)
		addButton:SetText(_G.ADD)
		addButton:SetPoint("LEFT", addEditBox, "RIGHT", 2, 0)
		addButton:SetScript("OnClick", AddAura)
		object.AddButton = addButton

		local maskLabel = object:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		maskLabel:SetPoint("TOPLEFT", addEditBox, "BOTTOMLEFT", -4, -2)
		maskLabel:SetText(L["MASK_COLON"])

		local maskDial = self:CreateMaskDial(object, lIndicatorData)
		maskDial:SetPoint("LEFT", maskLabel, "RIGHT", 2, -1)
		object.MaskDial = maskDial

		object.buttons = {}

		for i = 1, 10 do
			local button = _G.CreateFrame("CheckButton", "$parentButton"..i, object)
			button.type = "Button"
			button:SetHeight(30)
			button:EnableMouse(true)
			button:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue", "ADD")
			button:SetScript("OnEnter", AuraButton_OnEnter)
			button:SetScript("OnLeave", AuraButton_OnLeave)
			object.buttons[i] = button

			local icon = button:CreateTexture(nil, "BACKGROUND", nil, 0)
			icon:SetSize(24, 24)
			icon:SetPoint("LEFT", 3, 0)
			button.Icon = icon

			local text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
			text:SetJustifyH("LEFT")
			text:SetWordWrap(false)
			text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, 2)
			text:SetPoint("RIGHT", button, "RIGHT", -4, 0)
			button.Text = text

			local indicator = self:CreateMaskDial(button, bIndicatorData)
			indicator:SetFrameLevel(button:GetFrameLevel() + 4)
			indicator:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 4, -2)
			for j = 1, #indicator do
				indicator[j]:SetScript("OnMouseUp", Indicator_OnMouseUp)
			end
			button.Indicator = indicator

			local deleteButton = _G.CreateFrame("Button", "$parentDeleteButton", button)
			deleteButton:SetSize(16, 16)
			deleteButton:SetPoint("BOTTOMRIGHT", 0, 0)
			deleteButton:SetScript("OnClick", RemoveAura)
			deleteButton:SetScript("OnEnter", DeleteButton_OnEnter)
			deleteButton:SetScript("OnLeave", DeleteButton_OnLeave)
			button.DeleteButton = deleteButton

			local deleteButtonIcon = deleteButton:CreateTexture(nil, "ARTWORK")
			deleteButtonIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
			deleteButtonIcon:SetDesaturated(true)
			deleteButtonIcon:SetVertexColor(0.9, 0.15, 0.15)
			deleteButtonIcon:SetAlpha(0.5)
			deleteButtonIcon:SetPoint("TOPLEFT", 1, -1)
			deleteButtonIcon:SetPoint("BOTTOMRIGHT", -1, 1)
			deleteButton.Icon = deleteButtonIcon

			local bg = button:CreateTexture(nil, "BACKGROUND", nil, -8)
			bg:SetAllPoints()
			bg:SetColorTexture(0.15, 0.15, 0.15)
			button.Bg = bg

			if i == 1 then
				button:SetPoint("TOPLEFT", 6, -6)
			else
				button:SetPoint("TOPLEFT", object.buttons[i - 1], "BOTTOMLEFT", 0, -2)
			end

			button:SetPoint("RIGHT", object.ScrollBar, "LEFT", -2, -6)
		end

		object:SetValue(1)

		RegisterControlForRefresh(panel, object)

		return object
	end
end

-- Slider
do
	local function RefreshValue(self)
		local value = self:GetValue()

		self.value = value
		self:SetDisplayValue(value)
		self.CurrentValue:SetText(value)
	end

	local function Slider_OnValueChanged(self, value, userInput)
		if userInput then
			value = tonumber(string.format("%d", value))

			if value ~= self.value then
				self:SetValue(value)
				self:RefreshValue()
			end
		end
	end

	function CFG:CreateSlider(panel, data) --[[, name, text, stepValue, minValue, maxValue)]]
		local object = _G.CreateFrame("Slider", data.name, data.parent, "OptionsSliderTemplate")
		object.type = "Slider"
		object:SetMinMaxValues(data.min, data.max)
		object:SetValueStep(data.step)
		object:SetObeyStepOnDrag(true)
		object.SetDisplayValue = object.SetValue -- default
		object.GetValue = data.get
		object.SetValue = data.set
		object.RefreshValue = RefreshValue
		object:SetScript("OnValueChanged", Slider_OnValueChanged)

		local text = _G[object:GetName().."Text"]
		text:SetText(data.text)
		text:SetVertexColor(1, 0.82, 0)
		object.Text = text

		local lowText = _G[object:GetName().."Low"]
		lowText:SetText(data.min)
		object.LowValue = lowText

		local curText = object:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		curText:SetPoint("TOP", object, "BOTTOM", 0, 3)
		object.CurrentValue = curText

		local highText = _G[object:GetName().."High"]
		highText:SetText(data.max)
		object.HighValue = highText

		RegisterControlForRefresh(panel, object)

		return object
	end
end

-- Drop Down Menu
do
	local function RefreshValue(self)
		_G.UIDropDownMenu_Initialize(self, self.initialize)
		_G.UIDropDownMenu_SetSelectedValue(self, self:GetValue())
	end

	function CFG:CreateDropDownMenu(panel, data)
		local object = _G.CreateFrame("Frame",  data.name, data.parent, "UIDropDownMenuTemplate")
		object.type = "DropDownMenu"
		object.SetValue = data.set
		object.GetValue = data.get
		object.RefreshValue = RefreshValue
		_G.UIDropDownMenu_Initialize(object, data.init)
		_G.UIDropDownMenu_SetWidth(object, data.width or 128)

		local text = object:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		text:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 16, 3)
		text:SetJustifyH("LEFT")
		text:SetText(data.text)
		object.Label = text

		RegisterControlForRefresh(panel, object)

		return object
	end
end

-- Info Button
local function InfoButton_OnEnter(self)
	_G.HelpPlate_TooltipHide()

	if self.tooltipDir == "UP" then
		_G.HelpPlateTooltip.ArrowUP:Show()
		_G.HelpPlateTooltip.ArrowGlowUP:Show()
		_G.HelpPlateTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
	elseif self.tooltipDir == "DOWN" then
		_G.HelpPlateTooltip.ArrowDOWN:Show()
		_G.HelpPlateTooltip.ArrowGlowDOWN:Show()
		_G.HelpPlateTooltip:SetPoint("TOP", self, "BOTTOM", 0, -10)
	elseif self.tooltipDir == "LEFT" then
		_G.HelpPlateTooltip.ArrowLEFT:Show()
		_G.HelpPlateTooltip.ArrowGlowLEFT:Show()
		_G.HelpPlateTooltip:SetPoint("RIGHT", self, "LEFT", -10, 0)
	elseif self.tooltipDir == "RIGHT" then
		_G.HelpPlateTooltip.ArrowRIGHT:Show()
		_G.HelpPlateTooltip.ArrowGlowRIGHT:Show()
		_G.HelpPlateTooltip:SetPoint("LEFT", self, "RIGHT", 10, 0)
	end

	_G.HelpPlateTooltip.Text:SetText(self.toolTipText)
	_G.HelpPlateTooltip:Show()
end

local function InfoButton_OnLeave()
	_G.HelpPlate_TooltipHide()
end

function CFG:CreateInfoButton(parent, data)
	local object = _G.CreateFrame("Button", data.name, parent)
	object:SetSize(24, 24)
	object:SetScript("OnClick", data.click)
	object:SetScript("OnEnter", InfoButton_OnEnter)
	object:SetScript("OnLeave", InfoButton_OnLeave)
	object.toolTipText = data.tooltip_text
	object.tooltipDir = "UP"

	object:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

	local texture = object:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetTexture("Interface\\COMMON\\help-i")
	texture:SetTexCoord(13 / 64, 51 / 64, 13 / 64, 51 / 64)
	texture:SetBlendMode("BLEND")

	return object
end

-- Warning Plate
function CFG:CreateWarningPlate(parent, data)
	local object = _G.CreateFrame("Frame", data.name, parent, "ThinBorderTemplate")
	object:EnableMouse(true)
	object:Show()

	for i = 1, #object.Textures do
		object.Textures[i]:SetVertexColor(1, 0.82, 0)
	end

	local texture = object:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\warning-bg", true, true)
	texture:SetHorizTile(true)
	texture:SetVertTile(true)
	texture:SetAllPoints()
	texture:SetVertexColor(1, 0.82, 0, 0.5)

	return object
end

local function OpenToCategory(category)
	if not _G[category] then
		CFG:General_Init()
		CFG:Bars_Init()
		CFG:AuraTracker_Init()
		CFG:Blizzard_Init()
		CFG:Tooltips_Init()
		CFG:UnitFrames_Init()

		_G.InterfaceAddOnsList_Update()
		_G.InterfaceOptionsOptionsFrame_RefreshAddOns()
		return _G.InterfaceOptionsFrame_OpenToCategory(_G[category])
	end

	if not _G[category]:IsShown() then
		_G.InterfaceOptionsFrame_OpenToCategory(_G[category])
	else
		_G.InterfaceOptionsFrameOkay_OnClick(_G.InterfaceOptionsFrame)
	end
end

-----------------
-- INITIALISER --
-----------------

function CFG:Init()
	_G.SetActionBarToggles(false, false, false, false)
	_G.MultiActionBar_Update()
	_G.UIParent_ManageFramePositions()

	local warningPlate = CFG:CreateWarningPlate(_G.InterfaceOptionsActionBarsPanel,
		{
			name = "$parentLSUIBarsWarning"
		})
	warningPlate:SetFrameLevel(_G.InterfaceOptionsActionBarsPanelBottomLeft:GetFrameLevel() + 1)
	warningPlate:SetPoint("TOPLEFT", "InterfaceOptionsActionBarsPanelBottomLeft", "TOPLEFT", -4, 4)
	warningPlate:SetPoint("BOTTOM", "InterfaceOptionsActionBarsPanelRightTwo", "BOTTOM", 0, -4)
	warningPlate:SetPoint("RIGHT", "InterfaceOptionsActionBarsPanelBottomRightText", "RIGHT", 4, 0)

	local infoButton = CFG:CreateInfoButton(warningPlate,
		{
			name = "$parentLSUIBarsInfo",
			tooltip_text = L["ACTION_BAR_INFO_TOOLTIP"],
			click = function()
				OpenToCategory("LSUIBarsConfigPanel")
			end
		})
	infoButton:SetPoint("TOPRIGHT", warningPlate, "TOPRIGHT", -8, -8)

	P:AddCommand("", function()
		OpenToCategory("LSUIGeneralConfigPanel")
	end)
end
