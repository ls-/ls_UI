local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

--[[ luacheck: globals
	CreateFrame FlowContainer_PauseUpdates PetBattleFrame PetBattleFrameXPBar RegisterStateDriver UIParent
]]

-- Mine
local isInit = false

local CFG = {
	visible = true,
	num = 6,
	size = 32,
	spacing = 4,
	x_growth = "RIGHT",
	y_growth = "DOWN",
	per_row = 6,
	visibility = "[petbattle] show; hide",
	fade = {
		enabled = false,
		out_delay = 0.75,
		out_duration = 0.15,
		in_delay = 0,
		in_duration = 0.15,
		min_alpha = 0,
		max_alpha = 1,
	},
	point = {
		ls = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 16},
		traditional = {p = "BOTTOM", anchor = "UIParent", rP = "BOTTOM", x = 0, y = 16},
	},
}

local function bar_Update(self)
	self:UpdateConfig()
	self:UpdateVisibility()
	self:UpdateButtons("UpdateHotKey")
	self:UpdateButtons("UpdateHotKeyFont")
	self:UpdateFading()
	E:UpdateBarLayout(self)
end

local function bar_UpdateConfig(self)
	self._config = E:CopyTable(MODULE:IsRestricted() and CFG or C.db.profile.bars.pet_battle, self._config)

	if MODULE:IsRestricted() then
		self._config.hotkey = E:CopyTable(C.db.profile.bars.pet_battle.hotkey, self._config.hotkey)
	end
end

local function button_UpdateHotKey(self, state)
	if state ~= nil then
		self._parent._config.hotkey.enabled = state
	end

	if self._parent._config.hotkey.enabled then
		self.HotKey:SetParent(self)
		self.HotKey:SetFormattedText("%s", self:GetHotkey())
		self.HotKey:Show()
	else
		self.HotKey:SetParent(E.HIDDEN_PARENT)
	end
end

local function button_UpdateHotKeyFont(self)
	local config = self._parent._config.hotkey
	self.HotKey:SetFontObject("LSFont" .. config.size .. config.flag)
	self.HotKey:SetWordWrap(false)
end

function MODULE.HasPetBattleBar()
	return isInit
end

function MODULE.CreatePetBattleBar()
	if not isInit and (MODULE:IsRestricted() or C.db.char.bars.pet_battle.enabled) then
		local config = MODULE:IsRestricted() and CFG or C.db.profile.bars.pet_battle

		local bar = CreateFrame("Frame", "LSPetBattleBar", UIParent, "SecureHandlerStateTemplate")
		bar._id = "pet_battle"
		bar._buttons = {}

		MODULE:AddBar(bar._id, bar)

		bar.Update = bar_Update
		bar.UpdateConfig = bar_UpdateConfig
		bar.UpdateCooldownConfig = nil

		hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function()
			bar._buttons[1] = PetBattleFrame.BottomFrame.abilityButtons[1]
			bar._buttons[2] = PetBattleFrame.BottomFrame.abilityButtons[2]
			bar._buttons[3] = PetBattleFrame.BottomFrame.abilityButtons[3]
			bar._buttons[4] = PetBattleFrame.BottomFrame.SwitchPetButton
			bar._buttons[5] = PetBattleFrame.BottomFrame.CatchButton
			bar._buttons[6] = PetBattleFrame.BottomFrame.ForfeitButton

			for id, button in next, bar._buttons do
				button._parent = bar
				button._command = "ACTIONBUTTON" .. id
				button:SetParent(bar)

				button.UpdateHotKey = button_UpdateHotKey
				button.UpdateHotKeyFont = button_UpdateHotKeyFont

				E:SkinPetBattleButton(button)
			end

			bar:Update()
		end)

		if MODULE:IsRestricted() then
			MODULE:ActionBarController_AddWidget(bar, "PET_BATTLE_BAR")
		else
			local point = config.point[E.UI_LAYOUT]
			bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E.Movers:Create(bar)
		end

		bar:Update()

		-- Cleanup
		FlowContainer_PauseUpdates(PetBattleFrame.BottomFrame.FlowFrame)

		E:ForceHide(PetBattleFrame.BottomFrame.FlowFrame)
		E:ForceHide(PetBattleFrame.BottomFrame.Delimiter)
		E:ForceHide(PetBattleFrame.BottomFrame.MicroButtonFrame)
		E:ForceHide(PetBattleFrameXPBar)
		E:ForceHide(PetBattleFrame.BottomFrame.Background)
		E:ForceHide(PetBattleFrame.BottomFrame.LeftEndCap)
		E:ForceHide(PetBattleFrame.BottomFrame.RightEndCap)
		E:ForceHide(PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2)
		E:ForceHide(PetBattleFrame.BottomFrame, true, true)

		local timer = CreateFrame("Frame", "LSPetBattleTurnTimer", UIParent, "SecureHandlerStateTemplate")
		timer:SetSize(474, 28)
		timer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60)
		E.Movers:Create(timer)
		RegisterStateDriver(timer, "visibility", "[petbattle] show; hide")

		PetBattleFrame.BottomFrame.TurnTimer:SetParent(timer)
		PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
		PetBattleFrame.BottomFrame.TurnTimer:SetPoint("TOPLEFT", timer, "TOPLEFT", 1, -1)

		local selector = CreateFrame("Frame", "LSPetBattlePetSelector", UIParent, "SecureHandlerStateTemplate")
		selector:SetSize(636, 200)
		selector:SetPoint("TOP", "UIParent", "TOP", 0, -256)
		E.Movers:Create(selector)
		RegisterStateDriver(selector, "visibility", "[petbattle] show; hide")

		PetBattleFrame.BottomFrame.PetSelectionFrame:SetParent(selector)
		PetBattleFrame.BottomFrame.PetSelectionFrame:ClearAllPoints()
		PetBattleFrame.BottomFrame.PetSelectionFrame:SetPoint("BOTTOM", selector, "BOTTOM", 0, 0)

		isInit = true
	end
end
