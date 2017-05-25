local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

-----------------
-- INITIALISER --
-----------------

function BLIZZARD:Vehicle_IsInit()
	return isInit
end

function BLIZZARD:Vehicle_Init()
	if not isInit and C.db.char.blizzard.vehicle.enabled then
		_G.VehicleSeatIndicator:ClearAllPoints()
		_G.VehicleSeatIndicator:SetPoint("TOPRIGHT", _G.UIParent, "TOPRIGHT", -4, -196)
		E:CreateMover(_G.VehicleSeatIndicator)

		_G.hooksecurefunc(_G.VehicleSeatIndicator, "SetPoint", function(self, ...)
			local _, parent = ...

			if parent == "MinimapCluster" or parent == _G.MinimapCluster then
				local mover = E:GetMover(self)

				if mover then
					self:ClearAllPoints()
					self:SetPoint("TOPRIGHT", mover, "TOPRIGHT", 0, 0)
				end
			end
		end)

		_G.VehicleSeatIndicator:SetPoint("TOPRIGHT", _G.MinimapCluster, "TOPRIGHT", 0, 0)

		-- Finalise
		isInit = true

		return true
	end
end
