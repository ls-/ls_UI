local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local function frame_UpdateConfig(self)
	self._config = E:CopyTable(C.db.profile.units[self._unit][E.UI_LAYOUT], self._config)
	self._config.cooldown = E:CopyTable(C.db.profile.units.cooldown, self._config.cooldown)
end

do
	local function frame_Update(self)
		self:UpdateConfig()

		if self._config.enabled then
			if not self:IsEnabled() then
				self:Enable()
			end

			self:UpdateSize()
			self:UpdateHealth()
			self:UpdateHealthPrediction()
			self:UpdatePower()
			self:UpdateCastbar()
			self:UpdateRaidTargetIndicator()
			self:UpdateDebuffIndicator()
			self:UpdateThreatIndicator()
		else
			if self:IsEnabled() then
				self:Disable()
			end
		end
	end

	function UF:CreateVerticalPetFrame(frame)
		local level = frame:GetFrameLevel()

		local textureParent = CreateFrame("Frame", nil, frame)
		textureParent:SetFrameLevel(level + 4)
		textureParent:SetAllPoints()
		frame.TextureParent = textureParent

		local fg = textureParent:CreateTexture(nil, "ARTWORK", nil, 1)
		fg:SetSize(80 / 2, 148 / 2)
		fg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pet-frame")
		fg:SetTexCoord(1 / 128, 81 / 128, 1 / 256, 149 / 256)
		fg:SetPoint("CENTER", 0, 0)

		local health = self:CreateHealth(frame, true, "LSFont12_Shadow", frame)
		health:SetFrameLevel(level + 1)
		health:SetSize(8, 112)
		health:SetPoint("CENTER", -6, 0)
		health:SetClipsChildren(true)
		frame.Health = health

		local healthBG = health:CreateTexture(nil, "BACKGROUND")
		healthBG:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
		healthBG:SetAllPoints()

		frame.HealthPrediction = self:CreateHealthPrediction(frame, health)

		local power = self:CreatePower(frame, true, "LSFont12_Shadow", frame)
		power:SetFrameLevel(level + 1)
		power:SetSize(8, 102)
		power:SetPoint("CENTER", 6, 0)
		frame.Power = power

		local powerBG = power:CreateTexture(nil, "BACKGROUND")
		powerBG:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
		powerBG:SetAllPoints()

		frame.Castbar = self:CreateCastbar(frame)

		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, textureParent)

		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, textureParent)
		frame.DebuffIndicator:SetWidth(14)

		local threat = self:CreateThreatIndicator(frame, nil, true)
		threat:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pet-frame-glow")
		threat:SetTexCoord(1 / 128, 85 / 128, 1 / 128, 97 / 128)
		threat:SetSize(84 / 2, 96 / 2)
		threat:SetPoint("CENTER", 0, 0)
		frame.ThreatIndicator = threat

		local leftTube = CreateFrame("Frame", nil, frame)
		leftTube:SetFrameLevel(level + 3)
		leftTube:SetAllPoints(health)
		frame.LeftTube = leftTube

		E:SetStatusBarSkin(leftTube, "VERTICAL-8")

		local rightTube = CreateFrame("Frame", nil, frame)
		rightTube:SetFrameLevel(level + 3)
		rightTube:SetAllPoints(power)
		frame.RightTube = rightTube

		E:SetStatusBarSkin(rightTube, "VERTICAL-8")

		frame.Update = frame_Update
		frame.UpdateConfig = frame_UpdateConfig
	end
end

do
	local function frame_Update(self)
		self:UpdateConfig()

		if self._config.enabled then
			if not self:IsEnabled() then
				self:Enable()
			end

			self:UpdateSize()
			self:UpdateInsets()
			self:UpdateHealth()
			self:UpdateHealthPrediction()
			self:UpdatePower()
			self:UpdateCastbar()
			self:UpdateRaidTargetIndicator()
			self:UpdateDebuffIndicator()
			self:UpdateThreatIndicator()
			self:UpdateName()
			self:UpdateClassIndicator()
		else
			if self:IsEnabled() then
				self:Disable()
			end
		end
	end

	function UF:CreateHorizontalPetFrame(frame)
		local level = frame:GetFrameLevel()

		local bg = frame:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-bg", true)
		bg:SetHorizTile(true)

		local textureParent = CreateFrame("Frame", nil, frame)
		textureParent:SetFrameLevel(level + 7)
		textureParent:SetAllPoints()
		frame.TextureParent = textureParent

		local textParent = CreateFrame("Frame", nil, frame)
		textParent:SetFrameLevel(level + 9)
		textParent:SetAllPoints()
		frame.TextParent = textParent

		frame.Insets = self:CreateInsets(frame, textureParent)

		local health = self:CreateHealth(frame, true, "LSFont12_Shadow", textParent)
		health:SetFrameLevel(level + 1)
		health:SetPoint("LEFT", frame, "LEFT", 0, 0)
		health:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
		health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
		health:SetClipsChildren(true)
		frame.Health = health

		frame.HealthPrediction = self:CreateHealthPrediction(frame, health)

		local power = self:CreatePower(frame, true, "LSFont12_Shadow", textParent)
		power:SetFrameLevel(level + 1)
		power:SetPoint("LEFT", frame, "LEFT", 0, 0)
		power:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		power:SetPoint("TOP", frame.Insets.Bottom, "TOP", 0, -2)
		power:SetPoint("BOTTOM", frame.Insets.Bottom, "BOTTOM", 0, 0)
		frame.Power = power

		power.UpdateContainer = function(_, shouldShow)
			if shouldShow then
				if not frame.Insets.Bottom:IsExpanded() then
					frame.Insets.Bottom:Expand()
				end
			else
				if frame.Insets.Bottom:IsExpanded() then
					frame.Insets.Bottom:Collapse()
				end
			end
		end

		frame.Castbar = self:CreateCastbar(frame)
		frame.Castbar.Holder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -3, -6)

		frame.Name = self:CreateName(frame, "LSFont12_Shadow", textParent)

		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, textParent)

		frame.ThreatIndicator = self:CreateThreatIndicator(frame)

		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, textParent)

		local border = E:CreateBorder(textureParent)
		border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
		border:SetSize(16)
		border:SetOffset(-6)
		frame.Border = border

		local glass = textureParent:CreateTexture(nil, "OVERLAY", nil, 0)
		glass:SetAllPoints(health)
		glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")

		local shadow = textureParent:CreateTexture(nil, "OVERLAY", nil, -1)
		shadow:SetAllPoints(health)
		shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")

		self:CreateClassIndicator(frame)

		frame.Update = frame_Update
		frame.UpdateConfig = frame_UpdateConfig
	end
end
