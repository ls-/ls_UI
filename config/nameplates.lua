local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D
local CFG = E:GetModule("Config")
local NP = E:GetModule("NamePlates")

local function NPConfigPanel_OnShow(self)
	if InCombatLockdown() then
		self.StatusLog:SetText("|cffe52626Error!|r Can't be done, while in combat.")

		return
	end

	self.StatusLog:SetText("")

	CFG.ToggleDependantControls(self.NPToggle, not NP:IsEnabled())
end

local function NPToggle_OnClick(self)
	local result, msg
	local parent = self:GetParent()

	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())
	end

	if not self:GetChecked() then
		msg = "|cff26a526Success!|r NP will be disabled on next UI reload."
	else
		result, msg = NP:Enable()
	end

	CFG.ToggleDependantControls(parent.NPToggle, not NP:IsEnabled())

	parent.StatusLog:SetText(msg)
end

local function CBToggle_OnClick(self)
	local result, msg
	local parent = self:GetParent()

	if InCombatLockdown() then
		self:SetChecked(not self:GetChecked())
	end

	if not self:GetChecked() then
		result, msg = NP:DisableComboBar()
	else
		result, msg = NP:EnableComboBar()
	end

	parent.StatusLog:SetText(msg)
end

local function HPTextToggle_OnClick(self)
	local result, msg
	local parent = self:GetParent()

	if not self:GetChecked() then
		result, msg = NP:HideHealthText()
	else
		result, msg = NP:ShowHealthText()
	end

	parent.StatusLog:SetText(msg)
end

function CFG:NP_Initialize()
	local panel = CreateFrame("Frame", "LSNPConfigPanel", InterfaceOptionsFramePanelContainer)
	panel.name = "Nameplates"
	panel.parent = "oUF: |cff1a9fc0LS|r"
	panel:HookScript("OnShow", NPConfigPanel_OnShow)
	panel:Hide()

	panel.settings = {
		nameplates = {},
	}

	local header1 = CFG:CreateTextLabel(panel, 16, "|cffffd100Nameplates|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local npToggle = CFG:CreateCheckButton(panel, "NPToggle", nil, "Switches nameplates module on or off")
	npToggle:HookScript("OnClick", NPToggle_OnClick)
	npToggle:SetPoint("TOPRIGHT", -16, -16)
	panel.NPToggle = npToggle
	panel.settings.nameplates.enabled = npToggle

	local infoText1 = CFG:CreateTextLabel(panel, 10, "Nameplates and stuff.")
	infoText1:SetHeight(32)
	infoText1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	local cbToggle = CFG:CreateCheckButton(panel, "ComboBarToggle", "Show combo points")
	cbToggle:SetPoint("TOPLEFT", infoText1, "BOTTOMLEFT", -2, -8)
	cbToggle:HookScript("OnClick", CBToggle_OnClick)
	panel.settings.nameplates.show_combo = cbToggle
	CFG:SetupControlDependency(npToggle, cbToggle)

	local hpTextToggle = CFG:CreateCheckButton(panel, "HealthTextToggle", "Show health percentage")
	hpTextToggle:SetPoint("TOPLEFT", cbToggle, "BOTTOMLEFT", 0, -8)
	hpTextToggle:HookScript("OnClick", HPTextToggle_OnClick)
	panel.settings.nameplates.show_text = hpTextToggle
	CFG:SetupControlDependency(npToggle, hpTextToggle)

	local log1 = CFG:CreateTextLabel(panel, 10, "")
	log1:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 16)
	panel.StatusLog = log1

	panel.okay = function() CFG:OptionsPanelOkay(panel) end
	panel.cancel = function() CFG:OptionsPanelOkay(panel) end
	panel.refresh = function() CFG:OptionsPanelRefresh(panel) end
	panel.default = function() CFG:OptionsPanelDefault(panel) end

	InterfaceOptions_AddCategory(panel)
end
