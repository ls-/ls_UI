local _, ns = ...
local oUF = ns.oUF or oUF
local cfg = ns.cfg

local function InitUnitParameters(self)
	self:SetFrameStrata("BACKGROUND")
	self:SetFrameLevel(1)
	self:SetSize(40, 140)
	self:SetScale(cfg.globals.scale)
	self:SetPoint(unpack(cfg.units.pet.pos))
	self.menu = ns.menu
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", ns.UnitFrame_OnEnter)
	self:SetScript("OnLeave", ns.UnitFrame_OnLeave)
end

local function CreatePetArtwork(self)
	self.cover = CreateFrame("Frame", nil, self)
	self.cover:SetFrameLevel(self:GetFrameLevel()+1)
	self.cover:SetAllPoints(self)

	self.cover.tex = self.cover:CreateTexture(nil,"ARTWORK", nil, 2)
	self.cover.tex:SetPoint("CENTER", 0, 0)
	self.cover.tex:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
end

local function CreatePetHealth(self)
	local r, g, b = unpack(cfg.globals.colors.health.alt)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetOrientation("VERTICAL")
	bar:SetFrameLevel(self:GetFrameLevel())
	bar:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet_filling")
	bar:SetStatusBarColor(r, g, b)
	bar:SetSize(57, 114)
	bar:SetPoint("CENTER", -5, 0)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet_filling")
	bar.bg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
	return bar
end

local function CreatePetPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetOrientation("VERTICAL")
	bar:SetFrameLevel(self:GetFrameLevel())
	bar:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet_filling")
	bar:SetSize(51, 102)
	bar:SetPoint("CENTER", 5, 0)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet_filling")
	bar.bg.multiplier = .25
	return bar
end

local function CreatePetStrings(self)
	self.Health.value = ns.CreateFontString(self.cover, cfg.font, 14, "THINOUTLINE")
	self.Health.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 2, 20)

	self.Power.value = ns.CreateFontString(self.cover, cfg.font, 14, "THINOUTLINE")
	self.Power.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 8, 6)
end

local function CreateStyle(self)
	self.cfg = cfg.units[self.unit]

	self.mouseovers = {}

	InitUnitParameters(self)

	CreatePetArtwork(self)

	self.Health = CreatePetHealth(self)
	self.Health.PostUpdate = ns.UpdateHealth
	self.Health.Smooth = true
	tinsert(self.mouseovers, self.Health)

	self.Power = CreatePetPower(self)
	self.Power.PostUpdate = ns.UpdatePower
	self.Power.Smooth = true
	self.Power.colorPower = true
	tinsert(self.mouseovers, self.Power)

	CreatePetStrings(self)

	self.Threat = ns.CreateThreat(self, "pet")
	self.Threat.Override = ns.ThreatUpdateOverride

	self.DebuffHighlight = ns.CreateDebuffHighlight(self, "pet")
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightFilter = true

	if cfg.units.pet.auras then
		self.Debuffs = ns.CreateDebuff(self, cfg.units.pet)
		self.Debuffs.PostCreateIcon = ns.CreateAuraIcon
		self.Debuffs.PostUpdateIcon = ns.UpdateAuraIcon
	end
end

if cfg.units.pet then
	oUF:Factory(function(self)
		self:RegisterStyle("my:pet", CreateStyle)
		self:SetActiveStyle("my:pet")
		self:Spawn("pet", "oUF_LSPet")
	end)
end