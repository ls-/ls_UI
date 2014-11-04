local _, ns = ...

ns.bars = {}

local BAR_LAYOUT = {
	bar1 = {
		button_type = "ActionButton",
		num_buttons = NUM_ACTIONBAR_BUTTONS,
		original_bar = "MainMenuBarArtFrame",
		condition = "[petbattle] hide; show",
	},
	bar2 = {
		button_type = "MultiBarBottomLeftButton",
		num_buttons = NUM_ACTIONBAR_BUTTONS,
		original_bar = "MultiBarBottomLeft",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar3 = {
		button_type = "MultiBarBottomRightButton",
		num_buttons = NUM_ACTIONBAR_BUTTONS,
		original_bar = "MultiBarBottomRight",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar4 = {
		button_type = "MultiBarLeftButton",
		num_buttons = NUM_ACTIONBAR_BUTTONS,
		original_bar = "MultiBarLeft",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar5 = {
		button_type = "MultiBarRightButton",
		num_buttons = NUM_ACTIONBAR_BUTTONS,
		original_bar = "MultiBarRight",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar6 = {
		button_type = "PetActionButton",
		num_buttons = NUM_PET_ACTION_SLOTS,
		original_bar = "PetActionBarFrame",
		condition = "[pet,nopetbattle,novehicleui,nooverridebar,nobonusbar:5] show; hide",
	},
	bar7 = {
		button_type = "StanceButton",
		num_buttons = NUM_STANCE_SLOTS,
		original_bar = "StanceBarFrame",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar8 = {
		button_type = {"CharacterBag3Slot", "CharacterBag2Slot", "CharacterBag1Slot", "CharacterBag0Slot", "MainMenuBarBackpackButton"},
		num_buttons = 5,
	},
	bar9 = {
		button_type = "ExtraActionButton",
		num_buttons = 1,
		original_bar = "ExtraActionBarFrame",
	},
	bar10 = {
		num_buttons = 1,
		condition = "[petbattle] hide; [overridebar][vehicleui][possessbar,@vehicle,exists] show; hide",
	},
	bar11 = {
		button_type = {PetBattleFrame.BottomFrame.abilityButtons[1], PetBattleFrame.BottomFrame.abilityButtons[2],
			PetBattleFrame.BottomFrame.abilityButtons[3], PetBattleFrame.BottomFrame.SwitchPetButton,
			PetBattleFrame.BottomFrame.CatchButton, PetBattleFrame.BottomFrame.ForfeitButton},
		num_buttons = 12, -- actual number is 6, but we use 12, while creating a bar
		condition = "[petbattle] show; hide",
	},
	bar12 = {
		num_buttons = 1,
	},
}

local STANCE_PET_VISIBILITY = {
	WARRIOR = 2,
	PALADIN = 2,
	HUNTER = 1,
	ROGUE = 1,
	PRIEST = 2,
	DEATHKNIGHT = 2,
	SHAMAN = 1,
	MAGE = 1,
	WARLOCK = 1,
	MONK = 2,
	DRUID = 2,
	PET1 = {"BOTTOM", 0, 126},
	PET2 = {"BOTTOM", 0, 154},
	STANCE1 = {"BOTTOM", 0, 154},
	STANCE2 = {"BOTTOM", 0, 126},
}
-- page swapping is taken from tukui, thx :D really usefull thingy
local PAGE_LAYOUT = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7;",
	["MONK"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["DEFAULT"] = "[vehicleui:12] 12; [possessbar] 12; [overridebar] 14; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetPageLayout()
	local condition = PAGE_LAYOUT["DEFAULT"]
	local page = PAGE_LAYOUT[ns.C.playerclass]

	if page then
		condition = condition.." "..page
	end

	condition = condition.." [form] 1; 1"

	return condition
end

local function lsActionBar_OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		local button
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			button = _G["ActionButton"..i]
			self:SetFrameRef("ActionButton"..i, button)
		end

		self:Execute([[
			buttons = table.new()
			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("ActionButton"..i))
			end
		]])

		self:SetAttribute("_onstate-page", [[
			if HasTempShapeshiftActionBar() then
				newstate = GetTempShapeshiftBarIndex() or newstate
			end

			for i, button in ipairs(buttons) do
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])

		RegisterStateDriver(self, "page", GetPageLayout())
	else
		MainMenuBar_OnEvent(self, event, ...)
	end
end

local function SetStancePetActionBarPosition(self)
	if self:GetName() == "lsPetActionBar" then
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["PET"..STANCE_PET_VISIBILITY[ns.C.playerclass]]))
	else
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["STANCE"..STANCE_PET_VISIBILITY[ns.C.playerclass]]))
	end
end

local function lsSetFlashTexture(texture)
	texture:SetTexture(ns.M.textures.button.flash)
	texture:SetTexCoord(0.234375, 0.765625, 0.234375, 0.765625)
	texture:SetAllPoints()
end

local function lsSetNilNormalTexture(self, texture)
	if texture then
		self:SetNormalTexture(nil)
	end
end

local function lsSetVertexColor(self, r, g, b)
	local button = self:GetParent()

	if button == ExtraActionButton1 then
		button.lsBorder:SetVertexColor(0.9, 0.4, 0.1)
	else
		button.lsBorder:SetVertexColor(r, g, b)
	end
end

local function lsSetButtonStyle(button, petBattle)
	if not button then return end
	if button.styled then return end

	local name = button:GetName()
	local bIcon = button.icon or button.Icon
	local bFlash = button.Flash
	local bFOBorder = button.FlyoutBorder
	local bFOBorderShadow = button.FlyoutBorderShadow
	local bHotKey = button.HotKey
	local bCount = button.Count
	local bName = button.Name
	local bBorder = button.Border
	local bNewActionTexture = button.NewActionTexture
	local bCD = button.cooldown
	local bNormalTexture = button:GetNormalTexture()
	local bPushedTexture = button:GetPushedTexture()
	local bHighlightTexture = button:GetHighlightTexture()
	local bCheckedTexture = not petBattle and button:GetCheckedTexture()
	local bFloatingBG = not petBattle and _G[name.."FloatingBG"]

	-- PET
	local pAutoCast = not petBattle and _G[name.."AutoCastable"]
	local pShine = not petBattle and _G[name.."Shine"]

	-- PET BATTLE
	local pbCDShadow = button.CooldownShadow
	local pbCDFlash = button.CooldownFlash
	local pbCD = button.Cooldown
	local pbSelectedHighlight = button.SelectedHighlight
	local pbLock = button.Lock
	local pbBetterIcon = button.BetterIcon

	-- BAG
	local bbIconBorder = button.IconBorder

	ns.lsTweakIcon(bIcon)

	if bFlash then
		lsSetFlashTexture(bFlash)
	end

	if bFOBorder then
		ns.lsAlwaysHide(bFOBorder)
	end

	if bFOBorderShadow then
		ns.lsAlwaysHide(bFOBorderShadow)
	end

	if bHotKey then
		if name and gsub(name, "%d", "") == "PetActionButton" then ns.lsAlwaysHide(bHotKey) end

		bHotKey:SetFont(ns.M.font, 10, "THINOUTLINE")
		bHotKey:ClearAllPoints()
		bHotKey:SetPoint("TOPRIGHT", 2, 1)
	end

	if bCount then
		if name == "MainMenuBarBackpackButton" or name == "CharacterBag0Slot"
			or name == "CharacterBag1Slot" or name == " CharacterBag2Slot"
			or name == "CharacterBag3Slot" then
			ns.lsAlwaysHide(bCount)
		end

		bCount:SetFont(ns.M.font, 10, "THINOUTLINE")
		bCount:ClearAllPoints()
		bCount:SetPoint("BOTTOMRIGHT", 2, -1)
	end

	if bName then
		bName:SetFont(ns.M.font, 10, "THINOUTLINE")
		bName:ClearAllPoints()
		bName:SetPoint("BOTTOMLEFT", -2, 0)
		bName:SetPoint("BOTTOMRIGHT", 2, 0)
	end

	if bBorder then
		bBorder:SetTexture(nil)
	end

	if bNewActionTexture then
		bNewActionTexture:SetTexture(nil)
	end

	if bCD then
		ns.lsTweakCooldown(bCD)
	end

	if bNormalTexture then
		if name and gsub(name, "%d", "") == "PetActionButton" then hooksecurefunc(button, 'SetNormalTexture', lsSetNilNormalTexture) end

		bNormalTexture:SetTexture(nil)

		button.lsBorder = ns.lsCreateButtonBorder(button)

		if not petBattle then hooksecurefunc(bNormalTexture, 'SetVertexColor', lsSetVertexColor) end
	end

	if bPushedTexture then
		ns.lsSetPushedTexture(bPushedTexture)
	end

	if bHighlightTexture then
		ns.lsSetHighlightTexture(bHighlightTexture)
	end

	if bCheckedTexture then
		ns.lsSetCheckedTexture(bCheckedTexture)
	end

	if bFloatingBG then
		ns.lsAlwaysHide(bFloatingBG)
	end

	if pShine then
		pShine:ClearAllPoints()
		pShine:SetPoint("TOPLEFT", 1, -1)
		pShine:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	if pAutoCast then
		pAutoCast:ClearAllPoints()
		pAutoCast:SetPoint("TOPLEFT", -14, 14)
		pAutoCast:SetPoint("BOTTOMRIGHT", 14, -14)
	end

	if name == "ExtraActionButton1" then
		ns.lsAlwaysHide(button.style)
	end

	if pbCDShadow then
		pbCDShadow:SetAllPoints()
	end

	if pbCDFlash then
		pbCDFlash:SetAllPoints()
	end

	if pbCD then
		pbCD:SetFont(ns.M.font, 16, "THINOUTLINE")
		pbCD:ClearAllPoints()
		pbCD:SetPoint("CENTER", 0, -2)
	end

	if pbSelectedHighlight then
		pbSelectedHighlight:ClearAllPoints()
		pbSelectedHighlight:SetPoint("TOPLEFT", -8, 8)
		pbSelectedHighlight:SetPoint("BOTTOMRIGHT", 8, -8)
	end

	if pbLock then
		pbLock:ClearAllPoints()
		pbLock:SetPoint("TOPLEFT", 2, -2)
		pbLock:SetPoint("BOTTOMRIGHT", -2, 2)
	end

	if pbBetterIcon then
		pbBetterIcon:SetSize(18, 18)
		pbBetterIcon:ClearAllPoints()
		pbBetterIcon:SetPoint("BOTTOMRIGHT", 4, -4)
	end

	if bbIconBorder then
		ns.lsAlwaysHide(bbIconBorder)
		
		hooksecurefunc(bbIconBorder, 'SetVertexColor', lsSetVertexColor)
	end

	button.styled = true
end

local function lsSetButtonPosition(self, orientation, originalBar, buttonType, buttonSize, buttonGap, total)
	if originalBar and _G[originalBar]:GetParent() ~= self then
		_G[originalBar]:SetParent(self)
		_G[originalBar]:EnableMouse(false)
		_G[originalBar].ignoreFramePositionManager = true
	end

	local previous
	self.buttons = {}

	for i = 1, total do
		local button

		if type(buttonType) == "string" then
			button = _G[buttonType..i]
		else
			if type(buttonType[i]) == "string" then
				button = _G[buttonType[i]]
			else
				button = buttonType[i] or PetBattleFrame.BottomFrame.abilityButtons[i]
			end
		end

		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()

		if not originalBar then button:SetParent(self) end

		button:SetFrameStrata("LOW")
		button:SetFrameLevel(2)

		if i == 1 then
			button:SetPoint("TOPLEFT", self, "TOPLEFT", buttonGap / 2, -buttonGap / 2)
			button:SetPoint("BOTTOMLEFT", self, "TOPLEFT", buttonGap / 2, -buttonSize - buttonGap / 2)
		else
			if orientation == "HORIZONTAL" then
				button:SetPoint("LEFT", previous, "RIGHT", buttonGap, 0)
			else
				button:SetPoint("TOP", previous, "BOTTOM", 0, -buttonGap)
			end
		end

		if type(buttonType) == "string" or type(buttonType[i]) == "string" then
			lsSetButtonStyle(button)
		else
			lsSetButtonStyle(button, true)
		end

		self.buttons[i] = button
		previous = button
	end
end

local function lsActionButton_OnUpdate(button)
	local bIcon = button.icon
	local bName = button.Name

	if bName then
		local text = GetActionText(button.action)
		if text then
			bName:SetText(strsub(text, 1, 6))
		end
	end

	if bIcon then
		if button.action and IsActionInRange(button.action) ~= false then
			local isUsable, notEnoughMana = IsUsableAction(button.action)
			if isUsable then
				bIcon:SetVertexColor(1, 1, 1, 1)
			elseif notEnoughMana then
				bIcon:SetVertexColor(unpack(ns.M.colors.icon.oom))
			else
				bIcon:SetVertexColor(unpack(ns.M.colors.icon.nu))
			end
		else
			bIcon:SetVertexColor(unpack(ns.M.colors.icon.oor))
		end
	end
end

local function lsCreateLeaveVehicleButton(bar)
	local button = CreateFrame("Button", "lsVehicleExitButton", bar, "SecureHandlerClickTemplate")
	button:SetFrameStrata("LOW")
	button:SetFrameLevel(2)
	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function() VehicleExit() end)
	button:SetAllPoints(bar)

	button.icon = button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(12 / 64, 52 / 64, 12 / 64, 52 / 64)
	button.icon:ClearAllPoints()
	button.icon:SetPoint("TOPLEFT", 1, -1)
	button.icon:SetPoint("BOTTOMRIGHT", -1, 1)

	button.border = ns.lsCreateButtonBorder(button)
	button.border:SetVertexColor(1, 0.1, 0.15)

	button:SetHighlightTexture(1, 1, 1)
	ns.lsSetHighlightTexture(button:GetHighlightTexture())

	button:SetPushedTexture(1, 1, 1)
	ns.lsSetPushedTexture(button:GetPushedTexture())
end

local function SetPetBattleButtonPosition()
	local bdata = BAR_LAYOUT.bar11
	lsSetButtonPosition(lsPetBattleBar, ns.C.bars.bar11.orientation, bdata.original_bar, bdata.button_type, ns.C.bars.bar11.button_size, ns.C.bars.bar11.button_gap, 6)
end

local function FlyoutButtonToggleHook(...)
	local self, flyoutID = ...

	if not self:IsShown() then return end

	local _, _, numSlots = GetFlyoutInfo(flyoutID)
	for i = 1, numSlots do
		lsSetButtonStyle(_G["SpellFlyoutButton"..i])
	end
end

local function lsActionBarManager_OnEvent(self, event)
	local multiplier = 2 - (lsActionBarManager.bar2Shown and 1 or 0) - (lsActionBarManager.bar3Shown and 1 or 0)

	if lsActionBarManager.bar2Shown then
		RegisterStateDriver(lsMultiBottomLeftBar, "visibility", BAR_LAYOUT.bar2.condition)
	else
		RegisterStateDriver(lsMultiBottomLeftBar, "visibility", "hide")
	end

	if lsActionBarManager.bar3Shown then
		local point, x, y = unpack(ns.C.bars.bar3.point)
		lsMultiBottomRightBar:SetPoint(point, x, y - multiplier * 32)

		RegisterStateDriver(lsMultiBottomRightBar, "visibility", BAR_LAYOUT.bar3.condition)
	else
		RegisterStateDriver(lsMultiBottomRightBar, "visibility", "hide")
	end

	local point, x, y = unpack(STANCE_PET_VISIBILITY["PET"..STANCE_PET_VISIBILITY[ns.C.playerclass]])
	lsPetActionBar:SetPoint(point, x, y - multiplier * 32)

	local point, x, y = unpack(STANCE_PET_VISIBILITY["STANCE"..STANCE_PET_VISIBILITY[ns.C.playerclass]])
	lsStanceBar:SetPoint(point, x, y - multiplier * 32)

	if event == "PLAYER_REGEN_ENABLED" then
		lsActionBarManager:UnregisterEvent("PLAYER_REGEN_ENABLED")
		lsActionBarManager:SetScript("OnEvent", nil)
	end
end

local function lsActionBarManager_Update(bottomLeftBar, bottomRightBar)
	if not lsActionBarManager.forceUpdate then
		lsActionBarManager.forceUpdate = lsActionBarManager.bar2Shown ~= bottomLeftBar
		if not lsActionBarManager.forceUpdate then
			lsActionBarManager.forceUpdate = lsActionBarManager.bar3Shown ~= bottomRightBar
		end
	end

	if lsActionBarManager.forceUpdate then
		lsActionBarManager.bar2Shown = bottomLeftBar
		lsActionBarManager.bar3Shown = bottomRightBar

		if InCombatLockdown() then
			lsActionBarManager:RegisterEvent("PLAYER_REGEN_ENABLED")
			lsActionBarManager:SetScript("OnEvent", lsActionBarManager_OnEvent)
		else
			lsActionBarManager_OnEvent(lsActionBarManager, "CUSTOM_FORCE_UPDATE")
		end
	end
end

function ns.lsActionBars_Initialize(enableManager)
	local f = CreateFrame("Frame", "lsBottomLine", UIParent)
	f:SetFrameStrata("BACKGROUND")
	f:SetFrameLevel(3)
	f:SetSize(406, 52)
	f:SetPoint("BOTTOM", 0, 5)

	f.actbar = f:CreateTexture(nil, "BACKGROUND", nil, -8)
	f.actbar:SetPoint("CENTER")
	f.actbar:SetTexture("Interface\\AddOns\\oUF_LS\\media\\actionbar")

	for b, bdata in next, (BAR_LAYOUT) do
		local name
		if type(bdata.button_type) == "string" then
			name = "ls"..bdata.button_type:gsub("Button", ""):gsub("Bar", "").."Bar"
		else
			if tonumber(strmatch(b, "(%d+)")) == 8 then
				name = "lsBagBar"
			elseif tonumber(strmatch(b, "(%d+)")) == 10 then
				name = "lsVehicleExitBar"
			elseif tonumber(strmatch(b, "(%d+)")) == 11 then
				name = "lsPetBattleBar"
			elseif tonumber(strmatch(b, "(%d+)")) == 11 then
				name = "lsPlayerPowerBarAlt"
			end
		end

		local bar = CreateFrame("Frame", name, UIParent, "SecureHandlerStateTemplate")
		if ns.C.bars[b].orientation == "HORIZONTAL" then
			bar:SetSize(ns.C.bars[b].button_size * bdata.num_buttons + ns.C.bars[b].button_gap * bdata.num_buttons,
				ns.C.bars[b].button_size + ns.C.bars[b].button_gap)
		else
			bar:SetSize(ns.C.bars[b].button_size + ns.C.bars[b].button_gap,
				ns.C.bars[b].button_size * bdata.num_buttons + ns.C.bars[b].button_gap * bdata.num_buttons)
		end
		bar:SetFrameStrata("LOW")
		bar:SetFrameLevel(1)

		if tonumber(strmatch(b, "(%d+)")) == 1 then
			bar:RegisterEvent("PLAYER_LOGIN")
			bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			bar:SetScript("OnEvent", lsActionBar_OnEvent)
		end

		if tonumber(strmatch(b, "(%d+)")) ~= 10 and tonumber(strmatch(b, "(%d+)")) ~= 11 and tonumber(strmatch(b, "(%d+)")) ~= 12 then
			lsSetButtonPosition(bar, ns.C.bars[b].orientation, bdata.original_bar, bdata.button_type, ns.C.bars[b].button_size, ns.C.bars[b].button_gap, bdata.num_buttons)
		elseif tonumber(strmatch(b, "(%d+)")) == 10 then
			lsCreateLeaveVehicleButton(bar)
		elseif tonumber(strmatch(b, "(%d+)")) == 12 then
			PlayerPowerBarAlt:SetParent(bar)
			PlayerPowerBarAlt:ClearAllPoints()
			PlayerPowerBarAlt:SetPoint("BOTTOM", bar, "BOTTOM", 0, 0)
			PlayerPowerBarAlt.ignoreFramePositionManager = true
		end

		if bdata.condition then
			RegisterStateDriver(bar, "visibility", bdata.condition)
		end

		ns.bars[b] = bar
	end

	for b, bar in pairs(ns.bars) do
		if ns.C.bars[b].point then
			if b == "bar8" and not lsBagInfoBar then
				bar:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -20, 6)
			else
				bar:SetPoint(unpack(ns.C.bars[b].point))
			end
		else
			SetStancePetActionBarPosition(bar)
		end
	end

	-- Hiding different useless textures
	FlowContainer_PauseUpdates(PetBattleFrame.BottomFrame.FlowFrame)
	MainMenuBar.slideOut.IsPlaying = function() return true end

	for _, f in next, {
		MainMenuBar,
		MainMenuBarPageNumber,
		ActionBarDownButton,
		ActionBarUpButton,
		OverrideActionBarExpBar,
		OverrideActionBarHealthBar,
		OverrideActionBarPowerBar,
		OverrideActionBarPitchFrame,
		OverrideActionBarLeaveFrame,
		PetBattleFrame.BottomFrame.FlowFrame,
		PetBattleFrame.BottomFrame.Delimiter,
		PetBattleFrame.BottomFrame.MicroButtonFrame,
	} do
		f:SetParent(ns.hiddenParentFrame)
		f.ignoreFramePositionManager = true
	end

	for _, t in next, {
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
		PossessBackground1,
		PossessBackground2,
		StanceBarLeft,
		StanceBarMiddle,
		StanceBarRight,
		MainMenuBarTexture0,
		MainMenuBarTexture1,
		MainMenuBarTexture2,
		MainMenuBarTexture3,
		MainMenuBarLeftEndCap,
		MainMenuBarRightEndCap,
		PetBattleFrame.BottomFrame.Background,
		PetBattleFrame.BottomFrame.LeftEndCap,
		PetBattleFrame.BottomFrame.RightEndCap,
		PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2,
		PetBattleFrameXPBarLeft,
		PetBattleFrameXPBarMiddle,
		PetBattleFrameXPBarRight,
		SpellFlyoutHorizontalBackground,
		SpellFlyoutVerticalBackground,
		SpellFlyoutBackgroundEnd,
	} do
		t:SetTexture(nil)
	end

	for i = 7, 12 do
		select(i, PetBattleFrameXPBar:GetRegions()):SetTexture(nil)
	end

	for i = 1, 6 do
		local b = _G["OverrideActionBarButton"..i]
		b:UnregisterAllEvents()
		b:SetAttribute("statehidden", true)
	end

	select(5, PetBattleFrameXPBar:GetRegions()):SetTexture(unpack(ns.M.colors.exp.bg))

	PetBattleFrameXPBar:SetFrameStrata("LOW")
	PetBattleFrameXPBar:SetFrameLevel(4)
	PetBattleFrameXPBar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 52)
	PetBattleFrameXPBar:SetSize(378, 8)
	PetBattleFrameXPBar:SetStatusBarTexture(ns.M.textures.statusbar)
	PetBattleFrameXPBar:SetStatusBarColor(unpack(ns.M.colors.exp.normal))

	PetBattleFrameXPBar.TextString:SetFont(ns.M.font, 10, "THINOUTLINE")

	PetBattleFrameXPBar.Border = PetBattleFrameXPBar:CreateTexture(nil, "OVERLAY")
	PetBattleFrameXPBar.Border:SetPoint("CENTER", 0, 0)
	PetBattleFrameXPBar.Border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\exp_rep_border")

	PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
	PetBattleFrame.BottomFrame.TurnTimer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60)

	hooksecurefunc(SpellFlyout, "Toggle", FlyoutButtonToggleHook)
	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", SetPetBattleButtonPosition)
	hooksecurefunc("ActionButton_OnUpdate", lsActionButton_OnUpdate)

	if enableManager then
		local lsActionBarManager = CreateFrame("Frame", "lsActionBarManager")
		lsActionBarManager.bar2Shown = true
		lsActionBarManager.bar3Shown = true
		hooksecurefunc('SetActionBarToggles', lsActionBarManager_Update)
	end
end
