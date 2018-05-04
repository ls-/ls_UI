local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local select = _G.select
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local unpack = _G.unpack

-- Blizz
local C_Timer = _G.C_Timer

--[[ luacheck: globals
	BACKPACK_CONTAINER BAG_FILTER_ASSIGN_TO BAG_FILTER_CLEANUP BAG_FILTER_ICONS BAG_FILTER_IGNORE BAG_FILTER_LABELS
	BreakUpLargeNumbers CollectionsMicroButtonAlert ContainerIDToInventoryID CreateFrame CursorCanGoInSlot CursorHasItem
	EJMicroButtonAlert EQUIP_CONTAINER GameTooltip GameTooltip_AddNewbieTip GetAddOnInfo GetAddOnMemoryUsage
	GetBagSlotFlag GetContainerNumFreeSlots GetContainerNumSlots GetCurrencyInfo GetInventoryItemDurability
	GetInventoryItemTexture GetLFGDungeonShortageRewardInfo GetLFGRandomDungeonInfo GetLFGRoles
	GetLFGRoleShortageRewards GetMoney GetMoneyString GetNetStats GetNumAddOns GetNumRandomDungeons GetNumRFDungeons
	GetNumSavedInstances GetNumSavedWorldBosses GetQuestResetTime GetRFDungeonInfo GetSavedInstanceInfo
	GetSavedWorldBossInfo GetTime GuildMicroButtonTabard IsAddOnLoaded IsInventoryItemLocked
	IsInventoryItemProfessionBag IsLFGDungeonJoinable IsShiftKeyDown LE_BAG_FILTER_FLAG_EQUIPMENT
	LE_BAG_FILTER_FLAG_IGNORE_CLEANUP LE_BAG_FILTER_FLAG_JUNK LFDMicroButtonAlert LFG_ROLE_NUM_SHORTAGE_TYPES
	MainMenuBarDownload MainMenuBarPerformanceBar MainMenuMicroButton MICRO_BUTTONS MicroButtonPortrait
	MicroButtonTooltipText NUM_BAG_SLOTS NUM_LE_BAG_FILTER_FLAGS OverrideActionBar PERFORMANCEBAR_MEDIUM_LATENCY
	PetBattleFrame PickupBagFromSlot PlaySound PutItemInBag RegisterStateDriver RequestLFDPartyLockInfo
	RequestLFDPlayerLockInfo RequestRaidInfo SecondsToTime SetBagSlotFlag TalentMicroButtonAlert ToggleAllBags
	ToggleDropDownMenu UIDropDownMenu_AddButton UIDropDownMenu_CreateInfo UIDropDownMenu_Initialize UIParent
	UpdateAddOnMemoryUsage
]]

-- Mine
local isInit = false
local bar

local LATENCY_TEMPLATE = "|cff%s%s|r ".._G.MILLISECONDS_ABBR
local MEMORY_TEMPLATE = "%.2f MiB"

local ROLE_NAMES = {
	tank = L["TANK_BLUE"],
	healer = L["HEALER_GREEN"],
	damager = L["DAMAGER_RED"],
}

local BUTTONS = {
	CharacterMicroButton = {
		id =  1,
		icon = E.PLAYER_CLASS,
	},
	LSInventoryMicroButton = {
		id =  2,
		icon = "Inventory",
	},
	SpellbookMicroButton = {
		id =  3,
		icon = "Spellbook",
	},
	TalentMicroButton = {
		id =  4,
		icon = "Talent",
	},
	AchievementMicroButton = {
		id =  5,
		icon = "Achievement",
	},
	QuestLogMicroButton = {
		id =  6,
		icon = "Quest",
	},
	GuildMicroButton = {
		id =  7,
		icon = "Guild",
	},
	LFDMicroButton = {
		id =  8,
		icon = "LFD",
	},
	CollectionsMicroButton = {
		id =  9,
		icon = "Collection",
	},
	EJMicroButton = {
		id = 10,
		icon = "EJ",
	},
	StoreMicroButton = {
		id = 11,
		icon = "Store",
	},
	MainMenuMicroButton = {
		id = 12,
		icon = "MainMenu",
	},
	HelpMicroButton = {
		id = 13,
		icon = "Help",
	},
}

local TEXTURE_COORDS = {
	-- line #1
	WARRIOR = {1 / 256, 33 / 256, 1 / 256, 45 / 256},
	DEATHKNIGHT = {33 / 256, 65 / 256, 1 / 256, 45 / 256},
	PALADIN = {65 / 256, 97 / 256, 1 / 256, 45 / 256},
	MONK = {97 / 256, 129 / 256, 1 / 256, 45 / 256},
	PRIEST = {129 / 256, 161 / 256, 1 / 256, 45 / 256},
	SHAMAN = {161 / 256, 193 / 256, 1 / 256, 45 / 256},
	DRUID = {193 / 256, 225 / 256, 1 / 256, 45 / 256},
	-- line #2
	ROGUE = {1 / 256, 33 / 256, 45 / 256, 89 / 256},
	MAGE = {33 / 256, 65 / 256, 45 / 256, 89 / 256},
	WARLOCK = {65 / 256, 97 / 256, 45 / 256, 89 / 256},
	HUNTER = {97 / 256, 129 / 256, 45 / 256, 89 / 256},
	DEMONHUNTER = {129 / 256, 161 / 256, 45 / 256, 89 / 256},
	Spellbook = {161 / 256, 193 / 256, 45 / 256, 89 / 256},
	Talent = {193 / 256, 225 / 256, 45 / 256, 89 / 256},
	-- line #3
	Achievement = {1 / 256, 33 / 256, 89 / 256, 133 / 256},
	Quest = {33 / 256, 65 / 256, 89 / 256, 133 / 256},
	Guild = {65 / 256, 97 / 256, 89 / 256, 133 / 256},
	LFD = {97 / 256, 129 / 256, 89 / 256, 133 / 256},
	Collection = {129 / 256, 161 / 256, 89 / 256, 133 / 256},
	EJ = {161 / 256, 193 / 256, 89 / 256, 133 / 256},
	MainMenu = {193 / 256, 225 / 256, 89 / 256, 133 / 256},
	-- line #4
	Inventory = {1 / 256, 33 / 256, 133 / 256, 177 / 256},
	Store = {33 / 256, 65 / 256, 133 / 256, 177 / 256},
	Help = {65 / 256, 97 / 256, 133 / 256, 177 / 256},
	-- temp = {97 / 256, 129 / 256, 133 / 256, 177 / 256},
	-- temp = {129 / 256, 161 / 256, 133 / 256, 177 / 256},
	-- temp = {161 / 256, 193 / 256, 133 / 256, 177 / 256},
	-- temp = {193 / 256, 225 / 256, 133 / 256, 177 / 256},
	-- line #5
	highlight = {1 / 256, 33 / 256, 177 / 256, 221 / 256},
	pushed = {33 / 256, 65 / 256, 177 / 256, 221 / 256},
}

local function simpleSort(a, b)
	return a[2] > b[2]
end

local function button_UpdateIndicators(self)
	for i, indicator in next, self.Indicators do
		indicator:SetSize(self:GetWidth() / #self.Indicators, 4)
		indicator:ClearAllPoints()

		if i == 1 then
			indicator:SetPoint("BOTTOMLEFT", 0, 0)
		else
			indicator:SetPoint("BOTTOMLEFT", self.Indicators[i - 1], "BOTTOMRIGHT", 0, 0)
		end
	end
end

local function createButtonIndicator(button, indicators, num)
	indicators = indicators or {}
	num = num or #indicators

	for i = 1, num do
		local indicator = indicators[i]

		if not indicator then
			indicator = button:CreateTexture()
			indicators[i] = indicator
		end

		indicator:SetDrawLayer("BACKGROUND", 3)
		indicator:SetColorTexture(1, 1, 1, 1)
	end

	button.Indicators = indicators
	button.UpdateIndicators = button_UpdateIndicators
end

local function getTooltipPoint(self)
	local quadrant = E:GetScreenQuadrant(self)
	local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", 2, -2

	if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
		p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", 2, 2
	elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
		p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", -2, -2
	elseif quadrant == "BOTTOMRIGHT" then
		p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", -2, 2
	end

	return p, rP, x, y
end

local function updateNormalTexture(button)
	button:SetNormalTexture(nil)
end

local function updatePushedTexture(button)
	button:SetPushedTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")

	local pushed = button:GetPushedTexture()
	pushed:SetTexCoord(unpack(TEXTURE_COORDS.pushed))
	pushed:ClearAllPoints()
	pushed:SetPoint("TOPLEFT", 1, -1)
	pushed:SetPoint("BOTTOMRIGHT", -1, 1)
end

local function updateDisabledTexture(button)
	button:SetDisabledTexture(nil)
end

local function updateHighlightTexture(button)
	button:SetHighlightTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu", "ADD")

	local highlight = button:GetHighlightTexture()
	highlight:SetTexCoord(unpack(TEXTURE_COORDS.highlight))
	highlight:ClearAllPoints()
	highlight:SetPoint("TOPLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", -1, 1)
end

local function button_OnEnter(self)
	local p, rP, x, y = getTooltipPoint(LSMicroMenu)

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(p, self, rP, x, y)
	GameTooltip:SetText(self.tooltipText, 1, 1, 1, 1)

	if SHOW_NEWBIE_TIPS == "1" and self.newbieText then
		GameTooltip:AddLine(self.newbieText, 1, 0.82, 0, 1, true)
	end

	if not self:IsEnabled() and (self.minLevel or self.disabledTooltip or self.factionGroup) then
		local r, g, b = M.COLORS.RED:GetRGB()

		if self.factionGroup == "Neutral" then
			GameTooltip:AddLine(L["FEATURE_NOT_AVAILBLE_NEUTRAL"], r, g, b, true)
		elseif self.minLevel then
			GameTooltip:AddLine(L["FEATURE_BECOMES_AVAILABLE_AT_LEVEL"]:format(self.minLevel), r, g, b, true)
		elseif self.disabledTooltip then
			GameTooltip:AddLine(self.disabledTooltip, r, g, b, true)
		end
	end

	GameTooltip:Show()
end

local function handleMicroButton(button)
	button:SetHitRectInsets(0, 0, 0, 0)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	updateNormalTexture(button)
	updatePushedTexture(button)
	updateDisabledTexture(button)
	updateHighlightTexture(button)

	local border = E:CreateBorder(button)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
	border:SetSize(16)
	border:SetOffset(-4)
	button.Border = border

	local flash = button.Flash
	flash:SetTexture("Interface\\BUTTONS\\Micro-Highlight")
	flash:SetTexCoord(0 / 64, 33 / 64, 0, 42 / 64)
	flash:SetDrawLayer("OVERLAY", 2)
	flash:ClearAllPoints()
	flash:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
	flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)

	local bg = button:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetColorTexture(0, 0, 0, 1)
	bg:SetAllPoints()

	local icon = button:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.Icon = icon

	button:SetScript("OnEnter", button_OnEnter)
	button:SetScript("OnUpdate", nil)
end

local function createMicroButton(name)
	return CreateFrame("Button", name, UIParent, "MainMenuBarMicroButton")
end

-- Character
local characterButton_OnEnter, characterButton_UpdateIndicator, characterButton_OnEvent

do
	local slots = {
		[ 1] = _G["HEADSLOT"],
		[ 3] = _G["SHOULDERSLOT"],
		[ 5] = _G["CHESTSLOT"],
		[ 6] = _G["WAISTSLOT"],
		[ 7] = _G["LEGSSLOT"],
		[ 8] = _G["FEETSLOT"],
		[ 9] = _G["WRISTSLOT"],
		[10] = _G["HANDSSLOT"],
		[16] = _G["MAINHANDSLOT"],
		[17] = _G["SECONDARYHANDSLOT"],
	}
	local durabilities = {}
	local minDurability = 100

	function characterButton_UpdateIndicator(self)
		t_wipe(durabilities)
		minDurability = 100

		for i = 1, 17 do
			if slots[i] then
				local cur, max = GetInventoryItemDurability(i)

				if cur then
					cur = cur / max * 100

					durabilities[i] = cur

					if cur < minDurability then
						minDurability = cur
					end
				end
			end
		end

		self.Indicators[1]:SetVertexColor(M.COLORS.RYG:GetRGB(minDurability / 100))
	end

	function characterButton_OnEnter(self)
		button_OnEnter(self)

		if self:IsEnabled() then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["DURABILITY_COLON"])

			for i = 1, 17 do
				local cur = durabilities[i]

				if cur then
					GameTooltip:AddDoubleLine(slots[i], ("%d%%"):format(cur), 1, 1, 1, M.COLORS.RYG:GetRGB(cur / 100))
				end
			end

			GameTooltip:Show()
		end
	end

	function characterButton_OnEvent(self, event)
		if event == "UPDATE_INVENTORY_DURABILITY" then
			local t = GetTime()

			if t - (self.recentUpdate or 0 ) >= 0.1 then
				C_Timer.After(0.1, function()
					self:UpdateIndicator()
				end)

				self.recentUpdate = t
			end
		elseif event == "UPDATE_BINDINGS" then
			self.tooltipText = MicroButtonTooltipText(L["CHARACTER_INFO_BUTTON"], "TOGGLECHARACTER0")
		end
	end
end

-- Inventory
local inventoryButton_OnClick, inventoryButton_OnEnter, inventoryButton_OnEvent, inventoryButton_UpdateIndicator

do
	local CURRENCY_TEMPLATE = "%s |T%s:0|t"
	local CURRENCY_DETAILED_TEMPLATE = "%s / %s|T%s:0|t"

	local freeSlots, totalSlots = 0, 0

	local function updateBagUsageInfo()
		freeSlots, totalSlots = 0, 0

		for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			local slots, bagType = GetContainerNumFreeSlots(i)

			if bagType == 0 then
				freeSlots, totalSlots = freeSlots + slots, totalSlots + GetContainerNumSlots(i)
			end
		end
	end

	function inventoryButton_UpdateIndicator(self)
		updateBagUsageInfo()

		self.Indicators[1]:SetVertexColor(M.COLORS.RYG:GetRGB(freeSlots / totalSlots))
	end

	function inventoryButton_OnEvent(self, event, ...)
		if event == "BAG_UPDATE" then
			local bag = ...

			if bag >= BACKPACK_CONTAINER and bag <= NUM_BAG_SLOTS then
				local t = GetTime()

				if t - (self.recentUpdate or 0 ) >= 0.1 then
					C_Timer.After(0.1, function()
						self:UpdateIndicator()
					end)

					self.recentUpdate = t
				end
			end
		elseif event == "UPDATE_BINDINGS" then
			self.tooltipText = MicroButtonTooltipText(L["INVENTORY_BUTTON"], "OPENALLBAGS")
		end
	end

	function inventoryButton_OnEnter(self)
		button_OnEnter(self)

		if self:IsEnabled() then
			GameTooltip:AddLine(L["FREE_BAG_SLOTS_TOOLTIP"]:format(freeSlots))
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["CURRENCY_COLON"])

			for id in next, C.db.profile.bars.micromenu.buttons.inventory.currency do
				local name, cur, icon, _, _, max = GetCurrencyInfo(id)

				if name and icon then
					if max and max > 0 then
						if cur == max then
							GameTooltip:AddDoubleLine(name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), icon), 1, 1, 1, M.COLORS.RED:GetRGB())
						else
							GameTooltip:AddDoubleLine(name, CURRENCY_DETAILED_TEMPLATE:format(BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), icon), 1, 1, 1, M.COLORS.GREEN:GetRGB())
						end
					else
						GameTooltip:AddDoubleLine(name, CURRENCY_TEMPLATE:format(BreakUpLargeNumbers(cur), icon), 1, 1, 1, 1, 1, 1)
					end
				end
			end

			GameTooltip:AddDoubleLine(L["GOLD"], GetMoneyString(GetMoney(), true), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["INVENTORY_BUTTON_RCLICK_TOOLTIP"])
			GameTooltip:Show()
		end
	end

	function inventoryButton_OnClick(self, button)
		if button == "RightButton" then
			-- if self.Bags:IsShown() then
			-- 	self.Bags:Hide()
			-- else
			-- 	self.Bags:Show()
			-- end
		else
			ToggleAllBags()
		end
	end
end

-- Bag slots
local createBag

do
	local idOffset = ContainerIDToInventoryID(1) - 1

	local function bag_OnClick(self, button)
		if button == "RightButton" then
			PlaySound(856) -- IG_MAINMENU_OPTION_CHECKBOX_ON
			ToggleDropDownMenu(1, nil, self.FilterDropDown, self, 0, 0)
		else
			if CursorHasItem() then
				PutItemInBag(self:GetID())
			else
				PickupBagFromSlot(self:GetID())
			end
		end
	end

	local function bag_OnDragStart(self)
		PickupBagFromSlot(self:GetID())
	end

	local function bag_OnShow(self)
		self:Update()
	end

	local function bag_OnEvent(self, event)
		if event == "ITEM_LOCK_CHANGED" then
			self:UpdateLock()
		elseif event == "CURSOR_UPDATE" then
			self:UpdateCursor()
		elseif event == "BAG_UPDATE" then
			self:Update()
		elseif event == "BAG_SLOT_FLAGS_UPDATED" then
			self:Update()
		end
	end

	local function bag_OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")

		if not GameTooltip:SetInventoryItem("player", self:GetID()) then
			GameTooltip:SetText(EQUIP_CONTAINER, 1, 1, 1)
		end
	end

	local function bag_OnLeave()
		GameTooltip:Hide()
	end

	local function bag_UpdateCursor(self)
		if CursorCanGoInSlot(self:GetID()) then
			self:LockHighlight()
		else
			self:UnlockHighlight()
		end
	end

	local function bag_UpdateFilterIcon(self)
		if self:IsVisible() then
			self.FilterIcon:Hide()

			if not IsInventoryItemProfessionBag("player", self:GetID()) then
				for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
					if GetBagSlotFlag(self:GetID() - idOffset, i) then
						self.FilterIcon:SetAtlas(BAG_FILTER_ICONS[i])
						self.FilterIcon:Show()

						break
					end
				end
			end
		end
	end

	local function bag_UpdateIcon(self)
		if self:IsVisible() then
			self.Icon:SetTexture(GetInventoryItemTexture("player", self:GetID()))
		end
	end

	local function bag_UpdateLock(self)
		if self:IsVisible() then
			self.Icon:SetDesaturated(IsInventoryItemLocked(self:GetID()))
		end
	end

	local function bag_Update(self)
		if self:IsVisible() then
			self:UpdateCursor()
			self:UpdateFilterIcon()
			self:UpdateIcon()
			self:UpdateLock()
		end
	end

	local function dropDown_Initialize(self)
		local bag = self:GetParent()
		local containerID = bag:GetID() - idOffset
		local info = UIDropDownMenu_CreateInfo()

		if not IsInventoryItemProfessionBag("player", bag:GetID()) then -- The actual bank has ID -1, backpack has ID 0, we want to make sure we're looking at a regular or bank bag
			info.text = BAG_FILTER_ASSIGN_TO
			info.isTitle = 1
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info)

			info.isTitle = nil
			info.notCheckable = nil
			info.disabled = nil
			info.tooltipOnButton = 1
			info.tooltipTitle = nil
			info.tooltipWhileDisabled = 1

			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				if i ~= LE_BAG_FILTER_FLAG_JUNK then
					info.text = BAG_FILTER_LABELS[i]
					info.func = function(_, _, _, value)
						value = not value

						SetBagSlotFlag(containerID, i, value)

						if value then
							bag.FilterIcon:SetAtlas(BAG_FILTER_ICONS[i])
							bag.FilterIcon:Show()
						else
							bag.FilterIcon:Hide()
						end
					end
					info.checked = GetBagSlotFlag(containerID, i)
					UIDropDownMenu_AddButton(info)
				end
			end
		end

		info.text = BAG_FILTER_CLEANUP
		info.isTitle = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info)

		info.text = BAG_FILTER_IGNORE
		info.isTitle = nil
		info.notCheckable = nil
		info.disabled = nil
		info.isNotRadio = true
		info.func = function(_, _, _, value)
			SetBagSlotFlag(containerID, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value)
		end
		info.checked = GetBagSlotFlag(containerID, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP)
		UIDropDownMenu_AddButton(info)
	end

	function createBag(parent, containerID)
		local bag = E:CreateButton(parent, "LSBagSlot"..containerID, true)
		bag:SetID(ContainerIDToInventoryID(containerID))
		bag:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		bag:RegisterForDrag("LeftButton")
		bag:SetScript("OnClick", bag_OnClick)
		bag:SetScript("OnDragStart", bag_OnDragStart)
		bag:SetScript("OnEnter", bag_OnEnter)
		bag:SetScript("OnEvent", bag_OnEvent)
		bag:SetScript("OnLeave", bag_OnLeave)
		bag:SetScript("OnShow", bag_OnShow)
		bag:RegisterEvent("ITEM_LOCK_CHANGED")
		bag:RegisterEvent("CURSOR_UPDATE")
		bag:RegisterEvent("BAG_UPDATE")
		bag:RegisterEvent("BAG_SLOT_FLAGS_UPDATED")

		bag.Update = bag_Update
		bag.UpdateCursor = bag_UpdateCursor
		bag.UpdateFilterIcon = bag_UpdateFilterIcon
		bag.UpdateIcon = bag_UpdateIcon
		bag.UpdateLock = bag_UpdateLock

		bag.FilterDropDown = CreateFrame("Frame", "$parentFilterDropDown", bag, "UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(bag.FilterDropDown, dropDown_Initialize, "MENU")

		local filterIcon = bag.FGParent:CreateTexture(nil, "OVERLAY")
		filterIcon:SetAtlas("bags-icon-consumables")
		filterIcon:SetSize(20, 20)
		filterIcon:SetPoint("BOTTOMRIGHT", (28-20) / 2, -(28-20) / 2)
		bag.FilterIcon = filterIcon

		return bag
	end
end

-- Spellbook
local function spellbookButton_OnEvent(self, event)
	if event == "UPDATE_BINDINGS" then
		self.tooltipText = MicroButtonTooltipText(L["SPELLBOOK_ABILITIES_BUTTON"], "TOGGLESPELLBOOK")
	end
end

-- Quest
local function questLogButton_OnEnter(self)
	button_OnEnter(self)

	if self:IsEnabled() then
		GameTooltip:AddLine(L["DAILY_QUEST_RESET_TIME_TOOLTIP"]:format(SecondsToTime(GetQuestResetTime())))
		GameTooltip:Show()
	end
end

-- LFD
local lfdButton_OnEnter, lfdButton_UpdateIndicator, lfdButton_OnEvent

do
	local cta = {
		tank = {},
		healer = {},
		damager = {},
		total = 0
	}
	local roles = {"tank", "healer", "damager"}

	local function fetchCTAData(dungeonID, dungeonName, shortageRole, shortageIndex, numRewards)
		cta[shortageRole][dungeonID] = cta[shortageRole][dungeonID] or {}
		cta[shortageRole][dungeonID].name = dungeonName

		for rewardIndex = 1, numRewards do
			local name, texture, quantity = GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, rewardIndex)

			if not name or name == "" then
				name = L["UNKNOWN"]
				texture = texture or "Interface\\Icons\\INV_Misc_QuestionMark"
			end

			cta[shortageRole][dungeonID][rewardIndex] = {
				name = name,
				texture = "|T"..texture..":0|t",
				quantity = quantity or 1
			}

			cta.total = cta.total + 1
		end
	end

	local function updateCTARewards(dungeonID, dungeonName)
		if IsLFGDungeonJoinable(dungeonID) then
			for shortageIndex = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
				local eligible, forTank, forHealer, forDamager, numRewards = GetLFGRoleShortageRewards(dungeonID, shortageIndex)
				local _, tank, healer, damager = GetLFGRoles()

				if eligible and numRewards > 0 then
					if tank and forTank then
						fetchCTAData(dungeonID, dungeonName, "tank", shortageIndex, numRewards)
					end

					if healer and forHealer then
						fetchCTAData(dungeonID, dungeonName, "healer", shortageIndex, numRewards)
					end

					if damager and forDamager then
						fetchCTAData(dungeonID, dungeonName, "damager", shortageIndex, numRewards)
					end
				end
			end
		end
	end

	function lfdButton_OnEnter(self)
		button_OnEnter(self)

		if self:IsEnabled() then
			for _, role in next, roles do
				local hasTitle = false
				local r, g, b = M.COLORS.GRAY:GetRGB()

				for _, v in next, cta[role] do
					if v then
						if not hasTitle then
							GameTooltip:AddLine(" ")
							GameTooltip:AddLine(L["CALL_TO_ARMS_TOOLTIP"]:format(ROLE_NAMES[role]))

							hasTitle = true
						end

						GameTooltip:AddLine(v.name, 1, 1, 1)

						for i = 1, #v do
							GameTooltip:AddDoubleLine(v[i].name, v[i].quantity..v[i].texture, r, g, b, r, g, b)
						end
					end
				end
			end

			GameTooltip:Show()
		end
	end

	function lfdButton_UpdateIndicator(self)
		t_wipe(cta.tank)
		t_wipe(cta.healer)
		t_wipe(cta.damager)
		cta.total = 0

		if C.db.profile.bars.micromenu.buttons.lfd.tooltip then
			-- dungeons
			for i = 1, GetNumRandomDungeons() do
				updateCTARewards(GetLFGRandomDungeonInfo(i))
			end

			-- raids
			for i = 1, GetNumRFDungeons() do
				updateCTARewards(GetRFDungeonInfo(i))
			end
		end

		self.Flash:SetShown(cta.total > 0)

		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()

			lfdButton_OnEnter(self)
		end
	end

	function lfdButton_OnEvent(self, event)
		if event == "LFG_LOCK_INFO_RECEIVED" then
			local t = GetTime()

			if t - (self.recentUpdate or 0) >= 0.1 then
				C_Timer.After(0.1, function()
					self:UpdateIndicator()
				end)

				self.recentUpdate = t
			end
		end
	end
end

-- Collections
local function collectionsButton_OnEvent(self, event)
	if event == "UPDATE_BINDINGS" then
		self.tooltipText = MicroButtonTooltipText(L["COLLECTIONS"], "TOGGLECOLLECTIONS")
	end
end

-- EJ
local function ejButton_OnEnter(self)
	button_OnEnter(self)

	if self:IsEnabled() then
		RequestRaidInfo()

		local savedInstances = GetNumSavedInstances()
		local savedWorldBosses = GetNumSavedWorldBosses()

		if savedInstances + savedWorldBosses == 0 then return end

		local instanceName, instanceReset, difficultyName, numEncounters, encounterProgress
		local r, g, b = M.COLORS.GRAY:GetRGB()
		local hasTitle

		for i = 1, savedInstances + savedWorldBosses do
			if i <= savedInstances then
				instanceName, _, instanceReset, _, _, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)

				if instanceReset > 0 then
					if not hasTitle then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(L["RAID_INFO_COLON"])

						hasTitle = true
					end

					local color = encounterProgress == numEncounters and M.COLORS.RED or M.COLORS.GREEN

					GameTooltip:AddDoubleLine(instanceName, encounterProgress.." / "..numEncounters, 1, 1, 1, color:GetRGB())
					GameTooltip:AddDoubleLine(difficultyName, SecondsToTime(instanceReset, true, nil, 3), r, g, b, r, g, b)
				end
			else
				instanceName, _, instanceReset = GetSavedWorldBossInfo(i - savedInstances)

				if instanceReset > 0 then
					if not hasTitle then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(L["RAID_INFO_COLON"])

						hasTitle = true
					end

					GameTooltip:AddDoubleLine(instanceName, "1 / 1", 1, 1, 1, M.COLORS.RED:GetRGB())
					GameTooltip:AddDoubleLine(L["WORLD_BOSS"], SecondsToTime(instanceReset, true, nil, 3), r, g, b, r, g, b)
				end
			end
		end

		GameTooltip:Show()
	end
end

local function ejButton_OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" then
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()

			ejButton_OnEnter(self)
		end
	end
end

-- Main
local mainMenuButton_OnEnter, mainMenuButton_OnEvent, mainMenuButton_UpdateIndicator

do
	local addOns = {}
	local memUsage, latencyHome, latencyWorld = 0, 0, 0
	local _

	function mainMenuButton_UpdateIndicator(self)
		_, _, latencyHome, latencyWorld = GetNetStats()

		self.Indicators[1]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyHome / PERFORMANCEBAR_MEDIUM_LATENCY))
		self.Indicators[2]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyWorld / PERFORMANCEBAR_MEDIUM_LATENCY))
	end

	function mainMenuButton_OnEnter(self)
		button_OnEnter(self)

		if self:IsEnabled() then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["LATENCY_COLON"])
			GameTooltip:AddDoubleLine(L["LATENCY_HOME"], LATENCY_TEMPLATE:format(M.COLORS.GYR:GetHEX(latencyHome / PERFORMANCEBAR_MEDIUM_LATENCY), latencyHome), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["LATENCY_WORLD"], LATENCY_TEMPLATE:format(M.COLORS.GYR:GetHEX(latencyWorld / PERFORMANCEBAR_MEDIUM_LATENCY), latencyWorld), 1, 1, 1)

			if IsShiftKeyDown() then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["MEMORY_COLON"])

				t_wipe(addOns)
				memUsage = 0

				UpdateAddOnMemoryUsage()

				for i = 1, GetNumAddOns() do
					addOns[i] = {
						[1] = select(2, GetAddOnInfo(i)),
						[2] = GetAddOnMemoryUsage(i),
						[3] = IsAddOnLoaded(i),
					}

					memUsage = memUsage + addOns[i][2]
				end

				t_sort(addOns, simpleSort)

				for i = 1, #addOns do
					if addOns[i][3] then
						local m = addOns[i][2]

						GameTooltip:AddDoubleLine(addOns[i][1], MEMORY_TEMPLATE:format(m / 1024),
							1, 1, 1, M.COLORS.GYR:GetRGB(m / (memUsage == m and 1 or (memUsage - m))))
					end
				end

				GameTooltip:AddDoubleLine(L["TOTAL"], MEMORY_TEMPLATE:format(memUsage / 1024))
			else
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["MAINMENU_BUTTON_HOLD_TOOLTIP"])
			end

			GameTooltip:Show()
		end
	end

	function mainMenuButton_OnEvent(self, event)
		if event == "MODIFIER_STATE_CHANGED" then
			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide()

				mainMenuButton_OnEnter(self)
			end
		elseif event == "UPDATE_BINDINGS" then
			self.tooltipText = MicroButtonTooltipText(L["MAINMENU_BUTTON"], "TOGGLEGAMEMENU")
		end
	end
end

local function buttonSort(a, b)
	return a:GetID() < b:GetID()
end
local function bar_Update(self)
	self:UpdateConfig()
	self:UpdateButtonList()
	self:UpdateButtons("Update")
	self:UpdateFading()
	E:UpdateBarLayout(self)
	self:UpdateButtons("UpdateIndicators")
end

local function bar_UpdateConfig(self)
	self._config = C.db.profile.bars.micromenu
end

local function bar_UpdateButtonList(self)
	t_wipe(self._buttons)

	for name in next, BUTTONS do
		if _G[name]:ShouldShow() then
			t_insert(self._buttons, _G[name])
		else
			_G[name]:SetParent(E.HIDDEN_PARENT)
		end
	end

	t_sort(self._buttons, buttonSort)
end

local function updateMicroButtonsParent()
	if isInit then
		for name in next, BUTTONS do
			if _G[name]:ShouldShow() then
				_G[name]:SetParent(_G[name]._parent)
			else
				_G[name]:SetParent(E.HIDDEN_PARENT)
			end
		end
	end
end

local function moveMicroButtons()
	if isInit then
		bar:UpdateButtonList()
		E:UpdateBarLayout(bar)
	end
end

local function updateMicroButtons()
	if isInit then
		for _, button in next, bar._buttons do
			button:Show()
		end
	end
end

local function positionAlerts()
	-- MainMenuMicroButton_PositionAlert hook
end

function MODULE.CreateMicroMenu()
	if not isInit then
		bar = CreateFrame("Frame", "LSMicroMenu", UIParent)
		bar:SetFrameLevel(MicroButtonAndBagsBar:GetFrameLevel() + 2)
		bar._id = "micromenu"
		bar._buttons = {}

		MODULE:AddBar(bar._id, bar)

		bar.Update = bar_Update
		bar.UpdateButtonList = bar_UpdateButtonList
		bar.UpdateConfig = bar_UpdateConfig

		for name, data in next, BUTTONS do
			local button = _G[name] or createMicroButton(name)
			button:SetID(data.id)
			button:RegisterEvent("UPDATE_BINDINGS")
			button._parent = bar
			t_insert(bar._buttons, button)

			handleMicroButton(button)

			button.Icon:SetTexCoord(unpack(TEXTURE_COORDS[data.icon]))

			if name == "CharacterMicroButton" then
				E:ForceHide(MicroButtonPortrait)
				createButtonIndicator(button, {}, 1)

				button:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
				button:SetScript("OnEvent", characterButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["CHARACTER_INFO_BUTTON"], "TOGGLECHARACTER0")

				button.Update = function(self)
					if C.db.profile.bars.micromenu.buttons.character.tooltip then
						self:SetScript("OnEnter", characterButton_OnEnter)
					else
						self:SetScript("OnEnter", button_OnEnter)
					end

					self:UpdateIndicator()
				end
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.character.enabled
				end
				button.UpdateIndicator = characterButton_UpdateIndicator
			elseif name == "LSInventoryMicroButton" then
				createButtonIndicator(button, {}, 1)

				button:RegisterEvent("BAG_UPDATE")
				button:SetScript("OnClick", inventoryButton_OnClick)
				button:SetScript("OnEvent", inventoryButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["INVENTORY_BUTTON"], "OPENALLBAGS")

				button.Update = function(self)
					if C.db.profile.bars.micromenu.buttons.inventory.tooltip then
						self:SetScript("OnEnter", inventoryButton_OnEnter)
					else
						self:SetScript("OnEnter", button_OnEnter)
					end

					self:UpdateIndicator()
				end
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.inventory.enabled
				end
				button.UpdateIndicator = inventoryButton_UpdateIndicator

				-- local bags = CreateFrame("Frame", "$parentBagBar", button)
				-- bags:SetSize(30, 30)
				-- bags:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, 4)
				-- bags:Hide()
				-- bags._buttons = {}
				-- button.Bags = bags

				-- for i = 1, 4 do
				-- 	local bag = createBag(bags, i)
				-- 	t_insert(bags._buttons, bag)

				-- 	if i == 1 then
				-- 		bag:SetPoint("TOPLEFT", 0, -2)
				-- 	else
				-- 		bag:SetPoint("LEFT", bags._buttons[i - 1], "RIGHT", 4, 0)
				-- 	end
				-- end
			elseif name == "SpellbookMicroButton" then
				button:SetScript("OnEnter", button_OnEnter)
				button:SetScript("OnEvent", spellbookButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["SPELLBOOK_ABILITIES_BUTTON"], "TOGGLESPELLBOOK")
				button.newbieText = L["NEWBIE_TOOLTIP_SPELLBOOK"]

				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.spellbook.enabled
				end
			elseif name == "TalentMicroButton" then
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.talent.enabled
				end
			elseif name == "AchievementMicroButton" then
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.achievement.enabled
				end
			elseif name == "QuestLogMicroButton" then
				button.Update = function(self)
					if C.db.profile.bars.micromenu.buttons.quest.tooltip then
						self:SetScript("OnEnter", questLogButton_OnEnter)
					else
						self:SetScript("OnEnter", button_OnEnter)
					end
				end
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.quest.enabled
				end
			elseif name == "GuildMicroButton" then
				button.Tabard = GuildMicroButtonTabard

				button.Tabard.background:SetParent(button)
				button.Tabard.background:ClearAllPoints()
				button.Tabard.background:SetPoint("TOPLEFT", 1, -1)
				button.Tabard.background:SetPoint("BOTTOMRIGHT", -1, 1)
				button.Tabard.background:SetDrawLayer("BACKGROUND", 2)
				button.Tabard.background:SetTexture("Interface\\GUILDFRAME\\GuildDifficulty")
				button.Tabard.background:SetTexCoord(6 / 128, 38 / 128, 6 / 64, 50 / 64)

				button.Tabard.emblem:SetParent(button)
				button.Tabard.emblem:SetDrawLayer("BACKGROUND", 3)
				button.Tabard.emblem:SetPoint("CENTER", 0, 0)

				hooksecurefunc("GuildMicroButton_UpdateTabard", function()
					if button.Tabard:IsShown() then
						button.Tabard.background:Show()
						button.Tabard.emblem:Show()
						button.Icon:Hide()
					else
						button.Tabard.background:Hide()
						button.Tabard.emblem:Hide()
						button.Icon:Show()
					end

					updateNormalTexture(button)
					updatePushedTexture(button)
					updateDisabledTexture(button)
				end)

				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.guild.enabled
				end
			elseif name == "LFDMicroButton" then
				button:HookScript("OnEvent", lfdButton_OnEvent)

				button.Update = function(self)
					if C.db.profile.bars.micromenu.buttons.lfd.tooltip then
						self:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
						self:SetScript("OnEnter", lfdButton_OnEnter)

						self.ctaTicker = C_Timer.NewTicker(10, function()
							RequestLFDPlayerLockInfo()
							RequestLFDPartyLockInfo()
						end)
					else
						self:UnregisterEvent("LFG_LOCK_INFO_RECEIVED")
						self:SetScript("OnEnter", button_OnEnter)

						if self.ctaTicker then
							self.ctaTicker:Cancel()
							self.ctaTicker = nil
						end
					end

					self:UpdateIndicator()
				end
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.lfd.enabled
				end
				button.UpdateIndicator = lfdButton_UpdateIndicator
			elseif name == "CollectionsMicroButton" then
				button:HookScript("OnEvent", collectionsButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["COLLECTIONS"], "TOGGLECOLLECTIONS")

				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.collection.enabled
				end
			elseif name == "EJMicroButton" then
				button:HookScript("OnEvent", ejButton_OnEvent)

				button.NewAdventureNotice:ClearAllPoints()
				button.NewAdventureNotice:SetPoint("CENTER")

				button.Update = function(self)
					if C.db.profile.bars.micromenu.buttons.ej.tooltip then
						self:RegisterEvent("UPDATE_INSTANCE_INFO")
						self:SetScript("OnEnter", ejButton_OnEnter)
					else
						self:UnregisterEvent("UPDATE_INSTANCE_INFO")
						self:SetScript("OnEnter", button_OnEnter)
					end
				end
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.ej.enabled
				end
			elseif name == "StoreMicroButton" then
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.store.enabled
				end
			elseif name == "MainMenuMicroButton" then
				E:ForceHide(MainMenuBarDownload)
				createButtonIndicator(button, {MainMenuBarPerformanceBar}, 2)

				button:SetScript("OnEvent", mainMenuButton_OnEvent)

				button.Update = function(self)
					if C.db.profile.bars.micromenu.buttons.main.tooltip then
						self:RegisterEvent("MODIFIER_STATE_CHANGED")
						self:SetScript("OnEnter", mainMenuButton_OnEnter)
					else
						self:UnregisterEvent("MODIFIER_STATE_CHANGED")
						button:SetScript("OnEnter", button_OnEnter)
					end

					self:UpdateIndicator()
				end
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.main.enabled
				end
				button.UpdateIndicator = mainMenuButton_UpdateIndicator

				C_Timer.NewTicker(30, function()
					MainMenuMicroButton:UpdateIndicator()
				end)
			elseif name == "HelpMicroButton" then
				button.ShouldShow = function()
					return C.db.profile.bars.micromenu.buttons.help.enabled
				end
			end
		end

		TalentMicroButtonAlert:SetPoint("BOTTOM", "TalentMicroButton", "TOP", 0, 12)
		LFDMicroButtonAlert:SetPoint("BOTTOM", "LFDMicroButton", "TOP", 0, 12)
		EJMicroButtonAlert:SetPoint("BOTTOM", "EJMicroButton", "TOP", 0, 12)
		CollectionsMicroButtonAlert:SetPoint("BOTTOM", "CollectionsMicroButton", "TOP", 0, 12)

		hooksecurefunc("UpdateMicroButtonsParent", updateMicroButtonsParent)
		hooksecurefunc("MoveMicroButtons", moveMicroButtons)
		hooksecurefunc("UpdateMicroButtons", updateMicroButtons)
		hooksecurefunc("MainMenuMicroButton_PositionAlert", positionAlerts)

		local point = C.db.profile.bars.micromenu.point
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		bar:Update()

		isInit = true
	end
end
