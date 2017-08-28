local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Blizz
local CreateFrame = _G.CreateFrame
local FlowContainer_PauseUpdates = _G.FlowContainer_PauseUpdates
local RegisterStateDriver = _G.RegisterStateDriver

-- Mine
local isInit = false

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

function MODULE.CreatePetBattleBar()
	if not isInit then
		local config = MODULE:IsRestricted() and CFG or C.db.profile.bars.pet_battle

		local bar = CreateFrame("Frame", "LSPetBattleBar", UIParent, "SecureHandlerBaseTemplate")

		if MODULE:IsRestricted() then
			MODULE:ActionBarController_AddWidget(bar, "PET_BATTLE_BAR")
		else
			local point = config.point

			bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E:CreateMover(bar)
		end

		RegisterStateDriver(bar, "visibility", config.visibility)

		MODULE:AddBar("pet_battle", bar)

		-- hacks
		bar.Update = function(self)
			if self._buttons then
				self._config = MODULE:IsRestricted() and CFG or C.db.profile.bars.pet_battle

				E:UpdateBarLayout(self)
			end
		end

		hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function()
			local buttons = {
				PetBattleFrame.BottomFrame.abilityButtons[1],
				PetBattleFrame.BottomFrame.abilityButtons[2],
				PetBattleFrame.BottomFrame.abilityButtons[3],
				PetBattleFrame.BottomFrame.SwitchPetButton,
				PetBattleFrame.BottomFrame.CatchButton,
				PetBattleFrame.BottomFrame.ForfeitButton
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

		PetBattleFrame.BottomFrame.TurnTimer:SetParent(bar)
		PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
		PetBattleFrame.BottomFrame.TurnTimer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60)

		PetBattleFrame.BottomFrame.PetSelectionFrame:SetParent(bar)
		PetBattleFrame.BottomFrame.PetSelectionFrame:ClearAllPoints()
		PetBattleFrame.BottomFrame.PetSelectionFrame:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 92)
	end
end
