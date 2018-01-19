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
		type = "ACTIONBUTTON%d",
		b_buttons = {
			ActionButton1, ActionButton2, ActionButton3, ActionButton4,
			ActionButton5, ActionButton6, ActionButton7, ActionButton8,
			ActionButton9, ActionButton10, ActionButton11, ActionButton12,
		},
		num_buttons = 12,
	},
	bar2 = {
		name = "LSActionBar2",
		type = "MULTIACTIONBAR1BUTTON%d",
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
		type = "MULTIACTIONBAR2BUTTON%d",
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
		type = "MULTIACTIONBAR4BUTTON%d",
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
		type = "MULTIACTIONBAR3BUTTON%d",
		b_buttons = {
			MultiBarRightButton1, MultiBarRightButton2, MultiBarRightButton3, MultiBarRightButton4,
			MultiBarRightButton5, MultiBarRightButton6, MultiBarRightButton7, MultiBarRightButton8,
			MultiBarRightButton9, MultiBarRightButton10, MultiBarRightButton11, MultiBarRightButton12,
		},
		num_buttons = 12,
		page = 3,
	},
	-- bar6 = {
	-- 	name = "LSPetBar",
	-- 	type = "BONUSACTIONBUTTON%d",
	-- 	b_buttons = {
	-- 		PetActionButton1, PetActionButton2, PetActionButton3, PetActionButton4, PetActionButton5,
	-- 		PetActionButton6, PetActionButton7, PetActionButton8, PetActionButton9, PetActionButton10,
	-- 	},
	-- 	original_bar = "PetActionBarFrame",
	-- },
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

			for i = 1, data.num_buttons do
				local button = LibActionButton:CreateButton(i, "$parentButton"..i, bar)
				button:SetState(0, "action", i)
				button._parent = bar
				button._command = data.type:format(i)

				for k = 1, 14 do
					button:SetState(k, "action", (k - 1) * 12 + i)
				end

				-- for IconIntroTracker
				data.b_buttons[i]:SetAllPoints(button)
				E:ForceHide(data.b_buttons[i])

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

			RegisterStateDriver(bar, "page", barID == "bar1" and GetBarPage() or data.page)

			MODULE:AddBar(barID, bar)

			-- hacks
			if barID == "bar1" and MODULE:IsRestricted() then
				bar.Update = function(self)
					self._config = CFG.bar1

					MODULE:UpdateBarLABConfig(self)
					E:UpdateBarLayout(self)
				end
			end
		end

		for barID, bar in next, MODULE:GetBars() do
			if barID == "bar1" and MODULE:IsRestricted() then
				MODULE:ActionBarController_AddWidget(bar, "ACTION_BAR")
			else
				local point = config[barID].point
				bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
				E:CreateMover(bar)
			end

			bar._config = config[barID]

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
