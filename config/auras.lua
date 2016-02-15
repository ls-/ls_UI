local _, ns = ...
local E, C, M, D = ns.E, ns.C, ns.M, ns.D
local CFG = E:GetModule("Config")
local UF = E:GetModule("UnitFrames")

local FauxScrollFrame_Update, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_SetOffset, FauxScrollFrame_GetOffset =
	FauxScrollFrame_Update, FauxScrollFrame_OnVerticalScroll, FauxScrollFrame_SetOffset, FauxScrollFrame_GetOffset
local PanelTemplates_SetNumTabs, PanelTemplates_Tab_OnClick, PanelTemplates_SetTab, PanelTemplates_TabResize =
	PanelTemplates_SetNumTabs, PanelTemplates_Tab_OnClick, PanelTemplates_SetTab, PanelTemplates_TabResize

local sortedAuras = {}
local activeConfig

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

		for i = 1, 12 do
			aura = bufftable[i + offset]
			button = buttons[i]

			if aura then
				button:Show()
				button.Text:SetText(aura.name)
				button.Icon:SetTexture(aura.icon)
				button.spellID = aura.id
				button.value = aura.filter

				button.Indicator:Update(aura.filter)

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

local function LSUFAuraList_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 30, LSUFAuraList_Update)
end

local function LSUFAuraListTab_OnClick(self)
	local auraList = self:GetParent()

	FauxScrollFrame_SetOffset(auraList, 0)

	PanelTemplates_Tab_OnClick(self, auraList)

	LSUFAuraList_Update(auraList)
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
	self.UnitSelector.Indicator:Update(self.UnitSelector.EditButton:GetValue())
end

local function SpecIndicator_OnShow(self)
	if not self[1] then
		self:SetSize(GetNumSpecializations() * 13, 13)
		for i = 1 , GetNumSpecializations() do
			local indicator = self:CreateTexture(nil, "ARTWORK")
			indicator:SetTexture("Interface\\Store\\Services")
			indicator:SetTexCoord(0.02148438, 0.04003906, 0.08105469, 0.09960938)
			indicator:SetSize(13, 13)
			self[i] = indicator

			if i == 1 then
				indicator:SetPoint("LEFT", 0, 0)
			else
				indicator:SetPoint("LEFT", self[i - 1], "RIGHT", 0, 0)
			end
		end
	end
end

local function SpecIndicator_Update(self, mask, index)
	if index and index <= GetNumSpecializations() then
		if E:IsFilterApplied(mask, M.PLAYER_SPEC_FLAGS[index]) then
			self[index]:SetTexCoord(0.02148438, 0.04003906, 0.08105469, 0.09960938)
		else
			self[index]:SetTexCoord(0.00097656, 0.01953125, 0.08105469, 0.09960938)
		end
	else
		for i = 1 , GetNumSpecializations() do
			if E:IsFilterApplied(mask, M.PLAYER_SPEC_FLAGS[i]) then
				self[i]:SetTexCoord(0.02148438, 0.04003906, 0.08105469, 0.09960938)
			else
				self[i]:SetTexCoord(0.00097656, 0.01953125, 0.08105469, 0.09960938)
			end
		end
	end
end

local function IsFilterItemChecked(self)
	if not self.owner then return end

	return E:IsFilterApplied(self.owner.value or 0, self.arg1)
end

local function IsAnyFilterItemChecked(self)
	local button
	for i = 1, self:GetID() - 1 do
		button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i]

		if IsFilterItemChecked(button) then
			return false
		end
	end

	return true
end



local function UnitFilterDropDownMenu_OnClick(self, arg1, arg2, isChecked)
	if arg1 == 0x00000000 then
		self.owner.value = arg1
	else
		if isChecked then
			self.owner.value = E:AddFilterToMask(self.owner.value, arg1)
		else
			self.owner.value = E:DeleteFilterFromMask(self.owner.value, arg1)
		end
	end

	if self.owner.Indicator then
		self.owner.Indicator:Update(self.owner.value, self:GetID())
	end

	UIDropDownMenu_Refresh(self.owner.DropDown)
end

local function UnitFilterDropDown_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()

	for i = 1 , GetNumSpecializations() do
		local _, name = GetSpecializationInfo(i)
		info.text = name
		info.func = UnitFilterDropDownMenu_OnClick
		info.arg1 = M.PLAYER_SPEC_FLAGS[i]
		info.owner = self:GetParent()
		info.checked = IsFilterItemChecked
		info.isNotRadio = true;
		info.keepShownOnClick = true;
		UIDropDownMenu_AddButton(info)
	end

	info.text = NONE
	info.func = UnitFilterDropDownMenu_OnClick
	info.arg1 = 0x00000000
	info.owner = self:GetParent()
	info.checked = IsAnyFilterItemChecked
	info.isNotRadio = true
	info.keepShownOnClick = true;
	UIDropDownMenu_AddButton(info)
end

local function AuraListFilterDropDown_OnClick(self, arg1, arg2, isChecked)
	local config = activeConfig[self.owner:GetParent().filter].auralist
	local mask

	if arg1 == 0x00000000 then
		mask = arg1
	else
		if isChecked then
			mask = E:AddFilterToMask(config[self.owner.spellID], arg1)
		else
			mask = E:DeleteFilterFromMask(config[self.owner.spellID], arg1)
		end
	end

	self.owner.value = mask
	config[self.owner.spellID] = mask

	self.owner.Indicator:Update(mask, self:GetID())

	UIDropDownMenu_Refresh(self.owner:GetParent().DropDown) -- updating dropdown
end

local function AuraListFilterDropDown_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()

	for i = 1 , GetNumSpecializations() do
		local _, name = GetSpecializationInfo(i)
		info.text = name
		info.func = AuraListFilterDropDown_OnClick
		info.arg1 = M.PLAYER_SPEC_FLAGS[i]
		info.owner = self._owner
		info.checked = IsFilterItemChecked
		info.isNotRadio = true;
		info.keepShownOnClick = true;
		UIDropDownMenu_AddButton(info)
	end

	info.text = NONE
	info.func = AuraListFilterDropDown_OnClick
	info.arg1 = 0x00000000
	info.owner = self._owner
	info.checked = IsAnyFilterItemChecked
	info.isNotRadio = true
	info.keepShownOnClick = true;
	UIDropDownMenu_AddButton(info)
end

local function DeleteAuraButton_OnClick(self)
	print("will delete ID:", self:GetParent().spellID)
end

local function EditUnitButton_OnClick(self)
	ToggleDropDownMenu(1, nil, self.DropDown, self)
end

local function EditAuraButton_OnClick(self)
	local dropdown = self:GetParent():GetParent().DropDown
	local oldowner = dropdown._owner
	dropdown._owner = self:GetParent()

	if oldowner ~= dropdown._owner then
		HideDropDownMenu(1)
	end

	ToggleDropDownMenu(1, nil, dropdown, self)
end

local function SmallButton_OnEnter(self)
	self.Icon:SetAlpha(1)
end

local function SmallButton_OnLeave(self)
	self.Icon:SetAlpha(0.5)
end

function CFG:UFAuras_Initialize()
	activeConfig = C.units.target.auras

	local panel = CreateFrame("Frame", "LSUFAurasConfigPanel", InterfaceOptionsFramePanelContainer)
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

	local indicator = CreateFrame("Frame", "editUnitFilterIndicatorButton", unitSelector)
	indicator:SetFrameLevel(unitSelector:GetFrameLevel() + 1)
	indicator:SetPoint("LEFT", unitSelector, "LEFT", 24, 2)
	indicator.Update = SpecIndicator_Update
	indicator:SetScript("OnShow", SpecIndicator_OnShow)
	unitSelector.Indicator = indicator

	local editUnitButton = CreateFrame("Button", "$parentTestFilter", unitSelector)
	editUnitButton:SetSize(16, 16)
	editUnitButton:SetPoint("LEFT", unitSelector:GetName().."Right", "RIGHT", -12, 1)
	editUnitButton:SetScript("OnClick", EditUnitButton_OnClick)
	editUnitButton:SetScript("OnEnter", SmallButton_OnEnter)
	editUnitButton:SetScript("OnLeave", SmallButton_OnLeave)
	editUnitButton.SetValue = function(self, value) self.value = value end
	editUnitButton.GetValue = function(self, value) return self.value end
	panel.settings.units.target.auras.enabled = editUnitButton
	unitSelector.EditButton = editUnitButton

	local icon = editUnitButton:CreateTexture(nil, "ARTWORK")
	icon:SetTexture("Interface\\WorldMap\\GEAR_64GREY")
	icon:SetAlpha(0.5)
	icon:SetAllPoints()
	editUnitButton.Icon = icon

	local editUnitFilterDropDownButton = CreateFrame("Frame", "LSUFUnitFilterDropDown", editUnitButton, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(editUnitFilterDropDownButton, UnitFilterDropDown_Initialize, "MENU")
	UIDropDownMenu_SetAnchor(editUnitFilterDropDownButton, -2, -4, "TOPLEFT", nil, "BOTTOMLEFT")
	editUnitButton.DropDown = editUnitFilterDropDownButton

	local auraList = CreateFrame("ScrollFrame", "LSUFAuraList", panel, "FauxScrollFrameTemplate")
	auraList:SetSize(210, 394) -- 30 * 12 + 6 * 2 + 11 * 2
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

		local indicator = CreateFrame("Frame", "$parentFilterIndicator", button)
		indicator:SetFrameLevel(button:GetFrameLevel() + 1)
		indicator:SetPoint("BOTTOMLEFT", iconholder, "BOTTOMRIGHT", 4, -2)
		indicator.Update = SpecIndicator_Update
		indicator:SetScript("OnShow", SpecIndicator_OnShow)
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

		local editAuraButton = CreateFrame("Button", "$parentEditButton", button)
		editAuraButton:SetSize(16, 16)
		editAuraButton:SetPoint("RIGHT", deleteButton, "LEFT", 0, 0)
		editAuraButton:SetScript("OnClick", EditAuraButton_OnClick)
		editAuraButton:SetScript("OnEnter", SmallButton_OnEnter)
		editAuraButton:SetScript("OnLeave", SmallButton_OnLeave)
		button.EditButton = editAuraButton

		local icon = editAuraButton:CreateTexture(nil, "ARTWORK")
		icon:SetTexture("Interface\\WorldMap\\GEAR_64GREY")
		icon:SetAlpha(0.5)
		icon:SetAllPoints()
		editAuraButton.Icon = icon

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

		-- CFG:SetupControlDependency(atToggle, button)
	end

	local buffTab = CreateFrame("Button", "LSUFAuraListTab1", auraList, "TabButtonTemplate")
	buffTab.type = "Button"
	buffTab:SetID(1)
	buffTab:SetText("Buffs")
	buffTab:SetPoint("BOTTOMLEFT", auraList, "TOPLEFT", 8, -2)
	buffTab:SetScript("OnClick", LSUFAuraListTab_OnClick)
	auraList.BuffTab = buffTab
	-- CFG:SetupControlDependency(atToggle, buffTab)
	PanelTemplates_TabResize(buffTab, 0)

	local debuffTab = CreateFrame("Button", "LSUFAuraListTab2", auraList, "TabButtonTemplate")
	debuffTab.type = "Button"
	debuffTab:SetID(2)
	debuffTab:SetText("Debuffs")
	debuffTab:SetPoint("LEFT", buffTab, "RIGHT", 0, 0)
	debuffTab:SetScript("OnClick", LSUFAuraListTab_OnClick)
	auraList.DebuffTab = debuffTab
	-- CFG:SetupControlDependency(atToggle, debuffTab).
	PanelTemplates_TabResize(debuffTab, 0)

	PanelTemplates_SetNumTabs(auraList, 2)
	PanelTemplates_SetTab(auraList, 1)

	local auraListFilterDropDown = CreateFrame("Frame", "LSUFAuraListFilterDropDown", auraList, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(auraListFilterDropDown, AuraListFilterDropDown_Initialize, "MENU")
	UIDropDownMenu_SetAnchor(auraListFilterDropDown, -2, -4, "TOPLEFT", nil, "BOTTOMLEFT")
	auraList.DropDown = auraListFilterDropDown


	CFG:AddCatergory(panel)
end
