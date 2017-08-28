local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Blizz
local CanExitVehicle = _G.CanExitVehicle
local CreateFrame = _G.CreateFrame
local TaxiRequestEarlyLanding = _G.TaxiRequestEarlyLanding
local UnitOnTaxi = _G.UnitOnTaxi
local VehicleExit = _G.VehicleExit

-- Mine
local isInit = false
local bar

local function OnEvent(self)
	if UnitOnTaxi("player") or CanExitVehicle() then
		self:Show()
		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:Hide()
	end
end

local function OnClick(self)
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
		button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
		button:RegisterEvent("UNIT_ENTERED_VEHICLE")
		button:RegisterEvent("UNIT_EXITED_VEHICLE")
		button:SetScript("OnEvent", OnEvent)
		button:SetScript("OnClick", OnClick)
		button:SetPoint("TOPLEFT", 2, -2)
		button:SetPoint("BOTTOMRIGHT", -2, 2)

		button.Icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
		button.Icon:SetTexCoord(12 / 64, 52 / 64, 12 / 64, 52 / 64)

		OnEvent(button)

		isInit = true

		MODULE:UpdateVehicleExitButton()

		-- Cleanup
		E:ForceHide(MainMenuBarVehicleLeaveButton)
	end
end

function MODULE.UpdateVehicleExitButton()
	if isInit then
		bar:SetSize(C.db.profile.bars.vehicle.size + 4, C.db.profile.bars.vehicle.size + 4)
		E:UpdateMoverSize(bar)
	end
end
