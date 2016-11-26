local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = _G
local unpack = _G.unpack

-- Mine
local isInit = false

-----------------
-- INITIALISER --
-----------------

function BARS:ExtraActionButton_IsInit()
	return isInit
end

function BARS:ExtraActionButton_Init()
	if not isInit then
		_G.ExtraActionBarFrame.ignoreFramePositionManager = true
		_G.UIPARENT_MANAGED_FRAME_POSITIONS["ExtraActionBarFrame"] = nil

		_G.ExtraActionBarFrame:SetParent(_G.UIParent)
		_G.ExtraActionBarFrame:SetSize(C.bars.extra.button_size, C.bars.extra.button_size)
		_G.ExtraActionBarFrame:ClearAllPoints()
		_G.ExtraActionBarFrame:SetPoint(unpack(C.bars.extra.point))
		_G.ExtraActionBarFrame:EnableMouse(false)
		E:CreateMover(_G.ExtraActionBarFrame)

		_G.ExtraActionButton1:SetAllPoints()
		E:SkinExtraActionButton(_G.ExtraActionButton1)

		-- Finalise
		isInit = true
	end
end
