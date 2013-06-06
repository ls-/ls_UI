local _, ns = ...
local oUF = ns.oUF or oUF
local cfg = ns.cfg
local L = ns.L

local function InitUnitFrameParameters(self)
	self:SetFrameStrata("BACKGROUND")
	self:SetFrameLevel(1)
	self.menu = ns.menu
	if self.unit ~= "party" then
		self:SetAttribute("*type2", "menu")
		self:SetAttribute("initial-width", self.cfg.long and 306 or 152)
		self:SetWidth(self.cfg.long and 306 or 152)
		self:SetAttribute("initial-height", 46)
		self:SetHeight(46)
		self:SetAttribute("initial-scale", cfg.globals.scale)
		self:SetScale(cfg.globals.scale)
	end
	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", ns.UnitFrame_OnEnter)
	self:HookScript("OnLeave", ns.UnitFrame_OnLeave)
end

local function CreateUnitFrameArtwork(self)
	self.cover = CreateFrame("Frame", nil, self)
	self.cover:SetFrameLevel(self:GetFrameLevel()+1)
	self.cover:SetAllPoints(self)

	self.cover.tex = self.cover:CreateTexture(nil,"ARTWORK", nil, 2)
	self.cover.tex:SetPoint("CENTER", 0, 0)
	self.cover.tex:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_"..(self.cfg.long and "long_" or "short_")..(self.cfg.power and "sep" or "sol"))
end

local function CreateUnitFrameHealth(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetFrameLevel(self:GetFrameLevel())
	bar:SetSize(self.cfg.long and 250 or 96, self.cfg.power and 19 or 25)
	bar:SetPoint("CENTER", 0, self.cfg.power and 3 or 0)
	bar:SetStatusBarTexture(cfg.globals.textures.statusbar)

	bar.bg = bar:CreateTexture(nil,"BACKGROUND")
	bar.bg:SetTexture(1, 1, 1, 1)
	bar.bg:SetAllPoints(bar)
	bar.bg.multiplier = 0.25
	return bar
end

local function CreateUnitFramePower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetFrameLevel(self:GetFrameLevel())
	bar:SetSize(self.cfg.long and 250 or 96, 4)
	bar:SetPoint("CENTER", 0, -10)
	bar:SetStatusBarTexture(cfg.globals.textures.statusbar)

	bar.bg = bar:CreateTexture(nil,"BACKGROUND")
	bar.bg:SetTexture(1, 1, 1, 1)
	bar.bg:SetAllPoints(bar)
	bar.bg.multiplier = 0.25
	return bar
end

local function CreateUnitFrameBanner(self)
	self.banner = self.cover:CreateTexture(nil,"ARTWORK", nil, 3)
	self.banner:SetSize(120, 60)
	self.banner:SetPoint("BOTTOM", 0, -34)
	self.banner:Hide()

	hooksecurefunc(self, "Show", function(self)
		if not UnitIsPlayer(self.unit) then
			local class = UnitClassification(self.unit)
			if class ~= "normal" and class ~= "minus" then 
				if class == "worldboss" or UnitLevel(self.unit) == -1 then
					self.banner:SetTexture("Interface\\AddOns\\oUF_LS\\media\\banner_boss")
				elseif class == "rare" or class == "rareelite" then
					self.banner:SetTexture("Interface\\AddOns\\oUF_LS\\media\\banner_rare")
				elseif class == "elite" then
					self.banner:SetTexture("Interface\\AddOns\\oUF_LS\\media\\banner_elite")
				end
				self.banner:Show()
			else
				self.banner:Hide()
			end
		else 
			self.banner:Hide()
		end
	end)
end

local function CreateUnitFrameStrings(self)
	self.Name = ns.CreateFontString(self, cfg.font, 16, "THINOUTLINE")
	self.Name:SetPoint("BOTTOM", self, "TOP", 0, self.cfg.class and 16 or 0)
	self.Name:SetPoint("LEFT", self.Health, 0, 0)
	self.Name:SetPoint("RIGHT", self.Health, 0, 0)
	self:Tag(self.Name, "[custom:name]")

	self.Health.value = ns.CreateFontString(self.cover, cfg.font, 14, "THINOUTLINE")
	self.Health.value:SetPoint("RIGHT", -28, self.cfg.power and 4 or 1)
	if self.cfg.power then
		self.Power.value = ns.CreateFontString(self.cover, cfg.font, 12, "THINOUTLINE")
		self.Power.value:SetPoint("LEFT", 30, -10)
	end
	if self.cfg.class then
		local classtext = ns.CreateFontString(self, cfg.font, 14, "THINOUTLINE")
		classtext:SetPoint("BOTTOM", self, "TOP", 0, 0)
		self:Tag(classtext, "[difficulty][level]|r [custom:raceclass]")
	end
	if self.cfg.threat then
		local threat = ns.CreateFontString(self.cover, cfg.font, 14, "THINOUTLINE")
		threat:SetPoint("LEFT", 30, self.cfg.power and 4 or 0)
		self:Tag(threat, "[custom:threat]")
	end
end

local function CreateUnitFrameStyle(self)
	self.cfg = cfg.units[self.unit]

	unit = gsub(self.unit, "%d", "")

	self.mouseovers = {}

	InitUnitFrameParameters(self)

	CreateUnitFrameArtwork(self)

	self.Health = CreateUnitFrameHealth(self)
	self.Health.Smooth = true
	self.Health.colorDisconnected = true ~= "boss"
	self.Health.colorReaction = unit ~= "party"
	self.Health.colorHealth = true
	tinsert(self.mouseovers, self.Health)
	self.Health.PostUpdate = ns.UpdateHealth
	if self.cfg.power then
		self.Power = CreateUnitFramePower(self)
		self.Power.Smooth = true
		self.Power.colorPower = true
		tinsert(self.mouseovers, self.Power)
		self.Power.PostUpdate = ns.UpdatePower
	end
	if unit ~= "boss" and unit ~= "focustarget" and unit ~= "targettarget" then
		self.HealPrediction = ns.CreateHealPrediction(self)
		self.HealPrediction.PostUpdate = ns.UpdateHealPrediction
	end
	if unit == "target" then
		CreateUnitFrameBanner(self)
	end
	CreateUnitFrameStrings(self)
	if unit ~= "focustarget" and unit ~= "targettarget" then
		self.Threat = ns.CreateThreat(self, self.cfg.long and "long" or "short")
		self.Threat.Override = ns.ThreatUpdateOverride

		self.DebuffHighlight = ns.CreateDebuffHighlight(self, self.cfg.long and "long" or "short")
		self.DebuffHighlightAlpha = 1
		self.DebuffHighlightFilter = true
	end
	if self.cfg.auras then
		if self.cfg.auras.buffs then
			self.Buffs = ns.CreateBuff(self)
			self.Buffs.PreUpdate = ns.BuffPreUpdate
			self.Buffs.PostCreateIcon = ns.CreateAuraIcon
			self.Buffs.PostUpdateIcon = ns.UpdateAuraIcon
		end
		if self.cfg.auras.debuffs then
			self.Debuffs = ns.CreateDebuff(self)
			self.Debuffs.PreUpdate = ns.DebuffPreUpdate
			self.Debuffs.PostCreateIcon = ns.CreateAuraIcon
			self.Debuffs.PostUpdateIcon = ns.UpdateAuraIcon
		end
	end
	if self.cfg.castbar then
		self.Castbar = ns.CreateCastbar(self)
		self.Castbar.PostCastStart = ns.CastPostUpdate
		self.Castbar.PostChannelStart = ns.CastPostUpdate
	end
	if unit  == "party" then
		self.Range = { insideAlpha = 1, outsideAlpha = 0.65 }
	end
	self.RaidIcon = ns.CreateIcon(self.cover, 24, "TOP", 0, 6)
	if unit == "target" or unit == "party" then
		self.LFDRole = ns.CreateIcon(self, unpack(cfg.units[unit].icons.role))
		self.Leader = ns.CreateIcon(self, unpack(cfg.units[unit].icons.leader))
	end
	if unit == "target" then
		self.QuestIcon = ns.CreateIcon(self, unpack(cfg.units[unit].icons.quest))
		self.PvP = ns.CreateIcon(self, unpack(cfg.units[unit].icons.pvp))
		self.PvP.Override = ns.PvPOverride
	end
end

oUF:Factory(function(self)
	self:RegisterStyle("my:other", CreateUnitFrameStyle)
	self:SetActiveStyle("my:other")

	local headers, frames = {}, {}
	for unit, config in pairs(cfg.units) do
		if unit ~= "player" and unit ~= "pet" then
			local name = "oUF_LS"..unit:gsub("%a", strupper, 1):gsub("target", "Target")
			if config.pos then
				if config.attributes then
					headers[unit] = oUF:SpawnHeader(name, nil, "party",
						"oUF-initialConfigFunction", 
						([[self:SetAttribute("*type2", "menu")
						self:SetAttribute("initial-width", %d)
						self:SetWidth(%d)
						self:SetAttribute("initial-height", %d)
						self:SetHeight(%d)
						self:SetAttribute("initial-scale", %d)
						self:SetScale(%d)]]):format(152, 152, 46, 46, cfg.globals.scale, cfg.globals.scale),
						unpack(config.attributes))
				else
					frames[unit] = oUF:Spawn(unit, name)
				end
			end
		end
	end
	for unit, frame in pairs(frames) do
		frame:ClearAllPoints()
		frame:SetPoint(unpack(cfg.units[unit].pos))
		if strmatch(unit, "(boss)%d?$") == "boss" then
			local id = strmatch(unit, "boss(%d)")
			_G["Boss"..id.."TargetFramePowerBarAlt"]:ClearAllPoints()
			_G["Boss"..id.."TargetFramePowerBarAlt"]:SetParent(frame)
			_G["Boss"..id.."TargetFramePowerBarAlt"]:SetPoint("LEFT", frame, "RIGHT", -6, 0)
		end
	end
	for unit, header in pairs(headers) do
		header:ClearAllPoints()
		header:SetPoint(unpack(cfg.units[unit].pos))
		header.isVisible = true
		--hooks for hiding and showing my party frames, depends on show/hide state of default party frames
		hooksecurefunc("HidePartyFrame", function()
			if _G["oUF_LSParty"].isVisible == true then
				if not InCombatLockdown() then
					RegisterAttributeDriver(_G["oUF_LSParty"], "state-visibility", "hide")
				end
				_G["oUF_LSParty"].isVisible = false
			end
		end)
		hooksecurefunc("ShowPartyFrame", function()
			if _G["oUF_LSParty"].isVisible == false then
				if not InCombatLockdown() then
					RegisterAttributeDriver(_G["oUF_LSParty"], "state-visibility", "[group:party,nogroup:raid] show;hide")
				end
				_G["oUF_LSParty"].isVisible = true
			end
		end)
		--lil bit hacky, but we can't show/hide frames, while in combat, so that's why i did this check
		header:RegisterEvent("PLAYER_REGEN_ENABLED")
		header:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_ENABLED" then
				if self.isVisible == true and not self:IsShown() then
					RegisterAttributeDriver(self, "state-visibility", "[group:party,nogroup:raid] show;hide")
				elseif self.isVisible == false and self:IsShown() then
					RegisterAttributeDriver(self, "state-visibility", "hide")
				end
			end
		 end)
	end
end)