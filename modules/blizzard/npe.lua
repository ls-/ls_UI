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

function BLIZZARD:NPE_IsInit()
	return isInit
end

function BLIZZARD:NPE_Init()
	if not isInit and C.blizzard.npe.enabled then
		E:AddOnLoadTask("Blizzard_Tutorial", function()
			local holder = _G.CreateFrame("Frame", "NPE_TutorialInterfaceHelpHolder", _G.UIParent)
			holder:SetFrameLevel(_G.NPE_TutorialInterfaceHelp:GetFrameLevel() + 1)
			holder:SetSize(156, 50)
			holder:SetPoint("BOTTOM", _G.UIParent, "BOTTOM", -34, 336)
			E:CreateMover(holder, true)

			_G.NPE_TutorialInterfaceHelp:ClearAllPoints()
			_G.NPE_TutorialInterfaceHelp:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)

			_G.hooksecurefunc(_G.NPE_TutorialInterfaceHelp, "SetPoint", function(self, ...)
				local _, parent = ...

				if parent ~= holder then
					self:ClearAllPoints()
					self:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
				end
			end)
		end)

		-- Finalise
		isInit = true

		return true
	end
end
