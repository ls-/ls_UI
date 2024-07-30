local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local BLIZZARD = P:AddModule("Blizzard")

-- Mine
local isInit = false

function BLIZZARD:IsInit()
	return isInit
end

function BLIZZARD:Init()
	if not isInit and PrC.db.profile.blizzard.enabled then
		self:SetUpCharacterFrame()
		self:SetUpCommandBar()
		self:SetUpGameMenu()
		self:SetUpGMFrame()
		self:SetUpMail()
		self:SetUpSuggestFrame()
		self:SetUpTalkingHead()

		isInit = true
	end
end
