local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
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
		self:SetUpDigsiteBar()
		self:SetUpGMFrame()
		self:SetUpMail()
		self:SetUpMawBuffs()
		self:SetUpTalkingHead()
		self:SetUpVehicleSeatFrame()

		isInit = true
	end
end
