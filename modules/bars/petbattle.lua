local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local PetBattle = CreateFrame("Frame", "LSPetBattleBarModule"); E.PetBattle = PetBattle
local PB_CFG

local PetBattleFrame = PetBattleFrame
local BUTTONS

local function SetPetBattleButtonPosition()
	BUTTONS = {
		PetBattleFrame.BottomFrame.abilityButtons[1],
		PetBattleFrame.BottomFrame.abilityButtons[2],
		PetBattleFrame.BottomFrame.abilityButtons[3],
		PetBattleFrame.BottomFrame.SwitchPetButton,
		PetBattleFrame.BottomFrame.CatchButton,
		PetBattleFrame.BottomFrame.ForfeitButton
	}

	E:SetButtonPosition(BUTTONS, PB_CFG.button_size, PB_CFG.button_gap, PetBattle.BarHeader,
		PB_CFG.direction, E.SkinPetBattleButton)
end

function PetBattle:Initialize()
	PB_CFG = ns.C.petbattle
	local COLORS, TEXTURES = ns.M.colors, ns.M.textures

	local header = CreateFrame("Frame", "LSPetBattleBarHeader", UIParent, "SecureHandlerBaseTemplate")
	header:SetFrameStrata("LOW")
	header:SetFrameLevel(1)

	if PB_CFG.direction == "RIGHT" or PB_CFG.direction == "LEFT" then
		header:SetSize(PB_CFG.button_size * 12 + PB_CFG.button_gap * 12,
			PB_CFG.button_size + PB_CFG.button_gap)
	else
		header:SetSize(PB_CFG.button_size + PB_CFG.button_gap,
			PB_CFG.button_size * 12 + PB_CFG.button_gap * 12)
	end

	header:SetPoint(unpack(PB_CFG.point))

	RegisterStateDriver(header, "visibility", "[petbattle] show; hide")

	PetBattle.BarHeader = header

	FlowContainer_PauseUpdates(PetBattleFrame.BottomFrame.FlowFrame)

	for _, f in next, {
		PetBattleFrame.BottomFrame.FlowFrame,
		PetBattleFrame.BottomFrame.Delimiter,
		PetBattleFrame.BottomFrame.MicroButtonFrame,
		PetBattleFrameXPBar,
	} do
		f:SetParent(ns.M.HiddenParent)
		f.ignoreFramePositionManager = true
	end

	for _, t in next, {
		PetBattleFrame.BottomFrame.Background,
		PetBattleFrame.BottomFrame.LeftEndCap,
		PetBattleFrame.BottomFrame.RightEndCap,
		PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2,
	} do
		t:SetTexture(nil)
	end

	PetBattleFrame.BottomFrame.TurnTimer:ClearAllPoints()
	PetBattleFrame.BottomFrame.TurnTimer:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 60)

	local art = header:CreateTexture(nil, "BACKGROUND", nil, -8)
	art:SetPoint("CENTER")
	art:SetTexture("Interface\\AddOns\\oUF_LS\\media\\actionbar")

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", SetPetBattleButtonPosition)
end
