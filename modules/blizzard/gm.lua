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

function BLIZZARD:GM_IsInit()
	return isInit
end

function BLIZZARD:GM_Init()
	if not isInit and C.db.char.blizzard.gm.enabled then
		_G.TicketStatusFrame:ClearAllPoints()
		_G.TicketStatusFrame:SetPoint("TOPRIGHT", _G.UIParent, "TOPRIGHT", -132, -196)
		E:CreateMover(_G.TicketStatusFrame)

		_G.hooksecurefunc(_G.TicketStatusFrame, "SetPoint", function(self, ...)
			local _, parent = ...

			if parent == "UIParent" or parent == _G.UIParent then
				local mover = E:GetMover(self)

				if mover then
					self:ClearAllPoints()
					self:SetPoint("TOPRIGHT", mover, "TOPRIGHT", 0, 0)
				end
			end
		end)

		_G.TicketStatusFrame:SetPoint("TOPRIGHT", _G.UIParent, "TOPRIGHT", 0, 0)

		-- Finalise
		isInit = true

		return true
	end
end
