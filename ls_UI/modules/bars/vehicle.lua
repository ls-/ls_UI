local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local collectgarbage = _G.collectgarbage
local debugprofilestop = _G.debugprofilestop
local unpack = _G.unpack

-- Mine
local isInit = false

local button_proto = {}

function button_proto:OnSizeChanged(width, height)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if width > height then
		local offset = 0.625 * (1 - height / width) / 2
		self.Icon:SetTexCoord(0.1875, 0.8125, 0.1875 + offset, 0.8125 - offset)
	elseif width < height then
		local offset = 0.625 * (1 - width / height) / 2
		self.Icon:SetTexCoord(0.1875 + offset, 0.8125 - offset, 0.1875, 0.8125)
	else
		self.Icon:SetTexCoord(0.1875, 0.8125, 0.1875, 0.8125)
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "OnSizeChanged", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function button_proto:OnEvent()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if UnitOnTaxi("player") or CanExitVehicle() then
		self:Show()
		self.Icon:SetDesaturated(false)
		self:Enable()
	else
		self:Hide()
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "OnEvent", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function button_proto:OnClick()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if UnitOnTaxi("player") then
		TaxiRequestEarlyLanding()

		self:SetButtonState("NORMAL")
		self.Icon:SetDesaturated(true)
		self:Disable()
	else
		VehicleExit()
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "OnClick", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local bar_proto = {
	UpdateCooldownConfig = E.NOOP,
}

function bar_proto:Update()
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self:UpdateConfig()
	self:UpdateVisibility()
	self:UpdateFading()

	self:SetSize(self._config.width + 4, self._config.height + 4)
	E.Movers:Get(self):UpdateSize()

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "Update", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
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

		button.Border:SetVertexColor(C.db.global.colors.red:GetRGB())

		button:OnEvent()

		bar:SetPoint(unpack(C.db.profile.bars.vehicle.point))
		E.Movers:Create(bar)

		bar:Update()

		isInit = true
	end
end
