local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local s_format = _G.string.format

-- Blizz
local CalculateAction = _G.ActionButton_CalculateAction
local CreateFrame = _G.CreateFrame
local GetActionTexture = _G.GetActionTexture
local HasAction = _G.HasAction
local HasOverrideActionBar = _G.HasOverrideActionBar
local HasVehicleActionBar = _G.HasVehicleActionBar
local RegisterStateDriver = _G.RegisterStateDriver
local UnitLevel = _G.UnitLevel

-- Mine
local isInit = false
local bars = {}

local CFG = {
	bar1 = {
		visible = true,
		num = 12,
		size = 32,
		spacing = 4,
		x_growth = "RIGHT",
		y_growth = "DOWN",
		per_row = 12,
		visibility = "[petbattle] hide; show",
		point = {
			p = "BOTTOM",
			anchor = "UIParent",
			rP = "BOTTOM",
			x = 0,
			y = 16
		},
	},
}

local ACTION_BARS = {
	bar1 = {
		name = "LSActionBar1",
		buttons = {
			_G.ActionButton1, _G.ActionButton2, _G.ActionButton3, _G.ActionButton4,
			_G.ActionButton5, _G.ActionButton6, _G.ActionButton7, _G.ActionButton8,
			_G.ActionButton9, _G.ActionButton10, _G.ActionButton11, _G.ActionButton12,
		},
		skin_function = function(...) E:SkinActionButton(...) end
	},
	bar2 = {
		name = "LSActionBar2",
		buttons = {
			_G.MultiBarBottomLeftButton1, _G.MultiBarBottomLeftButton2, _G.MultiBarBottomLeftButton3, _G.MultiBarBottomLeftButton4,
			_G.MultiBarBottomLeftButton5, _G.MultiBarBottomLeftButton6, _G.MultiBarBottomLeftButton7, _G.MultiBarBottomLeftButton8,
			_G.MultiBarBottomLeftButton9, _G.MultiBarBottomLeftButton10, _G.MultiBarBottomLeftButton11, _G.MultiBarBottomLeftButton12,
		},
		page = 6,
		skin_function = function(...) E:SkinActionButton(...) end
	},
	bar3 = {
		buttons = {
			_G.MultiBarBottomRightButton1, _G.MultiBarBottomRightButton2, _G.MultiBarBottomRightButton3, _G.MultiBarBottomRightButton4,
			_G.MultiBarBottomRightButton5, _G.MultiBarBottomRightButton6, _G.MultiBarBottomRightButton7, _G.MultiBarBottomRightButton8,
			_G.MultiBarBottomRightButton9, _G.MultiBarBottomRightButton10, _G.MultiBarBottomRightButton11, _G.MultiBarBottomRightButton12,
		},
		name = "LSActionBar3",
		page = 5,
		skin_function = function(...) E:SkinActionButton(...) end
	},
	bar4 = {
		name = "LSActionBar4",
		buttons = {
			_G.MultiBarLeftButton1, _G.MultiBarLeftButton2, _G.MultiBarLeftButton3, _G.MultiBarLeftButton4,
			_G.MultiBarLeftButton5, _G.MultiBarLeftButton6, _G.MultiBarLeftButton7, _G.MultiBarLeftButton8,
			_G.MultiBarLeftButton9, _G.MultiBarLeftButton10, _G.MultiBarLeftButton11, _G.MultiBarLeftButton12,
		},
		page = 4,
		skin_function = function(...) E:SkinActionButton(...) end
	},
	bar5 = {
		name = "LSActionBar5",
		buttons = {
			_G.MultiBarRightButton1, _G.MultiBarRightButton2, _G.MultiBarRightButton3, _G.MultiBarRightButton4,
			_G.MultiBarRightButton5, _G.MultiBarRightButton6, _G.MultiBarRightButton7, _G.MultiBarRightButton8,
			_G.MultiBarRightButton9, _G.MultiBarRightButton10, _G.MultiBarRightButton11, _G.MultiBarRightButton12,
		},
		page = 3,
		skin_function = function(...) E:SkinActionButton(...) end
	},
	bar6 = {
		name = "LSPetBar",
		buttons = {
			_G.PetActionButton1, _G.PetActionButton2, _G.PetActionButton3, _G.PetActionButton4, _G.PetActionButton5,
			_G.PetActionButton6, _G.PetActionButton7, _G.PetActionButton8, _G.PetActionButton9, _G.PetActionButton10,
		},
		original_bar = "PetActionBarFrame",
		skin_function = function(...) E:SkinPetActionButton(...) end
	},
	bar7 = {
		name = "LSStanceBar",
		buttons = {
			_G.StanceButton1, _G.StanceButton2, _G.StanceButton3, _G.StanceButton4, _G.StanceButton5,
			_G.StanceButton6, _G.StanceButton7, _G.StanceButton8, _G.StanceButton9, _G.StanceButton10,
		},
		original_bar = "StanceBarFrame",
		skin_function = function(...) E:SkinStanceButton(...) end
	},
}

local TOP_POINT = {
	p = "BOTTOM",
	anchor = "UIParent",
	rP = "BOTTOM",
	x = 0,
	y = 152,
}

local BOTTOM_POINT = {
	p = "BOTTOM",
	anchor = "UIParent",
	rP = "BOTTOM",
	x = 0,
	y = 124,
}

local LAYOUT = {
	WARRIOR = {
		bar6 = TOP_POINT,
		bar7 = BOTTOM_POINT
	},
	PALADIN = {
		bar6 = TOP_POINT,
		bar7 = BOTTOM_POINT
	},
	HUNTER = {
		bar6 = BOTTOM_POINT,
		bar7 = TOP_POINT
	},
	ROGUE = {
		bar6 = BOTTOM_POINT,
		bar7 = TOP_POINT
	},
	PRIEST = {
		bar6 = TOP_POINT,
		bar7 = BOTTOM_POINT
	},
	DEATHKNIGHT = {
		bar6 = BOTTOM_POINT,
		bar7 = TOP_POINT
	},
	SHAMAN = {
		bar6 = BOTTOM_POINT,
		bar7 = TOP_POINT
	},
	MAGE = {
		bar6 = BOTTOM_POINT,
		bar7 = TOP_POINT
	},
	WARLOCK = {
		bar6 = BOTTOM_POINT,
		bar7 = TOP_POINT
	},
	MONK = {
		bar6 = TOP_POINT,
		bar7 = BOTTOM_POINT
	},
	DRUID = {
		bar6 = TOP_POINT,
		bar7 = BOTTOM_POINT
	},
	DEMONHUNTER = {
		bar6 = BOTTOM_POINT,
		bar7 = TOP_POINT
	},
}

local PAGES = {
	-- Unstealthed cat, stealthed cat, bear, owl; tree form [bonusbar:2] was removed
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	-- Stealth, shadow dance
	["ROGUE"] = "[bonusbar:1] 7;",
	["DEFAULT"] = "[vehicleui][possessbar] 12; [shapeshift] 13; [overridebar] 14; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBarPage()
	local condition = PAGES["DEFAULT"]
	local page = PAGES[E.PLAYER_CLASS]

	if page then
		condition = condition.." "..page
	end

	return condition.." [form] 1; 1"
end

local function GetBarPoint(barID)
	return LAYOUT[E.PLAYER_CLASS][barID]
end

local function UpdateOverrideBar()
	for i = 1, 6 do
		local button = _G["ActionButton"..i]
		local action = CalculateAction(button)

		if HasAction(action) then
			local texture = GetActionTexture(action)

			if texture then
				button.icon:SetTexture(texture)
				button.icon:Show()
			end
		end
	end
end

local function ResetOriginalBarPoints(bar)
	E:SetFrameState(bar, nil, function(self)
		self:SetParent(self._parent)
		self:SetAllPoints(self._parent)
	end)
end

function MODULE.CreateActionBars()
	if not isInit then
		local config = {
			bar1 = MODULE:IsRestricted() and CFG.bar1 or C.db.profile.bars.bar1,
			bar2 = C.db.profile.bars.bar2,
			bar3 = C.db.profile.bars.bar3,
			bar4 = C.db.profile.bars.bar4,
			bar5 = C.db.profile.bars.bar5,
			bar6 = C.db.profile.bars.bar6,
			bar7 = C.db.profile.bars.bar7,
		}

		-- constructor
		for barID, data in next, ACTION_BARS do
			local bar = CreateFrame("Frame", data.name, UIParent, "SecureHandlerStateTemplate")

			bar._buttons = {}

			if data.original_bar then
				local original_bar = _G[data.original_bar]

				original_bar.slideOut = E.NOA
				original_bar._parent = bar
				original_bar:SetParent(bar)
				original_bar:SetAllPoints(bar)
				original_bar:EnableMouse(false)

				original_bar.ignoreFramePositionManager = true
				UIPARENT_MANAGED_FRAME_POSITIONS[data.original_bar] = nil

				hooksecurefunc(original_bar, "SetPoint", ResetOriginalBarPoints)

				for i, button in next, data.buttons do
					button._parent = original_bar
					button:SetParent(original_bar)

					data.skin_function(button)

					bar._buttons[i] = button
				end
			else
				for i, button in next, data.buttons do
					button._parent = bar
					button:SetParent(bar)

					data.skin_function(button)

					if data.page then
						button:SetAttribute("actionpage", data.page)
					end

					bar._buttons[i] = button
				end
			end

			if barID == "bar1" then
				for i = 1, #bar._buttons do
					bar:SetFrameRef("ActionButton"..i, bar._buttons[i])
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

					for _, button in next, buttons do
						button:SetAttribute("actionpage", tonumber(newstate))

						if newstate == 12 then
							button:SetAttribute("showgrid", 1)

							if not button:GetAttribute("ls-hidden") then
								button:Show()
							end
						else
							button:SetAttribute("showgrid", 0)
						end
					end
				]])

				RegisterStateDriver(bar, "page", GetBarPage())
			end

			RegisterStateDriver(bar, "visibility", config[barID].visible and config[barID].visibility or "hide")

			MODULE:AddBar(barID, bar)

			-- hacks
			if barID == "bar1" then
				bar.Update = function(self)
					self._config = MODULE:IsRestricted() and CFG.bar1 or C.db.profile.bars.bar1

					E:UpdateBarLayout(self)
				end
			end
		end

		-- bar setup
		for barID, bar in next, bars do
			if barID == "bar1" and MODULE:IsRestricted() then
				MODULE:ActionBarController_AddWidget(bar, "ACTION_BAR")
			else
				local point = config[barID].point or GetBarPoint(barID)

				bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
				E:CreateMover(bar)
			end

			bar._config = config[barID]

			bar:Update()
		end

		E:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", function()
			if HasVehicleActionBar() then
				UpdateOverrideBar()
			end
		end)

		E:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", function()
			if HasOverrideActionBar() then
				UpdateOverrideBar()
			end
		end)

		-- Pet action bar hacks
		if UnitLevel("player") < 10 then
			PetActionBarFrame:Hide()

			local function PLAYER_LEVEL_UP(level)
				if level >= 10 then
					E:SetFrameState(PetActionBarFrame, nil, function(self) self:Show() end)
					E:UnregisterEvent("PLAYER_LEVEL_UP", PLAYER_LEVEL_UP)
				end
			end

			E:RegisterEvent("PLAYER_LEVEL_UP", PLAYER_LEVEL_UP)
		else
			PetActionBarFrame:Show()
		end

		PetActionBarFrame:SetScript("OnUpdate", nil)
		PetActionBarFrame.locked = true
		hooksecurefunc("UnlockPetActionBar", function()
			PetActionBarFrame.locked = true
		end)

		-- Let it handle stance bar and extra action button updates
		ActionBarController:UnregisterAllEvents()
		ActionBarController:RegisterEvent("PLAYER_ENTERING_WORLD")
		ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		ActionBarController:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
		ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
		ActionBarController:HookScript("OnEvent", function(self, event)
			if event == "PLAYER_ENTERING_WORLD" then
				self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			end
		end)

		-- Flyout
		P:HookSpellFlyout()

		-- Misc
		E:ForceHide(ActionBarDownButton)
		E:ForceHide(ActionBarUpButton)
		E:ForceHide(ArtifactWatchBar)
		E:ForceHide(HonorWatchBar)
		E:ForceHide(MainMenuBar)
		E:ForceHide(MainMenuBarLeftEndCap)
		E:ForceHide(MainMenuBarPageNumber)
		E:ForceHide(MainMenuBarRightEndCap)
		E:ForceHide(MainMenuBarTexture0)
		E:ForceHide(MainMenuBarTexture1)
		E:ForceHide(MainMenuBarTexture2)
		E:ForceHide(MainMenuBarTexture3)
		E:ForceHide(MainMenuExpBar)
		E:ForceHide(MultiBarBottomLeft)
		E:ForceHide(MultiBarBottomRight)
		E:ForceHide(MultiBarLeft)
		E:ForceHide(MultiBarRight)
		E:ForceHide(MultiCastActionBarFrame)
		E:ForceHide(OverrideActionBar)
		E:ForceHide(PossessBarFrame)
		E:ForceHide(ReputationWatchBar)
		E:ForceHide(SlidingActionBarTexture0)
		E:ForceHide(SlidingActionBarTexture1)
		E:ForceHide(SpellFlyoutBackgroundEnd)
		E:ForceHide(SpellFlyoutHorizontalBackground)
		E:ForceHide(SpellFlyoutVerticalBackground)
		E:ForceHide(StanceBarLeft)
		E:ForceHide(StanceBarMiddle)
		E:ForceHide(StanceBarRight)
		E:ForceHide(MainMenuBarArtFrame, true)

		isInit = true
	end
end

function MODULE.AddBar(_, barID, bar)
	bars[barID] = bar
	bars[barID].Update = function(self)
		if self._config.visibility then
			E:SetFrameState(self, "visibility", self._config.visible and self._config.visibility or "hide")
		end

		E:UpdateBarLayout(self)
	end
end

function MODULE.UpdateBar(_, barID)
	local bar = bars[barID]

	if not bar then
		return P.print(s_format("Bar with \'%s\' ID doesn't exist.", barID))
	end

	bar._config = C.db.profile.bars[barID]

	bar:Update()
end

function MODULE.UpdateBars()
	for id, bar in next, bars do
		bar._config = C.db.profile.bars[id]

		bar:Update()
	end
end

function MODULE.ToggleBar(_, barID, flag)
	local bar = bars[barID]

	if not bar then
		return P.print(s_format("Bar with \'%s\' ID doesn't exist.", barID))
	end

	return E:SetFrameState(bar, "visibility", flag and C.db.profile.bars[barID].visibility or "hide")
end
