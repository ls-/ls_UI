local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local CFG = P:GetModule("Config")
local AURATRACKER = P:GetModule("AuraTracker")

-- Lua
local _G = getfenv(0)
local string = _G.string
local table = _G.table
local pairs = _G.pairs

-- Mine
local sortedAuras = {}

local function SortAurasByName(a, b)
	return a.name < b.name or (a.name == b.name and a.id < b.id)
end

local function PrepareSortedAuraList(tbl)
	table.wipe(sortedAuras)

	for id, filter in pairs(tbl) do
		local name, _, icon = _G.GetSpellInfo(id)

		if name then
			table.insert(sortedAuras, {id = id, name = name, icon = icon, filter = filter})
		end
	end

	table.sort(sortedAuras, SortAurasByName)
end

local function AuraList_Update(frame)
	if not frame.buttons then return end

	for i = 1, 10 do
		local button = frame.buttons[i]

		button:Hide()
		button.Text:SetText("")
		button.Icon:SetTexture("")
		button.spellID = nil
		button.Bg:Hide()
	end

	PrepareSortedAuraList(frame.table)

	if #sortedAuras ~= 0 then
		local offset = _G.FauxScrollFrame_GetOffset(frame)
		local total = 0

		for i = 1, 10 do
			local aura = sortedAuras[i + offset]
			local button = frame.buttons[i]

			if aura then
				button:Show()
				button.Text:SetText(aura.name)
				button.Icon:SetTexture(aura.icon)
				button.spellID = aura.id

				button.Indicator.filter = frame.filter
				button.Indicator.key = aura.id
				button.Indicator:RefreshValue()

				if (i + offset) % 2 == 0 then
					button.Bg:Show()
				end

				total = total + 1
			end
		end

		_G.FauxScrollFrame_Update(frame, #sortedAuras, total, 30, nil, nil, nil, nil, nil, nil, true)
	end
end

function CFG:AuraTracker_Init()
	local panel = _G.CreateFrame("Frame", "LSUIAuraTrackerConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = L["AURA_TRACKER"]
	panel.parent = L["LS_UI"]
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(L["AURA_TRACKER"])

	local subtext = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtext:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtext:SetPoint("RIGHT", -16, 0)
	subtext:SetHeight(44)
	subtext:SetJustifyH("LEFT")
	subtext:SetJustifyV("TOP")
	subtext:SetNonSpaceWrap(true)
	subtext:SetMaxLines(4)
	subtext:SetText(L["AURA_TRACKER_DESC"])

	local atToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentAuraTrackerToggle",
			text = L["ENABLE"],
			get = function() return C.auratracker.enabled end,
			set = function(_, value)
				C.auratracker.enabled = value
			end,
			refresh = function(self)
				self:SetChecked(C.auratracker.enabled)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if isChecked then
					if AURATRACKER:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_ENABLED_ERR"],
							L["AURA_TRACKER"]))
					else
						local result = AURATRACKER:Init()

						if result then
							panel.Log:SetText(string.format(
								L["LOG_ENABLED"],
								L["ICON_GREEN_INLINE"],
								L["AURA_TRACKER"],
								""))
						end
					end
				else
					if AURATRACKER:IsInit() then
						panel.Log:SetText(string.format(
							L["LOG_DISABLED"],
							L["ICON_YELLOW_INLINE"],
							L["AURA_TRACKER"],
							L["REQUIRES_RELOAD"]))
					end
				end
			end
		})
	atToggle:SetPoint("TOPLEFT", subtext, "BOTTOMLEFT", 0, -8)

	local lockToggle = CFG:CreateCheckButton(panel,
		{
			parent = panel,
			name = "$parentLockToggle",
			text = L["LOCK_FRAME"],
			get = function() return C.auratracker.locked end,
			set = function(_, value)
				C.auratracker.locked = value
			end,
			refresh = function(self)
				self:SetChecked(C.auratracker.locked)
			end,
			click = function(self)
				local isChecked = self:GetChecked()

				self:SetValue(isChecked)

				if AURATRACKER:IsInit() then
					AURATRACKER:ToggleHeader(not isChecked)
				end
			end,
		})
	lockToggle:SetPoint("LEFT", atToggle, "RIGHT", 110, 0)

	local auraList = CFG:CreateAuraList(panel,
		{
			aura_list_params = {
				get = function(self)
					return self.table
				end,
				set = function(self, id)
					if id == 1 then
						self.filter = "HELPFUL"
						self.table = C.auratracker.HELPFUL
					elseif id == 2 then
						self.filter = "HARMFUL"
						self.table = C.auratracker.HARMFUL
					end
				end,
				refresh = function(self)
					AuraList_Update(self)

					if AURATRACKER:IsInit() then
						AURATRACKER:Refresh()
					end
				end,
			},
			add_aura_mask_dial_params = {
				name = "$parentAddAuraMaskDial",
				text = L["MASK_COLON"],
				adjust_size_on_show = true,
				get = function(self)
					return self.flags[0]
				end,
				flags = {
					[0] = E.PLAYER_SPEC_FLAGS[0],
					[1] = E.PLAYER_SPEC_FLAGS[1],
					[2] = E.PLAYER_SPEC_FLAGS[2],
					[3] = E.PLAYER_SPEC_FLAGS[3],
					[4] = E.PLAYER_SPEC_FLAGS[4],

				}
			},
			aura_button_mask_dial_params = {
				adjust_size_on_show = true,
				get = function(self)
					return C.auratracker[self.filter][self.key]
				end,
				set = function(self, value)
					C.auratracker[self.filter][self.key] = value
				end,
				flags = {
					[0] = E.PLAYER_SPEC_FLAGS[0],
					[1] = E.PLAYER_SPEC_FLAGS[1],
					[2] = E.PLAYER_SPEC_FLAGS[2],
					[3] = E.PLAYER_SPEC_FLAGS[3],
					[4] = E.PLAYER_SPEC_FLAGS[4],

				}
			}
		})
	auraList:SetPoint("TOPLEFT", atToggle, "BOTTOMLEFT", 0, -40) -- 8 + 32 (default offset + tab height)

	local buttonSizeSlider = CFG:CreateSlider(panel,
		{
			parent = panel,
			name = "$parentButtonSizeSlider",
			min = 32,
			max = 48,
			step = 2,
			text = L["BUTTON_SIZE"],
			get = function() return C.auratracker.button_size end,
			set = function(_, value)
				C.auratracker.button_size = value

				if AURATRACKER:IsInit() then
					AURATRACKER:UpdateLayout()
				end
			end,

		})
	buttonSizeSlider:SetPoint("TOP", atToggle, "BOTTOM", 0, -22)
	buttonSizeSlider:SetPoint("LEFT", panel, "CENTER", 10, 0)

	local buttonSpacingSlider = CFG:CreateSlider(panel,
		{
			parent = panel,
			name = "$parentButtonSpacingSlider",
			min = 2,
			max = 12,
			step = 2,
			text = L["BUTTON_SPACING"],
			get = function() return C.auratracker.button_gap end,
			set = function(_, value)
				C.auratracker.button_gap = value

				if AURATRACKER:IsInit() then
					AURATRACKER:UpdateLayout()
				end
			end,

		})
	buttonSpacingSlider:SetPoint("TOP", buttonSizeSlider, "BOTTOM", 0, -24)

	local buttonsPerRowSlider = CFG:CreateSlider(panel,
		{
			parent = panel,
			name = "$parentButtonsPerRowSlider",
			min = 1,
			max = 12,
			step = 1,
			text = L["BUTTONS_PER_ROW"],
			get = function() return C.auratracker.buttons_per_row end,
			set = function(_, value)
				C.auratracker.buttons_per_row = value

				if AURATRACKER:IsInit() then
					AURATRACKER:UpdateLayout()
				end
			end,

		})
	buttonsPerRowSlider:SetPoint("TOP", buttonSpacingSlider, "BOTTOM", 0, -24)

	local growthDropdown = CFG:CreateDropDownMenu(panel,
		{
			parent = panel,
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
			get = function() return C.auratracker.init_anchor end,
			set = function(self, value)
				_G.UIDropDownMenu_SetSelectedValue(self, value)

				C.auratracker.init_anchor = value

				if AURATRACKER:IsInit() then
					AURATRACKER:UpdateLayout()
				end
			end,
		})
	growthDropdown:SetPoint("TOPLEFT", buttonsPerRowSlider, "BOTTOMLEFT", -18, -32)

	CFG:AddPanel(panel)
end
