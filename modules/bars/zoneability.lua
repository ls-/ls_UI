local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

-- Lua
local _G = _G
local unpack = unpack

-- Blizz
local ZoneAbilityFrame = ZoneAbilityFrame
-- Mine
function B:HandleGarrisonButton()
	ZoneAbilityFrame:SetSize(C.bars.garrison.button_size, C.bars.garrison.button_size)
	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint(unpack(C.bars.garrison.point))
	ZoneAbilityFrame:EnableMouse(false)
	ZoneAbilityFrame.ignoreFramePositionManager = true
	E:CreateMover(ZoneAbilityFrame)

	ZoneAbilityFrame.SpellButton:SetAllPoints()
	E:SkinExtraActionButton(ZoneAbilityFrame.SpellButton)
end
