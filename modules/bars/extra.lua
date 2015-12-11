local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

function B:HandleExtraActionButton()
	local EXTRA_CONFIG = C.bars.extra

	ExtraActionBarFrame:SetParent(UIParent)
	ExtraActionBarFrame:SetSize(EXTRA_CONFIG.button_size, EXTRA_CONFIG.button_size)
	ExtraActionBarFrame:ClearAllPoints()
	ExtraActionBarFrame:SetPoint(unpack(EXTRA_CONFIG.point))
	ExtraActionBarFrame:EnableMouse(false)
	ExtraActionBarFrame.ignoreFramePositionManager = true

	E:CreateMover(ExtraActionBarFrame)

	ExtraActionButton1:SetAllPoints()

	E:SkinExtraActionButton(ExtraActionButton1)
end
