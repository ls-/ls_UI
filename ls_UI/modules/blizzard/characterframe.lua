local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local ipairs = _G.ipairs
local m_floor = _G.math.floor
local next = _G.next
local s_upper = _G.string.upper
local tonumber = _G.tonumber

-- Mine
local EQUIP_SLOTS = {
	[CharacterBackSlot] = true,
	[CharacterChestSlot] = true,
	[CharacterFeetSlot] = true,
	[CharacterFinger0Slot] = true,
	[CharacterFinger1Slot] = true,
	[CharacterHandsSlot] = true,
	[CharacterHeadSlot] = true,
	[CharacterLegsSlot] = true,
	[CharacterMainHandSlot] = true,
	[CharacterNeckSlot] = true,
	[CharacterSecondaryHandSlot] = true,
	[CharacterShirtSlot] = true,
	[CharacterShoulderSlot] = true,
	[CharacterTabardSlot] = true,
	[CharacterTrinket0Slot] = true,
	[CharacterTrinket1Slot] = true,
	[CharacterWaistSlot] = true,
	[CharacterWristSlot] = true,
}

local ILVL_COLORS = {}
local ILVL_STEP = 13 -- the ilvl step between content difficulties

local itemLoc = {}
local avgItemLevel

local function getItemLevelColor(itemLevel)
	itemLevel = tonumber(itemLevel or "") or 0

	-- if an item is worse than the average ilvl by one full step, it's really bad
	return E:GetGradientAsRGB((itemLevel - avgItemLevel + ILVL_STEP) / ILVL_STEP, ILVL_COLORS)
end

local function scanSlot(slotID)
	local link = GetInventoryItemLink("player", slotID)
	if link then
		-- C_Item.GetCurrentItemLevel is more accurate than GetDetailedItemLevelInfo
		itemLoc.equipmentSlotIndex = slotID

		return true, C_Item.GetCurrentItemLevel(itemLoc), E:GetItemEnchantGemInfo(link)
	elseif GetInventoryItemTexture("player", slotID) then
		-- if there's no link, but there's a texture, it means that there's an item we have no info for
		return false
	end

	return true
end

local function updateSlot(button)
	if not EQUIP_SLOTS[button] then
		return
	end

	if not (C.db.profile.blizzard.character_frame.ilvl or C.db.profile.blizzard.character_frame.enhancements or C.db.profile.blizzard.character_frame.upgrade) then
		button.ItemLevelText:SetText("")
		button.EnchantText:SetText("")
		button.UpgradeText:SetText("")
		button.GemDisplay:SetGems()

		return
	end

	local isOk, iLvl, enchant, gem1, gem2, gem3, upgrade = scanSlot(button:GetID())
	if isOk then
		if C.db.profile.blizzard.character_frame.ilvl then
			button.ItemLevelText:SetText(iLvl or "")
			button.ItemLevelText:SetTextColor(getItemLevelColor(iLvl))
		else
			button.ItemLevelText:SetText("")
		end

		if C.db.profile.blizzard.character_frame.enhancements then
			button.EnchantText:SetText(enchant or "")
			button.EnchantIcon:SetShown(enchant)
			button.GemDisplay:SetGems(gem1, gem2, gem3)
		else
			button.EnchantText:SetText("")
			button.EnchantIcon:Hide()
			button.GemDisplay:SetGems()
		end

		if C.db.profile.blizzard.character_frame.upgrade then
			button.UpgradeText:SetText(upgrade or "")
		else
			button.UpgradeText:SetText("")
		end
	else
		C_Timer.After(0.33, function() updateSlot(button) end)
	end
end

local gem_display_proto = {}

function gem_display_proto:SetGems(...)
	local sockets = {...}
	local numSockets = 0

	for _, socket in next, sockets do
		numSockets = numSockets + (socket and 1 or 0)
	end

	for index, slot in ipairs(self.Slots) do
		slot:SetShown(index <= numSockets)
		-- slot:SetShown(true)

		slot.Gem:SetTexture(sockets[index])
		-- slot.Gem:SetTexture("Interface\\ICONS\\INV_Misc_Gem_Opal_01")
	end

	self:Layout()
end

local isInit = false

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

		local SLOT_TEXTURES_TO_REMOVE = {
			["410248"] = true,
			["INTERFACE\\CHARACTERFRAME\\CHAR-PAPERDOLL-PARTS"] = true,
		}

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
			enchText:Hide()
			slot.EnchantText = enchText

			local enchIcon = slot:CreateTexture(nil, "OVERLAY", nil, 2)
			enchIcon:SetSize(12, 12)
			enchIcon:SetTexture("Interface\\ContainerFrame\\CosmeticIconBorder")
			enchIcon:SetSnapToPixelGrid(false)
			enchIcon:SetTexelSnappingBias(0)
			enchIcon:SetDesaturated(true)
			enchIcon:SetVertexColor(0, 0.95, 0, 0.85)
			slot.EnchantIcon = enchIcon

			local upgradeText = slot:CreateFontString(nil, "ARTWORK")
			upgradeText:SetFontObject("GameFontHighlightSmall")
			upgradeText:SetSize(160, 0)
			upgradeText:SetJustifyH(textOnRight and "LEFT" or "RIGHT")
			upgradeText:Hide()
			slot.UpgradeText = upgradeText

			local iLvlText = slot:CreateFontString(nil, "ARTWORK")
			E.FontStrings:Capture(iLvlText, "button")
			iLvlText:UpdateFont(12)
			iLvlText:SetJustifyV("BOTTOM")
			iLvlText:SetJustifyH(textOnRight and "LEFT" or "RIGHT")
			iLvlText:SetPoint("TOPLEFT", -1, -1)
			iLvlText:SetPoint("BOTTOMRIGHT", 2, 1)
			slot.ItemLevelText = iLvlText

			if textOnRight then
				enchText:SetPoint("TOPLEFT", slot, "TOPRIGHT", 6, 0)
				enchIcon:SetPoint("TOPLEFT", -2, 2)
				enchIcon:SetTexCoord(66 / 128, 42 / 128, 0 / 128, 24 / 128)
				upgradeText:SetPoint("BOTTOMLEFT", slot, "BOTTOMRIGHT", 6, 0)
			else
				enchText:SetPoint("TOPRIGHT", slot, "TOPLEFT", -6, 0)
				enchIcon:SetPoint("TOPRIGHT", 2, 2)
				enchIcon:SetTexCoord(42 / 128, 66 / 128, 0 / 128, 24 / 128)
				upgradeText:SetPoint("BOTTOMRIGHT", slot, "BOTTOMLEFT", -6, 0)
			end

			local isWeaponSlot = slot == CharacterMainHandSlot or slot == CharacterSecondaryHandSlot

			-- I could reuse .SocketDisplay, but my gut is telling me not to do it
			local gemDisplay = Mixin(CreateFrame("Frame", nil, slot, isWeaponSlot and "PaperDollItemSocketDisplayHorizontalTemplate" or "PaperDollItemSocketDisplayVerticalTemplate"), gem_display_proto)
			gemDisplay:Show()
			slot.GemDisplay = gemDisplay

			for i = 1, 3 do
				gemDisplay["Slot" .. i]:SetSize(12, 12)

				gemDisplay["Slot" .. i].Gem:Show()
				gemDisplay["Slot" .. i].Gem:SetTexCoord(6 / 64, 58 / 64, 6 / 64, 58 / 64)
				gemDisplay["Slot" .. i].Gem:SetSnapToPixelGrid(false)
				gemDisplay["Slot" .. i].Gem:SetTexelSnappingBias(0)

				gemDisplay["Slot" .. i].Slot:SetDrawLayer("OVERLAY")
				gemDisplay["Slot" .. i].Slot:SetTexture("Interface\\AddOns\\ls_UI\\assets\\empty-socket")
				gemDisplay["Slot" .. i].Slot:SetTexCoord(4 / 32, 28 / 32, 4 / 32, 28 / 32)
				gemDisplay["Slot" .. i].Slot:SetSnapToPixelGrid(false)
				gemDisplay["Slot" .. i].Slot:SetTexelSnappingBias(0)
			end

			if isWeaponSlot then
				gemDisplay:SetPoint("TOP", 0, 7)
			elseif textOnRight then
				gemDisplay:SetPoint("RIGHT", 7, 0)
			else
				gemDisplay:SetPoint("LEFT", -7, 0)
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

		CharacterModelScene.GearEnchantAnimation.FrameFX.PurpleGlow:ClearAllPoints()
		CharacterModelScene.GearEnchantAnimation.FrameFX.PurpleGlow:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
		CharacterModelScene.GearEnchantAnimation.FrameFX.PurpleGlow:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)

		CharacterModelScene.GearEnchantAnimation.FrameFX.BlueGlow:ClearAllPoints()
		CharacterModelScene.GearEnchantAnimation.FrameFX.BlueGlow:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
		CharacterModelScene.GearEnchantAnimation.FrameFX.BlueGlow:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)

		CharacterModelScene.GearEnchantAnimation.FrameFX.Sparkles:ClearAllPoints()
		CharacterModelScene.GearEnchantAnimation.FrameFX.Sparkles:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
		CharacterModelScene.GearEnchantAnimation.FrameFX.Sparkles:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)

		CharacterModelScene.GearEnchantAnimation.FrameFX.Mask:ClearAllPoints()
		CharacterModelScene.GearEnchantAnimation.FrameFX.Mask:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
		CharacterModelScene.GearEnchantAnimation.FrameFX.Mask:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)

		CharacterModelScene.GearEnchantAnimation.TopFrame.Frame:ClearAllPoints()
		CharacterModelScene.GearEnchantAnimation.TopFrame.Frame:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 2, -2)
		CharacterModelScene.GearEnchantAnimation.TopFrame.Frame:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -2, 2)

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
			texture:SetTexture(0)
			texture:Hide()
		end

		PaperDollFrame.TitleManagerPane:SetSize(0, 0)
		PaperDollFrame.TitleManagerPane:SetPoint("TOPLEFT", CharacterFrame.InsetRight, "TOPLEFT", 3, -2)
		PaperDollFrame.TitleManagerPane:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -21, 4)

		PaperDollFrame.TitleManagerPane.ScrollBox:SetSize(0, 0)
		PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint("TOPLEFT", CharacterFrame.InsetRight, "TOPLEFT", 3, -4)
		PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -26, 4)

		PaperDollFrame.TitleManagerPane.ScrollBar:ClearAllPoints()
		PaperDollFrame.TitleManagerPane.ScrollBar:SetPoint("TOPRIGHT", CharacterFrame.InsetRight, "TOPRIGHT", -10, -8)
		PaperDollFrame.TitleManagerPane.ScrollBar:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -10, 6)

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
		PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -26, 4)

		PaperDollFrame.EquipmentManagerPane.ScrollBar:ClearAllPoints()
		PaperDollFrame.EquipmentManagerPane.ScrollBar:SetPoint("TOPRIGHT", CharacterFrame.InsetRight, "TOPRIGHT", -10, -8)
		PaperDollFrame.EquipmentManagerPane.ScrollBar:SetPoint("BOTTOMRIGHT", CharacterFrame.InsetRight, "BOTTOMRIGHT", -10, 6)

		hooksecurefunc("PaperDollEquipmentManagerPane_InitButton", function(button)
			button.BgTop:Hide()
			button.BgMiddle:Hide()
			button.BgBottom:Hide()
		end)

		hooksecurefunc(CharacterFrame, "UpdateSize", function()
			if CharacterFrame.activeSubframe == "PaperDollFrame" then
				CharacterFrame:SetSize(640, 431) -- 540 + 100, 424 + 7
				CharacterFrame.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 432, 4)

				CharacterFrame.Inset.Bg:SetTexture("Interface\\DressUpFrame\\DressingRoom" .. E.PLAYER_CLASS)
				CharacterFrame.Inset.Bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
				CharacterFrame.Inset.Bg:SetHorizTile(false)
				CharacterFrame.Inset.Bg:SetVertTile(false)

				CharacterFrame.Background:Hide()
			else
				CharacterFrame.Background:Show()
			end
		end)

		local isMouseOver
		CharacterFrame:HookScript("OnUpdate", function()
			local state = CharacterFrame:IsMouseOver()
			if state ~= isMouseOver then
				for button in next, EQUIP_SLOTS do
					button.EnchantText:SetShown(state)
					button.UpgradeText:SetShown(state)
				end

				isMouseOver = state
			end
		end)

		hooksecurefunc("PaperDollItemSlotButton_Update", updateSlot)

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

	for button in next, EQUIP_SLOTS do
		updateSlot(button)
	end
end
