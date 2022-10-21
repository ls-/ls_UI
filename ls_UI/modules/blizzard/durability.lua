local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE:HasDurabilityFrame()
	return isInit
end

function MODULE:SetUpDurabilityFrame()
	if not isInit and PrC.db.profile.blizzard.durability.enabled then
		local point = C.db.profile.blizzard.durability.point
		DurabilityFrame:ClearAllPoints()
		DurabilityFrame:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(DurabilityFrame)

		isInit = true
	end
end
