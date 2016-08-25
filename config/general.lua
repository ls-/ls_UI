local _, ns = ...
local oUF, E, C, D = ns.oUF or oUF, ns.E, ns.C, ns.D
local CFG = E:GetModule("Config")
local STATS = E:GetModule("Stats")
local BLIZZARD = E:GetModule("Blizzard")

-- Lua
local _G = _G
local pairs = pairs
local tinsert = table.insert

-- Mine
local SUCCESS_TEXT = "|cff26a526Success!|r"
local WARNING_TEXT = "|cffffd100Warning!|r"
-- local ERROR_TEXT = "|cffe52626Error!|r"
local panel

local function LSGeneralConfigPanel_OnShow(self)
	for _, controller in pairs(self.controllers) do
		CFG:ToggleDependantControls(controller)
	end

	self.StatusLog:SetText("")
end

local function OTToggle_OnClick(self)
	local checked = self:GetValue()
	local initialized = BLIZZARD:OT_IsLoaded()

	if checked then
		if not initialized then
			BLIZZARD:OT_Initialize(true)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Enabled objective tracker module.")
		else
			panel.StatusLog:SetText(WARNING_TEXT.." Objective tracker module is already enabled.")
		end
	else
		if initialized then
			panel.StatusLog:SetText(WARNING_TEXT.." Objective tracker module will be disabled on next UI reload.")
		end
	end
end

local function CharInfoToggle_OnClick(self)
	local checked = self:GetValue()
	local initialized = STATS:IsLoaded()

	if checked then
		if not initialized then
			STATS:Initialize(true)
		else
			STATS:Refresh(true)
		end

		panel.StatusLog:SetText(SUCCESS_TEXT.." Enabled character info module for objective tracker.")
	else
		if initialized then
			STATS:Refresh(false)
		end

		panel.StatusLog:SetText(SUCCESS_TEXT.." Disabled character info module for objective tracker.")
	end
end

local function XPToggle_OnClick(self)
	local checked = self:GetValue()
	local _, enabled = STATS:IsLoaded()

	if enabled then
		if checked then
			STATS:ToggleXP(true)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Added XP bar to objective tracker. It\'ll be shown, when available.")
		else
			STATS:ToggleXP(false)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Removed XP bar from objective tracker.")
		end
	end
end

local function HonorToggle_OnClick(self)
	local checked = self:GetValue()
	local _, enabled = STATS:IsLoaded()

	if enabled then
		if checked then
			STATS:ToggleHonor(true)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Added honour bar to objective tracker. It\'ll be shown, when available.")
		else
			STATS:ToggleHonor(false)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Removed honour bar from objective tracker.")
		end
	end
end

local function ArtifactToggle_OnClick(self)
	local checked = self:GetValue()
	local _, enabled = STATS:IsLoaded()

	if enabled then
		if checked then
			STATS:ToggleArtifact(true)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Added artefact power bar to objective tracker. It\'ll be shown, when available.")
		else
			STATS:ToggleArtifact(false)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Removed artefact power bar from objective tracker.")
		end
	end
end

local function RepToggle_OnClick(self)
	local checked = self:GetValue()
	local _, enabled = STATS:IsLoaded()

	if enabled then
		if checked then
			STATS:ToggleReputation(true)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Added reputation bar to objective tracker. It\'ll be shown, when available.")
		else
			STATS:ToggleReputation(false)

			panel.StatusLog:SetText(SUCCESS_TEXT.." Removed reputation bar from objective tracker.")
		end
	end
end

function CFG:General_Initialize()
	panel = _G.CreateFrame("Frame", "LSGeneralConfigPanel", _G.InterfaceOptionsFramePanelContainer)
	panel.name = "|cff1a9fc0ls:|r UI"
	panel:HookScript("OnShow", LSGeneralConfigPanel_OnShow)
	panel:Hide()

	panel.settings = {}
	panel.settings.units = {
		player = {},
		pet = {},
		target = {},
		targettarget = {},
		focus = {},
		focustarget = {},
		party = {},
		boss = {},
		arena = {}
	}

	local header1 = CFG:CreateTextLabel(panel, 16, "|cffffd100General|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local subText = CFG:CreateTextLabel(panel, 10, "Thome thettings, duh...")
	subText:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)
	subText:SetPoint("RIGHT", -16, 0)
	subText:SetHeight(32)
	subText:SetMaxLines(3)

	local divider = CFG:CreateDivider(panel, "Unit Frames")
	divider:SetPoint("TOP", subText, "BOTTOM", 0, -10)

	local ufToggle = CFG:CreateCheckButton(panel, "UFToggle", nil, "Switches unit frame module on or off.")
	ufToggle:SetPoint("TOP", divider, "TOP", 0, 11)
	ufToggle:SetPoint("RIGHT", -16, 0)
	panel.settings.units.enabled = ufToggle
	CFG:SetupController(panel, ufToggle)

	local button1 = CFG:CreateCheckButton(panel, "PlayerPetFramesToggle", "Player & Pet")
	button1:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 4, -8)
	panel.settings.units.player.enabled = button1
	panel.settings.units.pet.enabled = button1
	CFG:SetupControlDependency(ufToggle, button1)

	local button2 = CFG:CreateCheckButton(panel, "TargetToTFramesToggle", "Target & ToT")
	button2:SetPoint("LEFT", button1, "RIGHT", 110, 0)
	panel.settings.units.target.enabled = button2
	panel.settings.units.targettarget.enabled = button2
	CFG:SetupControlDependency(ufToggle, button2)

	local button3 = CFG:CreateCheckButton(panel, "FocusToFFramesToggle", "Focus & ToF")
	button3:SetPoint("LEFT", button2, "RIGHT", 110, 0)
	panel.settings.units.focus.enabled = button3
	panel.settings.units.focustarget.enabled = button3
	CFG:SetupControlDependency(ufToggle, button3)

	local button4 = CFG:CreateCheckButton(panel, "PartyFramesToggle", "Party")
	button4:SetPoint("LEFT", button3, "RIGHT", 110, 0)
	panel.settings.units.party.enabled = button4
	CFG:SetupControlDependency(ufToggle, button4)

	local button5 = CFG:CreateCheckButton(panel, "BossFramesToggle", "Boss")
	button5:SetPoint("TOPLEFT", button1, "BOTTOMLEFT", 0, -8)
	panel.settings.units.boss.enabled = button5
	CFG:SetupControlDependency(ufToggle, button5)

	local button6 = CFG:CreateCheckButton(panel, "ArenaFramesToggle", "Arena")
	button6:SetPoint("LEFT", button5, "RIGHT", 110, 0)
	panel.settings.units.arena.enabled = button6
	CFG:SetupControlDependency(ufToggle, button6)

	local button7 = CFG:CreateCheckButton(panel, "CastbarToggle", "Castbars", "Switches player, target and focus castbars on or off.")
	button7:SetPoint("LEFT", button6, "RIGHT", 110, 0)
	panel.settings.units.player.castbar = button7
	panel.settings.units.pet.castbar = button7
	panel.settings.units.target.castbar = button7
	panel.settings.units.focus.castbar = button7
	CFG:SetupControlDependency(ufToggle, button7)

	divider = CFG:CreateDivider(panel, "Objective Tracker")
	divider:SetPoint("TOP", button6, "BOTTOM", 0, -12)

	subText = CFG:CreateTextLabel(panel, 10, "By enabling this module, you'll be able to move objective tracker and change its height.\n"..WARNING_TEXT.." If you're using other addons that alter objective tracker behaviour, disable this feature.")
	subText:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)
	subText:SetPoint("RIGHT", -16, 0)
	subText:SetHeight(32)
	subText:SetMaxLines(3)

	panel.settings.blizzard = {
		ot = {}
	}

	local otToggle = CFG:CreateCheckButton(panel, "OTToggle", nil, "Switches objective tracker module on or off.")
	otToggle:SetPoint("TOP", divider, "TOP", 0, 11)
	otToggle:SetPoint("RIGHT", -16, 0)
	otToggle:HookScript("OnClick", OTToggle_OnClick)
	panel.settings.blizzard.ot.enabled = otToggle
	CFG:SetupController(panel, otToggle)

	local slider1 = CFG:CreateSlider(panel, "$parentOTHeightSlider", _G.COMPACT_UNIT_FRAME_PROFILE_FRAMEHEIGHT, 10, 400, 1000)
	slider1:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", 10, -16)
	slider1:HookScript("OnValueChanged", function(self, value, userInput)
		if userInput then
			if value ~= self.oldValue then
				BLIZZARD:OT_SetHeight(value)

				self.oldValue = value
			end
		end
	end)
	panel.settings.blizzard.ot.height = slider1
	CFG:SetupControlDependency(otToggle, slider1)

	divider = CFG:CreateDivider(panel, "Character Info")
	divider:SetPoint("TOP", slider1, "BOTTOM", 0, -16)

	subText = CFG:CreateTextLabel(panel, 10, "Here you can enable experience, honour, artefact power and reputation bars for your objective tracker.")
	subText:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)
	subText:SetPoint("RIGHT", -16, 0)
	subText:SetHeight(32)
	subText:SetMaxLines(3)

	panel.settings.char_info = {}

	local charInfoToggle = CFG:CreateCheckButton(panel, "CharInfoToggle", nil, "Switches character info module for objective tracker on or off.")
	charInfoToggle:SetPoint("TOP", divider, "TOP", 0, 11)
	charInfoToggle:SetPoint("RIGHT", -16, 0)
	charInfoToggle:HookScript("OnClick", CharInfoToggle_OnClick)
	panel.settings.char_info.enabled = charInfoToggle
	CFG:SetupController(panel, charInfoToggle)

	local button14 = CFG:CreateCheckButton(panel, "OTXPToggle", "Experience")
	button14:SetPoint("TOPLEFT", subText, "BOTTOMLEFT", -2, -8)
	button14:HookScript("OnClick", XPToggle_OnClick)
	panel.settings.char_info.xp_enabled = button14
	CFG:SetupControlDependency(charInfoToggle, button14)

	local button15 = CFG:CreateCheckButton(panel, "OTHonorToggle", "Honour", "|cffe52626Available at level 110.|r\nOpen \"".._G.PVP_TALENTS.."\" panel, right-click the bar and choose \"".._G.SHOW_FACTION_ON_MAINSCREEN.."\".")
	button15:SetPoint("LEFT", button14, "RIGHT", 110, 0)
	button15:HookScript("OnClick", HonorToggle_OnClick)
	panel.settings.char_info.honor_enabled = button15
	CFG:SetupControlDependency(charInfoToggle, button15)

	local button16 = CFG:CreateCheckButton(panel, "OTAPToggle", "Artefact Power")
	button16:SetPoint("LEFT", button15, "RIGHT", 110, 0)
	button16:HookScript("OnClick", ArtifactToggle_OnClick)
	panel.settings.char_info.artifact_enabled = button16
	CFG:SetupControlDependency(charInfoToggle, button16)

	local button17 = CFG:CreateCheckButton(panel, "OTHRepToggle", "Reputation")
	button17:SetPoint("LEFT", button16, "RIGHT", 110, 0)
	button17:HookScript("OnClick", RepToggle_OnClick)
	panel.settings.char_info.reputation_enabled = button17
	CFG:SetupControlDependency(charInfoToggle, button17)

	divider = CFG:CreateDivider(panel, "Other Modules")
	divider:SetPoint("TOP", button14, "BOTTOM", 0, -12)

	panel.settings.bars = {
		bags = {}
	}
	panel.settings.minimap = {}
	panel.settings.auras = {}
	panel.settings.mail = {}
	panel.settings.tooltips = {}

	local button10 = CFG:CreateCheckButton(panel, "MinimapToggle", "Minimap")
	button10:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 4, -8)
	panel.settings.minimap.enabled = button10

	local button11 = CFG:CreateCheckButton(panel, "AurasToggle", "Buffs & Debuffs")
	button11:SetPoint("LEFT", button10, "RIGHT", 110, 0)
	panel.settings.auras.enabled = button11

	local button12 = CFG:CreateCheckButton(panel, "MailToggle", "Mail")
	button12:SetPoint("LEFT", button11, "RIGHT", 110, 0)
	panel.settings.mail.enabled = button12

	local button13 = CFG:CreateCheckButton(panel, "TooltipsToggle", "Tooltips")
	button13:SetPoint("LEFT", button12, "RIGHT", 110, 0)
	panel.settings.tooltips.enabled = button13

	divider = CFG:CreateDivider(panel, "Side Notes")
	divider:SetPoint("TOP", button10, "BOTTOM", 0, -12)

	subText = CFG:CreateTextLabel(panel, 10, "Although in-game config is still WIP, you can use |cffffd100/lsmovers|r command to move unit frames and other layout elements around.")
	subText:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 6, -8)
	subText:SetPoint("RIGHT", -16, 0)
	subText:SetHeight(32)
	subText:SetMaxLines(3)

	local log1 = CFG:CreateStatusLog(panel)
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	log1:SetWidth(512)
	panel.StatusLog = log1

	local reloadButton = CFG:CreateReloadUIButton(panel)
	reloadButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)

	CFG:AddCatergory(panel)
end
