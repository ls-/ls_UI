local addonName, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Config")

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local type = _G.type

-- Blizz
local CreateFrame = _G.CreateFrame
local FauxScrollFrame_GetOffset = _G.FauxScrollFrame_GetOffset
local FauxScrollFrame_OnVerticalScroll = _G.FauxScrollFrame_OnVerticalScroll
local FauxScrollFrame_SetOffset = _G.FauxScrollFrame_SetOffset
local FauxScrollFrame_Update = _G.FauxScrollFrame_Update
local GameTooltip = _G.GameTooltip
local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local InCombatLockdown = _G.InCombatLockdown
local InterfaceOptions_AddCategory = _G.InterfaceOptions_AddCategory
local InterfaceOptionsFrame_Show = _G.InterfaceOptionsFrame_Show
local PanelTemplates_DisableTab = _G.PanelTemplates_DisableTab
local PanelTemplates_EnableTab = _G.PanelTemplates_EnableTab
local PanelTemplates_SetNumTabs = _G.PanelTemplates_SetNumTabs
local PanelTemplates_SetTab = _G.PanelTemplates_SetTab
local PanelTemplates_TabResize = _G.PanelTemplates_TabResize
local ReloadUI = _G.ReloadUI

-- Mine
local LibStub = _G.LibStub
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

do
	-- Mine
	local frame
	local scrollFrame
	local auraList
	local auraLists
	local UpdateWidget
	local sortedAuraList = {}
	local NUM_BUTTONS = 12

	local FILTERS = {
		[1] = "HELPFUL",
		[2] = "HARMFUL",
		[3] = "ALL"
	}

	local function SortAurasByName(a, b)
		return a.name < b.name or (a.name == b.name and a.id < b.id)
	end

	local function PrepareSortedAuraList(list)
		t_wipe(sortedAuraList)

		for id in next, list do
			local name, _, icon = GetSpellInfo(id)

			if name then
				t_insert(sortedAuraList, {
					id = id,
					name = name,
					icon = icon,
				})
			end
		end

		t_sort(sortedAuraList, SortAurasByName)
	end

	local function AddAura(spellID)
		local name = GetSpellInfo(spellID)

		if name and not auraList[spellID] then
			auraList[spellID] = true

			scrollFrame:Update()

			UpdateWidget()

			return true
		else
			return false
		end
	end

	local function RemoveAura(spellID)
		auraList[spellID] = nil

		scrollFrame:Update()

		UpdateWidget()
	end

	local function Tab_OnClick(self)
		PanelTemplates_SetTab(scrollFrame, self:GetID())
		FauxScrollFrame_SetOffset(scrollFrame, 0)

		auraList = auraLists[FILTERS[self:GetID()]]

		scrollFrame:Update()
	end

	local function UpdateTooltip(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			if GameTooltip:IsOwned(self) then
				if self.spellID then
					GameTooltip:SetSpellByID(self.spellID)
				elseif self.link then
					GameTooltip:SetHyperlink(self.link)
				end
			end

			self.elapsed = 0
		end
	end

	local function AuraButton_OnEnter(self)
		self.Text:SetFontObject("GameFontHighlight")

		if not self.spellID then return end

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT", -2, -24)
		GameTooltip:SetSpellByID(self.spellID)
		GameTooltip:Show()

		self:SetScript("OnUpdate", UpdateTooltip)
	end

	local function AuraButton_OnLeave(self)
		self.Text:SetFontObject("GameFontNormal")

		GameTooltip:Hide()

		self:SetScript("OnUpdate", nil)
	end

	local function DeleteButton_OnEnter(self)
		self.Icon:SetAlpha(1)
	end

	local function DeleteButton_OnLeave(self)
		self.Icon:SetAlpha(0.5)
	end

	local function DeleteButton_OnClick(self)
		local spellID = self:GetParent().spellID

		if spellID then
			RemoveAura(spellID)
		end
	end

	function MODULE.OpenAuraConfig(_, name, data, activeTabs, inactiveTabs, updateFunc)
		if not frame then
			frame = CreateFrame("Frame", "LSAuraConfig", UIParent, "UIPanelDialogTemplate")
			frame:EnableMouse(true)
			frame:SetFrameStrata("TOOLTIP")
			frame:SetMovable(true)
			frame:SetToplevel(true)
			frame:SetSize(288, 522)
			frame:SetPoint("CENTER")
			frame:SetScript("OnHide", function()
				auraLists = nil
				UpdateWidget = nil
			end)
			frame:Hide()

			local bg = _G[frame:GetName().."DialogBG"]
			bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
			bg:SetVertexColor(0, 0, 0, 0.75)

			frame.TitleText = frame.title or frame.Title
			frame.TitleText:SetPoint("TOPRIGHT", -32, -8)
			frame.Title = nil
			frame.title = nil

			frame.Close = _G[frame:GetName().."Close"]
			frame.Close:SetScript("OnClick", function()
				frame:Hide()
			end)

			local title = CreateFrame("Button", nil, frame)
			title:SetPoint("TOPLEFT", 9, -6)
			title:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -28, -24)
			title:EnableMouse(true)
			title:SetScript("OnMouseDown",function(self)
				self:GetParent():StartMoving()
			end)
			title:SetScript("OnMouseUp", function(self)
				self:GetParent():StopMovingOrSizing()
			end)

			scrollFrame = CreateFrame("ScrollFrame", "LSAuraList", frame, "FauxScrollFrameTemplate")
			scrollFrame:SetBackdrop({
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 4, right = 4, top = 4, bottom = 4 }
			})
			scrollFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
			scrollFrame:SetPoint("TOPLEFT", 10, -60)
			scrollFrame:SetPoint("BOTTOMRIGHT", -7, 68)
			scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
				FauxScrollFrame_OnVerticalScroll(self, offset, 30, self.Update)
			end)
			scrollFrame.Update = function(self)
				PrepareSortedAuraList(auraList)

				local offset = FauxScrollFrame_GetOffset(self)
				local total = 0

				for i = 1, NUM_BUTTONS do
					local aura = sortedAuraList[i + offset]
					local button = self._buttons[i]

					if aura then
						button:Show()
						button.Text:SetText(aura.name)
						button.Icon:SetTexture(aura.icon)
						button.spellID = aura.id

						if (i + offset) % 2 == 0 then
							button.BG:Show()
						else
							button.BG:Hide()
						end

						total = total + 1
					else
						button:Hide()
						button.Text:SetText("")
						button.Icon:SetTexture("")
						button.spellID = nil
						button.BG:Hide()
					end
				end

				FauxScrollFrame_Update(self, #sortedAuraList, total, 30, nil, nil, nil, nil, nil, nil, true)
			end

			scrollFrame.ScrollBar:ClearAllPoints()
			scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame,"TOPRIGHT", -6, -22)
			scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame,"BOTTOMRIGHT", -6, 22)

			scrollFrame.Tabs = {}

			local buffTab = CreateFrame("Button", nil, frame, "TabButtonTemplate")
			buffTab:SetID(1)
			buffTab:SetText(L["BUFFS"])
			buffTab:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 8, -2)
			buffTab:SetScript("OnClick", Tab_OnClick)
			scrollFrame.Tabs[1] = buffTab
			PanelTemplates_TabResize(buffTab, 0)

			local debuffTab = CreateFrame("Button", nil, frame, "TabButtonTemplate")
			debuffTab:SetID(2)
			debuffTab:SetText(L["DEBUFFS"])
			debuffTab:SetPoint("LEFT", buffTab, "RIGHT", 0, 0)
			debuffTab:SetScript("OnClick", Tab_OnClick)
			scrollFrame.Tabs[2] = debuffTab
			PanelTemplates_TabResize(debuffTab, 0)

			local auraTab = CreateFrame("Button", nil, frame, "TabButtonTemplate")
			auraTab:SetID(3)
			auraTab:SetText(L["AURAS"])
			auraTab:SetPoint("LEFT", debuffTab, "RIGHT", 0, 0)
			auraTab:SetScript("OnClick", Tab_OnClick)
			scrollFrame.Tabs[3] = auraTab
			PanelTemplates_TabResize(auraTab, 0)

			PanelTemplates_SetNumTabs(scrollFrame, 3)

			scrollFrame._buttons = {}

			for i = 1, NUM_BUTTONS do
				local button = CreateFrame("Button", nil, scrollFrame)
				button:SetHeight(30)
				button:EnableMouse(true)
				button:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue", "ADD")
				button:SetScript("OnEnter", AuraButton_OnEnter)
				button:SetScript("OnLeave", AuraButton_OnLeave)
				button:Show()
				scrollFrame._buttons[i] = button

				local icon = button:CreateTexture(nil, "BACKGROUND")
				icon:SetSize(26, 26)
				icon:SetPoint("LEFT", 2, 0)
				button.Icon = icon

				local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
				text:SetJustifyH("LEFT")
				text:SetJustifyV("TOP")
				text:SetPoint("TOPLEFT", icon, "TOPRIGHT", 2, 0)
				text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 0)
				button.Text = text

				local deleteButton = CreateFrame("Button", nil, button)
				deleteButton:SetSize(16, 16)
				deleteButton:SetPoint("BOTTOMRIGHT", 0, 0)
				deleteButton:SetScript("OnClick", DeleteButton_OnClick)
				deleteButton:SetScript("OnEnter", DeleteButton_OnEnter)
				deleteButton:SetScript("OnLeave", DeleteButton_OnLeave)

				local deleteButtonIcon = deleteButton:CreateTexture(nil, "ARTWORK")
				deleteButtonIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
				deleteButtonIcon:SetDesaturated(true)
				deleteButtonIcon:SetVertexColor(M.COLORS.RED:GetRGB())
				deleteButtonIcon:SetAlpha(0.5)
				deleteButtonIcon:SetPoint("TOPLEFT", 1, -1)
				deleteButtonIcon:SetPoint("BOTTOMRIGHT", -1, 1)
				deleteButton.Icon = deleteButtonIcon

				local bg = button:CreateTexture(nil, "BACKGROUND", nil, -8)
				bg:SetAllPoints()
				bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGBA(0.65))
				button.BG = bg

				if i == 1 then
					button:SetPoint("TOPLEFT", 6, -6)
				else
					button:SetPoint("TOPLEFT", scrollFrame._buttons[i - 1], "BOTTOMLEFT", 0, -2)
				end

				button:SetPoint("RIGHT", scrollFrame.ScrollBar, "LEFT", -2, -6)
			end

			local result = CreateFrame("SimpleHTML", nil, frame)
			result:SetHeight(32)
			result:SetFontObject("GameFontHighlight")
			result:SetJustifyV("TOP")
			result:SetJustifyH("LEFT")
			result:SetScript("OnHyperlinkEnter", function(self, _, link)
				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT", -2, -24)
				GameTooltip:SetHyperlink(link)
				GameTooltip:Show()
			end)
			result:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)

			local editBox = CreateFrame("EditBox", nil, frame, "InputBoxInstructionsTemplate")
			editBox:SetHeight(22)
			editBox:SetAutoFocus(false)
			editBox:SetNumeric(true)
			editBox.Instructions:SetText(L["ENTER_SPELL_ID"])
			editBox:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 7, 0)
			editBox:SetPoint("TOPRIGHT", scrollFrame, "BOTTOMRIGHT", -2, 0)
			editBox:SetScript("OnEnterPressed", function(self)
				local spellID = tonumber(self:GetText())

				if not spellID then return end

				if AddAura(spellID) then
					self:SetText("")
					result:SetText("")
				end
			end)
			editBox:HookScript("OnTextChanged", function(self, isUserInput)
				if isUserInput then
					local spellID = tonumber(self:GetText())

					if not spellID or spellID > 2147483647 then
						return self:SetText("")
					end

					local link = GetSpellLink(spellID)

					if link then
						result:SetText(link)
					else
						result:SetText("...")
					end
				end
			end)

			result:SetPoint("TOP", editBox, "BOTTOM", 0, -2)
			result:SetPoint("LEFT", scrollFrame, "LEFT", 2, 0)
			result:SetPoint("RIGHT", scrollFrame, "RIGHT", -2, 0)
		end

		if frame:IsShown() then
			frame:Hide()
		end

		data.HELPFUL = data.HELPFUL or {}
		data.HARMFUL = data.HARMFUL or {}
		data.ALL = data.ALL or {}

		auraLists = data

		if activeTabs then
			for _, i in next, activeTabs do
				PanelTemplates_EnableTab(scrollFrame, i)
			end

			PanelTemplates_SetTab(scrollFrame, activeTabs[1])
			auraList = auraLists[FILTERS[activeTabs[1]]]
		end

		if inactiveTabs then
			for _, i in next, inactiveTabs do
				PanelTemplates_DisableTab(scrollFrame, i)
			end

		end

		UpdateWidget = updateFunc or E.NOOP

		frame.TitleText:SetText(name)
		scrollFrame:Update()
		frame:Show()
	end
end

do
	-- Blizz
	local StaticPopupDialogs = _G.StaticPopupDialogs
	local StaticPopup_Show = _G.StaticPopup_Show

	-- Mine
	local pendingPopups = {}
	local oldStrata

	local POPUPS = {
		["RELOAD_UI"] = {
			text = L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"],
			button1 = L["RELOAD_NOW"],
			button2 = L["LATER"],
			OnAccept = function() ReloadUI() end,
			OnCancel = function(self)
				pendingPopups[self.data] = true

				MODULE:SetStatusText(L["RELOAD_UI_WARNING"])

				if oldStrata then
					self:SetFrameStrata(oldStrata)
					oldStrata = nil
				end
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		},
	}

	function MODULE.ShowStaticPopup(_, which)
		if not StaticPopupDialogs["LS_UI_POPUP"] then
			StaticPopupDialogs["LS_UI_POPUP"] = {}
		end

		if pendingPopups[which] or not POPUPS[which] then return end

		local t = StaticPopupDialogs["LS_UI_POPUP"]
		t_wipe(t)

		t.exclusive = 1

		for k, v in next, POPUPS[which] do
			t[k] = v
		end

		local dialog = StaticPopup_Show("LS_UI_POPUP")

		if dialog then
			dialog.data = which
			oldStrata = dialog:GetFrameStrata()

			dialog:SetFrameStrata("TOOLTIP")
		end
	end
end

function MODULE.SetStatusText(_, text)
	local frame = AceConfigDialog.OpenFrames[addonName]

	if frame then
		frame:SetStatusText(text)
	end
end

function MODULE:CopySettings(src, dest, ignoredKeys)
	for k, v in next, dest do
		if not ignoredKeys or not ignoredKeys[k] then
			if src[k] ~= nil then
				if type(v) == "table" then
					if next(v) and type(src[k]) == "table" then
						self:CopySettings(src[k], v)
					end
				else
					if type(v) == type(src[k]) then
						dest[k] = src[k]
					end
				end
			end
		end
	end
end

function MODULE.Init()
	C.options = {
		type = "group",
		name = L["LS_UI"],
		disabled = function() return InCombatLockdown() end,
		args = {
			toggle_anchors = {
				order = 1,
				type = "execute",
				name = L["TOGGLE_ANCHORS"],
				func = function() E:ToggleAllMovers() end,
			},
			reload_ui = {
				order = 2,
				type = "execute",
				name = L["RELOADUI"],
				func = function() ReloadUI() end,
			},
		},
	}

	AceConfig:RegisterOptionsTable(addonName, C.options)
	AceConfigDialog:SetDefaultSize(addonName, 1024, 768)

	MODULE:CreateGeneralPanel(3)
	MODULE:CreateActionBarsPanel(4)
	MODULE:CreateAuraTrackerPanel(5)
	MODULE:CreateBlizzardPanel(6)
	MODULE:CreateAurasPanel(7)
	MODULE:CreateMinimapPanel(8)
	MODULE:CreateTooltipsPanel(9)
	MODULE:CreateUnitFramesPanel(10)

	C.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(C.db, true)
	C.options.args.profiles.order = 100
	C.options.args.profiles.desc = nil

	LibStub("LibDualSpec-1.0"):EnhanceOptions(C.options.args.profiles, C.db)

	local panel = CreateFrame("Frame", "LSUIConfigPanel", InterfaceOptionsFramePanelContainer)
	panel.name = L["LS_UI"]
	panel:Hide()

	local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	button:SetText(L["OPEN_CONFIG"])
	button:SetWidth(button:GetTextWidth() + 18)
	button:SetPoint("TOPLEFT", 16, -16)
	button:SetScript("OnClick", function()
		if not InCombatLockdown() then
			InterfaceOptionsFrame_Show()

			AceConfigDialog:Open(addonName)
		end
	end)

	InterfaceOptions_AddCategory(panel, true)

	P:AddCommand("", function()
		if not InCombatLockdown() then
			AceConfigDialog:Open(addonName)
		end
	end)

	E:RegisterEvent("PLAYER_REGEN_DISABLED", function()
		AceConfigDialog:Close(addonName)
	end)
end
