local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local s_trim = _G.string.trim
local s_upper = _G.string.upper
local tonumber = _G.tonumber

-- Mine
local ILVL_COLORS = {}
local ILVL_STEP = 13 -- the ilvl step between content difficulties

local avgItemLevel

local function getItemLevelColor(itemLevel)
	itemLevel = tonumber(itemLevel) or 0

	-- if an item is worse than the average ilvl by one full step, it's really bad
	return E:GetGradientAsRGB((itemLevel - avgItemLevel + ILVL_STEP) / ILVL_STEP, ILVL_COLORS)
end

local function scanSlot(slotID)
	local link = GetInventoryItemLink(InspectFrame.unit, slotID)
	if link then
		return true, C_Item.GetDetailedItemLevelInfo(link), E:GetItemEnchantGemInfo(link)
	elseif GetInventoryItemTexture(InspectFrame.unit, slotID) then
		-- if there's no link, but there's a texture, it means that there's an item we have no info for
		return false, "", "", "", "", ""
	end

	return true, "", "", "", "", ""
end

local function updateSlot(button)
	if avgItemLevel == 0 then
		avgItemLevel = C_PaperDollInfo.GetInspectItemLevel(InspectFrame.unit)
	end

	local isOk, iLvl, enchant, gem1, gem2, gem3 = scanSlot(button:GetID(), button:GetItem())
	if isOk then
		if C.db.profile.blizzard.inspect_frame.ilvl then
			button.ItemLevelText:SetText(iLvl)
			button.ItemLevelText:SetTextColor(getItemLevelColor(iLvl))
		else
			button.ItemLevelText:SetText("")
		end

		if C.db.profile.blizzard.inspect_frame.enhancements then
			button.EnchantText:SetText(enchant)
			button.GemText:SetText(s_trim(gem1 .. gem2 .. gem3))
		else
			button.EnchantText:SetText("")
			button.GemText:SetText("")
		end
	end
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

			E:SkinInvSlotButton(slot)
			slot:SetSize(36, 36)

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
