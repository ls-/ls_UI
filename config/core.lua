local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local CFG = E:AddModule("Config")

local UIDropDownMenu_SetSelectedValue, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton =
	UIDropDownMenu_SetSelectedValue, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton

local Panels = {}

local function MaskDial_OnShow(self)
	for i = 1, 4 do
		if i > GetNumSpecializations() then
			self[i]:Hide()
			self[i] = nil
		end
	end

	self:SetSize(#self * 14 + (#self - 1) * 2, 14)
	self:SetScript("OnShow", nil)
end

local function MaskDial_GetMask(self)
	local mask = 0x00000000

	for i = 1, #self do
		local button = self[i]

		if button:IsPositive() then
			mask = E:AddFilterToMask(mask, button.value)
		end
	end

	return mask
end

local function MaskDial_SetMask(self, mask)
	for i = 1, #self do
		local button = self[i]

		if E:IsFilterApplied(mask, E.PLAYER_SPEC_FLAGS[i]) then
			button:SetButtonState("NORMAL", true) -- positive
		else
			button:SetButtonState("PUSHED", true) -- negative
		end
	end
end

local function MaskDial_Enable(self)
	for i = 1, #self do
		self[i]:Enable()
	end

	self.Text:SetVertexColor(1, 0.82, 0)
end

local function MaskDial_Disable(self)
	for i = 1, #self do
		self[i]:Disable()
	end

	self.Text:SetVertexColor(0.5, 0.5, 0.5)
end

local function MaskDialIndicator_OnMouseDown(self)
	if not self:IsEnabled() then return end

	if self:GetButtonState() == "NORMAL" then
		self:SetButtonState("PUSHED", true)
	else
		self:SetButtonState("NORMAL", true)
	end
end

local function MaskDialIndicator_OnEnter(self)
	local _, name = GetSpecializationInfo(self:GetID())
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -4, -4)
	GameTooltip:AddLine(name)
	GameTooltip:Show()
end

local function MaskDialIndicator_OnLeave(self)
	GameTooltip:Hide()
end

local function MaskDialIndicator_IsPositive(self)
	return self:GetButtonState() == "NORMAL" and true or false
end

local function MaskDialIndicator_Enable(self)
	getmetatable(self).__index.Enable(self)

	self:GetNormalTexture():SetDesaturated(false)
	self:GetPushedTexture():SetDesaturated(false)
end

local function MaskDialIndicator_Disable(self)
	getmetatable(self).__index.Disable(self)

	self:GetNormalTexture():SetDesaturated(true)
	self:GetPushedTexture():SetDesaturated(true)
end

function CFG:CreateMaskDial(parent, name, text)
	local object = CreateFrame("Frame", "$parent"..name, parent)
	object:SetSize(56, 14)
	object:EnableMouse(true)
	object:SetScript("OnShow", MaskDial_OnShow)
	object.GetMask = MaskDial_GetMask
	object.SetMask = MaskDial_SetMask
	object.Enable = MaskDial_Enable
	object.Disable = MaskDial_Disable

	for i = 1, 4 do
		local button = CreateFrame("Button", "$parentSpecIndicator"..i, object)
		button:SetSize(14, 14)
		button:SetID(i)
		button:SetNormalTexture("Interface\\Store\\Services")
		button:GetNormalTexture():SetTexCoord(0.02148438, 0.04003906, 0.08105469, 0.09960938)
		button:SetPushedTexture("Interface\\Store\\Services")
		button:GetPushedTexture():SetTexCoord(0.00097656, 0.01953125, 0.08105469, 0.09960938)
		button:SetScript("OnMouseDown", MaskDialIndicator_OnMouseDown)
		button:SetScript("OnEnter", MaskDialIndicator_OnEnter)
		button:SetScript("OnLeave", MaskDialIndicator_OnLeave)
		button.IsPositive = MaskDialIndicator_IsPositive
		button.Enable = MaskDialIndicator_Enable
		button.Disable = MaskDialIndicator_Disable
		button.value = E.PLAYER_SPEC_FLAGS[i]
		object[i] = button

		if i == 1 then
			button:SetPoint("LEFT", 0, 0)
		else
			button:SetPoint("LEFT", object[i - 1], "RIGHT", 2, 0)
		end
	end

	local label = E:CreateFontString(object, 10, "$parentText", true)
	label:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, 2)
	label:SetVertexColor(1, 0.82, 0)
	label:SetText(text)
	object.Text = label

	return object
end

local function StatusLogHyperlink_OnEnter(self, linkData, link)
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
	GameTooltip:SetHyperlink(link)
	GameTooltip:Show()
end

local function StatusLogHyperlink_OnLeave(self)
	GameTooltip:Hide()
end

function CFG:CreateStatusLog(parent)
	local object = CreateFrame("SimpleHTML", "$parentStatusLog", parent)
	object:SetHeight(20)
	object:SetFontObject("LS10Font")
	object:SetJustifyH("LEFT")
	object:SetJustifyV("TOP")

	object:SetScript("OnHyperlinkEnter", StatusLogHyperlink_OnEnter)
	object:SetScript("OnHyperlinkLeave", StatusLogHyperlink_OnLeave)

	return object
end

function CFG:CreateTextLabel(parent, size, text)
	local object = E:CreateFontString(parent, size, nil, true)
	object:SetJustifyH("LEFT")
	object:SetJustifyV("TOP")
	object:SetWordWrap(true)
	object:SetNonSpaceWrap(true)
	object:SetText(text)

	return object
end

local function CheckButton_SetValue(self, value)
	self:SetChecked(value)
end

local function CheckButton_GetValue(self)
	return self:GetChecked()
end

local function CheckButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	GameTooltip:Show()
end

local function CheckButton_OnLeave(self)
	GameTooltip:Hide()
end

function CFG:CreateCheckButton(parent, name, text, tooltiptext)
	local object = CreateFrame("CheckButton", "$parent"..name, parent, "InterfaceOptionsCheckButtonTemplate")
	object.type = "Button"
	object.SetValue = CheckButton_SetValue
	object.GetValue = CheckButton_GetValue
	object.Text:SetText(text)

	if tooltiptext then
		object.tooltipText = tooltiptext
		object:SetScript("OnEnter", CheckButton_OnEnter)
		object:SetScript("OnLeave", CheckButton_OnLeave)
	end

	return object
end

local function ValidateValue(self, value)
	local button
	for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
		button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i]
		if button:IsShown() and button.value == value then
			return value
		end
	end

	return _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button1"].value
end

local function DropDownMenu_SetValue(self, value)
	self.oldValue = self.value
	self.value = value
	UIDropDownMenu_SetSelectedValue(self, value)
end

local function DropDownMenu_GetValue(self)
	return UIDropDownMenu_GetSelectedValue(self)
end

local function DropDownMenu_RefreshValue(self)
	UIDropDownMenu_Initialize(self, self.initialize)
	self.oldValue = self.value
	self.value = ValidateValue(self, self.value)
	UIDropDownMenu_SetSelectedValue(self, self.value)
end

local function RegisterControlForRefresh(parent, control)
	if not parent or not control then
		return
	end

	parent.controls = parent.controls or {}
	tinsert(parent.controls, control)
end

function CFG:CreateDropDownMenu(parent, name, text, func)
	local object = CreateFrame("Frame", "$parent"..name, parent, "UIDropDownMenuTemplate")
	object.type = "DropDownMenu"
	object.SetValue = DropDownMenu_SetValue
	object.GetValue = DropDownMenu_GetValue
	object.RefreshValue = DropDownMenu_RefreshValue
	UIDropDownMenu_Initialize(object, func)

	local label = E:CreateFontString(object, 10, "$parentLabel", true)
	label:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 16, 3)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("MIDDLE")
	label:SetText(text)
	label:SetVertexColor(1, 0.82, 0)
	object.Text = label

	RegisterControlForRefresh(parent, object)

	return object
end

local function Slider_SetValue(self, value)
	self:SetDisplayValue(value)
	self.CurrentValue:SetText(value)
	self.oldValue = self.value
	self.value = value
end

function CFG:CreateSlider(parent, name, text, minValue, maxValue)
	local object = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	object.type = "Slider"
	object:SetMinMaxValues(minValue, maxValue)
	object:SetValueStep(2)
	object:SetObeyStepOnDrag(true)
	object.SetDisplayValue = object.SetValue
	object.SetValue = Slider_SetValue
	object:SetScript("OnValueChanged", function(self, value)
		object.CurrentValue:SetText(value)
		self.value = value
	end)

	local label = _G[object:GetName().."Text"]
	label:SetText(text)
	label:SetVertexColor(1, 0.82, 0)
	object.Text = label

	local lowText = _G[object:GetName().."Low"]
	lowText:SetText(minValue)
	object.LowValue = lowText

	local curText = object:CreateFontString("$parentCurrent", "ARTWORK", "GameFontHighlightSmall")
	curText:SetPoint("TOP", object, "BOTTOM", 0, 3)
	object.CurrentValue = curText

	local highText = _G[object:GetName().."High"]
	highText:SetText(maxValue)
	object.HighValue = highText

	return object
end

function CFG:CreateDivider(parent, text)
	local object = parent:CreateTexture(nil, "ARTWORK")
	object:SetHeight(4)
	object:SetPoint("LEFT", 10, 0)
	object:SetPoint("RIGHT", -10, 0)
	object:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
	object:SetTexCoord(0, 1, 0.0625, 0.65625)
	object:SetAlpha(0.5)

	local label = E:CreateFontString(parent, 14)
	label:SetPoint("LEFT", object, "LEFT", 12, 1)
	label:SetPoint("RIGHT", object, "RIGHT", -12, 1)
	label:SetText(text)
	label:SetVertexColor(1, 0.82, 0)
	object.Text = label

	return object
end

local function InfoButton_OnEnter(self)
	_G.HelpPlate_TooltipHide()

	if self.tooltipDir == "UP" then
		HelpPlateTooltip.ArrowUP:Show()
		HelpPlateTooltip.ArrowGlowUP:Show()
		HelpPlateTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10)
	elseif self.tooltipDir == "DOWN" then
		HelpPlateTooltip.ArrowDOWN:Show()
		HelpPlateTooltip.ArrowGlowDOWN:Show()
		HelpPlateTooltip:SetPoint("TOP", self, "BOTTOM", 0, -10)
	elseif self.tooltipDir == "LEFT" then
		HelpPlateTooltip.ArrowLEFT:Show()
		HelpPlateTooltip.ArrowGlowLEFT:Show()
		HelpPlateTooltip:SetPoint("RIGHT", self, "LEFT", -10, 0)
	elseif self.tooltipDir == "RIGHT" then
		HelpPlateTooltip.ArrowRIGHT:Show()
		HelpPlateTooltip.ArrowGlowRIGHT:Show()
		HelpPlateTooltip:SetPoint("LEFT", self, "RIGHT", 10, 0)
	end

	HelpPlateTooltip.Text:SetText(self.toolTipText)
	HelpPlateTooltip:Show()
end

local function InfoButton_OnLeave(self)
	_G.HelpPlate_TooltipHide()
end

function CFG:CreateInfoButton(parent, name, tooltipText)
	local object = _G.CreateFrame("Button", "$parent"..name, parent)
	object:SetSize(16, 16)
	object:SetScript("OnEnter", InfoButton_OnEnter)
	object:SetScript("OnLeave", InfoButton_OnLeave)
	object.toolTipText = tooltipText
	object.tooltipDir = "UP"

	object:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")

	local texture = object:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetTexture("Interface\\COMMON\\help-i")
	texture:SetTexCoord(13 / 64, 51 / 64, 13 / 64, 51 / 64)
	texture:SetBlendMode("BLEND")

	return object
end

local function ReloadUIButton_OnClick(self)
	for _, panel in next, Panels do
		if panel.settings then
			E:ApplySettings(panel.settings, C)
		end
	end

	ReloadUI()
end

function CFG:CreateReloadUIButton(parent)
	local object = CreateFrame("Button", "$parentReloadUIButton", parent, "UIPanelButtonTemplate")
	object.type = "Button"
	object:SetText(RELOADUI)
	object:SetWidth(object:GetTextWidth() + 18)
	object:SetScript("OnClick", ReloadUIButton_OnClick)

	return object
end

local function Controller_OnClick(self)
	CFG:ToggleDependantControls(self)
end

function CFG:SetupController(panel, controller)
	if not controller then return end

	panel.controllers = panel.controllers or {}
	tinsert(panel.controllers, controller)

	controller:HookScript("OnClick", Controller_OnClick)
end

local function ButtonChild_Enable(self)
	getmetatable(self).__index.Enable(self)

	if self.Text then
		self.Text:SetVertexColor(1, 1, 1)
	end

	if self.Icon then
		self.Icon:SetDesaturated(false)
	end
end

local function ButtonChild_Disable(self)
	getmetatable(self).__index.Disable(self)

	if self.Text then
		self.Text:SetVertexColor(0.5, 0.5, 0.5)
	end

	if self.Icon then
		self.Icon:SetDesaturated(true)
	end
end

local function DropDownChild_Enable(self)
	UIDropDownMenu_EnableDropDown(self)
end

local function DropDownChild_Disable(self)
	UIDropDownMenu_DisableDropDown(self)
end

local function SliderChild_Enable(self)
	getmetatable(self).__index.Enable(self)

	if self.Text then
		self.Text:SetVertexColor(1, 0.82, 0)
	end

	if self.LowValue then
		self.LowValue:SetVertexColor(1, 1, 1)
	end

	if self.CurrentValue then
		self.CurrentValue:SetVertexColor(1, 1, 1)
	end

	if self.HighValue then
		self.HighValue:SetVertexColor(1, 1, 1)
	end
end

local function SliderChild_Disable(self)
	getmetatable(self).__index.Disable(self)

	if self.Text then
		self.Text:SetVertexColor(0.5, 0.5, 0.5)
	end

	if self.LowValue then
		self.LowValue:SetVertexColor(0.5, 0.5, 0.5)
	end

	if self.CurrentValue then
		self.CurrentValue:SetVertexColor(0.5, 0.5, 0.5)
	end

	if self.HighValue then
		self.HighValue:SetVertexColor(0.5, 0.5, 0.5)
	end
end

function CFG:SetupControlDependency(parent, child, setResersed)
	if not parent then return end

	parent.children = parent.children or {}
	tinsert(parent.children, child)

	if child.type == "Button" then
		if setResersed then
			child.Enable = ButtonChild_Disable
			child.Disable = ButtonChild_Enable
		else
			child.Enable = ButtonChild_Enable
			child.Disable = ButtonChild_Disable
		end
	elseif child.type == "DropDownMenu" then
		if setResersed then
			child.Enable = DropDownChild_Disable
			child.Disable = DropDownChild_Enable
		else
			child.Enable = DropDownChild_Enable
			child.Disable = DropDownChild_Disable
		end
	elseif child.type == "Slider" then
		if setResersed then
			child.Enable = SliderChild_Disable
			child.Disable = SliderChild_Enable
		else
			child.Enable = SliderChild_Enable
			child.Disable = SliderChild_Disable
		end
	end
end

function CFG:ToggleDependantControls(parent, forceDisable)
	if InCombatLockdown() or not parent.children then return end

	if not parent:GetValue() or forceDisable then
		for _, child in next, parent.children do
			child:Disable()
		end
	else
		for _, child in next, parent.children do
			child:Enable()
		end
	end
end

local function OptionsPanelOkay(panel)
	E:ApplySettings(panel.settings, C)
end

local function OptionsPanelRefresh(panel)
	E:FetchSettings(panel.settings, C)

	for _, control in next, panel.controls do
		if control.RefreshValue then
			control:RefreshValue()
		end
	end
end

local function OptionsPanelDefault(panel)
	E:FetchSettings(panel.settings, D)
end

function CFG:AddCatergory(panel)
	panel.okay = OptionsPanelOkay
	panel.cancel = OptionsPanelOkay
	panel.refresh = OptionsPanelRefresh
	panel.default = OptionsPanelDefault

	InterfaceOptions_AddCategory(panel)
	tinsert(Panels, panel)
end

local function LSConfigFrameToggle()
	InterfaceOptionsFrame_OpenToCategory(LSGeneralConfigPanel)
	InterfaceOptionsFrame_OpenToCategory(LSGeneralConfigPanel)
end

function CFG:Initialize()
	CFG:General_Initialize()
	CFG:UFAuras_Initialize()
	CFG:B_Initialize()
	CFG:AT_Initialize()
	-- CFG:NP_Initialize()

	SLASH_LSCONFIG1 = "/lsconfig"
	SlashCmdList["LSCONFIG"] = LSConfigFrameToggle
end
