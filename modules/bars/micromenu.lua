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
	CollectionsMicroButtonAlert CreateFrame EJMicroButtonAlert GameTooltip GameTooltip_AddNewbieTip GetAddOnInfo
	GetAddOnMemoryUsage GetInventoryItemDurability GetLFGDungeonShortageRewardInfo GetLFGRandomDungeonInfo GetLFGRoles
	GetLFGRoleShortageRewards GetNetStats GetNumAddOns GetNumRandomDungeons GetNumRFDungeons GetNumSavedInstances
	GetNumSavedWorldBosses GetQuestResetTime GetRFDungeonInfo GetSavedInstanceInfo GetSavedWorldBossInfo GetTime
	GuildMicroButtonTabard IsAddOnLoaded IsLFGDungeonJoinable IsShiftKeyDown LFDMicroButtonAlert
	LFG_ROLE_NUM_SHORTAGE_TYPES MainMenuBarDownload MainMenuBarPerformanceBar MainMenuMicroButton MICRO_BUTTONS
	MicroButtonPortrait MicroButtonTooltipText OverrideActionBar PERFORMANCEBAR_MEDIUM_LATENCY PetBattleFrame
	RegisterStateDriver RequestLFDPartyLockInfo RequestLFDPlayerLockInfo RequestRaidInfo SecondsToTime
	TalentMicroButtonAlert UIParent UpdateAddOnMemoryUsage
	BACKPACK_CONTAINER
	BreakUpLargeNumbers
	GetContainerNumFreeSlots
	GetContainerNumSlots
	GetCurrencyInfo
	GetMoney
	GetMoneyString
	NUM_BAG_SLOTS
	ToggleAllBags
]]

-- Mine
local isInit = false

local LATENCY_TEMPLATE = "|cff%s%s|r ".._G.MILLISECONDS_ABBR
local MEMORY_TEMPLATE = "%.2f MiB"
local MICRO_BUTTON_HEIGHT = 48 / 2
local MICRO_BUTTON_WIDTH = 36 / 2

local ROLE_NAMES = {
	tank = L["TANK_BLUE"],
	healer = L["HEALER_GREEN"],
	damager = L["DAMAGER_RED"],
}

local BUTTONS = {
	CharacterMicroButton = {
		point = {"LEFT", 2, 0},
		icon = E.PLAYER_CLASS,
	},
	LSInventoryMicroButton = {
		point = {"LEFT", "CharacterMicroButton", "RIGHT", 4, 0},
		icon = "Inventory",
	},
	SpellbookMicroButton = {
		point = {"LEFT", "LSInventoryMicroButton", "RIGHT", 4, 0},
		icon = "Spellbook",
	},
	TalentMicroButton = {
		point = {"LEFT", "SpellbookMicroButton", "RIGHT", 4, 0},
		icon = "Talent",
	},
	AchievementMicroButton = {
		point = {"LEFT", "TalentMicroButton", "RIGHT", 4, 0},
		icon = "Achievement",
	},
	QuestLogMicroButton = {
		point = {"LEFT", "AchievementMicroButton", "RIGHT", 4, 0},
		icon = "Quest",
	},
	GuildMicroButton = {
		point = {"LEFT", "QuestLogMicroButton", "RIGHT", 4, 0},
		icon = "Guild",
	},
	LFDMicroButton = {
		point = {"LEFT", "GuildMicroButton", "RIGHT", 4, 0},
		icon = "LFD",
	},
	CollectionsMicroButton = {
		point = {"LEFT", "LFDMicroButton", "RIGHT", 4, 0},
		-- point_alt = {"TOPLEFT", "CharacterMicroButton", "BOTTOMLEFT", 0, -4},
		icon = "Collections",
	},
	EJMicroButton = {
		point = {"LEFT", "CollectionsMicroButton", "RIGHT", 4, 0},
		icon = "EJ",
	},
	MainMenuMicroButton = {
		point = {"LEFT", "EJMicroButton", "RIGHT", 4, 0},
		icon = "MainMenu",
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
	Collections = {129 / 256, 161 / 256, 89 / 256, 133 / 256},
	EJ = {161 / 256, 193 / 256, 89 / 256, 133 / 256},
	MainMenu = {193 / 256, 225 / 256, 89 / 256, 133 / 256},
	-- line #4
	Inventory = {1 / 256, 33 / 256, 133 / 256, 177 / 256},
	-- temp = {33 / 256, 65 / 256, 133 / 256, 177 / 256},
	-- temp = {65 / 256, 97 / 256, 133 / 256, 177 / 256},
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

local function createMicroButtonIndicator(parent, indicators, num)
	indicators = indicators or {}
	num = num or #indicators

	for i = 1, num do
		local indicator = indicators[i]

		if not indicator then
			indicator = parent:CreateTexture()
			indicators[i] = indicator
		end

		indicator:SetDrawLayer("BACKGROUND", 3)
		indicator:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		indicator:SetSize(MICRO_BUTTON_WIDTH / num, 3)
		indicator:ClearAllPoints()

		if i == 1 then
			indicator:SetPoint("BOTTOMLEFT", 0, 0)
		else
			indicator:SetPoint("BOTTOMLEFT", indicators[i - 1], "BOTTOMRIGHT", 0, 0)
		end
	end

	parent.Indicators = indicators
end

local function SetNormalTexture(button)
	local normal = button:GetNormalTexture()

	if normal then
		normal:SetTexture(nil)
	end
end

local function SetPushedTexture(button)
	local pushed = button:GetPushedTexture()

	if pushed then
		pushed:SetTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")
		pushed:SetTexCoord(unpack(TEXTURE_COORDS.pushed))
		pushed:ClearAllPoints()
		pushed:SetPoint("TOPLEFT", 1, -1)
		pushed:SetPoint("BOTTOMRIGHT", -1, 1)
	end
end

local function SetDisabledTexture(button)
	local disabled = button:GetDisabledTexture()

	if disabled then
		disabled:SetTexture(nil)
	end
end

local function updateHighlightTexture(button)
	local highlight = button:GetHighlightTexture()

	if highlight then
		highlight:SetTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")
	else
		button:SetHighlightTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu", "ADD")
		highlight = button:GetHighlightTexture()
	end

	highlight:SetTexCoord(unpack(TEXTURE_COORDS.highlight))
	highlight:ClearAllPoints()
	highlight:SetPoint("TOPLEFT", 1, -1)
	highlight:SetPoint("BOTTOMRIGHT", -1, 1)
end

local function Button_OnEnter(self)
	GameTooltip_AddNewbieTip(self, self.tooltipText, 1, 1, 1, self.newbieText)

	if not self:IsEnabled() and (self.minLevel or self.disabledTooltip or self.factionGroup) then
		local r, g, b = M.COLORS.RED:GetRGB()

		if self.factionGroup == "Neutral" then
			GameTooltip:AddLine(L["FEATURE_NOT_AVAILBLE_NEUTRAL"], r, g, b, true)
		elseif self.minLevel then
			GameTooltip:AddLine(L["FEATURE_BECOMES_AVAILABLE_AT_LEVEL"]:format(self.minLevel), r, g, b, true)
		elseif self.disabledTooltip then
			GameTooltip:AddLine(self.disabledTooltip, r, g, b, true)
		end

		GameTooltip:Show()
	end
end

local function handleMicroButton(button)
	local flash = button.Flash

	button:SetSize(MICRO_BUTTON_WIDTH, MICRO_BUTTON_HEIGHT)
	button:SetHitRectInsets(0, 0, 0, 0)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	SetNormalTexture(button)
	SetPushedTexture(button)
	SetDisabledTexture(button)
	updateHighlightTexture(button)

	local border = E:CreateBorder(button)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
	border:SetSize(16)
	border:SetOffset(-4)
	button.Border = border

	if flash then
		flash:SetTexCoord(0 / 64, 33 / 64, 0, 42 / 64)
		flash:SetDrawLayer("OVERLAY", 2)
		flash:ClearAllPoints()
		flash:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
		flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)
	end

	local bg = button:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetColorTexture(0, 0, 0, 1)
	bg:SetAllPoints()

	local icon = button:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
	button.Icon = icon

	button:SetScript("OnEnter", Button_OnEnter)
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
		Button_OnEnter(self)

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
		Button_OnEnter(self)

		if self:IsEnabled() then
			-- WIP
			GameTooltip:AddLine(L["FREE_BAG_SLOTS_TOOLTIP"]:format(freeSlots))
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["CURRENCY_COLON"])

			for id in next, C.db.profile.bars.micromenu.tooltip.inventory.currency do
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

	function inventoryButton_OnClick(_, button)
		if button == "RightButton" then
			-- WIP
		else
			ToggleAllBags()
		end
	end
end

-- Spellbook
local function spellbookMicroButton_OnEvent(self, event)
	if event == "UPDATE_BINDINGS" then
		self.tooltipText = MicroButtonTooltipText(L["SPELLBOOK_ABILITIES_BUTTON"], "TOGGLESPELLBOOK")
	end
end

-- Quest
local function questLogButton_OnEnter(self)
	Button_OnEnter(self)

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
		Button_OnEnter(self)

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

		if C.db.profile.bars.micromenu.tooltip.lfd.enabled then
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
	Button_OnEnter(self)

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
		Button_OnEnter(self)

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

local function bar_Update(self)
	self:UpdateConfig()
	self:UpdateButtons("Update")
	self:UpdateFading()
end

local function bar_UpdateConfig(self)
	self._config = C.db.profile.bars.micromenu
end

local function updateMicroButtonsParent()
	if isInit then
		local parent
		if PetBattleFrame:IsShown() and not C.db.char.bars.pet_battle.enabled then
			parent = PetBattleFrame
		elseif OverrideActionBar:IsShown() and C.db.char.bars.blizz_vehicle then
			parent = OverrideActionBar
		end

		for name in next, BUTTONS do
			_G[name]:SetParent(parent or _G[name]._parent)
		end

		for _, name in next, MICRO_BUTTONS do
			if not BUTTONS[name] then
				E:ForceHide(_G[name])
			end
		end
	end
end

local function moveMicroButtons(p, parent, rP, x, y)
	if isInit then
		if (PetBattleFrame:IsShown() and not C.db.char.bars.pet_battle.enabled) or (OverrideActionBar:IsShown() and C.db.char.bars.blizz_vehicle) then
			for _, name in next, MICRO_BUTTONS do
				if BUTTONS[name] then
					_G[name]:ClearAllPoints()

					if name == "CharacterMicroButton" then
						local x_offset = (PetBattleFrame:IsShown() and 2) or (OverrideActionBar:IsShown() and 4) or 0
						local y_offset = (PetBattleFrame:IsShown() and -30) or (OverrideActionBar:IsShown() and 4) or 0
						_G[name]:SetPoint(p, parent, rP, x + x_offset, y + y_offset)
					else
						_G[name]:SetPoint(unpack(BUTTONS[name].point_alt or BUTTONS[name].point))
					end
				end
			end
		else
			for name, data in next, BUTTONS do
				_G[name]:ClearAllPoints()
				_G[name]:SetPoint(unpack(data.point))
			end
		end
	end
end

function MODULE.CreateMicroMenu()
	if not isInit then
		local bar = CreateFrame("Frame", "LSMBHolder", UIParent)
		bar:SetSize(MICRO_BUTTON_WIDTH * 12 + 4 * 12, MICRO_BUTTON_HEIGHT + 4)
		bar._id = "micromenu"
		bar._buttons = {}

		MODULE:AddBar(bar._id, bar)

		bar.Update = bar_Update
		bar.UpdateConfig = bar_UpdateConfig

		for name, data in next, BUTTONS do
			local button = _G[name] or createMicroButton(name)

			button._parent = bar
			button:SetParent(bar)
			button:ClearAllPoints()
			button:SetPoint(unpack(data.point))
			handleMicroButton(button)
			t_insert(bar._buttons, button)

			button.Icon:SetTexCoord(unpack(TEXTURE_COORDS[data.icon]))

			button:RegisterEvent("UPDATE_BINDINGS")

			if name == "CharacterMicroButton" then
				E:ForceHide(MicroButtonPortrait)
				createMicroButtonIndicator(button, {}, 1)

				button:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
				button:SetScript("OnEvent", characterButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["CHARACTER_INFO_BUTTON"], "TOGGLECHARACTER0")

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.character.enabled then
						self:SetScript("OnEnter", characterButton_OnEnter)
					else
						self:SetScript("OnEnter", Button_OnEnter)
					end

					self:UpdateIndicator()
				end
				button.UpdateIndicator = characterButton_UpdateIndicator
			elseif name == "LSInventoryMicroButton" then
				createMicroButtonIndicator(button, {}, 1)

				button:RegisterEvent("BAG_UPDATE")
				button:SetScript("OnClick", inventoryButton_OnClick)
				button:SetScript("OnEvent", inventoryButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["INVENTORY_BUTTON"], "OPENALLBAGS")

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.inventory.enabled then
						self:SetScript("OnEnter", inventoryButton_OnEnter)
					else
						self:SetScript("OnEnter", Button_OnEnter)
					end

					self:UpdateIndicator()
				end
				button.UpdateIndicator = inventoryButton_UpdateIndicator
			elseif name == "SpellbookMicroButton" then
				button:SetScript("OnEnter", Button_OnEnter)
				button:SetScript("OnEvent", spellbookMicroButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["SPELLBOOK_ABILITIES_BUTTON"], "TOGGLESPELLBOOK")
				button.newbieText = L["NEWBIE_TOOLTIP_SPELLBOOK"]
			-- elseif name == "TalentMicroButton" then
			-- elseif name == "AchievementMicroButton" then
			elseif name == "QuestLogMicroButton" then
				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.quest.enabled then
						self:SetScript("OnEnter", questLogButton_OnEnter)
					else
						self:SetScript("OnEnter", Button_OnEnter)
					end
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

					SetNormalTexture(button)
					SetPushedTexture(button)
					SetDisabledTexture(button)
				end)
			elseif name == "LFDMicroButton" then
				button:HookScript("OnEvent", lfdButton_OnEvent)

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.lfd.enabled then
						self:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
						self:SetScript("OnEnter", lfdButton_OnEnter)

						self.ctaTicker = C_Timer.NewTicker(10, function()
							RequestLFDPlayerLockInfo()
							RequestLFDPartyLockInfo()
						end)
					else
						self:UnregisterEvent("LFG_LOCK_INFO_RECEIVED")
						self:SetScript("OnEnter", Button_OnEnter)

						if self.ctaTicker then
							self.ctaTicker:Cancel()
							self.ctaTicker = nil
						end
					end

					self:UpdateIndicator()
				end
				button.UpdateIndicator = lfdButton_UpdateIndicator
			elseif name == "CollectionsMicroButton" then
				button:HookScript("OnEvent", collectionsButton_OnEvent)

				button.tooltipText = MicroButtonTooltipText(L["COLLECTIONS"], "TOGGLECOLLECTIONS")
			elseif name == "EJMicroButton" then
				button:HookScript("OnEvent", ejButton_OnEvent)

				button.NewAdventureNotice:ClearAllPoints()
				button.NewAdventureNotice:SetPoint("CENTER")

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.ej.enabled then
						self:RegisterEvent("UPDATE_INSTANCE_INFO")
						self:SetScript("OnEnter", ejButton_OnEnter)
					else
						self:UnregisterEvent("UPDATE_INSTANCE_INFO")
						self:SetScript("OnEnter", Button_OnEnter)
					end
				end
			-- elseif name == "StoreMicroButton" then
			elseif name == "MainMenuMicroButton" then
				E:ForceHide(MainMenuBarDownload)
				createMicroButtonIndicator(button, {MainMenuBarPerformanceBar}, 2)

				button:SetScript("OnEvent", mainMenuButton_OnEvent)

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.main.enabled then
						self:RegisterEvent("MODIFIER_STATE_CHANGED")
						self:SetScript("OnEnter", mainMenuButton_OnEnter)
					else
						self:UnregisterEvent("MODIFIER_STATE_CHANGED")
						button:SetScript("OnEnter", Button_OnEnter)
					end

					self:UpdateIndicator()
				end
				button.UpdateIndicator = mainMenuButton_UpdateIndicator

				C_Timer.NewTicker(30, function()
					MainMenuMicroButton:UpdateIndicator()
				end)
			-- elseif name == "HelpMicroButton" then
			end
		end

		for _, name in next, MICRO_BUTTONS do
			if not BUTTONS[name] then
				E:ForceHide(_G[name])
			end
		end

		TalentMicroButtonAlert:SetPoint("BOTTOM", "TalentMicroButton", "TOP", 0, 12)
		LFDMicroButtonAlert:SetPoint("BOTTOM", "LFDMicroButton", "TOP", 0, 12)
		EJMicroButtonAlert:SetPoint("BOTTOM", "EJMicroButton", "TOP", 0, 12)
		CollectionsMicroButtonAlert:SetPoint("BOTTOM", "CollectionsMicroButton", "TOP", 0, 12)

		hooksecurefunc("UpdateMicroButtonsParent", updateMicroButtonsParent)
		hooksecurefunc("MoveMicroButtons", moveMicroButtons)

		local controller = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
		controller.Update = function()
			updateMicroButtonsParent()
			moveMicroButtons()
		end

		controller:SetAttribute("_onstate-petbattle", [[
			if newstate == "false" then
				self:CallMethod("Update")
			end
		]])

		RegisterStateDriver(controller, "petbattle", "[petbattle] true; false")

		local point = C.db.profile.bars.micromenu.point
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		bar:Update()
		bar:UpdateButtons("Update")

		isInit = true
	end
end
