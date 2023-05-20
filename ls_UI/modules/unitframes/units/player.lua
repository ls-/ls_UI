local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

local player_proto = {}

function player_proto:Update()
	UF.large_proto.Update(self)

	if self:IsEnabled() then
		self:UpdateAdditionalPower()
		self:UpdatePowerPrediction()
		self:UpdateClassPower()

		if self.Runes then
			self:UpdateRunes()
		end

		if self.Stagger then
			self:UpdateStagger()
		end
	end
end

function UF:HasPlayerFrame()
	return isInit
end

function UF:CreatePlayerFrame(frame)
	Mixin(self:CreateLargeFrame(frame), player_proto)

	frame.AdditionalPower = self:CreateAdditionalPower(frame)
	frame.PowerPrediction = self:CreatePowerPrediction(frame, frame.Power, frame.AdditionalPower)
	frame.ClassPower = self:CreateClassPower(frame)

	if E.PLAYER_CLASS == "DEATHKNIGHT" then
		frame.Runes = self:CreateRunes(frame)
	elseif E.PLAYER_CLASS == "MONK" then
		frame.Stagger = self:CreateStagger(frame)
	end

	local pvpTimer = frame.PvPIndicator.Holder:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
	pvpTimer:SetPoint("TOPRIGHT", frame.PvPIndicator, "TOPRIGHT", 0, 0)
	pvpTimer:SetTextColor(1, 0.82, 0)
	pvpTimer:SetJustifyH("RIGHT")
	frame.PvPIndicator.Timer = pvpTimer

	isInit = true

	return frame
end
