local _, ns = ...
local oUF, E, C, D = ns.oUF or oUF

-- TogglePanelOptions = {
-- 	toggleMinimap = {text = "Minimap"},
-- }

-- UNITFRAMES --

local function lsOptions_CreateDivider(parent)
	local object = parent:CreateTexture(nil, "ARTWORK");
	object:SetHeight(8)
	object:SetPoint("LEFT", 10, 0)
	object:SetPoint("RIGHT", 10, 0)
	object:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	object:SetTexCoord(0.81, 0.94, 0.5, 1)
	object:SetVertexColor(0.2, 0.2, 0.2)

	return object
end

local function lsOptions_CreateHeader(parent, label)
	local object = E:CreateFontString(parent, 16, nil, true, nil, 1, 0.82, 0)
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

------------


function lsAuraTrackerCheckButton_OnClick(self)
	ns.C.auratracker.enabled = self:GetChecked()
end

function lsMinimapCheckButton_OnClick(self)
	ns.C.minimap.enabled = self:GetChecked()
end

function lsInfobarsCheckButton_OnClick(self)
	ns.C.infobars.enabled = self:GetChecked()
end

function lsActionbarsCheckButton_OnClick(self)
	ns.C.bars.enabled = self:GetChecked()
end

function lsAurasCheckButton_OnClick(self)
	ns.C.auras.enabled = self:GetChecked()
end

function lsOptionsFrame_Initialize()
	E, C, D = ns.E, ns.C, ns.D
	-- print(E, C, D)

	-- local header, object

	lsOptionsFrame.name = "oUF: LS"
	InterfaceOptions_AddCategory(lsOptionsFrame)
	-- ns.DebugTexture(lsOptionsFrame_ScrollFrame)
	-- ns.DebugTexture(lsOptionsMainFrame)
	--[[
	UnitFrames
	8 buttons
	Infobars
	7 buttons
	]]


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

	lsOptionsMainFrame["units"]["header"] = header1

	local button2 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Player")
	button2:SetPoint("TOPLEFT", header1, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["units"]["player"]["enabled"] = button2

	local button3 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Player\'s Pet")
	button3:SetPoint("TOPLEFT", button2, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["units"]["pet"]["enabled"] = button3

	local button4 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Target")
	button4:SetPoint("LEFT", button2, "RIGHT", 110, 0)

	lsOptionsMainFrame["units"]["target"]["enabled"] = button4

	local button5 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Target of Target")
	button5:SetPoint("TOPLEFT", button4, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["units"]["targettarget"]["enabled"] = button5

	local button6 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Focus")
	button6:SetPoint("LEFT", button4, "RIGHT", 110, 0)

	lsOptionsMainFrame["units"]["focus"]["enabled"] = button6

	local button7 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Target of Focus")
	button7:SetPoint("TOPLEFT", button6, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["units"]["focustarget"]["enabled"] = button7

	local button8 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Party")
	button8:SetPoint("LEFT", button6, "RIGHT", 110, 0)

	lsOptionsMainFrame["units"]["party"]["enabled"] = button8

	local button9 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Bosses")
	button9:SetPoint("TOPLEFT", button8, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["units"]["boss"]["enabled"] = button9

	local divider1 = lsOptions_CreateDivider(lsOptionsMainFrame)
	divider1:SetPoint("TOP", button9, "BOTTOM", 0, -8)

	lsOptionsMainFrame["infobars"] = {
		["location"] = {},
		["memory"] = {},
		["fps"] = {},
		["latency"] = {},
		["bag"] = {},
		["clock"] = {},
		["mail"] = {},
	}

	local button10 = lsOptions_CreateCheckButton(lsOptionsMainFrame)
	button10:SetPoint("LEFT", 0, 0)
	button10:SetPoint("TOP", divider1, "BOTTOM", 0, -8)

	lsOptionsMainFrame["infobars"]["enabled"] = button10
	
	local header2 = lsOptions_CreateHeader(lsOptionsMainFrame, "Infobars")
	header2:SetPoint("LEFT", button10, "RIGHT", 4, 0)

	lsOptionsMainFrame["infobars"]["header"] = header2

	local button11 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Location")
	button11:SetPoint("TOPLEFT", header2, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["infobars"]["location"]["enabled"] = button11

	local button12 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Memory")
	button12:SetPoint("TOPLEFT", button11, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["infobars"]["memory"]["enabled"] = button12

	local button13 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "FPS")
	button13:SetPoint("LEFT", button11, "RIGHT", 110, 0)

	lsOptionsMainFrame["infobars"]["fps"]["enabled"] = button13

	local button14 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Latency")
	button14:SetPoint("TOPLEFT", button13, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["infobars"]["latency"]["enabled"] = button14

	local button15 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Bags")
	button15:SetPoint("LEFT", button13, "RIGHT", 110, 0)

	lsOptionsMainFrame["infobars"]["bag"]["enabled"] = button15

	local button16 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Clock")
	button16:SetPoint("TOPLEFT", button15, "BOTTOMLEFT", 0, -8)

	lsOptionsMainFrame["infobars"]["clock"]["enabled"] = button16

	local button17 = lsOptions_CreateCheckButton(lsOptionsMainFrame, "Mail")
	button17:SetPoint("LEFT", button15, "RIGHT", 110, 0)

	lsOptionsMainFrame["infobars"]["mail"]["enabled"] = button17

	lsOptionsFrame.okay = function()
	print("pressed okay")
		E:ApplySettings(lsOptionsMainFrame, C)
		-- ReloadUI()
	end

	lsOptionsFrame.refresh = function()
		E:FetchSettings(lsOptionsMainFrame, C)
	end

	lsOptionsFrame.default = function()
		print("pressed default")
		E:FetchSettings(lsOptionsMainFrame, D)
	end
end
