local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local unpack = _G.unpack

-- Mine
local LibActionButton = LibStub("LibActionButton-1.0-ls")

local isInit = false

local CFG = {
	bar1 = {
		flyout_dir = "UP",
		num = 12,
		per_row = 12,
		width = 32,
		height = 0,
		spacing = 4,
		visibility = "[petbattle] hide; show",
		visible = true,
		x_growth = "RIGHT",
		y_growth = "DOWN",
		fade = {
			enabled = false,
			ooc = false,
			out_delay = 0.75,
			out_duration = 0.15,
			in_duration = 0.15,
			min_alpha = 0,
			max_alpha = 1,
		},
		point = {"BOTTOM", "UIParent", "BOTTOM", 0, 16},
	},
}

local ACTION_BARS = {
	["bar1"] = {
		name = "LSActionBar1",
		type = "ACTIONBUTTON",
		b_buttons = {
			ActionButton1, ActionButton2, ActionButton3, ActionButton4,
			ActionButton5, ActionButton6, ActionButton7, ActionButton8,
			ActionButton9, ActionButton10, ActionButton11, ActionButton12,
		},
	},
	["bar2"] = {
		name = "LSActionBar2",
		type = "MULTIACTIONBAR1BUTTON",
		b_buttons = {
			MultiBarBottomLeftButton1, MultiBarBottomLeftButton2, MultiBarBottomLeftButton3, MultiBarBottomLeftButton4,
			MultiBarBottomLeftButton5, MultiBarBottomLeftButton6, MultiBarBottomLeftButton7, MultiBarBottomLeftButton8,
			MultiBarBottomLeftButton9, MultiBarBottomLeftButton10, MultiBarBottomLeftButton11, MultiBarBottomLeftButton12,
		},
		page = 6,
	},
	["bar3"] = {
		name = "LSActionBar3",
		type = "MULTIACTIONBAR2BUTTON",
		b_buttons = {
			MultiBarBottomRightButton1, MultiBarBottomRightButton2, MultiBarBottomRightButton3, MultiBarBottomRightButton4,
			MultiBarBottomRightButton5, MultiBarBottomRightButton6, MultiBarBottomRightButton7, MultiBarBottomRightButton8,
			MultiBarBottomRightButton9, MultiBarBottomRightButton10, MultiBarBottomRightButton11, MultiBarBottomRightButton12,
		},
		page = 5,
	},
	["bar4"] = {
		name = "LSActionBar4",
		type = "MULTIACTIONBAR4BUTTON",
		b_buttons = {
			MultiBarLeftButton1, MultiBarLeftButton2, MultiBarLeftButton3, MultiBarLeftButton4,
			MultiBarLeftButton5, MultiBarLeftButton6, MultiBarLeftButton7, MultiBarLeftButton8,
			MultiBarLeftButton9, MultiBarLeftButton10, MultiBarLeftButton11, MultiBarLeftButton12,
		},
		page = 4,
	},
	["bar5"] = {
		name = "LSActionBar5",
		type = "MULTIACTIONBAR3BUTTON",
		b_buttons = {
			MultiBarRightButton1, MultiBarRightButton2, MultiBarRightButton3, MultiBarRightButton4,
			MultiBarRightButton5, MultiBarRightButton6, MultiBarRightButton7, MultiBarRightButton8,
			MultiBarRightButton9, MultiBarRightButton10, MultiBarRightButton11, MultiBarRightButton12,
		},
		page = 3,
	},
	["bar6"] = {
		name = "LSActionBar6",
		type = "MULTIACTIONBAR5BUTTON",
		b_buttons = {
			MultiBar5Button1, MultiBar5Button2, MultiBar5Button3, MultiBar5Button4,
			MultiBar5Button5, MultiBar5Button6, MultiBar5Button7, MultiBar5Button8,
			MultiBar5Button9, MultiBar5Button10, MultiBar5Button11, MultiBar5Button12,
		},
		page = 13,
	},
	["bar7"] = {
		name = "LSActionBar7",
		type = "MULTIACTIONBAR6BUTTON",
		b_buttons = {
			MultiBar6Button1, MultiBar6Button2, MultiBar6Button3, MultiBar6Button4,
			MultiBar6Button5, MultiBar6Button6, MultiBar6Button7, MultiBar6Button8,
			MultiBar6Button9, MultiBar6Button10, MultiBar6Button11, MultiBar6Button12,
		},
		page = 14,
	},
	["bar8"] = {
		name = "LSActionBar8",
		type = "MULTIACTIONBAR7BUTTON",
		b_buttons = {
			MultiBar7Button1, MultiBar7Button2, MultiBar7Button3, MultiBar7Button4,
			MultiBar7Button5, MultiBar7Button6, MultiBar7Button7, MultiBar7Button8,
			MultiBar7Button9, MultiBar7Button10, MultiBar7Button11, MultiBar7Button12,
		},
		page = 15,
	},
}

local PAGES = {
	-- Unstealthed cat, stealthed cat, bear, owl; tree form [bonusbar:2] was removed
	["DRUID"] = " [bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	-- Stealth, shadow dance
	["ROGUE"] = " [bonusbar:1] 7;",
	-- Soar
	["EVOKER"] = " [bonusbar:1] 7;",
	-- [bonusbar:5] 11 is dragon riding
	["DEFAULT"] = "[overridebar] 18; [shapeshift] 17; [vehicleui][possessbar] 16; [bonusbar:5,mounted] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function getBarPage()
	return PAGES["DEFAULT"] .. (PAGES[E.PLAYER_CLASS] or "") .. " [form] 1; 1"
end

local bar_proto = {
}

function bar_proto:Update()
	self:UpdateConfig()
	self:UpdateVisibility()
	self:UpdateButtonConfig()
	self:ForEach("UpdateCountFont")
	self:ForEach("UpdateHotKeyFont")
	self:ForEach("UpdateMacroFont")
	self:UpdateCooldownConfig()
	self:UpdateFading()
	self:UpdateLayout()
end

function bar_proto:UpdateButtonConfig()
	if not self.buttonConfig then
		self.buttonConfig = {
			tooltip = "enabled",
			colors = {
				normal = {},
				unusable = {},
				mana = {},
				range = {},
			},
			desaturation = {},
			hideElements = {
				equipped = false,
			},
		}
	end

	for k, v in next, C.db.global.colors.button do
		self.buttonConfig.colors[k][1], self.buttonConfig.colors[k][2], self.buttonConfig.colors[k][3] = v:GetRGB()
	end

	self.buttonConfig.clickOnDown = true
	self.buttonConfig.desaturation = E:CopyTable(self._config.desaturation, self.buttonConfig.desaturation)
	self.buttonConfig.flyoutDirection = self._config.flyout_dir
	self.buttonConfig.hideElements.hotkey = not self._config.hotkey.enabled
	self.buttonConfig.hideElements.macro = not self._config.macro.enabled
	self.buttonConfig.outOfManaColoring = self._config.mana_indicator
	self.buttonConfig.outOfRangeColoring = self._config.range_indicator
	self.buttonConfig.showGrid = self._config.grid

	for _, button in next, self._buttons do
		self.buttonConfig.keyBoundTarget = button._command

		button:UpdateConfig(self.buttonConfig)
		button:SetAttribute("buttonlock", true)
		button:SetAttribute("checkselfcast", true)
		button:SetAttribute("checkfocuscast", true)
		button:SetAttribute("*unit2", self._config.rightclick_selfcast and "player" or nil)
	end
end

local bar1_proto = {}

function bar1_proto:UpdateConfig()
	self._config = E:CopyTable(MODULE:IsRestricted() and CFG.bar1 or C.db.profile.bars.bar1, self._config)
	self._config.height = self._config.height ~= 0 and self._config.height or self._config.width
	self._config.cooldown = E:CopyTable(C.db.profile.bars.bar1.cooldown, self._config.cooldown)
	self._config.cooldown = E:CopyTable(C.db.profile.bars.cooldown, self._config.cooldown)
	self._config.desaturation = E:CopyTable(C.db.profile.bars.desaturation, self._config.desaturation)
	self._config.mana_indicator = C.db.profile.bars.mana_indicator
	self._config.range_indicator = C.db.profile.bars.range_indicator
	self._config.rightclick_selfcast = C.db.profile.bars.rightclick_selfcast

	if MODULE:IsRestricted() then
		self._config.count = E:CopyTable(C.db.profile.bars.bar1.count, self._config.count)
		self._config.grid = C.db.profile.bars.bar1.grid
		self._config.hotkey = E:CopyTable(C.db.profile.bars.bar1.hotkey, self._config.hotkey)
		self._config.macro = E:CopyTable(C.db.profile.bars.bar1.macro, self._config.macro)
	end
end

local button_proto = {}

function button_proto:UpdateMacroFont()
	self.Name:UpdateFont(self._parent._config.macro.size)
end

function button_proto:UpdateHotKeyFont()
	self.HotKey:UpdateFont(self._parent._config.hotkey.size)
end

function button_proto:UpdateCountFont()
	self.Count:UpdateFont(self._parent._config.count.size)
end

function MODULE:CreateActionBars()
	if not isInit then
		local config = {
			bar1 = MODULE:IsRestricted() and CFG.bar1 or C.db.profile.bars.bar1,
			bar2 = C.db.profile.bars.bar2,
			bar3 = C.db.profile.bars.bar3,
			bar4 = C.db.profile.bars.bar4,
			bar5 = C.db.profile.bars.bar5,
			bar6 = C.db.profile.bars.bar6,
			bar7 = C.db.profile.bars.bar7,
			bar8 = C.db.profile.bars.bar8,
		}

		for barID, data in next, ACTION_BARS do
			local bar = Mixin(self:Create(barID, data.name), bar_proto)

			if barID == "bar1" then
				Mixin(bar, bar1_proto)
			end

			for i = 1, #data.b_buttons do
				local button = Mixin(LibActionButton:CreateButton(i, "$parentButton" .. i, bar), button_proto)
				button:SetState(0, "action", i)
				button._parent = bar
				button._command = data.type .. i
				bar._buttons[i] = button

				-- 18 is the last page
				for k = 1, 18 do
					button:SetState(k, "action", (k - 1) * 12 + i)
				end

				E:SkinActionButton(button)

				-- for IconIntroTracker
				data.b_buttons[i]:SetAllPoints(button)
				data.b_buttons[i]:Hide()
				data.b_buttons[i]:SetAttribute("statehidden", true)
				data.b_buttons[i]:SetParent(E.HIDDEN_PARENT)
				data.b_buttons[i]:SetScript("OnEvent", nil)
				data.b_buttons[i]:SetScript("OnUpdate", nil)
				data.b_buttons[i]:UnregisterAllEvents()
			end

			bar:SetAttribute("_onstate-page", [[
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			]])

			RegisterStateDriver(bar, "page", barID == "bar1" and getBarPage() or data.page)

			if barID == "bar1" and MODULE:IsRestricted() then
				MODULE:AddControlledWidget("ACTION_BAR", bar)
			else
				bar:SetPoint(unpack(config[barID].point))
				E.Movers:Create(bar)
			end

			bar:Update()
		end

		hooksecurefunc(SpellFlyout, "Toggle", function(self, ID)
			if self:IsShown() then
				local _, _, numSlots = GetFlyoutInfo(ID)

				for i = 1, numSlots do
					E:SkinFlyoutButton(_G["SpellFlyoutButton" .. i])
				end
			end
		end)

		isInit = true
	end
end
