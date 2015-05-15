local _, ns = ...
local E, M = ns.E, ns.M

E.PetBattle = {}

local PetBattle = E.PetBattle

local BUTTONS, PB_CONFIG

local function SetPetBattleButtonPosition()
	BUTTONS = {
		PetBattleFrame.BottomFrame.abilityButtons[1],
		PetBattleFrame.BottomFrame.abilityButtons[2],
		PetBattleFrame.BottomFrame.abilityButtons[3],
		PetBattleFrame.BottomFrame.SwitchPetButton,
		PetBattleFrame.BottomFrame.CatchButton,
		PetBattleFrame.BottomFrame.ForfeitButton
	}

	E:SetButtonPosition(BUTTONS, PB_CONFIG.button_size, PB_CONFIG.button_gap, PetBattle.BarHeader,
		PB_CONFIG.direction, E.SkinPetBattleButton)
end

function PetBattle:Initialize()
	PB_CONFIG = ns.C.petbattle
	local COLORS, TEXTURES = ns.M.colors, ns.M.textures

	local header = CreateFrame("Frame", "lsPetBattleBarHeader", UIParent, "SecureHandlerBaseTemplate")
	header:SetFrameStrata("LOW")
	header:SetFrameLevel(1)

	if PB_CONFIG.direction == "RIGHT" or PB_CONFIG.direction == "LEFT" then
		header:SetSize(PB_CONFIG.button_size * 12 + PB_CONFIG.button_gap * 12,
			PB_CONFIG.button_size + PB_CONFIG.button_gap)
	else
		header:SetSize(PB_CONFIG.button_size + PB_CONFIG.button_gap,
			PB_CONFIG.button_size * 12 + PB_CONFIG.button_gap * 12)
	end

	header:SetPoint(unpack(PB_CONFIG.point))

	RegisterStateDriver(header, "visibility", "[petbattle] show; hide")

	PetBattle.BarHeader = header

	FlowContainer_PauseUpdates(PetBattleFrame.BottomFrame.FlowFrame)

	for _, f in next, {
		PetBattleFrame.BottomFrame.FlowFrame,
		PetBattleFrame.BottomFrame.Delimiter,
		PetBattleFrame.BottomFrame.MicroButtonFrame,
		PetBattleFrameXPBar,
	} do
		f:SetParent(ns.M.hiddenParent)
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
