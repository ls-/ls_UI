local _, ns = ...
local E = ns.E
local B = E:GetModule("Blizzard")

function B:HandleDurabilityFrame()
	_G.DurabilityFrame:ClearAllPoints()
	_G.DurabilityFrame:SetPoint("TOPRIGHT", _G.UIParent, "TOPRIGHT", -4, -168)

	E:CreateMover(_G.DurabilityFrame)

	_G.hooksecurefunc(_G.DurabilityFrame, "SetPoint", function(self, ...)
		local _, parent = ...

		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			local mover = E:GetMover(self)

			if mover then
				self:ClearAllPoints()
				self:SetPoint("TOPRIGHT", mover, "TOPRIGHT", 0, 0)
			end
		end
	end)

	_G.DurabilityFrame:SetPoint("TOPRIGHT", _G.MinimapCluster, "TOPRIGHT", 0, 0)
end
