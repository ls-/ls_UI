local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

-- Lua
local _G = _G
local pairs, unpack = pairs, unpack

-- Blizz
local PetBattleBottomFrame = PetBattleFrame.BottomFrame

-- Mine
local PetBattleBar

local PB_CFG = {
	point = {"BOTTOM", 0, 12},
	button_size = 28,
	button_gap = 4,
	direction = "RIGHT",
}

local function SetPetBattleButtonPosition()
	local BUTTONS = {
		PetBattleBottomFrame.abilityButtons[1],
		PetBattleBottomFrame.abilityButtons[2],
		PetBattleBottomFrame.abilityButtons[3],
		PetBattleBottomFrame.SwitchPetButton,
		PetBattleBottomFrame.CatchButton,
		PetBattleBottomFrame.ForfeitButton
	}

	for _, button in pairs(BUTTONS) do
		button:SetParent(PetBattleBar)
	end

	E:SetupBar(PetBattleBar, BUTTONS, PB_CFG.button_size, PB_CFG.button_gap, PB_CFG.direction, E.SkinPetBattleButton)
end

function B:HandlePetBattleBar()
	if not C.bars.restricted then
		PB_CFG = C.bars.bar1
	end

	PetBattleBar = _G.CreateFrame("Frame", "LSPetBattleBar", _G.UIParent, "SecureHandlerBaseTemplate")
	PetBattleBar:SetPoint(unpack(PB_CFG.point))
	_G.RegisterStateDriver(PetBattleBar, "visibility", "[petbattle] show; hide")
	B:SetupControlledBar(PetBattleBar, "PetBattle")

	_G.FlowContainer_PauseUpdates(PetBattleBottomFrame.FlowFrame)

	for _, f in pairs({
		PetBattleBottomFrame.FlowFrame,
		PetBattleBottomFrame.Delimiter,
		PetBattleBottomFrame.MicroButtonFrame,
		_G.PetBattleFrameXPBar,
		PetBattleBottomFrame.Background,
		PetBattleBottomFrame.LeftEndCap,
		PetBattleBottomFrame.RightEndCap,
		PetBattleBottomFrame.TurnTimer.ArtFrame2,
	}) do
		E:ForceHide(f)
	end

	PetBattleBottomFrame:SetParent(E.HIDDEN_PARENT)
	PetBattleBottomFrame.TurnTimer:SetParent(PetBattleBar)
	PetBattleBottomFrame.TurnTimer:ClearAllPoints()
	PetBattleBottomFrame.TurnTimer:SetPoint("BOTTOM", PetBattleBar, "TOP", 0, 8)

	_G.hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", SetPetBattleButtonPosition)
end
