local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local isInit = false

function MODULE.HasGMFrame()
	return isInit
end

function MODULE.SetUpGMFrame()
	if not isInit and C.db.char.blizzard.gm.enabled then
		TicketStatusFrame:ClearAllPoints()
		TicketStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -132, -196)
		E:CreateMover(TicketStatusFrame)

		hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, ...)
			local _, parent = ...

			if parent == "UIParent" or parent == UIParent then
				local mover = E:GetMover(self)

				if mover then
					self:ClearAllPoints()
					self:SetPoint("TOPRIGHT", mover, "TOPRIGHT", 0, 0)
				end
			end
		end)

		TicketStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)

		isInit = true
	end
end
