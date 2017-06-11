local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Blizzard
local PetBattleBottomFrame = _G.PetBattleFrame.BottomFrame

-- Mine
-- DO NOT add it to D table
local CFG = {
	num = 6,
	size = 32,
	spacing = 4,
	x_growth = "RIGHT",
	y_growth = "DOWN",
	per_row = 6,
	visibility = "[petbattle] show; hide",
	point = {
		p = "BOTTOM",
		anchor = "UIParent",
		rP = "BOTTOM",
		x = 0,
		y = 16
	},
}

function BARS:CreatePetBattleBar()
	local config = self:IsRestricted() and CFG or C.db.profile.bars.pet_battle

	local bar = _G.CreateFrame("Frame", "LSPetBattleBar", _G.UIParent, "SecureHandlerBaseTemplate")

	if self:IsRestricted() then
		self:ActionBarController_AddWidget(bar, "PET_BATTLE_BAR")
	else
		local point = config.point

		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)
	end

	_G.RegisterStateDriver(bar, "visibility", config.visibility)

	self:AddBar("pet_battle", bar)

	-- hacks
	bar.Update = function(self)
		if self._buttons then
			self._config = BARS:IsRestricted() and CFG or C.db.profile.bars.pet_battle

			E:UpdateBarLayout(self)
		end
	end

	_G.hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function()
		local buttons = {
			PetBattleBottomFrame.abilityButtons[1],
			PetBattleBottomFrame.abilityButtons[2],
			PetBattleBottomFrame.abilityButtons[3],
			PetBattleBottomFrame.SwitchPetButton,
			PetBattleBottomFrame.CatchButton,
			PetBattleBottomFrame.ForfeitButton
		}

		for _, button in next, buttons do
			button._parent = bar
			button:SetParent(bar)

			E:SkinPetBattleButton(button)
		end

		bar._buttons = buttons

		bar:Update()
	end)

	-- Cleanup
	_G.FlowContainer_PauseUpdates(PetBattleBottomFrame.FlowFrame)

	E:ForceHide(PetBattleBottomFrame.FlowFrame)
	E:ForceHide(PetBattleBottomFrame.Delimiter)
	E:ForceHide(PetBattleBottomFrame.MicroButtonFrame)
	E:ForceHide(_G.PetBattleFrameXPBar)
	E:ForceHide(PetBattleBottomFrame.Background)
	E:ForceHide(PetBattleBottomFrame.LeftEndCap)
	E:ForceHide(PetBattleBottomFrame.RightEndCap)
	E:ForceHide(PetBattleBottomFrame.TurnTimer.ArtFrame2)
	E:ForceHide(PetBattleBottomFrame, true, true)

	PetBattleBottomFrame.TurnTimer:SetParent(bar)
	PetBattleBottomFrame.TurnTimer:ClearAllPoints()
	PetBattleBottomFrame.TurnTimer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60)

	PetBattleBottomFrame.PetSelectionFrame:SetParent(bar)
	PetBattleBottomFrame.PetSelectionFrame:ClearAllPoints()
	PetBattleBottomFrame.PetSelectionFrame:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 92)

	self.CreatePetBattleBar = E.NOOP
end
