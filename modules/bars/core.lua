local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local isInit = false

function MODULE.ToggleHotKeyText(_, flag)
	for button in next, P:GetActionButtons() do
		if button.HotKey then
			button.HotKey:SetShown(flag)
		end
	end
end

function MODULE.ToggleMacroText(_, flag)
	for button in next, P:GetActionButtons() do
		if button.Name then
			button.Name:SetShown(flag)
		end
	end
end

function MODULE.ToggleIconIndicators()
	for button in next, P:GetActionButtons() do
		E:UpdateButtonState(button)
	end
end

function MODULE.IsInit()
	return isInit
end

function MODULE.Init()
	if not isInit and C.db.char.bars.enabled then
		MODULE:SetupActionBarController()
		MODULE:CreateActionBars()
		MODULE:CreatePetBattleBar()
		MODULE:CreateExtraButton()
		MODULE:CreateZoneButton()
		MODULE:CreateVehicleExitButton()
		MODULE:CreateMicroMenu()
		MODULE:CreateXPBar()
		MODULE:CreateBags()

		isInit = true
	end
end

function MODULE.Update()
	if isInit then
		MODULE:UpdateBars()
		MODULE:UpdateExtraButton()
		MODULE:UpdateZoneButton()
		MODULE:UpdateMicroButtons()
		MODULE:UpdateVehicleExitButton()
		MODULE:UpdateXPBar()
	end
end
