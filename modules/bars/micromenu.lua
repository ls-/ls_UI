local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local table = _G.table
local pairs = _G.pairs
local select = _G.select
local unpack = _G.unpack

-- Blizz
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local GetLFGRandomDungeonInfo = _G.GetLFGRandomDungeonInfo
local GetRFDungeonInfo = _G.GetRFDungeonInfo
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsLFGDungeonJoinable = _G.IsLFGDungeonJoinable

-- Mine
local isInit = false

local LATENCY_TEMPLATE = "|cff%s%s|r ".._G.MILLISECONDS_ABBR
local MEMORY_TEMPLATE = "%.3f MiB"
local MICRO_BUTTON_HEIGHT = 48 / 2
local MICRO_BUTTON_WIDTH = 36 / 2

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

local TEXTURES = {
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
	-- temp = {1 / 256, 33 / 256, 133 / 256, 177 / 256},
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

local function SetMicroButtonIndicator(parent, indicators, num)
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

local function UpdatePerformanceIndicator(self)
	local _, _, latencyHome, latencyWorld = _G.GetNetStats()

	self.Indicators[1]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyHome / _G.PERFORMANCEBAR_MEDIUM_LATENCY))
	self.Indicators[2]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyWorld / _G.PERFORMANCEBAR_MEDIUM_LATENCY))
end

local function SetNormalTextureOverride(button)
	local normal = button:GetNormalTexture()

	if normal then
		normal:SetTexture(nil)
	end
end

local function SetPushedTextureOverride(button)
	local pushed = button:GetPushedTexture()

	if pushed then
		pushed:SetTexture("Interface\\AddOns\\ls_UI\\media\\micromenu")
		pushed:SetTexCoord(unpack(TEXTURES.pushed))
		pushed:ClearAllPoints()
		pushed:SetPoint("TOPLEFT", 1, -1)
		pushed:SetPoint("BOTTOMRIGHT", -1, 1)
	end
end

local function SetDisabledTextureOverride(button)
	local disabled = button:GetDisabledTexture()

	if disabled then
		disabled:SetTexture(nil)
	end
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

	button:SetSize(MICRO_BUTTON_WIDTH, MICRO_BUTTON_HEIGHT)
	button:SetHitRectInsets(0, 0, 0, 0)
	E:CreateBorder(button)

	SetNormalTextureOverride(button)
	SetPushedTextureOverride(button)
	SetDisabledTextureOverride(button)

	if highlight then
		highlight:SetTexture("Interface\\AddOns\\ls_UI\\media\\micromenu")
		highlight:SetTexCoord(unpack(TEXTURES.highlight))
		highlight:ClearAllPoints()
		highlight:SetPoint("TOPLEFT", 1, -1)
		highlight:SetPoint("BOTTOMRIGHT", -1, 1)
	end

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
	icon:SetTexture("Interface\\AddOns\\ls_UI\\media\\micromenu")
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
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
			name = L["UNKNOWN"]
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

-- Micro Buttons
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
	_G.GameTooltip:AddLine(L["DAILY_QUEST_RESET_TIME"]:format(_G.SecondsToTime(_G.GetQuestResetTime())))
	_G.GameTooltip:Show()
end

local function AddCTARewardsInfo(role)
	local hasTitle = false

	for _, v in pairs(cta_rewards[role]) do
		if v then
			if not hasTitle then
				_G.GameTooltip:AddLine(" ")
				_G.GameTooltip:AddLine(L["LFG_CALL_TO_ARMS"]:format(ROLE_NAMES[role]))

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
		_G.GameTooltip:AddLine(" ")

		if self.factionGroup == "Neutral" then
			_G.GameTooltip:AddLine(L["FEATURE_NOT_AVAILBLE_PANDAREN"], 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		elseif self.minLevel then
			_G.GameTooltip:AddLine(L["FEATURE_BECOMES_AVAILABLE_AT_LEVEL"]:format(self.minLevel), 0.86, 0.27, 0.21, true) -- M.COLORS.RED
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
		-- NOTE: this event is quite spammy
		local t = _G.GetTime()

		if t - (self.recentUpdate or 0) >= 0.1 then
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

			self.recentUpdate = t
		end
	end
end

local function EJMicroButton_OnEnter(self)
	_G.GameTooltip_AddNewbieTip(self, self.tooltipText, 1, 1, 1, self.newbieText)

	if not self:IsEnabled() then
		_G.GameTooltip:AddLine(" ")

		if self.factionGroup == "Neutral" then
			_G.GameTooltip:AddLine(L["FEATURE_NOT_AVAILBLE_PANDAREN"], 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		elseif self.minLevel then
			_G.GameTooltip:AddLine(L["FEATURE_BECOMES_AVAILABLE_AT_LEVEL"]:format(self.minLevel), 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		elseif self.disabledTooltip then
			_G.GameTooltip:AddLine(self.disabledTooltip, 0.86, 0.27, 0.21, true) -- M.COLORS.RED
		end

		_G.GameTooltip:Show()

		return
	end

	_G.RequestRaidInfo()

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
					_G.GameTooltip:AddLine(L["RAID_INFO_COLON"])

					hasTitle = true
				end

				local color = encounterProgress == numEncounters and M.COLORS.RED or M.COLORS.GREEN

				_G.GameTooltip:AddDoubleLine(instanceName, encounterProgress.." / "..numEncounters, 1, 1, 1, color:GetRGB())
				_G.GameTooltip:AddDoubleLine(difficultyName, _G.SecondsToTime(instanceReset, true, nil, 3), 0.53, 0.54, 0.53, 0.53, 0.54, 0.53) -- M.COLORS.GRAY
			end
		else
			instanceName, _, instanceReset = _G.GetSavedWorldBossInfo(i - savedInstances)

			if instanceReset > 0 then
				if not hasTitle then
					_G.GameTooltip:AddLine(" ")
					_G.GameTooltip:AddLine(L["RAID_INFO_COLON"])

					hasTitle = true
				end

				_G.GameTooltip:AddDoubleLine(instanceName, "1 / 1", 1, 1, 1, M.COLORS.RED:GetRGB())
				_G.GameTooltip:AddDoubleLine(L["RAID_INFO_WORLD_BOSS"], _G.SecondsToTime(instanceReset, true, nil, 3), 0.53, 0.54, 0.53, 0.53, 0.54, 0.53) -- M.COLORS.GRAY
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
	_G.GameTooltip:AddLine(L["LATENCY_COLON"])

	local _, _, latencyHome, latencyWorld = _G.GetNetStats()
	local colorHome = M.COLORS.GYR:GetHEX(latencyHome / _G.PERFORMANCEBAR_MEDIUM_LATENCY)
	local colorWorld = M.COLORS.GYR:GetHEX(latencyWorld / _G.PERFORMANCEBAR_MEDIUM_LATENCY)

	_G.GameTooltip:AddDoubleLine(L["LATENCY_HOME"], LATENCY_TEMPLATE:format(colorHome, latencyHome), 1, 1, 1)
	_G.GameTooltip:AddDoubleLine(L["LATENCY_WORLD"], LATENCY_TEMPLATE:format(colorWorld, latencyWorld), 1, 1, 1)

	if _G.IsShiftKeyDown() then
		_G.GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(L["MEMORY_COLON"])

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

		for i = 1, #addons do
			if addons[i][3] then
				local m = addons[i][2]

				_G.GameTooltip:AddDoubleLine(addons[i][1], MEMORY_TEMPLATE:format(m / 1024),
					1, 1, 1, M.COLORS.GYR:GetRGB(m / (mem_usage == m and 1 or (mem_usage - m))))
			end
		end

		_G.GameTooltip:AddDoubleLine(L["TOTAL"], MEMORY_TEMPLATE:format(mem_usage / 1024))
	else
		_G.GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(L["MAIN_MICRO_BUTTON_HOLD_TEXT"])
	end

	UpdatePerformanceIndicator(self)

	_G.GameTooltip:Show()
end

local function MainMenuMicroButton_OnEvent(self, event)
	if event == "MODIFIER_STATE_CHANGED" then
		if self == _G.GameTooltip:GetOwner() then
			_G.GameTooltip:Hide()

			MainMenuMicroButton_OnEnter(self)
		end
	end
end

-----------------
-- INITIALISER --
-----------------

function BARS:MicroMenu_IsInit()
	return isInit
end

function BARS:MicroMenu_Init()
	local CFG = C.db.profile.bars.micromenu

	local holder1 = _G.CreateFrame("Frame", "LSMBHolderLeft", _G.UIParent)
	holder1:SetSize(MICRO_BUTTON_WIDTH * 5 + 4 * 5, MICRO_BUTTON_HEIGHT + 4)

	local holder2 = _G.CreateFrame("Frame", "LSMBHolderRight", _G.UIParent)
	holder2:SetSize(MICRO_BUTTON_WIDTH * 5 + 4 * 5, MICRO_BUTTON_HEIGHT + 4)

	if self:ActionBarController_IsInit() then
		self:ActionBarController_AddWidget(holder1, "MM_LEFT")
		self:ActionBarController_AddWidget(holder2, "MM_RIGHT")
	else
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

			button.Icon:SetTexCoord(unpack(TEXTURES[MICRO_BUTTONS[b].icon]))
		else
			E:ForceHide(button)
		end

		if b == "CharacterMicroButton" then
			E:ForceHide(_G.MicroButtonPortrait)
			SetMicroButtonIndicator(button, {}, 1)

			button:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
			button:HookScript("OnEvent", CharacterMicroButton_OnEvent)

			CharacterMicroButton_OnEvent(button, "FORCE_UPDATE")
		elseif b == "GuildMicroButton" then
			button.Tabard = _G.GuildMicroButtonTabard

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
			SetMicroButtonIndicator(button, {_G.MainMenuBarPerformanceBar}, 2)
			UpdatePerformanceIndicator(button)

			button:RegisterEvent("MODIFIER_STATE_CHANGED")
			button:HookScript("OnEvent", MainMenuMicroButton_OnEvent)
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
