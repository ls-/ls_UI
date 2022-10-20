local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local isInit = false

local function closeTalkingHead()
	if C.db.profile.blizzard.talking_head.hide then
		TalkingHeadFrame:CloseImmediately()
	end
end

function MODULE:HasTalkingHead()
	return isInit
end

function MODULE:SetUpTalkingHead()
	if not isInit and PrC.db.profile.blizzard.talking_head.enabled then
		local isLoaded = true
		if not IsAddOnLoaded("Blizzard_TalkingHeadUI") then
			isLoaded = LoadAddOn("Blizzard_TalkingHeadUI")
		end

		if isLoaded then
			hooksecurefunc(TalkingHeadFrame, "PlayCurrent", closeTalkingHead)

			isInit = true
		end
	end
end
