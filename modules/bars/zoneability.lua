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

function BARS:ZoneAbilityButton_IsInit()
	return isInit
end

function BARS:ZoneAbilityButton_Init()
	if not isInit then
		_G.ZoneAbilityFrame.ignoreFramePositionManager = true
		_G.UIPARENT_MANAGED_FRAME_POSITIONS["ZoneAbilityFrame"] = nil

		_G.ZoneAbilityFrame:SetSize(C.bars.garrison.button_size, C.bars.garrison.button_size)
		_G.ZoneAbilityFrame:ClearAllPoints()
		_G.ZoneAbilityFrame:SetPoint(unpack(C.bars.garrison.point))
		_G.ZoneAbilityFrame:EnableMouse(false)
		E:CreateMover(_G.ZoneAbilityFrame)

		_G.ZoneAbilityFrame.SpellButton:SetAllPoints()
		E:SkinExtraActionButton(_G.ZoneAbilityFrame.SpellButton)

		-- Finalise
		isInit = true

		return true
	end
end
