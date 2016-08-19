local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local Stats = E:AddModule("Stats", true)

-- Lua
local _G = _G
local unpack, pairs = unpack, pairs
local tinsert, tremove, twipe = table.insert, table.remove, table.wipe
local utf8len, utf8sub = string.utf8len, string.utf8sub

-- Blizz
_G.OBJECTIVE_TRACKER_UPDATE_ALL = 0xFFFFFFFF

-- Mine
local OBJECTIVE_TRACKER_UPDATE_CHAR_INFO = 0x40000000
local OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED = 0x80000000
local CHAR_INFO_TRACKER_MODULE = _G.ObjectiveTracker_GetModuleInfoTable()
local isHonorBarHooked = false
local charInfoHeader

function CHAR_INFO_TRACKER_MODULE:SetBlockHeader(block, text)
	local height = self:SetStringText(block.HeaderText, text, true, _G.OBJECTIVE_TRACKER_COLOR["Normal"], block.isHighlighted)
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
				bar.Bar.Label:SetText(bar.data.cur.." / "..bar.data.max)
			end
		end
	end
end

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

function CHAR_INFO_TRACKER_MODULE:Update()
	CHAR_INFO_TRACKER_MODULE:BeginLayout()

	if C.char_info.xp_enabled then
		if _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL and not _G.IsXPUserDisabled() then
			local r, g, b = unpack(M.colors.experience)
			local hex = E:RGBToHEX(r, g, b)

			local block = CHAR_INFO_TRACKER_MODULE:GetBlock(1)
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

	if C.char_info.artifact_enabled then
		if _G.HasArtifactEquipped() then
			local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = _G.C_ArtifactUI.GetEquippedArtifactInfo()
			local points, xpCur, xpMax = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
			local r, g, b = unpack(M.colors.artifact)
			local hex = E:RGBToHEX(r, g, b)

			local block = CHAR_INFO_TRACKER_MODULE:GetBlock(2)
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

	if C.char_info.honor_enabled then
		if _G.UnitLevel("player") >= _G.MAX_PLAYER_LEVEL and (_G.IsWatchingHonorAsXP() or _G.InActiveBattlefield()) then
			local isMaxHonorLevel = _G.UnitHonorLevel("player") == _G.GetMaxPlayerHonorLevel()
			local cur = isMaxHonorLevel and 1 or _G.UnitHonor("player")
			local max = isMaxHonorLevel and 1 or _G.UnitHonorMax("player")
			local text = isMaxHonorLevel and (_G.CanPrestige() and _G.PVP_HONOR_PRESTIGE_AVAILABLE or _G.MAX_HONOR_LEVEL) or nil

			local r, g, b = unpack(M.colors.honor)
			local hex = E:RGBToHEX(r, g, b)

			local block = CHAR_INFO_TRACKER_MODULE:GetBlock(3)
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

	if C.char_info.reputation_enabled then
		local name, standing, repMin, repMax, repValue, factionID = _G.GetWatchedFactionInfo()

		if name then
			local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = _G.GetFriendshipReputation(factionID)
			local standingText = _G.GetText("FACTION_STANDING_LABEL"..standing, _G.UnitSex("player"))
			local cur, max = 1, 1

			local block = CHAR_INFO_TRACKER_MODULE:GetBlock(4)
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

	CHAR_INFO_TRACKER_MODULE:EndLayout()
end

function Stats:DISABLE_XP_GAIN(...)
	print("DISABLE_XP_GAIN", ...)

	_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
end

function Stats:ENABLE_XP_GAIN(...)
	print("ENABLE_XP_GAIN", ...)

	if not charInfoHeader:IsShown() then
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
	else
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
	end
end

function Stats:PLAYER_LEVEL_UP(...)
	print("PLAYER_LEVEL_UP", ...)
	_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
end

function Stats:UPDATE_EXHAUSTION(...)
	print("UPDATE_EXHAUSTION", ...)
	_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
end

function Stats:ARTIFACT_XP_UPDATE(...)
	print("ARTIFACT_XP_UPDATE", ...)

	_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
end

function Stats:UNIT_INVENTORY_CHANGED(...)
	print("UNIT_INVENTORY_CHANGED", ...)
	local unit = ...

	if unit == "player" then
		if not charInfoHeader:IsShown() then
			_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
		else
			_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
		end
	end
end

function Stats:UPDATE_FACTION(...)
	print("UPDATE_FACTION", ...)

	if not charInfoHeader:IsShown() then
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
	else
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
	end
end

function Stats:HONOR_LEVEL_UPDATE(...)
	print("HONOR_LEVEL_UPDATE", ...)

	if not charInfoHeader:IsShown() then
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
	else
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
	end
end

function Stats:HONOR_PRESTIGE_UPDATE(...)
	print("HONOR_PRESTIGE_UPDATE", ...)

	if not charInfoHeader:IsShown() then
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
	else
		_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO)
	end
end

local function CreateCharInfoTracker()
	charInfoHeader = _G.CreateFrame("Frame", nil, _G.ObjectiveTrackerBlocksFrame, "ObjectiveTrackerHeaderTemplate")
	_G.ObjectiveTrackerFrame.BlocksFrame.CharInfoHeader = charInfoHeader

	CHAR_INFO_TRACKER_MODULE.updateReasonEvents = OBJECTIVE_TRACKER_UPDATE_CHAR_INFO + OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED
	CHAR_INFO_TRACKER_MODULE.usedBlocks = {}
	CHAR_INFO_TRACKER_MODULE.lineSpacing = 5
	CHAR_INFO_TRACKER_MODULE.blockOffsetY = -5
	CHAR_INFO_TRACKER_MODULE:SetHeader(_G.ObjectiveTrackerFrame.BlocksFrame.CharInfoHeader, _G.CHARACTER_INFO, OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)
	tinsert(_G.ObjectiveTrackerFrame.MODULES, 1, CHAR_INFO_TRACKER_MODULE)

	_G.ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_CHAR_INFO_ADDED)

	if C.char_info.xp_enabled then
		Stats:RegisterEvent("DISABLE_XP_GAIN")
		Stats:RegisterEvent("ENABLE_XP_GAIN")
		Stats:RegisterEvent("PLAYER_LEVEL_UP")
		Stats:RegisterEvent("UPDATE_EXHAUSTION")
	end

	if C.char_info.artifact_enabled then
		Stats:RegisterEvent("ARTIFACT_XP_UPDATE")
		Stats:RegisterEvent("UNIT_INVENTORY_CHANGED")
	end

	if C.char_info.honor_enabled then
		Stats:RegisterEvent("HONOR_LEVEL_UPDATE")
		Stats:RegisterEvent("HONOR_PRESTIGE_UPDATE")
		Stats:RegisterEvent("UPDATE_EXHAUSTION")
	end

	if C.char_info.reputation_enabled then
		Stats:RegisterEvent("UPDATE_FACTION")
	end
end

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

	if not charInfoHeader:IsShown() then
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

local function HookHonorBar()
	if not isHonorBarHooked then
		_G.PlayerTalentFramePVPTalents.XPBar:SetScript("OnMouseUp", PlayerTalentFramePVPTalentsXPBar_OnClick)

		isHonorBarHooked = true
	end
end

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

function Stats:Initialize()
	if C.char_info.enabled then
		if not _G.ObjectiveTracker_Initialize then
			_G.UIParentLoadAddOn("Blizzard_ObjectiveTracker")
		end

		_G.hooksecurefunc("ObjectiveTracker_Initialize", CreateCharInfoTracker)

		-- XXX: This way I can show honour and reputation bars together
		_G.hooksecurefunc("TalentFrame_LoadUI", HookHonorBar)

		_G.ReputationDetailMainScreenCheckBox:SetScript("OnClick", ReputationDetailMainScreenCheckBox_OnClick)
	end
end

-- HONOR_XP_UPDATE

-- PLAYER_XP_UPDATE - Update
-- UPDATE_EXHAUSTION - Update
-- PLAYER_LEVEL_UP - Update

-- UNIT_INVENTORY_CHANGED - visibility
-- ARTIFACT_XP_UPDATE

-- UPDATE_FACTION - Update
