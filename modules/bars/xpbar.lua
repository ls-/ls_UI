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

local MAX_SEGMENTS = 4
local NAME_TEMPLATE = "|cff%s%s|r"
local REPUTATION_TEMPLATE = "%s: |cff%s%s|r"
local BAR_VALUE_TEMPLATE = "%s / %s"

local CFG = {
	visible = true,
	width = 594,
	height = 12,
	point = {
		p = "BOTTOM",
		anchor = "UIParent",
		rP = "BOTTOM",
		x = 0,
		y = 4
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

local function bar_Update(self)
	self:UpdateConfig()
	self:UpdateFont()
	self:UpdateSize()

	if not BARS:IsRestricted() then
		self:UpdateFading()
		E.Movers:Get(self):UpdateSize()
	end
end

local function bar_UpdateConfig(self)
	self._config = E:CopyTable(BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar, self._config)

	if BARS:IsRestricted() then
		self._config.text = E:CopyTable(C.db.profile.bars.xpbar.text, self._config.text)
	end
end

local function bar_UpdateFont(self)
	local config = self._config.text
	local fontObject = "LSFont" .. config.size .. config.flag

	for i = 1, MAX_SEGMENTS do
		self[i].Text:SetFontObject(fontObject)

		if config.flag ~= "_Shadow" then
			self[i].Text:SetShadowOffset(0, 0)
		else
			self[i].Text:SetShadowOffset(1, -1)
		end
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
			local r, g, b = M.COLORS.XP.NORMAL:GetRGB()

			self[index].tooltipInfo = {
				header = NAME_TEMPLATE:format(M.COLORS.ITEM_QUALITY[rarity]:GetHEX(), name),
				line1 = L["LEVEL_TOOLTIP"]:format(level),
			}

			self[index]:Update(cur, max, 0, r, g, b)
		end
	else
		-- Artefact
		if HasArtifactEquipped() and not C_ArtifactUI.IsEquippedArtifactMaxed() and not C_ArtifactUI.IsEquippedArtifactDisabled() then
			index = index + 1

			local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, tier = C_ArtifactUI.GetEquippedArtifactInfo()
			local points, cur, max = ArtifactBarGetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, tier)
			local r, g, b = M.COLORS.ARTIFACT:GetRGB()

			self[index].tooltipInfo = {
				header = L["ARTIFACT_POWER"],
				line1 = L["UNSPENT_TRAIT_POINTS_TOOLTIP"]:format(points),
				line2 = L["ARTIFACT_LEVEL_TOOLTIP"]:format(pointsSpent),
			}

			self[index]:Update(cur, max, 0, r, g, b)
		end

		-- Azerite
		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

		if azeriteItemLocation then
			index = index + 1

			local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
			local level = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
			local r, g, b = M.COLORS.ARTIFACT:GetRGB()

			self[index].tooltipInfo = {
				header = L["ARTIFACT_POWER"],
				line1 = L["ARTIFACT_LEVEL_TOOLTIP"]:format(level),
			}

			self[index]:Update(cur, max, 0, r, g, b)
		end

		-- XP
		if UnitLevel("player") < MAX_PLAYER_LEVEL then
			if not IsXPUserDisabled() then
				index = index + 1

				local cur, max = UnitXP("player"), UnitXPMax("player")
				local bonus = GetXPExhaustion()
				local r, g, b

				if bonus and bonus > 0 then
					r, g, b = M.COLORS.XP.RESTED:GetRGB()
				else
					r, g, b = M.COLORS.XP.NORMAL:GetRGB()
				end

				self[index].tooltipInfo = {
					header = L["EXPERIENCE"],
					line1 = L["LEVEL_TOOLTIP"]:format(UnitLevel("player")),
				}

				if bonus and bonus > 0 then
					self[index].tooltipInfo.line2 = L["BONUS_XP_TOOLTIP"]:format(BreakUpLargeNumbers(bonus))
				else
					self[index].tooltipInfo.line2 = nil
				end

				self[index]:Update(cur, max, bonus, r, g, b)
			end
		end

		-- Honour
		if IsWatchingHonorAsXP() or InActiveBattlefield() or IsInActiveWorldPVP() then
			index = index + 1

			local cur, max = UnitHonor("player"), UnitHonorMax("player")
			local r, g, b = M.COLORS.FACTION[UnitFactionGroup("player"):upper()]:GetRGB()

			self[index].tooltipInfo = {
				header = L["HONOR"],
				line1 = L["HONOR_LEVEL_TOOLTIP"]:format(UnitHonorLevel("player")),
			}

			self[index]:Update(cur, max, 0, r, g, b)
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

			local r, g, b = M.COLORS.REACTION[standing]:GetRGB()
			local hex = M.COLORS.REACTION[standing]:GetHEX(0.2)

			self[index].tooltipInfo = {
				header = L["REPUTATION"],
				line1 = REPUTATION_TEMPLATE:format(name, hex, repTextLevel),
			}

			if isParagon and hasRewardPending then
				local text = GetQuestLogCompletionText(GetQuestLogIndexByID(rewardQuestID))

				if text and text ~= "" then
					self[index].tooltipInfo.line3 = text
				end
			else
				self[index].tooltipInfo.line3 = nil
			end

			self[index]:Update(cur, max, 0, r, g, b)
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

			self[1].Text:SetText(nil)
			self[1].Texture:SetVertexColor(M.COLORS.CLASS[E.PLAYER_CLASS]:GetRGB())
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

	self.Text:Show()
end

local function segment_OnLeave(self)
	GameTooltip:Hide()

	self.Text:Hide()
end

local function segment_Update(self, cur, max, bonus, r, g, b)
	if self._value ~= cur or self._max ~= max then
		self.Text:SetFormattedText(BAR_VALUE_TEMPLATE, E:NumberFormat(cur, 1), E:NumberFormat(max, 1))
		self.Texture:SetVertexColor(r, g, b)

		self:SetMinMaxValues(0, max)
		self:SetValue(cur)
	end

	if self._bonus ~= bonus then
		if bonus and bonus > 0 then
			if cur + bonus > max then
				bonus = max - cur
			end

			self.Extension.Texture:SetVertexColor(r, g, b, 0.4)

			self.Extension:SetMinMaxValues(0, max)
			self.Extension:SetValue(bonus)
		else
			self.Extension:SetMinMaxValues(0, 1)
			self.Extension:SetValue(0)
		end

		self._bonus = bonus
	end
end

function BARS.HasXPBar()
	return isInit
end

function BARS.CreateXPBar()
	if not isInit and (C.db.char.bars.xpbar.enabled or BARS:IsRestricted()) then
		local bar = CreateFrame("Frame", "LSUIXPBar", UIParent)
		bar._id = "xpbar"

		BARS:AddBar(bar._id, bar)

		bar.Update = bar_Update
		bar.UpdateConfig = bar_UpdateConfig
		bar.UpdateCooldownConfig = nil
		bar.UpdateFont = bar_UpdateFont
		bar.UpdateSegments = bar_UpdateSegments
		bar.UpdateSize = bar_UpdateSize

		local texParent = CreateFrame("Frame", nil, bar)
		texParent:SetAllPoints()
		texParent:SetFrameLevel(bar:GetFrameLevel() + 3)
		bar.TexParent = texParent

		local textParent = CreateFrame("Frame", nil, bar)
		textParent:SetAllPoints()
		textParent:SetFrameLevel(bar:GetFrameLevel() + 5)

		local bg = bar:CreateTexture(nil, "ARTWORK")
		bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
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

			segment.Update = segment_Update
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
			local point = config.point
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
					PVPQueueFrame.HonorInset.HonorLevelDisplay:SetScript("OnMouseUp", function()
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

					PVPQueueFrame.HonorInset.HonorLevelDisplay:HookScript("OnEnter", function()
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(L["SHIFT_CLICK_TO_SHOW_AS_XP"])
						GameTooltip:Show()
					end)

					PVPQueueFrame.HonorInset.HonorLevelDisplay:HookScript("OnLeave", function()
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
