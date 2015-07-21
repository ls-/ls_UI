local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D

E.CFG = CreateFrame("Frame")

local CFG = E.CFG

local UIDropDownMenu_SetSelectedValue, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton =
	UIDropDownMenu_SetSelectedValue, UIDropDownMenu_GetSelectedValue, UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton

function CFG:CreateTextLabel(parent, size, text)
	local object = E:CreateFontString(parent, size, nil, true, nil, true)
	object:SetJustifyH("LEFT")
	object:SetJustifyV("MIDDLE")
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

local function DropDownMenu_SetValue(self, value)
	self.value = value
	UIDropDownMenu_SetSelectedValue(self, value)
end

local function DropDownMenu_GetValue(self)
	return UIDropDownMenu_GetSelectedValue(self)
end

local function DropDownMenu_OnShow(self)
	UIDropDownMenu_Initialize(self, self.initialize)
	UIDropDownMenu_SetSelectedValue(self, self.value)
end

local function DropDownMenu_OnClick(self)
	self.owner.GrowthDirectionDropDownMenu:SetValue(self.value)

	if self.owner.StatusLog then
		self.owner.StatusLog:SetText("|cff26a526Success!|r This setting will be applied on next UI reload.")
	end
end

function CFG:GrowthDirectionDropDownMenu_Initialize(...)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "Right"
	info.func = DropDownMenu_OnClick
	info.value = "RIGHT"
	info.owner = self:GetParent()
	if info.value == selectedValue then
		info.checked = 1
	else
		info.checked = nil
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info.text = "Left"
	info.func = DropDownMenu_OnClick
	info.value = "LEFT"
	info.owner = self:GetParent()
	if info.value == selectedValue then
		info.checked = 1
	else
		info.checked = nil
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info.text = "Up"
	info.func = DropDownMenu_OnClick
	info.value = "UP"
	info.owner = self:GetParent()
	if info.value == selectedValue then
		info.checked = 1
	else
		info.checked = nil
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info.text = "Down"
	info.func = DropDownMenu_OnClick
	info.value = "DOWN"
	info.owner = self:GetParent()
	if info.value == selectedValue then
		info.checked = 1
	else
		info.checked = nil
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

function CFG:CreateDropDownMenu(parent, name, text, func)
	local object = CreateFrame("Frame", "$parent"..name, parent, "UIDropDownMenuTemplate")
	object.type = "DropDownMenu"
	object.SetValue = DropDownMenu_SetValue
	object.GetValue = DropDownMenu_GetValue
	object:HookScript("OnShow", DropDownMenu_OnShow)
	UIDropDownMenu_Initialize(object, CFG[func])

	local label = E:CreateFontString(object, 12, "$parentLabel", true, nil, true)
	label:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 16, 3)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("MIDDLE")
	label:SetText(text)
	object.Text = label

	return object
end

function CFG:OptionsPanelOkay(panel)
	-- print("OKAY", panel:GetName(), self:GetName())
	E:ApplySettings(panel.settings, C)
end

function CFG:OptionsPanelRefresh(panel)
	-- print("REFRESH", panel:GetName(), self:GetName())
	E:FetchSettings(panel.settings, C)
end

function CFG:OptionsPanelDefault(panel)
	-- print("DEFAULT", panel:GetName(), self:GetName())
	E:FetchSettings(panel.settings, D)
end

function CFG:SetupControlDependency(parent, child)
	if not parent then return end

	parent.children = parent.children or {}
	tinsert(parent.children, child)

	if child.type == "Button" then

		child.Disable = function(self)
			getmetatable(self).__index.Disable(self)

			if child.Text then
				child.Text:SetVertexColor(0.5, 0.5, 0.5)
			end

			if child.Icon then
				child.Icon:SetDesaturated(true)
			end
		end

		child.Enable = function(self)
			getmetatable(self).__index.Enable(self)

			if child.Text then
				child.Text:SetVertexColor(1, 1, 1)
			end

			if child.Icon then
				child.Icon:SetDesaturated(false)
			end
		end
	elseif child.type == "DropDownMenu" then
		child.Disable = function(self)
			UIDropDownMenu_DisableDropDown(self)
		end

		child.Enable = function(self)
			UIDropDownMenu_EnableDropDown(self)
		end
	end
end

function CFG:ToggleDependantControls(forceDisable)
	if not self:GetValue() or forceDisable then
		for _, child in next, self.children do
			child:Disable()
		end
	else
		for _, child in next, self.children do
			child:Enable()
		end
	end
end
