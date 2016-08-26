local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

-- Lua
local _G = _G
local unpack, tonumber, pairs = unpack, tonumber, pairs

-- Mine
local bars = {}
local queue = {}

local BARS_CFG = {
	bar1 = {
		enabled = true,
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
		name = "LSMainMenuBar",
		condition = "[petbattle] hide; show",
	},
	bar2 = {
		buttons = {
			MultiBarBottomLeftButton1, MultiBarBottomLeftButton2, MultiBarBottomLeftButton3, MultiBarBottomLeftButton4,
			MultiBarBottomLeftButton5, MultiBarBottomLeftButton6, MultiBarBottomLeftButton7, MultiBarBottomLeftButton8,
			MultiBarBottomLeftButton9, MultiBarBottomLeftButton10, MultiBarBottomLeftButton11, MultiBarBottomLeftButton12
		},
		name = "LSMultiBarBottomLeftBar",
		page = 6,
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar3 = {
		buttons = {
			MultiBarBottomRightButton1, MultiBarBottomRightButton2, MultiBarBottomRightButton3, MultiBarBottomRightButton4,
			MultiBarBottomRightButton5, MultiBarBottomRightButton6, MultiBarBottomRightButton7, MultiBarBottomRightButton8,
			MultiBarBottomRightButton9, MultiBarBottomRightButton10, MultiBarBottomRightButton11, MultiBarBottomRightButton12
		},
		name = "LSMultiBarBottomRightBar",
		page = 5,
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar4 = {
		buttons = {
			MultiBarLeftButton1, MultiBarLeftButton2, MultiBarLeftButton3, MultiBarLeftButton4,
			MultiBarLeftButton5, MultiBarLeftButton6, MultiBarLeftButton7, MultiBarLeftButton8,
			MultiBarLeftButton9, MultiBarLeftButton10, MultiBarLeftButton11, MultiBarLeftButton12
		},
		name = "LSMultiBarLeftBar",
		page = 4,
		condition = "[vehicleui][petbattle][overridebar] hide; show",
	},
	bar5 = {
		buttons = {
			MultiBarRightButton1, MultiBarRightButton2, MultiBarRightButton3, MultiBarRightButton4,
			MultiBarRightButton5, MultiBarRightButton6, MultiBarRightButton7, MultiBarRightButton8,
			MultiBarRightButton9, MultiBarRightButton10, MultiBarRightButton11, MultiBarRightButton12
		},
		name = "LSMultiBarRightBar",
		page = 3,
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
		skin_function = "SkinPetActionButton"
	},
	bar7 = {
		buttons = {
			StanceButton1, StanceButton2, StanceButton3, StanceButton4, StanceButton5,
			StanceButton6, StanceButton7, StanceButton8, StanceButton9, StanceButton10
		},
		original_bar = StanceBarFrame,
		name = "LSStanceBar",
		condition = "[vehicleui][petbattle][overridebar] hide; show",
		skin_function = "SkinStanceButton"
	},
}

local TOP_POINT = {"BOTTOM", 0, 138}
local BOTTOM_POINT = {"BOTTOM", 0, 110}

local LAYOUT_ID = {
	WARRIOR = {pet = TOP_POINT, stance = BOTTOM_POINT},
	PALADIN = {pet = TOP_POINT, stance = BOTTOM_POINT},
	HUNTER = {pet = BOTTOM_POINT, stance = TOP_POINT},
	ROGUE = {pet = BOTTOM_POINT, stance = TOP_POINT},
	PRIEST = {pet = TOP_POINT, stance = BOTTOM_POINT},
	DEATHKNIGHT = {pet = BOTTOM_POINT, stance = TOP_POINT},
	SHAMAN = {pet = BOTTOM_POINT, stance = TOP_POINT},
	MAGE = {pet = BOTTOM_POINT, stance = TOP_POINT},
	WARLOCK = {pet = BOTTOM_POINT, stance = TOP_POINT},
	MONK = {pet = TOP_POINT, stance = BOTTOM_POINT},
	DRUID = {pet = TOP_POINT, stance = BOTTOM_POINT},
	DEMONHUNTER = {pet = BOTTOM_POINT, stance = TOP_POINT},
}

local PAGE_LAYOUT = {
	-- XXX: unstealthed cat, stealthed cat, bear, owl; tree form [bonusbar:2] was removed
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	-- XXX: stealth, shadow dance
	["ROGUE"] = "[bonusbar:1] 7;",
	["DEFAULT"] = "[vehicleui][possessbar] 12; [shapeshift] 13; [overridebar] 14; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
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

local function SetStancePetActionBarPosition(self)
	if self:GetName() == "LSPetActionBar" then
		self:SetPoint(unpack(LAYOUT_ID[E.PLAYER_CLASS].pet))
	else
		self:SetPoint(unpack(LAYOUT_ID[E.PLAYER_CLASS].stance))
	end
end

local function GetBarCondition(name)
	for _, data in pairs(BAR_LAYOUT) do
		if name == data.name then
			return data.condition
		end
	end

	return nil
end

local function UpdateBarState(name, state)
	local bar = _G[name]
	local condition = GetBarCondition(name)

	if condition then
		if state == "Show" then
			_G.RegisterStateDriver(bar, "visibility", condition)
		elseif state == "Hide" then
			_G.RegisterStateDriver(bar, "visibility", "hide")
		end
	else
		bar[state](bar)
	end
end

function B:ToggleBar(name, state)
	if _G[name] then
		if _G.InCombatLockdown() then
			queue[name] = state

			return false, name, state == "Show" and true or false
		else
			UpdateBarState(name, state)

			return true, name, state == "Show" and true or false
		end
	end
end

local function ManageQueue()
	for name, state in pairs(queue) do
		UpdateBarState(name, state)
	end
end

function B:PLAYER_REGEN_ENABLED()
	ManageQueue()
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

	for key, data in pairs(BAR_LAYOUT) do
		local config = BARS_CFG[key]
		local bar = _G.CreateFrame("Frame", data.name, _G.UIParent, "SecureHandlerStateTemplate")

		E:SetupBar(bar, data.buttons, config.button_size, config.button_gap, config.direction, E[data.skin_function or "SkinActionButton"])

		if data.condition then
			if config.enabled then
				_G.RegisterStateDriver(bar, "visibility", data.condition)
			else
				_G.RegisterStateDriver(bar, "visibility", "hide")
			end
		end

		if data.name == "LSMainMenuBar" then
			for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
				bar:SetFrameRef("ActionButton"..i, _G["ActionButton"..i])
			end

			bar:Execute([[
				buttons = table.new()

				for i = 1, 12 do
					table.insert(buttons, self:GetFrameRef("ActionButton"..i))
				end
			]])

			bar:SetAttribute("_onstate-page", [[
				if HasTempShapeshiftActionBar() then
					newstate = GetTempShapeshiftBarIndex() or newstate
				end

				for _, button in pairs(buttons) do
					button:SetAttribute("actionpage", tonumber(newstate))
				end
			]])

			_G.RegisterStateDriver(bar, "page", GetPageLayout())

			if C.bars.restricted then
				B:SetupControlledBar(bar, "Main")
			end
		end

		if data.original_bar then
			data.original_bar.slideOut = E.NOA
			data.original_bar:SetParent(bar)
			data.original_bar:SetAllPoints()
			data.original_bar:EnableMouse(false)
			_G.UIPARENT_MANAGED_FRAME_POSITIONS[data.original_bar:GetName()] = nil
		else
			for _, button in pairs(data.buttons) do
				button:SetParent(bar)

				if data.page then
					button:SetAttribute("actionpage", data.page)
				end
			end
		end

		bars[key] = bar
	end

	for key, bar in pairs(bars) do
		if not bar.controlled then
			if BARS_CFG[key].point then
				bar:SetPoint(unpack(BARS_CFG[key].point))
			else
				SetStancePetActionBarPosition(bar)
			end

			E:CreateMover(bar)
		end
	end

	B:RegisterEvent("PLAYER_REGEN_ENABLED")

	--------------------
	-- PET ACTION BAR --
	--------------------

	if _G.UnitLevel("player") < 10 then
		_G.PetActionBarFrame:Hide()

		function B:PLAYER_LEVEL_UP(level)
			if level >= 10 then
				B:ToggleBar("PetActionBarFrame", "Show")

				B:UnregisterEvent("PLAYER_LEVEL_UP")
			end
		end

		B:RegisterEvent("PLAYER_LEVEL_UP")
	else
		_G.PetActionBarFrame:Show()
	end

	_G.PetActionBarFrame:SetScript("OnUpdate", nil)
	_G.PetActionBarFrame.locked = true
	_G.hooksecurefunc("UnlockPetActionBar", function()
		_G.PetActionBarFrame.locked = true
	end)

	--------------------------
	-- BLIZZ BAR CONTROLLER --
	--------------------------

	-- XXX: Bye Fe... ActionBarController
	_G.ActionBarController:UnregisterAllEvents()

	-- XXX: But let it handle stance bar updates
	_G.ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	_G.ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	_G.ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
	_G.StanceBar_Update()

	-- XXX: ... and extra action bar
	_G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	----------
	-- MISC --
	----------

	for _, v in pairs({
		_G.ActionBarDownButton,
		_G.ActionBarUpButton,
		_G.MainMenuBar,
		_G.MainMenuBarLeftEndCap,
		_G.MainMenuBarPageNumber,
		_G.MainMenuBarRightEndCap,
		_G.MainMenuBarTexture0,
		_G.MainMenuBarTexture1,
		_G.MainMenuBarTexture2,
		_G.MainMenuBarTexture3,
		_G.MultiBarBottomLeft,
		_G.MultiBarBottomRight,
		_G.MultiBarLeft,
		_G.MultiBarRight,
		_G.MultiCastActionBarFrame,
		_G.OverrideActionBar,
		_G.PossessBarFrame,
		_G.ReputationWatchBar,
		_G.SlidingActionBarTexture0,
		_G.SlidingActionBarTexture1,
		_G.SpellFlyoutBackgroundEnd,
		_G.SpellFlyoutHorizontalBackground,
		_G.SpellFlyoutVerticalBackground,
		_G.StanceBarLeft,
		_G.StanceBarMiddle,
		_G.StanceBarRight,
	})do
		E:ForceHide(v)
	end

	_G.MainMenuBarArtFrame:SetParent(E.HIDDEN_PARENT)
end
