local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local CFG = E:AddModule("Config")

local UIDropDownMenu_SetSelectedValue, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton =
	UIDropDownMenu_SetSelectedValue, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton

CFG.Panels = {}

function CFG:CreateTextLabel(parent, size, text)
	local object = E:CreateFontString(parent, size, nil, true, nil, true)
	object:SetJustifyH("LEFT")
	object:SetJustifyV("TOP")
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
	GameTooltip:AddLine(self.tooltipText)
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

function CFG:CreateDropDownMenu(parent, name, text, func)
	local object = CreateFrame("Frame", "$parent"..name, parent, "UIDropDownMenuTemplate")
	object.type = "DropDownMenu"
	object.SetValue = DropDownMenu_SetValue
	object.GetValue = DropDownMenu_GetValue
	object.RefreshValue = DropDownMenu_RefreshValue
	UIDropDownMenu_Initialize(object, func)

	local label = E:CreateFontString(object, 12, "$parentLabel", true, nil, true)
	label:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 16, 3)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("MIDDLE")
	label:SetText(text)
	label:SetVertexColor(1, 0.82, 0)
	object.Text = label

	CFG:RegisterControlForRefresh(parent, object)

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
	object:SetPoint("RIGHT", 10, 0)
	object:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
	object:SetTexCoord(0, 1, 0.0625, 0.65625)
	object:SetAlpha(0.5)

	local label = E:CreateNewFontString(parent, 14)
	label:SetPoint("LEFT", object, "LEFT", 12, 1)
	label:SetPoint("RIGHT", object, "RIGHT", -12, 1)
	label:SetText(text)
	label:SetVertexColor(1, 0.82, 0)
	object.Text = label

	return object
end

local function ReloadUIButton_OnClick(self)
	for _, panel in next, CFG.Panels do
		E:ApplySettings(panel.settings, C)
	end

	ReloadUI()
end

function CFG:CreateReloadUIButton(parent)
	local object = CreateFrame("CheckButton", "$parentReloadUIButton", parent, "UIPanelButtonTemplate")
	object.type = "Button"
	object:SetText(RELOADUI)
	object:SetWidth(object:GetTextWidth() + 18)
	object:SetScript("OnClick", ReloadUIButton_OnClick)

	return object
end

function CFG:OptionsPanelOkay(panel)
	E:ApplySettings(panel.settings, C)
end

function CFG:OptionsPanelRefresh(panel)
	E:FetchSettings(panel.settings, C)

	for _, control in next, panel.controls do
		if control.RefreshValue then
			control:RefreshValue()
		end
	end
end

function CFG:OptionsPanelDefault(panel)
	E:FetchSettings(panel.settings, D)
end

function CFG:RegisterControlForRefresh(parent, control)
	if not parent or not control then
		return
	end

	parent.controls = parent.controls or {}
	tinsert(parent.controls, control)
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

local function LSConfigFrameToggle()
	InterfaceOptionsFrame_OpenToCategory(LSGeneralConfigPanel)
	InterfaceOptionsFrame_OpenToCategory(LSGeneralConfigPanel)
end

function CFG:Initialize()
	CFG:General_Initialize()
	CFG:B_Initialize()
	CFG:AT_Initialize()
	CFG:NP_Initialize()

	SLASH_LSCONFIG1 = "/lsconfig"
	SlashCmdList["LSCONFIG"] = LSConfigFrameToggle
end
