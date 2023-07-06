local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
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
		self:SetUpGMFrame()
		self:SetUpMail()
		self:SetUpTalkingHead()
		self:SetUpVehicleSeatFrame()

		isInit = true
	end
end
