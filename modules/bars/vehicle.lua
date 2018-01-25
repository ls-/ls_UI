local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false
local bar

local function onEvent(self)
	if UnitOnTaxi("player") or CanExitVehicle() then
		self:Show()
		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:Hide()
	end
end

local function onClick(self)
	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding()

		self:SetButtonState("NORMAL")
		self.Icon:SetDesaturated(true)
		self:Disable()
	else
		VehicleExit()
	end
end

function MODULE.CreateVehicleExitButton()
	if not isInit then
		local point = C.db.profile.bars.vehicle.point

		bar = CreateFrame("Frame", "LSVehicleExitFrame", UIParent)
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		local button = E:CreateButton(bar)
		button:SetBorderColor(1, 0.1, 0.15)
		button:RegisterEvent("UNIT_ENTERED_VEHICLE")
		button:RegisterEvent("UNIT_EXITED_VEHICLE")
		button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
		button:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
		button:RegisterEvent("VEHICLE_UPDATE")
		button:SetScript("OnEvent", onEvent)
		button:SetScript("OnClick", onClick)
		button:SetPoint("TOPLEFT", 2, -2)
		button:SetPoint("BOTTOMRIGHT", -2, 2)

		button.Icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
		button.Icon:SetTexCoord(12 / 64, 52 / 64, 12 / 64, 52 / 64)

		onEvent(button)

		MODULE:InitBarFading(bar)

		isInit = true

		MODULE:UpdateVehicleExitButton()

		-- Cleanup
		E:ForceHide(MainMenuBarVehicleLeaveButton)
	end
end

function MODULE.UpdateVehicleExitButton()
	if isInit then
		bar._config = C.db.profile.bars.vehicle

		bar:SetSize(bar._config.size + 4, bar._config.size + 4)
		bar:AdjustMoverSize()
		MODULE:UpdateBarFading(bar)
	end
end
