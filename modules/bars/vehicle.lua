local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local isInit = false

local function VehicleExitButton_OnEvent(self)
	if _G.UnitOnTaxi("player") or _G.CanExitVehicle() then
		self:Show()
		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:Hide()
	end
end

local function VehicleExitButton_OnClick(self)
	if _G.UnitOnTaxi("player") then
		_G.TaxiRequestEarlyLanding()

		self:SetButtonState("NORMAL")
		self.Icon:SetDesaturated(true)
		self:Disable()
	else
		_G.VehicleExit()
	end
end

-----------------
-- INITIALISER --
-----------------

function BARS:VehicleExitButton_IsInit()
	return isInit
end

function BARS:VehicleExitButton_Init()
	if not isInit then
		local button = E:CreateButton(_G.UIParent, "LSVehicleExitButton")
		button:SetSize(C.db.profile.bars.vehicle.button_size, C.db.profile.bars.vehicle.button_size)
		button:SetPoint(unpack(C.db.profile.bars.vehicle.point))
		button:SetBorderColor(1, 0.1, 0.15)
		button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
		button:RegisterEvent("UNIT_ENTERED_VEHICLE")
		button:RegisterEvent("UNIT_EXITED_VEHICLE")
		button:SetScript("OnEvent", VehicleExitButton_OnEvent)
		button:SetScript("OnClick", VehicleExitButton_OnClick)
		E:CreateMover(button)

		button.Icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
		button.Icon:SetTexCoord(12 / 64, 52 / 64, 12 / 64, 52 / 64)

		VehicleExitButton_OnEvent(button)

		_G.MainMenuBarVehicleLeaveButton:UnregisterAllEvents()

		-- Finalise
		isInit = true

		return true
	end
end
