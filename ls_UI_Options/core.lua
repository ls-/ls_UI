local _, CONFIG = ...
ls_UI.Config = CONFIG

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_trim = _G.string.trim
local t_concat = _G.table.concat
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

-- Libs
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Mine
local E, M, L, C, D, PrC, PrD, P, oUF = unpack(ls_UI)

-- CONFIG:ShowStaticPopup(which)
do
	local POPUPS = {
		["RELOAD_UI"] = {
			text = L["RELOAD_UI_ON_CHAR_SETTING_CHANGE_POPUP"],
			accept = L["RELOAD_NOW"],
			cancel = L["LATER"],
			OnAccept = function() ReloadUI() end,
			OnCancel = function(self)
				AceConfigDialog.popup:Hide()

				AceConfigDialog.popup.accept:SetScript("OnClick", nil)
				AceConfigDialog.popup.accept:SetText(L["ACCEPT"] )

				self:SetScript("OnClick", nil)
				self:SetText(L["CANCEL"])

				CONFIG:SetStatusText(L["RELOAD_UI_WARNING"])
			end,
		},
	}

	function CONFIG:ShowStaticPopup(which)
		if not POPUPS[which] then
			return
		end

		local frame = AceConfigDialog.popup
		frame:Show()
		frame.text:SetText(POPUPS[which].text)
		frame:SetHeight(61 + frame.text:GetHeight())

		frame.accept:ClearAllPoints()
		frame.accept:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -6, 16)
		frame.accept:SetScript("OnClick", POPUPS[which].OnAccept)
		frame.accept:SetText(POPUPS[which].accept)

		frame.cancel:Show()
		frame.cancel:SetScript("OnClick", POPUPS[which].OnCancel)
		frame.cancel:SetText(POPUPS[which].cancel)
	end
end

function CONFIG:SetStatusText(text)
	local frame = AceConfigDialog.OpenFrames.ls_UI
	if frame then
		frame:SetStatusText(text)
	end
end

function CONFIG.ConfirmReset(info)
	local option = CONFIG.options

	for i = 1, #info - 1 do
		option = option.args[info[i]]
	end

	return L["CONFIRM_RESET"]:format(option.name)
end

---------------
-- OLD STUFF --
---------------

local INT_LIMIT = 2 ^ 32 / 2 - 1

CONFIG.H_ALIGNMENTS = {
	["CENTER"] = "CENTER",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
}

CONFIG.V_ALIGNMENTS = {
	["BOTTOM"] = "BOTTOM",
	["MIDDLE"] = "MIDDLE",
	["TOP"] = "TOP",
}

CONFIG.POINTS = {
	["BOTTOM"] = "BOTTOM",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	["CENTER"] = "CENTER",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
	["TOP"] = "TOP",
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
}

CONFIG.POINTS_EXT = {
	[""] = "NONE",
	["BOTTOM"] = "BOTTOM",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	["CENTER"] = "CENTER",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
	["TOP"] = "TOP",
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
}

CONFIG.CASTBAR_ICON_POSITIONS = {
	["NONE"] = L["NONE"],
	["LEFT"] = L["LEFT"],
	["RIGHT"] = L["RIGHT"],
}

CONFIG.GROWTH_DIRS = {
	["LEFT_DOWN"] = L["LEFT_DOWN"],
	["LEFT_UP"] = L["LEFT_UP"],
	["RIGHT_DOWN"] = L["RIGHT_DOWN"],
	["RIGHT_UP"] = L["RIGHT_UP"],
}

function CONFIG:GetRegionAnchors(anchorsToRemove, anchorsToAdd)
	local temp = {
		[""] = L["FRAME"],
		["Health"] = L["HEALTH"],
		["Health.Text"] = L["HEALTH_TEXT"],
		["Power"] = L["POWER"],
		["Power.Text"] = L["POWER_TEXT"],
	}

	if anchorsToRemove then
		for anchor in next, anchorsToRemove do
			temp[anchor] = nil
		end
	end

	if anchorsToAdd then
		for anchor, name in next, anchorsToAdd do
			temp[anchor] = name
		end
	end

	return temp
end

-- CONFIG.OpenAuraConfig
do
	local NUM_BUTTONS = 13

	local frame
	local data = {}
	local activeData
	local sortedData = {}
	local history = {{}, {}, {}}
	local activeHistory

	local function sortFunc(a, b)
		return a.name < b.name or (a.name == b.name and a.id < b.id)
	end

	local function prepAuraList(list)
		t_wipe(sortedData)

		local name, icon, _
		for id in next, list do
			if type(id) == "number" then
				name, _, icon = GetSpellInfo(id)
				if name then
					t_insert(sortedData, {
						id = id,
						name = name,
						icon = icon,
					})
				end
			end
		end

		t_sort(sortedData, sortFunc)
	end

	local function tab_OnClick(self)
		PanelTemplates_SetTab(frame.AuraList, self:GetID())
		FauxScrollFrame_SetOffset(frame.AuraList, 0)

		activeData = data[self:GetID()]
		prepAuraList(activeData)

		activeHistory = history[self:GetID()]

		frame.AuraList:Update()
	end

	local function auraButtonUpdateTooltip(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			if GameTooltip:IsOwned(self) and self.spellID then
				GameTooltip:SetSpellByID(self.spellID)
			end

			self.elapsed = 0
		end
	end

	local function auraButton_OnEnter(self)
		self.Text:SetFontObject("GameFontHighlight")

		if not self.spellID then return end

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint("TOPRIGHT", frame, "TOPLEFT", 2, -24)
		GameTooltip:SetSpellByID(self.spellID)
		GameTooltip:Show()

		self:SetScript("OnUpdate", auraButtonUpdateTooltip)
	end

	local function auraButton_OnLeave(self)
		self.Text:SetFontObject("GameFontNormal")

		GameTooltip:Hide()

		self:SetScript("OnUpdate", nil)
	end

	local function deleteButton_OnClick(self)
		local spellID = self:GetParent().spellID
		if spellID then
			activeData[spellID] = nil
			prepAuraList(activeData)

			t_insert(activeHistory, spellID)

			frame.AuraList:Update()
		end
	end

	local function deleteButton_OnEnter(self)
		self.Icon:SetAlpha(1)
	end

	local function deleteButton_OnLeave(self)
		self.Icon:SetAlpha(0.5)
	end

	local function undoButtonUpdateTooltip(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			if GameTooltip:IsOwned(self) then
				if activeHistory[#activeHistory] then
					GameTooltip:SetSpellByID(activeHistory[#activeHistory])
				else
					GameTooltip:Hide()
				end
			end

			self.elapsed = 0
		end
	end

	function CONFIG:OpenAuraConfig(name, auras, buffs, debuffs, hideCallback)
		if not frame then
			frame = CreateFrame("Frame", "LSAuraFilterConfig", UIParent, "UIPanelDialogTemplate")
			frame:EnableMouse(true)
			frame:SetFrameStrata("DIALOG")
			frame:SetMovable(true)
			frame:SetToplevel(true)
			frame:SetSize(320, 653)
			frame:SetPoint("TOP", 0, -64)

			local bg = _G[frame:GetName() .. "DialogBG"]
			bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
			bg:SetVertexColor(0, 0, 0, 0.75)

			frame.TitleText = frame.title or frame.Title
			frame.TitleText:SetPoint("TOPRIGHT", -32, -8)
			frame.Title = nil
			frame.title = nil

			frame.Close = _G[frame:GetName() .. "Close"]
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

			local previewFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
			previewFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 5, -8)
			previewFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 5, 10)
			previewFrame:SetWidth(320)
			previewFrame:SetFrameLevel(frame:GetFrameLevel() + 1)
			frame.Preview = previewFrame

			previewFrame.ScrollBar:ClearAllPoints()
			previewFrame.ScrollBar:SetPoint("TOPRIGHT", previewFrame,"TOPRIGHT", 0, -16)
			previewFrame.ScrollBar:SetPoint("BOTTOMRIGHT", previewFrame,"BOTTOMRIGHT", 0, 16)

			local previewFrameBG = CreateFrame("Frame", nil, previewFrame, "BackdropTemplate")
			previewFrameBG:SetPoint("TOPLEFT", -6, 6)
			previewFrameBG:SetPoint("BOTTOMRIGHT", 6, -6)
			previewFrameBG:SetFrameLevel(frame:GetFrameLevel())
			previewFrameBG:SetBackdrop({
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 4, right = 4, top = 4, bottom = 4 }
			})
			previewFrameBG:SetBackdropBorderColor(0.6, 0.6, 0.6)

			local previewScrollChild = CreateFrame("SimpleHTML", nil, previewFrame)
			previewScrollChild:SetSize(296, 636)
			previewScrollChild:SetFontObject("GameFontHighlight")
			previewScrollChild:SetJustifyH("LEFT")
			previewScrollChild:SetScript("OnHyperlinkEnter", function(self, _, link)
				GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
				GameTooltip:SetHyperlink(link)
				GameTooltip:Show()
			end)
			previewScrollChild:SetScript("OnHyperlinkLeave", function()
				GameTooltip:Hide()
			end)
			previewFrame.ScrollChild = previewScrollChild

			previewFrame:SetScrollChild(previewScrollChild)

			local undoButton = E:CreateButton(frame)
			undoButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -30)
			undoButton:SetScript("OnClick", function()
				local spellID = t_remove(activeHistory, #activeHistory)
				if not spellID then return end

				activeData[spellID] = true
				prepAuraList(activeData)

				frame.AuraList:Update()
			end)
			undoButton:SetScript("OnEnter", function(self)
				local spellID = activeHistory[#activeHistory]
				if not spellID then return end

				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint("TOPRIGHT", frame, "TOPLEFT", 2, -24)
				GameTooltip:SetSpellByID(spellID)
				GameTooltip:Show()

				self:SetScript("OnUpdate", undoButtonUpdateTooltip)
			end)
			undoButton:SetScript("OnLeave", function(self)
				GameTooltip:Hide()

				self:SetScript("OnUpdate", nil)
			end)
			frame.UndoButton = undoButton

			undoButton.Icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-Undo")

			local auraListFrame = CreateFrame("ScrollFrame", nil, frame, "FauxScrollFrameTemplate, BackdropTemplate")
			auraListFrame:SetFrameLevel(frame:GetFrameLevel() + 2)
			auraListFrame:SetBackdrop({
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 4, right = 4, top = 4, bottom = 4 }
			})
			auraListFrame:SetBackdropBorderColor(0.6, 0.6, 0.6)
			auraListFrame:SetHeight(426)
			auraListFrame:SetPoint("TOP", 0, -60)
			auraListFrame:SetPoint("LEFT", 10, 0)
			auraListFrame:SetPoint("RIGHT", -7, 0)
			auraListFrame:SetScript("OnVerticalScroll", function(self, offset)
				FauxScrollFrame_OnVerticalScroll(self, offset, 30, self.Update)
			end)
			frame.AuraList = auraListFrame

			auraListFrame.Update = function(self)
				local offset = FauxScrollFrame_GetOffset(self)
				local total = 0
				local aura, button

				for i = 1, NUM_BUTTONS do
					aura = sortedData[i + offset]
					button = self.Buttons[i]

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

				FauxScrollFrame_Update(self, #sortedData, total, 30, nil, nil, nil, nil, nil, nil, true)
			end

			auraListFrame.ScrollBar:ClearAllPoints()
			auraListFrame.ScrollBar:SetPoint("TOPRIGHT", auraListFrame,"TOPRIGHT", -6, -22)
			auraListFrame.ScrollBar:SetPoint("BOTTOMRIGHT", auraListFrame,"BOTTOMRIGHT", -6, 21)

			auraListFrame.Tabs = {}

			for i = 1, 3 do
				local tab = CreateFrame("Button", nil, frame, "TabButtonTemplate")
				tab:SetID(i)
				tab:SetText(i == 1 and L["AURAS"] or i == 2 and L["BUFFS"] or L["DEBUFFS"])
				tab:SetPoint("BOTTOMLEFT", auraListFrame, "TOPLEFT", 8, -2)
				tab:SetScript("OnClick", tab_OnClick)
				auraListFrame.Tabs[i] = tab
				PanelTemplates_TabResize(tab, 0, 86)

				if i == 1 then
					tab:SetPoint("BOTTOMLEFT", auraListFrame, "TOPLEFT", 8, -2)
				else
					tab:SetPoint("LEFT", auraListFrame.Tabs[i - 1], "RIGHT", 0, 0)
				end
			end

			PanelTemplates_SetNumTabs(auraListFrame, 3)

			auraListFrame.Buttons = {}

			for i = 1, NUM_BUTTONS do
				local button = CreateFrame("Button", nil, auraListFrame)
				button:SetHeight(30)
				button:EnableMouse(true)
				button:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar-Blue", "ADD")
				button:SetScript("OnEnter", auraButton_OnEnter)
				button:SetScript("OnLeave", auraButton_OnLeave)
				button:Show()
				auraListFrame.Buttons[i] = button

				local icon = button:CreateTexture(nil, "BACKGROUND")
				icon:SetSize(26, 26)
				icon:SetPoint("LEFT", 2, 0)
				icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
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
				deleteButton:SetScript("OnClick", deleteButton_OnClick)
				deleteButton:SetScript("OnEnter", deleteButton_OnEnter)
				deleteButton:SetScript("OnLeave", deleteButton_OnLeave)

				local deleteButtonIcon = deleteButton:CreateTexture(nil, "ARTWORK")
				deleteButtonIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
				deleteButtonIcon:SetDesaturated(true)
				deleteButtonIcon:SetVertexColor(E:GetRGB(C.db.global.colors.red))
				deleteButtonIcon:SetAlpha(0.5)
				deleteButtonIcon:SetPoint("TOPLEFT", 1, -1)
				deleteButtonIcon:SetPoint("BOTTOMRIGHT", -1, 1)
				deleteButton.Icon = deleteButtonIcon

				local bg = button:CreateTexture(nil, "BACKGROUND", nil, -8)
				bg:SetAllPoints()
				bg:SetColorTexture(E:GetRGBA(C.db.global.colors.dark_gray, 0.65))
				button.BG = bg

				if i == 1 then
					button:SetPoint("TOPLEFT", 6, -6)
				else
					button:SetPoint("TOPLEFT", auraListFrame.Buttons[i - 1], "BOTTOMLEFT", 0, -2)
				end

				button:SetPoint("RIGHT", auraListFrame.ScrollBar, "LEFT", -2, -6)
			end

			local idInputFrame = CreateFrame("ScrollFrame", nil, frame, "InputScrollFrameTemplate")
			idInputFrame:SetFrameLevel(frame:GetFrameLevel() + 2)
			idInputFrame:SetHeight(96)
			idInputFrame:SetPoint("TOP", auraListFrame, "BOTTOM", 0, -6)
			idInputFrame:SetPoint("LEFT", frame, "LEFT", 16, 0)
			idInputFrame:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
			frame.IDInput = idInputFrame

			idInputFrame.CharCount:Hide()

			idInputFrame.ScrollBar:ClearAllPoints()
			idInputFrame.ScrollBar:SetPoint("TOPRIGHT", idInputFrame,"TOPRIGHT", 3, -12)
			idInputFrame.ScrollBar:SetPoint("BOTTOMRIGHT", idInputFrame,"BOTTOMRIGHT", 3, 11)

			idInputFrame.BottomLeftTex:SetTexture()
			idInputFrame.BottomRightTex:SetTexture()
			idInputFrame.BottomTex:SetTexture()
			idInputFrame.LeftTex:SetTexture()
			idInputFrame.MiddleTex:SetTexture()
			idInputFrame.RightTex:SetTexture()
			idInputFrame.TopLeftTex:SetTexture()
			idInputFrame.TopRightTex:SetTexture()
			idInputFrame.TopTex:SetTexture()

			local idInputFrameBG = CreateFrame("Frame", nil, idInputFrame, "BackdropTemplate")
			idInputFrameBG:SetFrameLevel(frame:GetFrameLevel() + 1)
			idInputFrameBG:SetPoint("TOPLEFT", -6, 6)
			idInputFrameBG:SetPoint("BOTTOMRIGHT", 9, -6)
			idInputFrameBG:SetBackdrop({
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
				tile = true, tileSize = 16, edgeSize = 16,
				insets = { left = 4, right = 4, top = 4, bottom = 4 }
			})
			idInputFrameBG:SetBackdropBorderColor(0.6, 0.6, 0.6)

			local idInputEditBox= idInputFrame.EditBox
			idInputEditBox.Instructions:SetText("ID #1, ID #2, ID #3...")
			idInputEditBox:SetWidth(idInputFrame:GetWidth() - 18)
			idInputEditBox:HookScript("OnTextChanged", function(self, isUserInput)
				if isUserInput then
					local output = ""

					for spellID in self:GetText():gmatch("%d+") do
						spellID = tonumber(spellID)
						if spellID > INT_LIMIT then
							output = output .. spellID .. " > " .. L["ERROR_RED"] .. "\n"
						else
							local link = GetSpellLink(spellID)
							if link then
								output = output .. spellID .. " > " .. link .. "\n"
							else
								output = output .. spellID .. " > " .. L["ERROR_RED"] .. "\n"
							end
						end
					end

					previewScrollChild:SetText(output)
				end
			end)

			local addButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
			addButton:SetPoint("TOP", idInputFrameBG, "BOTTOM", 0, 0)
			addButton:SetPoint("LEFT", 10, 0)
			addButton:SetPoint("RIGHT", -7, 0)
			addButton:SetHeight(24)
			addButton:SetScript("OnClick", function()
				local text = s_trim(idInputEditBox:GetText())
				if text ~= "" then
					for spellID in text:gmatch("%d+") do
						spellID = tonumber(spellID)
						if spellID <= INT_LIMIT and not activeData[spellID] and GetSpellLink(spellID) then
							activeData[spellID] = true
						end
					end

					prepAuraList(activeData)

					auraListFrame:Update()

					idInputEditBox:SetText("")
					idInputEditBox:ClearFocus()
					previewScrollChild:SetText("")
				end
			end)

			local addText = addButton:GetFontString()
			addText:ClearAllPoints()
			addText:SetPoint("TOPLEFT", 15, -1)
			addText:SetPoint("BOTTOMRIGHT", -15, 1)
			addText:SetJustifyV("MIDDLE")
			addText:SetText(L["ADD"])

			local exportButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
			exportButton:SetPoint("TOP", addButton, "BOTTOM", 0, 0)
			exportButton:SetPoint("LEFT", 10, 0)
			exportButton:SetPoint("RIGHT", -7, 0)
			exportButton:SetHeight(24)
			exportButton:SetScript("OnClick", function()
				local text = ""
				for id in next, activeData do
					text = text .. id .. ", "
				end

				idInputEditBox:SetFocus()
				idInputEditBox:SetText(text)
				idInputEditBox:HighlightText()
			end)

			local exportText = exportButton:GetFontString()
			exportText:ClearAllPoints()
			exportText:SetPoint("TOPLEFT", 15, -1)
			exportText:SetPoint("BOTTOMRIGHT", -15, 1)
			exportText:SetJustifyV("MIDDLE")
			exportText:SetText(L["EXPORT"])
		end

		data[1], data[2], data[3] = auras, buffs, debuffs

		t_wipe(history[1])
		t_wipe(history[2])
		t_wipe(history[3])

		local firstTab = 1

		for i = 3, 1, -1 do
			if data[i] then
				PanelTemplates_EnableTab(frame.AuraList, i)

				firstTab = i
			else
				PanelTemplates_DisableTab(frame.AuraList, i)
			end
		end

		PanelTemplates_SetTab(frame.AuraList, firstTab)

		activeData = data[firstTab]
		prepAuraList(activeData)

		activeHistory = history[firstTab]

		frame.AuraList:Update()

		frame.TitleText:SetText(name)
		frame.IDInput.EditBox:SetText("")
		frame.Preview.ScrollChild:SetText("")

		frame:SetScript("OnHide", nil)
		frame:Hide()
		frame:SetScript("OnHide", hideCallback)
		frame:Show()
	end
end

local globalIgnoredKeys = {
	-- enabled = true,
	point = true,
}

function CONFIG:CopySettings(src, dest, ignoredKeys)
	for k, v in next, dest do
		if not globalIgnoredKeys[k] and not (ignoredKeys and ignoredKeys[k]) then
			if src[k] ~= nil then
				if type(v) == "table" then
					if next(v) and type(src[k]) == "table" then
						self:CopySettings(src[k], v, ignoredKeys)
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

do
	local callbacks = {}

	function CONFIG:AddCallback(func)
		t_insert(callbacks, func)
	end

	function CONFIG:RunCallbacks()
		for i = #callbacks, 1, -1 do
			callbacks[i]()
		end
	end
end
