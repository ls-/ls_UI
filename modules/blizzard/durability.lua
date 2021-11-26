local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function MODULE:HasDurabilityFrame()
	return isInit
end

function MODULE:SetUpDurabilityFrame()
	if not isInit and C.db.char.blizzard.durability.enabled then
		local point = C.db.profile.blizzard.durability.point[E.UI_LAYOUT]
		DurabilityFrame:ClearAllPoints()
		DurabilityFrame:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(DurabilityFrame)

		isInit = true
	end
end
