local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local isInit = false

function UF:HasPlayerFrame()
	return isInit
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
			self:UpdateName()
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

	function UF:CreateVerticalPlayerFrame(frame)
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

		local texture = borderParent:CreateTexture(nil, "BACKGROUND")
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

		-- for i = 1, 9 do
		-- 	local sep = leftSlot:CreateTexture(nil, "ARTWORK", nil, 1)
		-- 	sep:SetSize(12, 12)
		-- 	sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
		-- 	sep:SetTexCoord(0.03125, 3, 0.78125, 3, 0.03125, 0, 0.78125, 0)
		-- 	seps[i] = sep
		-- end

		-- leftSlot.Refresh = function(self, sender, visible, slots)
		-- 	if (slots == self._slots and visible == self._visible)
		-- 		or (not visible and sender ~= self._sender) then return end

		-- 	self._slots = slots
		-- 	self._visible = visible
		-- 	self._sender = sender

		-- 	if visible then
		-- 		self:Show()

		-- 		for i = 1, 9 do
		-- 			if i < slots then
		-- 				seps[i]:SetPoint("BOTTOM", sender[i], "TOP", 0, -5)
		-- 				seps[i]:Show()
		-- 			else
		-- 				seps[i]:Hide()
		-- 			end
		-- 		end
		-- 	else
		-- 		self:Hide()

		-- 		for i = 1, 9 do
		-- 			seps[i]:Hide()
		-- 		end
		-- 	end
		-- end

		local health = self:CreateHealth(frame, textParent)
		health:SetFrameLevel(level + 1)
		health:SetSize(180 / 2, 280 / 2)
		health:SetPoint("CENTER")
		health:SetClipsChildren(true)
		frame.Health = health

		local healthPrediction = self:CreateHealthPrediction(frame, health, textParent)
		frame.HealthPrediction = healthPrediction

		local rightSlot = UF:CreateSlot(frame, level + 6)
		rightSlot:SetPoint("RIGHT", -23, 0)
		rightSlot:UpdateSize(12, 128)
		E:SetStatusBarSkin(rightSlot, "VERTICAL-12")
		frame.PowerSlot = rightSlot

		local power = self:CreatePower(frame, textParent)
		power:SetFrameLevel(level + 4)
		power:Hide()
		frame.Power = power

		rightSlot:Capture(power)

		local leftSlot = UF:CreateSlot(frame, level + 6)
		leftSlot:SetPoint("LEFT", 23, 0)
		leftSlot:UpdateSize(12, 128)
		E:SetStatusBarSkin(leftSlot, "VERTICAL-12")
		frame.ClassPowerSlot = leftSlot

		local addPower = self:CreateAdditionalPower(frame)
		addPower:SetFrameLevel(level + 4)
		addPower:Hide()
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

		frame.Name = self:CreateName(frame, textParent)

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

		frame.Update = frame_Update

		isInit = true
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

			self.Power:SetWidth(self._config.width)
			self:UpdatePower()

			self.AdditionalPower:SetWidth(self._config.width)
			self:UpdateAdditionalPower()
			self:UpdatePowerPrediction()

			self.ClassPower:SetWidth(self._config.width)
			self:UpdateClassPower()

			if self.Runes then
				self.Runes:SetWidth(self._config.width)
				self:UpdateRunes()
			end

			if self.Stagger then
				self.Stagger:SetWidth(self._config.width)
				self:UpdateStagger()
			end

			self:UpdateCastbar()
			self:UpdateName()
			self:UpdateRaidTargetIndicator()
			self:UpdatePvPIndicator()
			self:UpdateDebuffIndicator()
			self:UpdateThreatIndicator()
			self:UpdateAuras()
			self:UpdateClassIndicator()
			self:UpdateCustomTexts()
		else
			if self:IsEnabled() then
				self:Disable()
			end
		end
	end

	function UF:CreateHorizontalPlayerFrame(frame)
		local level = frame:GetFrameLevel()

		-- .TextureParent
		-- .TextParent
		-- .Insets
		-- .Border
		self:CreateLayout(frame, level)

		-- health
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

		-- power
		local power = self:CreatePower(frame, frame.TextParent)
		power:SetFrameLevel(level + 1)
		frame.Power = power

		frame.Insets.Bottom:Capture(power, 0, 0, -2, 0)

		-- additional power
		local addPower = self:CreateAdditionalPower(frame)
		addPower:SetFrameLevel(level + 1)
		frame.AdditionalPower = addPower

		frame.Insets.Top:Capture(addPower, 0, 0, 0, 2)

		-- power cost prediction
		frame.PowerPrediction = self:CreatePowerPrediction(frame, power, addPower)

		-- class power
		if E.PLAYER_CLASS == "MONK" then
			local stagger = self:CreateStagger(frame)
			stagger:SetFrameLevel(level + 1)
			frame.Stagger = stagger

			frame.Insets.Top:Capture(stagger, 0, 0, 0, 2)
		elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
			local runes = self:CreateRunes(frame)
			runes:SetFrameLevel(level + 1)
			frame.Runes = runes

			frame.Insets.Top:Capture(runes, 0, 0, 0, 2)
		end

		local classPower = self:CreateClassPower(frame)
		classPower:SetFrameLevel(level + 1)
		frame.ClassPower = classPower

		frame.Insets.Top:Capture(classPower, 0, 0, 0, 2)

		frame.Name = self:CreateName(frame, frame.TextParent)

		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, frame.TextParent)

		local leftslot = UF:CreateSlot(frame, level)
		leftslot:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 10)
		leftslot:UpdateSize(50, 54) -- pvp holder size
		frame.PvPSlot = leftslot

		local pvp = self:CreatePvPIndicator(frame, frame.TextureParent)
		frame.PvPIndicator = pvp

		leftslot:Capture(pvp.Holder)

		local pvpTimer = pvp.Holder:CreateFontString(nil, "ARTWORK", "Game10Font_o1")
		pvpTimer:SetPoint("TOPRIGHT", pvp, "TOPRIGHT", 0, 0)
		pvpTimer:SetTextColor(1, 0.82, 0)
		pvpTimer:SetJustifyH("RIGHT")
		pvp.Timer = pvpTimer

		local rightSlot = UF:CreateSlot(frame, level)
		rightSlot:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -6)
		rightSlot:SetPoint("LEFT", leftslot, "RIGHT", 0, 0)
		rightSlot:UpdateSize(0, 12) -- default castbar height
		frame.CastbarSlot = rightSlot

		frame.Castbar = self:CreateCastbar(frame)

		-- debuff indicator
		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, frame.TextParent)

		-- threat
		frame.ThreatIndicator = self:CreateThreatIndicator(frame)

		-- auras
		frame.Auras = self:CreateAuras(frame, "player")

		local status = frame.TextParent:CreateFontString(nil, "ARTWORK")
		status:SetFont(GameFontNormal:GetFont(), 16)
		status:SetJustifyH("RIGHT")
		status:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, -1)
		frame:Tag(status, "[ls:combatresticon][ls:leadericon][ls:lfdroleicon]")

		frame.ClassIndicator = self:CreateClassIndicator(frame)

		frame.CustomTexts = self:CreateCustomTexts(frame, frame.TextParent)

		frame.Update = frame_Update

		isInit = true
	end
end
