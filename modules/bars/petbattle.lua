local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS, TEXTURES = M.colors, M.textures
local B = E:GetModule("Bars")
local PB_CFG

local PetBattleBottomFrame = PetBattleFrame.BottomFrame
local BUTTONS

local function SetPetBattleButtonPosition()
	BUTTONS = {
		PetBattleBottomFrame.abilityButtons[1],
		PetBattleBottomFrame.abilityButtons[2],
		PetBattleBottomFrame.abilityButtons[3],
		PetBattleBottomFrame.SwitchPetButton,
		PetBattleBottomFrame.CatchButton,
		PetBattleBottomFrame.ForfeitButton
	}

	E:SetButtonPosition(BUTTONS, PB_CFG.button_size, PB_CFG.button_gap, LSPetBattleBar,
		PB_CFG.direction, E.SkinPetBattleButton)
end

function B:HandlePetBattleBar()
	PB_CFG = C.bars.petbattle

	local bar = CreateFrame("Frame", "LSPetBattleBar", UIParent, "SecureHandlerBaseTemplate")
	bar:SetFrameStrata("LOW")
	bar:SetFrameLevel(1)

	if PB_CFG.direction == "RIGHT" or PB_CFG.direction == "LEFT" then
		bar:SetSize(PB_CFG.button_size * 12 + PB_CFG.button_gap * 12,
			PB_CFG.button_size + PB_CFG.button_gap)
	else
		bar:SetSize(PB_CFG.button_size + PB_CFG.button_gap,
			PB_CFG.button_size * 12 + PB_CFG.button_gap * 12)
	end

	bar:SetPoint(unpack(PB_CFG.point))

	RegisterStateDriver(bar, "visibility", "[petbattle] show; hide")

	FlowContainer_PauseUpdates(PetBattleBottomFrame.FlowFrame)

	for _, f in next, {
		PetBattleBottomFrame.FlowFrame,
		PetBattleBottomFrame.Delimiter,
		PetBattleBottomFrame.MicroButtonFrame,
		PetBattleFrameXPBar,
	} do
		f:SetParent(M.HiddenParent)
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
	PetBattleBottomFrame.TurnTimer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60)

	local art = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
	art:SetPoint("CENTER")
	art:SetTexture("Interface\\AddOns\\oUF_LS\\media\\actionbar")

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", SetPetBattleButtonPosition)
end
