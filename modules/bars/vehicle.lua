local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")

-- Lua
local _G = _G
local unpack = unpack

-- Mine
local function LeaveButton_OnEvent(self, event)
	if not _G.InCombatLockdown() then
		if event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end

		if _G.UnitOnTaxi("player") then
			_G.RegisterStateDriver(self, "visibility", "show")
		else
			_G.RegisterStateDriver(self, "visibility", "[canexitvehicle] show; hide")
		end

		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

local function LeaveButton_OnClick(self)
	if _G.UnitOnTaxi("player") then
		_G.TaxiRequestEarlyLanding()

		self:SetButtonState("NORMAL")
		self.Icon:SetDesaturated(true)
		self:Disable()
	else
		_G.VehicleExit()
	end
end

function B:HandleVehicleExitButton()
	C.bars.vehicle = C.bars.vehicle

	local button = E:CreateButton(_G.UIParent, "LSVehicleExitButton")
	button:SetSize(C.bars.vehicle.button_size, C.bars.vehicle.button_size)
	button:SetPoint(unpack(C.bars.vehicle.point))
	button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	button:RegisterEvent("VEHICLE_UPDATE")
	button:SetScript("OnEvent", LeaveButton_OnEvent)
	button:SetScript("OnClick", LeaveButton_OnClick)
	E:CreateMover(button)
	button:SetBorderColor(1, 0.1, 0.15)

	button.Icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button.Icon:SetTexCoord(12 / 64, 52 / 64, 12 / 64, 52 / 64)

	LeaveButton_OnEvent(button, "CUSTOM_FORCE_UPDATE")

	_G.MainMenuBarVehicleLeaveButton:UnregisterAllEvents()
end
