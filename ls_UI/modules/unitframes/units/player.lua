local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
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

	local addPower = self:CreateAdditionalPower(frame)
	addPower:SetFrameLevel(frame:GetFrameLevel() + 1)
	frame.AdditionalPower = addPower
	frame.Insets.Top:Capture(addPower, 0, 0, 0, 2)

	frame.PowerPrediction = self:CreatePowerPrediction(frame, frame.Power, addPower)

	local classPower = self:CreateClassPower(frame)
	classPower:SetFrameLevel(frame:GetFrameLevel() + 1)
	frame.ClassPower = classPower
	frame.Insets.Top:Capture(classPower, 0, 0, 0, 2)

	if E.PLAYER_CLASS == "MONK" then
		local stagger = self:CreateStagger(frame)
		stagger:SetFrameLevel(frame:GetFrameLevel() + 1)
		frame.Stagger = stagger
		frame.Insets.Top:Capture(stagger, 0, 0, 0, 2)
	elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
		local runes = self:CreateRunes(frame)
		runes:SetFrameLevel(frame:GetFrameLevel() + 1)
		frame.Runes = runes
		frame.Insets.Top:Capture(runes, 0, 0, 0, 2)
	end

	local pvpTimer = frame.PvPIndicator.Holder:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
	pvpTimer:SetPoint("TOPRIGHT", frame.PvPIndicator, "TOPRIGHT", 0, 0)
	pvpTimer:SetTextColor(1, 0.82, 0)
	pvpTimer:SetJustifyH("RIGHT")
	frame.PvPIndicator.Timer = pvpTimer

	frame:Tag(frame.Status, "[ls:combatresticon][ls:leadericon][ls:lfdroleicon]")

	isInit = true

	return frame
end
