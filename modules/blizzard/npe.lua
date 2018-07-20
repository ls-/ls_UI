local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

--[[ luacheck: globals
	CreateFrame NPE_TutorialInterfaceHelp UIParent
]]

-- Mine
local isInit = false

function BLIZZARD:HasNPE()
	return isInit
end

function BLIZZARD:SetUpNPE()
	if not isInit and C.db.char.blizzard.npe.enabled then
		E:AddOnLoadTask("Blizzard_Tutorial", function()
			local holder = CreateFrame("Frame", "NPE_TutorialInterfaceHelpHolder", UIParent)
			holder:SetFrameLevel(NPE_TutorialInterfaceHelp:GetFrameLevel() + 1)
			holder:SetSize(156, 50)
			holder:SetPoint("BOTTOM", UIParent, "BOTTOM", -34, 336)
			E.Movers:Create(holder, true)

			NPE_TutorialInterfaceHelp:ClearAllPoints()
			NPE_TutorialInterfaceHelp:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)

			hooksecurefunc(NPE_TutorialInterfaceHelp, "SetPoint", function(self, ...)
				local _, parent = ...

				if parent ~= holder then
					self:ClearAllPoints()
					self:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
				end
			end)
		end)

		isInit = true
	end
end
