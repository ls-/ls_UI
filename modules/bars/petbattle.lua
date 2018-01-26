local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

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
	point = {
		p = "BOTTOM",
		anchor = "UIParent",
		rP = "BOTTOM",
		x = 0,
		y = 16
	},
	fade = {
		enabled = false,
	},
}

function MODULE.CreatePetBattleBar()
	if not isInit then
		local config = MODULE:IsRestricted() and CFG or C.db.profile.bars.pet_battle

		local bar = CreateFrame("Frame", "LSPetBattleBar", UIParent, "SecureHandlerStateTemplate")

		MODULE:AddBar("pet_battle", bar)

		-- hacks
		bar.Update = function(self)
			self._config = MODULE:IsRestricted() and CFG or C.db.profile.bars.pet_battle

			MODULE:UpdateBarFading(self)
			MODULE:UpdateBarVisibility(self)

			if self._buttons then
				E:UpdateBarLayout(self)
			end
		end

		if MODULE:IsRestricted() then
			MODULE:ActionBarController_AddWidget(bar, "PET_BATTLE_BAR")
		else
			local point = config.point

			bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
			E:CreateMover(bar)
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

			for id, button in next, buttons do
				button._parent = bar
				button._command = "ACTIONBUTTON"..id
				button:SetParent(bar)

				E:SkinPetBattleButton(button)
			end

			bar._buttons = buttons

			bar:Update()
		end)

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
		E:CreateMover(timer)
		RegisterStateDriver(timer, "visibility", "[petbattle] show; hide")

		PetBattleFrame.BottomFrame.TurnTimer:SetParent(timer)
		PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
		PetBattleFrame.BottomFrame.TurnTimer:SetPoint("TOPLEFT", timer, "TOPLEFT", 1, -1)

		local selector = CreateFrame("Frame", "LSPetBattlePetSelector", UIParent, "SecureHandlerStateTemplate")
		selector:SetSize(636, 200)
		selector:SetPoint("TOP", "UIParent", "TOP", 0, -194)
		E:CreateMover(selector)
		RegisterStateDriver(selector, "visibility", "[petbattle] show; hide")

		PetBattleFrame.BottomFrame.PetSelectionFrame:SetParent(selector)
		PetBattleFrame.BottomFrame.PetSelectionFrame:ClearAllPoints()
		PetBattleFrame.BottomFrame.PetSelectionFrame:SetPoint("BOTTOM", selector, "BOTTOM", 0, 0)
	end
end
