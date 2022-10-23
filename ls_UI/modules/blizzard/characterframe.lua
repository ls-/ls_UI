local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_floor = _G.math.floor
local next = _G.next
local s_trim = _G.string.trim
local s_upper = _G.string.upper
local tonumber = _G.tonumber

-- Mine
local isInit = false

local EQUIP_SLOTS = {
	[ 1] = "CharacterHeadSlot",
	[ 2] = "CharacterNeckSlot",
	[ 3] = "CharacterShoulderSlot",
	[ 5] = "CharacterChestSlot",
	[ 6] = "CharacterWaistSlot",
	[ 7] = "CharacterLegsSlot",
	[ 8] = "CharacterFeetSlot",
	[ 9] = "CharacterWristSlot",
	[10] = "CharacterHandsSlot",
	[11] = "CharacterFinger0Slot",
	[12] = "CharacterFinger1Slot",
	[13] = "CharacterTrinket0Slot",
	[14] = "CharacterTrinket1Slot",
	[15] = "CharacterBackSlot",
	[16] = "CharacterMainHandSlot",
	[17] = "CharacterSecondaryHandSlot",
}

local ILVL_COLORS = {}
local ILVL_STEP = 19 -- the ilvl step between content difficulties

local avgItemLevel

local function getItemLevelColor(itemLevel)
	itemLevel = tonumber(itemLevel) or 0

	-- if an item is worse than the average ilvl by one full step, it's really bad
	return E:GetGradientAsRGB((itemLevel - avgItemLevel + ILVL_STEP) / ILVL_STEP, ILVL_COLORS)
end

local function scanSlot(slotID)
	local link = GetInventoryItemLink("player", slotID)
	if link then
		return true, GetDetailedItemLevelInfo(link), E:GetItemEnchantGemInfo(link)
	elseif GetInventoryItemTexture("player", slotID) then
		-- if there's no link, but there's a texture, it means that there's
		-- an item we have no info for
		return false, "", "", "", "", ""
	end

	return true, "", "", "", "", ""
end

local function updateSlot(slotID)
	if not (C.db.profile.blizzard.character_frame.ilvl or C.db.profile.blizzard.character_frame.enhancements) then
		_G[EQUIP_SLOTS[slotID]].ItemLevelText:SetText("")
		_G[EQUIP_SLOTS[slotID]].EnchantText:SetText("")
		_G[EQUIP_SLOTS[slotID]].GemText:SetText("")

		return
	end

	local isOk, iLvl, enchant, gem1, gem2, gem3 = scanSlot(slotID)
	if isOk then
		if C.db.profile.blizzard.character_frame.ilvl then
			_G[EQUIP_SLOTS[slotID]].ItemLevelText:SetText(iLvl)
			_G[EQUIP_SLOTS[slotID]].ItemLevelText:SetTextColor(getItemLevelColor(iLvl))
		else
			_G[EQUIP_SLOTS[slotID]].ItemLevelText:SetText("")
		end

		if C.db.profile.blizzard.character_frame.enhancements then
			_G[EQUIP_SLOTS[slotID]].EnchantText:SetText(enchant)
			_G[EQUIP_SLOTS[slotID]].GemText:SetText(s_trim(gem1 .. gem2 .. gem3))
		else
			_G[EQUIP_SLOTS[slotID]].EnchantText:SetText("")
			_G[EQUIP_SLOTS[slotID]].GemText:SetText("")
		end
	else
		C_Timer.After(0.33, function() updateSlot(slotID) end)
	end
end

local function updateAllSlots()
	if not (C.db.profile.blizzard.character_frame.ilvl or C.db.profile.blizzard.character_frame.enhancements) then
		for _, slotName in next, EQUIP_SLOTS do
			_G[slotName].ItemLevelText:SetText("")
			_G[slotName].EnchantText:SetText("")
			_G[slotName].GemText:SetText("")
		end

		return
	end

	local scanComplete = true
	local showILvl, showEnchants = C.db.profile.blizzard.character_frame.ilvl, C.db.profile.blizzard.character_frame.enhancements
	local isOk, iLvl, enchant, gem1, gem2, gem3
	for slotID, slotName in next, EQUIP_SLOTS do
		isOk, iLvl, enchant, gem1, gem2, gem3 = scanSlot(slotID)

		if showILvl then
			_G[slotName].ItemLevelText:SetText(iLvl)
			_G[slotName].ItemLevelText:SetTextColor(getItemLevelColor(iLvl))
		else
			_G[slotName].ItemLevelText:SetText("")
		end

		if showEnchants then
			_G[slotName].EnchantText:SetText(enchant)
			_G[slotName].GemText:SetText(s_trim(gem1 .. gem2 .. gem3))
		else
			_G[slotName].EnchantText:SetText("")
			_G[slotName].GemText:SetText("")
		end

		scanComplete = scanComplete and isOk
	end

	if not scanComplete then
		C_Timer.After(0.33, updateAllSlots)
	end
end

local SLOT_TEXTURES_TO_REMOVE = {
	["410248"] = true,
	["INTERFACE\\CHARACTERFRAME\\CHAR-PAPERDOLL-PARTS"] = true,
}

function MODULE:HasCharacterFrame()
	return isInit
end

function MODULE:SetUpCharacterFrame()
	if not isInit and PrC.db.profile.blizzard.character_frame.enabled then
		if CharacterFrame:IsShown() then
			HideUIPanel(CharacterFrame)
		end

		avgItemLevel = m_floor(GetAverageItemLevel())

		ILVL_COLORS[1] = C.db.global.colors.red
		ILVL_COLORS[2] = C.db.global.colors.yellow
		ILVL_COLORS[3] = C.db.global.colors.white

		for slot, textOnRight in next, {
			[CharacterBackSlot] = true,
			[CharacterChestSlot] = true,
			[CharacterFeetSlot] = false,
			[CharacterFinger0Slot] = false,
			[CharacterFinger1Slot] = false,
			[CharacterHandsSlot] = false,
			[CharacterHeadSlot] = true,
			[CharacterLegsSlot] = false,
			[CharacterMainHandSlot] = false,
			[CharacterNeckSlot] = true,
			[CharacterSecondaryHandSlot] = true,
			[CharacterShirtSlot] = true,
			[CharacterShoulderSlot] = true,
			[CharacterTabardSlot] = true,
			[CharacterTrinket0Slot] = false,
			[CharacterTrinket1Slot] = false,
			[CharacterWaistSlot] = false,
			[CharacterWristSlot] = true,
		} do
			for _, v in next, {slot:GetRegions()} do
				if v:IsObjectType("Texture") and SLOT_TEXTURES_TO_REMOVE[s_upper(v:GetTexture() or "")] then
					v:SetTexture(0)
					v:Hide()
				end
			end

			E:SkinInvSlotButton(slot)
			slot:SetSize(36, 36)

			slot.popoutButton:SetFrameStrata("HIGH")

			local enchText = slot:CreateFontString(nil, "ARTWORK")
			enchText:SetFontObject("GameFontNormalSmall")
			enchText:SetSize(160, 22)
			enchText:SetJustifyH(textOnRight and "LEFT" or "RIGHT")
			enchText:SetJustifyV("TOP")
			enchText:SetTextColor(0, 1, 0)
			slot.EnchantText = enchText

			local gemText = slot:CreateFontString(nil, "ARTWORK")
			gemText:SetFont(GameFontNormal:GetFont(), 14) -- it only displays icons
			gemText:SetSize(157, 14)
			gemText:SetJustifyH(textOnRight and "LEFT" or "RIGHT")
			slot.GemText = gemText

			local iLvlText = slot:CreateFontString(nil, "ARTWORK")
			E.FontStrings:Capture(iLvlText, "button")
			iLvlText:UpdateFont(12)
			iLvlText:SetJustifyH("RIGHT")
			iLvlText:SetJustifyV("BOTTOM")
			iLvlText:SetPoint("TOPLEFT", -2, -1)
			iLvlText:SetPoint("BOTTOMRIGHT", 2, 1)
			slot.ItemLevelText = iLvlText

			if textOnRight then
				enchText:SetPoint("TOPLEFT", slot, "TOPRIGHT", 4, 0)
				gemText:SetPoint("BOTTOMLEFT", slot, "BOTTOMRIGHT", 7, 0)
			else
				enchText:SetPoint("TOPRIGHT", slot, "TOPLEFT", -4, 0)
				gemText:SetPoint("BOTTOMRIGHT", slot, "BOTTOMLEFT", -7, 0)
			end
		end

		CharacterHeadSlot:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 6, -6)
		CharacterHandsSlot:SetPoint("TOPRIGHT", CharacterFrame.Inset, "TOPRIGHT", -6, -6)
		CharacterMainHandSlot:SetPoint("BOTTOMLEFT", CharacterFrame.Inset, "BOTTOMLEFT", 176, 5)
		CharacterSecondaryHandSlot:ClearAllPoints()
		CharacterSecondaryHandSlot:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -176, 5)

		CharacterModelScene:SetSize(300, 360) -- needed for OrbitCameraMixin
		CharacterModelScene:ClearAllPoints()
		CharacterModelScene:SetPoint("TOPLEFT", CharacterFrame.Inset, 64, -3)
		-- CharacterModelScene:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, -64, 4)

		for _, texture in next, {
			CharacterModelScene.BackgroundBotLeft,
			CharacterModelScene.BackgroundBotRight,
			CharacterModelScene.BackgroundOverlay,
			CharacterModelScene.BackgroundTopLeft,
			CharacterModelScene.BackgroundTopRight,
			CharacterStatsPane.ClassBackground,
			PaperDollInnerBorderBottom,
			PaperDollInnerBorderBottom2,
			PaperDollInnerBorderBottomLeft,
			PaperDollInnerBorderBottomRight,
			PaperDollInnerBorderLeft,
			PaperDollInnerBorderRight,
			PaperDollInnerBorderTop,
			PaperDollInnerBorderTopLeft,
			PaperDollInnerBorderTopRight,
		} do
			texture:SetTexture(nil)
			texture:Hide()
		end

		PaperDollFrame.TitleManagerPane:SetSize(0, 0)
		PaperDollFrame.TitleManagerPane:SetPoint("TOPLEFT", CharacterFrame.InsetRight, "TOPLEFT", 3, -2)
		PaperDollFrame.TitleManagerPane:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -21, 4)

		PaperDollFrame.TitleManagerPane.ScrollBox:SetSize(0, 0)
		PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint("TOPLEFT", CharacterFrame.InsetRight, "TOPLEFT", 3, -2)
		PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -26, 5)

		PaperDollFrame.TitleManagerPane.ScrollBar:ClearAllPoints()
		PaperDollFrame.TitleManagerPane.ScrollBar:SetPoint("TOPRIGHT", CharacterFrame.InsetRight, "TOPRIGHT", 1, -2)
		PaperDollFrame.TitleManagerPane.ScrollBar:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", 1, 0)

		hooksecurefunc("PaperDollTitlesPane_InitButton", function(button)
			button.BgTop:Hide()
			button.BgMiddle:Hide()
			button.BgBottom:Hide()
		end)

		PaperDollFrame.EquipmentManagerPane.EquipSet:SetPoint("TOPLEFT", 2, -2)

		PaperDollFrame.EquipmentManagerPane:SetSize(0, 0)
		PaperDollFrame.EquipmentManagerPane:SetPoint("TOPLEFT", CharacterFrame.InsetRight, "TOPLEFT", 3, -2)
		PaperDollFrame.EquipmentManagerPane:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -21, 4)

		PaperDollFrame.EquipmentManagerPane.ScrollBox:SetSize(0, 0)
		PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint("TOPLEFT", CharacterFrame.InsetRight, "TOPLEFT", 3, -28)
		PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -26, 5)

		PaperDollFrame.EquipmentManagerPane.ScrollBar:ClearAllPoints()
		PaperDollFrame.EquipmentManagerPane.ScrollBar:SetPoint("TOPRIGHT", CharacterFrame.InsetRight, "TOPRIGHT", 1, -2)
		PaperDollFrame.EquipmentManagerPane.ScrollBar:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", 1, 0)

		hooksecurefunc("PaperDollEquipmentManagerPane_InitButton", function(button)
			button.BgTop:Hide()
			button.BgMiddle:Hide()
			button.BgBottom:Hide()
		end)

		hooksecurefunc("CharacterFrame_Expand", function()
			CharacterFrame:SetSize(640, 431) -- 540 + 100, 424 + 7
			CharacterFrame.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 432, 4)

			CharacterFrame.Inset.Bg:SetTexture("Interface\\DressUpFrame\\DressingRoom" .. E.PLAYER_CLASS)
			CharacterFrame.Inset.Bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
			CharacterFrame.Inset.Bg:SetHorizTile(false)
			CharacterFrame.Inset.Bg:SetVertTile(false)

			updateAllSlots()
		end)

		hooksecurefunc("CharacterFrame_Collapse", function()
			CharacterFrame:SetHeight(424)
			CharacterFrame.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 332, 4)

			CharacterFrame.Inset.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", "REPEAT", "REPEAT")
			CharacterFrame.Inset.Bg:SetTexCoord(0, 1, 0, 1)
			CharacterFrame.Inset.Bg:SetHorizTile(true)
			CharacterFrame.Inset.Bg:SetVertTile(true)
		end)

		E:RegisterEvent("ITEM_LOCK_CHANGED", function(bagOrSlotID, slotID)
			if CharacterFrame:IsShown() and bagOrSlotID and not slotID and EQUIP_SLOTS[bagOrSlotID] then
				updateSlot(bagOrSlotID)
			end
		end)

		E:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", function(slotID)
			if CharacterFrame:IsShown() and EQUIP_SLOTS[slotID] then
				updateSlot(slotID)
			end
		end)

		E:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE", function()
			avgItemLevel = m_floor(GetAverageItemLevel())
		end)

		isInit = true
	end
end

function MODULE:UpadteCharacterFrame()
	if not isInit then
		return
	end

	updateAllSlots()
end
