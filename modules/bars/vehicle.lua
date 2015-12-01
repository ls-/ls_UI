local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Bars")
local VEHICLE_CFG

local function LeaveButton_OnEvent(self, event)
	if not InCombatLockdown() then
		if event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end

		if UnitOnTaxi("player") then
			RegisterStateDriver(self, "visibility", "show")
		else
			RegisterStateDriver(self, "visibility", "[canexitvehicle] show; hide")
		end

		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

local function LeaveButton_OnClick(self)
	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding()

		self:SetButtonState("NORMAL")
		self.Icon:SetDesaturated(true)
		self:Disable()
	else
		VehicleExit()
	end
end

function B:HandleVehicleExitButton()
	VEHICLE_CFG = C.bars.vehicle

	local button = E:CreateButton(UIParent, "LSVehicleExitButton")
	button:SetSize(VEHICLE_CFG.button_size, VEHICLE_CFG.button_size)
	button:SetPoint(unpack(VEHICLE_CFG.point))
	button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	button:RegisterEvent("VEHICLE_UPDATE")
	button:SetScript("OnEvent", LeaveButton_OnEvent)
	button:SetScript("OnClick", LeaveButton_OnClick)
	E:CreateMover(button)
	button:SetBorderColor(1, 0.1, 0.15)

	button.Icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button.Icon:SetTexCoord(12 / 64, 52 / 64, 12 / 64, 52 / 64)

	LeaveButton_OnEvent(button, "CUSTOM_FORCE_UPDATE")
end
