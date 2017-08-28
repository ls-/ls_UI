local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE.CreateExtraButton()
	if not isInit then
		local point = C.db.profile.bars.extra.point

		ExtraActionBarFrame:SetParent(UIParent)
		ExtraActionBarFrame:ClearAllPoints()
		ExtraActionBarFrame:EnableMouse(false)
		ExtraActionBarFrame:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(ExtraActionBarFrame)

		ExtraActionBarFrame.ignoreFramePositionManager = true
		UIPARENT_MANAGED_FRAME_POSITIONS["ExtraActionBarFrame"] = nil

		ExtraActionButton1:SetPoint("TOPLEFT", 2, -2)
		ExtraActionButton1:SetPoint("BOTTOMRIGHT", -2, 2)
		E:SkinExtraActionButton(ExtraActionButton1)

		isInit = true

		MODULE:UpdateExtraButton()
	end
end

function MODULE.UpdateExtraButton()
	if isInit then
		ExtraActionBarFrame:SetSize(C.db.profile.bars.extra.size + 4, C.db.profile.bars.extra.size + 4)
		E:UpdateMoverSize(ExtraActionBarFrame)
	end
end
