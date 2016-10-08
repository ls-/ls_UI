local _, ns = ...
local E = ns.E
local B = E:GetModule("Blizzard")

function B:HandleGM()
	_G.TicketStatusFrame:ClearAllPoints()
	_G.TicketStatusFrame:SetPoint("TOPRIGHT", _G.UIParent, "TOPRIGHT", -136, -168)

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
end
