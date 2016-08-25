local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local STATS = E:AddModule("Stats")

-- Lua
local _G = _G
local unpack, pairs = unpack, pairs
local tinsert, tremove, twipe = table.insert, table.remove, table.wipe
local strgsub, utf8len, utf8sub = string.gsub, string.utf8len, string.utf8sub

-- Mine
local OBJECTIVE_TRACKER_UPDATE_CHAR_INFO = 0x40000000
local OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED = 0x80000000
local EXPERIENCE = strgsub(EXPERIENCE_COLON, ":", "")
local isHonorBarHooked = false
local isInitialized = false
local isEnabled = false

-------------
-- TRACKER --
-------------

local function CreateCharInfoTracker()
	_G.OBJECTIVE_TRACKER_UPDATE_ALL = 0xFFFFFFFF

	local charInfoHeader = _G.CreateFrame("Frame", nil, _G.ObjectiveTrackerBlocksFrame, "ObjectiveTrackerHeaderTemplate")
	_G.ObjectiveTrackerFrame.BlocksFrame.CharInfoHeader = charInfoHeader

	local CHAR_INFO_TRACKER_MODULE = _G.ObjectiveTracker_GetModuleInfoTable()
	CHAR_INFO_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_CHAR_INFO + OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED
	CHAR_INFO_TRACKER_MODULE.usedBlocks = {}
	CHAR_INFO_TRACKER_MODULE.lineSpacing = 5
	CHAR_INFO_TRACKER_MODULE.blockOffsetY = -5
	CHAR_INFO_TRACKER_MODULE:SetHeader(_G.ObjectiveTrackerFrame.BlocksFrame.CharInfoHeader, _G.CHARACTER_INFO, OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
	tinsert(_G.ObjectiveTrackerFrame.MODULES, 1, CHAR_INFO_TRACKER_MODULE)

	------------
	-- HEADER --
	------------

	function CHAR_INFO_TRACKER_MODULE:SetBlockHeader(block, text)
		local height = self:SetStringText(block.HeaderText, text, nil, _G.OBJECTIVE_TRACKER_COLOR["Normal"], block.isHighlighted)
		block.height = height
	end

	function CHAR_INFO_TRACKER_MODULE:OnBlockHeaderEnter(block)
		block.isHighlighted = true

		if block.HeaderText then
			local headerColorStyle = _G.OBJECTIVE_TRACKER_COLOR["NormalHighlight"]

			block.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b)
			block.HeaderText.colorStyle = headerColorStyle
		end

		if block.type == "reputation" then
			for _, line in pairs(block.lines) do
				local bar = line.ProgressBar

				if bar then
					bar.Bar.Label:SetText(bar.data.standing)
				end
			end
		end
	end

	function CHAR_INFO_TRACKER_MODULE:OnBlockHeaderLeave(block)
		block.isHighlighted = nil

		if block.HeaderText then
			local headerColorStyle = _G.OBJECTIVE_TRACKER_COLOR["Normal"]

			block.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b)
			block.HeaderText.colorStyle = headerColorStyle
		end

		if block.type == "reputation" then
			for _, line in pairs(block.lines) do
				local bar = line.ProgressBar

				if bar then
					bar.Bar.Label:SetText(bar.data.text or (bar.data.cur.." / "..bar.data.max))
				end
			end
		end
	end

	local function CharInfo_UntrackStat(dropDownButton, statType)
		if statType == "honor" then
			_G.SetWatchingHonorAsXP(false)

			_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
		elseif statType == "reputation" then
			_G.SetWatchedFactionIndex(0)

			_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
		end

	end

	local function CharInfo_OnOpenDropDown(self)
		local block = self.activeFrame

		local info = _G.UIDropDownMenu_CreateInfo()
		info.text = block.name
		info.isTitle = 1
		info.notCheckable = 1
		_G.UIDropDownMenu_AddButton(info)
		twipe(info)

		info.notCheckable = 1
		info.text = _G.OBJECTIVES_STOP_TRACKING
		info.func = CharInfo_UntrackStat
		info.arg1 = block.type
		info.checked = false
		_G.UIDropDownMenu_AddButton(info)
	end

	function CHAR_INFO_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
		if block.type == "honor" or block.type == "reputation" then
			if mouseButton == "LeftButton" then
				_G.CloseDropDownMenus()

				if _G.IsModifiedClick("QUESTWATCHTOGGLE") then
					CharInfo_UntrackStat(nil, block.type)
				end
			else
				_G.ObjectiveTracker_ToggleDropDown(block, CharInfo_OnOpenDropDown)
			end
		end
	end

	------------------
	-- PROGRESS BAR --
	------------------

	local function CharInfoProgressBar_SetValue(self, cur, max, color, text)
		self.Bar:SetValue(cur)
		self.Bar:SetStatusBarColor(color.r, color.g, color.b)
		self.Bar.Label:SetText(text or (cur.." / "..max))
	end

	local function CharInfoProgressBar_OnEvent(self, event, ...)
		if event == "PLAYER_XP_UPDATE" then
			local cur = _G.UnitXP("player")
			local max = _G.UnitXPMax("player")
			local r, g, b = unpack(M.colors.experience)

			self.Bar:SetMinMaxValues(0, max)
			CharInfoProgressBar_SetValue(self, cur, max, {r = r, g = g, b = b})
		elseif event == "HONOR_XP_UPDATE" then
			local isMaxHonorLevel = _G.UnitHonorLevel("player") == _G.GetMaxPlayerHonorLevel()
			local cur = isMaxHonorLevel and 1 or _G.UnitHonor("player")
			local max = isMaxHonorLevel and 1 or _G.UnitHonorMax("player")
			local text = isMaxHonorLevel and (_G.CanPrestige() and _G.PVP_HONOR_PRESTIGE_AVAILABLE or _G.MAX_HONOR_LEVEL) or nil
			local r, g, b = unpack(M.colors.honor)

			CharInfoProgressBar_SetValue(self, cur, max, {r = r, g = g, b = b}, text)
		end
	end

	function CHAR_INFO_TRACKER_MODULE:AddProgressBar(block, line, barData)
		local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line]

		if not progressBar then
			local numBars = #self.freeProgressBars

			if numBars > 0 then
				progressBar = tremove(self.freeProgressBars, numBars)
				progressBar:SetParent(block)
			else
				progressBar = _G.CreateFrame("Frame", nil, block, "ObjectiveTrackerProgressBarTemplate")
				progressBar:SetSize(212, 13)
				progressBar:SetScript("OnEvent", CharInfoProgressBar_OnEvent)

				progressBar.Bar:SetAllPoints()
				progressBar.Bar.BorderLeft:ClearAllPoints()
				progressBar.Bar.BorderLeft:SetPoint("TOPLEFT", -3, 3)
				progressBar.Bar.BorderLeft:SetSize(9, 19)
				progressBar.Bar.BorderLeft:SetTexCoord(2 / 256, 11 / 256, 6 / 32, 25 / 32)
				progressBar.Bar.BorderRight:ClearAllPoints()
				progressBar.Bar.BorderRight:SetPoint("TOPRIGHT", 3, 3)
				progressBar.Bar.BorderRight:SetSize(9, 19)
				progressBar.Bar.BorderRight:SetTexCoord(11 / 256, 2 / 256, 6 / 32, 25 / 32)
				progressBar.Bar.BorderMid:SetTexCoord(29 / 256, 38 / 256, 6 / 32, 25 / 32)
				progressBar.Bar.Label:SetFontObject("GameFontHighlightSmall")
				progressBar.Bar.Label:SetJustifyV("TOP")
				progressBar.Bar.Label:SetSize(0, 0)
				progressBar.Bar.Label:ClearAllPoints()
				progressBar.Bar.Label:SetPoint("CENTER", 0, 0)
			end

			if not self.usedProgressBars[block] then
				self.usedProgressBars[block] = {}
			end

			self.usedProgressBars[block][line] = progressBar

			progressBar:SetPoint("TOPLEFT", block.HeaderText, "BOTTOMLEFT", 0, -block.module.lineSpacing)
			progressBar:Show()
		end

		if barData.type == "xp" then
			progressBar:RegisterEvent("PLAYER_XP_UPDATE")
		elseif barData.type == "honor" then
			progressBar:RegisterEvent("HONOR_XP_UPDATE")
		end

		progressBar.block = block
		progressBar.data = barData
		progressBar.height = progressBar:GetHeight()
		progressBar.Bar:SetMinMaxValues(0, barData.max)
		CharInfoProgressBar_SetValue(progressBar, barData.cur, barData.max, barData.color, barData.text)

		line.ProgressBar = progressBar
		block.height = block.height + progressBar.height + block.module.lineSpacing

		return progressBar
	end

	function CHAR_INFO_TRACKER_MODULE:FreeProgressBar(block, line)
		local progressBar = line.ProgressBar

		if progressBar then
			self.usedProgressBars[block][line] = nil
			line.ProgressBar = nil

			progressBar:ClearAllPoints()
			progressBar:Hide()
			progressBar:UnregisterEvent("HONOR_XP_UPDATE")
			progressBar:UnregisterEvent("PLAYER_XP_UPDATE")
			tinsert(self.freeProgressBars, progressBar)
		end
	end

	------------
	-- UPDATE --
	------------

	function CHAR_INFO_TRACKER_MODULE:Update()
		CHAR_INFO_TRACKER_MODULE:BeginLayout()

		if C.char_info.enabled then
			if C.char_info.xp_enabled then
				if _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL and not _G.IsXPUserDisabled() then
					local r, g, b = unpack(M.colors.experience)
					local hex = E:RGBToHEX(r, g, b)

					local block = CHAR_INFO_TRACKER_MODULE:GetBlock(1)
					block.name = EXPERIENCE
					block.type = "xp"

					local line = CHAR_INFO_TRACKER_MODULE:AddObjective(block, 1, " ", nil, nil, _G.OBJECTIVE_DASH_STYLE_HIDE)

					CHAR_INFO_TRACKER_MODULE:SetBlockHeader(block, "Bonus XP: |cff"..hex..(_G.GetXPExhaustion() or 0).."|r")

					local barData = {
						cur = _G.UnitXP("player"),
						max = _G.UnitXPMax("player"),
						color = {r = r, g = g, b = b},
						type = "xp",
					}

					CHAR_INFO_TRACKER_MODULE:AddProgressBar(block, line, barData)

					block:SetHeight(block.height)

					if _G.ObjectiveTracker_AddBlock(block) then
						block:Show()
					else
						block.used = false
					end
				end
			end

			if C.char_info.honor_enabled then
				-- FIX-ME: 110 -> MAX_PLAYER_LEVEL, when Legion hits Live
				if _G.UnitLevel("player") >= 110 and (_G.IsWatchingHonorAsXP() or _G.InActiveBattlefield()) then
					local isMaxHonorLevel = _G.UnitHonorLevel("player") == _G.GetMaxPlayerHonorLevel()
					local cur = isMaxHonorLevel and 1 or _G.UnitHonor("player")
					local max = isMaxHonorLevel and 1 or _G.UnitHonorMax("player")
					local text = isMaxHonorLevel and (_G.CanPrestige() and _G.PVP_HONOR_PRESTIGE_AVAILABLE or _G.MAX_HONOR_LEVEL) or nil

					local r, g, b = unpack(M.colors.honor)
					local hex = E:RGBToHEX(r, g, b)

					local block = CHAR_INFO_TRACKER_MODULE:GetBlock(3)
					block.name = _G.HONOR
					block.type = "honor"

					local line = CHAR_INFO_TRACKER_MODULE:AddObjective(block, 1, " ", nil, nil, _G.OBJECTIVE_DASH_STYLE_HIDE)

					CHAR_INFO_TRACKER_MODULE:SetBlockHeader(block, _G.BONUS_HONOR.." |cff"..hex..(_G.GetHonorExhaustion() or 0).."|r")

					local barData = {
						cur = cur,
						max = max,
						text = text,
						color = {r = r, g = g, b = b},
						type = "honor",
					}

					CHAR_INFO_TRACKER_MODULE:AddProgressBar(block, line, barData)

					block:SetHeight(block.height)

					if _G.ObjectiveTracker_AddBlock(block) then
						block:Show()
					else
						block.used = false
					end
				end
			end

			if C.char_info.artifact_enabled then
				if _G.HasArtifactEquipped() then
					local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = _G.C_ArtifactUI.GetEquippedArtifactInfo()
					local points, xpCur, xpMax = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
					local r, g, b = unpack(M.colors.artifact)
					local hex = E:RGBToHEX(r, g, b)

					local block = CHAR_INFO_TRACKER_MODULE:GetBlock(2)
					block.name = _G.ARTIFACT_POWER
					block.type = "artifact"

					local line = CHAR_INFO_TRACKER_MODULE:AddObjective(block, 1, " ", nil, nil, _G.OBJECTIVE_DASH_STYLE_HIDE)

					CHAR_INFO_TRACKER_MODULE:SetBlockHeader(block, "Trait points: |cff"..hex..points.."|r")

					local barData = {
						cur = xpCur,
						max = xpMax,
						color = {r = r, g = g, b = b},
						type = "artifact",
					}

					CHAR_INFO_TRACKER_MODULE:AddProgressBar(block, line, barData)

					block:SetHeight(block.height)

					if _G.ObjectiveTracker_AddBlock(block) then
						block:Show()
					else
						block.used = false
					end
				end
			end

			if C.char_info.reputation_enabled then
				local name, standing, repMin, repMax, repValue, factionID = _G.GetWatchedFactionInfo()

				if name then
					local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = _G.GetFriendshipReputation(factionID)
					local standingText = _G.GetText("FACTION_STANDING_LABEL"..standing, _G.UnitSex("player"))
					local cur, max = 1, 1
					local text

					local block = CHAR_INFO_TRACKER_MODULE:GetBlock(4)
					block.name = _G.REPUTATION
					block.type = "reputation"

					local line = CHAR_INFO_TRACKER_MODULE:AddObjective(block, 1, " ", nil, nil, _G.OBJECTIVE_DASH_STYLE_HIDE)

					if friendRep then
						if nextFriendThreshold then
							cur, max = friendRep - friendThreshold, nextFriendThreshold - friendThreshold
						end

						standing = 5
						standingText = friendTextLevel
					else
						cur, max = repValue - repMin, repMax - repMin
					end

					CHAR_INFO_TRACKER_MODULE:SetBlockHeader(block, utf8len(name) > 26 and utf8sub(name, 1, 26).."..." or name)

					local barData = {
						cur = cur,
						max = max,
						text = max == 1 and standingText or nil,
						color = _G.FACTION_BAR_COLORS[standing],
						type = "reputation",
						standing = standingText,
					}

					CHAR_INFO_TRACKER_MODULE:AddProgressBar(block, line, barData)

					block:SetHeight(block.height)

					if _G.ObjectiveTracker_AddBlock(block) then
						block:Show()
					else
						block.used = false
					end
				end
			end
		end

		CHAR_INFO_TRACKER_MODULE:EndLayout()
	end

	_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
end

----------------
-- HONOR HOOK --
----------------

local function WatchHonorAsXP(...)
	local _, _, _, value = ...

	if value then
		_G.PlaySound("igMainMenuOptionCheckBoxOff")
		_G.SetWatchingHonorAsXP(false)
	else
		_G.PlaySound("igMainMenuOptionCheckBoxOn")
		_G.SetWatchingHonorAsXP(true)
	end

	_G.MainMenuBar_UpdateExperienceBars()

	if not _G.ObjectiveTrackerFrame.BlocksFrame.CharInfoHeader:IsShown() then
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
	else
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
	end
end

local function InitializePVPTalentsXPBarDropDown(self, level)
	local info = _G.UIDropDownMenu_CreateInfo()

	info.isNotRadio = true
	info.text = _G.SHOW_FACTION_ON_MAINSCREEN
	info.checked = _G.IsWatchingHonorAsXP()
	info.func = WatchHonorAsXP
	_G.UIDropDownMenu_AddButton(info, level)
	twipe(info)

	info.notCheckable = true
	info.text = _G.CANCEL
	_G.UIDropDownMenu_AddButton(info, level)
end

local function PlayerTalentFramePVPTalentsXPBar_OnClick(self, button)
	if button == "RightButton" then
		_G.UIDropDownMenu_Initialize(self.DropDown, InitializePVPTalentsXPBarDropDown, "MENU")
		_G.ToggleDropDownMenu(1, nil, self.DropDown, self, 310, 12)
	end
end

--------------
-- REP HOOK --
--------------

local function ReputationDetailMainScreenCheckBox_OnClick(self)
	if self:GetChecked() then
		_G.PlaySound("igMainMenuOptionCheckBoxOn")
		_G.SetWatchedFactionIndex(_G.GetSelectedFaction())
	else
		_G.PlaySound("igMainMenuOptionCheckBoxOff")
		_G.SetWatchedFactionIndex(0)
	end

	_G.MainMenuBar_UpdateExperienceBars()
end

-----------
-- UTILS --
-----------

local function UpdateObjectiveTracker()
	if not _G.ObjectiveTrackerFrame.BlocksFrame.CharInfoHeader:IsShown() then
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
	else
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
	end
end

local function EventHandler(self, event, ...)
	if event == "PLAYER_EQUIPMENT_CHANGED" then
		local slotID = ...

		if slotID == 16 or slotID == 17 then
			UpdateObjectiveTracker()
		end
	else
		UpdateObjectiveTracker()
	end
end

function STATS:ToggleXP(flag)
	-- FIX-ME
	if flag ~= nil then
		C.char_info.xp_enabled = flag
	end

	if C.char_info.enabled and C.char_info.xp_enabled then
		STATS:RegisterEvent("DISABLE_XP_GAIN")
		STATS:RegisterEvent("ENABLE_XP_GAIN")
		STATS:RegisterEvent("PLAYER_LEVEL_UP")
		STATS:RegisterEvent("UPDATE_EXHAUSTION")
	else
		STATS:UnregisterEvent("DISABLE_XP_GAIN")
		STATS:UnregisterEvent("ENABLE_XP_GAIN")
		STATS:UnregisterEvent("PLAYER_LEVEL_UP")

		if not C.char_info.enabled or not C.char_info.honor_enabled then
			STATS:UnregisterEvent("UPDATE_EXHAUSTION")
		end
	end

	UpdateObjectiveTracker()
end

function STATS:ToggleHonor(flag)
	-- FIX-ME
	if flag ~= nil then
		C.char_info.honor_enabled = flag
	end

	if C.char_info.enabled and C.char_info.honor_enabled then
		STATS:RegisterEvent("HONOR_LEVEL_UPDATE")
		STATS:RegisterEvent("HONOR_PRESTIGE_UPDATE")
		STATS:RegisterEvent("UPDATE_EXHAUSTION")
	else
		STATS:UnregisterEvent("HONOR_LEVEL_UPDATE")
		STATS:UnregisterEvent("HONOR_PRESTIGE_UPDATE")

		if not C.char_info.enabled or not C.char_info.xp_enabled then
			STATS:UnregisterEvent("UPDATE_EXHAUSTION")
		end
	end

	UpdateObjectiveTracker()
end

function STATS:ToggleArtifact(flag)
	-- FIX-ME
	if flag ~= nil then
		C.char_info.artifact_enabled = flag
	end

	if C.char_info.enabled and C.char_info.artifact_enabled then
		STATS:RegisterEvent("ARTIFACT_XP_UPDATE")
		-- XXX: UNIT_INVENTORY_CHANGED is way too spammy
		STATS:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	else
		STATS:UnregisterEvent("ARTIFACT_XP_UPDATE")
		STATS:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	end

	UpdateObjectiveTracker()
end

function STATS:ToggleReputation(flag)
	-- FIX-ME
	if flag ~= nil then
		C.char_info.reputation_enabled = flag
	end

	if C.char_info.enabled and C.char_info.reputation_enabled then
		STATS:RegisterEvent("UPDATE_FACTION")
	else
		STATS:UnregisterEvent("UPDATE_FACTION")
	end

	UpdateObjectiveTracker()
end

function STATS:IsLoaded()
	return isInitialized, isEnabled
end

function STATS:Refresh(flag)
	-- FIX-ME
	C.char_info.enabled = flag
	isEnabled = flag

	STATS:ToggleXP()
	STATS:ToggleHonor()
	STATS:ToggleArtifact()
	STATS:ToggleReputation()
end

function STATS:Initialize(forceEnable)
	-- FIX-ME: I need to rewrite how config refreshes values
	if forceEnable then
		C.char_info.enabled = true
	end

	if C.char_info.enabled then
		STATS:SetScript("OnEvent", EventHandler)

		if not _G.ObjectiveTracker_Initialize then
			_G.UIParentLoadAddOn("Blizzard_ObjectiveTracker")
		end

		if not _G.ObjectiveTrackerFrame.initialized then
			_G.hooksecurefunc("ObjectiveTracker_Initialize", function()
				CreateCharInfoTracker()

				STATS:Refresh(true)
			end)
		else
			CreateCharInfoTracker()

			STATS:Refresh(true)
		end

		-- XXX: This way I can show honour and reputation bars together
		_G.hooksecurefunc("TalentFrame_LoadUI", function()
			if not isHonorBarHooked then
				_G.PlayerTalentFramePVPTalents.XPBar:SetScript("OnMouseUp", PlayerTalentFramePVPTalentsXPBar_OnClick)

				isHonorBarHooked = true
			end
		end)

		_G.ReputationDetailMainScreenCheckBox:SetScript("OnClick", ReputationDetailMainScreenCheckBox_OnClick)

		isInitialized = true
		isEnabled = true
	end
end
