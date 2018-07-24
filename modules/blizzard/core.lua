local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:AddModule("Blizzard")

-- Mine
local isInit = false

function BLIZZARD:IsInit()
	return isInit
end

function BLIZZARD:Init()
	if not isInit and C.db.char.blizzard.enabled then
		self:SetUpCastBars()
		self:SetUpCommandBar()
		self:SetUpDigsiteBar()
		self:SetUpDurabilityFrame()
		self:SetUpGMFrame()
		self:SetUpNPE()
		self:SetUpObjectiveTracker()
		self:SetUpAltPowerBar()
		self:SetUpTalkingHead()
		self:SetUpMirrorTimers()
		self:SetUpVehicleSeatFrame()

		isInit = true

		self:Update()
	end
end

function BLIZZARD:Update()
	if isInit then
		self:UpdateObjectiveTracker()
	end
end
