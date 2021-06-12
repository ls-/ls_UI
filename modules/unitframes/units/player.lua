local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function UF:HasPlayerFrame()
	return isInit
end

do
	local frame_proto = {}

	function frame_proto:Update()
		self:UpdateConfig()

		if self._config.enabled then
			if not self:IsEnabled() then
				self:Enable()
			end

			self:UpdateSize()
			self:UpdateFading()
			self:UpdateInlay()
			self:UpdateHealth()
			self:UpdateHealthPrediction()
			self:UpdatePower()
			self:UpdateAdditionalPower()
			self:UpdatePowerPrediction()
			self:UpdateClassPower()

			if self.Runes then
				self:UpdateRunes()
			end

			if self.Stagger then
				self:UpdateStagger()
			end

			self:UpdateCastbar()
			self:UpdateRaidTargetIndicator()
			self:UpdatePvPIndicator()
			self:UpdateDebuffIndicator()
			self:UpdateThreatIndicator()
			self:UpdateClassIndicator()
			self:UpdateCustomTexts()
		else
			if self:IsEnabled() then
				self:Disable()
			end
		end
	end

	function frame_proto:UpdateInlay()
		self.Inlay:SetAlpha(C.db.profile.units.inlay.alpha)
	end

	function UF:CreateVerticalPlayerFrame(frame)
		P:Mixin(frame, frame_proto)

		E:SetUpFading(frame)

		local level = frame:GetFrameLevel()

		-- Note: can't touch this
		-- 1: frame
			-- 2: frame.Health
				-- 3: frame.HealthPrediction
			-- 2: frame.AdditionalPower
				-- 3: frame.PowerPrediction.altBar
			-- 4: borderParent
			-- 5: frame.Power
				-- 6: frame.PowerPrediction.mainBar
			-- 5: frame.Stagger, frame.Runes, frame.ClassIcons
			-- 7: frame.LeftSlot, frame.RightSlot
			-- 8: frame.TextureParent
			-- 9: frame.TextParent

		local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
		bg:SetAllPoints()
		bg:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
		bg:SetHorizTile(true)
		bg:SetVertTile(true)

		local borderParent = CreateFrame("Frame", nil, frame)
		borderParent:SetFrameLevel(level + 3)
		borderParent:SetAllPoints()
		frame.BorderParent = borderParent

		local texture = borderParent:CreateTexture(nil, "BACKGROUND", nil, -7)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(667 / 1024, 999 / 1024, 1 / 512, 333 / 512)
		frame.Inlay = texture

		texture = borderParent:CreateTexture(nil, "BACKGROUND", nil, -6)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(1 / 1024, 333 / 1024, 1 / 512, 333 / 512)
		frame.Border = texture

		local textureParent = CreateFrame("Frame", nil, frame)
		textureParent:SetFrameLevel(level + 7)
		textureParent:SetAllPoints()
		frame.TextureParent = textureParent

		texture = textureParent:CreateTexture(nil, "ARTWORK", nil, 2)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(334 / 1024, 666 / 1024, 1 / 512, 333 / 512)

		local textParent = CreateFrame("Frame", nil, frame)
		textParent:SetFrameLevel(level + 8)
		textParent:SetAllPoints()
		frame.TextParent = textParent

		local health = self:CreateHealth(frame, textParent)
		health:SetFrameLevel(level + 1)
		health:SetSize(180 / 2, 280 / 2)
		health:SetPoint("CENTER")
		health:SetClipsChildren(true)
		frame.Health = health

		local healthPrediction = self:CreateHealthPrediction(frame, health)
		frame.HealthPrediction = healthPrediction

		local rightSlot = UF:CreateSlot(frame, level + 6)
		rightSlot:SetPoint("RIGHT", -23, 0)
		rightSlot:UpdateSize(12, 128)
		E:SetStatusBarSkin(rightSlot, "VERTICAL-12")
		frame.PowerSlot = rightSlot

		local power = self:CreatePower(frame, textParent)
		power:SetFrameLevel(level + 4)
		frame.Power = power

		rightSlot:Capture(power)

		local leftSlot = UF:CreateSlot(frame, level + 6)
		leftSlot:SetPoint("LEFT", 23, 0)
		leftSlot:UpdateSize(12, 128)
		E:SetStatusBarSkin(leftSlot, "VERTICAL-12")
		frame.ClassPowerSlot = leftSlot

		local addPower = self:CreateAdditionalPower(frame)
		addPower:SetFrameLevel(level + 4)
		frame.AdditionalPower = addPower

		leftSlot:Capture(addPower)

		frame.PowerPrediction = self:CreatePowerPrediction(frame, power, addPower)

		if E.PLAYER_CLASS == "MONK" then
			local stagger = self:CreateStagger(frame)
			stagger:SetFrameLevel(level + 4)
			frame.Stagger = stagger

			leftSlot:Capture(stagger)
		elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
			local runes = self:CreateRunes(frame)
			runes:SetFrameLevel(level + 4)
			frame.Runes = runes

			leftSlot:Capture(runes)
		end

		local classPower = self:CreateClassPower(frame)
		classPower:SetFrameLevel(level + 4)
		frame.ClassPower = classPower

		leftSlot:Capture(classPower)

		local pvp = self:CreatePvPIndicator(frame, textureParent)
		pvp.Holder:SetPoint("TOP", frame, "BOTTOM", 0, 21)
		frame.PvPIndicator = pvp

		local pvpTimer = pvp.Holder:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
		pvpTimer:SetPoint("TOPRIGHT", pvp, "TOPRIGHT", 0, 0)
		pvpTimer:SetTextColor(1, 0.82, 0)
		pvpTimer:SetJustifyH("RIGHT")
		pvp.Timer = pvpTimer

		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, textParent)

		frame.Castbar = self:CreateCastbar(frame)

		local status = textParent:CreateFontString(nil, "OVERLAY")
		status:SetFont(GameFontNormal:GetFont(), 16)
		status:SetWidth(24)
		status:SetPoint("LEFT", frame, "LEFT", 2, 0)
		status:SetNonSpaceWrap(true)

		frame:Tag(status, "[ls:leadericon][ls:lfdroleicon]")

		status = textParent:CreateFontString(nil, "OVERLAY")
		status:SetFont(GameFontNormal:GetFont(), 16)
		status:SetWidth(24)
		status:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
		status:SetNonSpaceWrap(true)

		frame:Tag(status, "[ls:combatresticon]")

		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, textParent)
		frame.DebuffIndicator:SetWidth(18)

		local threat = self:CreateThreatIndicator(frame, borderParent, true)
		threat:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame-glow")
		threat:SetTexCoord(1 / 512, 337 / 512, 1 / 512, 337 / 512)
		threat:SetSize(336 / 2, 336 / 2)
		threat:SetPoint("CENTER", 0, 0)
		frame.ThreatIndicator = threat

		frame.ClassIndicator = self:CreateClassIndicator(frame)

		frame.CustomTexts = self:CreateCustomTexts(frame, textParent)

		local mask = textureParent:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetSize(288 / 2, 288 / 2)
		mask:SetPoint("CENTER")

		bg:AddMaskTexture(mask)
		health._texture:AddMaskTexture(mask)
		healthPrediction.myBar._texture:AddMaskTexture(mask)
		healthPrediction.otherBar._texture:AddMaskTexture(mask)
		healthPrediction.absorbBar._texture:AddMaskTexture(mask)
		healthPrediction.healAbsorbBar._texture:AddMaskTexture(mask)
		health.GainLossIndicators.Loss:AddMaskTexture(mask)

		isInit = true
	end
end

do
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

	function UF:CreateHorizontalPlayerFrame(frame)
		P:Mixin(self:CreateLargeFrame(frame), player_proto)

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
end
