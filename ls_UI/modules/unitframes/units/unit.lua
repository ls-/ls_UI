local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local small_proto = {}
UF.small_proto = small_proto

function small_proto:Update()
	self:UpdateConfig()

	if self._config.enabled then
		if not self:IsEnabled() then
			self:Enable()
		end

		self:UpdateSize()
		self:UpdateFading()
		self:UpdateLayout()
		self:UpdateInlay()
		self:UpdateGradient()
		self:UpdateHealth()
		self:UpdateHealthPrediction()
		self:UpdatePower()
		self:UpdateName()
		self:UpdatePortrait()
		self:UpdateRaidTargetIndicator()
		self:UpdateThreatIndicator()
		self:UpdateClassIndicator()

		if self.Status then
			self:UpdateStatus()
		end
	else
		if self:IsEnabled() then
			self:Disable()
		end
	end
end

function UF:CreateSmallUnitFrame(frame)
	Mixin(frame, small_proto)

	-- .Fader
	E:SetUpFading(frame)

	-- .Border
	-- .Inlay
	-- .Insets
	-- .TextParent
	-- .TextureParent
	self:CreateLayout(frame, frame:GetFrameLevel())

	local health = self:CreateHealth(frame, frame.TextParent)
	health:SetPoint("LEFT", frame.Insets.Left, "RIGHT", 0, 0)
	health:SetPoint("TOPRIGHT", health.TempLoss_:GetStatusBarTexture(), "TOPLEFT", 0, 0)
	health:SetPoint("BOTTOMRIGHT", health.TempLoss_:GetStatusBarTexture(), "BOTTOMLEFT", 0, 0)
	frame.Health = health

	health.TempLoss_:SetPoint("LEFT", frame.Insets.Left, "RIGHT", 0, 0)
	health.TempLoss_:SetPoint("RIGHT", frame.Insets.Right, "LEFT", 0, 0)
	health.TempLoss_:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
	health.TempLoss_:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)

	frame.HealthPrediction = self:CreateHealthPrediction(frame, health)
	frame.Power = self:CreatePower(frame, frame.TextParent)
	frame.Name = self:CreateName(frame, frame.TextParent)
	frame.Portrait = self:CreatePortrait(frame)
	frame.ClassIndicator = self:CreateClassIndicator(frame)
	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, frame.TextParent)
	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	return frame
end

local medium_proto = {}
UF.medium_proto = medium_proto

function medium_proto:Update()
	small_proto.Update(self)

	if self:IsEnabled() then
		self:UpdateCastbar()
		self:UpdateDebuffIndicator()
		self:UpdateAuras()
		self:UpdateCustomTexts()
	end
end

function UF:CreateMediumUnitFrame(frame)
	Mixin(self:CreateSmallUnitFrame(frame), medium_proto)

	local castbarSlot = UF:CreateSlot(frame, frame:GetFrameLevel())
	castbarSlot:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -6)
	castbarSlot:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -6)
	castbarSlot:UpdateSize(0, 12) -- default castbar height
	frame.CastbarSlot = castbarSlot

	frame.Castbar = self:CreateCastbar(frame)
	frame.DebuffIndicator = self:CreateDebuffIndicator(frame, frame.TextParent)
	frame.Auras = self:CreateAuras(frame, frame.__unit)
	frame.CustomTexts = self:CreateCustomTexts(frame, frame.TextParent)

	return frame
end

local large_proto = {}
UF.large_proto = large_proto

function large_proto:Update()
	medium_proto.Update(self)

	if self:IsEnabled() then
		self:UpdatePvPIndicator()
		self:AlignWidgets()
	end
end

function large_proto:AlignWidgets()
	if self._config.mirror_widgets then
		self.PvPSlot:ClearAllPoints()
		self.PvPSlot:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 10)

		self.CastbarSlot:ClearAllPoints()
		self.CastbarSlot:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
		self.CastbarSlot:SetPoint("LEFT", self.PvPSlot, "RIGHT", 0, 0)

		self.Status:ClearAllPoints()
		self.Status:SetPoint("RIGHT", self, "BOTTOMRIGHT", -4, -1)
		self.Status:SetJustifyH("RIGHT")
	else
		self.PvPSlot:ClearAllPoints()
		self.PvPSlot:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 10)

		self.CastbarSlot:ClearAllPoints()
		self.CastbarSlot:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
		self.CastbarSlot:SetPoint("RIGHT", self.PvPSlot, "LEFT", 0, 0)

		self.Status:ClearAllPoints()
		self.Status:SetPoint("LEFT", self, "BOTTOMLEFT", 4, -1)
		self.Status:SetJustifyH("LEFT")
	end
end

function UF:CreateLargeFrame(frame)
	Mixin(self:CreateMediumUnitFrame(frame), large_proto)

	local pvpSlot = UF:CreateSlot(frame, frame:GetFrameLevel())
	pvpSlot:UpdateSize(50, 54) -- pvp holder size
	frame.PvPSlot = pvpSlot

	frame.PvPIndicator = self:CreatePvPIndicator(frame, frame.TextureParent)
	pvpSlot:Capture(frame.PvPIndicator.Holder)

	frame.Status = self:CreateStatus(frame, frame.TextParent)

	return frame
end
