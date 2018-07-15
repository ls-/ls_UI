local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Loot")

-- Lua
local _G = getfenv(0)
local t_wipe = _G.table.wipe
local t_insert = _G.table.insert

-- Blizz
local GetCurrencyContainerInfo = _G.CurrencyContainerUtil.GetCurrencyContainerInfo
local GetLootSlotInfo = _G.GetLootSlotInfo
local GetLootSlotLink = _G.GetLootSlotLink
local GetLootSlotType = _G.GetLootSlotType

--[[ luacheck: globals
	CloseLoot CreateFrame CursorUpdate FauxScrollFrame_GetOffset FauxScrollFrame_OnVerticalScroll
	FauxScrollFrame_SetOffset FauxScrollFrame_Update GameTooltip GetCursorPosition GetCVarBool GetNumLootItems
	HandleModifiedItemClick IsFishingLoot IsModifiedClick LootFrame LootSlot PlaySound ResetCursor StaticPopup_Hide
	UIParent UISpecialFrames

	ITEM_QUALITY_COLORS LOOT_SLOT_CURRENCY LOOT_SLOT_ITEM TEXTURE_ITEM_QUEST_BANG TEXTURE_ITEM_QUEST_BORDER
]]

-- Mine
local isInit = false
local MIN_BUTTONS = 4
local MAX_BUTTONS = 6

local lootTable = {}

local function getNum(t)
	local num = 0

	for i = 1, #t do
		if t[i] then
			num = num + 1
		end
	end

	return num
end

local function getTooltipPoint(self)
	local quadrant = E:GetScreenQuadrant(self)
	local p, rP = "BOTTOMRIGHT", "TOPLEFT"

	if quadrant == "TOPLEFT" or quadrant == "LEFT" or quadrant == "BOTTOMLEFT" then
		p, rP = "BOTTOMLEFT", "TOPRIGHT"
	end

	return p, rP
end

local function buildSlotInfo(slot)
	local texture, item, quantity, currencyID, quality, locked, isQuestItem, questID, isActive = GetLootSlotInfo(slot)
	local link = GetLootSlotLink(slot)
	local type = GetLootSlotType(slot)

	if currencyID then
		item, texture, quantity, quality = GetCurrencyContainerInfo(currencyID, quantity, item, texture, quality)
	end

	return {
		type = type,
		link = link,
		texture = texture,
		name = item:gsub("\n", " "),
		quantity = quantity,
		quality = quality,
		isLocked = locked,
		isQuestItem = isQuestItem,
		questID = questID,
		isQuestActive = isActive,
	}
end

local function frame_OnEvent(self, event, ...)
	if event == "LOOT_OPENED" then
		self:Show()

		-- couldn't open for some reason
		if not self:IsShown() then
			CloseLoot(true)
			return
		end

		if IsFishingLoot() then
			PlaySound(3407) -- SOUNDKIT.FISHING_REEL_IN
			self.portrait:SetTexture("Interface\\ICONS\\INV_Misc_Fish_02")
		else
			if #lootTable == 0 then
				PlaySound(1264) -- SOUNDKIT.LOOT_WINDOW_OPEN_EMPTY
			end

			self.portrait:SetTexture("Interface\\ICONS\\INV_Misc_Bone_TaurenSkull_01")
		end

		if GetCVarBool("lootUnderMouse") then
			local mover = E.Movers:Get(self)
			if mover then
				mover:Disable()
			end

			local x, y = GetCursorPosition()
			x = x / UIParent:GetEffectiveScale() - 24
			y = y / UIParent:GetEffectiveScale() + 78
			if y < 480 then
				y = 480
			end

			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x, y)
			self:GetCenter()
			self:Raise()
		else
			local mover = E.Movers:Get(self, true)
			if not mover:IsEnabled() then
				mover:Enable()

				self:ClearAllPoints()
				self:SetPoint("TOPLEFT")
			end
		end

		t_wipe(lootTable)

		for slot = 1, GetNumLootItems() do
			lootTable[slot] = buildSlotInfo(slot)
		end

		self.ItemList:Update()
	elseif event == "LOOT_SLOT_CHANGED" then
		local slot = ...

		lootTable[slot] = buildSlotInfo(slot)

		self.ItemList:Update()
	elseif event == "LOOT_SLOT_CLEARED" then
		local slot = ...

		-- this event fires two times for the same slot
		if lootTable[slot] then
			lootTable[slot] = false

			self.ItemList:Update()
		end
	elseif event == "LOOT_CLOSED" then
		StaticPopup_Hide("LOOT_BIND")

		t_wipe(lootTable)

		self:Hide()
		self.ItemList:Reset()
	-- elseif event == "OPEN_MASTER_LOOT_LIST" then
	-- elseif event == "UPDATE_MASTER_LOOT_LIST" then
	end
end

local function frame_OnHide()
	CloseLoot()
end

local function itemList_Update(self)
	local buttons = self.buttons
	local offset = FauxScrollFrame_GetOffset(self)
	local index = 1
	local button, color, loot

	for i = 1, #lootTable do
		if index > MAX_BUTTONS then break end

		button = buttons[index]
		if not button then break end

		loot = lootTable[i + offset]
		if loot then
			color = ITEM_QUALITY_COLORS[loot.quality] or ITEM_QUALITY_COLORS[1]

			button.link = loot.link
			button.slot = i + offset
			button.type = loot.type
			button.hasItem = loot.type == LOOT_SLOT_ITEM

			button.Icon:SetTexture(loot.texture)
			button.Icon:SetDesaturated(not not loot.isLocked)
			button.Border:SetVertexColor(color.r, color.g, color.b)
			button.Name:SetText(loot.name)
			button.Name:SetVertexColor(color.r, color.g, color.b)
			button.Count:SetText(loot.quantity > 1 and loot.quantity or "")

			if loot.questID and not loot.isQuestActive then
				button.Quest:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBang")
				button.Quest:Show()
			elseif loot.questID or loot.isQuestItem then
				button.Quest:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder")
				button.Quest:Show()
			else
				button.Quest:Hide()
			end

			button:Show()

			index = index + 1
		end
	end

	for i = index, #buttons do
		buttons[i].link = nil
		buttons[i].slot = nil
		buttons[i]:SetScript("OnUpdate", nil)
		buttons[i]:Hide()
	end

	FauxScrollFrame_Update(self, getNum(lootTable), index - 1, 40, nil, nil, nil, nil, nil, nil, true)
end

local function itemList_Reset(self)
	FauxScrollFrame_SetOffset(self, 0)

	for i = 1, #self.buttons do
		self.buttons[i].link = nil
		self.buttons[i].slot = nil
		self.buttons[i]:SetScript("OnUpdate", nil)
		self.buttons[i]:Hide()
	end

	self.ScrollBar:SetValue(0)
end

local function itemList_OnVerticalScroll(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 40, itemList_Update)
end

local function itemButton_OnClick(self)
	if IsModifiedClick() then
		HandleModifiedItemClick(self.link)
	else
		LootSlot(self.slot)
	end
end

local function showTooltip(self)
	if self.type == LOOT_SLOT_ITEM then
		local p, rP = getTooltipPoint(self)

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, 0, 0)
		GameTooltip:SetLootItem(self.slot)

		CursorUpdate(self)
	elseif self.type == LOOT_SLOT_CURRENCY then
		local p, rP = getTooltipPoint(self)

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, 0, 0)
		GameTooltip:SetLootCurrency(self.slot)

		CursorUpdate(self)
	end
end

local function itemButton_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.2 then
		if GameTooltip:IsOwned(self) then
			showTooltip(self)
		end

		self.elapsed = 0
	end
end

local function itemButton_OnEnter(self)
	showTooltip(self)

	self:SetScript("OnUpdate", itemButton_OnUpdate)
end

local function itemButton_OnLeave(self)
	GameTooltip:Hide()
	ResetCursor()

	self:SetScript("OnUpdate", nil)
end

local function createButton(parent, index)
	local button = CreateFrame("Button", "LSLootButton" .. index, parent)
	button:SetHeight(40)
	button:SetPoint("LEFT", 2, 0)
	button:SetPoint("RIGHT", -2, 0)
	button:SetPoint("TOP", 0, -2 - 40 * (index - 1))
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", itemButton_OnClick)
	button:SetScript("OnEnter", itemButton_OnEnter)
	button:SetScript("OnLeave", itemButton_OnLeave)
	parent.buttons[index] = button

	button:SetHighlightTexture("Interface\\BUTTONS\\WHITE8X8")
	button:GetHighlightTexture():SetVertexColor(0.25, 0.4, 0.8, 0.5)
	button:GetHighlightTexture():SetPoint("TOPLEFT", 1, -1)
	button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", -1, 1)

	button:SetPushedTexture("Interface\\BUTTONS\\WHITE8X8")
	button:GetPushedTexture():SetVertexColor(0.8, 0.4, 0.25, 0.5)
	button:GetPushedTexture():SetPoint("TOPLEFT", 1, -1)
	button:GetPushedTexture():SetPoint("BOTTOMRIGHT", -1, 1)

	local iconParent = CreateFrame("Frame", nil, button)
	iconParent:SetSize(32, 32)
	iconParent:SetPoint("TOPLEFT", 4, -4)

	button.Icon = E:SetIcon(iconParent, "Interface\\ICONS\\INV_Misc_QuestionMark")

	local border = E:CreateBorder(iconParent)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
	border:SetSize(16)
	border:SetOffset(-4)
	button.Border = border

	local quest = iconParent:CreateTexture(nil, "BACKGROUND", nil, 1)
	quest:SetAllPoints()
	quest:Hide()
	button.Quest = quest

	local count = iconParent:CreateFontString(nil, "OVERLAY", "LSFont12_Outline")
	count:SetPoint("BOTTOMRIGHT", 0, 1)
	count:SetJustifyH("RIGHT")
	count:SetVertexColor(1, 1, 1)
	button.Count = count

	local name = button:CreateFontString(nil, "OVERLAY", "LSFont12")
	name:SetWordWrap(true)
	name:SetJustifyH("LEFT")
	name:SetPoint("TOPLEFT", iconParent, "TOPRIGHT", 6, 0)
	name:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
	button.Name = name

	local bg = button:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", 1, -1)
	bg:SetPoint("BOTTOMRIGHT", -1, 1)
	bg:SetColorTexture(0.25, 0.25, 0.25, 0.25)
	button.BG = bg
end

function MODULE:IsInit()
	return isInit
end

function MODULE:Init()
	if not isInit and C.db.char.loot.enabled then
		local frame = CreateFrame("Frame", "LSLootFrame", UIParent, "PortraitFrameTemplate")
		frame:SetSize(192, 230 + 40 * (MAX_BUTTONS - MIN_BUTTONS))
		frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -256)
		frame:SetClampedToScreen(true)
		frame:SetClampRectInsets(-16, 4, 16, -4)
		frame:SetScript("OnEvent", frame_OnEvent)
		frame:SetScript("OnHide", frame_OnHide)
		frame:RegisterEvent("LOOT_OPENED")
		frame:RegisterEvent("LOOT_SLOT_CHANGED")
		frame:RegisterEvent("LOOT_SLOT_CLEARED")
		frame:RegisterEvent("LOOT_CLOSED")
		-- frame:RegisterEvent("OPEN_MASTER_LOOT_LIST")
		-- frame:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

		local mover = E.Movers:Create(frame)
		mover:SetClampRectInsets(-16, 4, 16, -4)

		frame.onCloseCallback = function() CloseLoot() end

		frame.portrait:SetMask("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")

		frame.TitleText:SetPoint("RIGHT", -30, 0)
		frame.TitleText:SetText(L["LOOT"])

		local inset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
		inset:SetPoint("TOPLEFT", 3, -60)
		inset:SetPoint("BOTTOMRIGHT", -5, 5)

		local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", inset, "FauxScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", 0, -1)
		scrollFrame:SetPoint("BOTTOMRIGHT", -20, -1)
		scrollFrame:SetScript("OnVerticalScroll", itemList_OnVerticalScroll)
		frame.ItemList = scrollFrame

		scrollFrame.Update = itemList_Update
		scrollFrame.Reset = itemList_Reset

		scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 0, -20)
		scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 0, 20)

		scrollFrame.buttons = {}
		for i = 1, MAX_BUTTONS do
			createButton(scrollFrame, i)
		end

		LootFrame:UnregisterAllEvents()
		t_insert(UISpecialFrames, "LSLootFrame")

		frame:Hide()

		isInit = true
	end
end
