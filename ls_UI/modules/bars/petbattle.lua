local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local unpack = _G.unpack

-- Mine
local isInit = false

local CFG = {
	visible = true,
	num = 6,
	width = 32,
	height = 0,
	spacing = 4,
	x_growth = "RIGHT",
	y_growth = "DOWN",
	per_row = 6,
	visibility = "[petbattle] show; hide",
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
}

local bar_proto = {
	UpdateCooldownConfig = E.NOOP,
}

function bar_proto:Update()
	self:UpdateConfig()
	self:UpdateVisibility()
	self:ForEach("UpdateHotKey")
	self:ForEach("UpdateHotKeyFont")
	self:UpdateFading()
	E.Layout:Update(self)
end

function bar_proto:UpdateConfig()
	self._config = E:CopyTable(MODULE:IsRestricted() and CFG or C.db.profile.bars.pet_battle, self._config)
	self._config.height = self._config.height ~= 0 and self._config.height or self._config.width

	if MODULE:IsRestricted() then
		self._config.hotkey = E:CopyTable(C.db.profile.bars.pet_battle.hotkey, self._config.hotkey)
	end
end

local button_proto = {}

function button_proto:UpdateHotKey(state)
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

function button_proto:UpdateHotKeyFont()
	self.HotKey:UpdateFont(self._parent._config.hotkey.size)
end

function MODULE:HasPetBattleBar()
	return isInit
end

function MODULE:CreatePetBattleBar()
	if not isInit and (MODULE:IsRestricted() or PrC.db.profile.bars.pet_battle.enabled) then
		local config = MODULE:IsRestricted() and CFG or C.db.profile.bars.pet_battle

		local bar = Mixin(self:Create("pet_battle", "LSPetBattleBar"), bar_proto)

		hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function()
			bar._buttons[1] = PetBattleFrame.BottomFrame.abilityButtons[1]
			bar._buttons[2] = PetBattleFrame.BottomFrame.abilityButtons[2]
			bar._buttons[3] = PetBattleFrame.BottomFrame.abilityButtons[3]
			bar._buttons[4] = PetBattleFrame.BottomFrame.SwitchPetButton
			bar._buttons[5] = PetBattleFrame.BottomFrame.CatchButton
			bar._buttons[6] = PetBattleFrame.BottomFrame.ForfeitButton

			for id, button in next, bar._buttons do
				Mixin(button, button_proto)
				button._parent = bar
				button._command = "ACTIONBUTTON" .. id
				button:SetParent(bar)

				E:SkinPetBattleButton(button)
			end

			bar:Update()
		end)

		if MODULE:IsRestricted() then
			MODULE:AddControlledWidget("PET_BATTLE_BAR", bar)
		else
			bar:SetPoint(unpack(config.point))
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
