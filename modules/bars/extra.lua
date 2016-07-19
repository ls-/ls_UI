local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

-- Lua
local _G = _G
local unpack = unpack

-- Blizz
local ExtraActionBarFrame = ExtraActionBarFrame

-- Mine
function B:HandleExtraActionButton()
	ExtraActionBarFrame:SetParent(_G.UIParent)
	ExtraActionBarFrame:SetSize(C.bars.extra.button_size, C.bars.extra.button_size)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint(unpack(C.bars.extra.point))
	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame.ignoreFramePositionManager = true
	E:CreateMover(ExtraActionBarFrame)

	_G.ExtraActionButton1:SetAllPoints()
	E:SkinExtraActionButton(_G.ExtraActionButton1)
end
