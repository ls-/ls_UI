local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	TicketStatusFrame UIParent
]]

-- Mine
local isInit = false

function MODULE.HasGMFrame()
	return isInit
end

function MODULE.SetUpGMFrame()
	if not isInit and C.db.char.blizzard.gm.enabled then
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -228, -240)
		E.Movers:Create(TicketStatusFrame)

		isInit = true
	end
end
