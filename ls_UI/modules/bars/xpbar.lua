local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local unpack = _G.unpack

-- Mine
local isInit = false
local barValueTemplate

local MAX_SEGMENTS = 4
local CUR_MAX_PERC_VALUE_TEMPLATE = "%s / %s (%.1f%%)"
local CUR_MAX_VALUE_TEMPLATE = "%s / %s"
local HONOR_TEMPLATE = _G.LFG_LIST_HONOR_LEVEL_CURRENT_PVP:gsub("%%d", "|cffffffff%%d|r")
local RENOWN_PLUS = _G.LANDING_PAGE_RENOWN_LABEL .. "+"
local REPUTATION_TEMPLATE = "%s: %s"

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
do
	function bar_proto:ForEach(method, ...)
		for i = 1, MAX_SEGMENTS do
			if self[i][method] then
				self[i][method](self[i], ...)
			end
		end
	end

	function bar_proto:Update()
		self:UpdateConfig()
		self:UpdateFont()
		self:UpdateTextFormat()
		self:UpdateTextVisibility()
		self:UpdateSize(self._config.width, self._config.height)
		self:UpdateFading()
	end

	function bar_proto:UpdateConfig()
		self._config = E:CopyTable(BARS:IsRestricted() and CFG or C.db.profile.bars.xpbar, self._config)

		if BARS:IsRestricted() then
			self._config.text = E:CopyTable(C.db.profile.bars.xpbar.text, self._config.text)
		end
	end

	function bar_proto:UpdateFont()
		for i = 1, MAX_SEGMENTS do
			self[i].Text:UpdateFont(self._config.text.size)
		end
	end

	function bar_proto:UpdateTextFormat()
		if self._config.text.format == "NUM" then
			barValueTemplate = CUR_MAX_VALUE_TEMPLATE
		elseif self._config.text.format == "NUM_PERC" then
			barValueTemplate = CUR_MAX_PERC_VALUE_TEMPLATE
		end
	end

	function bar_proto:UpdateTextVisibility()
		for i = 1, MAX_SEGMENTS do
			self[i]:LockText(self._config.text.visibility == 1)
		end
	end

	function bar_proto:UpdateSize(width, height)
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

		self.total = nil

		self:UpdateSegments()
	end

	function bar_proto:UpdateSegments()
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
			local data = C_Reputation.GetWatchedFactionData()
			if data then
				index = index + 1

				self[index]:UpdateReputation(data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID)
			end
		end

		if self.total ~= index then
			for i = 1, MAX_SEGMENTS do
				if i <= index then
					self[i]:SetWidth(LAYOUT[index][i].size[1])

					self[i].Extension:SetWidth(LAYOUT[index][i].size[1])
				else
					if index == 0 and i == 1 then
						self[i]:SetWidth(LAYOUT[1][1].size[1])
						self[i]:Update(1, 1, 0, C.db.global.colors.class[E.PLAYER_CLASS])
					else
						self[i]:SetWidth(0.0001)
						self[i]:SetValue(0)

						self[i].Extension:SetWidth(0.0001)
						self[i].Extension:SetValue(0)
					end

					self[i].cur = nil
					self[i].max = nil
					self[i].bonus = nil
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

			if not BARS:IsRestricted() then
				if index == 0 then
					self:Hide()
				else
					self:Show()
				end
			end

			self.total = index
		end
	end

	local deferredUpdate, timer

	function bar_proto:OnEvent(event, ...)
		if not deferredUpdate then
			deferredUpdate = function()
				self:UpdateSegments()

				timer = nil
			end
		end

		if event == "UNIT_INVENTORY_CHANGED" then
			local unit = ...
			if unit == "player" then
				if not timer then
					timer = C_Timer.NewTimer(0.1, deferredUpdate)
				end
			end
		elseif event == "PLAYER_EQUIPMENT_CHANGED" then
			local slot = ...
			if slot == Enum.InventoryType.IndexNeckType then
				if not timer then
					timer = C_Timer.NewTimer(0.1, deferredUpdate)
				end
			end
		else
			if not timer then
				timer = C_Timer.NewTimer(0.1, deferredUpdate)
			end
		end
	end
end

local segment_base_proto = {}
do
	function segment_base_proto:SetSmoothStatusBarColor(r, g, b, a)
		local color = self.ColorAnim.color
		a = a or 1

		if color.r == r and color.g == g and color.b == b and color.a == a then return end

		color.r, color.g, color.b, color.a = self:GetStatusBarColor()
		self.ColorAnim.Anim:SetStartColor(color)

		color.r, color.g, color.b, color.a = r, g, b, a
		self.ColorAnim.Anim:SetEndColor(color)

		self.ColorAnim:Play()
	end
end

local segment_ext_proto = {}
do
	function segment_ext_proto:OnEnter()
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

	function segment_ext_proto:OnLeave()
		GameTooltip:Hide()

		if not self:IsTextLocked() then
			self.Text:Hide()
		end
	end

	function segment_ext_proto:Update(cur, max, bonus, color)
		self:SetSmoothStatusBarColor(color:GetRGBA(1))

		self.Extension:SetSmoothStatusBarColor(color:GetRGBA(0.4))

		if self.cur ~= cur or self.max ~= max then
			self:SetValue(cur / max)
			self:UpdateText(cur, max)

			self.cur = cur
			self.max = max
		end

		if self.bonus ~= bonus then
			if bonus and bonus > 0 then
				if cur + bonus > max then
					bonus = max - cur
				end

				self.Extension:SetValue(bonus / max)
			else
				self.Extension:SetValue(0)
			end

			self.bonus = bonus
		end
	end

	function segment_ext_proto:UpdateAzerite(item)
		local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(item)
		local level = C_AzeriteItem.GetPowerLevel(item)

		self.tooltipInfo = {
			header = L["ARTIFACT_POWER"],
			line1 = L["ARTIFACT_LEVEL_TOOLTIP"]:format(level),
		}

		self:Update(cur, max, 0, ITEM_QUALITY_COLORS[6].color)
	end

	function segment_ext_proto:UpdateXP()
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
	end

	function segment_ext_proto:UpdateHonor()
		local cur, max = UnitHonor("player"), UnitHonorMax("player")

		self.tooltipInfo = {
			header = _G.HONOR,
			line1 = HONOR_TEMPLATE:format(UnitHonorLevel("player")),
		}

		self:Update(cur, max, 0, C.db.global.colors.faction[UnitFactionGroup("player")])
	end

	function segment_ext_proto:UpdateReputation(name, standing, repMin, repMax, repCur, factionID)
		local repTextLevel = GetText("FACTION_STANDING_LABEL" .. standing, UnitSex("player"))
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
		local isParagon = C_Reputation.IsFactionParagon(factionID)
		local isMajor = C_Reputation.IsMajorFaction(factionID)
		local isFriendship = repInfo and repInfo.friendshipFactionID > 0
		local rewardQuestID, hasRewardPending
		local cur, max

		-- any faction can be paragon as in you keep earning more rep to unlock extra rewards
		if isParagon then
			cur, max, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
			cur = cur % max

			if hasRewardPending then
				cur = cur + max
			end

			if isMajor then
				standing = 9
				repTextLevel = RENOWN_PLUS
			elseif isFriendship then
				repTextLevel = repInfo.reaction .. "+"
			else
				repTextLevel = repTextLevel .. "+"
			end
		elseif isMajor then
			repInfo = C_MajorFactions.GetMajorFactionData(factionID)

			if C_MajorFactions.HasMaximumRenown(factionID) then
				max, cur = 1, 1
			else
				max, cur = repInfo.renownLevelThreshold, repInfo.renownReputationEarned
			end

			standing = 9
			repTextLevel = _G.RENOWN_LEVEL_LABEL:format(repInfo.renownLevel)
		elseif isFriendship then
			if repInfo.nextThreshold then
				max, cur = repInfo.nextThreshold - repInfo.reactionThreshold, repInfo.standing - repInfo.reactionThreshold
			else
				max, cur = 1, 1
			end

			standing = 5
			repTextLevel = repInfo.reaction
		else
			if standing ~= MAX_REPUTATION_REACTION then
				max, cur = repMax - repMin, repCur - repMin
			else
				max, cur = 1, 1
			end
		end

		self.tooltipInfo = {
			header = _G.REPUTATION,
			line1 = REPUTATION_TEMPLATE:format(name, C.db.global.colors.reaction[standing]:WrapTextInColorCode(repTextLevel)),
		}

		if hasRewardPending then
			local text = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(rewardQuestID))
			if text and text ~= "" then
				self.tooltipInfo.line3 = text
			end
		else
			self.tooltipInfo.line3 = nil
		end

		self:Update(cur, max, 0, C.db.global.colors.reaction[standing])
	end

	function segment_ext_proto:UpdatePetXP(i, level)
		local name = C_PetBattles.GetName(1, i)
		local rarity = C_PetBattles.GetBreedQuality(1, i)
		local cur, max = C_PetBattles.GetXP(1, i)

		self.tooltipInfo = {
			header = ITEM_QUALITY_COLORS[rarity].color:WrapTextInColorCode(name),
			line1 = L["LEVEL_TOOLTIP"]:format(level),
		}

		self:Update(cur, max, 0, C.db.global.colors.xp[2])
	end

	function segment_ext_proto:UpdateText(cur, max)
		cur = cur or self.cur or 1
		max = max or self.max or 1

		if cur == 1 and max == 1 then
			self.Text:SetText(nil)
		else
			self.Text:SetFormattedText(barValueTemplate, E:FormatNumber(cur), E:FormatNumber(max), E:NumberToPerc(cur, max))
		end
	end

	function segment_ext_proto:LockText(isLocked)
		if self.textLocked ~= isLocked then
			self.textLocked = isLocked
			self.Text:SetShown(isLocked)
		end
	end

	function segment_ext_proto:IsTextLocked()
		return self.textLocked
	end
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
		bar.TextureParent = texParent

		local textParent = CreateFrame("Frame", nil, bar)
		textParent:SetAllPoints()
		textParent:SetFrameLevel(bar:GetFrameLevel() + 5)
		bar.TextParent = textParent

		local bg = bar:CreateTexture(nil, "ARTWORK")
		bg:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
		bg:SetHorizTile(true)
		bg:SetVertTile(true)
		bg:SetAllPoints()

		local gradient = texParent:CreateTexture(nil, "BORDER")
		gradient:SetAllPoints(texParent)
		gradient:SetSnapToPixelGrid(false)
		gradient:SetTexelSnappingBias(0)
		gradient:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		gradient:SetGradient("VERTICAL", {r = 0, g = 0, b = 0, a = 0}, {r = 0, g = 0, b = 0, a = 0.4})
		texParent.Gradient = gradient

		if not BARS:IsRestricted() then
			local border = E:CreateBorder(texParent)
			border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-statusbar")
			border:SetSize(16)
			border:SetOffset(-4)
			texParent.Border = border
		end

		for i = 1, MAX_SEGMENTS do
			local segment = Mixin(CreateFrame("StatusBar", "$parentSegment" .. i, bar), segment_base_proto, segment_ext_proto)
			segment:SetFrameLevel(bar:GetFrameLevel() + 1)
			segment:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			E.StatusBars:Capture(segment, "xpbar", segment.UpdateTextureCallback)
			segment:SetStatusBarColor(1, 1, 1, 0)
			segment:SetMinMaxValues(0, 1)
			segment:SetHitRectInsets(0, 0, -4, -4)
			segment:SetPoint("TOP", 0, 0)
			segment:SetPoint("BOTTOM", 0, 0)
			segment:SetClipsChildren(true)
			segment:SetScript("OnEnter", segment.OnEnter)
			segment:SetScript("OnLeave", segment.OnLeave)
			E.StatusBars:Smooth(segment)
			bar[i] = segment

			if i == 1 then
				segment:SetPoint("LEFT", bar, "LEFT", 0, 0)
			else
				segment:SetPoint("LEFT", bar[i - 1], "RIGHT", 2, 0)
			end

			segment.Texture = segment:GetStatusBarTexture()

			local ag = segment.Texture:CreateAnimationGroup()
			ag.color = {a = 1}
			segment.ColorAnim = ag

			local anim = ag:CreateAnimation("VertexColor")
			anim:SetDuration(0.125)
			ag.Anim = anim

			local ext = Mixin(CreateFrame("StatusBar", nil, segment), segment_base_proto)
			ext:SetFrameLevel(segment:GetFrameLevel())
			ext:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
			E.StatusBars:Capture(segment, "ext", segment.UpdateTextureCallback)
			ext:SetStatusBarColor(1, 1, 1, 0)
			ext:SetMinMaxValues(0, 1)
			ext:SetPoint("TOPLEFT", segment.Texture, "TOPRIGHT")
			ext:SetPoint("BOTTOMLEFT", segment.Texture, "BOTTOMRIGHT")
			E.StatusBars:Smooth(ext)
			segment.Extension = ext

			ext.Texture = ext:GetStatusBarTexture()

			ag = ext.Texture:CreateAnimationGroup()
			ext.ColorAnim = ag

			anim = ag:CreateAnimation("VertexColor")
			anim:SetDuration(0.125)
			ag.color = {a = 1}
			ag.Anim = anim

			local text = textParent:CreateFontString(nil, "OVERLAY")
			E.FontStrings:Capture(text, "statusbar")
			text:SetWordWrap(false)
			text:SetAllPoints(segment)
			text:Hide()
			segment.Text = text

			if i < MAX_SEGMENTS then
				local sep = texParent:CreateTexture(nil, "ARTWORK", nil, -7)
				sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
				sep:SetVertTile(true)
				sep:SetTexCoord(2 / 16, 14 / 16, 0 / 8, 8 / 8)
				sep:SetVertexColor(1, 0.6, 0)
				sep:SetSize(12 / 2, 0)
				sep:SetPoint("TOP", 0, 0)
				sep:SetPoint("BOTTOM", 0, 0)
				sep:SetPoint("LEFT", bar[i], "RIGHT", -2, 0)
				sep:SetSnapToPixelGrid(false)
				sep:SetTexelSnappingBias(0)
				sep:Hide()
				bar[i].Sep = sep
			end
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
		local function hookHonor()
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

		if C_AddOns.IsAddOnLoaded("Blizzard_PVPUI") then
			hookHonor()
		else
			hooksecurefunc("UIParentLoadAddOn", function(addOnName)
				if addOnName == "Blizzard_PVPUI" then
					hookHonor()
				end
			end)
		end

		ReputationFrame.ReputationDetailFrame.WatchFactionCheckbox:SetScript("OnClick", function(self)
			if self:GetChecked() then
				PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
				C_Reputation.SetWatchedFactionByIndex(C_Reputation.GetSelectedFaction())
			else
				PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
				C_Reputation.SetWatchedFactionByIndex(0)
			end

			bar:UpdateSegments()
		end)

		isInit = true
	end
end
