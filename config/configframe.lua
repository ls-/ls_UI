local _, ns = ...
local oUF, E, C, D = ns.oUF or oUF, ns.E, ns.C, ns.D

local function lsOptions_CreateDivider(parent)
	local object = parent:CreateTexture(nil, "ARTWORK");
	object:SetHeight(4)
	object:SetPoint("LEFT", 10, 0)
	object:SetPoint("RIGHT", 10, 0)
	object:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RecentHeader")
	object:SetTexCoord(0, 1, 0.0625, 0.65625)
	object:SetAlpha(0.5)

	return object
end

local function lsOptions_CreateHeader(parent, label)
	local object = E:CreateFontString(parent, 16, nil, true, nil, nil, 1, 0.82, 0)
	object:SetSize(512, 20)
	object:SetJustifyH("LEFT")
	object:SetJustifyV("MIDDLE")
	object:SetText(label)

	return object
end

local function lsOptions_CreateCheckButton(parent, label)
	local object = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")

	object.Text:SetText(label)

	object.GetValue = function()
		if object:GetChecked() then
			return true
		else
			return false
		end
	end

	object.SetValue = object.SetChecked

	return object
end

function lsOptionsFrame_Initialize()
	lsOptionsFrame.name = "oUF: LS"

	InterfaceOptions_AddCategory(lsOptionsFrame)

	lsOptionsMainFrame["units"] = {
		["player"] = {},
		["pet"] = {},
		["target"] = {},
		["targettarget"] = {},
		["focus"] = {},
		["focustarget"] = {},
		["party"] = {},
		["boss"] = {},
	}

	local button1 = lsOptions_CreateCheckButton(lsOptionsMainFrame)
	button1:SetPoint("TOPLEFT", 0, 0)

	lsOptionsMainFrame["units"]["enabled"] = button1

	local header1 = lsOptions_CreateHeader(lsOptionsMainFrame, "Unit Frames")
	header1:SetPoint("LEFT", button1, "RIGHT", 4, 0)

	local button2 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Player & Pet")
	button2:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["units"]["player"]["enabled"] = button2
	lsOptionsMainFrame["units"]["pet"]["enabled"] = button2

	local button3 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Target & ToT")
	button3:SetPoint("LEFT", button2, "RIGHT", 110, 0)

	lsOptionsMainFrame["units"]["target"]["enabled"] = button3
	lsOptionsMainFrame["units"]["targettarget"]["enabled"] = button3

	local button4 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Focus & ToF")
	button4:SetPoint("LEFT", button3, "RIGHT", 110, 0)

	lsOptionsMainFrame["units"]["focus"]["enabled"] = button4
	lsOptionsMainFrame["units"]["focustarget"]["enabled"] = button4

	local button5 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Party")
	button5:SetPoint("LEFT", button4, "RIGHT", 110, 0)

	lsOptionsMainFrame["units"]["party"]["enabled"] = button5

	local button6 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Bosses")
	button6:SetPoint("TOPLEFT", button2, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["units"]["boss"]["enabled"] = button6

	local divider1 = lsOptions_CreateDivider(lsOptionsMainFrame)
	divider1:SetPoint("TOP", button6, "BOTTOM", 0, -8)

	lsOptionsMainFrame["auratracker"] = {}
	lsOptionsMainFrame["minimap"] = {}
	lsOptionsMainFrame["infobars"] = {}
	lsOptionsMainFrame["nameplates"] = {}
	lsOptionsMainFrame["bars"] = {}
	lsOptionsMainFrame["auras"] = {}
	lsOptionsMainFrame["mail"] = {}
	lsOptionsMainFrame["bags"] = {}

	local header2 = lsOptions_CreateHeader(lsOptionsMainFrame, "Other Modules")
	header2:SetPoint("TOPLEFT", divider1, "BOTTOMLEFT", 0, -8)

	local button7 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Aura Tracker")
	button7:SetPoint("TOPLEFT", header2, "BOTTOMLEFT", 20, -8)

	lsOptionsMainFrame["auratracker"]["enabled"] = button7

	local button8 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Minimap")
	button8:SetPoint("LEFT", button7, "RIGHT", 110, 0)

	lsOptionsMainFrame["minimap"]["enabled"] = button8

	local button9 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Clock")
	button9:SetPoint("LEFT", button8, "RIGHT", 110, 0)

	lsOptionsMainFrame["infobars"]["enabled"] = button9

	local button10 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Nameplates")
	button10:SetPoint("LEFT", button9, "RIGHT", 110, 0)

	lsOptionsMainFrame["nameplates"]["enabled"] = button10

	local button11 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Action Bars")
	button11:SetPoint("TOPLEFT", button7, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["bars"]["enabled"] = button11

	local button12 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Buffs & Debuffs")
	button12:SetPoint("LEFT", button11, "RIGHT", 110, 0)

	lsOptionsMainFrame["auras"]["enabled"] = button12

	local button13 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Mail")
	button13:SetPoint("LEFT", button12, "RIGHT", 110, 0)

	lsOptionsMainFrame["mail"]["enabled"] = button13

	local button14 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Bags")
	button14:SetPoint("LEFT", button13, "RIGHT", 110, 0)

	lsOptionsMainFrame["bags"]["enabled"] = button14

	local divider2 = lsOptions_CreateDivider(lsOptionsMainFrame)
	divider2:SetPoint("TOP", button11, "BOTTOM", 0, -8)

	local header3 = lsOptions_CreateHeader(lsOptionsMainFrame, "Info")
	header3:SetPoint("TOPLEFT", divider2, "BOTTOMLEFT", 0, -8)

	local infotext = E:CreateFontString(lsOptionsFrame, 10, nil, nil, nil, true)
	infotext:SetPoint("TOPLEFT", header3, "BOTTOMLEFT", 0, -8)
	infotext:SetPoint("TOPRIGHT", header3, "BOTTOMRIGHT", 0, -8)
	infotext:SetHeight(200)
	infotext:SetJustifyH("LEFT")
	infotext:SetJustifyV("TOP")
	infotext:SetText([[Once again, welcome to v2-alpha.

|cffffbf19First of all, this config panel is WIP and will be changed later! Obviously!|r

I'll be releasing alpha builds approximately every weekend. Please, be patient.

Things can be, and definitely will be, buggy and inconsistent; that's alpha build for you! If it bothers you, consider switching back to stable release channel.

If you find a bug, please, use Curse/WoWI comment section to post a report.

If you have ideas on how to improve my layout, now is the best time to speak out!

I'm currently working on unit frames, so I won't be touching other aspects of my layout for now.

To toggle frame movers use |cffffbf19/lsmovers|r command.

You have to |cffe51919manually reload UI|r to apply changes, use |cffffbf19/rl|r or |cffffbf19/reload|r commands to do so.]])

	lsOptionsFrame.okay = function()
		E:ApplySettings(lsOptionsMainFrame, C)
		-- ReloadUI()
	end

	lsOptionsFrame.refresh = function()
		E:FetchSettings(lsOptionsMainFrame, C)
	end

	lsOptionsFrame.default = function()
		E:FetchSettings(lsOptionsMainFrame, D)
	end

	SLASH_LSCONFIG1 = "/lsconfig"
	SlashCmdList["LSCONFIG"] = function()
		InterfaceOptionsFrame_OpenToCategory(lsOptionsFrame)
		InterfaceOptionsFrame_OpenToCategory(lsOptionsFrame)
	end

end
