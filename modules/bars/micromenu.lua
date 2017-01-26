local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = _G
local table = _G.table
local string = _G.string
local pairs, select, unpack = _G.pairs, _G.select, _G.unpack

-- Blizz
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local GetLFGRandomDungeonInfo = _G.GetLFGRandomDungeonInfo
local GetRFDungeonInfo = _G.GetRFDungeonInfo
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsLFGDungeonJoinable = _G.IsLFGDungeonJoinable

-- Mine
local isInit = false
local DAILY_QUEST_RESET_TIME = "|cffffd100Daily Quest Reset Time:|r %s"
local LATENCY = "Latency:"
local LATENCY_HOME = "Home"
local LATENCY_WORLD = "World"
local LATENCY_TEXT = "|cff%s%s|r ".._G.MILLISECONDS_ABBR
local MEMORY = "Memory:"
local MEMORY_TEXT = "%.3f MB"
local RAID_INFO = _G.RAID_INFO..":"
local TOTAL = _G.TOTAL..":"

local ROLE_NAMES = {
	tank = "|cff1798fb".._G.TANK.."|r",
	healer = "|cff2eac34".._G.HEALER.."|r",
	damager = "|cffdc4436".._G.DAMAGER.."|r"
}

local DURABILITY_SLOTS = {1, 3, 5, 6, 7, 8, 9, 10, 16, 17}

local MICRO_BUTTONS = {
	CharacterMicroButton = {
		point = {"LEFT", "LSMBHolderLeft", "LEFT", 2, 0},
		parent = "LSMBHolderLeft",
		icon = E.PLAYER_CLASS,
	},
	SpellbookMicroButton = {
		point = {"LEFT", "CharacterMicroButton", "RIGHT", 4, 0},
		parent = "LSMBHolderLeft",
		icon = "Spellbook",
	},
	TalentMicroButton = {
		point = {"LEFT", "SpellbookMicroButton", "RIGHT", 4, 0},
		parent = "LSMBHolderLeft",
		icon = "Talent",
	},
	AchievementMicroButton = {
		point = {"LEFT", "TalentMicroButton", "RIGHT", 4, 0},
		parent = "LSMBHolderLeft",
		icon = "Achievement",
	},
	QuestLogMicroButton = {
		point = {"LEFT", "AchievementMicroButton", "RIGHT", 4, 0},
		parent = "LSMBHolderLeft",
		icon = "Quest",
	},
	GuildMicroButton = {
		point = {"LEFT", "LSMBHolderRight", "LEFT", 2, 0},
		parent = "LSMBHolderRight",
		icon = "Guild",
	},
	LFDMicroButton = {
		point = {"LEFT", "GuildMicroButton", "RIGHT", 4, 0},
		parent = "LSMBHolderRight",
		icon = "LFD",
	},
	CollectionsMicroButton = {
		point = {"LEFT", "LFDMicroButton", "RIGHT", 4, 0},
		parent = "LSMBHolderRight",
		icon = "Collections",
	},
	EJMicroButton = {
		point = {"LEFT", "CollectionsMicroButton", "RIGHT", 4, 0},
		parent = "LSMBHolderRight",
		icon = "EJ",
	},
	MainMenuMicroButton = {
		point = {"LEFT", "EJMicroButton", "RIGHT", 4, 0},
		parent = "LSMBHolderRight",
		icon = "MainMenu",
	},
}

local ICON_COORDS = {
	--line one
	WARRIOR = {18 / 256, 34 / 256, 0, 22 / 64},
	PALADIN = {34 / 256, 50 / 256, 0, 22 / 64},
	HUNTER = {50 / 256, 66 / 256, 0, 22 / 64},
	ROGUE = {66 / 256, 82 / 256, 0, 22 / 64},
	PRIEST = {82 / 256, 98 / 256, 0, 22 / 64},
	DEATHKNIGHT = {98 / 256, 114 / 256, 0, 22 / 64},
	--line two
	SHAMAN = {18 / 256, 34 / 256, 22 / 64, 44 / 64},
	MAGE = {34 / 256, 50 / 256, 22 / 64, 44 / 64},
	WARLOCK = {50 / 256, 66 / 256, 22 / 64, 44 / 64},
	MONK = {66 / 256, 82 / 256, 22 / 64, 44 / 64},
	DRUID = {82 / 256, 98 / 256, 22 / 64, 44 / 64},
	DEMONHUNTER = {98 / 256, 114 / 256, 22 / 64, 44 / 64},
	--line one
	Spellbook = {114 / 256, 130 / 256, 0, 22 / 64},
	Talent = 	{130 / 256, 146 / 256, 0, 22 / 64},
	Achievement = {146 / 256, 162 / 256, 0, 22 / 64},
	Quest = {162 / 256, 178 / 256, 0, 22 / 64},
	Guild = {178 / 256, 194 / 256, 0, 22 / 64},
	LFD = {194 / 256, 210 / 256, 0, 22 / 64},
	Collections = {210 / 256, 226 / 256, 0, 22 / 64},
	--line two
	EJ = {114 / 256, 130 / 256, 22 / 64, 44 / 64},
	MainMenu = {130 / 256, 146 / 256, 22 / 64, 44 / 64},
	-- Temp1 = {146 / 256, 162 / 256, 22 / 64, 44 / 64},
	-- Temp2 = {162 / 256, 178 / 256, 22 / 64, 44 / 64},
	-- Temp3 = {178 / 256, 194 / 256, 22 / 64, 44 / 64},
	-- Temp4 = {194 / 256, 210 / 256, 22 / 64, 44 / 64},
	-- Temp5 = {210 / 256, 226 / 256, 22 / 64, 44 / 64},
}

-- Handler & Utils
local function HandleMicroButtonIndicator(parent, indicators, num)
	indicators = indicators or {}

	for i = 1, num do
		local indicator = indicators[i]

		if not indicator then
			indicator = parent:CreateTexture()
			indicators[i] = indicator
		end

		indicator:SetDrawLayer("BACKGROUND", 3)
		indicator:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		indicator:SetSize(18 / num, 3)
		indicator:ClearAllPoints()

		if i == 1 then
			indicator:SetPoint("BOTTOMLEFT", 0, 0)
		else
			indicator:SetPoint("BOTTOMLEFT", indicators[i - 1], "BOTTOMRIGHT", 0, 0)
		end
	end

	parent.Indicators = indicators
end

local function UpdatePerformanceIndicator(self)
	local _, _, latencyHome, latencyWorld = _G.GetNetStats()

	self.Indicators[1]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyHome / _G.PERFORMANCEBAR_MEDIUM_LATENCY))
	self.Indicators[2]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyWorld / _G.PERFORMANCEBAR_MEDIUM_LATENCY))
end

local function SetNormalTextureOverride(button)
	local normal = button:GetNormalTexture()
	if normal then normal:SetTexture(nil) end
end

local function SetPushedTextureOverride(button)
	local pushed = button:GetPushedTexture()
	if pushed then
		pushed:SetTexture("Interface\\AddOns\\ls_UI\\media\\micromenu")
		pushed:SetBlendMode("ADD")
		pushed:SetTexCoord(0 / 256, 18 / 256, 24 / 64, 48 / 64)
		pushed:ClearAllPoints()
		pushed:SetAllPoints()
	end
end

local function SetDisabledTextureOverride(button)
	local disabled = button:GetDisabledTexture()
	if disabled then disabled:SetTexture(nil) end
end

local function MicroButton_OnLeave()
	if _G.GameTooltip.shownStatusBars then
		for i = 1, _G.GameTooltip.shownStatusBars do
			_G[_G.GameTooltip:GetName().."StatusBar"..i]:SetStatusBarColor(M.COLORS.GREEN:GetRGB())
			_G[_G.GameTooltip:GetName().."StatusBar"..i]:ClearAllPoints()
			_G[_G.GameTooltip:GetName().."StatusBar"..i]:Hide()
		end
		_G.GameTooltip.shownStatusBars = 0
	end

	_G.GameTooltip:Hide()
end

local function HandleMicroButton(button)
	local highlight = button:GetHighlightTexture()
	local flash = button.Flash

	button:SetSize(18, 24)
	button:SetHitRectInsets(0, 0, 0, 0)
	E:CreateBorder(button)

	SetNormalTextureOverride(button)
	SetPushedTextureOverride(button)
	SetDisabledTextureOverride(button)

	if highlight then
		highlight:SetTexture("Interface\\AddOns\\ls_UI\\media\\micromenu")
		highlight:SetTexCoord(0 / 256, 18 / 256, 0, 24 / 64)
		highlight:ClearAllPoints()
		highlight:SetAllPoints()
	end

	if flash then
		flash:SetTexCoord(0 / 64, 33 / 64, 0, 42 / 64)
		flash:SetSize(28, 34)
		flash:SetDrawLayer("OVERLAY", 2)
		flash:ClearAllPoints()
		flash:SetPoint("CENTER", 0, 0)
	end

	local bg = button:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetColorTexture(0, 0, 0, 1)
	bg:SetAllPoints()

	local icon = button:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexture("Interface\\AddOns\\ls_UI\\media\\micromenu")
	icon:SetSize(16, 22)
	icon:SetPoint("CENTER", 0, 0)
	button.Icon = icon

	button:SetScript("OnLeave", MicroButton_OnLeave)
	button:SetScript("OnUpdate", nil)
end

-- Call to Arms
local cta_rewards = {
	tank = {},
	healer = {},
	damager = {},
	count = 0
}

local function SimpleSort(a, b)
	if a and b then
		return a[2] > b[2]
	end
end

local function PopulateDungeonShortageRewards(dungeonID, dungeonNAME, shortageRole, shortageIndex, numRewards)
	cta_rewards[shortageRole][dungeonID] = cta_rewards[shortageRole][dungeonID] or {}
	cta_rewards[shortageRole][dungeonID].name = dungeonNAME

	for rewardIndex = 1, numRewards do
		local name, texture, quantity = _G.GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, rewardIndex)

		if not name or name == "" then
			name = _G.UNKNOWN
			texture = texture or "Interface\\Icons\\INV_Misc_QuestionMark"
		end

		cta_rewards[shortageRole][dungeonID][rewardIndex] = {name = name, texture = "|T"..texture..":0|t", quantity = quantity or 1}

		cta_rewards.count = cta_rewards.count + 1
	end
end

local function PopulateCTARewards(dungeonID, dungeonNAME)
	if IsLFGDungeonJoinable(dungeonID) then
		for shortageIndex = 1, _G.LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamager, numRewards = _G.GetLFGRoleShortageRewards(dungeonID, shortageIndex)
			local _, tank, healer, damager = _G.GetLFGRoles()

			if eligible and numRewards > 0 then
				if tank and forTank then
					PopulateDungeonShortageRewards(dungeonID, dungeonNAME, "tank", shortageIndex, numRewards)
				end

				if healer and forHealer then
					PopulateDungeonShortageRewards(dungeonID, dungeonNAME, "healer", shortageIndex, numRewards)
				end

				if damager and forDamager then
					PopulateDungeonShortageRewards(dungeonID, dungeonNAME, "damager", shortageIndex, numRewards)
				end
			end
		end
	end
end

-------------------
-- MICRO BUTTONS --
-------------------

local function CharacterMicroButton_OnEvent(self, event)
	if event == "UPDATE_INVENTORY_DURABILITY" or event == "FORCE_UPDATE" then
		local total, cur, max = 100

		for _, v in pairs(DURABILITY_SLOTS) do
			cur, max = _G.GetInventoryItemDurability(v)

			if cur then
				cur = cur / max * 100

				if cur < total then
					total = cur
				end
			end
		end

		self.Indicators[1]:SetVertexColor(M.COLORS.RYG:GetRGB(total / 100))
	end
end

local function QuestLogMicroButton_OnEnter()
	_G.GameTooltip:AddLine(string.format(DAILY_QUEST_RESET_TIME, _G.SecondsToTime(_G.GetQuestResetTime())), 1, 1, 1)
	_G.GameTooltip:Show()
end

local function AddCTARewardsInfo(role)
	local hasTitle = false

	for _, v in pairs(cta_rewards[role]) do
		if v then
			if not hasTitle then
				_G.GameTooltip:AddLine(" ")
				_G.GameTooltip:AddLine(string.format(_G.LFG_CALL_TO_ARMS, ROLE_NAMES[role]))

				hasTitle = true
			end

			_G.GameTooltip:AddLine(v.name, 1, 1, 1)

			for i = 1, #v do
				_G.GameTooltip:AddDoubleLine(v[i].name, v[i].quantity..v[i].texture, 0.53, 0.54, 0.53, 0.53, 0.54, 0.53) -- M.COLORS.GRAY
			end
		end
	end
end

local function LFDMicroButton_OnEnter(self)
	_G.GameTooltip_AddNewbieTip(self, self.tooltipText, 1, 1, 1, self.newbieText)

	if not self:IsEnabled() then
		if self.factionGroup == "Neutral" then
			_G.GameTooltip:AddLine(_G.FEATURE_NOT_AVAILBLE_PANDAREN, 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		elseif self.minLevel then
			_G.GameTooltip:AddLine(string.format(_G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		elseif self.disabledTooltip then
			_G.GameTooltip:AddLine(self.disabledTooltip, 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		end

		_G.GameTooltip:Show()

		return
	end

	AddCTARewardsInfo("tank")
	AddCTARewardsInfo("healer")
	AddCTARewardsInfo("damager")

	_G.GameTooltip:Show()
end

local function LFDMicroButton_OnEvent(self, event)
	if event == "LFG_LOCK_INFO_RECEIVED" then
		-- this event is quite spammy
		local curTime = _G.GetTime()

		if curTime - (self.recentLockInfoUpdateTime or 0) < 0.1 then
			return
		else
			self.recentLockInfoUpdateTime = curTime
		end

		table.wipe(cta_rewards.tank)
		table.wipe(cta_rewards.healer)
		table.wipe(cta_rewards.damager)

		cta_rewards.count = 0

		-- dungeons
		for i = 1, _G.GetNumRandomDungeons() do
			PopulateCTARewards(GetLFGRandomDungeonInfo(i))
		end

		-- raids
		for i = 1, _G.GetNumRFDungeons() do
			PopulateCTARewards(GetRFDungeonInfo(i))
		end

		self.Flash:SetShown(cta_rewards.count > 0)

		if self == _G.GameTooltip:GetOwner() then
			_G.GameTooltip:Hide()

			LFDMicroButton_OnEnter(self)
		end
	end
end

local function EJMicroButton_OnEnter(self)
	_G.RequestRaidInfo()

	_G.GameTooltip_AddNewbieTip(self, self.tooltipText, 1, 1, 1, self.newbieText)

	if not self:IsEnabled() then
		if self.factionGroup == "Neutral" then
			_G.GameTooltip:AddLine(_G.FEATURE_NOT_AVAILBLE_PANDAREN, 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		elseif self.minLevel then
			_G.GameTooltip:AddLine(string.format(_G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL, self.minLevel), 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		elseif self.disabledTooltip then
			_G.GameTooltip:AddLine(self.disabledTooltip, 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		end

		_G.GameTooltip:Show()

		return
	end

	local savedInstances = _G.GetNumSavedInstances()
	local savedWorldBosses = _G.GetNumSavedWorldBosses()

	if savedInstances + savedWorldBosses == 0 then return end

	local instanceName, instanceReset, difficultyName, numEncounters, encounterProgress
	local hasTitle

	for i = 1, savedInstances + savedWorldBosses do
		if i <= savedInstances then
			instanceName, _, instanceReset, _, _, _, _, _, _, difficultyName, numEncounters, encounterProgress = _G.GetSavedInstanceInfo(i)
			if instanceReset > 0 then
				if not hasTitle then
					_G.GameTooltip:AddLine(" ")
					_G.GameTooltip:AddLine(RAID_INFO)

					hasTitle = true
				end

				local color = encounterProgress == numEncounters and M.COLORS.RED or M.COLORS.GREEN

				_G.GameTooltip:AddDoubleLine(instanceName, encounterProgress.."/"..numEncounters, 1, 1, 1, color:GetRGB())
				_G.GameTooltip:AddDoubleLine(difficultyName, _G.SecondsToTime(instanceReset, true, nil, 3), 0.53, 0.54, 0.53, 0.53, 0.54, 0.53) -- M.COLORS.GRAY
			end
		else
			instanceName, _, instanceReset = _G.GetSavedWorldBossInfo(i - savedInstances)
			if instanceReset > 0 then
				if not hasTitle then
					_G.GameTooltip:AddLine(" ")
					_G.GameTooltip:AddLine(RAID_INFO)

					hasTitle = true
				end

				_G.GameTooltip:AddDoubleLine(instanceName, "1/1", 1, 1, 1, M.COLORS.RED:GetRGB())
				_G.GameTooltip:AddDoubleLine(_G.RAID_INFO_WORLD_BOSS, _G.SecondsToTime(instanceReset, true, nil, 3), 0.53, 0.54, 0.53, 0.53, 0.54, 0.53) -- M.COLORS.GRAY
			end
		end
	end

	_G.GameTooltip:Show()
end

local function EJMicroButton_OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" then
		if self == _G.GameTooltip:GetOwner() then
			_G.GameTooltip:Hide()

			EJMicroButton_OnEnter(self)
		end
	end
end

local function MainMenuMicroButton_OnEnter(self)
	_G.GameTooltip_AddNewbieTip(self, self.tooltipText, 1, 1, 1, self.newbieText)
	_G.GameTooltip:AddLine(" ")
	_G.GameTooltip:AddLine(LATENCY)

	local _, _, latencyHome, latencyWorld = _G.GetNetStats()
	local colorHome = M.COLORS.GYR:GetHEX(latencyHome / _G.PERFORMANCEBAR_MEDIUM_LATENCY)
	local colorWorld = M.COLORS.GYR:GetHEX(latencyWorld / _G.PERFORMANCEBAR_MEDIUM_LATENCY)

	_G.GameTooltip:AddDoubleLine(LATENCY_HOME, string.format(LATENCY_TEXT, colorHome, latencyHome), 1, 1, 1)
	_G.GameTooltip:AddDoubleLine(LATENCY_WORLD, string.format(LATENCY_TEXT, colorWorld, latencyWorld), 1, 1, 1)
	_G.GameTooltip:AddLine(" ")

	local addons = {}
	local mem_usage = 0

	_G.UpdateAddOnMemoryUsage()

	for i = 1, _G.GetNumAddOns() do
		addons[i] = {
			[1] = select(2, GetAddOnInfo(i)),
			[2] = GetAddOnMemoryUsage(i),
			[3] = IsAddOnLoaded(i),
		}

		mem_usage = mem_usage + addons[i][2]
	end

	table.sort(addons, SimpleSort)

	_G.GameTooltip:AddLine(MEMORY)

	for i = 1, #addons do
		if addons[i][3] then
			local m = addons[i][2]

			_G.GameTooltip:AddDoubleLine(addons[i][1], string.format(MEMORY_TEXT, m / 1024),
				1, 1, 1, M.COLORS.GYR:GetRGB(m / (mem_usage == m and 1 or (mem_usage - m))))
		end
	end

	_G.GameTooltip:AddDoubleLine(TOTAL, string.format(MEMORY_TEXT, mem_usage / 1024))

	UpdatePerformanceIndicator(self)

	_G.GameTooltip:Show()
end

-----------------
-- INITIALISER --
-----------------

function BARS:MicroMenu_IsInit()
	return isInit
end

function BARS:MicroMenu_Init()
	local CFG = C.bars.micromenu

	local holder1 = _G.CreateFrame("Frame", "LSMBHolderLeft", _G.UIParent)
	holder1:SetSize(18 * 5 + 4 * 5, 24 + 4)

	local holder2 = _G.CreateFrame("Frame", "LSMBHolderRight", _G.UIParent)
	holder2:SetSize(18 * 5 + 4 * 5, 24 + 4)

	if not C.bars.restricted then
		holder1:SetPoint(unpack(CFG.holder1.point))
		E:CreateMover(holder1)

		holder2:SetPoint(unpack(CFG.holder2.point))
		E:CreateMover(holder2)
	end

	for _, b in pairs(_G.MICRO_BUTTONS) do
		local button = _G[b]

		if MICRO_BUTTONS[b] then
			HandleMicroButton(button)

			button:SetParent(MICRO_BUTTONS[b].parent)
			button:ClearAllPoints()
			button:SetPoint(unpack(MICRO_BUTTONS[b].point))

			button.Icon:SetTexCoord(unpack(ICON_COORDS[MICRO_BUTTONS[b].icon]))
		else
			E:ForceHide(button)
		end

		if b == "CharacterMicroButton" then
			E:ForceHide(_G.MicroButtonPortrait)
			HandleMicroButtonIndicator(button, {}, 1)

			button:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
			button:HookScript("OnEvent", CharacterMicroButton_OnEvent)

			CharacterMicroButton_OnEvent(button, "FORCE_UPDATE")
		elseif b == "GuildMicroButton" then
			button.Tabard = _G.GuildMicroButtonTabard

			button.Tabard.background:SetParent(button)
			button.Tabard.background:SetDrawLayer("BACKGROUND", 2)
			button.Tabard.background:SetSize(18, 30)
			button.Tabard.background:ClearAllPoints()
			button.Tabard.background:SetPoint("TOP", 0, 0)
			button.Tabard.background:SetTexCoord(6 / 32, 26 / 32, 0.5, 1)

			button.Tabard.emblem:SetParent(button)
			button.Tabard.emblem:SetDrawLayer("BACKGROUND", 3)
			button.Tabard.emblem:SetPoint("CENTER", 0, 0)

			_G.hooksecurefunc("GuildMicroButton_UpdateTabard", function()
				if button.Tabard:IsShown() then
					button.Tabard.background:Show()
					button.Tabard.emblem:Show()
					button.Icon:Hide()
				else
					button.Tabard.background:Hide()
					button.Tabard.emblem:Hide()
					button.Icon:Show()
				end

				SetNormalTextureOverride(button)
				SetPushedTextureOverride(button)
				SetDisabledTextureOverride(button)
			end)
		elseif b == "QuestLogMicroButton" then
			button:HookScript("OnEnter", QuestLogMicroButton_OnEnter)
		elseif b == "LFDMicroButton" then
			button:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
			button:SetScript("OnEnter", LFDMicroButton_OnEnter)
			button:HookScript("OnEvent", LFDMicroButton_OnEvent)
		elseif b == "EJMicroButton" then
			button:RegisterEvent("UPDATE_INSTANCE_INFO")
			button:SetScript("OnEnter", EJMicroButton_OnEnter)
			button:HookScript("OnEvent", EJMicroButton_OnEvent)

			button.NewAdventureNotice:ClearAllPoints()
			button.NewAdventureNotice:SetPoint("CENTER")

			_G.RequestLFDPlayerLockInfo()
			_G.RequestLFDPartyLockInfo()
		elseif b == "MainMenuMicroButton" then
			E:ForceHide(_G.MainMenuBarDownload)
			HandleMicroButtonIndicator(button, {_G.MainMenuBarPerformanceBar}, 2)
			UpdatePerformanceIndicator(button)

			button:SetScript("OnEnter", MainMenuMicroButton_OnEnter)
		end
	end

	_G.TalentMicroButtonAlert:SetPoint("BOTTOM", "TalentMicroButton", "TOP", 0, 12)
	_G.LFDMicroButtonAlert:SetPoint("BOTTOM", "LFDMicroButton", "TOP", 0, 12)
	_G.EJMicroButtonAlert:SetPoint("BOTTOM", "EJMicroButton", "TOP", 0, 12)
	_G.CollectionsMicroButtonAlert:SetPoint("BOTTOM", "CollectionsMicroButton", "TOP", 0, 12)

	_G.hooksecurefunc("UpdateMicroButtonsParent", function()
		for _, b in pairs(_G.MICRO_BUTTONS) do
			local button = _G[b]

			if MICRO_BUTTONS[b] then
				button:SetParent(MICRO_BUTTONS[b].parent)
			else
				button:SetParent(E.HIDDEN_PARENT)
			end
		end
	end)

	_G.hooksecurefunc("MoveMicroButtons", function()
		for _, b in pairs(_G.MICRO_BUTTONS) do
			local button = _G[b]

			if button then
				button:ClearAllPoints()
				button:SetPoint(unpack(MICRO_BUTTONS[b].point))
			end
		end
	end)

	-- Finalise
	_G.C_Timer.NewTicker(10, function()
		_G.RequestLFDPlayerLockInfo()
		_G.RequestLFDPartyLockInfo()
	end)

	_G.C_Timer.NewTicker(30, function()
		UpdatePerformanceIndicator(_G.MainMenuMicroButton)
	end)

	isInit = true

	return true
end
