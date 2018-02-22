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

-- Mine
local isInit = false
local ctaTicker
local holder1
local holder2

local LATENCY_TEMPLATE = "|cff%s%s|r ".._G.MILLISECONDS_ABBR
local MEMORY_TEMPLATE = "%.2f MiB"
local MICRO_BUTTON_HEIGHT = 48 / 2
local MICRO_BUTTON_WIDTH = 36 / 2

local CFG = {
	visible = true,
	fade = {
		enabled = false,
	},
	menu1 = {
		point = {
			p = "BOTTOM",
			anchor = "UIParent",
			rP = "BOTTOM",
			x = -280,
			y = 16
		},
	},
	menu2 = {
		point = {
			p = "BOTTOM",
			anchor = "UIParent",
			rP = "BOTTOM",
			x = 280,
			y = 16
		},
	},
}

local ROLE_NAMES = {
	tank = L["TANK_BLUE"],
	healer = L["HEALER_GREEN"],
	damager = L["DAMAGER_RED"],
}

local DURABILITY_SLOTS = {
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

local BUTTONS = {
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
		point_alt = {"LEFT", "QuestLogMicroButton", "RIGHT", 4, 0},
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
		point_alt = {"TOPLEFT", "CharacterMicroButton", "BOTTOMLEFT", 0, -4},
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

local function SimpleSort(a, b)
	return a[2] > b[2]
end

local function CreateMicroButtonIndicator(parent, indicators, num)
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
	local _, _, latencyHome, latencyWorld = GetNetStats()

	self.Indicators[1]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyHome / PERFORMANCEBAR_MEDIUM_LATENCY))
	self.Indicators[2]:SetVertexColor(M.COLORS.GYR:GetRGB(latencyWorld / PERFORMANCEBAR_MEDIUM_LATENCY))
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
		pushed:SetTexture("Interface\\AddOns\\ls_UI\\media\\micromenu")
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

local function HandleMicroButton(button)
	local highlight = button:GetHighlightTexture()
	local flash = button.Flash

	button:SetSize(MICRO_BUTTON_WIDTH, MICRO_BUTTON_HEIGHT)
	button:SetHitRectInsets(0, 0, 0, 0)

	SetNormalTexture(button)
	SetPushedTexture(button)
	SetDisabledTexture(button)

	local border = E:CreateBorder(button)
	border:SetTexture("Interface\\AddOns\\ls_UI\\media\\border-thin")
	border:SetSize(16)
	border:SetOffset(-4)
	button.Border = border

	if highlight then
		highlight:SetTexture("Interface\\AddOns\\ls_UI\\media\\micromenu")
		highlight:SetTexCoord(unpack(TEXTURE_COORDS.highlight))
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

	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnUpdate", nil)
end

-- Character
local durability = {
	slots = {},
	min = 100,
}

local function CharacterButton_OnEnter(self)
	Button_OnEnter(self)

	if self:IsEnabled() then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["DURABILITY_COLON"])

		for i = 1, 17 do
			local cur = durability.slots[i]

			if cur then
				GameTooltip:AddDoubleLine(DURABILITY_SLOTS[i], ("%d%%"):format(cur), 1, 1, 1, M.COLORS.RYG:GetRGB(cur / 100))
			end
		end

		GameTooltip:Show()
	end
end

local function CharacterButton_OnEvent(self, event)
	if event == "UPDATE_INVENTORY_DURABILITY" or event == "FORCE_UPDATE" then
		t_wipe(durability.slots)
		durability.min = 100

		for i = 1, 17 do
			local name = DURABILITY_SLOTS[i]

			if name then
				local cur, max = GetInventoryItemDurability(i)

				if cur then
					cur = cur / max * 100

					durability.slots[i] = cur

					if cur < durability.min then
						durability.min = cur
					end
				end
			end
		end

		self.Indicators[1]:SetVertexColor(M.COLORS.RYG:GetRGB(durability.min / 100))
	end
end

-- Quest
local function QuestLogButton_OnEnter(self)
	Button_OnEnter(self)

	if self:IsEnabled() then
		GameTooltip:AddLine(L["DAILY_QUEST_RESET_TIME"]:format(SecondsToTime(GetQuestResetTime())))
		GameTooltip:Show()
	end
end

-- LFD
local cta_rewards = {
	tank = {},
	healer = {},
	damager = {},
	count = 0
}

local function FetchCTAData(dungeonID, dungeonNAME, shortageRole, shortageIndex, numRewards)
	cta_rewards[shortageRole][dungeonID] = cta_rewards[shortageRole][dungeonID] or {}
	cta_rewards[shortageRole][dungeonID].name = dungeonNAME

	for rewardIndex = 1, numRewards do
		local name, texture, quantity = GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, rewardIndex)

		if not name or name == "" then
			name = L["UNKNOWN"]
			texture = texture or "Interface\\Icons\\INV_Misc_QuestionMark"
		end

		cta_rewards[shortageRole][dungeonID][rewardIndex] = {
			name = name,
			texture = "|T"..texture..":0|t",
			quantity = quantity or 1
		}

		cta_rewards.count = cta_rewards.count + 1
	end
end

local function UpdateCTARewards(dungeonID, dungeonNAME)
	if IsLFGDungeonJoinable(dungeonID) then
		for shortageIndex = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local eligible, forTank, forHealer, forDamager, numRewards = GetLFGRoleShortageRewards(dungeonID, shortageIndex)
			local _, tank, healer, damager = GetLFGRoles()

			if eligible and numRewards > 0 then
				if tank and forTank then
					FetchCTAData(dungeonID, dungeonNAME, "tank", shortageIndex, numRewards)
				end

				if healer and forHealer then
					FetchCTAData(dungeonID, dungeonNAME, "healer", shortageIndex, numRewards)
				end

				if damager and forDamager then
					FetchCTAData(dungeonID, dungeonNAME, "damager", shortageIndex, numRewards)
				end
			end
		end
	end
end

local function AddCTARewardsToTooltip(role)
	local hasTitle = false
	local r, g, b = M.COLORS.GRAY:GetRGB()

	for _, v in next, cta_rewards[role] do
		if v then
			if not hasTitle then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["LFG_CALL_TO_ARMS"]:format(ROLE_NAMES[role]))

				hasTitle = true
			end

			GameTooltip:AddLine(v.name, 1, 1, 1)

			for i = 1, #v do
				GameTooltip:AddDoubleLine(v[i].name, v[i].quantity..v[i].texture, r, g, b, r, g, b)
			end
		end
	end
end

local function LFDButton_OnEnter(self)
	Button_OnEnter(self)

	if self:IsEnabled() then
		AddCTARewardsToTooltip("tank")
		AddCTARewardsToTooltip("healer")
		AddCTARewardsToTooltip("damager")

		GameTooltip:Show()
	end
end

local function LFDButton_OnEvent(self, event)
	if event == "LFG_LOCK_INFO_RECEIVED" or event == "FORCE_UPDATE" then
		-- NOTE: this event is quite spammy
		local t = GetTime()

		if t - (self.recentUpdate or 0) >= 0.1 then
			t_wipe(cta_rewards.tank)
			t_wipe(cta_rewards.healer)
			t_wipe(cta_rewards.damager)
			cta_rewards.count = 0

			-- dungeons
			for i = 1, GetNumRandomDungeons() do
				UpdateCTARewards(GetLFGRandomDungeonInfo(i))
			end

			-- raids
			for i = 1, GetNumRFDungeons() do
				UpdateCTARewards(GetRFDungeonInfo(i))
			end

			self.Flash:SetShown(cta_rewards.count > 0)

			if self == GameTooltip:GetOwner() then
				GameTooltip:Hide()

				LFDButton_OnEnter(self)
			end

			self.recentUpdate = t
		end
	end
end

-- EJ
local function EJButton_OnEnter(self)
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
					GameTooltip:AddDoubleLine(L["RAID_INFO_WORLD_BOSS"], SecondsToTime(instanceReset, true, nil, 3), r, g, b, r, g, b)
				end
			end
		end

		GameTooltip:Show()
	end
end

local function EJButton_OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" then
		if self == GameTooltip:GetOwner() then
			GameTooltip:Hide()

			EJButton_OnEnter(self)
		end
	end
end

-- Main
local addons = {
	list = {},
	mem_usage = 0
}

local function MainMenuButton_OnEnter(self)
	Button_OnEnter(self)

	if self:IsEnabled() then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["LATENCY_COLON"])

		local _, _, latencyHome, latencyWorld = GetNetStats()
		local colorHome = M.COLORS.GYR:GetHEX(latencyHome / PERFORMANCEBAR_MEDIUM_LATENCY)
		local colorWorld = M.COLORS.GYR:GetHEX(latencyWorld / PERFORMANCEBAR_MEDIUM_LATENCY)

		GameTooltip:AddDoubleLine(L["LATENCY_HOME"], LATENCY_TEMPLATE:format(colorHome, latencyHome), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["LATENCY_WORLD"], LATENCY_TEMPLATE:format(colorWorld, latencyWorld), 1, 1, 1)

		if IsShiftKeyDown() then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["MEMORY_COLON"])

			t_wipe(addons.list)
			addons.mem_usage = 0

			UpdateAddOnMemoryUsage()

			for i = 1, GetNumAddOns() do
				addons.list[i] = {
					[1] = select(2, GetAddOnInfo(i)),
					[2] = GetAddOnMemoryUsage(i),
					[3] = IsAddOnLoaded(i),
				}

				addons.mem_usage = addons.mem_usage + addons.list[i][2]
			end

			t_sort(addons.list, SimpleSort)

			for i = 1, #addons.list do
				if addons.list[i][3] then
					local m = addons.list[i][2]

					GameTooltip:AddDoubleLine(addons.list[i][1], MEMORY_TEMPLATE:format(m / 1024),
						1, 1, 1, M.COLORS.GYR:GetRGB(m / (addons.mem_usage == m and 1 or (addons.mem_usage - m))))
				end
			end

			GameTooltip:AddDoubleLine(L["TOTAL"], MEMORY_TEMPLATE:format(addons.mem_usage / 1024))
		else
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["MAIN_MICRO_BUTTON_HOLD_TEXT"])
		end

		UpdatePerformanceIndicator(self)

		GameTooltip:Show()
	end
end

local function MainMenuButton_OnEvent(self, event)
	if event == "MODIFIER_STATE_CHANGED" then
		if self == GameTooltip:GetOwner() then
			GameTooltip:Hide()

			MainMenuButton_OnEnter(self)
		end
	end
end

local function bar_Update(self)
	self:UpdateConfig()
	self:UpdateFading()
	self:UpdateButtons("Update")
end

local function bar_UpdateConfig(self)
	self._config = MODULE:IsRestricted() and CFG or C.db.profile.bars.micromenu

	if MODULE:IsRestricted() then
		self._config.fade = C.db.profile.bars.micromenu.fade
	end
end

local function updateMicroButtonsParent()
	if isInit then
		local parent
		if not MODULE:IsRestricted() then
			if PetBattleFrame:IsShown() and not C.db.char.bars.pet_battle.enabled then
				parent = PetBattleFrame
			elseif OverrideActionBar:IsShown() and C.db.char.bars.blizz_vehicle then
				parent = OverrideActionBar
			end
		end

		for _, name in next, MICRO_BUTTONS do
			if BUTTONS[name] then
				_G[name]:SetParent(parent or BUTTONS[name].parent)
			else
				_G[name]:SetParent(E.HIDDEN_PARENT)
			end
		end
	end
end

local function moveMicroButtons(p, parent, rP, x, y)
	if isInit then
		if not MODULE:IsRestricted() and ((PetBattleFrame:IsShown() and not C.db.char.bars.pet_battle.enabled) or (OverrideActionBar:IsShown() and C.db.char.bars.blizz_vehicle)) then
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
			for _, name in next, MICRO_BUTTONS do
				if BUTTONS[name] then
					_G[name]:ClearAllPoints()
					_G[name]:SetPoint(unpack(BUTTONS[name].point))
				end
			end
		end
	end
end

function MODULE.CreateMicroMenu()
	if not isInit then
		holder1 = CreateFrame("Frame", "LSMBHolderLeft", UIParent)
		holder1:SetSize(MICRO_BUTTON_WIDTH * 5 + 4 * 5, MICRO_BUTTON_HEIGHT + 4)
		holder1._id = "menu1"
		holder1._buttons = {}

		MODULE:AddBar(holder1._id, holder1)

		holder1.Update = bar_Update
		holder1.UpdateConfig = bar_UpdateConfig

		holder2 = CreateFrame("Frame", "LSMBHolderRight", UIParent)
		holder2:SetSize(MICRO_BUTTON_WIDTH * 5 + 4 * 5, MICRO_BUTTON_HEIGHT + 4)
		holder2._id = "menu2"
		holder2._buttons = {}

		MODULE:AddBar(holder2._id, holder2)

		holder2.Update = bar_Update
		holder2.UpdateConfig = bar_UpdateConfig

		for _, name in next, MICRO_BUTTONS do
			local button = _G[name]

			if BUTTONS[name] then
				local parent = _G[BUTTONS[name].parent]

				button._parent = parent
				button:SetParent(parent)
				button:ClearAllPoints()
				button:SetPoint(unpack(BUTTONS[name].point))
				HandleMicroButton(button)
				t_insert(parent._buttons, button)

				button.Icon:SetTexCoord(unpack(TEXTURE_COORDS[BUTTONS[name].icon]))
			else
				E:ForceHide(button)
			end

			if name == "CharacterMicroButton" then
				E:ForceHide(MicroButtonPortrait)
				CreateMicroButtonIndicator(button, {}, 1)

				button:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
				button:HookScript("OnEvent", CharacterButton_OnEvent)

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.character then
						self:SetScript("OnEnter", CharacterButton_OnEnter)
					else
						self:SetScript("OnEnter", Button_OnEnter)

						t_wipe(durability.slots)
						durability.min = 100
					end

					CharacterButton_OnEvent(self, "FORCE_UPDATE")
				end
			elseif name == "SpellbookMicroButton" then
				button.tooltipText = MicroButtonTooltipText(L["SPELLBOOK_ABILITIES"], "TOGGLESPELLBOOK")
				button.newbieText = L["NEWBIE_TOOLTIP_SPELLBOOK"]
			elseif name == "QuestLogMicroButton" then
				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.quest then
						self:SetScript("OnEnter", QuestLogButton_OnEnter)
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
				button:HookScript("OnEvent", LFDButton_OnEvent)

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.lfd then
						self:RegisterEvent("LFG_LOCK_INFO_RECEIVED")
						self:SetScript("OnEnter", LFDButton_OnEnter)

						ctaTicker = C_Timer.NewTicker(10, function()
							RequestLFDPlayerLockInfo()
							RequestLFDPartyLockInfo()
						end)

						LFDButton_OnEvent(self, "FORCE_UPDATE")
					else
						self:UnregisterEvent("LFG_LOCK_INFO_RECEIVED")
						self:SetScript("OnEnter", Button_OnEnter)

						t_wipe(cta_rewards.tank)
						t_wipe(cta_rewards.healer)
						t_wipe(cta_rewards.damager)
						cta_rewards.count = 0

						if ctaTicker then
							ctaTicker:Cancel()
						end

						self.Flash:Hide()
					end
				end
			elseif name == "EJMicroButton" then
				button:HookScript("OnEvent", EJButton_OnEvent)

				button.NewAdventureNotice:ClearAllPoints()
				button.NewAdventureNotice:SetPoint("CENTER")

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.ej then
						self:RegisterEvent("UPDATE_INSTANCE_INFO")
						self:SetScript("OnEnter", EJButton_OnEnter)
					else
						self:UnregisterEvent("UPDATE_INSTANCE_INFO")
						self:SetScript("OnEnter", Button_OnEnter)
					end
				end
			elseif name == "MainMenuMicroButton" then
				E:ForceHide(MainMenuBarDownload)
				CreateMicroButtonIndicator(button, {MainMenuBarPerformanceBar}, 2)
				UpdatePerformanceIndicator(button)

				C_Timer.NewTicker(30, function()
					UpdatePerformanceIndicator(MainMenuMicroButton)
				end)

				button:HookScript("OnEvent", MainMenuButton_OnEvent)

				button.Update = function(self)
					if C.db.profile.bars.micromenu.tooltip.main then
						self:RegisterEvent("MODIFIER_STATE_CHANGED")
						self:SetScript("OnEnter", MainMenuButton_OnEnter)
					else
						self:UnregisterEvent("MODIFIER_STATE_CHANGED")
						button:SetScript("OnEnter", Button_OnEnter)

						t_wipe(addons.list)
						addons.mem_usage = 0
					end
				end
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

		if MODULE:IsRestricted() then
			MODULE:ActionBarController_AddWidget(holder1, "MM_LEFT")
			MODULE:ActionBarController_AddWidget(holder2, "MM_RIGHT")
		else
			local config = MODULE:IsRestricted() and CFG or C.db.profile.bars.micromenu
			local point = config.menu1.point
			holder1:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E:CreateMover(holder1)

			point = config.menu2.point
			holder2:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E:CreateMover(holder2)
		end

		holder1:Update()
		holder1:UpdateButtons("Update")

		holder2:Update()
		holder2:UpdateButtons("Update")

		isInit = true
	end
end
