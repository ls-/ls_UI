local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local ipairs = _G.ipairs
local next = _G.next
local s_upper = _G.string.upper
local tonumber = _G.tonumber

-- Mine
local ILVL_COLORS = {}
local ILVL_STEP = 13 -- the ilvl step between content difficulties

local avgItemLevel

local function getItemLevelColor(itemLevel)
	itemLevel = tonumber(itemLevel or "") or 0

	-- if an item is worse than the average ilvl by one full step, it's really bad
	return E:GetGradientAsRGB((itemLevel - avgItemLevel + ILVL_STEP) / ILVL_STEP, ILVL_COLORS)
end

local function scanSlot(slotID)
	local link = GetInventoryItemLink(InspectFrame.unit, slotID)
	if link then
		return true, C_Item.GetDetailedItemLevelInfo(link), E:GetItemEnchantGemInfo(link)
	elseif GetInventoryItemTexture(InspectFrame.unit, slotID) then
		-- if there's no link, but there's a texture, it means that there's an item we have no info for
		return false
	end

	return true
end

local function updateSlot(button)
	if avgItemLevel == 0 then
		avgItemLevel = C_PaperDollInfo.GetInspectItemLevel(InspectFrame.unit)
	end

	local isOk, iLvl, enchant, gem1, gem2, gem3, upgrade = scanSlot(button:GetID())
	if isOk then
		if C.db.profile.blizzard.inspect_frame.ilvl then
			button.ItemLevelText:SetText(iLvl)
			button.ItemLevelText:SetTextColor(getItemLevelColor(iLvl))
		else
			button.ItemLevelText:SetText("")
		end

		if C.db.profile.blizzard.inspect_frame.enhancements then
			button.EnchantText:SetText(enchant or "")
			button.EnchantIcon:SetShown(enchant)
			button.GemDisplay:SetGems(gem1, gem2, gem3)
		else
			button.EnchantText:SetText("")
			button.EnchantIcon:Hide()
			button.GemDisplay:SetGems()
		end

		if C.db.profile.blizzard.inspect_frame.upgrade then
			button.UpgradeText:SetText(upgrade or "")
		else
			button.UpgradeText:SetText("")
		end
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

local function init()
	if not isInit then
		ILVL_COLORS[1] = C.db.global.colors.red
		ILVL_COLORS[2] = C.db.global.colors.yellow
		ILVL_COLORS[3] = C.db.global.colors.white

		local SLOT_TEXTURES_TO_REMOVE = {
			["410248"] = true,
			["INTERFACE\\CHARACTERFRAME\\CHAR-PAPERDOLL-PARTS"] = true,
		}

		for slot, textOnRight in next, {
			[InspectBackSlot] = true,
			[InspectChestSlot] = true,
			[InspectFeetSlot] = false,
			[InspectFinger0Slot] = false,
			[InspectFinger1Slot] = false,
			[InspectHandsSlot] = false,
			[InspectHeadSlot] = true,
			[InspectLegsSlot] = false,
			[InspectMainHandSlot] = false,
			[InspectNeckSlot] = true,
			[InspectSecondaryHandSlot] = true,
			[InspectShirtSlot] = true,
			[InspectShoulderSlot] = true,
			[InspectTabardSlot] = true,
			[InspectTrinket0Slot] = false,
			[InspectTrinket1Slot] = false,
			[InspectWaistSlot] = false,
			[InspectWristSlot] = true,
		} do
			for _, v in next, {slot:GetRegions()} do
				if v:IsObjectType("Texture") and SLOT_TEXTURES_TO_REMOVE[s_upper(v:GetTexture() or "")] then
					v:SetTexture(0)
					v:Hide()
				end
			end

			local isWeaponSlot = slot == InspectMainHandSlot or slot == InspectSecondaryHandSlot

			E:SkinInvSlotButton(slot)
			slot:SetSize(36, 36)

			local enchText = slot:CreateFontString(nil, "ARTWORK")
			enchText:SetFontObject("GameFontNormalSmall")
			enchText:SetSize(160, 22)
			enchText:SetJustifyH(textOnRight and "LEFT" or "RIGHT")
			enchText:SetJustifyV("TOP")
			enchText:SetTextColor(0, 1, 0)
			slot.EnchantText = enchText

			local upgradeText = slot:CreateFontString(nil, "ARTWORK")
			upgradeText:SetFontObject("GameFontHighlightSmall")
			upgradeText:SetSize(160, 0)
			upgradeText:SetJustifyH(textOnRight and "LEFT" or "RIGHT")
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
				upgradeText:SetPoint("BOTTOMLEFT", slot, "BOTTOMRIGHT", 6, 0)
			else
				enchText:SetPoint("TOPRIGHT", slot, "TOPLEFT", -6, 0)
				upgradeText:SetPoint("BOTTOMRIGHT", slot, "BOTTOMLEFT", -6, 0)
			end

			-- I could reuse .SocketDisplay, but my gut is telling me not to do it
			local gemDisplay = Mixin(CreateFrame("Frame", nil, slot, isWeaponSlot and "PaperDollItemSocketDisplayHorizontalTemplate" or "PaperDollItemSocketDisplayVerticalTemplate"), gem_display_proto)
			gemDisplay:Show()
			slot.GemDisplay = gemDisplay

			for i = 1, 3 do
				gemDisplay["Slot" .. i]:SetSize(12, 12)

				gemDisplay["Slot" .. i].Gem:Show()
				gemDisplay["Slot" .. i].Gem:SetTexCoord(6 / 64, 58 / 64, 6 / 64, 58 / 64)

				gemDisplay["Slot" .. i].Slot:SetDrawLayer("OVERLAY")
				gemDisplay["Slot" .. i].Slot:SetTexture("Interface\\AddOns\\ls_UI\\assets\\empty-socket")
				gemDisplay["Slot" .. i].Slot:SetTexCoord(4 / 32, 28 / 32, 4 / 32, 28 / 32)
			end

			if isWeaponSlot then
				gemDisplay:SetPoint("TOP", 0, 7)
			elseif textOnRight then
				gemDisplay:SetPoint("RIGHT", 7, 0)
			else
				gemDisplay:SetPoint("LEFT", -7, 0)
			end
		end

		InspectHeadSlot:SetPoint("TOPLEFT", InspectFrame.Inset, "TOPLEFT", 6, -6)
		InspectHandsSlot:SetPoint("TOPRIGHT", InspectFrame.Inset, "TOPRIGHT", -6, -6)
		InspectMainHandSlot:SetPoint("BOTTOMLEFT", InspectFrame.Inset, "BOTTOMLEFT", 176, 5)
		InspectSecondaryHandSlot:ClearAllPoints()
		InspectSecondaryHandSlot:SetPoint("BOTTOMRIGHT", InspectFrame.Inset, "BOTTOMRIGHT", -176, 5)

		InspectModelFrame:SetSize(0, 0) -- needed for OrbitCameraMixin
		InspectModelFrame:ClearAllPoints()
		InspectModelFrame:SetPoint("TOPLEFT", 49, -66)
		InspectModelFrame:SetPoint("BOTTOMRIGHT", -51, 32)

		for _, texture in next, {
			InspectModelFrame.BackgroundBotLeft,
			InspectModelFrame.BackgroundBotRight,
			InspectModelFrame.BackgroundOverlay,
			InspectModelFrame.BackgroundTopLeft,
			InspectModelFrame.BackgroundTopRight,
			InspectModelFrameBorderBottom,
			InspectModelFrameBorderBottom2,
			InspectModelFrameBorderBottomLeft,
			InspectModelFrameBorderBottomRight,
			InspectModelFrameBorderLeft,
			InspectModelFrameBorderRight,
			InspectModelFrameBorderTop,
			InspectModelFrameBorderTopLeft,
			InspectModelFrameBorderTopRight,
		} do
			texture:SetTexture(0)
			texture:Hide()
		end

		InspectPaperDollItemsFrame.InspectTalents:SetPoint("BOTTOMRIGHT", InspectPaperDollItemsFrame, "BOTTOMRIGHT", -9, 7)

		local averageItemLevelText = InspectPaperDollItemsFrame:CreateFontString(nil, "ARTWORK")
		averageItemLevelText:SetFontObject("GameFontNormalSmall")
		averageItemLevelText:SetSize(0, 0)
		averageItemLevelText:SetJustifyH("LEFT")
		averageItemLevelText:SetPoint("BOTTOMLEFT", 9, 7)
		InspectPaperDollItemsFrame.AverageItemLevelText = averageItemLevelText

		hooksecurefunc("InspectSwitchTabs", function(tabID)
			if tabID == 1 then
				InspectFrame:SetSize(440, 431) -- 432 + 8, 424 + 7

				if not InspectFrame.unit then return end

				avgItemLevel = C_PaperDollInfo.GetInspectItemLevel(InspectFrame.unit)

				local _, class = UnitClass(InspectFrame.unit)

				InspectFrame.Inset.Bg:SetTexture("Interface\\DressUpFrame\\DressingRoom" .. class)
				InspectFrame.Inset.Bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
				InspectFrame.Inset.Bg:SetHorizTile(false)
				InspectFrame.Inset.Bg:SetVertTile(false)
			else
				InspectFrame:SetSize(338, 424) -- PortraitFrameBaseTemplate's default size
			end
		end)

		hooksecurefunc("InspectPaperDollItemSlotButton_Update", updateSlot)

		hooksecurefunc("InspectPaperDollFrame_SetLevel", function()
			averageItemLevelText:SetFormattedText(DUNGEON_SCORE_LINK_ITEM_LEVEL, C_PaperDollInfo.GetInspectItemLevel(InspectFrame.unit))
		end)

		isInit = true
	end
end

function MODULE:HasInspectFrame()
	return isInit
end

function MODULE:SetUpInspectFrame()
	if not isInit and PrC.db.profile.blizzard.inspect_frame.enabled then
		if not InspectFrame then
			E:AddOnLoadTask("Blizzard_InspectUI", init)
		else
			init()
		end
	end
end

function MODULE:UpadteInspectFrame()
	if not (isInit and InspectFrame.unit) then
		return
	end

	for _, button in next, {
		InspectBackSlot,
		InspectChestSlot,
		InspectFeetSlot,
		InspectFinger0Slot,
		InspectFinger1Slot,
		InspectHandsSlot,
		InspectHeadSlot,
		InspectLegsSlot,
		InspectMainHandSlot,
		InspectNeckSlot,
		InspectSecondaryHandSlot,
		InspectShirtSlot,
		InspectShoulderSlot,
		InspectTabardSlot,
		InspectTrinket0Slot,
		InspectTrinket1Slot,
		InspectWaistSlot,
		InspectWristSlot,
	} do
		updateSlot(button)
	end
end
