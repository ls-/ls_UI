local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local unpack = _G.unpack

-- Blizz
local C_ArtifactUI = _G.C_ArtifactUI
local C_AzeriteItem = _G.C_AzeriteItem
local C_PetBattles = _G.C_PetBattles
local C_PvP = _G.C_PvP
local C_QuestLog = _G.C_QuestLog
local C_Reputation = _G.C_Reputation

--[[ luacheck: globals
	ArtifactBarGetNumArtifactTraitsPurchasableFromXP BreakUpLargeNumbers CreateFrame GameTooltip GetFriendshipReputation
	GetHonorExhaustion GetQuestLogCompletionText GetQuestLogIndexByID GetSelectedFaction GetText GetWatchedFactionInfo
	GetXPExhaustion HasArtifactEquipped InActiveBattlefield IsInActiveWorldPVP IsShiftKeyDown IsWatchingHonorAsXP
	IsXPUserDisabled PlaySound PVPQueueFrame ReputationDetailMainScreenCheckBox SetWatchedFactionIndex
	SetWatchingHonorAsXP UIParent UnitFactionGroup UnitHonor UnitHonorLevel UnitHonorMax UnitLevel UnitPrestige UnitSex
	UnitXP UnitXPMax

	LE_BATTLE_PET_ALLY MAX_PLAYER_LEVEL MAX_REPUTATION_REACTION
]]

-- Mine
local isInit = false
local barValueTemplate

local MAX_SEGMENTS = 4
local NAME_TEMPLATE = "|c%s%s|r"
local REPUTATION_TEMPLATE = "%s: |c%s%s|r"
local CUR_MAX_VALUE_TEMPLATE = "%s / %s"
local CUR_MAX_PERC_VALUE_TEMPLATE = "%s / %s (%.1f%%)"

local CFG = {
	visible = true,
	width = 594,
	height = 12,
	point = {
		ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 4},
		traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 4},
	},
	fade = {
		enabled = false,
	},
}

local LAYOUT = {
	[1] = {[1] = {},},
	[2] = {[1] = {}, [2] = {},},
	[3] = {[1] = {}, [2] = {}, [3] = {},},
	[4] = {[1] = {}, [2] = {}, [3] = {}, [4] = {}},
}

local function bar_ForEach(self, method, ...)
	for i = 1, MAX_SEGMENTS do
		if self[i][method] then
			self[i][method](self[i], ...)
		end
	end
end

local function bar_Update(self)
	self:UpdateConfig()

	for i = 1, MAX_SEGMENTS do
		self[i]:UpdateFont(self._config.text.size, self._config.text.flag)
		self[i]:LockText(self._config.text.visibility == 1)
	end

	self:UpdateTextFormat(self._config.text.format)
	self:UpdateSize(self._config.width, self._config.height)

	if not BARS:IsRestricted() then
		self:UpdateFading()
	end
end

local function bar_UpdateConfig(self)
	self._config = E:CopyTable(BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar, self._config)

	if BARS:IsRestricted() then
		self._config.text = E:CopyTable(C.db.profile.bars.xpbar.text, self._config.text)
	end
end

local function bar_UpdateTextFormat(self, format)
	format = format or self._config.text.format

	if format == "NUM" then
		barValueTemplate = CUR_MAX_VALUE_TEMPLATE
	elseif format == "NUM_PERC" then
		barValueTemplate = CUR_MAX_PERC_VALUE_TEMPLATE
	end
end

local function bar_UpdateSize(self, width, height)
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

	for i = 1, MAX_SEGMENTS - 1 do
		self[i].Sep:SetSize(12, height)
		self[i].Sep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, height / 4)
	end

	if not BARS:IsRestricted() then
		E:SetStatusBarSkin(self.TexParent, "HORIZONTAL-" .. height)
	end

	self._total = nil

	self:UpdateSegments()
end

local function bar_UpdateSegments(self)
	local index = 0

	if C_PetBattles.IsInBattle() then
		local i = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY)
		local level = C_PetBattles.GetLevel(LE_BATTLE_PET_ALLY, i)

		if level and level < 25 then
			index = index + 1

			local name = C_PetBattles.GetName(1, i)
			local rarity = C_PetBattles.GetBreedQuality(1, i)
			local cur, max = C_PetBattles.GetXP(1, i)

			self[index].tooltipInfo = {
				header = NAME_TEMPLATE:format(C.db.global.colors.quality[rarity - 1].hex, name),
				line1 = L["LEVEL_TOOLTIP"]:format(level),
			}

			self[index]:Update(cur, max, 0, C.db.global.colors.xp[2])
		end
	else
		-- Artefact
		if HasArtifactEquipped() and not C_ArtifactUI.IsEquippedArtifactMaxed() and not C_ArtifactUI.IsEquippedArtifactDisabled() then
			index = index + 1

			local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, tier = C_ArtifactUI.GetEquippedArtifactInfo()
			local points, cur, max = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, tier)

			self[index].tooltipInfo = {
				header = L["ARTIFACT_POWER"],
				line1 = L["UNSPENT_TRAIT_POINTS_TOOLTIP"]:format(points),
				line2 = L["ARTIFACT_LEVEL_TOOLTIP"]:format(pointsSpent),
			}

			self[index]:Update(cur, max, 0, C.db.global.colors.artifact)
		end

		-- Azerite
		if not C_AzeriteItem.IsAzeriteItemAtMaxLevel or not C_AzeriteItem.IsAzeriteItemAtMaxLevel() then
			local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
			if azeriteItemLocation then
				index = index + 1

				local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
				local level = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)

				self[index].tooltipInfo = {
					header = L["ARTIFACT_POWER"],
					line1 = L["ARTIFACT_LEVEL_TOOLTIP"]:format(level),
				}

				self[index]:Update(cur, max, 0, C.db.global.colors.white, "Interface\\AddOns\\ls_UI\\assets\\statusbar-azerite-fill")
			end
		end

		-- XP
		if not IsXPUserDisabled() and UnitLevel("player") < MAX_PLAYER_LEVEL then
			index = index + 1

			local cur, max = UnitXP("player"), UnitXPMax("player")
			local bonus = GetXPExhaustion() or 0

			self[index].tooltipInfo = {
				header = L["EXPERIENCE"],
				line1 = L["LEVEL_TOOLTIP"]:format(UnitLevel("player")),
			}

			if bonus > 0 then
				self[index].tooltipInfo.line2 = L["BONUS_XP_TOOLTIP"]:format(BreakUpLargeNumbers(bonus))
			else
				self[index].tooltipInfo.line2 = nil
			end

			self[index]:Update(cur, max, bonus, bonus > 0 and C.db.global.colors.xp[1] or C.db.global.colors.xp[2])
		end

		-- Honour
		if IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP() then
			index = index + 1

			local cur, max = UnitHonor("player"), UnitHonorMax("player")

			self[index].tooltipInfo = {
				header = L["HONOR"],
				line1 = L["HONOR_LEVEL_TOOLTIP"]:format(UnitHonorLevel("player")),
			}

			self[index]:Update(cur, max, 0, C.db.global.colors.faction[UnitFactionGroup("player")])
		end

		-- Reputation
		local name, standing, repMin, repMax, repCur, factionID = GetWatchedFactionInfo()
		if name then
			index = index + 1

			local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
			local repTextLevel = GetText("FACTION_STANDING_LABEL" .. standing, UnitSex("player"))
			local isParagon, rewardQuestID, hasRewardPending
			local cur, max

			if friendRep then
				if nextFriendThreshold then
					max, cur = nextFriendThreshold - friendThreshold, friendRep - friendThreshold
				else
					max, cur = 1, 1
				end

				standing = 5
				repTextLevel = friendTextLevel
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

			self[index].tooltipInfo = {
				header = L["REPUTATION"],
				line1 = REPUTATION_TEMPLATE:format(name, C.db.global.colors.reaction[standing].hex, repTextLevel),
			}

			if isParagon and hasRewardPending then
				local text = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(rewardQuestID))

				if text and text ~= "" then
					self[index].tooltipInfo.line3 = text
				end
			else
				self[index].tooltipInfo.line3 = nil
			end

			self[index]:Update(cur, max, 0, C.db.global.colors.reaction[standing])
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
			self[1].Texture:SetVertexColor(E:GetRGB(C.db.global.colors.class[E.PLAYER_CLASS]))
		end

		self._total = index
	end
end

local function bar_OnEvent(self, event, ...)
	if event == "UNIT_INVENTORY_CHANGED" then
		local unit = ...
		if unit == "player" then
			self:UpdateSegments()
		end
	else
		self:UpdateSegments()
	end
end

local function segment_OnEnter(self)
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
end

local function segment_OnLeave(self)
	GameTooltip:Hide()

	if not self:IsTextLocked() then
		self.Text:Hide()
	end
end

local function segment_Update(self, cur, max, bonus, color, texture)
	if not self._color or not E:AreColorsEqual(self._color, color) then
		self.Texture:SetVertexColor(E:GetRGBA(color, 1))
		self.Extension.Texture:SetVertexColor(E:GetRGBA(color, 0.4))

		self._color = self._color or {}
		E:SetRGB(self._color, E:GetRGB(color))
	end

	texture = texture or "Interface\\BUTTONS\\WHITE8X8"
	if not self._texture or self._texture ~= texture then
		self:SetStatusBarTexture(texture)
		self.Extension:SetStatusBarTexture(texture)

		self._texture = texture
	end

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
end

local function segment_UpdateFont(self, size, flag)
	self.Text:SetFontObject("LSFont" .. size .. flag)

	if flag ~= "_Shadow" then
		self.Text:SetShadowOffset(0, 0)
	else
		self.Text:SetShadowOffset(1, -1)
	end
end

local function segment_UpdateText(self, cur, max)
	cur = cur or self._value or 1
	max = max or self._max or 1

	if cur == 1 and max == 1 then
		self.Text:SetText(nil)
	else
		self.Text:SetFormattedText(barValueTemplate, E:FormatNumber(cur), E:FormatNumber(max), E:NumberToPerc(cur, max))
	end
end

local function segment_LockText(self, isLocked)
	if self.textLocked ~= isLocked then
		self.textLocked = isLocked
		self.Text:SetShown(isLocked)
	end
end

local function segment_IsTextLocked(self)
	return self.textLocked
end

function BARS.HasXPBar()
	return isInit
end

function BARS.CreateXPBar()
	if not isInit and (C.db.char.bars.xpbar.enabled or BARS:IsRestricted()) then
		local bar = CreateFrame("Frame", "LSUIXPBar", UIParent)
		bar._id = "xpbar"

		BARS:AddBar(bar._id, bar)

		bar.ForEach = bar_ForEach
		bar.Update = bar_Update
		bar.UpdateConfig = bar_UpdateConfig
		bar.UpdateCooldownConfig = nil
		bar.UpdateSegments = bar_UpdateSegments
		bar.UpdateSize = bar_UpdateSize
		bar.UpdateTextFormat = bar_UpdateTextFormat

		local texParent = CreateFrame("Frame", nil, bar)
		texParent:SetAllPoints()
		texParent:SetFrameLevel(bar:GetFrameLevel() + 3)
		bar.TexParent = texParent

		local textParent = CreateFrame("Frame", nil, bar)
		textParent:SetAllPoints()
		textParent:SetFrameLevel(bar:GetFrameLevel() + 5)

		local bg = bar:CreateTexture(nil, "ARTWORK")
		bg:SetColorTexture(E:GetRGB(C.db.global.colors.dark_gray))
		bg:SetAllPoints()

		for i = 1, MAX_SEGMENTS do
			local segment = CreateFrame("StatusBar", "$parentSegment" .. i, bar)
			segment:SetFrameLevel(bar:GetFrameLevel() + 1)
			segment:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			segment:SetHitRectInsets(0, 0, -4, -4)
			segment:SetClipsChildren(true)
			segment:SetScript("OnEnter", segment_OnEnter)
			segment:SetScript("OnLeave", segment_OnLeave)
			segment:Hide()
			E:SmoothBar(segment)
			bar[i] = segment

			segment.Texture = segment:GetStatusBarTexture()
			E:SmoothColor(segment.Texture)

			local ext = CreateFrame("StatusBar", nil, segment)
			ext:SetFrameLevel(segment:GetFrameLevel())
			ext:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			ext:SetPoint("TOPLEFT", segment.Texture, "TOPRIGHT")
			ext:SetPoint("BOTTOMLEFT", segment.Texture, "BOTTOMRIGHT")
			E:SmoothBar(ext)
			segment.Extension = ext

			ext.Texture = ext:GetStatusBarTexture()
			E:SmoothColor(ext.Texture)

			local text = textParent:CreateFontString(nil, "OVERLAY")
			text:SetAllPoints(segment)
			text:SetWordWrap(false)
			text:Hide()
			segment.Text = text

			segment.IsTextLocked = segment_IsTextLocked
			segment.LockText = segment_LockText
			segment.Update = segment_Update
			segment.UpdateFont = segment_UpdateFont
			segment.UpdateText = segment_UpdateText
		end

		for i = 1, MAX_SEGMENTS - 1 do
			local sep = texParent:CreateTexture(nil, "ARTWORK", nil, -7)
			sep:SetPoint("LEFT", bar[i], "RIGHT", -5, 0)
			sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
			sep:Hide()
			bar[i].Sep = sep
		end

		bar:SetScript("OnEvent", bar_OnEvent)
		-- all
		bar:RegisterEvent("PET_BATTLE_CLOSE")
		bar:RegisterEvent("PET_BATTLE_OPENING_START")
		bar:RegisterEvent("PLAYER_UPDATE_RESTING")
		bar:RegisterEvent("UPDATE_EXHAUSTION")
		-- honour
		bar:RegisterEvent("HONOR_XP_UPDATE")
		bar:RegisterEvent("ZONE_CHANGED")
		bar:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		-- artefact
		bar:RegisterEvent("ARTIFACT_XP_UPDATE")
		bar:RegisterEvent("UNIT_INVENTORY_CHANGED")
		bar:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
		-- azerite
		bar:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
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
			BARS:ActionBarController_AddWidget(bar, "XP_BAR")
		else
			local config = BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar
			local point = config.point[E.UI_LAYOUT]
			bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
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
