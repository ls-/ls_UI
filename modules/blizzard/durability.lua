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

function BLIZZARD:Durability_IsInit()
	return isInit
end

function BLIZZARD:Durability_Init()
	if not isInit and C.db.char.blizzard.durability.enabled then
		_G.DurabilityFrame:ClearAllPoints()
		_G.DurabilityFrame:SetPoint("TOPRIGHT", _G.UIParent, "TOPRIGHT", -4, -196)
		E:CreateMover(_G.DurabilityFrame)

		_G.hooksecurefunc(_G.DurabilityFrame, "SetPoint", function(self, ...)
			local _, parent = ...

			if parent == "MinimapCluster" or parent == _G.MinimapCluster then
				local mover = E:GetMover(self)

				if mover then
					self:ClearAllPoints()
					self:SetPoint("TOPRIGHT", mover, "TOPRIGHT", 0, 0)
				end
			end
		end)

		_G.DurabilityFrame:SetPoint("TOPRIGHT", _G.MinimapCluster, "TOPRIGHT", 0, 0)

		-- Finalise
		isInit = true

		return true
	end
end
