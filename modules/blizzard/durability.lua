local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	DurabilityFrame UIParent
]]

-- Mine
local isInit = false

function MODULE.HasDurabilityFrame()
	return isInit
end

function MODULE.SetUpDurabilityFrame()
	if not isInit and C.db.char.blizzard.durability.enabled then
		DurabilityFrame:ClearAllPoints()
		DurabilityFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -196)
		E.Movers:Create(DurabilityFrame)

		isInit = true
	end
end
