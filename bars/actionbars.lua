local _, ns = ...
local cfg = ns.cfg
local barcfg = cfg.bars
local btncfg = cfg.buttons
local glcolors = cfg.globals.colors
local bar_module = CreateFrame("Frame")

--MAINMENU
local bar1 = CreateFrame("Frame", "new_ActionBar1", UIParent, "SecureHandlerStateTemplate")
--BOTTOMLEFT
local bar2 = CreateFrame("Frame", "new_ActionBar2", UIParent, "SecureHandlerStateTemplate")
--BOTTOMRIGHT
local bar3 = CreateFrame("Frame", "new_ActionBar3", UIParent, "SecureHandlerStateTemplate")
--SIDERIGHT
local bar4 = CreateFrame("Frame", "new_ActionBar4", UIParent, "SecureHandlerStateTemplate")
--SIDELEFT
local bar5 = CreateFrame("Frame", "new_ActionBar5", UIParent, "SecureHandlerStateTemplate")
--PET
local bar6 = CreateFrame("Frame", "new_ActionBar6", UIParent, "SecureHandlerStateTemplate")
--STANCE/SS
local bar7 = CreateFrame("Frame", "new_ActionBar7", UIParent, "SecureHandlerStateTemplate")
--POSSESS
local bar8 = CreateFrame("Frame", "new_ActionBar8", UIParent, "SecureHandlerStateTemplate")
--OVERRIDE/VEHICLE
local bar9 = CreateFrame("Frame", "new_ActionBar9", UIParent, "SecureHandlerStateTemplate")
--PETBATTLE
local bar10 = CreateFrame("Frame", "new_ActionBar10", UIParent, "SecureHandlerStateTemplate")
--EXTRA
local bar11 = CreateFrame("Frame", "new_ExtraBarFrame", UIParent, "SecureHandlerStateTemplate")
--BAGS
local bar12 = CreateFrame("Frame", "new_BagFrame", UIParent, "SecureHandlerStateTemplate")

local defbar = {
	[1] = "Action",
	[2] = "MultiBarBottomLeft",
	[3] = "MultiBarBottomRight",
	[4] = "MultiBarRight",
	[5] = "MultiBarLeft",
	[6] = "PetAction",
	[7] = "Stance",
	[8] = "Possess",
	[9] = "OverrideAction",
	[10] = "PetBattle",
}

local BagSlots = {
	"MainMenuBarBackpackButton",
	"CharacterBag0Slot",
	"CharacterBag1Slot",
	"CharacterBag2Slot",
	"CharacterBag3Slot",
} 

local PetBattleButtons = {
	[1] = PetBattleFrame.BottomFrame.abilityButtons[1],
	[2] = PetBattleFrame.BottomFrame.abilityButtons[2],
	[3] = PetBattleFrame.BottomFrame.abilityButtons[3],
	[4] = PetBattleFrame.BottomFrame.SwitchPetButton,
	[5] = PetBattleFrame.BottomFrame.CatchButton,
	[6] = PetBattleFrame.BottomFrame.ForfeitButton,
}

local ButtonsToStyle = {
	["ActionButton"] = NUM_ACTIONBAR_BUTTONS,
	["MultiBarBottomLeftButton"] = NUM_ACTIONBAR_BUTTONS,
	["MultiBarBottomRightButton"] = NUM_ACTIONBAR_BUTTONS,
	["MultiBarRightButton"] = NUM_ACTIONBAR_BUTTONS,
	["MultiBarLeftButton"] = NUM_ACTIONBAR_BUTTONS,
	["PetActionButton"] = NUM_PET_ACTION_SLOTS,
	["StanceButton"] = NUM_STANCE_SLOTS,
	["PossessButton"] = NUM_POSSESS_SLOTS,
	["OverrideActionBarButton"] = 6,
}
--------------
-- SPAWNING --
--------------

local function SetBarPosition(f)
	local num
	if defbar[f] == "PetAction" then
		num = NUM_PET_ACTION_SLOTS
	elseif defbar[f] == "Stance" then
		num = NUM_STANCE_SLOTS
	elseif defbar[f] == "Possess" then
		num = NUM_POSSESS_SLOTS
	else
		num = NUM_ACTIONBAR_BUTTONS
	end
	--2 SIDEBARS
	if defbar[f] == "MultiBarRight" or defbar[f] == "MultiBarLeft" then
		_G["new_ActionBar"..f]:SetWidth(btncfg.buttonsize)
		_G["new_ActionBar"..f]:SetHeight(btncfg.buttonsize * num + btncfg.buttonspacing * (num - 1))
	else
		_G["new_ActionBar"..f]:SetWidth(btncfg.buttonsize * num + btncfg.buttonspacing * (num - 1))
		_G["new_ActionBar"..f]:SetHeight(btncfg.buttonsize)
	end
	--BOTTOMS & OVERRIDE & PETBATTLE
	if defbar[f] ~= "PetAction" and defbar[f] ~= "Stance" and defbar[f] ~= "Possess" then
		_G["new_ActionBar"..f]:SetPoint(unpack(barcfg["bar"..f].pos))
	end
	--ADDITIONAL
	if defbar[f] == "MultiBarBottomLeft" or defbar[f] == "MultiBarBottomRight" or defbar[f] == "MultiBarRight" or defbar[f] == "MultiBarLeft" then
		_G[defbar[f]]:SetParent(_G["new_ActionBar"..f])
		_G[defbar[f]]:EnableMouse(false)
	--PETBATTLE
	elseif defbar[f] == "PetBattle" then
		PetBattleFrame:SetParent(_G["new_ActionBar"..f])
		PetBattleFrame:EnableMouse(false)
	--OVERRIDE
	elseif defbar[f] == "OverrideAction" then
		_G[defbar[f].."Bar"]:SetParent(_G["new_ActionBar"..f])
		_G[defbar[f].."Bar"]:EnableMouse(false)
	--MAINBAR
	elseif defbar[f] == "Action" then
		MainMenuBarArtFrame:SetParent(_G["new_ActionBar"..f])
		MainMenuBarArtFrame:EnableMouse(false)
	--PET, STANCE/SS, POSSESS & TOTEM
	elseif defbar[f] == "PetAction" or defbar[f] == "Stance" or defbar[f] == "Possess" then
		if defbar[f] == "PetAction" then
			_G["new_ActionBar"..f]:SetPoint(unpack(barcfg["add"]["pet"..barcfg["add"][cfg.playerclass]]))
		else
			_G["new_ActionBar"..f]:SetPoint(unpack(barcfg["add"]["stance"..barcfg["add"][cfg.playerclass]]))
		end
		_G[defbar[f].."BarFrame"]:SetParent(_G["new_ActionBar"..f])
		_G[defbar[f].."BarFrame"]:EnableMouse(false)
	end
	_G["new_ActionBar"..f]:SetScale(cfg.globals.scale)
	_G["new_ActionBar"..f]:SetFrameLevel(3)

	if f == 9 then
		RegisterStateDriver(OverrideActionBar, "visibility", "[overridebar][vehicleui] show; hide")
	elseif f == 6 then
		RegisterStateDriver(_G["new_ActionBar"..f], "visibility", "[petbattle][overridebar][vehicleui] hide; [@pet,exists,nodead] show; hide")
	elseif f == 10 then
		--NONE
	else
		RegisterStateDriver(_G["new_ActionBar"..f], "visibility", "[petbattle][overridebar][vehicleui] hide; show")
	end
end

local function SpawnBarButtons(f)
	if f == 10 then return end
	local button, previous, num, cd
	if defbar[f] == "PetAction" then
		num = NUM_PET_ACTION_SLOTS
	elseif defbar[f] == "Stance" then
		num = NUM_STANCE_SLOTS
	elseif defbar[f] == "Possess" then
		num = NUM_POSSESS_SLOTS
	elseif defbar[f] == "OverrideAction" then
		num = 6
	else
		num = NUM_ACTIONBAR_BUTTONS
	end
	for i = 1, num do
		if f == 9 then
			button = _G[defbar[f].."BarButton"..i]
		else
			button = _G[defbar[f].."Button"..i]
		end
		button:ClearAllPoints()
		button:SetSize(btncfg.buttonsize, btncfg.buttonsize)
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", _G["new_ActionBar"..f], 0, 0)
		else
			if defbar[f] == "MultiBarRight" or defbar[f] == "MultiBarLeft" then
				button:SetPoint("TOP", previous, "BOTTOM", 0, -btncfg.buttonspacing)
			else
				button:SetPoint("LEFT", previous, "RIGHT", btncfg.buttonspacing, 0)
			end
		end
		previous = button
	end
end

local function SetBagPosition()
	_G["new_BagFrame"]:SetSize(btncfg.buttonsize * 5, btncfg.buttonsize)
	if InfoBar5 then
		_G["new_BagFrame"]:SetPoint(unpack(barcfg.bags.pos1))
		_G["new_BagFrame"]:Hide()
	else
		_G["new_BagFrame"]:SetPoint(unpack(barcfg.bags.pos2))
	end
	_G["new_BagFrame"]:SetScale(cfg.globals.scale)
	for i, button in pairs(BagSlots) do
		_G[button]:SetParent(_G["new_BagFrame"])
		_G[button]:SetSize(btncfg.buttonsize, btncfg.buttonsize)
		if i == 1 then
			_G[button]:ClearAllPoints()
			_G[button]:SetPoint("RIGHT", btncfg.buttonsize, 0)
		else
			_G[button]:SetPoint("RIGHT", _G[BagSlots[i - 1]], "LEFT", -btncfg.buttonspacing, 0)
		end
	end
end

local function SetExtraButtonPosition()
	_G["new_ExtraBarFrame"]:SetSize(64,64)
	_G["new_ExtraBarFrame"]:SetPoint(unpack(barcfg.extrabar.pos))
	_G["new_ExtraBarFrame"]:SetScale(cfg.globals.scale)
	ExtraActionBarFrame:SetParent(_G["new_ExtraBarFrame"])
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint("CENTER", 0, 0)
	ExtraActionBarFrame.ignoreFramePositionManager = true
end

local function SetLeaveButtonPosition()
	if MainMenuBarVehicleLeaveButton then
		MainMenuBarVehicleLeaveButton:SetSize(btncfg.buttonsize, btncfg.buttonsize)
		MainMenuBarVehicleLeaveButton:UnregisterAllEvents()
		MainMenuBarVehicleLeaveButton:SetParent(UIParent)
		MainMenuBarVehicleLeaveButton:ClearAllPoints()
		MainMenuBarVehicleLeaveButton:SetPoint(unpack(barcfg.vehicle.pos))

		RegisterStateDriver(MainMenuBarVehicleLeaveButton, "visibility", "[overridebar][vehicleui][possessbar][@vehicle,exists] show; hide")
	end
end

-------------
-- STYLING --
-------------

local function bIconUpdate(button)
	local bIcon = _G[button:GetName().."Icon"]
	if not bIcon then return end
	if button.action and IsActionInRange(button.action) ~= 0 then
		local isUsable, notEnoughMana = IsUsableAction(button.action)
		if isUsable then
			bIcon:SetVertexColor(1, 1, 1, 1)
		elseif notEnoughMana then
			bIcon:SetVertexColor(unpack(glcolors.icon.oom))
		else
			bIcon:SetVertexColor(unpack(glcolors.icon.nu)) 
		end
	else
		bIcon:SetVertexColor(unpack(glcolors.icon.oor))
	end
end

local function SetDefaultButtonStyle(btn, id)
	local name = btn..id
	local button = _G[name]
	if not button then return end
	if button.styled then return end
	local bIcon = _G[name.."Icon"] or _G[name.."IconTexture"]
	local bCount = _G[name.."Count"]
	local bFlash = _G[name.."Flash"]
	local bCD = _G[name.."Cooldown"]
	local bHotKey = _G[name.."HotKey"]
	local bNormal = button:GetNormalTexture()

	bIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bIcon:SetDrawLayer("BACKGROUND", -7)
	bIcon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
	bIcon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	if bCD then
		bCD:SetAllPoints(button)
	end
	if bHotKey then
		bHotKey:SetFont(cfg.font, 12, "THINOUTLINE")
		bHotKey:ClearAllPoints()
		bHotKey:SetPoint("TOPRIGHT", 0, 0)
	end
	if bNormal then
		bNormal:SetTexture("")
		bNormal:Hide()
	end
	if 	btn == "ActionButton" or btn == "MultiBarBottomLeftButton" or btn == "MultiBarBottomRightButton" or btn == "MultiBarRightButton" or btn == "MultiBarLeftButton" then
		hooksecurefunc(bNormal, "SetVertexColor", ns.NormalTextureVertexColor)
	end
	if bCount and (btn == "MainMenuBarBackpackButton" or btn == "CharacterBag0Slot" or btn == "CharacterBag1Slot" or btn == " CharacterBag2Slot" or btn == "CharacterBag3Slot") then
		bCount:Hide()
		hooksecurefunc(bCount, "Show", function(self) self:Hide() end)
	end
	button.NewBorder = button:CreateTexture()
	bNormal = button.NewBorder
	bNormal:SetTexture(cfg.globals.textures.button_normal)
	bNormal:SetVertexColor(unpack(glcolors.btnstate.normal))
	bNormal:Show()
	bNormal:SetDrawLayer("BACKGROUND", -6)
	bNormal:SetDrawLayer("BORDER")
	bNormal:SetBlendMode("BLEND")
	bNormal:SetAllPoints(button)
	hooksecurefunc(button, "SetNormalTexture", function(self, texture)
		button:GetNormalTexture():SetTexture("")
		button:GetNormalTexture():Hide()
	end)
	button:SetHighlightTexture(cfg.globals.textures.button_highlight)
	button:SetPushedTexture(cfg.globals.textures.button_pushed)
	button:SetCheckedTexture(cfg.globals.textures.button_checked)
	if bFlash then
		bFlash:Hide()
		hooksecurefunc(bFlash, "Show", function(self) self:Hide() end)
	end
	if btn == "ActionButton" or btn == "MultiBarBottomLeftButton" or btn == "MultiBarBottomRightButton" or btn == "MultiBarRightButton" or btn == "MultiBarLeftButton" or btn == "OverrideActionBarButton" then 
		local bBorder	= _G[name.."Border"]
		local bMacro = _G[name.."Name"]
		local bFlyoutBorder = _G[name.."FlyoutBorder"]
		local bFlyoutBorderShadow = _G[name.."FlyoutBorderShadow"]
		local bFloatingBG = _G[name.."FloatingBG"]
		if bCount then 
			bCount:SetFont(cfg.font, 12, "THINOUTLINE")
			bCount:ClearAllPoints()
			bCount:SetPoint("BOTTOMLEFT", 0, 0)
		end
		if bBorder then
			bBorder:Hide()
			hooksecurefunc(bBorder, "Show", function(self) self:Hide() end)
		end
		if bMacro then
			bMacro:Hide()
			hooksecurefunc(bMacro, "Show", function(self) self:Hide() end)
		end
		if bFlyoutBorder then
			bFlyoutBorder:Hide()
			hooksecurefunc(bFlyoutBorder, "Show", function(self) self:Hide() end)
		end
		if bFlyoutBorderShadow then
			bFlyoutBorderShadow:Hide()
			hooksecurefunc(bFlyoutBorderShadow, "Show", function(self) self:Hide() end)
		end
		if bFloatingBG then
			bFloatingBG:Hide()
			hooksecurefunc(bFloatingBG, "Show", function(self) self:Hide() end)
		end
	end
	if btn == "PetActionButton" then
		local bShine = _G[name.."Shine"]
		local bAutoCast = _G[name.."AutoCastable"]
		if bShine then
			bShine:ClearAllPoints()
			bShine:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
			bShine:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		end
		if bAutoCast then
			bAutoCast:ClearAllPoints()
			bAutoCast:SetPoint("TOPLEFT", button, "TOPLEFT", -13, 13)
			bAutoCast:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 13, -13)
		end
	end
	if not button.bg then ns.CreateButtonBackdrop(button) end
	button.styled = true
end

local function SetLeaveButtonStyle(button)
	if not button then return end
	if button.styled then return end
	if not button.border then
		button.border = button:CreateTexture(nil, "ARTWORK", nil, 2)
		button.border:SetAllPoints(button)
		button.border:SetTexture(cfg.globals.textures.button_normal)
		button.border:SetVertexColor(unpack(glcolors.btnstate.normal))
	end
	button:SetHighlightTexture(cfg.globals.textures.button_highlight)
	if not button.bg then ns.CreateButtonBackdrop(button) end
end

---------------
-- PETBATTLE --
---------------

local function SetPetBattleButtonStyle(button)
	if button.styled then return end
	local bIcon = button.Icon
	local bCDShadow = button.CooldownShadow
	local bCDFlash = button.CooldownFlash
	local bCD = button.Cooldown
	local bHotKey = button.HotKey
	local bSelectedHighlight = button.SelectedHighlight
	local bLock = button.Lock
	local bBetterIcon = button.BetterIcon
	local bNormal = button:GetNormalTexture()

	bIcon:SetTexCoord(0.1 ,0.9, 0.1, 0.9)
	bIcon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
	bIcon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	if bSelectedHighlight then
		bSelectedHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
		bSelectedHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 10, -10)
	end
	if bHotKey then
		bHotKey:Hide()
	end
	if bLock then
		bLock:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		bLock:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	end
	if bBetterIcon then
		bBetterIcon:SetSize(24, 24)
	end
	if bCDFlash then
		bCDFlash:SetAllPoints(button)
	end
	if bCDShadow then
		bCDShadow:SetAllPoints(button)
	end
	if bCD then
		bCD:ClearAllPoints()
		bCD:SetPoint("CENTER", 0, -2)
	end
	if bNormal then
		bNormal:SetTexture("")
		bNormal:Hide()
	end
	button.NewBorder = button:CreateTexture()
	bNormal = button.NewBorder
	bNormal:SetTexture(cfg.globals.textures.button_normal)
	bNormal:SetVertexColor(unpack(glcolors.btnstate.normal))
	bNormal:Show()
	bNormal:SetDrawLayer("BORDER")
	bNormal:SetBlendMode("BLEND")
	bNormal:SetAllPoints(button)
	hooksecurefunc(button, "SetNormalTexture", function(self, texture)
		button.NewBorder:SetTexture(cfg.globals.textures.button_normal)
		button.NewBorder:SetVertexColor(unpack(glcolors.btnstate.normal))
	end)
	button:SetHighlightTexture(cfg.globals.textures.button_highlight)
	button:SetPushedTexture(cfg.globals.textures.button_pushed)
	if not button.bg then ns.CreateButtonBackdrop(button) end
	button.styled = true
end

local function SetPetBattleButtonPosition(self)
	local button, previous
	for i = 1, 6 do
		button = PetBattleButtons[i]
		if not button then
			button = self.BottomFrame.abilityButtons[i]
		end
		button:ClearAllPoints()
		button:SetFrameLevel(4)
		button:SetSize(btncfg.buttonsize, btncfg.buttonsize)
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", _G["new_ActionBar10"], 0, 0)
		else
			button:SetPoint("LEFT", previous, "RIGHT", btncfg.buttonspacing, 0)
		end
		SetPetBattleButtonStyle(button)
		previous = button
	end
end

local function HideBlizStuff()
	local AnchorFrameToHide = CreateFrame("Frame")
	AnchorFrameToHide:Hide()
	--frames
	MainMenuBar:SetParent(AnchorFrameToHide)
	MainMenuBarPageNumber:SetParent(AnchorFrameToHide)
	ActionBarDownButton:SetParent(AnchorFrameToHide)
	ActionBarUpButton:SetParent(AnchorFrameToHide)
	OverrideActionBarExpBar:SetParent(AnchorFrameToHide)
	OverrideActionBarHealthBar:SetParent(AnchorFrameToHide)
	OverrideActionBarPowerBar:SetParent(AnchorFrameToHide)
	OverrideActionBarPitchFrame:SetParent(AnchorFrameToHide)
	OverrideActionBar.LeaveButton:SetParent(AnchorFrameToHide)
	PetBattleFrame.BottomFrame.FlowFrame:SetParent(AnchorFrameToHide)
	FlowContainer_PauseUpdates(PetBattleFrame.BottomFrame.FlowFrame)
	PetBattleFrame.BottomFrame.Delimiter:SetParent(AnchorFrameToHide)
	PetBattleFrame.BottomFrame.MicroButtonFrame:SetParent(AnchorFrameToHide)
	-- textures
	SlidingActionBarTexture0:SetTexture("")
	SlidingActionBarTexture1:SetTexture("")
	PossessBackground1:SetTexture("")
	PossessBackground2:SetTexture("")
	StanceBarLeft:SetTexture("")
	StanceBarMiddle:SetTexture("")
	StanceBarRight:SetTexture("")
	MainMenuBarTexture0:SetTexture("")
	MainMenuBarTexture1:SetTexture("")
	MainMenuBarTexture2:SetTexture("")
	MainMenuBarTexture3:SetTexture("")
	MainMenuBarLeftEndCap:SetTexture("")
	MainMenuBarRightEndCap:SetTexture("")
	PetBattleFrame.BottomFrame.Background:SetTexture("")
	PetBattleFrame.BottomFrame.LeftEndCap:SetTexture("")
	PetBattleFrame.BottomFrame.RightEndCap:SetTexture("")
	--PetBattle XP Bar
	for i = 7, 12 do
		select(i, PetBattleFrameXPBar:GetRegions()):SetTexture("")
	end
	select(5, PetBattleFrameXPBar:GetRegions()):SetTexture(0.25, 0.4, 0.35, 0.3)
	PetBattleFrameXPBar:SetFrameStrata("LOW")
	PetBattleFrameXPBar:SetFrameLevel(2)
	PetBattleFrameXPBar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 78)
	PetBattleFrameXPBar:SetSize(420, 8)
	PetBattleFrameXPBar:SetStatusBarTexture(cfg.globals.textures.statusbar)
	PetBattleFrameXPBar:SetStatusBarColor(0.51, 0.8, 0.7, 1)
	PetBattleFrameXPBar.TextString:SetFont(cfg.font, 11, "THINOUTLINE")
	PetBattleFrameXPBarLeft:SetVertexColor(0.37, 0.3, 0.3)
	PetBattleFrameXPBarMiddle:SetVertexColor(0.37, 0.3, 0.3)
	PetBattleFrameXPBarRight:SetVertexColor(0.37, 0.3, 0.3)
	--PetBattle Skip Button
	PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2:SetTexture("")
	PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
	PetBattleFrame.BottomFrame.TurnTimer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 86)

	local TexturesToHide = {
		"_BG",
		"EndCapL",
		"EndCapR",
		"_Border",
		"Divider1",
		"Divider2",
		"Divider3",
		"ExitBG",
		"MicroBGL",
		"MicroBGR",
		"_MicroBGMid",
		"ButtonBGL",
		"ButtonBGR",
		"_ButtonBGMid",
	}
	for _,tex in pairs(TexturesToHide) do
		OverrideActionBar[tex]:SetAlpha(0)
	end
end

local function InitBarParameters()
	for i = 1, 10 do
		SetBarPosition(i)
		SpawnBarButtons(i)
	end
	for k, v in pairs(ButtonsToStyle) do
		for i = 1, v do
			SetDefaultButtonStyle(k, i)
		end
	end

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", SetPetBattleButtonPosition)

	local FlyoutButtonCount = 0
	for i = 1, GetNumFlyouts() do
		local _, _, numSlots, isKnown = GetFlyoutInfo(GetFlyoutID(i))
		if isKnown == true then
				FlyoutButtonCount = numSlots
			break
		end
	end
	local function HookFlyoutButtonOnShow()
		for i = 1, FlyoutButtonCount do
			SetDefaultButtonStyle("SpellFlyoutButton", i)
		end
	end
	SpellFlyout:HookScript("OnShow", HookFlyoutButtonOnShow)
	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)

	SetLeaveButtonPosition()
	SetLeaveButtonStyle(OverrideActionBar.LeaveButton)
	SetLeaveButtonStyle(MainMenuBarVehicleLeaveButton)

	hooksecurefunc("ActionButton_OnUpdate", bIconUpdate)

	SetBagPosition()

	for _, BagSlot in pairs(BagSlots) do
		SetDefaultButtonStyle(BagSlot, "")
	end

	SetExtraButtonPosition()

	HideBlizStuff()
end

bar_module:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		InitBarParameters()
	end
end)

bar_module:RegisterEvent("PLAYER_LOGIN")