local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local isInit = false

function MODULE:HasVehicleSeatFrame()
	return isInit
end

function MODULE:SetUpVehicleSeatFrame()
	if not isInit and PrC.db.profile.blizzard.vehicle_seat.enabled then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint(unpack(C.db.profile.blizzard.vehicle_seat.point))
		E.Movers:Create(VehicleSeatIndicator)

		isInit = true
	end
end
