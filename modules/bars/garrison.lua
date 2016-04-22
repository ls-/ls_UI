local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

-- Lua
local unpack = unpack

-- Blizz
local DraenorZoneAbilityFrame = DraenorZoneAbilityFrame

function B:HandleGarrisonButton()
	DraenorZoneAbilityFrame:SetSize(C.bars.garrison.button_size, C.bars.garrison.button_size)
	DraenorZoneAbilityFrame:ClearAllPoints()
	DraenorZoneAbilityFrame:SetPoint(unpack(C.bars.garrison.point))
	DraenorZoneAbilityFrame:EnableMouse(false)
	DraenorZoneAbilityFrame.ignoreFramePositionManager = true
	E:CreateMover(DraenorZoneAbilityFrame)

	DraenorZoneAbilityFrame.SpellButton:SetAllPoints()
	E:SkinExtraActionButton(DraenorZoneAbilityFrame.SpellButton)
end
