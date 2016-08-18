local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

-- Lua
local _G = _G
local pairs, next, select, unpack = pairs, next, select, unpack
local strformat = string.format
local twipe, tsort = table.wipe, table.sort

-- Blizz
local GameTooltip = GameTooltip
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local GetInventoryItemDurability = GetInventoryItemDurability
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetRFDungeonInfo = GetRFDungeonInfo
local IsAddOnLoaded = IsAddOnLoaded
local IsLFGDungeonJoinable = IsLFGDungeonJoinable

-- Mine
local COLORS = M.colors
local GRADIENT_GYR = COLORS.gradient["GYR"]
local GRADIENT_RYG = COLORS.gradient["RYG"]
local TANK = "|cff1e8eff"..TANK.."|r"
local HEALER = "|cff26a526"..HEALER.."|r"
local DAMAGER = "|cffe52626"..DAMAGER.."|r"
local DAILY_QUEST_RESET_TIME = "|cffffd100Daily Quest Reset Time:|r %s"

local DURABILITY_SLOTS = {1, 3, 5, 6, 7, 8, 9, 10, 16, 17}

local MICRO_BUTTON_LAYOUT = {
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

local ICONS = {
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

local CTA_REWARDS = {
	TANK = {},
	HEALER = {},
	DAMAGER = {},
}

local function SimpleSort(a, b)
	if a and b then
		return a[2] > b[2]
	end
end

local function UpdatePerformanceBar(self)
	local _, _, latencyHome, latencyWorld = _G.GetNetStats()
	local latency = latencyHome > latencyWorld and latencyHome or latencyWorld

	self.Indicator:SetVertexColor(E:ColorGradient(latency / _G.PERFORMANCEBAR_MEDIUM_LATENCY, unpack(GRADIENT_GYR)))
end

local addons = {}
local function MainMenuMicroButton_OnEnter(self)
	_G.GameTooltip_AddNewbieTip(self, self.tooltipText, 1, 1, 1, self.newbieText)
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Latency:")

	local _, _, latencyHome, latencyWorld = _G.GetNetStats()
	local colorHome = E:RGBToHEX(E:ColorGradient(latencyHome / _G.PERFORMANCEBAR_MEDIUM_LATENCY, unpack(GRADIENT_GYR)))
	local colorWorld = E:RGBToHEX(E:ColorGradient(latencyWorld / _G.PERFORMANCEBAR_MEDIUM_LATENCY, unpack(GRADIENT_GYR)))

	GameTooltip:AddDoubleLine("Home", "|cff"..colorHome..latencyHome.."|r ".._G.MILLISECONDS_ABBR, 1, 1, 1)
	GameTooltip:AddDoubleLine("World", "|cff"..colorWorld..latencyWorld.."|r ".._G.MILLISECONDS_ABBR, 1, 1, 1)
	GameTooltip:AddLine(" ")

	local memory = 0

	_G.UpdateAddOnMemoryUsage()

	for i = 1, _G.GetNumAddOns() do
		addons[i] = {
			[1] = select(2, GetAddOnInfo(i)),
			[2] = GetAddOnMemoryUsage(i),
			[3] = IsAddOnLoaded(i),
		}

		memory = memory + addons[i][2]
	end

	tsort(addons, SimpleSort)

	GameTooltip:AddLine("Memory:")

	for i = 1, #addons do
		if addons[i][3] then
			local m = addons[i][2]

			GameTooltip:AddDoubleLine(addons[i][1], strformat("%.3f MB", m / 1024), 1, 1, 1, E:ColorGradient(m / (memory == m and 1 or (memory - m)), unpack(GRADIENT_GYR)))
		end
	end

	GameTooltip:AddDoubleLine(_G.TOTAL..":", strformat("%.3f MB", memory / 1024), 1, 1, 0.6, 1, 1, 0.6)

	UpdatePerformanceBar(self)

	GameTooltip:Show()
end

local function MainMenuMicroButton_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 30 then
		UpdatePerformanceBar(self)

		self.elapsed = 0
	end
end

local function CharacterMicroButton_OnEnter(self)
	local hasInfo = false

	if _G.C_PetBattles.IsInBattle() then
		local hasTitle = false
		for i = 1, 3 do
			local petID, _, _, _, locked = _G.C_PetJournal.GetPetLoadOutInfo(i)

			if petID and not locked then
				local _, customName, level, xp, maxXp, _, _, name = _G.C_PetJournal.GetPetInfoByPetID(petID)
				local _, _, _, _, rarity = _G.C_PetJournal.GetPetStats(petID)
				local color = _G.ITEM_QUALITY_COLORS[rarity - 1]

				if level < 25 then
					if not hasTitle then
						GameTooltip:AddLine(_G.EXPERIENCE_COLON)

						hasTitle = true
					else
						GameTooltip:AddLine(" ")
					end

					GameTooltip:AddLine(customName or name, color.r, color.g, color.b)
					E:ShowTooltipStatusBar(GameTooltip, 0, maxXp, xp, unpack(COLORS.experience))
				end
			end
		end

		hasInfo = true
	else
		-- XP
		if _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL and not _G.IsXPUserDisabled() then
			local r, g, b = unpack(COLORS.experience)

			GameTooltip:AddLine(_G.EXPERIENCE_COLON)
			GameTooltip:AddDoubleLine("Bonus XP", _G.GetXPExhaustion() or 0, 1, 1, 1, r, g, b)
			E:ShowTooltipStatusBar(GameTooltip, 0, _G.UnitXPMax("player"), _G.UnitXP("player"), r, g, b)

			hasInfo = true
		end

		-- ARTIFACT
		if _G.HasArtifactEquipped() then
			if hasInfo then GameTooltip:AddLine(" ") end

			GameTooltip:AddLine(_G.ARTIFACT_POWER..":")

			local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = _G.C_ArtifactUI.GetEquippedArtifactInfo()
			local points, xpCur, xpMax = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
			local r, g, b = unpack(COLORS.artifact)

			GameTooltip:AddDoubleLine("Trait Points", points, 1, 1, 1, r, g, b)
			E:ShowTooltipStatusBar(GameTooltip, 0, xpMax, xpCur, r, g, b)

			hasInfo = true
		end

		-- HONOR
		if _G.UnitLevel("player") >= _G.MAX_PLAYER_LEVEL and (_G.IsWatchingHonorAsXP() or _G.InActiveBattlefield()) then
			if hasInfo then GameTooltip:AddLine(" ") end

			local cur = _G.UnitHonor("player")
			local max = _G.UnitHonorMax("player")
			local r, g, b = unpack(COLORS.honor)

			GameTooltip:AddLine(_G.HONOR..":")
			GameTooltip:AddDoubleLine("Bonus Honor", _G.GetHonorExhaustion() or 0, 1, 1, 1, r, g, b)

			if _G.UnitHonorLevel("player") == _G.GetMaxPlayerHonorLevel() then
				cur, max = 1, 1

				if _G.CanPrestige() then
					GameTooltip:AddLine(_G.PVP_HONOR_PRESTIGE_AVAILABLE, r, g, b)
				else
					GameTooltip:AddLine(_G.MAX_HONOR_LEVEL, r, g, b)
				end
			end

			E:ShowTooltipStatusBar(GameTooltip, 0, max, cur, r, g, b)
		end

		-- REPUTATION
		local name, standing, repMin, repMax, repValue, factionID = _G.GetWatchedFactionInfo()

		if name then
			if hasInfo then GameTooltip:AddLine(" ") end

			GameTooltip:AddLine(_G.REPUTATION..":")

			local min, max, value = 0, 1, 1
			local text = _G.GetText("FACTION_STANDING_LABEL"..standing, _G.UnitSex("player"))
			local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = _G.GetFriendshipReputation(factionID)

			if friendRep then
				if nextFriendThreshold then
					max, value = nextFriendThreshold - friendThreshold, friendRep - friendThreshold
				else
					max, value = 1, 1
				end

				standing = 5
				text = friendTextLevel
			else
				max, value = repMax - repMin, repValue - repMin
			end

			local color = _G.FACTION_BAR_COLORS[standing]

			GameTooltip:AddDoubleLine(name, text, 1, 1, 1, color.r, color.g, color.b)
			E:ShowTooltipStatusBar(GameTooltip, 0, max, value, color.r, color.g, color.b)

			hasInfo = true
		end
	end

	if hasInfo then
		GameTooltip:Show()
	end
end

local function CharacterMicroButton_OnEvent(self, event, ...)
	if event == "UPDATE_INVENTORY_DURABILITY" then
		local total, cur, max = 100

		for _, v in next, DURABILITY_SLOTS do
			cur, max = GetInventoryItemDurability(v)

			if cur then
				cur = cur / max * 100

				if cur < total then
					total = cur
				end
			end
		end

		self.Indicator:SetVertexColor(E:ColorGradient(total / 100, unpack(GRADIENT_RYG)))
	end
end

local function QuestLogMicroButton_OnEnter(self)
	GameTooltip:AddLine(strformat(DAILY_QUEST_RESET_TIME, _G.SecondsToTime(_G.GetQuestResetTime())), 1, 1, 1)
	GameTooltip:Show()
end

local function PopulateCTARewardsTable(dungeonID, dungeonNAME)
	local isAvailable = IsLFGDungeonJoinable(dungeonID)
	if isAvailable then
		for i = 1, _G.LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamage, itemCount = _G.GetLFGRoleShortageRewards(dungeonID, i)
			local _, tank, healer, dps = _G.GetLFGRoles()
			if eligible and itemCount > 0 then
				if tank and forTank then
					CTA_REWARDS.TANK[dungeonID] = CTA_REWARDS.TANK[dungeonID] or {}
					CTA_REWARDS.TANK[dungeonID].name = dungeonNAME

					for rewardIndex = 1, itemCount do
						local name, texture, quantity = _G.GetLFGDungeonShortageRewardInfo(dungeonID, i, rewardIndex)
						CTA_REWARDS.TANK[dungeonID][rewardIndex] = {name = name, texture = "|T"..texture..":0|t", quantity = quantity or 1}
					end
				end

				if healer and forHealer then
					CTA_REWARDS.HEALER[dungeonID] = CTA_REWARDS.HEALER[dungeonID] or {}
					CTA_REWARDS.HEALER[dungeonID].name = dungeonNAME

					for rewardIndex = 1, itemCount do
						local name, texture, quantity = _G.GetLFGDungeonShortageRewardInfo(dungeonID, i, rewardIndex)
						CTA_REWARDS.HEALER[dungeonID][rewardIndex] = {name = name, texture = "|T"..texture..":0|t", quantity = quantity or 1}
					end
				end

				if dps and forDamage then
					CTA_REWARDS.DAMAGER[dungeonID] = CTA_REWARDS.DAMAGER[dungeonID] or {}
					CTA_REWARDS.DAMAGER[dungeonID].name = dungeonNAME

					for rewardIndex = 1, itemCount do
						local name, texture, quantity = _G.GetLFGDungeonShortageRewardInfo(dungeonID, i, rewardIndex)
						CTA_REWARDS.DAMAGER[dungeonID][rewardIndex] = {name = name, texture = "|T"..texture..":0|t", quantity = quantity or 1}
					end
				end
			end
		end
	end
end

local function UpdateLFDMicroButtonTooltip(button, event)
	if event == "LFG_LOCK_INFO_RECEIVED" or event == "FORCE_UPDATE" then
		if event == "LFG_LOCK_INFO_RECEIVED" then
			-- this event is quite spammy sometimes
			local curTime = _G.GetTime()
			if curTime - (button.recentLockInfoUpdateTime or 0) < 0.1 then
				return
			else
				button.recentLockInfoUpdateTime = curTime
			end

			twipe(CTA_REWARDS.TANK)
			twipe(CTA_REWARDS.HEALER)
			twipe(CTA_REWARDS.DAMAGER)

			-- dungeons
			for i = 1, _G.GetNumRandomDungeons() do
				PopulateCTARewardsTable(GetLFGRandomDungeonInfo(i))
			end

			-- raids
			for i = 1, _G.GetNumRFDungeons() do
				PopulateCTARewardsTable(GetRFDungeonInfo(i))
			end

			if GameTooltip:GetOwner() ~= button then return end
		end

		GameTooltip:Hide()
		_G.GameTooltip_AddNewbieTip(button, button.tooltipText, 1, 1, 1, button.newbieText)
		GameTooltip:AddLine(" ")

		if not button:IsEnabled() then
			if button.factionGroup == "Neutral" then
				GameTooltip:AddLine(_G.FEATURE_NOT_AVAILBLE_PANDAREN, 1, 0.1, 0.1, true)
				GameTooltip:Show()
			elseif button.minLevel then
				GameTooltip:AddLine(strformat(_G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL, button.minLevel), 1, 0.1, 0.1, true)
				GameTooltip:Show()
			elseif button.disabledTooltip then
				GameTooltip:AddLine(button.disabledTooltip, 1, 0.1, 0.1, true)
				GameTooltip:Show()
			end

			return
		end

		local hasTankTitle
		for k, v in pairs(CTA_REWARDS.TANK) do
			if v then
				if not hasTankTitle then
					GameTooltip:AddLine(strformat(_G.LFG_CALL_TO_ARMS, TANK))

					hasTankTitle = true
				end

				GameTooltip:AddLine(v.name, 1, 1, 1)
				for i = 1, #v do
					GameTooltip:AddDoubleLine(v[i].name, v[i].quantity..v[i].texture, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
				end
			end
		end

		local hasHealerTitle
		for k, v in pairs(CTA_REWARDS.HEALER) do
			if v then
				if not hasHealerTitle then
					if hasTankTitle then
						GameTooltip:AddLine(" ")
					end

					GameTooltip:AddLine(strformat(_G.LFG_CALL_TO_ARMS, HEALER))

					hasHealerTitle = true
				end

				GameTooltip:AddLine(v.name, 1, 1, 1)
				for i = 1, #v do
					GameTooltip:AddDoubleLine(v[i].name, v[i].quantity..v[i].texture, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
				end
			end
		end

		local hasDamagerTitle
		for k, v in pairs(CTA_REWARDS.DAMAGER) do
			if v then
				if not hasDamagerTitle then
					if hasTankTitle or hasHealerTitle then
						GameTooltip:AddLine(" ")
					end

					GameTooltip:AddLine(strformat(_G.LFG_CALL_TO_ARMS, DAMAGER))

					hasDamagerTitle = true
				end

				GameTooltip:AddLine(v.name, 1, 1, 1)
				for i = 1, #v do
					GameTooltip:AddDoubleLine(v[i].name, v[i].quantity..v[i].texture, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
				end
			end
		end

		if hasTankTitle or hasHealerTitle or hasDamagerTitle then
			GameTooltip:Show()
		end
	end
end

local function LFDMicroButton_OnEnter(self)
	_G.RequestLFDPlayerLockInfo()
	_G.RequestLFDPartyLockInfo()
	UpdateLFDMicroButtonTooltip(self, "FORCE_UPDATE")
end

local function UpdateEJMicroButtonTooltip(button, event)
	if event == "UPDATE_INSTANCE_INFO" or event == "FORCE_UPDATE" then
		if GameTooltip:GetOwner() ~= button then return end

		if event == "UPDATE_INSTANCE_INFO" then
			GameTooltip:Hide()
			_G.GameTooltip_AddNewbieTip(button, button.tooltipText, 1, 1, 1, button.newbieText)
			GameTooltip:AddLine(" ")

			if not button:IsEnabled() then
				if button.factionGroup == "Neutral" then
					GameTooltip:AddLine(_G.FEATURE_NOT_AVAILBLE_PANDAREN, 1, 0.1, 0.1, true)
					GameTooltip:Show()
				elseif button.minLevel then
					GameTooltip:AddLine(strformat(_G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL, button.minLevel), 1, 0.1, 0.1, true)
					GameTooltip:Show()
				elseif button.disabledTooltip then
					GameTooltip:AddLine(button.disabledTooltip, 1, 0.1, 0.1, true)
					GameTooltip:Show()
				end

				return
			end
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
						GameTooltip:AddLine(_G.RAID_INFO..":")

						hasTitle = true
					end

					local color = encounterProgress == numEncounters and {0.9, 0.15, 0.15} or {0.15, 0.65, 0.15}

					GameTooltip:AddDoubleLine(instanceName, encounterProgress.."/"..numEncounters, 1, 1, 1, unpack(color))
					GameTooltip:AddDoubleLine(difficultyName, _G.SecondsToTime(instanceReset, true, nil, 3), 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
				end
			else
				instanceName, _, instanceReset = _G.GetSavedWorldBossInfo(i - savedInstances)
				if instanceReset > 0 then
					if not hasTitle then
						GameTooltip:AddLine(_G.RAID_INFO..":")

						hasTitle = true
					end

					GameTooltip:AddDoubleLine(instanceName, "1/1", 1, 1, 1, 0.9, 0.15, 0.15)
					GameTooltip:AddDoubleLine(_G.RAID_INFO_WORLD_BOSS, _G.SecondsToTime(instanceReset, true, nil, 3), 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
				end
			end
		end

		if hasTitle then
			GameTooltip:Show()
		end
	end
end

local function EJMicroButton_OnEnter(self)
	_G.RequestRaidInfo()
	UpdateEJMicroButtonTooltip(self, "FORCE_UPDATE")
end

local function MicroButton_OnLeave(self)
	if GameTooltip.shownStatusBars then
		for i = 1, GameTooltip.shownStatusBars do
			_G[GameTooltip:GetName().."StatusBar"..i]:SetStatusBarColor(unpack(COLORS.green))
			_G[GameTooltip:GetName().."StatusBar"..i]:Hide()
		end
		GameTooltip.shownStatusBars = 0
	end

	GameTooltip:Hide()
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

local function HandleMicroButtonIndicator(parent, indicator)
	if not indicator then
		indicator = parent:CreateTexture("$parentIndicator")
	end

	indicator:SetDrawLayer("BACKGROUND", 3)
	indicator:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	indicator:SetSize(18, 3)
	indicator:ClearAllPoints()
	indicator:SetPoint("BOTTOM", 0, 0)
	parent.Indicator = indicator
end

local function SetMicroButtonIcon(button, texCoord)
	button.Icon:SetTexCoord(unpack(texCoord))
end

local function GuildTabardUpdateHook()
	if _G.GuildMicroButton.Tabard:IsShown() then
		_G.GuildMicroButton.Tabard.background:Show()
		_G.GuildMicroButton.Tabard.emblem:Show()
		_G.GuildMicroButton.Icon:Hide()
	else
		_G.GuildMicroButton.Tabard.background:Hide()
		_G.GuildMicroButton.Tabard.emblem:Hide()
		_G.GuildMicroButton.Icon:Show()
	end

	SetNormalTextureOverride(_G.GuildMicroButton)
	SetPushedTextureOverride(_G.GuildMicroButton)
	SetDisabledTextureOverride(_G.GuildMicroButton)
end

local function HandleGuildButtonTabard(button)
	button.Tabard = _G.GuildMicroButtonTabard

	local banner = button.Tabard.background
	banner:SetParent(button)
	banner:SetDrawLayer("BACKGROUND", 2)
	banner:SetSize(18, 30)
	banner:ClearAllPoints()
	banner:SetPoint("TOP", 0, 0)
	banner:SetTexCoord(6 / 32, 26 / 32, 0.5, 1)

	local emblem = button.Tabard.emblem
	emblem:SetParent(button)
	emblem:SetDrawLayer("BACKGROUND", 3)
	emblem:SetPoint("CENTER", 0, 0)

	_G.hooksecurefunc("GuildMicroButton_UpdateTabard", GuildTabardUpdateHook)
end

local function ResetMicroButtonsParent()
	for _, b in next, _G.MICRO_BUTTONS do
		local button = _G[b]

		if MICRO_BUTTON_LAYOUT[b] then
			button:SetParent(MICRO_BUTTON_LAYOUT[b].parent)
		else
			button:SetParent(E.HIDDEN_PARENT)
		end
	end
end

local function ResetMicroButtonsPosition()
	for _, b in next, _G.MICRO_BUTTONS do
		local button = _G[b]

		if MICRO_BUTTON_LAYOUT[b] then
			button:ClearAllPoints()
			button:SetPoint(unpack(MICRO_BUTTON_LAYOUT[b].point))
		end
	end
end

function B:HandleMicroMenu()
	local MM_CFG = C.bars.micromenu

	local holder1 = _G.CreateFrame("Frame", "LSMBHolderLeft", _G.UIParent)
	holder1:SetSize(18 * 5 + 4 * 5, 24 + 4)

	local holder2 = _G.CreateFrame("Frame", "LSMBHolderRight", _G.UIParent)
	holder2:SetSize(18 * 5 + 4 * 5, 24 + 4)

	if C.bars.restricted then
		B:SetupControlledBar(holder1, "MicroMenuLeft")
		B:SetupControlledBar(holder2, "MicroMenuRight")
	else
		holder1:SetPoint(unpack(MM_CFG.holder1.point))
		E:CreateMover(holder1)

		holder2:SetPoint(unpack(MM_CFG.holder2.point))
		E:CreateMover(holder2)
	end

	for _, b in next, _G.MICRO_BUTTONS do
		local button = _G[b]

		if MICRO_BUTTON_LAYOUT[b] then
			HandleMicroButton(button)

			button:SetParent(MICRO_BUTTON_LAYOUT[b].parent)
			button:ClearAllPoints()
			button:SetPoint(unpack(MICRO_BUTTON_LAYOUT[b].point))

			SetMicroButtonIcon(button, ICONS[MICRO_BUTTON_LAYOUT[b].icon])
		else
			E:ForceHide(button)
		end

		if b == "CharacterMicroButton" then
			E:ForceHide(_G.MicroButtonPortrait)
			HandleMicroButtonIndicator(button)

			button:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
			button:HookScript("OnEnter", CharacterMicroButton_OnEnter)
			button:HookScript("OnEvent", CharacterMicroButton_OnEvent)
		elseif b == "GuildMicroButton" then
			HandleGuildButtonTabard(button)
		elseif b == "QuestLogMicroButton" then
			button:HookScript("OnEnter", QuestLogMicroButton_OnEnter)
		elseif b == "LFDMicroButton" then
			button:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
			button:SetScript("OnEnter", LFDMicroButton_OnEnter)
			button:HookScript("OnEvent", UpdateLFDMicroButtonTooltip)
		elseif b == "EJMicroButton" then
			button:RegisterEvent("UPDATE_INSTANCE_INFO")
			button:HookScript("OnEnter", EJMicroButton_OnEnter)
			button:HookScript("OnEvent", UpdateEJMicroButtonTooltip)

			button.NewAdventureNotice:ClearAllPoints()
			button.NewAdventureNotice:SetPoint("CENTER")
		elseif b == "MainMenuMicroButton" then
			E:ForceHide(_G.MainMenuBarDownload)
			HandleMicroButtonIndicator(button, _G.MainMenuBarPerformanceBar)
			UpdatePerformanceBar(button)

			button:SetScript("OnEnter", MainMenuMicroButton_OnEnter)
			button:SetScript("OnUpdate", MainMenuMicroButton_OnUpdate)
		end
	end

	_G.TalentMicroButtonAlert:SetPoint("BOTTOM", "TalentMicroButton", "TOP", 0, 12)
	_G.CollectionsMicroButtonAlert:SetPoint("BOTTOM", "CollectionsMicroButton", "TOP", 0, 12)
	_G.LFDMicroButtonAlert:SetPoint("BOTTOM", "LFDMicroButton", "TOP", 0, 12)
	_G.EJMicroButtonAlert:SetPoint("BOTTOM", "EJMicroButton", "TOP", 0, 12)

	_G.hooksecurefunc("UpdateMicroButtonsParent", ResetMicroButtonsParent)
	_G.hooksecurefunc("MoveMicroButtons", ResetMicroButtonsPosition)
end
