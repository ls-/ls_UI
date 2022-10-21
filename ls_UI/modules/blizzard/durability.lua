local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local isInit = false

function MODULE:HasDurabilityFrame()
	return isInit
end

function MODULE:SetUpDurabilityFrame()
	if not isInit and PrC.db.profile.blizzard.durability.enabled then
		DurabilityFrame:ClearAllPoints()
		DurabilityFrame:SetPoint(unpack(C.db.profile.blizzard.durability.point))
		E.Movers:Create(DurabilityFrame)

		isInit = true
	end
end
