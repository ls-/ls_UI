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
	BACKPACK_CONTAINER BAG_FILTER_ASSIGN_TO BAG_FILTER_CLEANUP BAG_FILTER_ICONS BAG_FILTER_ICONS BAG_FILTER_IGNORE
	BAG_FILTER_LABELS EQUIP_CONTAINER LE_BAG_FILTER_FLAG_EQUIPMENT LE_BAG_FILTER_FLAG_IGNORE_CLEANUP
	LE_BAG_FILTER_FLAG_JUNK LFG_ROLE_NUM_SHORTAGE_TYPES NEWBIE_TOOLTIP_SPELLBOOK NUM_BAG_SLOTS NUM_LE_BAG_FILTER_FLAGS
	PERFORMANCEBAR_MEDIUM_LATENCY SHOW_NEWBIE_TIPS

	AchievementMicroButton BreakUpLargeNumbers CharacterMicroButton CollectionsMicroButton ContainerIDToInventoryID
	CreateFrame CursorCanGoInSlot CursorHasItem EJMicroButton GameTooltip GetAddOnInfo GetAddOnMemoryUsage
	GetBagSlotFlag GetContainerNumFreeSlots GetContainerNumSlots GetCurrencyInfo GetInventoryItemDurability
	GetInventoryItemTexture GetLFGDungeonShortageRewardInfo GetLFGRandomDungeonInfo GetLFGRoles
	GetLFGRoleShortageRewards GetMoney GetMoneyString GetNetStats GetNumAddOns GetNumRandomDungeons GetNumRFDungeons
	GetNumSavedInstances GetNumSavedWorldBosses GetQuestResetTime GetRFDungeonInfo GetSavedInstanceInfo
	GetSavedWorldBossInfo GetTime GuildMicroButton GuildMicroButtonTabard HelpMicroButton InCombatLockdown
	IsAddOnLoaded IsInventoryItemLocked IsInventoryItemProfessionBag IsLFGDungeonJoinable IsShiftKeyDown LFDMicroButton
	LSBagBar LSInventoryMicroButton MainMenuBarDownload MainMenuBarPerformanceBar MainMenuMicroButton
	MicroButtonAndBagsBar MicroButtonPortrait MicroButtonTooltipText PickupBagFromSlot PlaySound PutItemInBag
	QuestLogMicroButton RequestLFDPartyLockInfo RequestLFDPlayerLockInfo RequestRaidInfo SecondsToTime SetBagSlotFlag
	SetClampedTextureRotation SpellbookMicroButton StoreMicroButton TalentMicroButton ToggleAllBags ToggleDropDownMenu
	UIDropDownMenu_AddButton UIDropDownMenu_CreateInfo UIDropDownMenu_Initialize UIParent UpdateAddOnMemoryUsage LibStub
]]

-- Mine
local LibDropDown = LibStub("LibDropDown")
local isInit = false

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
		events = {
			AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED = true,
			AZERITE_ITEM_POWER_LEVEL_CHANGED = true,
			NEUTRAL_FACTION_SELECT_RESULT = true,
			PLAYER_ENTERING_WORLD = true,
			UPDATE_BINDINGS = true,
			UPDATE_INVENTORY_DURABILITY = true,
		},
	},
	LSInventoryMicroButton = {
		id =  2,
		icon = "Inventory",
		events = {
			BAG_UPDATE_DELAYED = true,
			UPDATE_BINDINGS = true,
		},
	},
	SpellbookMicroButton = {
		id =  3,
		icon = "Spellbook",
		events = {
			NEUTRAL_FACTION_SELECT_RESULT = true,
			UPDATE_BINDINGS = true,
		},
	},
	TalentMicroButton = {
		id =  4,
		icon = "Talent",
		events = {
			HONOR_LEVEL_UPDATE = true,
			NEUTRAL_FACTION_SELECT_RESULT = true,
			PLAYER_LEVEL_UP = true,
			PLAYER_PVP_TALENT_UPDATE = true,
			PLAYER_SPECIALIZATION_CHANGED = true,
			PLAYER_TALENT_UPDATE = true,
			UPDATE_BINDINGS = true,
		},
	},
	AchievementMicroButton = {
		id =  5,
		icon = "Achievement",
		events = {
			ACHIEVEMENT_EARNED = true,
			NEUTRAL_FACTION_SELECT_RESULT = true,
			RECEIVED_ACHIEVEMENT_LIST = true,
			UPDATE_BINDINGS = true,
		},
	},
	QuestLogMicroButton = {
		id =  6,
		icon = "Quest",
		events = {
			NEUTRAL_FACTION_SELECT_RESULT = true,
			UPDATE_BINDINGS = true,
		},
	},
	GuildMicroButton = {
		id =  7,
		icon = "Guild",
		events = {
			NEUTRAL_FACTION_SELECT_RESULT = true,
			PLAYER_GUILD_UPDATE = true,
			UPDATE_BINDINGS = true,
		},
	},
	LFDMicroButton = {
		id =  8,
		icon = "LFD",
		events = {
			LFG_LOCK_INFO_RECEIVED = true,
			NEUTRAL_FACTION_SELECT_RESULT = true,
			UPDATE_BINDINGS = true,
		},
	},
	CollectionsMicroButton = {
		id =  9,
		icon = "Collection",
		events = {
			COMPANION_LEARNED = true,
			HEIRLOOMS_UPDATED = true,
			NEUTRAL_FACTION_SELECT_RESULT = true,
			PET_JOURNAL_LIST_UPDATE = true,
			PET_JOURNAL_NEW_BATTLE_SLOT = true,
			PLAYER_ENTERING_WORLD = true,
			TOYS_UPDATED = true,
			UPDATE_BINDINGS = true,
		},
	},
	EJMicroButton = {
		id = 10,
		icon = "EJ",
		events = {
			NEUTRAL_FACTION_SELECT_RESULT = true,
			PLAYER_ENTERING_WORLD = true,
			UPDATE_BINDINGS = true,
			UPDATE_INSTANCE_INFO = true,
			VARIABLES_LOADED = true,
			ZONE_CHANGED_NEW_AREA = true,
		},
	},
	StoreMicroButton = {
		id = 11,
		icon = "Store",
		events = {
			NEUTRAL_FACTION_SELECT_RESULT = true,
			UPDATE_BINDINGS = true,
		},
	},
	MainMenuMicroButton = {
		id = 12,
		icon = "MainMenu",
		events = {
			MODIFIER_STATE_CHANGED = true,
			NEUTRAL_FACTION_SELECT_RESULT = true,
			UPDATE_BINDINGS = true,
		},
	},
	HelpMicroButton = {
		id = 13,
		icon = "Help",
		events = {
			NEUTRAL_FACTION_SELECT_RESULT = true,
			UPDATE_BINDINGS = true,
		},
	},
}

local ALERTS = {
	"TalentMicroButtonAlert",
	"CollectionsMicroButtonAlert",
	"LFDMicroButtonAlert",
	"EJMicroButtonAlert",
	"StoreMicroButtonAlert",
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

local function button_ResizeIndicators(self)
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

local function createButtonIndicators(button, indicators, num)
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
	button.ResizeIndicators = button_ResizeIndicators
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
	local p, rP, x, y = getTooltipPoint(self._parent)

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

local function button_ShouldShow(self)
	return self._config.enabled
end

local function button_GetAnchor(self)
	return MODULE:GetBar(self._config.parent) or MODULE:GetBar("micromenu1")
end

local function button_UpdateConfig(self)
	self._config = C.db.profile.bars.micromenu.buttons[self._id]
end

local function button_UpdateEvents(self)
	if self._config.enabled then
		for event in next, BUTTONS[self:GetName()].events do
			self:RegisterEvent(event)
		end
	else
		self:UnregisterAllEvents()
	end
end

local function handleMicroButton(button)
	button:SetHitRectInsets(0, 0, 0, 0)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:UnregisterAllEvents()

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

	button.GetAnchor = button_GetAnchor
	button.ShouldShow = button_ShouldShow
	button.UpdateConfig = button_UpdateConfig
	button.UpdateEvents = button_UpdateEvents
end

local function createMicroButton(name)
	return CreateFrame("Button", name, UIParent, "MainMenuBarMicroButton")
end

-- Character
local characterButton_OnEvent, characterButton_Update, characterButton_UpdateIndicators

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

	local function characterButton_OnEnter(self)
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
					self:UpdateIndicators()
				end)

				self.recentUpdate = t
			end
		elseif event == "UPDATE_BINDINGS" then
			self.tooltipText = MicroButtonTooltipText(L["CHARACTER_BUTTON"], "TOGGLECHARACTER0")
		end
	end

	function characterButton_Update(self)
		if self._config.tooltip then
			self:SetScript("OnEnter", characterButton_OnEnter)
		else
			self:SetScript("OnEnter", button_OnEnter)
		end

		self:UpdateIndicators()
	end

	function characterButton_UpdateIndicators(self)
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
end

-- Inventory
local inventoryButton_OnClick, inventoryButton_OnEvent, inventoryButton_Update, inventoryButton_UpdateIndicators

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

	local function inventoryButton_OnEnter(self)
		button_OnEnter(self)

		if self:IsEnabled() then
			GameTooltip:AddLine(L["FREE_BAG_SLOTS_TOOLTIP"]:format(freeSlots))
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["CURRENCY_COLON"])

			for id in next, self._config.currency do
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

			if C.db.profile.bars.micromenu.bars.bags.enabled then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["INVENTORY_BUTTON_RCLICK_TOOLTIP"])
			end

			GameTooltip:Show()
		end
	end

	function inventoryButton_OnClick(_, button)
		if button == "RightButton" then
			if C.db.profile.bars.micromenu.bars.bags.enabled then
				if not InCombatLockdown() then
					if LSBagBar:IsShown() then
						LSBagBar:Hide()
					else
						LSBagBar:Show()
					end
				end
			else
				ToggleAllBags()
			end
		else
			ToggleAllBags()
		end
	end

	function inventoryButton_OnEvent(self, event)
		if event == "BAG_UPDATE_DELAYED" then
			self:UpdateIndicators()
		elseif event == "UPDATE_BINDINGS" then
			self.tooltipText = MicroButtonTooltipText(L["INVENTORY_BUTTON"], "OPENALLBAGS")
		end
	end

	function inventoryButton_Update(self)
		if self._config.tooltip then
			self:SetScript("OnEnter", inventoryButton_OnEnter)
		else
			self:SetScript("OnEnter", button_OnEnter)
		end

		self:UpdateIndicators()
	end

	function inventoryButton_UpdateIndicators(self)
		updateBagUsageInfo()

		self.Indicators[1]:SetVertexColor(M.COLORS.RYG:GetRGB(freeSlots / totalSlots))
	end
end

-- Bags
local bagBar_OnEvent, bagBar_OnShow, bagBar_Update, bagBar_UpdateEvents, createBag

do
	local invIDOffset = ContainerIDToInventoryID(1) - 1

	local function generateMenuLinesForBag(bag)
		local invID = bag:GetID()
		local containerID = invID - invIDOffset
		local lines = {}

		if not IsInventoryItemProfessionBag("player", invID) then
			lines[1] = {
				text = BAG_FILTER_ASSIGN_TO,
				isTitle = true,
			}

			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				if i ~= LE_BAG_FILTER_FLAG_JUNK then
					t_insert(lines, {
						text = BAG_FILTER_LABELS[i],
						isRadio = true,
						func = function(self)
							local value = not self:GetRadioState()

							SetBagSlotFlag(containerID, i, value)

							if value then
								bag.FilterIcon:SetAtlas(BAG_FILTER_ICONS[i])
								bag.FilterIcon:Show()
							else
								bag.FilterIcon:Hide()
							end
						end,
						checked = function()
							return GetBagSlotFlag(containerID, i)
						end,
					})
				end
			end
		end

		t_insert(lines, {
			text = BAG_FILTER_CLEANUP,
			isTitle = true,
		})

		t_insert(lines, {
			text = BAG_FILTER_IGNORE,
			func = function(self)
				SetBagSlotFlag(containerID, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not self:GetCheckedState())
			end,
			checked = function()
				return GetBagSlotFlag(containerID, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP)
			end,
		})

		return unpack(lines)
	end

	local function bag_OnClick(self, button)
		if button == "RightButton" then
			GameTooltip:Hide()
			LibDropDown:CloseAll()

			local p, rP, x, y = getTooltipPoint(LSBagBar)

			LSBagBar.FilterMenu:SetAnchor(p, self, rP, x * 5, y * 5)
			LSBagBar.FilterMenu:ClearLines()
			LSBagBar.FilterMenu:AddLines(generateMenuLinesForBag(self))
			LSBagBar.FilterMenu:Toggle()

			PlaySound(856) -- IG_MAINMENU_OPTION_CHECKBOX_ON
		else
			if not InCombatLockdown() then
				if CursorHasItem() then
					PutItemInBag(self:GetID())
				else
					PickupBagFromSlot(self:GetID())
				end
			end
		end
	end

	local function bag_OnDragStart(self)
		if not InCombatLockdown() then
			PickupBagFromSlot(self:GetID())
		end
	end

	local function bag_OnEnter(self)
		local p, rP, x, y = getTooltipPoint(LSBagBar)

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, x, y)

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
		self.FilterIcon:Hide()

		if not IsInventoryItemProfessionBag("player", self:GetID()) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				if GetBagSlotFlag(self:GetID() - invIDOffset, i) then
					self.FilterIcon:SetAtlas(BAG_FILTER_ICONS[i])
					self.FilterIcon:Show()

					break
				end
			end
		end
	end

	local function bag_UpdateIcon(self)
		self.Icon:SetTexture(GetInventoryItemTexture("player", self:GetID()))
	end

	local function bag_UpdateLock(self)
		self.Icon:SetDesaturated(IsInventoryItemLocked(self:GetID()))
	end

	local function bag_Update(self)
		self:UpdateCursor()
		self:UpdateFilterIcon()
		self:UpdateIcon()
		self:UpdateLock()
	end

	function createBag(parent, containerID)
		local bag = E:CreateButton(parent, "$parentBag"..containerID, true)
		bag:SetID(ContainerIDToInventoryID(containerID))
		bag:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		bag:RegisterForDrag("LeftButton")
		bag:SetScript("OnClick", bag_OnClick)
		bag:SetScript("OnDragStart", bag_OnDragStart)
		bag:SetScript("OnEnter", bag_OnEnter)
		bag:SetScript("OnLeave", bag_OnLeave)

		bag.Update = bag_Update
		bag.UpdateCursor = bag_UpdateCursor
		bag.UpdateFilterIcon = bag_UpdateFilterIcon
		bag.UpdateIcon = bag_UpdateIcon
		bag.UpdateLock = bag_UpdateLock

		local filterIcon = bag.FGParent:CreateTexture(nil, "OVERLAY")
		filterIcon:SetAtlas("bags-icon-consumables")
		filterIcon:SetSize(20, 20)
		filterIcon:SetPoint("BOTTOMRIGHT", 4, -4)
		bag.FilterIcon = filterIcon

		return bag
	end

	function bagBar_OnEvent(self, event, ...)
		if self:IsShown() then
			if event == "ITEM_LOCK_CHANGED" then
				local bagID, slotID = ...

				if bagID and not slotID then
					bagID = bagID - invIDOffset
				end

				if bagID >= 1 and bagID <= 4 then
					self._buttons[bagID]:UpdateLock()
				end
			elseif event == "CURSOR_UPDATE" then
				for _, button in next, self._buttons do
					button:UpdateCursor()
				end
			elseif event == "BAG_UPDATE_DELAYED" then
				for _, button in next, self._buttons do
					button:Update()
				end
			elseif event == "BAG_SLOT_FLAGS_UPDATED" then
				local bagID = ...

				if bagID >= 1 and bagID <= 4 then
					self._buttons[bagID]:Update()
				end
			elseif event == "PLAYER_REGEN_DISABLED" then
				self:Hide()
				LibDropDown:CloseAll()
			end
		end
	end

	function bagBar_OnShow(self)
		for _, button in next, self._buttons do
			button:Update()
		end
	end

	function bagBar_Update(self)
		self:UpdateConfig()
		self:UpdateEvents()
		E:UpdateBarLayout(self)

		if not (self._config.enabled and C.db.profile.bars.micromenu.buttons.inventory.enabled) then
			self:Hide()
		end
	end

	function bagBar_UpdateEvents(self)
		if self._config.enabled then
			self:RegisterEvent("BAG_SLOT_FLAGS_UPDATED")
			self:RegisterEvent("BAG_UPDATE_DELAYED")
			self:RegisterEvent("CURSOR_UPDATE")
			self:RegisterEvent("ITEM_LOCK_CHANGED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
		else
			self:UnregisterAllEvents()
		end
	end
end

-- Spellbook
local function spellbookButton_OnEvent(self, event)
	if event == "UPDATE_BINDINGS" then
		self.tooltipText = MicroButtonTooltipText(L["SPELLBOOK_ABILITIES_BUTTON"], "TOGGLESPELLBOOK")
	end
end

-- Quest
local questLogButton_Update

do
	local function questLogButton_OnEnter(self)
		button_OnEnter(self)

		if self:IsEnabled() then
			GameTooltip:AddLine(L["DAILY_QUEST_RESET_TIME_TOOLTIP"]:format(SecondsToTime(GetQuestResetTime())))
			GameTooltip:Show()
		end
	end

	function questLogButton_Update(self)
		if self._config.tooltip then
			self:SetScript("OnEnter", questLogButton_OnEnter)
		else
			self:SetScript("OnEnter", button_OnEnter)
		end
	end
end

-- Guild
local function guildButton_Update(self)
	if self.Tabard:IsShown() then
		self.Tabard.background:Show()
		self.Tabard.emblem:Show()
		self.Icon:Hide()
	else
		self.Tabard.background:Hide()
		self.Tabard.emblem:Hide()
		self.Icon:Show()
	end

	updateNormalTexture(self)
	updatePushedTexture(self)
	updateDisabledTexture(self)
end

-- LFD
local lfdButton_OnEvent, lfdButton_Update, lfdButton_UpdateIndicators

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

	local function lfdButton_OnEnter(self)
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

	function lfdButton_OnEvent(self, event)
		if event == "LFG_LOCK_INFO_RECEIVED" then
			self:UpdateIndicators()
		end
	end

	function lfdButton_Update(self)
		if self._config.enabled and self._config.tooltip then
			self:SetScript("OnEnter", lfdButton_OnEnter)

			self.Ticker = C_Timer.NewTicker(10, function()
				RequestLFDPlayerLockInfo()
				RequestLFDPartyLockInfo()
			end)
		else
			self:SetScript("OnEnter", button_OnEnter)

			if self.Ticker then
				self.Ticker:Cancel()
				self.Ticker = nil
			end
		end

		self:UpdateIndicators()
	end

	function lfdButton_UpdateIndicators(self)
		t_wipe(cta.tank)
		t_wipe(cta.healer)
		t_wipe(cta.damager)
		cta.total = 0

		if self._config.tooltip then
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
end

-- Collections
local function collectionsButton_OnEvent(self, event)
	if event == "UPDATE_BINDINGS" then
		self.tooltipText = MicroButtonTooltipText(L["COLLECTIONS"], "TOGGLECOLLECTIONS")
	end
end

-- EJ
local ejButton_OnEvent, ejButton_Update

do
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

	function ejButton_OnEvent(self, event)
		if event == "UPDATE_INSTANCE_INFO" then
			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide()

				ejButton_OnEnter(self)
			end
		end
	end

	function ejButton_Update(self)
		if self._config.tooltip then
			self:SetScript("OnEnter", ejButton_OnEnter)
		else
			self:SetScript("OnEnter", button_OnEnter)
		end
	end
end

-- Main
local mainMenuButton_OnEvent, mainMenuButton_Update, mainMenuButton_UpdateIndicators

do
	local addOns = {}
	local memUsage, latencyHome, latencyWorld = 0, 0, 0
	local _

	local function sortFunc(a, b)
		return a[2] > b[2]
	end

	local function mainMenuButton_OnEnter(self)
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

				t_sort(addOns, sortFunc)

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

	function mainMenuButton_Update(self)
		if self._config.enabled and self._config.tooltip then
			self:SetScript("OnEnter", mainMenuButton_OnEnter)

			self.Ticker = C_Timer.NewTicker(30, function()
				MainMenuMicroButton:UpdateIndicators()
			end)
		else
			self:SetScript("OnEnter", button_OnEnter)

			if self.Ticker then
				self.Ticker:Cancel()
				self.Ticker = nil
			end
		end

		self:UpdateIndicators()
	end

	function mainMenuButton_UpdateIndicators(self)
		_, _, latencyHome, latencyWorld = GetNetStats()

		self.Indicators[1]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyHome / PERFORMANCEBAR_MEDIUM_LATENCY))
		self.Indicators[2]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyWorld / PERFORMANCEBAR_MEDIUM_LATENCY))
	end
end

local function buttonSort(a, b)
	return a:GetID() < b:GetID()
end

local function bar_Update(self)
	self:UpdateConfig()
	self:UpdateButtonList()
	self:UpdateButtons("Update")
	self:UpdateButtons("UpdateEvents")
	self:UpdateFading()
	self:UpdateButtonVisibility()
	E:UpdateBarLayout(self)
	self:UpdateButtons("ResizeIndicators")

	if self.BagBar then
		self.BagBar:Update()
	end
end

local function bar_UpdateConfig(self)
	self._config = C.db.profile.bars.micromenu.bars[self._id]
	self._config.fade = C.db.profile.bars.micromenu.fade
	self._config.visible = C.db.profile.bars.micromenu.visible
end

local function bar_UpdateButtonList(self)
	t_wipe(self._buttons)

	for name in next, BUTTONS do
		local button = _G[name]
		if button:ShouldShow() and button:GetAnchor() == self then
			button._parent = self
			t_insert(self._buttons, button)
		end
	end

	t_sort(self._buttons, buttonSort)
end

local function bar_UpdateButtonVisibility(self)
	for _, button in next, self._buttons do
		button:SetShown(button:ShouldShow())

		if not button:ShouldShow() then
			button:SetParent(E.HIDDEN_PARENT)
		end
	end
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
		local bar = MODULE:GetBar("micromenu1")
		bar:UpdateButtonList()
		bar:UpdateButtonVisibility()
		E:UpdateBarLayout(bar)

		bar = MODULE:GetBar("micromenu2")
		bar:UpdateButtonList()
		bar:UpdateButtonVisibility()
		E:UpdateBarLayout(bar)
	end
end

local function updateMicroButtons()
	if isInit then
		for _, button in next, MODULE:GetBar("micromenu1")._buttons do
			if button:ShouldShow() then
				button:Show()
			end
		end

		for _, button in next, MODULE:GetBar("micromenu2")._buttons do
			if button:ShouldShow() then
				button:Show()
			end
		end
	end
end

local function repositionAlert(alert)
	local quadrant = E:GetScreenQuadrant(alert.MicroButton)
	local isTopQuadrant = quadrant == "TOPLEFT" or quadrant == "TOP" or quadrant == "TOPRIGHT"

	alert:SetParent(alert.MicroButton)
	alert:ClearAllPoints()
	alert.Arrow:ClearAllPoints()
	alert.Arrow.Glow:ClearAllPoints()

	if isTopQuadrant then
		alert:SetPoint("TOP", alert.MicroButton, "BOTTOM", 0, -20)
		alert.Arrow:SetPoint("BOTTOM", alert, "TOP", 0, -4)
		alert.Arrow.Glow:SetPoint("BOTTOM")
	else
		alert:SetPoint("BOTTOM", alert.MicroButton, "TOP", 0, 20)
		alert.Arrow:SetPoint("TOP", alert, "BOTTOM", 0, 4)
		alert.Arrow.Glow:SetPoint("TOP")
	end

	SetClampedTextureRotation(alert.Arrow.Arrow, isTopQuadrant and 180 or 0)
	SetClampedTextureRotation(alert.Arrow.Glow, isTopQuadrant and 180 or 0)

	if alert:GetRight() and (alert:GetRight() + alert:GetWidth() / 4) > UIParent:GetRight() then
		alert:ClearAllPoints()
		alert.Arrow:ClearAllPoints()
		alert.Arrow.Glow:ClearAllPoints()

		if isTopQuadrant then
			alert:SetPoint("TOPRIGHT", alert.MicroButton, "BOTTOMRIGHT", 20, -20)
			alert.Arrow:SetPoint("BOTTOMRIGHT", alert, "TOPRIGHT", -4, -4)
			alert.Arrow.Glow:SetPoint("BOTTOM")
		else
			alert:SetPoint("BOTTOMRIGHT", alert.MicroButton, "TOPRIGHT", 20, 20)
			alert.Arrow:SetPoint("TOPRIGHT", alert, "BOTTOMRIGHT", -4, 4)
			alert.Arrow.Glow:SetPoint("TOP")
		end
	elseif alert:GetLeft() and (alert:GetLeft() - alert:GetWidth() / 4) < UIParent:GetLeft() then
		alert:ClearAllPoints()
		alert.Arrow:ClearAllPoints()
		alert.Arrow.Glow:ClearAllPoints()

		if isTopQuadrant then
			alert:SetPoint("TOPLEFT", alert.MicroButton, "BOTTOMLEFT", -20, -20)
			alert.Arrow:SetPoint("BOTTOMLEFT", alert, "TOPLEFT", 4, -4)
			alert.Arrow.Glow:SetPoint("BOTTOM")
		else
			alert:SetPoint("BOTTOMLEFT", alert.MicroButton, "TOPLEFT", -20, 20)
			alert.Arrow:SetPoint("TOPLEFT", alert, "BOTTOMLEFT", 4, 4)
			alert.Arrow.Glow:SetPoint("TOP")
		end
	end
end

function MODULE:CreateMicroMenu()
	if not isInit then
		local bar1 = CreateFrame("Frame", "LSMicroMenu1", UIParent)
		bar1._id = "micromenu1"
		bar1._buttons = {}

		MODULE:AddBar(bar1._id, bar1)

		bar1.Update = bar_Update
		bar1.UpdateButtonList = bar_UpdateButtonList
		bar1.UpdateButtonVisibility = bar_UpdateButtonVisibility
		bar1.UpdateConfig = bar_UpdateConfig

		local bar2 = CreateFrame("Frame", "LSMicroMenu2", UIParent)
		bar2._id = "micromenu2"
		bar2._buttons = {}

		MODULE:AddBar(bar2._id, bar2)

		bar2.Update = bar_Update
		bar2.UpdateButtonList = bar_UpdateButtonList
		bar2.UpdateButtonVisibility = bar_UpdateButtonVisibility
		bar2.UpdateConfig = bar_UpdateConfig

		for name, data in next, BUTTONS do
			local button = _G[name] or createMicroButton(name)
			button:SetID(data.id)

			handleMicroButton(button)

			button.Icon:SetTexCoord(unpack(TEXTURE_COORDS[data.icon]))

			if name == "CharacterMicroButton" then
				button._id = "character"
				E:ForceHide(MicroButtonPortrait)
				createButtonIndicators(button, {}, 1)

				button:SetScript("OnEvent", characterButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["CHARACTER_BUTTON"], "TOGGLECHARACTER0")

				button.Update = characterButton_Update
				button.UpdateIndicators = characterButton_UpdateIndicators
			elseif name == "LSInventoryMicroButton" then
				button._id = "inventory"

				createButtonIndicators(button, {}, 1)

				button:SetScript("OnClick", inventoryButton_OnClick)
				button:SetScript("OnEvent", inventoryButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["INVENTORY_BUTTON"], "OPENALLBAGS")

				button.Update = inventoryButton_Update
				button.UpdateIndicators = inventoryButton_UpdateIndicators
			elseif name == "SpellbookMicroButton" then
				button._id = "spellbook"

				button:SetScript("OnEnter", button_OnEnter)
				button:SetScript("OnEvent", spellbookButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["SPELLBOOK_ABILITIES_BUTTON"], "TOGGLESPELLBOOK")
				button.newbieText = NEWBIE_TOOLTIP_SPELLBOOK
			elseif name == "TalentMicroButton" then
				button._id = "talent"
			elseif name == "AchievementMicroButton" then
				button._id = "achievement"
			elseif name == "QuestLogMicroButton" then
				button._id = "quest"

				button.Update = questLogButton_Update
			elseif name == "GuildMicroButton" then
				button._id = "guild"

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
					button:Update()
				end)

				button.Update = guildButton_Update
			elseif name == "LFDMicroButton" then
				button._id = "lfd"

				button:HookScript("OnEvent", lfdButton_OnEvent)

				button.Update = lfdButton_Update
				button.UpdateIndicators = lfdButton_UpdateIndicators
			elseif name == "CollectionsMicroButton" then
				button._id = "collection"

				button:HookScript("OnEvent", collectionsButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["COLLECTIONS"], "TOGGLECOLLECTIONS")
			elseif name == "EJMicroButton" then
				button._id = "ej"

				button:HookScript("OnEvent", ejButton_OnEvent)

				button.NewAdventureNotice:ClearAllPoints()
				button.NewAdventureNotice:SetPoint("CENTER")

				button.Update = ejButton_Update
			elseif name == "StoreMicroButton" then
				button._id = "store"
			elseif name == "MainMenuMicroButton" then
				button._id = "main"

				E:ForceHide(MainMenuBarDownload)
				createButtonIndicators(button, {MainMenuBarPerformanceBar}, 2)

				button:SetScript("OnEvent", mainMenuButton_OnEvent)

				button.Update = mainMenuButton_Update
				button.UpdateIndicators = mainMenuButton_UpdateIndicators
			elseif name == "HelpMicroButton" then
				button._id = "help"
			end
		end

		hooksecurefunc("UpdateMicroButtonsParent", updateMicroButtonsParent)
		hooksecurefunc("MoveMicroButtons", moveMicroButtons)
		hooksecurefunc("UpdateMicroButtons", updateMicroButtons)
		hooksecurefunc("MainMenuMicroButton_ShowAlert", repositionAlert)

		local bagBar = CreateFrame("Frame", "LSBagBar", UIParent)
		bagBar:Hide()
		bagBar:SetScript("OnEvent", bagBar_OnEvent)
		bagBar:SetScript("OnShow", bagBar_OnShow)
		bagBar._id = "bags"
		bagBar._buttons = {}
		bar1.BagBar = bagBar

		for i = 4, 1, -1 do
			local bag = createBag(bagBar, i)
			bag._parent = bagBar
			t_insert(bagBar._buttons, bag)
		end

		local menu = LibDropDown:NewMenu(bagBar, "LSBagFilterMenu")
		menu:SetStyle("MENU")
		bagBar.FilterMenu = menu

		bagBar.Update = bagBar_Update
		bagBar.UpdateConfig = bar_UpdateConfig
		bagBar.UpdateEvents = bagBar_UpdateEvents

		E:ForceHide(MicroButtonAndBagsBar)

		local point = C.db.profile.bars.micromenu.bars.micromenu1.point
		bar1:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(bar1)

		point = C.db.profile.bars.micromenu.bars.bags.point
		bagBar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(bagBar)

		bar2:SetPoint("TOPRIGHT", bar1, "TOPLEFT", 0, 0)
		E.Movers:Create(bar2)

		self:UpdateMicroMenu()

		-- hack
		E:RegisterEvent("PLAYER_ENTERING_WORLD", function()
			for _, name in next, ALERTS do
				repositionAlert(_G[name])
			end
		end)

		isInit = true
	end
end

function MODULE:UpdateMicroMenu()
	for name in next, BUTTONS do
		_G[name]:UpdateConfig()
	end

	self:GetBar("micromenu1"):Update()
	self:GetBar("micromenu2"):Update()
end
