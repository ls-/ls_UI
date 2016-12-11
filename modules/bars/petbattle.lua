local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = _G
local pairs = _G.pairs
local unpack = _G.unpack

-- Mine
local isInit = false
local CFG = {
	point = {"BOTTOM", 0, 12},
	button_size = 28,
	button_gap = 4,
	init_anchor = "TOPLEFT",
	buttons_per_row = 6,
}

-----------------
-- INITIALISER --
-----------------

function BARS:PetBattleBar_IsInit()
	return isInit
end

function BARS:PetBattleBar_Init()
	if not isInit then
		if not C.bars.restricted then
			CFG = C.bars.bar1
		end

		local bar = _G.CreateFrame("Frame", "LSPetBattleBar", _G.UIParent, "SecureHandlerBaseTemplate")
		bar:SetPoint(unpack(CFG.point))

		_G.RegisterStateDriver(bar, "visibility", "[petbattle] show; hide")

		_G.FlowContainer_PauseUpdates(_G.PetBattleFrame.BottomFrame.FlowFrame)

		E:ForceHide(_G.PetBattleFrame.BottomFrame.FlowFrame)
		E:ForceHide(_G.PetBattleFrame.BottomFrame.Delimiter)
		E:ForceHide(_G.PetBattleFrame.BottomFrame.MicroButtonFrame)
		E:ForceHide(_G.PetBattleFrameXPBar)
		E:ForceHide(_G.PetBattleFrame.BottomFrame.Background)
		E:ForceHide(_G.PetBattleFrame.BottomFrame.LeftEndCap)
		E:ForceHide(_G.PetBattleFrame.BottomFrame.RightEndCap)
		E:ForceHide(_G.PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2)

		_G.PetBattleFrame.BottomFrame:SetParent(E.HIDDEN_PARENT)

		_G.PetBattleFrame.BottomFrame.TurnTimer:SetParent(bar)
		_G.PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
		_G.PetBattleFrame.BottomFrame.TurnTimer:SetPoint("BOTTOM", bar, "TOP", 0, 8)

		_G.PetBattleFrame.BottomFrame.PetSelectionFrame:SetParent(bar)
		_G.PetBattleFrame.BottomFrame.PetSelectionFrame:ClearAllPoints()
		_G.PetBattleFrame.BottomFrame.PetSelectionFrame:SetPoint("BOTTOM", bar, "TOP", 0, 32)

		_G.hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function()
			local buttons = {
				_G.PetBattleFrame.BottomFrame.abilityButtons[1],
				_G.PetBattleFrame.BottomFrame.abilityButtons[2],
				_G.PetBattleFrame.BottomFrame.abilityButtons[3],
				_G.PetBattleFrame.BottomFrame.SwitchPetButton,
				_G.PetBattleFrame.BottomFrame.CatchButton,
				_G.PetBattleFrame.BottomFrame.ForfeitButton
			}

			for _, button in pairs(buttons) do
				E:SkinPetBattleButton(button)

				button:SetParent(bar)
			end

			bar.buttons = buttons

			E:UpdateBarLayout(bar, bar.buttons, CFG.button_size, CFG.button_gap, CFG.init_anchor, CFG.buttons_per_row)
		end)

		-- Finalise
		isInit = true

		return true
	end
end
