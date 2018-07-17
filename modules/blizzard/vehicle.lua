local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local isInit = false

function MODULE.HasVehicleSeatFrame()
	return isInit
end

function MODULE.SetUpVehicleSeatFrame()
	if not isInit and C.db.char.blizzard.vehicle.enabled then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -196)
		E.Movers:Create(VehicleSeatIndicator)

		isInit = true
	end
end
