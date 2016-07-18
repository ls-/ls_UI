local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS, TEXTURES = M.colors, M.textures
local B = E:GetModule("Bars")

local PetBattleBottomFrame = PetBattleFrame.BottomFrame
local BUTTONS

local PB_CFG = {
	point = {"BOTTOM", 0, 12},
	button_size = 28,
	button_gap = 4,
	direction = "RIGHT",
}

local function SetPetBattleButtonPosition()
	BUTTONS = {
		PetBattleBottomFrame.abilityButtons[1],
		PetBattleBottomFrame.abilityButtons[2],
		PetBattleBottomFrame.abilityButtons[3],
		PetBattleBottomFrame.SwitchPetButton,
		PetBattleBottomFrame.CatchButton,
		PetBattleBottomFrame.ForfeitButton
	}

	E:SetupBar(LSPetBattleBar, BUTTONS, PB_CFG.button_size, PB_CFG.button_gap, PB_CFG.direction, E.SkinPetBattleButton)
end

function B:HandlePetBattleBar()
	if not C.bars.restricted then
		PB_CFG = C.bars.bar1
	end

	local bar = CreateFrame("Frame", "LSPetBattleBar", UIParent, "SecureHandlerBaseTemplate")
	bar:SetPoint(unpack(PB_CFG.point))

	RegisterStateDriver(bar, "visibility", "[petbattle] show; hide")

	FlowContainer_PauseUpdates(PetBattleBottomFrame.FlowFrame)

	for _, f in next, {
		PetBattleBottomFrame.FlowFrame,
		PetBattleBottomFrame.Delimiter,
		PetBattleBottomFrame.MicroButtonFrame,
		PetBattleFrameXPBar,
	} do
		f:SetParent(E.HIDDEN_PARENT)
		f.ignoreFramePositionManager = true
	end

	for _, t in next, {
		PetBattleBottomFrame.Background,
		PetBattleBottomFrame.LeftEndCap,
		PetBattleBottomFrame.RightEndCap,
		PetBattleBottomFrame.TurnTimer.ArtFrame2,
	} do
		t:SetTexture(nil)
	end

	PetBattleBottomFrame.TurnTimer:ClearAllPoints()
	PetBattleBottomFrame.TurnTimer:SetPoint("BOTTOM", bar, "TOP", 0, 8)

	-- local art = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
	-- art:SetPoint("CENTER")
	-- art:SetTexture("Interface\\AddOns\\oUF_LS\\media\\actionbar")

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", SetPetBattleButtonPosition)

	B:SetupControlledBar(bar, "PetBattle")
end
