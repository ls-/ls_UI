local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE:HasGMFrame()
	return isInit
end

function MODULE:SetUpGMFrame()
	if not isInit and C.db.char.blizzard.gm.enabled then
		local point = C.db.profile.blizzard.gm.point[E.UI_LAYOUT]
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(TicketStatusFrame)

		isInit = true
	end
end
