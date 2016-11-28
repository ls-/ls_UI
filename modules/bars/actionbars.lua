local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = _G
local pairs = _G.pairs
local hooksecurefunc = _G.hooksecurefunc
local unpack = _G.unpack

-- Mine
local isInit = false
local actionbars = {}

local CFG = {
	bar1 = {
		visible = true,
		point = {"BOTTOM", 0, 12},
		button_size = 28,
		button_gap = 4,
		init_anchor = "TOPLEFT",
		buttons_per_row = 12,
	},
}

local ACTION_BARS = {
	bar1 = {
		buttons = {
			_G.ActionButton1, _G.ActionButton2, _G.ActionButton3, _G.ActionButton4, _G.ActionButton5, _G.ActionButton6,
			_G.ActionButton7, _G.ActionButton8, _G.ActionButton9, _G.ActionButton10, _G.ActionButton11, _G.ActionButton12
		},
		name = "LSMainBar",
		visibility = "[petbattle] hide; show",
	},
	bar2 = {
		buttons = {
			_G.MultiBarBottomLeftButton1, _G.MultiBarBottomLeftButton2, _G.MultiBarBottomLeftButton3, _G.MultiBarBottomLeftButton4,
			_G.MultiBarBottomLeftButton5, _G.MultiBarBottomLeftButton6, _G.MultiBarBottomLeftButton7, _G.MultiBarBottomLeftButton8,
			_G.MultiBarBottomLeftButton9, _G.MultiBarBottomLeftButton10, _G.MultiBarBottomLeftButton11, _G.MultiBarBottomLeftButton12
		},
		name = "LSMultiBarBottomLeftBar",
		page = 6,
		visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
	},
	bar3 = {
		buttons = {
			_G.MultiBarBottomRightButton1, _G.MultiBarBottomRightButton2, _G.MultiBarBottomRightButton3, _G.MultiBarBottomRightButton4,
			_G.MultiBarBottomRightButton5, _G.MultiBarBottomRightButton6, _G.MultiBarBottomRightButton7, _G.MultiBarBottomRightButton8,
			_G.MultiBarBottomRightButton9, _G.MultiBarBottomRightButton10, _G.MultiBarBottomRightButton11, _G.MultiBarBottomRightButton12
		},
		name = "LSMultiBarBottomRightBar",
		page = 5,
		visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
	},
	bar4 = {
		buttons = {
			_G.MultiBarLeftButton1, _G.MultiBarLeftButton2, _G.MultiBarLeftButton3, _G.MultiBarLeftButton4,
			_G.MultiBarLeftButton5, _G.MultiBarLeftButton6, _G.MultiBarLeftButton7, _G.MultiBarLeftButton8,
			_G.MultiBarLeftButton9, _G.MultiBarLeftButton10, _G.MultiBarLeftButton11, _G.MultiBarLeftButton12
		},
		name = "LSMultiBarLeftBar",
		page = 4,
		visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
	},
	bar5 = {
		buttons = {
			_G.MultiBarRightButton1, _G.MultiBarRightButton2, _G.MultiBarRightButton3, _G.MultiBarRightButton4,
			_G.MultiBarRightButton5, _G.MultiBarRightButton6, _G.MultiBarRightButton7, _G.MultiBarRightButton8,
			_G.MultiBarRightButton9, _G.MultiBarRightButton10, _G.MultiBarRightButton11, _G.MultiBarRightButton12
		},
		name = "LSMultiBarRightBar",
		page = 3,
		visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
	},
	bar6 = {
		buttons = {
			_G.PetActionButton1, _G.PetActionButton2, _G.PetActionButton3, _G.PetActionButton4, _G.PetActionButton5,
			_G.PetActionButton6, _G.PetActionButton7, _G.PetActionButton8, _G.PetActionButton9, _G.PetActionButton10
		},
		original_bar = _G.PetActionBarFrame,
		name = "LSPetBar",
		visibility = "[pet,nopetbattle,novehicleui,nooverridebar,nopossessbar] show; hide",
		skin_function = "SkinPetActionButton"
	},
	bar7 = {
		buttons = {
			_G.StanceButton1, _G.StanceButton2, _G.StanceButton3, _G.StanceButton4, _G.StanceButton5,
			_G.StanceButton6, _G.StanceButton7, _G.StanceButton8, _G.StanceButton9, _G.StanceButton10
		},
		original_bar = _G.StanceBarFrame,
		name = "LSStanceBar",
		visibility = "[vehicleui][petbattle][overridebar][possessbar] hide; show",
		skin_function = "SkinStanceButton"
	},
}

local TOP_POINT = {"BOTTOM", "UIParent", "BOTTOM", 0, 138}
local BOTTOM_POINT = {"BOTTOM", "UIParent", "BOTTOM", 0, 110}

local LAYOUT = {
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

local PAGE = {
	-- Unstealthed cat, stealthed cat, bear, owl; tree form [bonusbar:2] was removed
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	-- Stealth, shadow dance
	["ROGUE"] = "[bonusbar:1] 7;",
	["DEFAULT"] = "[vehicleui][possessbar] 12; [shapeshift] 13; [overridebar] 14; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetPage()
	local condition = PAGE["DEFAULT"]
	local page = PAGE[E.PLAYER_CLASS]

	if page then
		condition = condition.." "..page
	end

	condition = condition.." [form] 1; 1"

	return condition
end

local function SetStancePetActionBarPosition(self)
	if self:GetName() == "LSPetBar" then
		self:SetPoint(unpack(LAYOUT[E.PLAYER_CLASS].pet))
	else
		self:SetPoint(unpack(LAYOUT[E.PLAYER_CLASS].stance))
	end
end

local function UPDATE_VEHICLE_ACTIONBAR()
	if _G.HasVehicleActionBar() then
		for i = 1, 6 do
			local button = _G["ActionButton"..i]
			local action = _G.ActionButton_CalculateAction(button)

			if _G.HasAction(action) then
				local texture = _G.GetActionTexture(action)

				if texture then
					button.icon:SetTexture(texture)
					button.icon:Show()
				end
			end
		end
	end
end

local function UPDATE_OVERRIDE_ACTIONBAR()
	if _G.HasOverrideActionBar() then
		for i = 1, 6 do
			local button = _G["ActionButton"..i]
			local action = _G.ActionButton_CalculateAction(button)

			if _G.HasAction(action) then
				local texture = _G.GetActionTexture(action)

				if texture then
					button.icon:SetTexture(texture)
					button.icon:Show()
				end
			end
		end
	end
end

-----------------
-- INITIALISER --
-----------------

function BARS:ActionBars_IsInit()
	return isInit
end

function BARS:ActionBars_Init()
	if not isInit then
		if C.bars.restricted then
			CFG.bar2 = C.bars.bar2
			CFG.bar3 = C.bars.bar3
			CFG.bar4 = C.bars.bar4
			CFG.bar5 = C.bars.bar5
			CFG.bar6 = C.bars.bar6
			CFG.bar7 = C.bars.bar7
		else
			CFG = C.bars
		end

		-- Bar setup
		for key, data in pairs(ACTION_BARS) do
			local cfg = CFG[key]
			local bar = _G.CreateFrame("Frame", data.name, _G.UIParent, "SecureHandlerStateTemplate")

			if data.original_bar then
				data.original_bar.slideOut = E.NOA
				data.original_bar:SetParent(bar)
				data.original_bar:SetAllPoints()
				data.original_bar:EnableMouse(false)
				_G.UIPARENT_MANAGED_FRAME_POSITIONS[data.original_bar:GetName()] = nil

				for _, button in pairs(data.buttons) do
					E[data.skin_function or "SkinActionButton"](E, button)
				end
			else
				for _, button in pairs(data.buttons) do
					button:SetParent(bar)
					E[data.skin_function or "SkinActionButton"](E, button)

					if data.page then
						button:SetAttribute("actionpage", data.page)
					end
				end
			end

			bar.buttons = data.buttons

			E:UpdateBarLayout(bar, bar.buttons, cfg.button_size, cfg.button_gap, cfg.init_anchor, cfg.buttons_per_row)

			if data.name == "LSMainBar" then
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

						if newstate == 12 then
							button:SetAttribute("showgrid", 1)
							button:CallMethod("SetBorderColor", 244 / 255, 202 / 255, 22 / 255) -- M.COLORS.YELLOW

							if not button:GetAttribute("ls-hidden") then
								button:Show()
							end
						else
							button:SetAttribute("showgrid", 0)
						end
					end
				]])

				_G.RegisterStateDriver(bar, "page", GetPage())
			end

			if data.visibility then
				E:SaveFrameState(bar, "visibility", data.visibility)

				_G.RegisterStateDriver(bar, "visibility", cfg.visible and data.visibility or "hide")
			end

			actionbars[bar] = key
		end

		for bar, key in pairs(actionbars) do
			if not (key == "bar1" and C.bars.restricted) then
				if CFG[key].point then
					bar:SetPoint(unpack(CFG[key].point))
				else
					SetStancePetActionBarPosition(bar)
				end

				E:CreateMover(bar)
			end
		end

		E:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", UPDATE_VEHICLE_ACTIONBAR)
		E:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", UPDATE_OVERRIDE_ACTIONBAR)

		-- Pet action bar
		if _G.UnitLevel("player") < 10 then
			_G.PetActionBarFrame:Hide()

			local function PLAYER_LEVEL_UP(level)
				if level >= 10 then
					E:SetFrameState(_G.PetActionBarFrame, "Show")
					E:UnregisterEvent("PLAYER_LEVEL_UP", PLAYER_LEVEL_UP)
				end
			end

			E:RegisterEvent("PLAYER_LEVEL_UP", PLAYER_LEVEL_UP)
		else
			_G.PetActionBarFrame:Show()
		end

		_G.PetActionBarFrame:SetScript("OnUpdate", nil)
		_G.PetActionBarFrame.locked = true
		hooksecurefunc("UnlockPetActionBar", function()
			_G.PetActionBarFrame.locked = true
		end)

		-- Blizz bar controller
		-- XXX: Bye Fe... ActionBarController
		_G.ActionBarController:UnregisterAllEvents()

		-- XXX: But let it handle stance bar updates
		_G.ActionBarController:RegisterEvent("PLAYER_ENTERING_WORLD")
		_G.ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		_G.ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		_G.ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")

		_G.ActionBarController:HookScript("OnEvent", function(self, event)
			if event == "PLAYER_ENTERING_WORLD" then
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			end
		end)

		-- XXX: ... and extra action bar
		_G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

		-- Flyout
		hooksecurefunc(_G.SpellFlyout, "Toggle", function(self, ID)
			if not self:IsShown() then return end

			local _, _, numSlots = _G.GetFlyoutInfo(ID)

			for i = 1, numSlots do
				E:SkinActionButton(_G["SpellFlyoutButton"..i])
			end
		end)

		-- Misc
		E:ForceHide(_G.ActionBarDownButton)
		E:ForceHide(_G.ActionBarUpButton)
		E:ForceHide(_G.ArtifactWatchBar)
		E:ForceHide(_G.HonorWatchBar)
		E:ForceHide(_G.MainMenuBar)
		E:ForceHide(_G.MainMenuBarLeftEndCap)
		E:ForceHide(_G.MainMenuBarPageNumber)
		E:ForceHide(_G.MainMenuBarRightEndCap)
		E:ForceHide(_G.MainMenuBarTexture0)
		E:ForceHide(_G.MainMenuBarTexture1)
		E:ForceHide(_G.MainMenuBarTexture2)
		E:ForceHide(_G.MainMenuBarTexture3)
		E:ForceHide(_G.MainMenuExpBar)
		E:ForceHide(_G.MultiBarBottomLeft)
		E:ForceHide(_G.MultiBarBottomRight)
		E:ForceHide(_G.MultiBarLeft)
		E:ForceHide(_G.MultiBarRight)
		E:ForceHide(_G.MultiCastActionBarFrame)
		E:ForceHide(_G.OverrideActionBar)
		E:ForceHide(_G.PossessBarFrame)
		E:ForceHide(_G.ReputationWatchBar)
		E:ForceHide(_G.SlidingActionBarTexture0)
		E:ForceHide(_G.SlidingActionBarTexture1)
		E:ForceHide(_G.SpellFlyoutBackgroundEnd)
		E:ForceHide(_G.SpellFlyoutHorizontalBackground)
		E:ForceHide(_G.SpellFlyoutVerticalBackground)
		E:ForceHide(_G.StanceBarLeft)
		E:ForceHide(_G.StanceBarMiddle)
		E:ForceHide(_G.StanceBarRight)

		_G.MainMenuBarArtFrame:SetParent(E.HIDDEN_PARENT)

		-- Finalise
		isInit = true
	end
end
