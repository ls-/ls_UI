local _, ns = ...
local E = ns.E
local B = E:GetModule("Blizzard")

function B:HandleNPE()
	E:AddAddonOnLoadTask("Blizzard_Tutorial", function()
		_G.NPE_TutorialInterfaceHelp:ClearAllPoints()
		_G.NPE_TutorialInterfaceHelp:SetPoint("BOTTOM", _G.UIParent, "BOTTOM", 0, 336)

		E:CreateMover(_G.NPE_TutorialInterfaceHelp, true)

		_G.hooksecurefunc(_G.NPE_TutorialInterfaceHelp, "SetPoint", function(self, ...)
			local _, parent = ...

			if parent == "UIParent" or parent == _G.UIParent then
				local mover = E:GetMover(self)

				if mover then
					self:ClearAllPoints()
					self:SetPoint("TOPRIGHT", mover, "TOPRIGHT", 0, 0)
				end
			end
		end)

		_G.NPE_TutorialInterfaceHelp:SetPoint("TOPRIGHT", _G.UIParent, "TOPRIGHT", 0, 0)
	end)
end
