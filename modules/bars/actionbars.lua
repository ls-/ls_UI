local _, ns = ...
local E = ns.E

local match, tonumber = strmatch, tonumber
local BAR_CONFIG, COLORS, TEXTURES

E.ActionBars = {}

local ActionBars = E.ActionBars

ns.bars = {}

local BAR_LAYOUT = {
	bar1 = {
		buttons = {
			ActionButton1, ActionButton2, ActionButton3, ActionButton4, ActionButton5, ActionButton6,
			ActionButton7, ActionButton8, ActionButton9, ActionButton10, ActionButton11, ActionButton12
		},
		original_bar = MainMenuBarArtFrame,
		name = "lsMainMenuBar",
		condition = "[petbattle] hide; show",
	},
	bar2 = {
		buttons = {
			MultiBarBottomLeftButton1, MultiBarBottomLeftButton2, MultiBarBottomLeftButton3,	MultiBarBottomLeftButton4,
			MultiBarBottomLeftButton5, MultiBarBottomLeftButton6, MultiBarBottomLeftButton7, MultiBarBottomLeftButton8,
			MultiBarBottomLeftButton9, MultiBarBottomLeftButton10, MultiBarBottomLeftButton11, MultiBarBottomLeftButton12
		},
		original_bar = MultiBarBottomLeft,
		name = "lsMultiBarBottomLeftBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar3 = {
		buttons = {
			MultiBarBottomRightButton1, MultiBarBottomRightButton2, MultiBarBottomRightButton3, MultiBarBottomRightButton4,
			MultiBarBottomRightButton5, MultiBarBottomRightButton6, MultiBarBottomRightButton7, MultiBarBottomRightButton8,
			MultiBarBottomRightButton9, MultiBarBottomRightButton10, MultiBarBottomRightButton11, MultiBarBottomRightButton12
		},
		original_bar = MultiBarBottomRight,
		name = "lsMultiBarBottomRightBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar4 = {
		buttons = {
			MultiBarLeftButton1, MultiBarLeftButton2, MultiBarLeftButton3, MultiBarLeftButton4,
			MultiBarLeftButton5, MultiBarLeftButton6, MultiBarLeftButton7, MultiBarLeftButton8,
			MultiBarLeftButton9, MultiBarLeftButton10, MultiBarLeftButton11, MultiBarLeftButton12
		},
		original_bar = MultiBarLeft,
		name = "lsMultiBarLeftBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar5 = {
		buttons = {
			MultiBarRightButton1, MultiBarRightButton2, MultiBarRightButton3, MultiBarRightButton4,
			MultiBarRightButton5, MultiBarRightButton6, MultiBarRightButton7, MultiBarRightButton8,
			MultiBarRightButton9, MultiBarRightButton10, MultiBarRightButton11, MultiBarRightButton12
		},
		original_bar = MultiBarRight,
		name = "lsMultiBarRightBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar6 = {
		buttons = {
			PetActionButton1, PetActionButton2, PetActionButton3, PetActionButton4, PetActionButton5,
			PetActionButton6, PetActionButton7, PetActionButton8, PetActionButton9, PetActionButton10
		},
		original_bar = PetActionBarFrame,
		name = "lsPetActionBar",
		condition = "[pet,nopetbattle,novehicleui,nooverridebar,nobonusbar:5] show; hide",
	},
	bar7 = {
		buttons = {
			StanceButton1, StanceButton2, StanceButton3, StanceButton4, StanceButton5,
			StanceButton6, StanceButton7, StanceButton8, StanceButton9, StanceButton10
		},
		original_bar = StanceBarFrame,
		name = "lsStanceBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
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
	PET1 = {"BOTTOM", 0, 127},
	PET2 = {"BOTTOM", 0, 155},
	STANCE1 = {"BOTTOM", 0, 155},
	STANCE2 = {"BOTTOM", 0, 127},
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
	local page = PAGE_LAYOUT[ns.E.playerclass]

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
	end
end

local function SetStancePetActionBarPosition(self)
	if self:GetName() == "lsPetActionBar" then
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["PET"..STANCE_PET_VISIBILITY[ns.E.playerclass]]))
	else
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["STANCE"..STANCE_PET_VISIBILITY[ns.E.playerclass]]))
	end
end

local function ActionButton_OnUpdate(button)
	local bIcon = button.icon
	local bName = button.Name

	if bIcon then
		if button.action and IsActionInRange(button.action) ~= false then
			local isUsable, notEnoughMana = IsUsableAction(button.action)
			if isUsable then
				bIcon:SetVertexColor(1, 1, 1, 1)
			elseif notEnoughMana then
				bIcon:SetVertexColor(unpack(COLORS.icon.oom))
			else
				bIcon:SetVertexColor(unpack(COLORS.icon.nu))
			end
		else
			bIcon:SetVertexColor(unpack(COLORS.icon.oor))
		end
	end

	if bName then
		local text = bName:GetText()
		if text then
			bName:SetText(E:StringTruncate(text, 4))
		end
	end
end

local function FlyoutButtonToggleHook(...)
	local self, flyoutID = ...

	if not self:IsShown() then return end

	local _, _, numSlots = GetFlyoutInfo(flyoutID)
	for i = 1, numSlots do
		E:SkinActionButton(_G["SpellFlyoutButton"..i])
	end
end

local function ActionBarManager_OnEvent(self, event)
	local multiplier = 2 - (lsActionBarManager.bar2Shown and 1 or 0) - (lsActionBarManager.bar3Shown and 1 or 0)

	if lsActionBarManager.bar2Shown then
		RegisterStateDriver(lsMultiBarBottomLeftBar, "visibility", BAR_LAYOUT.bar2.condition)
	else
		RegisterStateDriver(lsMultiBarBottomLeftBar, "visibility", "hide")
	end

	if lsActionBarManager.bar3Shown then
		local point, x, y = unpack(BAR_CONFIG.bar3.point)
		lsMultiBarBottomRightBar:SetPoint(point, x, y - multiplier * 32)

		RegisterStateDriver(lsMultiBarBottomRightBar, "visibility", BAR_LAYOUT.bar3.condition)
	else
		RegisterStateDriver(lsMultiBarBottomRightBar, "visibility", "hide")
	end

	local point, x, y = unpack(STANCE_PET_VISIBILITY["PET"..STANCE_PET_VISIBILITY[ns.E.playerclass]])
	lsPetActionBar:SetPoint(point, x, y - multiplier * 32)

	local point, x, y = unpack(STANCE_PET_VISIBILITY["STANCE"..STANCE_PET_VISIBILITY[ns.E.playerclass]])
	lsStanceBar:SetPoint(point, x, y - multiplier * 32)

	if event == "PLAYER_REGEN_ENABLED" then
		lsActionBarManager:UnregisterEvent("PLAYER_REGEN_ENABLED")
		lsActionBarManager:SetScript("OnEvent", nil)
	end
end

local function ActionBarManager_Update(bottomLeftBar, bottomRightBar)
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
			lsActionBarManager:SetScript("OnEvent", ActionBarManager_OnEvent)
		else
			ActionBarManager_OnEvent(lsActionBarManager, "CUSTOM_FORCE_UPDATE")
		end
	end
end

function ActionBars:Initialize(enableManager)
	BAR_CONFIG, COLORS, TEXTURES = ns.C.bars, ns.M.colors, ns.M.textures

	local f = CreateFrame("Frame", nil, UIParent)
	f:SetFrameStrata("BACKGROUND")
	f:SetFrameLevel(3)
	f:SetSize(406, 52)
	f:SetPoint("BOTTOM", 0, 5)

	f.actbar = f:CreateTexture(nil, "BACKGROUND", nil, -8)
	f.actbar:SetPoint("CENTER")
	f.actbar:SetTexture("Interface\\AddOns\\oUF_LS\\media\\actionbar")

	for b, bdata in next, BAR_LAYOUT do
		local bar = CreateFrame("Frame", bdata.name, UIParent, "SecureHandlerStateTemplate")
		bar:SetFrameStrata("LOW")
		bar:SetFrameLevel(1)

		if BAR_CONFIG[b].orientation == "HORIZONTAL" then
			bar:SetSize(BAR_CONFIG[b].button_size * #bdata.buttons + BAR_CONFIG[b].button_gap * #bdata.buttons,
				BAR_CONFIG[b].button_size + BAR_CONFIG[b].button_gap)
		else
			bar:SetSize(BAR_CONFIG[b].button_size + BAR_CONFIG[b].button_gap,
				BAR_CONFIG[b].button_size * #bdata.buttons + BAR_CONFIG[b].button_gap * #bdata.buttons)
		end

		if tonumber(match(b, "(%d+)")) == 1 then
			bar:RegisterEvent("PLAYER_LOGIN")
			bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			bar:SetScript("OnEvent", lsActionBar_OnEvent)
		end

		if tonumber(match(b, "(%d+)")) == 6 then
			E:SetButtonPosition(bdata.buttons, BAR_CONFIG[b].button_size, BAR_CONFIG[b].button_gap, bar, BAR_CONFIG[b].orientation, BAR_CONFIG[b].direction, E.SkinPetActionButton, bdata.original_bar)
		else
			E:SetButtonPosition(bdata.buttons, BAR_CONFIG[b].button_size, BAR_CONFIG[b].button_gap, bar, BAR_CONFIG[b].orientation, BAR_CONFIG[b].direction, E.SkinActionButton, bdata.original_bar)
		end

		if bdata.condition then
			RegisterStateDriver(bar, "visibility", bdata.condition)
		end

		ns.bars[b] = bar
	end

	for b, bar in next, ns.bars do
		if BAR_CONFIG[b].point then
			bar:SetPoint(unpack(BAR_CONFIG[b].point))
		else
			SetStancePetActionBarPosition(bar)
		end
	end

	-- Hiding different useless textures
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
	} do
		f:SetParent(ns.M.hiddenParent)
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
		SpellFlyoutHorizontalBackground,
		SpellFlyoutVerticalBackground,
		SpellFlyoutBackgroundEnd,
	} do
		t:SetTexture(nil)
	end

	for i = 1, 6 do
		local b = _G["OverrideActionBarButton"..i]
		b:UnregisterAllEvents()
		b:SetAttribute("statehidden", true)
	end

	hooksecurefunc(SpellFlyout, "Toggle", FlyoutButtonToggleHook)
	hooksecurefunc("ActionButton_OnUpdate", ActionButton_OnUpdate)

	if enableManager then
		local lsActionBarManager = CreateFrame("Frame", "lsActionBarManager")
		lsActionBarManager.bar2Shown = true
		lsActionBarManager.bar3Shown = true
		hooksecurefunc("SetActionBarToggles", ActionBarManager_Update)
	end
end
