local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:AddModule("Bars")

-- Lua
local _G = _G
local pairs = _G.pairs

-- Mine
local isInit = false

----------------------
-- UTILS & SETTINGS --
----------------------

function BARS:ToggleHotKeyText(isVisible)
	for button in pairs(P:GetHandledButtons()) do
		if button.HotKey then
			button.HotKey:SetShown(isVisible)
		end
	end
end

function BARS:ToggleMacroText(isVisible)
	for button in pairs(P:GetHandledButtons()) do
		if button.Name then
			button.Name:SetShown(isVisible)
		end
	end
end

function BARS:ToggleBar(key, isVisible)
	local bar = P:GetActionBars()[key]

	if bar then
		if isVisible then
			return E:ResetFrameState(bar, "visibility")
		else
			return E:SetFrameState(bar, "visibility", "hide")
		end
	end
end

function BARS:UpdateLayout(key)
	local bar = P:GetActionBars()[key]

	E:UpdateBarLayout(bar, bar.buttons, C.bars[key].button_size, C.bars[key].button_gap, C.bars[key].init_anchor, C.bars[key].buttons_per_row)
	E:UpdateMoverSize(bar)
end

-----------------
-- INITIALISER --
-----------------

function BARS:IsInit()
	return isInit
end

function BARS:Init()
	if not isInit and C.bars.enabled then
		self:ActionBars_Init()
		self:Bags_Init()
		self:ExtraActionButton_Init()
		self:MicroMenu_Init()
		self:PetBattleBar_Init()
		self:VehicleExitButton_Init()
		self:ZoneAbilityButton_Init()

		-- Should be the last one
		self:ActionBarController_Init()

		-- Finalise
		isInit = true

		return true
	end
end
