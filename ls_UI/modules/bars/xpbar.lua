local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local collectgarbage = _G.collectgarbage
local debugprofilestop = _G.debugprofilestop
local hooksecurefunc = _G.hooksecurefunc
local unpack = _G.unpack

-- Mine
local isInit = false
local barValueTemplate

local MAX_SEGMENTS = 4
local REPUTATION_TEMPLATE = "%s: %s"
local CUR_MAX_VALUE_TEMPLATE = "%s / %s"
local CUR_MAX_PERC_VALUE_TEMPLATE = "%s / %s (%.1f%%)"
local DEFAULT_TEXTURE = "Interface\\BUTTONS\\WHITE8X8"
local AZERITE_TEXTURE = "Interface\\AddOns\\ls_UI\\assets\\statusbar-azerite-fill"

local CFG = {
	visible = true,
	width = 594,
	height = 12,
	fade = {
		enabled = false,
		ooc = false,
		out_delay = 0.75,
		out_duration = 0.15,
		in_duration = 0.15,
		min_alpha = 0,
		max_alpha = 1,
	},
	point = {"BOTTOM", "UIParent", "BOTTOM", 0, 4},
}

local LAYOUT = {
	[1] = {[1] = {},},
	[2] = {[1] = {}, [2] = {},},
	[3] = {[1] = {}, [2] = {}, [3] = {},},
	[4] = {[1] = {}, [2] = {}, [3] = {}, [4] = {}},
}

local bar_proto = {
	UpdateCooldownConfig = E.NOOP,
}

function bar_proto:ForEach(method, ...)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for i = 1, MAX_SEGMENTS do
		if self[i][method] then
			self[i][method](self[i], ...)
		end
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "ForEach", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function bar_proto:Update()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self:UpdateConfig()
	self:UpdateFont()
	self:UpdateTextFormat()
	self:UpdateTextVisibility()
	self:UpdateSize(self._config.width, self._config.height)
	self:UpdateFading()

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "Update", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function bar_proto:UpdateConfig()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self._config = E:CopyTable(BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar, self._config)

	if BARS:IsRestricted() then
		self._config.text = E:CopyTable(C.db.profile.bars.xpbar.text, self._config.text)
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateConfig", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function bar_proto:UpdateFont()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for i = 1, MAX_SEGMENTS do
		self[i].Text:UpdateFont(self._config.text.size)
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateFont", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function bar_proto:UpdateTextFormat()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if self._config.text.format == "NUM" then
		barValueTemplate = CUR_MAX_VALUE_TEMPLATE
	elseif self._config.text.format == "NUM_PERC" then
		barValueTemplate = CUR_MAX_PERC_VALUE_TEMPLATE
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateTextFormat", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function bar_proto:UpdateTextVisibility()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for i = 1, MAX_SEGMENTS do
		self[i]:LockText(self._config.text.visibility == 1)
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateTextVisibility", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function bar_proto:UpdateSize(width, height)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	width = width or self._config.width
	height = height or self._config.height

	for i = 1, MAX_SEGMENTS do
		local layout = E:CalcSegmentsSizes(width, 2, i)

		for j = 1, i do
			LAYOUT[i][j].size = {layout[j], height}
		end
	end

	self:SetSize(width, height)

	if not BARS:IsRestricted() then
		E.Movers:Get(self):UpdateSize(width, height)
	end

	if not BARS:IsRestricted() then
		E:SetStatusBarSkin(self.TexParent, "HORIZONTAL-" .. height)
	end

	self._total = nil

	self:UpdateSegments()

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateSize", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function bar_proto:UpdateSegments()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local index = 0

	if C_PetBattles.IsInBattle() then
		local i = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally)
		local level = C_PetBattles.GetLevel(Enum.BattlePetOwner.Ally, i)
		if level and level < 25 then
			index = index + 1

			self[index]:UpdatePetXP(i, level)
		end
	else
		-- Azerite
		if not C_AzeriteItem.IsAzeriteItemAtMaxLevel() then
			local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
			if azeriteItem and azeriteItem:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem) then
				index = index + 1

				self[index]:UpdateAzerite(azeriteItem)
			end
		end

		-- XP
		if not IsXPUserDisabled() and not IsPlayerAtEffectiveMaxLevel() then
			index = index + 1

			self[index]:UpdateXP()
		end

		-- Honour
		if IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP() then
			index = index + 1

			self[index]:UpdateHonor()
		end

		-- Reputation
		local name, standing, repMin, repMax, repCur, factionID = GetWatchedFactionInfo()
		if name then
			index = index + 1

			self[index]:UpdateReputation(name, standing, repMin, repMax, repCur, factionID)
		end
	end

	if self._total ~= index then
		for i = 1, MAX_SEGMENTS do
			if i <= index then
				self[i]:SetSize(unpack(LAYOUT[index][i].size))
				self[i]:Show()

				if i == 1 then
					self[i]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
				else
					self[i]:SetPoint("TOPLEFT", self[i - 1], "TOPRIGHT", 2, 0)
				end

				self[i].Extension:SetSize(unpack(LAYOUT[index][i].size))
			else
				self[i]:SetMinMaxValues(0, 1)
				self[i]:SetValue(0)
				self[i]:ClearAllPoints()
				self[i]:Hide()

				self[i].Extension:SetMinMaxValues(0, 1)
				self[i].Extension:SetValue(0)

				self[i].tooltipInfo = nil
			end
		end

		for i = 1, MAX_SEGMENTS - 1 do
			if i <= index - 1 then
				self[i].Sep:Show()
			else
				self[i].Sep:Hide()
			end
		end

		if index == 0 then
			self[1]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			self[1]:SetSize(unpack(LAYOUT[1][1].size))
			self[1]:SetMinMaxValues(0, 1)
			self[1]:SetValue(1)
			self[1]:Show()
			self[1]:UpdateText(1, 1)
			self[1]:SetStatusBarTexture(DEFAULT_TEXTURE)
			self[1].Texture:SetVertexColor(C.db.global.colors.class[E.PLAYER_CLASS]:GetRGB())
		end

		self._total = index
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateSegments", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function bar_proto:OnEvent(event, ...)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if event == "UNIT_INVENTORY_CHANGED" then
		local unit = ...
		if unit == "player" then
			self:UpdateSegments()
		end
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local slot = ...
		if slot == Enum.InventoryType.IndexNeckType then
			self:UpdateSegments()
		end
	else
		self:UpdateSegments()
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "OnEvent", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local segment_proto = {}

function segment_proto:OnEnter()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if self.tooltipInfo then
		local quadrant = E:GetScreenQuadrant(self)
		local p, rP, sign = "BOTTOMLEFT", "TOPLEFT", 1

		if quadrant == "TOPLEFT" or quadrant == "TOP" or quadrant == "TOPRIGHT" then
			p, rP, sign = "TOPLEFT", "BOTTOMLEFT", -1
		end

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(p, self, rP, 0, sign * 2)
		GameTooltip:AddLine(self.tooltipInfo.header, 1, 1, 1)
		GameTooltip:AddLine(self.tooltipInfo.line1)

		if self.tooltipInfo.line2 then
			GameTooltip:AddLine(self.tooltipInfo.line2)
		end

		if self.tooltipInfo.line3 then
			GameTooltip:AddLine(self.tooltipInfo.line3)
		end

		GameTooltip:Show()
	end

	if not self:IsTextLocked() then
		self.Text:Show()
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "OnEnter", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:OnLeave()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	GameTooltip:Hide()

	if not self:IsTextLocked() then
		self.Text:Hide()
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "OnLeave", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:Update(cur, max, bonus, color, texture)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self:SetStatusBarTexture(texture or DEFAULT_TEXTURE)
	self.Texture:SetVertexColor(color:GetRGBA(1))

	self.Extension:SetStatusBarTexture(texture or DEFAULT_TEXTURE)
	self.Extension.Texture:SetVertexColor(color:GetRGBA(0.4))

	if self._value ~= cur or self._max ~= max then
		self:SetMinMaxValues(0, max)
		self:SetValue(cur)
		self:UpdateText(cur, max)
	end

	if self._bonus ~= bonus then
		if bonus and bonus > 0 then
			if cur + bonus > max then
				bonus = max - cur
			end
			self.Extension:SetMinMaxValues(0, max)
			self.Extension:SetValue(bonus)
		else
			self.Extension:SetMinMaxValues(0, 1)
			self.Extension:SetValue(0)
		end

		self._bonus = bonus
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "Update", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:UpdateAzerite(item)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(item)
	local level = C_AzeriteItem.GetPowerLevel(item)

	self.tooltipInfo = {
		header = L["ARTIFACT_POWER"],
		line1 = L["ARTIFACT_LEVEL_TOOLTIP"]:format(level),
	}

	self:Update(cur, max, 0, C.db.global.colors.white, AZERITE_TEXTURE)

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateAzerite", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:UpdateXP()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local cur, max = UnitXP("player"), UnitXPMax("player")
	local bonus = GetXPExhaustion() or 0

	self.tooltipInfo = {
		header = L["EXPERIENCE"],
		line1 = L["LEVEL_TOOLTIP"]:format(UnitLevel("player")),
	}

	if bonus > 0 then
		self.tooltipInfo.line2 = L["BONUS_XP_TOOLTIP"]:format(BreakUpLargeNumbers(bonus))
	else
		self.tooltipInfo.line2 = nil
	end

	self:Update(cur, max, bonus, bonus > 0 and C.db.global.colors.xp[1] or C.db.global.colors.xp[2])

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateXP", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:UpdateHonor()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local cur, max = UnitHonor("player"), UnitHonorMax("player")

	self.tooltipInfo = {
		header = L["HONOR"],
		line1 = L["HONOR_LEVEL_TOOLTIP"]:format(UnitHonorLevel("player")),
	}

	self:Update(cur, max, 0, C.db.global.colors.faction[UnitFactionGroup("player")])

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateHonor", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:UpdateReputation(name, standing, repMin, repMax, repCur, factionID)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local repTextLevel = GetText("FACTION_STANDING_LABEL" .. standing, UnitSex("player"))
	local isParagon, rewardQuestID, hasRewardPending
	local cur, max

	local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
	if repInfo and repInfo.friendshipFactionID > 0 then
		if repInfo.nextThreshold then
			max, cur = repInfo.nextThreshold - repInfo.reactionThreshold, repInfo.standing - repInfo.reactionThreshold
		else
			max, cur = 1, 1
		end

		standing = 5
		repTextLevel = repInfo.reaction
	elseif C_Reputation.IsMajorFaction(factionID) then
		repInfo = C_MajorFactions.GetMajorFactionData(factionID)

		if C_MajorFactions.HasMaximumRenown(factionID) then
			max, cur = 1, 1
		else
			max, cur = repInfo.renownLevelThreshold, repInfo.renownReputationEarned
		end

		standing = 9
		repTextLevel = RENOWN_LEVEL_LABEL .. repInfo.renownLevel
	else
		if standing ~= MAX_REPUTATION_REACTION then
			max, cur = repMax - repMin, repCur - repMin
		else
			isParagon = C_Reputation.IsFactionParagon(factionID)
			if isParagon then
				cur, max, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
				cur = cur % max
				repTextLevel = repTextLevel .. "+"

				if hasRewardPending then
					cur = cur + max
				end
			else
				max, cur = 1, 1
			end
		end
	end

	self.tooltipInfo = {
		header = L["REPUTATION"],
		line1 = REPUTATION_TEMPLATE:format(name, C.db.global.colors.reaction[standing]:WrapTextInColorCode(repTextLevel)),
	}

	if isParagon and hasRewardPending then
		local text = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(rewardQuestID))
		if text and text ~= "" then
			self.tooltipInfo.line3 = text
		end
	else
		self.tooltipInfo.line3 = nil
	end

	self:Update(cur, max, 0, C.db.global.colors.reaction[standing])

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdateReputation", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:UpdatePetXP(i, level)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local name = C_PetBattles.GetName(1, i)
	local rarity = C_PetBattles.GetBreedQuality(1, i)
	local cur, max = C_PetBattles.GetXP(1, i)

	self.tooltipInfo = {
		header = C.db.global.colors.quality[rarity - 1]:WrapTextInColorCode(name),
		line1 = L["LEVEL_TOOLTIP"]:format(level),
	}

	self:Update(cur, max, 0, C.db.global.colors.xp[2])

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdatePetXP", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:UpdateText(cur, max)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	cur = cur or self._value or 1
	max = max or self._max or 1

	if cur == 1 and max == 1 then
		self.Text:SetText(nil)
	else
		self.Text:SetFormattedText(barValueTemplate, E:FormatNumber(cur), E:FormatNumber(max), E:NumberToPerc(cur, max))
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "UpdatePetXP", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:LockText(isLocked)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if self.textLocked ~= isLocked then
		self.textLocked = isLocked
		self.Text:SetShown(isLocked)
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "LockText", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function segment_proto:IsTextLocked()
	return self.textLocked
end

function BARS:HasXPBar()
	return isInit
end

function BARS:CreateXPBar()
	if not isInit and (PrC.db.profile.bars.xpbar.enabled or BARS:IsRestricted()) then
		local bar = Mixin(self:Create("xpbar", "LSUIXPBar", true), bar_proto)

		local texParent = CreateFrame("Frame", nil, bar)
		texParent:SetAllPoints()
		texParent:SetFrameLevel(bar:GetFrameLevel() + 3)
		bar.TexParent = texParent

		local textParent = CreateFrame("Frame", nil, bar)
		textParent:SetAllPoints()
		textParent:SetFrameLevel(bar:GetFrameLevel() + 5)

		local bg = bar:CreateTexture(nil, "ARTWORK")
		bg:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
		bg:SetHorizTile(true)
		bg:SetVertTile(true)
		bg:SetAllPoints()

		for i = 1, MAX_SEGMENTS do
			local segment = Mixin(CreateFrame("StatusBar", "$parentSegment" .. i, bar), segment_proto)
			segment:SetFrameLevel(bar:GetFrameLevel() + 1)
			segment:SetStatusBarTexture(DEFAULT_TEXTURE)
			segment:SetHitRectInsets(0, 0, -4, -4)
			segment:SetClipsChildren(true)
			segment:SetScript("OnEnter", segment.OnEnter)
			segment:SetScript("OnLeave", segment.OnLeave)
			segment:Hide()
			E:SmoothBar(segment)
			bar[i] = segment

			segment.Texture = segment:GetStatusBarTexture()
			E:SmoothColor(segment.Texture)

			local ext = CreateFrame("StatusBar", nil, segment)
			ext:SetFrameLevel(segment:GetFrameLevel())
			ext:SetStatusBarTexture(DEFAULT_TEXTURE)
			ext:SetPoint("TOPLEFT", segment.Texture, "TOPRIGHT")
			ext:SetPoint("BOTTOMLEFT", segment.Texture, "BOTTOMRIGHT")
			E:SmoothBar(ext)
			segment.Extension = ext

			ext.Texture = ext:GetStatusBarTexture()
			E:SmoothColor(ext.Texture)

			local text = textParent:CreateFontString(nil, "OVERLAY")
			E.FontStrings:Capture(text, "statusbar")
			text:SetWordWrap(false)
			text:SetAllPoints(segment)
			text:Hide()
			segment.Text = text
		end

		for i = 1, MAX_SEGMENTS - 1 do
			local sep = texParent:CreateTexture(nil, "ARTWORK", nil, -7)
			sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
			sep:SetVertTile(true)
			sep:SetTexCoord(2 / 16, 14 / 16, 0 / 8, 8 / 8)
			sep:SetSize(12 / 2, 0)
			sep:SetPoint("TOP", 0, 0)
			sep:SetPoint("BOTTOM", 0, 0)
			sep:SetPoint("LEFT", bar[i], "RIGHT", -2, 0)
			sep:SetSnapToPixelGrid(false)
			sep:SetTexelSnappingBias(0)
			sep:Hide()
			bar[i].Sep = sep
		end

		bar:SetScript("OnEvent", bar.OnEvent)
		-- all
		bar:RegisterEvent("PET_BATTLE_CLOSE")
		bar:RegisterEvent("PET_BATTLE_OPENING_START")
		bar:RegisterEvent("PLAYER_UPDATE_RESTING")
		bar:RegisterEvent("UPDATE_EXHAUSTION")
		-- honour
		bar:RegisterEvent("HONOR_XP_UPDATE")
		bar:RegisterEvent("ZONE_CHANGED")
		bar:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		-- azerite
		bar:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
		bar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		-- xp
		bar:RegisterEvent("DISABLE_XP_GAIN")
		bar:RegisterEvent("ENABLE_XP_GAIN")
		bar:RegisterEvent("PLAYER_LEVEL_UP")
		bar:RegisterEvent("PLAYER_XP_UPDATE")
		bar:RegisterEvent("UPDATE_EXPANSION_LEVEL")
		-- pet xp
		bar:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
		bar:RegisterEvent("PET_BATTLE_PET_CHANGED")
		bar:RegisterEvent("PET_BATTLE_XP_CHANGED")
		-- rep
		bar:RegisterEvent("UPDATE_FACTION")

		if BARS:IsRestricted() then
			BARS:AddControlledWidget("XP_BAR", bar)
		else
			local config = BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar
			bar:SetPoint(unpack(config.point))
			E.Movers:Create(bar)
		end

		bar:Update()

		-- Honour & Rep Hooks
		-- This way I'm able to show honour and reputation bars simultaneously
		local isHonorBarHooked = false

		hooksecurefunc("UIParentLoadAddOn", function(addOnName)
			if addOnName == "Blizzard_PVPUI" then
				if not isHonorBarHooked then
					PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay:SetScript("OnMouseUp", function()
						if IsShiftKeyDown() then
							if IsWatchingHonorAsXP() then
								PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
								SetWatchingHonorAsXP(false)
							else
								PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
								SetWatchingHonorAsXP(true)
							end

							bar:UpdateSegments()
						end
					end)

					PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay:HookScript("OnEnter", function()
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(L["SHIFT_CLICK_TO_SHOW_AS_XP"])
						GameTooltip:Show()
					end)

					PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay:HookScript("OnLeave", function()
						GameTooltip:Hide()
					end)

					isHonorBarHooked = true
				end
			end
		end)

		ReputationDetailMainScreenCheckBox:SetScript("OnClick", function(self)
			if self:GetChecked() then
				PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
				SetWatchedFactionIndex(GetSelectedFaction())
			else
				PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
				SetWatchedFactionIndex(0)
			end

			bar:UpdateSegments()
		end)

		isInit = true
	end
end
