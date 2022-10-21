local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

local button_proto = {}

function button_proto:OnSizeChanged(width, height)
	if width > height then
		local offset = 0.625 * (1 - height / width) / 2
		self.Icon:SetTexCoord(0.1875, 0.8125, 0.1875 + offset, 0.8125 - offset)
	elseif width < height then
		local offset = 0.625 * (1 - width / height) / 2
		self.Icon:SetTexCoord(0.1875 + offset, 0.8125 - offset, 0.1875, 0.8125)
	else
		self.Icon:SetTexCoord(0.1875, 0.8125, 0.1875, 0.8125)
	end
end

function button_proto:OnEvent()
	if UnitOnTaxi("player") or CanExitVehicle() then
		self:Show()
		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:Hide()
	end
end

function button_proto:OnClick()
	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding()

		self:SetButtonState("NORMAL")
		self.Icon:SetDesaturated(true)
		self:Disable()
	else
		VehicleExit()
	end
end

local bar_proto = {
	UpdateCooldownConfig = E.NOOP,
}

function bar_proto:Update()
	self:UpdateConfig()
	self:UpdateVisibility()
	self:UpdateFading()

	self:SetSize(self._config.width + 4, self._config.height + 4)
	E.Movers:Get(self):UpdateSize()
end

function MODULE:CreateVehicleExitButton()
	if not isInit then
		local bar = Mixin(self:Create("vehicle", "LSVehicleExitFrame"), bar_proto)

		local button = Mixin(E:CreateButton(bar), button_proto)
		button:SetPoint("TOPLEFT", 2, -2)
		button:SetPoint("BOTTOMRIGHT", -2, 2)
		button:SetScript("OnClick", button.OnClick)
		button:SetScript("OnEvent", button.OnEvent)
		button:RegisterEvent("UNIT_ENTERED_VEHICLE")
		button:RegisterEvent("UNIT_EXITED_VEHICLE")
		button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
		button:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
		button:RegisterEvent("VEHICLE_UPDATE")
		bar._buttons[1] = button

		button.Icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
		button.Icon:SetTexCoord(0.1875, 0.8125, 0.1875, 0.8125)

		button.Border:SetVertexColor(E:GetRGB(C.db.global.colors.red))

		button:OnEvent()

		local point = C.db.profile.bars.vehicle.point
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(bar)

		bar:Update()

		isInit = true
	end
end
