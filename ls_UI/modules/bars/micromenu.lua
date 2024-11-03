local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local ipairs = _G.ipairs
local m_abs = _G.math.abs
local next = _G.next
local select = _G.select
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local unpack = _G.unpack

-- Mine
local buttons = {}
local activeButtons = {}
local isInit = false

local BUTTONS = {
	character = {
		name = "CharacterMicroButton",
		icon = E.PLAYER_CLASS,
		events = {
			PLAYER_ENTERING_WORLD = true,
			UPDATE_INVENTORY_DURABILITY = true,
		},
	},
	spellbook = {
		name = "ProfessionMicroButton",
		icon = "SPELLBOOK",
		events = {},
	},
	talent = {
		name = "PlayerSpellsMicroButton",
		icon = "TALENT",
		events = {
			HONOR_LEVEL_UPDATE = true,
			PLAYER_LEVEL_CHANGED = true,
			PLAYER_PVP_TALENT_UPDATE = true,
			PLAYER_SPECIALIZATION_CHANGED = true,
			PLAYER_TALENT_UPDATE = true,
			UPDATE_BATTLEFIELD_STATUS = true,
		},
	},
	achievement = {
		name = "AchievementMicroButton",
		icon = "ACHIEVEMENT",
		events = {
			ACHIEVEMENT_EARNED = true,
			RECEIVED_ACHIEVEMENT_LIST = true,
		},
	},
	quest = {
		name = "QuestLogMicroButton",
		icon = "QUEST",
		events = {},
	},
	guild = {
		name = "GuildMicroButton",
		icon = "GUILD",
		events = {
			BN_CONNECTED = true,
			BN_DISCONNECTED = true,
			CHAT_DISABLED_CHANGE_FAILED = true,
			CHAT_DISABLED_CHANGED = true,
			CLUB_FINDER_COMMUNITY_OFFLINE_JOIN = true,
			CLUB_INVITATION_ADDED_FOR_SELF = true,
			CLUB_INVITATION_REMOVED_FOR_SELF = true,
			INITIAL_CLUBS_LOADED = true,
			PLAYER_ENTERING_WORLD = true,
			STREAM_VIEW_MARKER_UPDATED = true,
		},
	},
	lfd = {
		name = "LFDMicroButton",
		icon = "LFD",
		events = {
			LFG_LOCK_INFO_RECEIVED = true,
		},
	},
	collection = {
		name = "CollectionsMicroButton",
		icon = "COLLECTION",
		events = {
			COMPANION_LEARNED = true,
			HEIRLOOMS_UPDATED = true,
			PET_JOURNAL_LIST_UPDATE = true,
			PET_JOURNAL_NEW_BATTLE_SLOT = true,
			PLAYER_ENTERING_WORLD = true,
			TOYS_UPDATED = true,
		},
	},
	ej = {
		name = "EJMicroButton",
		icon = "EJ",
		events = {
			PLAYER_ENTERING_WORLD = true,
			UPDATE_INSTANCE_INFO = true,
			VARIABLES_LOADED = true,
			ZONE_CHANGED_NEW_AREA = true,
		},
	},
	store = {
		name = "StoreMicroButton",
		icon = "STORE",
		events = {
			STORE_STATUS_CHANGED = true,
		},
	},
	main = {
		name = "MainMenuMicroButton",
		icon = "MAINMENU",
		events = {
			MODIFIER_STATE_CHANGED = true,
		},
	},
	help = {
		name = "HelpMicroButton",
		icon = "HELP",
		events = {},
	},
}

local ALERTS = {
	"CharacterMicroButton",
	"CollectionsMicroButton",
	"EJMicroButton",
	"GuildMicroButton",
	"PlayerSpellsMicroButton",
}

local TEXTURE_COORDS = {
	-- line #1
	["DEATHKNIGHT"] = {1 / 512, 33 / 512, 1 / 128, 45 / 128},
	["DEMONHUNTER"] = {33 / 512, 65 / 512, 1 / 128, 45 / 128},
	["DRUID"] = {65 / 512, 97 / 512, 1 / 128, 45 / 128},
	["EVOKER"] = {97 / 512, 129 / 512, 1 / 128, 45 / 128},
	["HUNTER"] = {129 / 512, 161 / 512, 1 / 128, 45 / 128},
	["MAGE"] = {161 / 512, 193 / 512, 1 / 128, 45 / 128},
	["MONK"] = {193 / 512, 225 / 512, 1 / 128, 45 / 128},
	["PALADIN"] = {225 / 512, 257 / 512, 1 / 128, 45 / 128},
	["PRIEST"] = {257 / 512, 289 / 512, 1 / 128, 45 / 128},
	["ROGUE"] = {289 / 512, 321 / 512, 1 / 128, 45 / 128},
	["SHAMAN"] = {321 / 512, 353 / 512, 1 / 128, 45 / 128},
	["WARLOCK"] = {353 / 512, 385 / 512, 1 / 128, 45 / 128},
	["WARRIOR"] = {385 / 512, 417 / 512, 1 / 128, 45 / 128},
	["SPELLBOOK"] = {417 / 512, 449 / 512, 1 / 128, 45 / 128},
	["TALENT"] = {449 / 512, 481 / 512, 1 / 128, 45 / 128},
	-- line #2
	["ACHIEVEMENT"] = {1 / 512, 33 / 512, 45 / 128, 89 / 128},
	["QUEST"] = {33 / 512, 65 / 512, 45 / 128, 89 / 128},
	["GUILD"] = {65 / 512, 97 / 512, 45 / 128, 89 / 128},
	["LFD"] = {97 / 512, 129 / 512, 45 / 128, 89 / 128},
	["COLLECTION"] = {129 / 512, 161 / 512, 45 / 128, 89 / 128},
	["EJ"] = {161 / 512, 193 / 512, 45 / 128, 89 / 128},
	["STORE"] = {193 / 512, 225 / 512, 45 / 128, 89 / 128},
	["MAINMENU"] = {225 / 512, 257 / 512, 45 / 128, 89 / 128},
	["HELP"] = {257 / 512, 289 / 512, 45 / 128, 89 / 128},
	["BORDER"] = {289 / 512, 333 / 512, 45 / 128, 101 / 128},
	["HIGHLIGHT"] = {333 / 512, 369 / 512, 45 / 128, 93 / 128},
	["INDICATOR"] = {1 / 512, 33 / 512, 93 / 128, 97 / 128},
	["BAG_INDICATOR"] = {369 / 512, 449 / 512, 45 / 128, 125 / 128},
}

local idToIndex = {
	["character"] = 1,
	["spellbook"] = 2,
	["talent"] = 3,
	["achievement"] = 4,
	["quest"] = 5,
	["guild"] = 6,
	["lfd"] = 7,
	["collection"] = 8,
	["ej"] = 9,
	["store"] = 10,
	["main"] = 11,
	["help"] = 12,
}

local function createButtonIndicator(button, indicator)
	indicator = indicator or button:CreateTexture()
	indicator:SetTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")
	indicator:SetTexCoord(unpack(TEXTURE_COORDS.INDICATOR))

	if PrC.db.profile.bars.micromenu.blizz_enabled then
		indicator:SetDrawLayer("BACKGROUND", -1)
		indicator:ClearAllPoints()
		indicator:SetPoint("BOTTOMLEFT", 5, 5)
		indicator:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", -4, 7)
	else
		indicator:SetDrawLayer("BACKGROUND", 3)
		indicator:ClearAllPoints()
		indicator:SetPoint("BOTTOMLEFT", 1, 1)
		indicator:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", -1, 3)
	end

	return indicator
end

local function updateNormalTexture(button)
	button:SetNormalTexture("Interface\\AddOns\\ls_UI\\assets\\transparent")
end

local function updatePushedTexture(button)
	button:SetPushedTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")

	local pushed = button:GetPushedTexture()
	pushed:SetTexCoord(unpack(TEXTURE_COORDS.HIGHLIGHT))
	pushed:ClearAllPoints()
	pushed:SetPoint("TOPLEFT", 0, 0)
	pushed:SetPoint("BOTTOMRIGHT", 0, 0)
end

local function updateDisabledTexture(button)
	button:SetDisabledTexture("Interface\\AddOns\\ls_UI\\assets\\transparent")
end

local function updateHighlightTexture(button)
	button:SetHighlightTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")

	local highlight = button:GetHighlightTexture()
	highlight:SetTexCoord(unpack(TEXTURE_COORDS.HIGHLIGHT))
	highlight:SetVertexColor(1, 1, 1)
	highlight:ClearAllPoints()
	highlight:SetPoint("TOPLEFT", 0, 0)
	highlight:SetPoint("BOTTOMRIGHT", 0, 0)
end

local function setNormalHook(button)
	if button.Indicator then
		button.Indicator:SetPoint("BOTTOMLEFT", 5, 5)
		button.Indicator:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", -4, 7)
	end
end

local function setPushedHook(button)
	if button.Indicator then
		button.Indicator:SetPoint("BOTTOMLEFT", 6, 3)
		button.Indicator:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", -3, 6)
	end
end

local button_proto = {}

function button_proto:OnEnterOverride()
	if not KeybindFrames_InQuickKeybindMode() then
		local p, rP, x, y = E:GetTooltipPoint(self._parent)

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, x, y)
		GameTooltip:SetText(self.tooltipText or "", 1, 1, 1, 1)

		if not self:IsEnabled() and (self.minLevel or self.disabledTooltip or self.factionGroup) then
			local r, g, b = C.db.global.colors.red:GetRGB()

			if self.factionGroup == "Neutral" then
				GameTooltip:AddLine(_G.FEATURE_NOT_AVAILBLE_NEUTRAL, r, g, b, true)
			elseif self.minLevel then
				GameTooltip:AddLine(_G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL:format(self.minLevel), r, g, b, true)
			elseif self.disabledTooltip then
				GameTooltip:AddLine(GetValueOrCallFunction(self, "disabledTooltip"), r, g, b, true)
			end
		end

		GameTooltip:Show()
	else
		self:QuickKeybindButtonOnEnter()
	end
end

function button_proto:UpdateConfig()
	self._config = E:CopyTable(C.db.profile.bars.micromenu.buttons[self._id], self._config)
end

function button_proto:UpdateVisibility()
	if self._config.enabled then
		self:Show()
		self:SetParent(self._parent)

		activeButtons[self:GetID()] = self
	else
		self:Hide()
		self:SetParent(E.HIDDEN_PARENT)

		activeButtons[self:GetID()] = nil
	end
end

function button_proto:UpdateEvents()
	self:UnregisterAllEvents()

	if self._config.enabled then
		for event in next, BUTTONS[self._id].events do
			self:RegisterEvent(event)
		end

		self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
		self:RegisterEvent("UPDATE_BINDINGS")
	end
end

function button_proto:Update()
	self:UpdateConfig()
	self:UpdateVisibility()
	self:UpdateEvents()
end

local function handleMicroButton(button, useBlizz)
	Mixin(button, button_proto)

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:UnregisterAllEvents()
	button:SetScript("OnEnter", button.OnEnterOverride)
	button:SetScript("OnUpdate", nil)

	if useBlizz then
		hooksecurefunc(button, "SetNormal", setNormalHook)
		hooksecurefunc(button, "SetPushed", setPushedHook)
	else
		button:SetSize(36 / 2, 48 / 2)
		button:SetHitRectInsets(0, 0, 0, 0)

		updateNormalTexture(button)
		updatePushedTexture(button)
		updateDisabledTexture(button)
		updateHighlightTexture(button)

		hooksecurefunc(button, "SetHighlightAtlas", updateHighlightTexture)

		local border = button:CreateTexture(nil, "BORDER")
		border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")
		border:SetTexCoord(unpack(TEXTURE_COORDS.BORDER))
		border:SetVertexColor(0, 0, 0)
		border:SetPoint("TOPLEFT", -2, 2)
		border:SetPoint("BOTTOMRIGHT", 2, -2)
		button.Border = border

		local flash = button.FlashBorder
		flash:SetDrawLayer("OVERLAY", 2)
		flash:SetTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")
		flash:SetTexCoord(unpack(TEXTURE_COORDS.BORDER))
		flash:SetVertexColor(242 / 255, 228 / 255, 165 / 255)
		flash:ClearAllPoints()
		flash:SetPoint("TOPLEFT", -2, 2)
		flash:SetPoint("BOTTOMRIGHT", 2, -2)

		if button.FlashContent then
			E:ForceHide(button.FlashContent)
		end

		local icon = button:CreateTexture(nil, "BACKGROUND", nil, 1)
		icon:SetTexture("Interface\\AddOns\\ls_UI\\assets\\micromenu")
		icon:SetPoint("TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", -1, 1)
		button.Icon = icon

		E:ForceHide(button.Background)
		E:ForceHide(button.PushedBackground)

		if button.Shadow then
			E:ForceHide(button.Shadow)
		end

		if button.Portrait then
			E:ForceHide(button.Portrait)
			E:ForceHide(button.PortraitMask)
		end

		if button.PushedShadow then
			E:ForceHide(button.PushedShadow)
		end

		if button.Emblem then
			E:ForceHide(button.Emblem)
			E:ForceHide(button.HighlightEmblem)
		end
	end
end

local char_button_proto = {}
do
	local DURABILITY_COLON = _G.DURABILITY .. _G.HEADER_COLON

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

	function char_button_proto:OnEnterOverride()
		button_proto.OnEnterOverride(self)

		if self:IsEnabled() then
			if #durabilities > 0 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(DURABILITY_COLON)

				for i = 1, 17 do
					local cur = durabilities[i]
					if cur then
						GameTooltip:AddDoubleLine(slots[i], ("%d%%"):format(cur), 1, 1, 1, E:GetGradientAsRGB(cur / 100, C.db.global.colors.ryg))
					end
				end

				GameTooltip:Show()
			end
		end
	end

	local deferredUpdate, timer

	function char_button_proto:OnEventHook(event)
		if event == "UPDATE_INVENTORY_DURABILITY" then
			if not deferredUpdate then
				deferredUpdate = function()
					self:UpdateIndicator()

					timer = nil
				end
			end

			if not timer then
				timer = C_Timer.NewTimer(1, deferredUpdate)
			end
		end
	end

	function char_button_proto:Update()
		button_proto.Update(self)

		if self._config.tooltip then
			self:SetScript("OnEnter", self.OnEnterOverride)
		else
			self:SetScript("OnEnter", button_proto.OnEnterOverride)
		end

		self:UpdateIndicator()
	end

	function char_button_proto:UpdateIndicator()
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

		self.Indicator:SetVertexColor(E:GetGradientAsRGB(minDurability / 100, C.db.global.colors.ryg))

		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()

			self:OnEnterOverride()
		end
	end
end

local quest_button_proto = {}
do
	function quest_button_proto:OnEnterOverride()
		button_proto.OnEnterOverride(self)

		if self:IsEnabled() then
			GameTooltip:AddLine(L["DAILY_QUEST_RESET_TIME_TOOLTIP"]:format(SecondsToTime(GetQuestResetTime())))
			GameTooltip:Show()
		end
	end

	function quest_button_proto:Update()
		button_proto.Update(self)

		if self._config.tooltip then
			self:SetScript("OnEnter", self.OnEnterOverride)
		else
			self:SetScript("OnEnter", button_proto.OnEnterOverride)
		end
	end
end

local lfd_button_proto = {}
do
	-- C.db isn't available yet, but these are static colours, so whatevs..
	local DAMAGER = D.global.colors.red:WrapTextInColorCode(_G.DAMAGER)
	local HEALER = D.global.colors.green:WrapTextInColorCode(_G.HEALER)
	local TANK = D.global.colors.blue:WrapTextInColorCode(_G.TANK)

	local cta = {
		tank = {},
		healer = {},
		damager = {},
		total = 0
	}
	local ROLES = {"tank", "healer", "damager"}
	local ROLE_NAMES = {
		damager = DAMAGER,
		healer = HEALER,
		tank = TANK,
	}

	local function fetchCTAData(dungeonID, dungeonName, shortageRole, shortageIndex, numRewards)
		cta[shortageRole][dungeonID] = cta[shortageRole][dungeonID] or {}
		cta[shortageRole][dungeonID].name = dungeonName

		for rewardIndex = 1, numRewards do
			local name, texture, quantity = GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, rewardIndex)

			if not name or name == "" then
				name = _G.UNKNOWN
				texture = texture or QUESTION_MARK_ICON
			end

			cta[shortageRole][dungeonID][rewardIndex] = {
				name = name,
				texture = "|T" .. texture .. ":0|t",
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

	function lfd_button_proto:OnEnterOverride()
		button_proto.OnEnterOverride(self)

		if self:IsEnabled() then
			local gray = C.db.global.colors.gray

			for _, role in next, ROLES do
				local hasTitle = false

				for _, v in next, cta[role] do
					if v then
						if not hasTitle then
							GameTooltip:AddLine(" ")
							GameTooltip:AddLine(_G.LFG_CALL_TO_ARMS:format(ROLE_NAMES[role]))

							hasTitle = true
						end

						GameTooltip:AddLine(v.name, 1, 1, 1)

						for i = 1, #v do
							GameTooltip:AddDoubleLine(v[i].name, v[i].quantity .. v[i].texture, gray.r, gray.g, gray.b, gray.r, gray.g, gray.b)
						end
					end
				end
			end

			GameTooltip:Show()
		end
	end

	function lfd_button_proto:OnEventHook(event)
		if event == "LFG_LOCK_INFO_RECEIVED" then
			if GetTime() - (self.lastUpdate or 0) > 9 then
				self:UpdateIndicator()
				self.lastUpdate = GetTime()
			end
		end
	end

	function lfd_button_proto:Update()
		button_proto.Update(self)

		if self._config.enabled and self._config.tooltip then
			self:SetScript("OnEnter", self.OnEnterOverride)

			self.Ticker = C_Timer.NewTicker(15, function()
				RequestLFDPlayerLockInfo()
				RequestLFDPartyLockInfo()
			end)
		else
			self:SetScript("OnEnter", button_proto.OnEnterOverride)

			if self.Ticker then
				self.Ticker:Cancel()
				self.Ticker = nil
			end
		end

		self:UpdateIndicator()
	end

	function lfd_button_proto:UpdateIndicator()
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

		self.FlashBorder:SetShown(cta.total > 0)

		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()

			self:OnEnterOverride()
		end
	end
end

local ej_button_proto = {}
do
	local isInfoRequested = false

	local lockouts = {}
	local instanceNames = {}
	local instanceResets = {}

	local EXPIRATION_FORMAT = _G.RAID_INSTANCE_EXPIRES .. _G.HEADER_COLON
	local WORLD_BOSS = _G.RAID_INFO_WORLD_BOSS
	local WORLD_BOSS_ID = 172
	local WORLD_BOSS_PROGRESS = "1 / 1"

	local function difficultySortFunc(a, b)
		return a[1] < b[1]
	end

	function ej_button_proto:OnEnterOverride()
		button_proto.OnEnterOverride(self)

		if self:IsEnabled() then
			if not isInfoRequested then
				RequestRaidInfo()

				isInfoRequested = true
			end

			local gray = C.db.global.colors.gray

			for _, instanceReset in next, instanceResets do
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(EXPIRATION_FORMAT:format(SecondsToTime(instanceReset, true, nil, 3)))

				for _, instanceName in ipairs(instanceNames) do
					local resetData = lockouts[instanceReset][instanceName]
					if resetData then
						GameTooltip:AddLine(instanceName, 1, 1, 1)

						-- it's easier to sort on demand here
						t_sort(resetData, difficultySortFunc)

						for _, difficultyData in ipairs(resetData) do
							GameTooltip:AddDoubleLine(difficultyData[2], difficultyData[3], gray.r, gray.g, gray.b, difficultyData[4].r, difficultyData[4].g, difficultyData[4].b)
						end
					end
				end
			end

			GameTooltip:Show()
		end
	end

	function ej_button_proto:OnEventHook(event)
		if event == "UPDATE_INSTANCE_INFO" then
			local savedInstances = GetNumSavedInstances()
			local savedWorldBosses = GetNumSavedWorldBosses()

			if savedInstances + savedWorldBosses > 0 then
				t_wipe(lockouts)
				t_wipe(instanceNames)
				t_wipe(instanceResets)

				for i = 1, savedInstances + savedWorldBosses do
					if i <= savedInstances then
						local instanceName, _, instanceReset, difficultyID, _, _, _, _, _, difficultyName, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)
						if instanceReset > 0 then
							if not lockouts[instanceReset] then
								lockouts[instanceReset] = {}

								t_insert(instanceResets, instanceReset)
							end

							if not lockouts[instanceReset][instanceName] then
								lockouts[instanceReset][instanceName] = {}

								-- the same instance can have multiple resets because heroics reset daily, but mythics reset weekly
								if not instanceNames[instanceName] then

									instanceNames[instanceName] = true
									t_insert(instanceNames, instanceName)
								end
							end

							t_insert(lockouts[instanceReset][instanceName], {
								difficultyID,
								difficultyName,
								encounterProgress .. " / " .. numEncounters,
								encounterProgress == numEncounters and C.db.global.colors.red or C.db.global.colors.green,
							})
						end
					else
						local instanceName, _, instanceReset = GetSavedWorldBossInfo(i - savedInstances)
						if instanceReset > 0 then
							-- there's some desync between instance and WB reset timers, sometimes it can be as bad as 600s
							for _, reset in next, instanceResets do
								if m_abs(reset - instanceReset) <= 600 then
									instanceReset = reset

									break
								end
							end

							if not lockouts[instanceReset] then
								lockouts[instanceReset] = {}

								t_insert(instanceResets, instanceReset)
							end

							if not lockouts[instanceReset][instanceName] then
								lockouts[instanceReset][instanceName] = {}

								if not instanceNames[instanceName] then

									instanceNames[instanceName] = true
									t_insert(instanceNames, instanceName)
								end
							end

							t_insert(lockouts[instanceReset][instanceName], {
								WORLD_BOSS_ID,
								WORLD_BOSS,
								WORLD_BOSS_PROGRESS,
								C.db.global.colors.red,
							})
						end
					end
				end

				t_sort(instanceNames)
				t_sort(instanceResets)
			end

			if GameTooltip:IsOwned(self) then
				self:OnEnterOverride()
			end
		end
	end

	function ej_button_proto:OnLeaveHook()
		isInfoRequested = false
	end

	function ej_button_proto:Update()
		button_proto.Update(self)

		if self._config.tooltip then
			self:SetScript("OnEnter", self.OnEnterOverride)
		else
			self:SetScript("OnEnter", button_proto.OnEnterOverride)
		end
	end
end

local main_button_proto = {}
do
	local cache = {}
	local addOns = {}
	local memUsage = 0
	local latencyHome, latencyWorld = 0, 0
	local MED_LATENCY = 600
	local LATENCY_COLON = L["LATENCY"] .. _G.HEADER_COLON
	local LATENCY_TEMPLATE = "|c%s%s|r " .. _G.MILLISECONDS_ABBR
	local MEMORY_COLON = L["MEMORY"] .. _G.HEADER_COLON
	local MEMORY_TEMPLATE = "%.2f MiB"
	local _

	local function sortFunc(a, b)
		return a[2] > b[2]
	end

	function main_button_proto:OnEnterOverride()
		button_proto.OnEnterOverride(self)

		if self:IsEnabled() then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(LATENCY_COLON)
			GameTooltip:AddDoubleLine(L["LATENCY_HOME"], LATENCY_TEMPLATE:format(E:GetGradientAsHex(latencyHome / MED_LATENCY, C.db.global.colors.gyr), latencyHome), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["LATENCY_WORLD"], LATENCY_TEMPLATE:format(E:GetGradientAsHex(latencyWorld / MED_LATENCY, C.db.global.colors.gyr), latencyWorld), 1, 1, 1)

			if IsShiftKeyDown() then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(MEMORY_COLON)

				UpdateAddOnMemoryUsage()

				for i = 1, C_AddOns.GetNumAddOns() do
					if C_AddOns.IsAddOnLoaded(i) then
						if not cache[i] then
							cache[i] = {
								[1] = select(2, C_AddOns.GetAddOnInfo(i)),
							}
						end

						cache[i][2] = GetAddOnMemoryUsage(i)
					end
				end

				t_wipe(addOns)
				memUsage = 0

				for i, data in next, cache do
					t_insert(addOns, {i, data[2]})

					memUsage = memUsage + data[2]
				end

				if memUsage > 0 then
					t_sort(addOns, sortFunc)

					for i = 1, #addOns do
						local m = addOns[i][2]

						GameTooltip:AddDoubleLine(cache[addOns[i][1]][1], MEMORY_TEMPLATE:format(m / 1024), 1, 1, 1, E:GetGradientAsRGB(m / (memUsage == m and 1 or (memUsage - m)), C.db.global.colors.gyr))
					end

					GameTooltip:AddDoubleLine(_G.TOTAL, MEMORY_TEMPLATE:format(memUsage / 1024))
				end
			else
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["MAINMENU_BUTTON_HOLD_TOOLTIP"])
			end

			GameTooltip:Show()
		end
	end

	function main_button_proto:OnEventOverride(event)
		if event == "MODIFIER_STATE_CHANGED" then
			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide()

				self:OnEnterOverride()
			end
		elseif event == "UPDATE_BINDINGS" then
			self.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
		end
	end

	function main_button_proto:Update()
		button_proto.Update(self)

		if self._config.enabled and self._config.tooltip then
			self:SetScript("OnEnter", self.OnEnterOverride)

			self.Ticker = C_Timer.NewTicker(30, function()
				self:UpdateIndicator()
			end)
		else
			self:SetScript("OnEnter", button_proto.OnEnterOverride)

			if self.Ticker then
				self.Ticker:Cancel()
				self.Ticker = nil
			end
		end

		self:UpdateIndicator()
	end

	function main_button_proto:UpdateIndicator()
		_, _, latencyHome, latencyWorld = GetNetStats()
		self.Indicator:SetVertexColor(E:GetGradientAsRGB(latencyWorld / MED_LATENCY, C.db.global.colors.gyr))
	end
end

local function buttonSort(a, b)
	return a:GetID() < b:GetID()
end

local CFG_OVERRIDE = {
	width = 32,
	height = 40,
	spacing = -4,
}

local bar_proto = {
	UpdateCooldownConfig = E.NOOP,
}

function bar_proto:Update()
	self:UpdateConfig()
	self:ForEach("Update")
	self:ForEach("UpdateEvents")
	self:UpdateButtonList()
	self:UpdateFading()
	self:UpdateLayout()
end

function bar_proto:UpdateConfig()
	self._config = E:CopyTable(C.db.profile.bars.micromenu, self._config)

	if PrC.db.profile.bars.micromenu.blizz_enabled then
		self._config = E:CopyTable(CFG_OVERRIDE, self._config)
	end
end

function bar_proto:UpdateButtonList()
	t_wipe(self._buttons)

	for _, button in next, activeButtons do
		if button._config.enabled then
			t_insert(self._buttons, button)
		end
	end

	t_sort(self._buttons, buttonSort)
end

local function updateMicroButtons()
	if isInit then
		for _, button in next, buttons do
			button:SetShown(button._config.enabled)
		end
	end
end

local function repositionAlert(button)
	if not C.db.profile.bars.micromenu.helptips then return end

	for alert in HelpTip.framePool:EnumerateActive() do
		if button and alert.relativeRegion == button and alert:Matches(UIParent) then
			alert.info.autoEdgeFlipping = true
			alert.info.autoHorizontalSlide = true
			alert.flippedTargetPoint = HelpTip.PointInfo[alert.info.targetPoint].oppositePoint

			alert:SetScript("OnUpdate", function()
				alert:OnUpdate()
			end)
		end
	end
end

local MICRO_BUTTONS = {
	[AchievementMicroButton] = true,
	[CharacterMicroButton] = true,
	[CollectionsMicroButton] = true,
	[EJMicroButton] = true,
	[GuildMicroButton] = true,
	[HelpMicroButton] = true,
	[LFDMicroButton] = true,
	[MainMenuMicroButton] = true,
	[PlayerSpellsMicroButton] = true,
	[ProfessionMicroButton] = true,
	[QuestLogMicroButton] = true,
	[StoreMicroButton] = true,
}

local function hideHelpTips(self)
	if C.db.profile.bars.micromenu.helptips then return end

	for frame in self.framePool:EnumerateActive() do
		if MICRO_BUTTONS[frame.relativeRegion] then
			frame:Hide()
		end
	end
end

function MODULE:HasMicroMenu()
	return isInit
end

function MODULE:CreateMicroMenu()
	if not isInit then
		local bar = Mixin(self:Create("micromenu", "LSMicroMenu"), bar_proto)

		for id, data in next, BUTTONS do
			local button = _G[data.name] or CreateFrame("Button", data.name, UIParent, "MainMenuBarMicroButton")
			button:SetID(idToIndex[id])
			button._id = id
			button._parent = bar

			handleMicroButton(button, PrC.db.profile.bars.micromenu.blizz_enabled)

			if not PrC.db.profile.bars.micromenu.blizz_enabled then
				button.Icon:SetTexCoord(unpack(TEXTURE_COORDS[data.icon]))
			end

			if id == "character" then
				if PrC.db.profile.bars.micromenu.blizz_enabled then
					data.events.PORTRAITS_UPDATED = true
					data.events.UNIT_PORTRAIT_UPDATE = true
				end

				Mixin(button, char_button_proto)
				button:HookScript("OnEvent", button.OnEventHook)

				button.Indicator = createButtonIndicator(button)
			-- elseif id == "spellbook" then
			-- elseif id == "talent" then
			-- elseif id == "achievement" then
			elseif id == "quest" then
				Mixin(button, quest_button_proto)
				-- elseif id == "guild" then
			elseif id == "lfd" then
				Mixin(button, lfd_button_proto)
				button:HookScript("OnEvent", button.OnEventHook)
			-- elseif id == "collection" then
			elseif id == "ej" then
				Mixin(button, ej_button_proto)
				button:HookScript("OnEvent", button.OnEventHook)
				button:HookScript("OnLeave", button.OnLeaveHook)
			-- -- elseif id == "store" then
			elseif id == "main" then
				Mixin(button, main_button_proto)
				button:SetScript("OnEvent", button.OnEventOverride)

				button.tooltipText = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
				button.Indicator = createButtonIndicator(button, button.MainMenuBarPerformanceBar)
			-- elseif id == "help" then
			end

			buttons[idToIndex[id]] = button
		end

		hooksecurefunc("UpdateMicroButtons", updateMicroButtons)
		hooksecurefunc("MainMenuMicroButton_ShowAlert", repositionAlert)
		hooksecurefunc(HelpTip, "Show", hideHelpTips)

		bar:SetPoint(unpack(C.db.profile.bars.micromenu.point))
		E.Movers:Create(bar)

		E:RegisterEvent("PLAYER_ENTERING_WORLD", function()
			for _, name in next, ALERTS do
				repositionAlert(_G[name])
			end

			hideHelpTips(HelpTip)
		end)

		isInit = true

		self:UpdateMicroMenu()
	end
end

function MODULE:UpdateMicroMenu()
	if isInit then
		for _, button in next, buttons do
			button:Update()
		end

		self:For("micromenu", "Update")
	end
end

function MODULE:ForMicroButton(id, method, ...)
	local button = buttons[idToIndex[id]]
	if button and button[method] then
		button[method](button, ...)
	end
end

function MODULE:HideHelpTips()
	hideHelpTips(HelpTip)
end
