local _, ns = ...
local oUF, E, C, D = ns.oUF or oUF, ns.E, ns.C, ns.D
local CFG = E:GetModule("Config")

local tinsert = table.insert

local function LSGeneralConfigPanel_OnShow(self)
	for _, controller in next, self.controllers do
		CFG:ToggleDependantControls(controller)
	end
end

local function UFToggle_OnClick(self)
	CFG:ToggleDependantControls(self)
end

local function ABToggle_OnClick(self)
	CFG:ToggleDependantControls(self)
end

function CFG:General_Initialize()
	local panel = CreateFrame("Frame", "LSGeneralConfigPanel", InterfaceOptionsFramePanelContainer)
	panel.name = "oUF: |cff1a9fc0LS|r"
	panel:HookScript("OnShow", LSGeneralConfigPanel_OnShow)
	panel:Hide()

	panel.controllers = {}

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

	local infoText1 = CFG:CreateTextLabel(panel, 10, "WIP general settings.")
	infoText1:SetHeight(32)
	infoText1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)
	infoText1:SetPoint("RIGHT", -16, 0)

	local header2 = CFG:CreateTextLabel(panel, 16, "|cffffd100Unit Frames|r")
	header2:SetPoint("TOPLEFT", infoText1, "BOTTOMLEFT", 0, -8)

	local ufToggle = CFG:CreateCheckButton(panel, "UFToggle", nil, "Switches unit frame module on or off")
	ufToggle:HookScript("OnClick", UFToggle_OnClick)
	ufToggle:SetPoint("TOP", infoText1, "BOTTOM", 0, -6)
	ufToggle:SetPoint("RIGHT", -16, 0)
	tinsert(panel.controllers, ufToggle)
	panel.settings.units.enabled = ufToggle

	local button1 = CFG:CreateCheckButton(panel, "PlayerPetFramesToggle", "Player & Pet")
	button1:SetPoint("TOPLEFT", header2, "BOTTOMLEFT", -2, -8)
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

	local button7 = CFG:CreateCheckButton(panel, "CastbarToggle", "Castbars", "Switches player, target and focus castbars on or off")
	button7:SetPoint("TOPLEFT", button5, "BOTTOMLEFT", 0, -8)
	panel.settings.units.player.castbar = button7
	panel.settings.units.pet.castbar = button7
	panel.settings.units.target.castbar = button7
	panel.settings.units.focus.castbar = button7
	CFG:SetupControlDependency(ufToggle, button7)

	local divider1 = CFG:CreateDivider(panel)
	divider1:SetPoint("TOP", button7, "BOTTOM", 0, -8)

	panel.settings.bars = {
		bags = {}
	}
	panel.settings.minimap = {}
	panel.settings.auras = {}
	panel.settings.mail = {}
	panel.settings.tooltips = {}

	local header3 = CFG:CreateTextLabel(panel, 16, "|cffffd100Other Modules|r")
	header3:SetPoint("LEFT", 16, 0)
	header3:SetPoint("TOP", divider1, "BOTTOM", 0, -8)

	local button10 = CFG:CreateCheckButton(panel, "MinimapToggle", "Minimap")
	button10:SetPoint("TOPLEFT", header3, "BOTTOMLEFT", -2, -8)
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

	local divider2 = CFG:CreateDivider(panel)
	divider2:SetPoint("TOP", button10, "BOTTOM", 0, -8)

	local header4 = CFG:CreateTextLabel(panel, 16, "|cffffd100Info|r")
	header4:SetPoint("LEFT", 16, 0)
	header4:SetPoint("TOP", divider2, "BOTTOM", 0, -8)

	local infoText2 = CFG:CreateTextLabel(panel, 10, "Although in-game config is still WIP, you can use |cffffd100/lsmovers|r command to move unit frames and other layout elements around.")
	infoText2:SetHeight(32)
	infoText2:SetPoint("TOPLEFT", header4, "BOTTOMLEFT", 0, -8)
	infoText2:SetPoint("RIGHT", -16, 0)

	local reloadButton = CFG:CreateReloadUIButton(panel)
	reloadButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)

	CFG:AddCatergory(panel)
end
