local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Mine
local LibActionButton = LibStub("LibActionButton-1.0-ls")
local isInit = false

local CFG = {
	bar1 = {
		flyout_dir = "UP",
		grid = true,
		hotkey = true,
		macro = true,
		num = 12,
		per_row = 12,
		size = 32,
		spacing = 4,
		visibility = "[petbattle] hide; show",
		visible = true,
		x_growth = "RIGHT",
		y_growth = "DOWN",
		fade = {
			enabled = false,
		},
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
		type = "ACTIONBUTTON",
		b_buttons = {
			ActionButton1, ActionButton2, ActionButton3, ActionButton4,
			ActionButton5, ActionButton6, ActionButton7, ActionButton8,
			ActionButton9, ActionButton10, ActionButton11, ActionButton12,
		},
		num_buttons = 12,
	},
	bar2 = {
		name = "LSActionBar2",
		type = "MULTIACTIONBAR1BUTTON",
		b_buttons = {
			MultiBarBottomLeftButton1, MultiBarBottomLeftButton2, MultiBarBottomLeftButton3, MultiBarBottomLeftButton4,
			MultiBarBottomLeftButton5, MultiBarBottomLeftButton6, MultiBarBottomLeftButton7, MultiBarBottomLeftButton8,
			MultiBarBottomLeftButton9, MultiBarBottomLeftButton10, MultiBarBottomLeftButton11, MultiBarBottomLeftButton12,
		},
		num_buttons = 12,
		page = 6,
	},
	bar3 = {
		name = "LSActionBar3",
		type = "MULTIACTIONBAR2BUTTON",
		b_buttons = {
			MultiBarBottomRightButton1, MultiBarBottomRightButton2, MultiBarBottomRightButton3, MultiBarBottomRightButton4,
			MultiBarBottomRightButton5, MultiBarBottomRightButton6, MultiBarBottomRightButton7, MultiBarBottomRightButton8,
			MultiBarBottomRightButton9, MultiBarBottomRightButton10, MultiBarBottomRightButton11, MultiBarBottomRightButton12,
		},
		num_buttons = 12,
		page = 5,
	},
	bar4 = {
		name = "LSActionBar4",
		type = "MULTIACTIONBAR4BUTTON",
		b_buttons = {
			MultiBarLeftButton1, MultiBarLeftButton2, MultiBarLeftButton3, MultiBarLeftButton4,
			MultiBarLeftButton5, MultiBarLeftButton6, MultiBarLeftButton7, MultiBarLeftButton8,
			MultiBarLeftButton9, MultiBarLeftButton10, MultiBarLeftButton11, MultiBarLeftButton12,
		},
		num_buttons = 12,
		page = 4,
	},
	bar5 = {
		name = "LSActionBar5",
		type = "MULTIACTIONBAR3BUTTON",
		b_buttons = {
			MultiBarRightButton1, MultiBarRightButton2, MultiBarRightButton3, MultiBarRightButton4,
			MultiBarRightButton5, MultiBarRightButton6, MultiBarRightButton7, MultiBarRightButton8,
			MultiBarRightButton9, MultiBarRightButton10, MultiBarRightButton11, MultiBarRightButton12,
		},
		num_buttons = 12,
		page = 3,
	},
}

local PAGES = {
	-- Unstealthed cat, stealthed cat, bear, owl; tree form [bonusbar:2] was removed
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	-- Stealth, shadow dance
	["ROGUE"] = "[bonusbar:1] 7;",
	["DEFAULT"] = "[vehicleui][possessbar] 12; [shapeshift] 13; [overridebar] 14; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function getBarPage()
	local condition = PAGES["DEFAULT"]
	local page = PAGES[E.PLAYER_CLASS]

	if page then
		condition = condition.." "..page
	end

	return condition.." [form] 1; 1"
end

local function bar_Update(self)
	self:UpdateConfig()
	self:UpdateFading()
	self:UpdateVisibility()
	self:UpdateButtonConfig()
	self:UpdateButtons("UpdateFontObjects")
	E:UpdateBarLayout(self)
end

local function bar_UpdateButtonConfig(self)
	if not self.buttonConfig then
		self.buttonConfig = {
			tooltip = "enabled",
			colors = {},
			hideElements = {
				equipped = false,
			},
		}
	end

	self.buttonConfig.clickOnDown = C.db.profile.bars.click_on_down
	self.buttonConfig.desaturateOnCooldown = C.db.profile.bars.desaturate_on_cd
	self.buttonConfig.flyoutDirection = self._config.flyout_dir
	self.buttonConfig.outOfManaColoring = C.db.profile.bars.mana_indicator
	self.buttonConfig.outOfRangeColoring = C.db.profile.bars.range_indicator
	self.buttonConfig.showGrid = self._config.grid

	self.buttonConfig.colors.mana = {M.COLORS.BUTTON_ICON.OOM:GetRGB()}
	self.buttonConfig.colors.normal = {M.COLORS.BUTTON_ICON.N:GetRGB()}
	self.buttonConfig.colors.range = {M.COLORS.BUTTON_ICON.OOR:GetRGB()}

	self.buttonConfig.hideElements.hotkey = not self._config.hotkey
	self.buttonConfig.hideElements.macro = not self._config.macro

	for _, button in next, self._buttons do
		self.buttonConfig.keyBoundTarget = button._command

		button:UpdateConfig(self.buttonConfig)
		button:SetAttribute("buttonlock", C.db.profile.bars.lock)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)
		button:SetAttribute("*unit2", C.db.profile.bars.rightclick_selfcast and "player" or nil)
	end
end

local function button_UpdateFontObjects(self)
	local config = self._parent._config.font
	self.Count:SetFontObject("LSFont"..config.size..(config.flag ~= "" and "_"..config.flag or ""))
	self.HotKey:SetFontObject("LSFont"..config.size..(config.flag ~= "" and "_"..config.flag or ""))
	self.Name:SetFontObject("LSFont"..config.size..(config.flag ~= "" and "_"..config.flag or ""))
end

local function button_UpdateMacroText(self, state)
	if state ~= nil then
		self._parent._config.macro = state
	end

	self._parent:UpdateButtonConfig()
end

local function button_UpdateGrid(self, state)
	if state ~= nil then
		self._parent._config.grid = state
	end

	self._parent:UpdateButtonConfig()
end

local function button_UpdateFlyoutDirection(self, state)
	if state ~= nil then
		self._parent._config.flyout_dir = state
	end

	self._parent:UpdateButtonConfig()
end

local function button_UpdateHotKey(self, state)
	if state ~= nil then
		self._parent._config.hotkey = state
	end

	self._parent:UpdateButtonConfig()
end

function MODULE.CreateActionBars()
	if not isInit then
		local config = {
			bar1 = MODULE:IsRestricted() and CFG.bar1 or C.db.profile.bars.bar1,
			bar2 = C.db.profile.bars.bar2,
			bar3 = C.db.profile.bars.bar3,
			bar4 = C.db.profile.bars.bar4,
			bar5 = C.db.profile.bars.bar5,
		}

		for barID, data in next, ACTION_BARS do
			local bar = CreateFrame("Frame", data.name, UIParent, "SecureHandlerStateTemplate")
			bar._id = barID
			bar._buttons = {}

			MODULE:AddBar(bar._id, bar)

			bar.Update = bar_Update
			bar.UpdateButtonConfig = bar_UpdateButtonConfig

			if barID == "bar1" then
				bar.UpdateConfig = function(self)
					self._config = MODULE:IsRestricted() and CFG.bar1 or C.db.profile.bars.bar1

					if MODULE:IsRestricted() then
						self._config.font = C.db.profile.bars.bar1.font
						self._config.grid = C.db.profile.bars.bar1.grid
						self._config.hotkey = C.db.profile.bars.bar1.hotkey
						self._config.macro = C.db.profile.bars.bar1.macro
					end
				end
			end

			for i = 1, data.num_buttons do
				local button = LibActionButton:CreateButton(i, "$parentButton"..i, bar)
				button:SetState(0, "action", i)
				button._parent = bar
				button._command = data.type..i

				button.UpdateFlyoutDirection = button_UpdateFlyoutDirection
				button.UpdateFontObjects = button_UpdateFontObjects
				button.UpdateGrid = button_UpdateGrid
				button.UpdateHotKey = button_UpdateHotKey
				button.UpdateMacroText = button_UpdateMacroText

				for k = 1, 14 do
					button:SetState(k, "action", (k - 1) * 12 + i)
				end

				-- for IconIntroTracker
				data.b_buttons[i]:SetAllPoints(button)
				data.b_buttons[i]:SetAttribute("statehidden", true)
				data.b_buttons[i]:SetParent(E.HIDDEN_PARENT)
				data.b_buttons[i]:SetScript("OnEvent", nil)
				data.b_buttons[i]:SetScript("OnUpdate", nil)
				data.b_buttons[i]:UnregisterAllEvents()

				E:SkinActionButton(button)

				bar._buttons[i] = button
			end

			bar:SetAttribute("_onstate-page", [[
				if HasTempShapeshiftActionBar() then
					newstate = GetTempShapeshiftBarIndex() or newstate
				end

				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			]])

			RegisterStateDriver(bar, "page", barID == "bar1" and getBarPage() or data.page)
		end

		for barID, bar in next, MODULE:GetBars() do
			if barID == "bar1" and MODULE:IsRestricted() then
				MODULE:ActionBarController_AddWidget(bar, "ACTION_BAR")
			else
				local point = config[barID].point
				bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
				E:CreateMover(bar)
			end

			bar:Update()
		end

		hooksecurefunc(SpellFlyout, "Toggle", function(self, ID)
			if self:IsShown() then
				local _, _, numSlots = GetFlyoutInfo(ID)

				for i = 1, numSlots do
					E:SkinFlyoutButton(_G["SpellFlyoutButton"..i])
				end
			end
		end)

		isInit = true
	end
end
