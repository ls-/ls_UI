local _, ns = ...
local E, M = ns.E, ns.M

E.Vehicle = {}

local Vehicle = E.Vehicle

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

function Vehicle:Initialize()
	local VEHICLE_CONFIG = ns.C.bars.vehicle

	local button = CreateFrame("Button", nil, UIParent, "SecureHandlerBaseTemplate")
	button:SetSize(VEHICLE_CONFIG.button_size, VEHICLE_CONFIG.button_size)
	button:SetPoint(unpack(VEHICLE_CONFIG.point))
	button:SetFrameStrata("LOW")
	button:SetFrameLevel(2)

	button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	button:RegisterEvent("VEHICLE_UPDATE")

	button:SetScript("OnEvent", LeaveButton_OnEvent)
	button:SetScript("OnClick", LeaveButton_OnClick)

	button.Border = ns.lsCreateButtonBorder(button)
	button.Border:SetVertexColor(1, 0.1, 0.15)

	icon = button:CreateTexture()
	icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	E:TweakIcon(icon, 12 / 64, 52 / 64, 12 / 64, 52 / 64)

	button.Icon = icon

	button:SetHighlightTexture(1, 1, 1)
	ns.lsSetHighlightTexture(button:GetHighlightTexture())

	button:SetPushedTexture(1, 1, 1)
	ns.lsSetPushedTexture(button:GetPushedTexture())

	LeaveButton_OnEvent(button, "CUSTOM_FORCE_UPDATE")
end