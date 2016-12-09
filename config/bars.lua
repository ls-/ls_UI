local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local BARS = P:GetModule("Bars")

-- Lua
local _G = _G
local string = _G.string

-- Mine
function CFG:Bars_Init()
	local panel = _G.CreateFrame("Frame", "LSUIBarsConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["ACTION_BARS"]
	panel.parent = L["LS_UI"]
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["ACTION_BARS"])

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["SETTINGS_ACTION_BARS_DESC"])

	local barsToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentBarsToggle",
			text = L["ENABLE"],
			get = function() return C.bars.enabled end,
			set = function(_, value)
				C.bars.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if BARS:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["ACTION_BARS"]))
					else
						local result = BARS:Init(true)

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["ACTION_BARS"],
								""))
						end
					end
				else
					if BARS:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["ACTION_BARS"],
							L["REQUIRES_RELOAD"]))
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED_ERR"],
							L["ACTION_BARS"]))
					end
				end
			end
		})
	barsToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local modeToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentModeToggle",
			text = L["ACTION_BAR_RESTRICTED_MODE"],
			tooltip_text= L["ACTION_BAR_RESTRICTED_MODE_TOOLTIP"],
			get = function() return C.bars.restricted end,
			set = function(_, value)
				C.bars.restricted = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.restricted)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if BARS:ActionBarController_IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["ACTION_BAR_RESTRICTED_MODE"]))
					else
						panel.Log:SetText(string.format(
							L["LOG_ENABLED"],
							L["ICON_YELLOW_INLINE"],
							L["ACTION_BAR_RESTRICTED_MODE"],
							L["REQUIRES_RELOAD"]))
					end
				else
					if BARS:ActionBarController_IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["ACTION_BAR_RESTRICTED_MODE"],
							L["REQUIRES_RELOAD"]))
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED_ERR"],
							L["ACTION_BAR_RESTRICTED_MODE"]))
					end
				end
			end,
		})
	modeToggle:SetPoint("LEFT", barsToggle, "RIGHT", 110, 0)

	local divider = CFG:CreateDivider(panel, L["BARS"])
	divider:SetPoint("TOP", barsToggle, "BOTTOM", 0, -10)

	local ab2Toggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentActionBar2Toggle",
			text = L["ACTION_BAR_2"],
			get = function() return C.bars.bar2.visible end,
			set = function(_, value)
				C.bars.bar2.visible = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.bar2.visible)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				BARS:ToggleBar("bar2", isChecked)
			end
		})
	ab2Toggle:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)

	local ab3Toggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentActionBar3Toggle",
			text = L["ACTION_BAR_3"],
			get = function() return C.bars.bar3.visible end,
			set = function(_, value)
				C.bars.bar3.visible = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.bar3.visible)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				BARS:ToggleBar("bar3", isChecked)
			end
		})
	ab3Toggle:SetPoint("LEFT", ab2Toggle, "RIGHT", 110, 0)

	local ab4Toggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentActionBar4Toggle",
			text = L["ACTION_BAR_4"],
			get = function() return C.bars.bar4.visible end,
			set = function(_, value)
				C.bars.bar4.visible = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.bar4.visible)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				BARS:ToggleBar("bar4", isChecked)
			end
		})
	ab4Toggle:SetPoint("LEFT", ab3Toggle, "RIGHT", 110, 0)

	local ab5Toggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentActionBar5Toggle",
			text = L["ACTION_BAR_5"],
			get = function() return C.bars.bar5.visible end,
			set = function(_, value)
				C.bars.bar5.visible = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.bar5.visible)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				BARS:ToggleBar("bar5", isChecked)
			end
		})
	ab5Toggle:SetPoint("LEFT", ab4Toggle, "RIGHT", 110, 0)

	local ab6Toggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentPetBarToggle",
			text = L["PET_BAR"],
			get = function() return C.bars.bar6.visible end,
			set = function(_, value)
				C.bars.bar6.visible = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.bar6.visible)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				BARS:ToggleBar("bar6", isChecked)
			end
		})
	ab6Toggle:SetPoint("TOPLEFT", ab2Toggle, "BOTTOMLEFT", 0, -8)

	local ab7Toggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentStanceBarToggle",
			text = L["STANCE_BAR"],
			get = function() return C.bars.bar7.visible end,
			set = function(_, value)
				C.bars.bar7.visible = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.bar7.visible)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				BARS:ToggleBar("bar7", isChecked)
			end
		})
	ab7Toggle:SetPoint("LEFT", ab6Toggle, "RIGHT", 110, 0)

	divider = CFG:CreateDivider(panel, L["BUTTONS"])
	divider:SetPoint("TOP", ab6Toggle, "BOTTOM", 0, -10)

	local tabbedFrame = CFG:CreateTabbedFrame(panel,
		{
			parent = panel,
			name = "$parentButtonOptionsFrame",
			get = function(self) return self.key end,
			set = function(self, i)
				self.key = "bar"..i
			end,
			refresh = function(self)
				self.ButtonSizeSlider.key = self.key
				self.ButtonSpacingSlider.key = self.key
				self.ButtonsPerRowSlider.key = self.key
				self.GrowthDropdown.key = self.key

				self.ButtonSizeSlider:RefreshValue()
				self.ButtonSpacingSlider:RefreshValue()
				self.ButtonsPerRowSlider:RefreshValue()
				self.GrowthDropdown:RefreshValue()
			end,
			tabs = {
				[1] = {
					text = L["ACTION_BAR_1_SHORT"],
					tooltip_text = L["ACTION_BAR_1"],
				},
				[2] = {
					text = L["ACTION_BAR_2_SHORT"],
					tooltip_text = L["ACTION_BAR_2"],
				},
				[3] = {
					text = L["ACTION_BAR_3_SHORT"],
					tooltip_text = L["ACTION_BAR_3"],
				},
				[4] = {
					text = L["ACTION_BAR_4_SHORT"],
					tooltip_text = L["ACTION_BAR_4"],
				},
				[5] = {
					text = L["ACTION_BAR_5_SHORT"],
					tooltip_text = L["ACTION_BAR_5"],
				},
				[6] = {
					text = L["PET_BAR_SHORT"],
					tooltip_text = L["PET_BAR"],
				},
				[7] = {
					text = L["STANCE_BAR_SHORT"],
					tooltip_text = L["STANCE_BAR"],
				},
			},
		})
	tabbedFrame:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -40)
	tabbedFrame:SetPoint("RIGHT", panel, "RIGHT", -16, 0)
	tabbedFrame:SetHeight(112)

	local buttonSizeSlider = CFG:CreateSlider(panel,
		{
			parent = tabbedFrame,
			name = "$parentButtonSizeSlider",
			min = 24,
			max = 48,
			step = 2,
			text = L["BUTTON_SIZE"],
			get = function(self) return C.bars[self.key].button_size end,
			set = function(self, value)
				C.bars[self.key].button_size = value

				BARS:UpdateLayout(self.key)
			end,
		})
	buttonSizeSlider:SetPoint("TOPLEFT", tabbedFrame, "TOPLEFT", 16, -22)
	tabbedFrame.ButtonSizeSlider = buttonSizeSlider

	local buttonSpacingSlider = CFG:CreateSlider(panel,
		{
			parent = tabbedFrame,
			name = "$parentButtonSpacingSlider",
			min = 2,
			max = 12,
			step = 2,
			text = L["BUTTON_SPACING"],
			get = function(self) return C.bars[self.key].button_gap end,
			set = function(self, value)
				C.bars[self.key].button_gap = value

				BARS:UpdateLayout(self.key)
			end,

		})
	buttonSpacingSlider:SetPoint("LEFT", buttonSizeSlider, "RIGHT", 64, 0)
	tabbedFrame.ButtonSpacingSlider = buttonSpacingSlider

	local buttonsPerRowSlider = CFG:CreateSlider(panel,
		{
			parent = tabbedFrame,
			name = "$parentButtonsPerRowSlider",
			min = 1,
			max = 12,
			step = 1,
			text = L["BUTTONS_PER_ROW"],
			get = function(self) return C.bars[self.key].buttons_per_row end,
			set = function(self, value)
				C.bars[self.key].buttons_per_row = value

				BARS:UpdateLayout(self.key)
			end,

		})
	buttonsPerRowSlider:SetPoint("LEFT", buttonSpacingSlider, "RIGHT", 64, 0)
	tabbedFrame.ButtonsPerRowSlider = buttonsPerRowSlider

	local growthDropdown = CFG:CreateDropDownMenu(panel,
		{
			parent = tabbedFrame,
			name = "$parentInitAnchorDropDown",
			text = L["BUTTON_ANCHOR_POINT"],
			init = function(self)
				local info = _G.UIDropDownMenu_CreateInfo()

				info.text = "TOPLEFT"
				info.func = function(button) self:SetValue(button.value) end
				info.checked = nil
				_G.UIDropDownMenu_AddButton(info)

				info.text = "TOPRIGHT"
				info.checked = nil
				_G.UIDropDownMenu_AddButton(info)

				info.text = "BOTTOMLEFT"
				info.checked = nil
				_G.UIDropDownMenu_AddButton(info)

				info.text = "BOTTOMRIGHT"
				info.checked = nil
				_G.UIDropDownMenu_AddButton(info)
			end,
			get = function(self) return C.bars[self.key].init_anchor end,
			set = function(self, value)
				_G.UIDropDownMenu_SetSelectedValue(self, value)

				C.bars[self.key].init_anchor = value

				BARS:UpdateLayout(self.key)
			end,
		})
	growthDropdown:SetPoint("TOPLEFT", buttonSizeSlider, "BOTTOMLEFT", -18, -32)
	tabbedFrame.GrowthDropdown = growthDropdown

	if BARS:ActionBarController_IsInit() then
		_G.PanelTemplates_SetTab(tabbedFrame, 2)
		_G.PanelTemplates_DisableTab(tabbedFrame, 1)

		tabbedFrame.key = "bar2"
		buttonSizeSlider.key = "bar2"
		buttonSpacingSlider.key = "bar2"
		buttonsPerRowSlider.key = "bar2"
		growthDropdown.key = "bar2"
	else
		_G.PanelTemplates_SetTab(tabbedFrame, 1)

		tabbedFrame.key = "bar1"
		buttonSizeSlider.key = "bar1"
		buttonSpacingSlider.key = "bar1"
		buttonsPerRowSlider.key = "bar1"
		growthDropdown.key = "bar1"
	end

	divider = CFG:CreateDivider(panel, L["MISC"])
	divider:SetPoint("TOP", tabbedFrame, "BOTTOM", 0, -10)

	local bagsToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentBarsToggle",
			text = L["BAGS"],
			get = function() return C.bars.bags.enabled end,
			set = function(_, value)
				C.bars.bags.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.bars.bags.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if BARS:Bags_IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["BAGS"]))
					else
						if BARS:ActionBarController_IsInit() then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_YELLOW_INLINE"],
								L["BAGS"],
								L["REQUIRES_RELOAD"]))
						else
							local result = BARS:Bags_Init(true)

							if result then
								panel.Log:SetText(string.format(
									L["LOG_ENABLED"],
									L["ICON_GREEN_INLINE"],
									L["BAGS"],
									""))
							end
						end
					end
				else
					if BARS:Bags_IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["BAGS"],
							L["REQUIRES_RELOAD"]))
					else
						panel.Log:SetText(string.format(
							L["LOG_DISABLED_ERR"],
							L["BAGS"]))
					end
				end
			end
		})
	bagsToggle:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)

	CFG:AddPanel(panel)
end
