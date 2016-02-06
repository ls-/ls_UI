local _, ns = ...
local E, C, D = ns.E, ns.C, ns.D
local CFG = E:GetModule("Config")
local UF = E:GetModule("UnitFrames")

local function UnitSelectorDropDown_OnClick(self)
	print(self.value)
end

local function UnitSelectorDropDown_Initialize(self, ...)
	local info = UIDropDownMenu_CreateInfo()

	info.text = "Target"
	info.func = UnitSelectorDropDown_OnClick
	info.value = "target"
	info.owner = self
	info.checked = nil
	UIDropDownMenu_AddButton(info)
end

local function CheckButton_SetMaskValue(self, value)
 self:SetChecked(E:IsFilterApplied(value, E:GetPlayerSpecFlag()))
end

local function CheckButton_GetMaskValue(self, value)
	return self:GetChecked() and E:AddFilterToMask(value, E:GetPlayerSpecFlag()) or E:DeleteFilterFromMask(value, E:GetPlayerSpecFlag())
end

function CFG:UFAuras_Initialize()
	local panel = CreateFrame("Frame", "LSUFAurasConfigPanel", InterfaceOptionsFramePanelContainer)
	panel.name = "Buffs and Debuffs"
	panel.parent = "oUF: |cff1a9fc0LS|r"
	panel:Hide()

	panel.settings = {
		units = {
			target = {
				auras = {},
			},
		},
	}

	local header1 = CFG:CreateTextLabel(panel, 16, "|cffffd100Buffs and Debuffs|r")
	header1:SetPoint("TOPLEFT", 16, -16)

	local infoText1 = CFG:CreateTextLabel(panel, 10, "Something something unit frames something something auras.")
	infoText1:SetHeight(32)
	infoText1:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	local unitSelector = CFG:CreateDropDownMenu(panel, "UnitSelectorDropDown", nil, UnitSelectorDropDown_Initialize)
	unitSelector:SetPoint("TOPLEFT", infoText1, "BOTTOMLEFT", -18, -6)
	unitSelector:SetValue("target")
	panel.UnitSelectorDropDown = unitSelector

	local ufAuraToggle = CFG:CreateCheckButton(panel, "UFAuraToggle", nil, "Show auras on selected unit frame.")
	ufAuraToggle.SetValue = CheckButton_SetMaskValue
	ufAuraToggle.GetValue = CheckButton_GetMaskValue
	ufAuraToggle:SetPoint("TOP", infoText1, "BOTTOM", 0, -6)
	ufAuraToggle:SetPoint("RIGHT", -16, 0)
	panel.settings.units.target.auras.enabled = ufAuraToggle

	local divider1 = CFG:CreateDivider(panel, "Aura Options")
	divider1:SetPoint("TOP", unitSelector, "BOTTOM", 0, -8)

	CFG:AddCatergory(panel)
end
