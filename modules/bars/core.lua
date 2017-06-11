local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:AddModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local isInit = false

function BARS:ToggleHotKeyText(flag)
	for button in next, P:GetActionButtons() do
		if button.HotKey then
			button.HotKey:SetShown(flag)
		end
	end
end

function BARS:ToggleMacroText(flag)
	for button in next, P:GetActionButtons() do
		if button.Name then
			button.Name:SetShown(flag)
		end
	end
end

function BARS:ToggleIconIndicators()
	for button in next, P:GetActionButtons() do
		E:UpdateButtonState(button)
	end
end

function BARS:IsInit()
	return isInit
end

function BARS:Init()
	if not isInit and C.db.char.bars.enabled then
		self:SetupActionBarController()
		self:CreateBars()
		self:CreatePetBattleBar()
		self:CreateExtraButton()
		self:CreateZoneButton()
		self:CreateVehicleExitButton()
		self:CreateMicroMenu()
		self:CreateXPBar()
		self:CreateBags()

		isInit = true
	end
end

function BARS:Update()
	if isInit then
		self:UpdateBars()
		self:UpdateExtraButton()
		self:UpdateZoneButton()
		self:UpdateMicroButtons()
		self:UpdateVehicleExitButton()
		self:UpdateXPBar()
	end
end
