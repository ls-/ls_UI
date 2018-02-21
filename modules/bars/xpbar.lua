local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local unpack = _G.unpack

-- Mine
local isInit = false

local MAX_BARS = 3
local NAME_TEMPLATE = "|cff%s%s|r"
local REPUTATION_TEMPLATE = "%s: |cff%s%s|r"
local BAR_VALUE_TEMPLATE = "%1$s / |cff%3$s%2$s|r"

local CFG = {
	visible = true,
	width = 746,
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
	[1] = {
		[1] = {
			point = {"TOPLEFT", "LSUIXPBar", "TOPLEFT", 0, 0},
		},
	},
	[2] = {
		[1] = {
			point = {"TOPLEFT", "LSUIXPBar", "TOPLEFT", 0, 0},
		},
		[2] = {
			point = {"TOPLEFT", "LSUIXPBarSegment1", "TOPRIGHT", 0, 0},
		},
	},
	[3] = {
		[1] = {
			point = {"TOPLEFT", "LSUIXPBar", "TOPLEFT", 0, 0},
		},
		[2] = {
			point = {"TOPLEFT", "LSUIXPBarSegment1", "TOPRIGHT", 0, 0},
		},
		[3] = {
			point = {"TOPLEFT", "LSUIXPBarSegment2", "TOPRIGHT", 0, 0},
		},
	},
}

local function bar_UpdateSegments(self)
	local index = 0

	if C_PetBattles.IsInBattle() then
		for i = 1, 3 do
			if i < C_PetBattles.GetNumPets(1) then
				local level = C_PetBattles.GetLevel(1, i)

				if level and level < 25 then
					index = index + 1

					local name = C_PetBattles.GetName(1, i)
					local rarity = C_PetBattles.GetBreedQuality(1, i)
					local cur, max = C_PetBattles.GetXP(1, i)
					local r, g, b = M.COLORS.XP.NORMAL:GetRGB()
					local hex = M.COLORS.XP.NORMAL:GetHEX(0.2)

					self[index].tooltipInfo = {
						header = NAME_TEMPLATE:format(M.COLORS.ITEM_QUALITY[rarity]:GetHEX(), name),
						line1 = {
							text = L["XP_BAR_LEVEL_TOOLTIP"]:format(level)
						},
					}

					self[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
					E:SetSmoothedVertexColor(self[index].Texture, r, g, b)

					self[index]:SetMinMaxValues(0, max)
					self[index]:SetValue(cur)

					self[index].Extension:SetMinMaxValues(0, 1)
					self[index].Extension:SetValue(0)
				end
			end
		end
	else
		-- Artefact
		if HasArtifactEquipped() then
			index = index + 1

			local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, tier = C_ArtifactUI.GetEquippedArtifactInfo()
			local points, cur, max = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, tier)
			local r, g, b = M.COLORS.ARTIFACT:GetRGBHEX()
			local hex = M.COLORS.ARTIFACT:GetHEX(0.2)

			self[index].tooltipInfo = {
				header = L["ARTIFACT_POWER"],
				line1 = {
					text = L["XP_BAR_ARTIFACT_NUM_UNSPENT_TRAIT_POINTS_TOOLTIP"]:format(points)
				},
				line2 = {
					text = L["XP_BAR_ARTIFACT_NUM_PURCHASED_RANKS_TOOLTIP"]:format(pointsSpent)
				},
			}

			self[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, E:NumberFormat(cur, 1), E:NumberFormat(max, 1), hex)
			E:SetSmoothedVertexColor(self[index].Texture, r, g, b)

			self[index]:SetMinMaxValues(0, max)
			self[index]:SetValue(cur)

			self[index].Extension:SetMinMaxValues(0, 1)
			self[index].Extension:SetValue(0)
		end

		-- XP / Honour
		if UnitLevel("player") < MAX_PLAYER_LEVEL then
			if not IsXPUserDisabled() then
				index = index + 1

				local cur, max = UnitXP("player"), UnitXPMax("player")
				local bonus = GetXPExhaustion()
				local r, g, b, hex

				if bonus and bonus > 0 then
					r, g, b = M.COLORS.XP.RESTED:GetRGB()
					hex = M.COLORS.XP.RESTED:GetHEX(0.2)
				else
					r, g, b = M.COLORS.XP.NORMAL:GetRGB()
					hex = M.COLORS.XP.NORMAL:GetHEX(0.2)
				end

				self[index].tooltipInfo = {
					header = L["EXPERIENCE"],
					line1 = {
						text = L["XP_BAR_LEVEL_TOOLTIP"]:format(UnitLevel("player"))
					},
				}

				if bonus and bonus > 0 then
					self[index].tooltipInfo.line2 = {
						text = L["XP_BAR_XP_BONUS_TOOLTIP"]:format(bonus)
					}
				else
					self[index].tooltipInfo.line2 = nil
				end

				self[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
				E:SetSmoothedVertexColor(self[index].Texture, r, g, b)

				self[index]:SetMinMaxValues(0, max)
				self[index]:SetValue(cur)

				if bonus and bonus > 0 then
					if cur + bonus > max then
						bonus = max - cur
					end

					self[index].Extension:SetStatusBarColor(r, g, b, 0.45)
					self[index].Extension:SetMinMaxValues(0, max)
					self[index].Extension:SetValue(bonus)
				else
					self[index].Extension:SetMinMaxValues(0, 1)
					self[index].Extension:SetValue(0)
				end
			end
		else
			if IsWatchingHonorAsXP() or InActiveBattlefield() or IsInActiveWorldPVP() then
				index = index + 1

				local cur, max = UnitHonor("player"), UnitHonorMax("player")
				local bonus = GetHonorExhaustion()
				local r, g, b = M.COLORS.FACTION[UnitFactionGroup("player"):upper()]:GetRGB()
				local hex = M.COLORS.FACTION[UnitFactionGroup("player"):upper()]:GetHEX(0.2)

				self[index].tooltipInfo = {
					header = L["HONOR"],
					line1 = {
						text = L["XP_BAR_HONOR_TOOLTIP"]:format(UnitHonorLevel("player")),
					},
					line2 = {
						text = L["XP_BAR_PRESTIGE_LEVEL_TOOLTIP"]:format(UnitPrestige("player"))
					},
				}

				if bonus and bonus > 0 then
					self[index].tooltipInfo.line3 = {
						text = L["XP_BAR_HONOR_BONUS_TOOLTIP"]:format(bonus)
					}
				else
					self[index].tooltipInfo.line3 = nil
				end

				self[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
				E:SetSmoothedVertexColor(self[index].Texture, r, g, b)

				self[index]:SetMinMaxValues(0, max)
				self[index]:SetValue(cur)

				if bonus and bonus > 0 then
					if cur + bonus > max then
						bonus = max - cur
					end

					self[index].Extension:SetStatusBarColor(r, g, b, 0.45)
					self[index].Extension:SetMinMaxValues(0, max)
					self[index].Extension:SetValue(bonus)
				else
					self[index].Extension:SetMinMaxValues(0, 1)
					self[index].Extension:SetValue(0)
				end
			end
		end

		-- Reputation
		local name, standing, repMin, repMax, repCur, factionID = GetWatchedFactionInfo()

		if name then
			index = index + 1

			local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
			local repTextLevel = GetText("FACTION_STANDING_LABEL"..standing, UnitSex("player"))
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
						repTextLevel = repTextLevel.."+"

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
				line1 = {
					text = REPUTATION_TEMPLATE:format(name, hex, repTextLevel)
				},
			}

			if isParagon and hasRewardPending then
				local text = GetQuestLogCompletionText(GetQuestLogIndexByID(rewardQuestID))

				if text and text ~= "" then
					self[index].tooltipInfo.line3 = {
						text = text
					}
				end
			else
				self[index].tooltipInfo.line3 = nil
			end

			self[index].Text:SetFormattedText(BAR_VALUE_TEMPLATE, BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), hex)
			E:SetSmoothedVertexColor(self[index].Texture, r, g, b)

			self[index]:SetMinMaxValues(0, max)
			self[index]:SetValue(cur)

			self[index].Extension:SetMinMaxValues(0, 1)
			self[index].Extension:SetValue(0)
		end
	end

	if self._total ~= index then
		for i = 1, MAX_BARS do
			if i <= index then
				self[i]:SetSize(unpack(LAYOUT[index][i].size))
			self[i]:SetPoint(unpack(LAYOUT[index][i].point))
			self[i]:Show()

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

	for i = 1, 2 do
		if i <= index - 1 then
			self[i].Sep:Show()
		else
			self[i].Sep:Hide()
		end
	end

	if index == 0 then
		self[1]:SetPoint(unpack(LAYOUT[1][1].point))
		self[1]:SetSize(unpack(LAYOUT[1][1].size))
		self[1]:SetMinMaxValues(0, 1)
		self[1]:SetValue(1)
		self[1]:Show()

			self[1].Text:SetText(nil)
			E:SetSmoothedVertexColor(self[1].Texture, M.COLORS.CLASS[E.PLAYER_CLASS]:GetRGB())
		end

		self._total = index
	end
end

local function bar_UpdateSize(self, width)
	width = width or self._config.width
	LAYOUT[1][1].size = {width, 16 / 2}

	local layout = E:CalcSegmentsSizes(width, 2)
	LAYOUT[2][1].size = {layout[1], 16 / 2}
	LAYOUT[2][2].size = {layout[2], 16 / 2}

	layout = E:CalcSegmentsSizes(width, 3)
	LAYOUT[3][1].size = {layout[1], 16 / 2}
	LAYOUT[3][2].size = {layout[2], 16 / 2}
	LAYOUT[3][3].size = {layout[3], 16 / 2}

	self:SetSize(width, 16 / 2)

	local total = 0
	for i = 1, MAX_BARS do
		if self[i]:IsShown() then
			total = total + 1
	end
	end

	for i = 1, total do
		self[i]:SetSize(unpack(LAYOUT[total][i].size))
		self[i]:SetPoint(unpack(LAYOUT[total][i].point))
		self[i].Extension:SetSize(unpack(LAYOUT[total][i].size))
	end

	self:UpdateSegments()
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
		GameTooltip:AddLine(self.tooltipInfo.line1.text)

		if self.tooltipInfo.line2 then
			GameTooltip:AddLine(self.tooltipInfo.line2.text)
		end

		if self.tooltipInfo.line3 then
			GameTooltip:AddLine(self.tooltipInfo.line3.text)
		end

		GameTooltip:Show()
	end

	self.Text:Show()
end

local function segment_OnLeave(self)
	GameTooltip:Hide()

	self.Text:Hide()
end

function BARS.HasXPBar()
	return isInit
end

function BARS.CreateXPBar()
	if not isInit and (C.db.char.bars.xpbar.enabled or BARS:IsRestricted()) then
		local bar = CreateFrame("Frame", "LSUIXPBar", UIParent)
		bar._id = "xpbar"
		bar._total = 0

		BARS:AddBar(bar._id, bar)

		bar.Update = function(self)
			self:UpdateConfig()
			self:UpdateSize()

			if not BARS:IsRestricted() then
				self:UpdateFading()
				E:UpdateMoverSize(self)
			end
		end
		bar.UpdateConfig = function(self)
			self._config = BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar
		end
		bar.UpdateSize = bar_UpdateSize
		bar.UpdateSegments = bar_UpdateSegments

		local cover = CreateFrame("Frame", nil, bar)
		cover:SetAllPoints()
		cover:SetFrameLevel(bar:GetFrameLevel() + 3)

		local text_parent = CreateFrame("Frame", nil, bar)
		text_parent:SetAllPoints()
		text_parent:SetFrameLevel(bar:GetFrameLevel() + 5)

		local t = bar:CreateTexture(nil, "ARTWORK")
		t:SetAllPoints()
		t:SetTexture("Interface\\Artifacts\\_Artifacts-DependencyBar-BG", true)
		t:SetHorizTile(true)
		t:SetTexCoord(0 / 128, 128 / 128, 4 / 16, 12 / 16)

		for i = 1, MAX_BARS do
			bar[i] = CreateFrame("StatusBar", "$parentSegment"..i, bar)
			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			bar[i]:SetHitRectInsets(0, 0, -4, -4)
			bar[i]:SetClipsChildren(true)
			bar[i]:SetScript("OnEnter", segment_OnEnter)
			bar[i]:SetScript("OnLeave", segment_OnLeave)
			bar[i]:Hide()
			E:SmoothBar(bar[i])

			bar[i].Texture = bar[i]:GetStatusBarTexture()

			local ext = CreateFrame("StatusBar", nil, bar[i])
			ext:SetFrameLevel(bar[i]:GetFrameLevel())
			ext:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			ext:SetPoint("TOPLEFT", bar[i].Texture, "TOPRIGHT")
			ext:SetPoint("BOTTOMLEFT", bar[i].Texture, "BOTTOMRIGHT")
			E:SmoothBar(ext)
			bar[i].Extension = ext

			local text = text_parent:CreateFontString(nil, "OVERLAY", "LSFont10_Outline")
			text:SetAllPoints(bar[i])
			text:SetWordWrap(false)
			text:Hide()
			bar[i].Text = text
		end

		local sep = cover:CreateTexture(nil, "ARTWORK", nil, -7)
		sep:SetPoint("LEFT", bar[1], "RIGHT", -5, 0)
		sep:SetSize(24 / 2, 16 / 2)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
		sep:SetTexCoord(1 / 64, 25 / 64, 1 / 64, 17 / 64)
		sep:Hide()
		bar[1].Sep = sep

		sep = cover:CreateTexture(nil, "ARTWORK", nil, -7)
		sep:SetPoint("LEFT", bar[2], "RIGHT", -5, 0)
		sep:SetSize(24 / 2, 16 / 2)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
		sep:SetTexCoord(1 / 64, 25 / 64, 1 / 64, 17 / 64)
		sep:Hide()
		bar[2].Sep = sep

		bar:SetScript("OnEvent", bar_OnEvent)
		-- all
		bar:RegisterEvent("PET_BATTLE_CLOSE")
		bar:RegisterEvent("PET_BATTLE_OPENING_START")
		bar:RegisterEvent("PLAYER_UPDATE_RESTING")
		bar:RegisterEvent("UPDATE_EXHAUSTION")
		-- honour
		bar:RegisterEvent("HONOR_LEVEL_UPDATE")
		bar:RegisterEvent("HONOR_XP_UPDATE")
		bar:RegisterEvent("ZONE_CHANGED")
		bar:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		-- ap
		bar:RegisterEvent("ARTIFACT_XP_UPDATE")
		bar:RegisterEvent("UNIT_INVENTORY_CHANGED")
		-- xp
		bar:RegisterEvent("DISABLE_XP_GAIN")
		bar:RegisterEvent("ENABLE_XP_GAIN")
		bar:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
		bar:RegisterEvent("PET_BATTLE_XP_CHANGED")
		bar:RegisterEvent("PLAYER_LEVEL_UP")
		bar:RegisterEvent("PLAYER_XP_UPDATE")
		bar:RegisterEvent("UPDATE_EXPANSION_LEVEL")
		-- rep
		bar:RegisterEvent("UPDATE_FACTION")

		if BARS:IsRestricted() then
			BARS:ActionBarController_AddWidget(bar, "XP_BAR")
		else
			local config = BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar
			local point = config.point
			bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E:CreateMover(bar)
			E:SetStatusBarSkin(cover, "HORIZONTAL-8")
		end

		bar:Update()

		-- Honour & Rep Hooks
		-- This way I'm able to show honour and reputation bars simultaneously
		local isHonorBarHooked = false

		hooksecurefunc("TalentFrame_LoadUI", function()
			if not isHonorBarHooked then
				PlayerTalentFramePVPTalents.XPBar:SetScript("OnMouseUp", function()
					if IsShiftKeyDown() then
						if IsWatchingHonorAsXP() or InActiveBattlefield() or IsInActiveWorldPVP() then
							PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
							SetWatchingHonorAsXP(false)
						else
							PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
							SetWatchingHonorAsXP(true)
						end

						bar:UpdateSegments()
					end
				end)

				PlayerTalentFramePVPTalents.XPBar:HookScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_TOP")
					GameTooltip:AddLine(L["SHIFT_CLICK_TO_SHOW_AS_XP"])
					GameTooltip:Show()
				end)

				PlayerTalentFramePVPTalents.XPBar:HookScript("OnLeave", function()
					GameTooltip:Hide()
				end)

				isHonorBarHooked = true
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
