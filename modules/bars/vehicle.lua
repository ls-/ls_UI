local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local bar

local function OnEvent(self)
	if _G.UnitOnTaxi("player") or _G.CanExitVehicle() then
		self:Show()
		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:Hide()
	end
end

local function OnClick(self)
	if _G.UnitOnTaxi("player") then
		_G.TaxiRequestEarlyLanding()

		self:SetButtonState("NORMAL")
		self.Icon:SetDesaturated(true)
		self:Disable()
	else
		_G.VehicleExit()
	end
end

function BARS:CreateVehicleExitButton()
	local point = C.db.profile.bars.vehicle.point

	bar = _G.CreateFrame("Frame", "LSVehicleExitFrame", _G.UIParent)
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

	self:UpdateVehicleExitButton()

	-- Cleanup
	E:ForceHide(_G.MainMenuBarVehicleLeaveButton)

	self.CreateVehicleExitButton = E.NOOP
end

function BARS:UpdateVehicleExitButton()
	bar:SetSize(C.db.profile.bars.vehicle.size + 4, C.db.profile.bars.vehicle.size + 4)
	E:UpdateMoverSize(bar)
end
