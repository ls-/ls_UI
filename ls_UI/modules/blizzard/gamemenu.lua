local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

local function adjustScale(self)
	self:SetScale(C.db.profile.blizzard.game_menu.scale)
end

function MODULE:HasGameMenu()
	return isInit
end

function MODULE:SetUpGameMenu()
	if not isInit then
		GameMenuFrame:HookScript("OnShow", adjustScale)

		isInit = true
	end
end
