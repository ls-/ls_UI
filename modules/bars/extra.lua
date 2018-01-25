local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false
local bar

function MODULE.CreateExtraButton()
	if not isInit then
		local point = C.db.profile.bars.extra.point

		bar = CreateFrame("Frame", "LSExtraActionBar", UIParent, "SecureHandlerStateTemplate")
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		ExtraActionBarFrame.ignoreFramePositionManager = true
		UIPARENT_MANAGED_FRAME_POSITIONS["ExtraActionBarFrame"] = nil

		ExtraActionBarFrame:EnableMouse(false)
		ExtraActionBarFrame:SetParent(bar)
		ExtraActionBarFrame:SetAllPoints()

		ExtraActionButton1:SetPoint("TOPLEFT", 2, -2)
		ExtraActionButton1:SetPoint("BOTTOMRIGHT", -2, 2)
		E:SkinExtraActionButton(ExtraActionButton1)

		MODULE:InitBarFading(bar)

		isInit = true

		MODULE:UpdateExtraButton()
	end
end

function MODULE.UpdateExtraButton()
	if isInit then
		bar._config = C.db.profile.bars.extra

		ExtraActionBarFrame:SetAllPoints()

		bar:SetSize(bar._config.size + 4, bar._config.size + 4)
		bar:AdjustMoverSize()
		MODULE:UpdateBarFading(bar)
		MODULE:UpdateBarVisibility(bar)
	end
end
