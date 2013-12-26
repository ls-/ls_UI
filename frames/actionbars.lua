local _, ns = ...
local C, M = ns.C, ns.M

ns.bars = {}

local BAR_LAYOUT = {
	bar1 = {
		size = {380, 28},
		point = {"BOTTOM", 0, 16.5},
		button_type = "ActionButton",
		total_button = 12,
		button_size = 28,
		original_bar = "MainMenuBarArtFrame",
		orientation = "HORIZONTAL",
		condition = "[petbattle] hide; show",
	},
	bar2 = {
		size = {380, 28},
		point = {"BOTTOM", 0, 64},
		button_type = "MultiBarBottomLeftButton",
		total_button = 12,
		button_size = 28,
		original_bar = "MultiBarBottomLeft",
		orientation = "HORIZONTAL",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar3 = {
		size = {380, 28},
		point = {"BOTTOM", 0, 96},
		button_type = "MultiBarBottomRightButton",
		total_button = 12,
		button_size = 28,
		original_bar = "MultiBarBottomRight",
		orientation = "HORIZONTAL",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar4 = {
		size = {28, 380},
		point = {"BOTTOMRIGHT", -36, 300},
		button_type = "MultiBarLeftButton",
		total_button = 12,
		button_size = 28,
		original_bar = "MultiBarLeft",
		orientation = "VERTICAL",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar5 = {
		size = {28, 380},
		point = {"BOTTOMRIGHT", -4, 300},
		button_type = "MultiBarRightButton",
		total_button = 12,
		button_size = 28,
		original_bar = "MultiBarRight",
		orientation = "VERTICAL",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar6 = {
		size = {276, 24},
		button_type = "PetActionButton",
		total_button = 10,
		button_size = 24,
		original_bar = "PetActionBarFrame",
		orientation = "HORIZONTAL",
		condition = "[pet,nopetbattle,novehicleui,nooverridebar,nobonusbar:5] show; hide",
	},
	bar7 = {
		size = {276, 24},
		button_type = "StanceButton",
		total_button = 10,
		button_size = 24,
		original_bar = "StanceBarFrame",
		orientation = "HORIZONTAL",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar8 = {
		size = {144, 28},
		point = {"TOPLEFT", "oUF_LSBagInfoBar", "BOTTOM", 0, -6},
		button_type = {"CharacterBag3Slot", "CharacterBag2Slot", "CharacterBag1Slot", "CharacterBag0Slot", "MainMenuBarBackpackButton"},
		total_button = 5,
		button_size = 28,
		orientation = "HORIZONTAL",
	},
	bar9 = {
		size = {44, 44},
		point = {"BOTTOM", -166, 158},
		button_type = "ExtraActionButton",
		total_button = 1,
		button_size = 44,
		original_bar = "ExtraActionBarFrame",
		orientation = "HORIZONTAL",
	},
	bar10 = {
		size = {24, 24},
		point = {"BOTTOM", 176, 130},
		condition = "[target=vehicle,exists] show; hide",
	},
	bar11 = {
		size = {380, 28},
		point = {"BOTTOM", 0, 16.5},
		button_type = {PetBattleFrame.BottomFrame.abilityButtons[1], PetBattleFrame.BottomFrame.abilityButtons[2],
			PetBattleFrame.BottomFrame.abilityButtons[3], PetBattleFrame.BottomFrame.SwitchPetButton,
			PetBattleFrame.BottomFrame.CatchButton, PetBattleFrame.BottomFrame.ForfeitButton},
		total_button = 6,
		button_size = 28,
		orientation = "HORIZONTAL",
		condition = "[petbattle] show; hide",
	},
	bar12 = {
		size = {128, 128},
		point = {"BOTTOM", 0, 240},
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
	PET1 = {"BOTTOM", "UIParent", "BOTTOM", 0, 130},
	PET2 = {"BOTTOM", "UIParent", "BOTTOM", 0, 158},
	STANCE1 = {"BOTTOM", "UIParent", "BOTTOM", 0, 158},
	STANCE2 = {"BOTTOM", "UIParent", "BOTTOM", 0, 130},
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

local function oUF_LSActionBar_OnEvent(self, event, ...)
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

local function oUF_LSPetActionBar_OnUpdate(self, event, ...)
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i = 1, 10 do
		local buttonName = "PetActionButton" .. i
		petActionButton = _G[buttonName]
		petActionIcon = _G[buttonName.."Icon"]
		petAutoCastableTexture = _G[buttonName.."AutoCastable"]
		petAutoCastShine = _G[buttonName.."Shine"]

		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		
		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end
		
		petActionButton.isToken = isToken
		petActionButton.tooltipSubtext = subtext

		if isActive then
			petActionButton:SetChecked(1)
			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(petActionButton)
			end
		else
			petActionButton:SetChecked(0)
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(petActionButton)
			end			
		end
		
		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end
		
		if autoCastEnabled then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end

		if name then
			petActionButton:SetAlpha(1)
			petActionButton.border:Show()
		else
			petActionButton:SetAlpha(0)
			if self.showGrid == 0 then
				petActionButton.border:Hide()
			end
		end

		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(petActionIcon, nil)
			else
				SetDesaturation(petActionIcon, 1)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end
		
		if not PetHasActionBar() then
			petActionButton:SetAlpha(0)
		else
			petActionButton:SetAlpha(1)
		end
	end
end

local function oUF_LSPetActionBar_ShowGrid(self)
	self.showGrid = self.showGrid + 1
	for i = 1, #self.buttons do
		self.buttons[i]:SetAlpha(1)
		self.buttons[i].border:Show()
	end
	oUF_LSPetActionBar_OnUpdate(self, "FROM_SHOW_GRID")
	
end

local function oUF_LSPetActionBar_HideGrid(self)
	if self.showGrid > 0 then self.showGrid = self.showGrid - 1 end
	if self.showGrid == 0 then
		for i = 1, 10 do
			if not GetPetActionInfo(i) then
				self.buttons[i]:SetAlpha(0)
				self.buttons[i].border:Hide()
			end
		end
		oUF_LSPetActionBar_OnUpdate(self, "FROM_HIDE_GRID")
	end
end

local function oUF_LSPetActionButton_OnDragStart(self)
	if InCombatLockdown() then return end
	if LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION") then
		self:SetChecked(0)
		PickupPetAction(self:GetID())
	end
end

local function oUF_LSPetActionButton_OnReceiveDrag(self)
	if InCombatLockdown() then return end
	local cursorType = GetCursorInfo()
		if cursorType == "petaction" then
		self:SetChecked(0)
		PickupPetAction(self:GetID())
	end
end

local function oUF_LSPetActionBar_OnEvent(self, event, ...)
	arg1 = ...
	if event == "PET_BAR_UPDATE" or
		(event == "UNIT_PET" and arg1 == "player") or
		((event == "UNIT_FLAGS" or event == "UNIT_AURA") and arg1 == "pet") or
		event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" then
		oUF_LSPetActionBar_OnUpdate(self, event)
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar_UpdateCooldowns()
	elseif event == "PET_BAR_SHOWGRID" then
		oUF_LSPetActionBar_ShowGrid(self)
		elseif event == "PET_BAR_HIDEGRID" then
		oUF_LSPetActionBar_HideGrid(self)
	end
end

local function SetStancePetActionBarPosition(self)
	if self:GetName() == "oUF_LSPetActionBar" then
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["PET"..STANCE_PET_VISIBILITY[ns.C.playerclass]]))
	else
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["STANCE"..STANCE_PET_VISIBILITY[ns.C.playerclass]]))
	end
end

-- TODO: REWRITE!
local function SetDefaultButtonStyle(bType, id)
	local button
	local id = id or ""
	if type(bType) == "string" then
		button = _G[bType..id]
	else
		button = bType
	end
	if not button then return end
	if button.styled then return end

	local bIcon = button.Icon or button.icon or button.IconTexture
	local HotKey
	if type(bType) == "string" then
		bHotKey = _G[bType..id.."HotKey"]
	else 
		bHotKey = button.HotKey
	end
	button.border = button:GetNormalTexture()

	ns.SetIconStyle(button, bIcon)

	if bHotKey then
		bHotKey:SetFont(M.font, 12, "THINOUTLINE")
		bHotKey:ClearAllPoints()
		bHotKey:SetPoint("TOPRIGHT", 0, 0)
	end

	button:SetNormalTexture("")
	button.SetNormalTexture = function() return end

	ns.SetHighlightTexture(button)
	ns.SetPushedTexture(button)

	if type(bType) == "string" then
		local name = bType..id
		local bCount = _G[name.."Count"]
		local bFlash = _G[name.."Flash"]
		local bCD = _G[name.."Cooldown"]

		if bCD then
			bCD:SetAllPoints(button)
		end

		if bType == "ActionButton" or bType == "PetActionButton"
			or bType == "StanceButton" or bType == "ExtraActionButton" then
			button.border = ns.CreateButtonBorder(button, 1)
		else
			button.border = ns.CreateButtonBorder(button, 0)
			button.border:SetVertexColor(unpack(M.colors.button.normal))
		end

		if bCount and (bType == "MainMenuBarBackpackButton" 
			or bType == "CharacterBag0Slot"	or bType == "CharacterBag1Slot"
			or bType == " CharacterBag2Slot" or bType == "CharacterBag3Slot") then
			ns.AlwaysHide(bCount)
		end

		ns.SetCheckedTexture(button)

		if bFlash then
			ns.AlwaysHide(bFlash)
		end

		if bType == "ExtraActionButton" then
			ns.AlwaysHide(button.style)
		end

		if bType == "ActionButton" or bType == "MultiBarBottomLeftButton"
			or bType == "MultiBarBottomRightButton" or bType == "MultiBarRightButton"
			or bType == "MultiBarLeftButton" then
			local bBorder	= _G[name.."Border"]
			local bMacro = _G[name.."Name"]
			local bFlyoutBorder = _G[name.."FlyoutBorder"]
			local bFlyoutBorderShadow = _G[name.."FlyoutBorderShadow"]
			local bFloatingBG = _G[name.."FloatingBG"]

			if bCount then 
				bCount:SetFont(M.font, 12, "THINOUTLINE")
				bCount:ClearAllPoints()
				bCount:SetPoint("BOTTOMLEFT", 0, 0)
			end

			if bBorder then
				ns.AlwaysHide(bBorder)
			end

			if bMacro then
				bMacro:SetFont(M.font, 10, "THINOUTLINE")
				bMacro:ClearAllPoints()
				bMacro:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -2, 0)
				bMacro:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, 0)
			end

			if bFlyoutBorder then
				ns.AlwaysHide(bFlyoutBorder)
			end

			if bFlyoutBorderShadow then
				ns.AlwaysHide(bFlyoutBorderShadow)
			end

			if bFloatingBG then
				ns.AlwaysHide(bFloatingBG)
			end

			if button:GetChecked() then
				ActionButton_UpdateState(button)
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

		button.border = ns.CreateButtonBorder(button, 1)
	end
	button.styled = true
end

local function SetButtonPosition(self, orientation, originalBar, buttonType, buttonSize, total)
	if originalBar then
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

		if originalBar == "MainMenuBarArtFrame" or originalBar == "PetActionBarFrame" 
			--[[or originalBar == "StanceBarFrame"]] or not originalBar then button:SetParent(self) end
		
		if originalBar == "PetActionBarFrame" then
			button:SetScript("OnDragStart", oUF_LSPetActionButton_OnDragStart)
			button:SetScript("OnReceiveDrag", oUF_LSPetActionButton_OnReceiveDrag)
			button:Show()
		end

		button:SetFrameStrata("LOW")
		button:SetFrameLevel(2)

		if i == 1 then
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			button:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -buttonSize)
		else
			if orientation == "HORIZONTAL" then
				button:SetPoint("LEFT", previous, "RIGHT", 4, 0)
			else
				button:SetPoint("TOP", previous, "BOTTOM", 0, -4)
			end
		end

		if type(buttonType) == "string" then
			SetDefaultButtonStyle(buttonType, i)
		else
			if type(buttonType[i]) == "string" then
				SetDefaultButtonStyle(buttonType[i])
			else
				SetDefaultButtonStyle(button)
			end
		end

		self.buttons[i] = button
		previous = button
	end
end

local function oUF_LSActionButton_OnUpdate(button)
	local bIcon = _G[button:GetName().."Icon"]
	local bMacro = _G[button:GetName().."Name"]

	if bMacro then
		local text = GetActionText(button.action)
		if text then
			bMacro:SetText(strsub(text, 1, 6))
		end
	end

	if bIcon then 
		if button.action and IsActionInRange(button.action) ~= 0 then
			local isUsable, notEnoughMana = IsUsableAction(button.action)
			if isUsable then
				bIcon:SetVertexColor(1, 1, 1, 1)
			elseif notEnoughMana then
				bIcon:SetVertexColor(unpack(M.colors.icon.oom))
			else
				bIcon:SetVertexColor(unpack(M.colors.icon.nu))
			end
		else
			bIcon:SetVertexColor(unpack(M.colors.icon.oor))
		end
	end
end

local function CreateLeaveVehicleButton(bar)
	local button = CreateFrame("Button", "oUF_LSVehicleExitButton", bar, "SecureHandlerClickTemplate")
	button:SetFrameStrata("LOW")
	button:SetFrameLevel(2)
	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function() VehicleExit() end)
	button:SetAllPoints(bar)

	button.icon = button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(12 / 64, 52 / 64, 12 / 64, 52 / 64)
	button.icon:ClearAllPoints()
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)

	button.border = ns.CreateButtonBorder(button, 1)

	ns.SetHighlightTexture(button)
	ns.SetPushedTexture(button)
end

local function SetPetBattleButtonPosition()
	local bdata = BAR_LAYOUT.bar11
	SetButtonPosition(oUF_LSPetBattleBar, bdata.orientation, bdata.original_bar, bdata.button_type, bdata.button_size, bdata.total_button)
end

local function FlyoutButtonToggleHook(...)
	local self, flyoutID = ...

	if not self:IsShown() then return end

	local _, _, numSlots = GetFlyoutInfo(flyoutID)
	for i = 1, numSlots do
		SetDefaultButtonStyle("SpellFlyoutButton", i)
	end
end

do
	local f = CreateFrame("Frame", "oUF_LSBottomLine", UIParent)
	f:SetFrameStrata("BACKGROUND")
	f:SetFrameLevel(3)
	f:SetSize(406, 52)
	f:SetPoint("BOTTOM", 0, 5)

	f.actbar = f:CreateTexture(nil, "BACKGROUND", nil, -8)
	f.actbar:SetPoint("CENTER")
	f.actbar:SetTexture("Interface\\AddOns\\oUF_LS\\media\\actionbar")

	local FRAMES = {
		MainMenuBar, MainMenuBarArtFrame, OverrideActionBar,
		PossessBarFrame, PetActionBarFrame, IconIntroTracker,
		ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight
	}

	for i, f in pairs(FRAMES) do
		f:UnregisterAllEvents()
		f.ignoreFramePositionManager = true
		f:SetParent(ns.hiddenParentFrame)
	end

	for i = 1, 6 do
		local b = _G["OverrideActionBarButton"..i]
		b:UnregisterAllEvents()
		b:SetAttribute("statehidden", true)
	end

	for b, bdata in pairs(BAR_LAYOUT) do
		local name
		if type(bdata.button_type) == "string" then
			name = "oUF_LS"..bdata.button_type:gsub("Button", ""):gsub("Bar", "").."Bar"
		else
			if tonumber(strmatch(b, "(%d+)")) == 8 then
				name = "oUF_LSBagBar"
			elseif tonumber(strmatch(b, "(%d+)")) == 10 then
				name = "oUF_LSVehicleExitBar"
			elseif tonumber(strmatch(b, "(%d+)")) == 11 then
				name = "oUF_LSPetBattleBar"
			elseif tonumber(strmatch(b, "(%d+)")) == 11 then
				name = "oUF_LSPlayerPowerBarAlt"
			end
		end

		local bar = CreateFrame("Frame", name, UIParent, "SecureHandlerStateTemplate")
		bar:SetSize(unpack(bdata.size))
		bar:SetFrameStrata("LOW")
		bar:SetFrameLevel(1)

		bar.showGrid = 0

		if tonumber(strmatch(b, "(%d+)")) == 1 then
			bar:RegisterEvent("PLAYER_LOGIN")
			bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			bar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
			bar:SetScript("OnEvent", oUF_LSActionBar_OnEvent)
		elseif tonumber(strmatch(b, "(%d+)")) == 6 then
			bar:RegisterEvent("PLAYER_CONTROL_LOST")
			bar:RegisterEvent("PLAYER_CONTROL_GAINED")
			bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
			bar:RegisterEvent("UNIT_PET")
			bar:RegisterEvent("UNIT_FLAGS")
			bar:RegisterEvent("UNIT_AURA")
			bar:RegisterEvent("PET_BAR_UPDATE")
			bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
			bar:RegisterEvent("PET_BAR_SHOWGRID")
			bar:RegisterEvent("PET_BAR_HIDEGRID")
			bar:SetScript("OnEvent", oUF_LSPetActionBar_OnEvent)
		end

		if tonumber(strmatch(b, "(%d+)")) ~= 10 and tonumber(strmatch(b, "(%d+)")) ~= 11 and tonumber(strmatch(b, "(%d+)")) ~= 12 then
			SetButtonPosition(bar, bdata.orientation, bdata.original_bar, bdata.button_type, bdata.button_size, bdata.total_button)
		elseif tonumber(strmatch(b, "(%d+)")) == 10 then
			CreateLeaveVehicleButton(bar)
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
		if BAR_LAYOUT[b].point then
			if b == "bar8" and not oUF_LSBagInfoBar then
				bar:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -20, 6)
			else
				bar:SetPoint(unpack(BAR_LAYOUT[b].point))
			end
		else
			SetStancePetActionBarPosition(bar)
		end
	end

	FlowContainer_PauseUpdates(PetBattleFrame.BottomFrame.FlowFrame)
	MainMenuBar.slideOut.IsPlaying = function() return true end
	-- Hiding different useless textures
	MainMenuBarPageNumber:SetParent(ns.hiddenParentFrame)
	ActionBarDownButton:SetParent(ns.hiddenParentFrame)
	ActionBarUpButton:SetParent(ns.hiddenParentFrame)
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
	--PetBattle UI
	PetBattleFrame.BottomFrame.FlowFrame:SetParent(ns.hiddenParentFrame)
	PetBattleFrame.BottomFrame.Delimiter:SetParent(ns.hiddenParentFrame)
	PetBattleFrame.BottomFrame.MicroButtonFrame:SetParent(ns.hiddenParentFrame)
	PetBattleFrame.BottomFrame.Background:SetTexture("")
	PetBattleFrame.BottomFrame.LeftEndCap:SetTexture("")
	PetBattleFrame.BottomFrame.RightEndCap:SetTexture("")
	PetBattleFrameXPBarLeft:SetTexture("")
	PetBattleFrameXPBarMiddle:SetTexture("")
	PetBattleFrameXPBarRight:SetTexture("")
	for i = 7, 12 do
		select(i, PetBattleFrameXPBar:GetRegions()):SetTexture("")
	end

	select(5, PetBattleFrameXPBar:GetRegions()):SetTexture(unpack(M.colors.exp.bg))

	PetBattleFrameXPBar:SetFrameStrata("LOW")
	PetBattleFrameXPBar:SetFrameLevel(4)
	PetBattleFrameXPBar:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 52)
	PetBattleFrameXPBar:SetSize(382, 8)
	PetBattleFrameXPBar:SetStatusBarTexture(M.textures.statusbar)
	PetBattleFrameXPBar:SetStatusBarColor(unpack(M.colors.exp.normal))

	PetBattleFrameXPBar.TextString:SetFont(M.font, 10, "THINOUTLINE")

	PetBattleFrameXPBar.Border = PetBattleFrameXPBar:CreateTexture(nil, "OVERLAY")
	PetBattleFrameXPBar.Border:SetPoint("CENTER", 0, 0)
	PetBattleFrameXPBar.Border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\exp_rep_border")
	
	PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2:SetTexture(nil)
	PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
	PetBattleFrame.BottomFrame.TurnTimer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 66)

	hooksecurefunc(SpellFlyout, "Toggle", FlyoutButtonToggleHook)
	SpellFlyoutHorizontalBackground:SetTexture(nil)
	SpellFlyoutVerticalBackground:SetTexture(nil)
	SpellFlyoutBackgroundEnd:SetTexture(nil)
	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", SetPetBattleButtonPosition)
	hooksecurefunc("ActionButton_OnUpdate", oUF_LSActionButton_OnUpdate)
end