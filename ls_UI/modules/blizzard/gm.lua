local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
local isInit = false

function MODULE:HasGMFrame()
	return isInit
end

function MODULE:SetUpGMFrame()
	if not isInit and PrC.db.profile.blizzard.gm.enabled then
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint(unpack(C.db.profile.blizzard.gm.point))
		E.Movers:Create(TicketStatusFrame)

		isInit = true
	end
end
