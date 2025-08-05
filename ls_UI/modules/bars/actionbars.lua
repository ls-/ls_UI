local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local unpack = _G.unpack

-- Mine
local LAB = LibStub("LibActionButton-1.0-ls")
local LSM = LibStub("LibSharedMedia-3.0")

local isInit = false

local CFG = {
	bar1 = {
		flyout_dir = "UP",
		-- num = 12,
		per_row = 12,
		width = 32,
		height = 0,
		x_spacing = 4,
		y_spacing = 4,
		-- scale = 1,
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
	},
	["bar2"] = {
		name = "LSActionBar2",
		type = "MULTIACTIONBAR1BUTTON",
		page = 6,
	},
	["bar3"] = {
		name = "LSActionBar3",
		type = "MULTIACTIONBAR2BUTTON",
		page = 5,
	},
	["bar4"] = {
		name = "LSActionBar4",
		type = "MULTIACTIONBAR4BUTTON",
		page = 4,
	},
	["bar5"] = {
		name = "LSActionBar5",
		type = "MULTIACTIONBAR3BUTTON",
		page = 3,
	},
	["bar6"] = {
		name = "LSActionBar6",
		type = "MULTIACTIONBAR5BUTTON",
		page = 13,
	},
	["bar7"] = {
		name = "LSActionBar7",
		type = "MULTIACTIONBAR6BUTTON",
		page = 14,
	},
	["bar8"] = {
		name = "LSActionBar8",
		type = "MULTIACTIONBAR7BUTTON",
		page = 15,
	},
}

local PAGE_STATES = {
	-- Unstealthed cat, stealthed cat, bear, owl; tree form [bonusbar:2] was removed
	["DRUID"] = " [bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	-- Stealth, shadow dance
	["ROGUE"] = " [bonusbar:1] 7;",
	-- Soar
	["EVOKER"] = " [bonusbar:1] 7;",
	-- [bonusbar:5] 11 is skyriding
	["DEFAULT"] = "[overridebar] 18; [shapeshift] 17; [vehicleui][possessbar] 16; [bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function getPageState()
	return PAGE_STATES["DEFAULT"] .. (PAGE_STATES[E.PLAYER_CLASS] or "") .. " [form] 1; 1"
end

local AVAILABLE_PAGES = {
	["DRUID"] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 16, 17, 18},
	["ROGUE"] = {1, 2, 3, 4, 5, 6, 7, 11, 16, 17, 18},
	["EVOKER"] = {1, 2, 3, 4, 5, 6, 7, 11, 16, 17, 18},
	["DEFAULT"] = {1, 2, 3, 4, 5, 6, 11, 16, 17, 18},
}

local function getAvalablePages()
	return AVAILABLE_PAGES[E.PLAYER_CLASS] or AVAILABLE_PAGES.DEFAULT
end

local bar_proto = {}

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
				equipped = {},
			},
			desaturation = {},
			hideElements = {
				border = true,
				borderIfEmpty = true,
			},
			text = {
				count = {
					font = {},
					position = {},
				},
				hotkey = {
					font = {},
					position = {},
				},
				macro = {
					font = {},
					position = {},
				},
			},
		}
	end

	for k, v in next, C.db.global.colors.button do
		self.buttonConfig.colors[k][1], self.buttonConfig.colors[k][2], self.buttonConfig.colors[k][3] = v:GetRGB()
	end

	-- this is here just to make LAB happy
	for _, text in next, {"count", "hotkey", "macro"} do
		self.buttonConfig.text[text].font.font = LSM:Fetch("font", C.db.global.fonts.button.font)
		self.buttonConfig.text[text].font.size = self._config[text].size
		self.buttonConfig.text[text].font.flags = C.db.global.fonts.button.outline and "OUTLINE" or ""

		self.buttonConfig.text[text].position.anchor = self._config[text].point[1]
		self.buttonConfig.text[text].position.relAnchor = self._config[text].point[1]
		self.buttonConfig.text[text].position.offsetX = self._config[text].point[2]
		self.buttonConfig.text[text].position.offsetY = self._config[text].point[3]

		self.buttonConfig.text[text].justifyH = self._config[text].h_alignment
	end

	self.buttonConfig.actionButtonUI = true
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
		button:SetAttribute("buttonlock", self._config.lock)
		button:SetAttribute("unlockedpreventdrag", true)
		button:SetAttribute("checkmouseovercast", true)
		button:SetAttribute("checkfocuscast", true)
		button:SetAttribute("checkselfcast", true)
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
	self._config.lock = C.db.profile.bars.lock
	self._config.mana_indicator = C.db.profile.bars.mana_indicator
	self._config.range_indicator = C.db.profile.bars.range_indicator
	self._config.rightclick_selfcast = C.db.profile.bars.rightclick_selfcast

	if MODULE:IsRestricted() then
		if C.db.profile.bars.bar1.num < 6 then
			C.db.profile.bars.bar1.num = 6
		end

		self._config.grid = C.db.profile.bars.bar1.grid
		self._config.num = C.db.profile.bars.bar1.num
		self._config.count = E:CopyTable(C.db.profile.bars.bar1.count, self._config.count)
		self._config.hotkey = E:CopyTable(C.db.profile.bars.bar1.hotkey, self._config.hotkey)
		self._config.macro = E:CopyTable(C.db.profile.bars.bar1.macro, self._config.macro)

		MODULE:UpdateMainBarMaxButtons(C.db.profile.bars.bar1.num)
		MODULE:UpdateScale(C.db.profile.bars.bar1.scale)
	else
		if C.db.profile.bars.bar1.num > 12 then
			C.db.profile.bars.bar1.num = 12
		end
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
		-- register these first because they might fire right away
		LAB:RegisterCallback("OnFlyoutButtonCreated", function(_, button)
			E:SkinActionButton(button)
			button:SetScale(1)
			button:SetSize(32, 32)
		end)

		LAB:RegisterCallback("OnAssistedCombatRotationFrameCreated", function(_, button)
			if button.AssistedCombatRotationFrame then
				button.AssistedCombatRotationFrame.InactiveTexture:ClearAllPoints()
				button.AssistedCombatRotationFrame.InactiveTexture:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
				button.AssistedCombatRotationFrame.InactiveTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 10, -10)

				button.AssistedCombatRotationFrame.ActiveFrame.Border:ClearAllPoints()
				button.AssistedCombatRotationFrame.ActiveFrame.Border:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
				button.AssistedCombatRotationFrame.ActiveFrame.Border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 10, -10)

				button.AssistedCombatRotationFrame.ActiveFrame.Mask:ClearAllPoints()
				button.AssistedCombatRotationFrame.ActiveFrame.Mask:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
				button.AssistedCombatRotationFrame.ActiveFrame.Mask:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 10, -10)
			end
		end)

		LAB:RegisterCallback("OnAssistedCombatHighlightFrameCreated", function(_, button)
			if button.AssistedCombatHighlightFrame then
				button.AssistedCombatHighlightFrame.Flipbook:ClearAllPoints()
				button.AssistedCombatHighlightFrame.Flipbook:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
				button.AssistedCombatHighlightFrame.Flipbook:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 10, -10)
			end
		end)

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

			for i = 1, 12 do
				local button = Mixin(LAB:CreateButton(i, "$parentButton" .. i, bar), button_proto)
				button:SetState(0, "action", i)
				button._parent = bar
				button._command = data.type .. i
				button.MasqueSkinned = true -- so that LAB doesn't move stuff around
				bar._buttons[i] = button

				if barID == "bar1" then
					for _, p in next, getAvalablePages() do
						button:SetState(p, "action", (p - 1) * 12 + i)
					end
				else
					button:SetState(data.page, "action", (data.page - 1) * 12 + i)
				end

				E:SkinActionButton(button)
			end

			bar:SetAttribute("_onstate-page", [[
				self:SetAttribute("state", newstate)
				control:ChildUpdate("state", newstate)
			]])

			RegisterStateDriver(bar, "page", barID == "bar1" and getPageState() or data.page)

			if barID == "bar1" and MODULE:IsRestricted() then
				MODULE:AddControlledWidget("ACTION_BAR", bar)
			else
				bar:SetPoint(unpack(config[barID].point))
				E.Movers:Create(bar)
			end

			bar:Update()
		end

		hooksecurefunc(SpellFlyout, "Toggle", function(self, _, ID)
			if self:IsShown() then
				local _, _, numSlots = GetFlyoutInfo(ID)
				for i = 1, numSlots do
					E:SkinFlyoutButton(_G["SpellFlyoutButton" .. i])
				end
			end
		end)

		local flyout = LAB:GetSpellFlyoutFrame()
		if flyout then
			E:ForceHide(flyout.Background)
		end

		isInit = true
	end
end
