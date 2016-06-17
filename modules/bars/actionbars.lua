local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS, TEXTURES = M.colors, M.textures
local B = E:GetModule("Bars")

local tonumber = tonumber
local match = strmatch

local Bars = {}

local BARS_CFG = {
	bar1 = {
		point = {"BOTTOM", 0, 12},
		button_size = 28,
		button_gap = 4,
		direction = "RIGHT",
	},
}

local BAR_LAYOUT = {
	bar1 = {
		buttons = {
			ActionButton1, ActionButton2, ActionButton3, ActionButton4, ActionButton5, ActionButton6,
			ActionButton7, ActionButton8, ActionButton9, ActionButton10, ActionButton11, ActionButton12
		},
		original_bar = MainMenuBarArtFrame,
		name = "LSMainMenuBar",
		condition = "[petbattle] hide; show",
	},
	bar2 = {
		buttons = {
			MultiBarBottomLeftButton1, MultiBarBottomLeftButton2, MultiBarBottomLeftButton3,	MultiBarBottomLeftButton4,
			MultiBarBottomLeftButton5, MultiBarBottomLeftButton6, MultiBarBottomLeftButton7, MultiBarBottomLeftButton8,
			MultiBarBottomLeftButton9, MultiBarBottomLeftButton10, MultiBarBottomLeftButton11, MultiBarBottomLeftButton12
		},
		original_bar = MultiBarBottomLeft,
		name = "LSMultiBarBottomLeftBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar3 = {
		buttons = {
			MultiBarBottomRightButton1, MultiBarBottomRightButton2, MultiBarBottomRightButton3, MultiBarBottomRightButton4,
			MultiBarBottomRightButton5, MultiBarBottomRightButton6, MultiBarBottomRightButton7, MultiBarBottomRightButton8,
			MultiBarBottomRightButton9, MultiBarBottomRightButton10, MultiBarBottomRightButton11, MultiBarBottomRightButton12
		},
		original_bar = MultiBarBottomRight,
		name = "LSMultiBarBottomRightBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar4 = {
		buttons = {
			MultiBarLeftButton1, MultiBarLeftButton2, MultiBarLeftButton3, MultiBarLeftButton4,
			MultiBarLeftButton5, MultiBarLeftButton6, MultiBarLeftButton7, MultiBarLeftButton8,
			MultiBarLeftButton9, MultiBarLeftButton10, MultiBarLeftButton11, MultiBarLeftButton12
		},
		original_bar = MultiBarLeft,
		name = "LSMultiBarLeftBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar5 = {
		buttons = {
			MultiBarRightButton1, MultiBarRightButton2, MultiBarRightButton3, MultiBarRightButton4,
			MultiBarRightButton5, MultiBarRightButton6, MultiBarRightButton7, MultiBarRightButton8,
			MultiBarRightButton9, MultiBarRightButton10, MultiBarRightButton11, MultiBarRightButton12
		},
		original_bar = MultiBarRight,
		name = "LSMultiBarRightBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar6 = {
		buttons = {
			PetActionButton1, PetActionButton2, PetActionButton3, PetActionButton4, PetActionButton5,
			PetActionButton6, PetActionButton7, PetActionButton8, PetActionButton9, PetActionButton10
		},
		original_bar = PetActionBarFrame,
		name = "LSPetActionBar",
		condition = "[pet,nopetbattle,novehicleui,nooverridebar,nopossessbar] show; hide",
	},
	bar7 = {
		buttons = {
			StanceButton1, StanceButton2, StanceButton3, StanceButton4, StanceButton5,
			StanceButton6, StanceButton7, StanceButton8, StanceButton9, StanceButton10
		},
		original_bar = StanceBarFrame,
		name = "LSStanceBar",
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
	DEMONHUNTER = 1,
	PET1 = {"BOTTOM", 0, 110},
	PET2 = {"BOTTOM", 0, 138},
	STANCE1 = {"BOTTOM", 0, 138},
	STANCE2 = {"BOTTOM", 0, 110},
}

-- page swapping is taken from tukui, thx :D really usefull thingy
local PAGE_LAYOUT = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["PRIEST"] = "[bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:1] 7;",
	["MONK"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["DEFAULT"] = "[vehicleui] 12; [possessbar] 12; [shapeshift] 13; [overridebar] 14; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetPageLayout()
	local condition = PAGE_LAYOUT["DEFAULT"]
	local page = PAGE_LAYOUT[E.PLAYER_CLASS]

	if page then
		condition = condition.." "..page
	end

	condition = condition.." [form] 1; 1"

	return condition
end

local function LSActionBar_OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" or event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "FORCE_CUSTOM_UPDATE" then
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			self:SetFrameRef("ActionButton"..i, _G["ActionButton"..i])
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
	if self:GetName() == "LSPetActionBar" then
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["PET"..STANCE_PET_VISIBILITY[E.PLAYER_CLASS]]))
	else
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["STANCE"..STANCE_PET_VISIBILITY[E.PLAYER_CLASS]]))
	end
end

local function UnlockPetActionBarHook()
	PetActionBarFrame.locked = true
end

function B:PLAYER_REGEN_ENABLED()
	if UnitLevel("player") >= 10 and not PetActionBarFrame:IsShown() then
		PetActionBarFrame:Show()

		B:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end

function B:PLAYER_LEVEL_UP(level)
	if level >= 10 then
		if InCombatLockdown() then
			B:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			PetActionBarFrame:Show()
		end

		B:UnregisterEvent("PLAYER_LEVEL_UP")
	end
end

function B:HandleActionBars()
	if C.bars.restricted then
		BARS_CFG.bar2 = C.bars.bar2
		BARS_CFG.bar3 = C.bars.bar3
		BARS_CFG.bar4 = C.bars.bar4
		BARS_CFG.bar5 = C.bars.bar5
		BARS_CFG.bar6 = C.bars.bar6
		BARS_CFG.bar7 = C.bars.bar7
	else
		BARS_CFG = C.bars
	end

	for key, data in next, BAR_LAYOUT do
		local config = BARS_CFG[key]
		local index = match(key, "(%d+)")
		local bar = CreateFrame("Frame", data.name, UIParent, "SecureHandlerStateTemplate")

		if index == "6" then
			E:SetupBar(data.buttons, config.button_size, config.button_gap, bar, config.direction, E.SkinPetActionButton, data.original_bar)
		elseif index == "7" then
			E:SetupBar(data.buttons, config.button_size, config.button_gap, bar, config.direction, E.SkinStanceButton, data.original_bar)
		else
			E:SetupBar(data.buttons, config.button_size, config.button_gap, bar, config.direction, E.SkinActionButton, data.original_bar)
		end

		if data.condition then
			RegisterStateDriver(bar, "visibility", data.condition)
		end

		if index == "1" then
			bar:RegisterEvent("PLAYER_LOGIN")
			bar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			bar:SetScript("OnEvent", LSActionBar_OnEvent)

			if C.bars.restricted then
				B:SetupControlledBar(bar, "Main")
			end
		end

		Bars[key] = bar
	end

	for key, bar in next, Bars do
		if not bar.controlled then
			if BARS_CFG[key].point then
				bar:SetPoint(unpack(BARS_CFG[key].point))
			else
				SetStancePetActionBarPosition(bar)
			end

			E:CreateMover(bar)
		end
	end

	if UnitLevel("player") < 10 then
		PetActionBarFrame:Hide()

		B:RegisterEvent("PLAYER_LEVEL_UP")
	else
		PetActionBarFrame:Show()
	end

	PetActionBarFrame:SetScript("OnUpdate", nil)
	PetActionBarFrame.locked = true
	hooksecurefunc("UnlockPetActionBar", UnlockPetActionBarHook)

	for _, v in next, {
		MainMenuBar,
		ActionBarDownButton,
		ActionBarUpButton,
		MainMenuBarTexture0,
		MainMenuBarTexture1,
		MainMenuBarTexture2,
		MainMenuBarTexture3,
		MainMenuBarLeftEndCap,
		MainMenuBarRightEndCap,
		MainMenuBarPageNumber,
		MultiCastActionBarFrame,
		OverrideActionBar,
		PossessBarFrame,
		ReputationWatchBar,
		StanceBarLeft,
		StanceBarMiddle,
		StanceBarRight,
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
		SpellFlyoutHorizontalBackground,
		SpellFlyoutVerticalBackground,
		SpellFlyoutBackgroundEnd,
	} do
		E:ForceHide(v)
	end
end
