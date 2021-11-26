local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE.HasVehicleSeatFrame()
	return isInit
end

function MODULE.SetUpVehicleSeatFrame()
	if not isInit and C.db.char.blizzard.vehicle.enabled then
		local point = C.db.profile.blizzard.vehicle.point[E.UI_LAYOUT]
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(VehicleSeatIndicator)

		isInit = true
	end
end
