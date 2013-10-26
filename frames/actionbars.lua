local _, ns = ...
local cfg = ns.cfg
local glcolors = cfg.globals.colors

local hidenParentFrame = CreateFrame("Frame")
hidenParentFrame:Hide()

function SetStancePossessPetBarPosition(self)
	if self:GetName() == "oUF_LSPetActionBar" then
		self:SetPoint(unpack(cfg.bars["add"]["pet"..cfg.bars["add"][cfg.playerclass]]))
	else
		self:SetPoint(unpack(cfg.bars["add"]["stance"..cfg.bars["add"][cfg.playerclass]]))
	end
end

local function SetDefaultButtonStyle(bType, id)
	local button
	if type(bType) == "string" then
		button = _G[bType..id]
	else
		button = bType
	end
	if not button then return end
	if button.styled then return end
	local bIcon = button.Icon or button.icon or button.IconTexture
	local bHotKey = button.HotKey
	local bNormal = button:GetNormalTexture()
	bIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	bIcon:SetDrawLayer("BACKGROUND", 0)
	bIcon:ClearAllPoints()
	bIcon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
	bIcon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	if bNormal then
		bNormal:SetTexture(nil)
		bNormal:Hide()
	end
	button.newBorder = button:CreateTexture()
	bNormal = button.newBorder
	bNormal:SetDrawLayer("BORDER", 0)
	bNormal:SetTexCoord(14 / 64, 50 / 64, 14 / 64, 50 / 64)
	bNormal:ClearAllPoints()
	bNormal:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
	bNormal:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
	hooksecurefunc(button, "SetNormalTexture", function(self, texture)
		button:GetNormalTexture():SetTexture(nil)
		button:GetNormalTexture():Hide()
	end)
	button:SetHighlightTexture(cfg.globals.textures.button_highlight)
	button:GetHighlightTexture():SetTexCoord(17 / 64, 47 / 64, 17 / 64, 47 / 64)
	button:GetHighlightTexture():ClearAllPoints()
	button:GetHighlightTexture():SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	button:SetPushedTexture(cfg.globals.textures.button_pushed_checked)
	button:GetPushedTexture():SetTexCoord(17 / 64, 47 / 64, 17 / 64, 47 / 64)
	button:GetPushedTexture():ClearAllPoints()
	button:GetPushedTexture():SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button:GetPushedTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	if type(bType) == "string" then
		local name = bType..id
		local bCount = _G[name.."Count"]
		local bFlash = _G[name.."Flash"]
		local bCooldown = _G[name.."Cooldown"]
		if bCooldown then
			bCooldown:SetAllPoints(button)
		end
		if bHotKey then
			bHotKey:SetFont(cfg.font, 12, "THINOUTLINE")
			bHotKey:ClearAllPoints()
			bHotKey:SetPoint("TOPRIGHT", 0, 0)
		end
		if bType == "ActionButton" or bType == "PetActionButton"
			or bType == "StanceButton" or bType == "PossessButton"
			or bType == "OverrideActionBarButton" then
			bNormal:SetTexture(cfg.globals.textures.button_normal_bronze)
		else
			bNormal:SetTexture(cfg.globals.textures.button_normal)
			bNormal:SetVertexColor(unpack(glcolors.btnstate.normal))
		end
		if 	bType == "MultiBarBottomLeftButton" or bType == "MultiBarBottomRightButton" 
			or bType == "MultiBarRightButton" or bType == "MultiBarLeftButton" then
			bNormal.SetVertexColor = ns.NormalTextureVertexColor
		end
		if bCount and (bType == "MainMenuBarBackpackButton" 
			or bType == "CharacterBag0Slot"	or bType == "CharacterBag1Slot"
			or bType == " CharacterBag2Slot" or bType == "CharacterBag3Slot") then
			bCount:Hide()
			bCount.Show = function () end
		end
		button:SetCheckedTexture(cfg.globals.textures.button_pushed_checked)
		button:GetCheckedTexture():SetTexCoord(17 / 64, 47 / 64, 17 / 64, 47 / 64)
		button:GetCheckedTexture():ClearAllPoints()
		button:GetCheckedTexture():SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
		button:GetCheckedTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
		if bFlash then
			bFlash:Hide()
			bFlash.Show = function () end
		end
		if bType == "ActionButton" or bType == "MultiBarBottomLeftButton"
			or bType == "MultiBarBottomRightButton" or bType == "MultiBarRightButton"
			or bType == "MultiBarLeftButton" or bType == "OverrideActionBarButton" then
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
				bBorder.Show = function () end
			end
			if bMacro then
				bMacro:Hide()
				bMacro.Show = function () end
			end
			if bFlyoutBorder then
				bFlyoutBorder:Hide()
				bFlyoutBorder.Show = function () end
			end
			if bFlyoutBorderShadow then
				bFlyoutBorderShadow:Hide()
				bFlyoutBorderShadow.Show = function () end
			end
			if bFloatingBG then
				bFloatingBG:Hide()
				bFloatingBG.Show = function () end
			end
		end
		if bType == "PetActionButton" then
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
	else
		local bCDShadow = button.CooldownShadow
		local bCDFlash = button.CooldownFlash
		local bCD = button.Cooldown
		local bSelectedHighlight = button.SelectedHighlight
		local bLock = button.Lock
		local bBetterIcon = button.BetterIcon
		if bSelectedHighlight then
			bSelectedHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 8)
			bSelectedHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 8, -8)
		end
		if bLock then
			bLock:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
			bLock:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
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
		bNormal:SetTexture(cfg.globals.textures.button_normal_bronze)
	end
	button.styled = true	
end

function SetButtonPosition(self, horizontal, originalBar, buttonType, total, uniqueSize)
	if originalBar then
		_G[originalBar]:SetParent(self)
		_G[originalBar]:EnableMouse(false)
		_G[originalBar].ignoreFramePositionManager = true
	end
	local previous
	for i = 1, total do
		local button
		if type(buttonType) == "string" then
			button = _G[buttonType..i]
		else
			button = _G[buttonType[i]] or buttonType[i]
		end
		if not originalBar then button:SetParent(self) end
		button:SetSize(uniqueSize or 30, uniqueSize or 30)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			button:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -(uniqueSize or 30))
		else
			if horizontal then
				button:SetPoint("LEFT", previous, "RIGHT", 4, 0)
			else
				button:SetPoint("TOP", previous, "BOTTOM", 0, -4)
			end
		end
		if type(buttonType) == "string" then
			SetDefaultButtonStyle(buttonType, i)
		else
			SetDefaultButtonStyle(buttonType[i], "")
		end
		previous = button
	end
end

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

function SetLeaveButtonStyle(button)
	if not button then return end
	if button.styled then return end
	if not button.border then
		button.border = button:CreateTexture(nil, "ARTWORK", nil, 2)
		button.border:SetTexture(cfg.globals.textures.button_normal)
		button.border:SetTexCoord(14 / 64, 50 / 64, 14 / 64, 50 / 64)
		button.border:ClearAllPoints()
		button.border:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
		button.border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
		button.border:SetVertexColor(unpack(glcolors.btnstate.normal))
	end
	button:SetHighlightTexture(cfg.globals.textures.button_highlight)
	button:GetHighlightTexture():SetTexCoord(17 / 64, 47 / 64, 17 / 64, 47 / 64)
	button:GetHighlightTexture():ClearAllPoints()
	button:GetHighlightTexture():SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
end

local function SetPetBattleButtonPosition(self)
	SetButtonPosition(oUF_LSPetBattleBar, true, nil,
		{PetBattleFrame.BottomFrame.abilityButtons[1],
		PetBattleFrame.BottomFrame.abilityButtons[2],
		PetBattleFrame.BottomFrame.abilityButtons[3],
		PetBattleFrame.BottomFrame.SwitchPetButton,
		PetBattleFrame.BottomFrame.CatchButton,
		PetBattleFrame.BottomFrame.ForfeitButton}, 6)
end

do
	MainMenuBar:SetParent(hidenParentFrame)
	MainMenuBarPageNumber:SetParent(hidenParentFrame)
	ActionBarDownButton:SetParent(hidenParentFrame)
	ActionBarUpButton:SetParent(hidenParentFrame)
	OverrideActionBarExpBar:SetParent(hidenParentFrame)
	OverrideActionBarHealthBar:SetParent(hidenParentFrame)
	OverrideActionBarPowerBar:SetParent(hidenParentFrame)
	OverrideActionBarPitchFrame:SetParent(hidenParentFrame)
	OverrideActionBar.LeaveButton:SetParent(hidenParentFrame)
	PetBattleFrame.BottomFrame.FlowFrame:SetParent(hidenParentFrame)
	FlowContainer_PauseUpdates(PetBattleFrame.BottomFrame.FlowFrame)
	PetBattleFrame.BottomFrame.Delimiter:SetParent(hidenParentFrame)
	PetBattleFrame.BottomFrame.MicroButtonFrame:SetParent(hidenParentFrame)
	-- textures
	SlidingActionBarTexture0:SetTexture(nil)
	SlidingActionBarTexture1:SetTexture(nil)
	PossessBackground1:SetTexture(nil)
	PossessBackground2:SetTexture(nil)
	StanceBarLeft:SetTexture(nil)
	StanceBarMiddle:SetTexture(nil)
	StanceBarRight:SetTexture(nil)
	MainMenuBarTexture0:SetTexture(nil)
	MainMenuBarTexture1:SetTexture(nil)
	MainMenuBarTexture2:SetTexture(nil)
	MainMenuBarTexture3:SetTexture(nil)
	MainMenuBarLeftEndCap:SetTexture(nil)
	MainMenuBarRightEndCap:SetTexture(nil)
	PetBattleFrame.BottomFrame.Background:SetTexture(nil)
	PetBattleFrame.BottomFrame.LeftEndCap:SetTexture(nil)
	PetBattleFrame.BottomFrame.RightEndCap:SetTexture(nil)
	PetBattleFrameXPBarLeft:SetTexture(nil)
	PetBattleFrameXPBarMiddle:SetTexture(nil)
	PetBattleFrameXPBarRight:SetTexture(nil)
	--PetBattle XP Bar
	for i = 7, 12 do
		select(i, PetBattleFrameXPBar:GetRegions()):SetTexture(nil)
	end
	select(5, PetBattleFrameXPBar:GetRegions()):SetTexture(unpack(cfg.bottomline.expbar.colors.bg))
	PetBattleFrameXPBar:SetFrameStrata("LOW")
	PetBattleFrameXPBar:SetFrameLevel(4)
	PetBattleFrameXPBar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 56)
	PetBattleFrameXPBar:SetSize(404, 8)
	PetBattleFrameXPBar:SetStatusBarTexture(cfg.globals.textures.statusbar)
	PetBattleFrameXPBar:SetStatusBarColor(unpack(cfg.bottomline.expbar.colors.experience))
	PetBattleFrameXPBar.TextString:SetFont(cfg.font, 10, "THINOUTLINE")
	PetBattleFrameXPBar.Border = PetBattleFrameXPBar:CreateTexture(nil, "OVERLAY")
	PetBattleFrameXPBar.Border:SetPoint("CENTER", 0, 0)
	PetBattleFrameXPBar.Border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\exp_rep_border")
	--PetBattle Skip Button
	PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2:SetTexture(nil)
	PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
	PetBattleFrame.BottomFrame.TurnTimer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 66)
	local texturesToHide = {
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
	for _, j in pairs(texturesToHide) do
		OverrideActionBar[j]:SetAlpha(0)
	end

	local flyoutButtonCount = 0
	for i = 1, GetNumFlyouts() do
		local _, _, numSlots, isKnown = GetFlyoutInfo(GetFlyoutID(i))
		if isKnown == true then
				flyoutButtonCount = numSlots
			break
		end
	end
	local function FlyoutButtonOnShowHook()
		for i = 1, flyoutButtonCount do
			SetDefaultButtonStyle("SpellFlyoutButton", i)
		end
	end
	SpellFlyout:HookScript("OnShow", FlyoutButtonOnShowHook)
	SpellFlyoutHorizontalBackground:SetTexture(nil)
	SpellFlyoutVerticalBackground:SetTexture(nil)
	SpellFlyoutBackgroundEnd:SetTexture(nil)

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", SetPetBattleButtonPosition)
	hooksecurefunc("ActionButton_OnUpdate", bIconUpdate)
end