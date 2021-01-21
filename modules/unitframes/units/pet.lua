local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
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
			self:UpdateCustomTexts()
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

		local textParent = CreateFrame("Frame", nil, frame)
		textParent:SetFrameLevel(level + 6)
		textParent:SetAllPoints()
		frame.TextParent = textParent

		local fg = textureParent:CreateTexture(nil, "ARTWORK", nil, 1)
		fg:SetSize(80 / 2, 148 / 2)
		fg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pet-frame")
		fg:SetTexCoord(1 / 128, 81 / 128, 1 / 256, 149 / 256)
		fg:SetPoint("CENTER", 0, 0)

		local health = self:CreateHealth(frame, textParent)
		health:SetFrameLevel(level + 1)
		health:SetSize(8, 112)
		health:SetPoint("CENTER", -6, 0)
		health:SetClipsChildren(true)
		frame.Health = health

		local healthBG = health:CreateTexture(nil, "BACKGROUND")
		healthBG:SetColorTexture(E:GetRGB(C.db.global.colors.dark_gray))
		healthBG:SetAllPoints()

		frame.HealthPrediction = self:CreateHealthPrediction(frame, health, textParent)

		local power = self:CreatePower(frame, textParent)
		power:SetFrameLevel(level + 1)
		power:SetSize(8, 102)
		power:SetPoint("CENTER", 6, 0)
		frame.Power = power

		local powerBG = power:CreateTexture(nil, "BACKGROUND")
		powerBG:SetColorTexture(E:GetRGB(C.db.global.colors.dark_gray))
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

		frame.CustomTexts = self:CreateCustomTexts(frame, textParent)

		local leftTube = CreateFrame("Frame", nil, frame)
		leftTube:SetFrameLevel(level + 3)
		leftTube:SetAllPoints(health)
		frame.LeftSlot = leftTube

		E:SetStatusBarSkin(leftTube, "VERTICAL-8")

		local rightTube = CreateFrame("Frame", nil, frame)
		rightTube:SetFrameLevel(level + 3)
		rightTube:SetAllPoints(power)
		frame.RightSlot = rightTube

		E:SetStatusBarSkin(rightTube, "VERTICAL-8")

		frame.Update = frame_Update
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
			self:UpdateLayout()
			self:UpdateHealth()
			self:UpdateHealthPrediction()
			self:UpdatePortrait()
			self:UpdatePower()
			self:UpdateCastbar()
			self:UpdateRaidTargetIndicator()
			self:UpdateDebuffIndicator()
			self:UpdateThreatIndicator()
			self:UpdateName()
			self:UpdateClassIndicator()
			self:UpdateCustomTexts()
		else
			if self:IsEnabled() then
				self:Disable()
			end
		end
	end

	function UF:CreateHorizontalPetFrame(frame)
		local level = frame:GetFrameLevel()

		-- .TextureParent
		-- .TextParent
		-- .Insets
		-- .Border
		self:CreateLayout(frame, level)

		local health = self:CreateHealth(frame, frame.TextParent)
		health:SetFrameLevel(level + 1)
		health:SetPoint("LEFT", frame.Insets.Left, "RIGHT", 0, 0)
		health:SetPoint("RIGHT", frame.Insets.Right, "LEFT", 0, 0)
		health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
		health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
		health:SetClipsChildren(true)
		frame.Health = health

		frame.HealthPrediction = self:CreateHealthPrediction(frame, health, frame.TextParent)

		frame.Portrait = self:CreatePortrait(frame)

		local power = self:CreatePower(frame, frame.TextParent)
		power:SetFrameLevel(level + 1)
		frame.Power = power

		frame.Insets.Bottom:Capture(power, 0, 0, -2, 0)

		frame.Castbar = self:CreateCastbar(frame)
		frame.Castbar.Holder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -3, -6)

		frame.Name = self:CreateName(frame, frame.TextParent)

		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, frame.TextParent)

		frame.ThreatIndicator = self:CreateThreatIndicator(frame)

		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, frame.TextParent)

		frame.ClassIndicator = self:CreateClassIndicator(frame)

		frame.CustomTexts = self:CreateCustomTexts(frame, frame.TextParent)

		frame.Update = frame_Update
	end
end
