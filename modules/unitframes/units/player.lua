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

		-- bg
		local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(667 / 1024, 999 / 1024, 1 / 512, 333 / 512)

		-- border
		local borderParent = CreateFrame("Frame", nil, frame)
		borderParent:SetFrameLevel(level + 3)
		borderParent:SetAllPoints()
		frame.BorderParent = borderParent

		texture = borderParent:CreateTexture(nil, "BACKGROUND")
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(1 / 1024, 333 / 1024, 1 / 512, 333 / 512)
		frame.Border = texture

		-- fg
		local textureParent = CreateFrame("Frame", nil, frame)
		textureParent:SetFrameLevel(level + 7)
		textureParent:SetAllPoints()
		frame.TextureParent = textureParent

		texture = textureParent:CreateTexture(nil, "ARTWORK", nil, 2)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(334 / 1024, 666 / 1024, 1 / 512, 333 / 512)

		-- text
		local textParent = CreateFrame("Frame", nil, frame)
		textParent:SetFrameLevel(level + 8)
		textParent:SetAllPoints()
		frame.TextParent = textParent

		-- class power tube
		local leftSlot = CreateFrame("Frame", nil, frame)
		leftSlot:SetFrameLevel(level + 6)
		leftSlot:SetSize(12, 128)
		leftSlot:SetPoint("LEFT", 23, 0)
		frame.LeftSlot = leftSlot

		E:SetStatusBarSkin(leftSlot, "VERTICAL-12")

		local seps = {}

		for i = 1, 9 do
			local sep = leftSlot:CreateTexture(nil, "ARTWORK", nil, 1)
			sep:SetSize(12, 12)
			sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
			sep:SetTexCoord(0.03125, 3, 0.78125, 3, 0.03125, 0, 0.78125, 0)
			seps[i] = sep
		end

		leftSlot.Refresh = function(self, sender, visible, slots)
			if (slots == self._slots and visible == self._visible)
				or (not visible and sender ~= self._sender) then return end

			self._slots = slots
			self._visible = visible
			self._sender = sender

			if visible then
				self:Show()

				for i = 1, 9 do
					if i < slots then
						seps[i]:SetPoint("BOTTOM", sender[i], "TOP", 0, -5)
						seps[i]:Show()
					else
						seps[i]:Hide()
					end
				end
			else
				self:Hide()

				for i = 1, 9 do
					seps[i]:Hide()
				end
			end
		end

		leftSlot:Refresh(nil, false, 0)

		-- power tube
		local rightSlot = CreateFrame("Frame", nil, frame)
		rightSlot:SetFrameLevel(level + 6)
		rightSlot:SetSize(12, 128)
		rightSlot:SetPoint("RIGHT", -23, 0)
		frame.RightSlot = rightSlot

		E:SetStatusBarSkin(rightSlot, "VERTICAL-12")

		-- mask
		local mask = textureParent:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetSize(312 / 2, 312 / 2)
		mask:SetPoint("CENTER")

		-- health
		local health = self:CreateHealth(frame, textParent)
		health:SetFrameLevel(level + 1)
		health:SetSize(180 / 2, 280 / 2)
		health:SetPoint("CENTER")
		health:SetClipsChildren(true)
		frame.Health = health

		-- health prediction
		local healthPrediction = self:CreateHealthPrediction(frame, health, textParent)
		frame.HealthPrediction = healthPrediction

		-- masking
		health._texture:AddMaskTexture(mask)
		healthPrediction.myBar._texture:AddMaskTexture(mask)
		healthPrediction.otherBar._texture:AddMaskTexture(mask)
		healthPrediction.absorbBar.Overlay:AddMaskTexture(mask)
		healthPrediction.healAbsorbBar._texture:AddMaskTexture(mask)
		health.GainLossIndicators.Loss:AddMaskTexture(mask)

		-- power
		local power = self:CreatePower(frame, textParent)
		power:SetFrameLevel(level + 4)
		power:SetSize(12, 128)
		power:SetPoint("RIGHT", -23, 0)
		power:Hide()
		frame.Power = power

		hooksecurefunc(power, "Hide", function()
			rightSlot:Hide()
		end)
		hooksecurefunc(power, "Show", function()
			rightSlot:Show()
		end)

		-- additional power
		local addPower = self:CreateAdditionalPower(frame)
		addPower:SetFrameLevel(level + 4)
		addPower:SetSize(12, 128)
		addPower:SetPoint("LEFT", 23, 0)
		addPower:Hide()
		frame.AdditionalPower = addPower

		hooksecurefunc(addPower, "Hide", function(self)
			leftSlot:Refresh(self, false, 0)
		end)
		hooksecurefunc(addPower, "Show", function(self)
			leftSlot:Refresh(self, true, 1)
		end)

		-- power cost prediction
		frame.PowerPrediction = self:CreatePowerPrediction(frame, power, addPower)

		-- class power
		if E.PLAYER_CLASS == "MONK" then
			local stagger = self:CreateStagger(frame)
			stagger:SetFrameLevel(level + 4)
			stagger:SetPoint("LEFT", 23, 0)
			stagger:SetSize(12, 128)
			frame.Stagger = stagger

			hooksecurefunc(stagger, "Hide", function(self)
				leftSlot:Refresh(self, false, 0)
			end)
			hooksecurefunc(stagger, "Show", function(self)
				leftSlot:Refresh(self, true, 1)
			end)
		elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
			local runes = self:CreateRunes(frame)
			runes:SetFrameLevel(level + 4)
			runes:SetPoint("LEFT", 23, 0)
			runes:SetSize(12, 128)
			frame.Runes = runes

			hooksecurefunc(runes, "Hide", function(self)
				leftSlot:Refresh(self, false, 0)
			end)
			hooksecurefunc(runes, "Show", function(self)
				leftSlot:Refresh(self, true, 6)
			end)
		end

		local classPower = self:CreateClassPower(frame)
		classPower:SetFrameLevel(level + 4)
		classPower:SetPoint("LEFT", 23, 0)
		classPower:SetSize(12, 128)
		frame.ClassPower = classPower

		hooksecurefunc(classPower, "Hide", function(self)
			leftSlot:Refresh(self, false, 0)
		end)
		hooksecurefunc(classPower, "Show", function(self)
			leftSlot:Refresh(self, true, self.__max)
		end)

		-- pvp
		frame.PvPIndicator = self:CreatePvPIndicator(frame, textureParent)

		local pvpTimer = frame.PvPIndicator.Holder:CreateFontString(nil, "ARTWORK", "LSFont10_Outline")
		pvpTimer:SetPoint("TOPRIGHT", frame.PvPIndicator, "TOPRIGHT", 0, 0)
		pvpTimer:SetTextColor(1, 0.82, 0)
		pvpTimer:SetJustifyH("RIGHT")
		frame.PvPIndicator.Timer = pvpTimer

		-- raid target
		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, textParent)

		-- castbar
		frame.Castbar = self:CreateCastbar(frame)

		frame.Name = self:CreateName(frame, textParent)

		-- status icons/texts
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

		-- threat
		local threat = self:CreateThreatIndicator(frame, borderParent, true)
		threat:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame-glow")
		threat:SetTexCoord(1 / 512, 337 / 512, 1 / 512, 337 / 512)
		threat:SetSize(336 / 2, 336 / 2)
		threat:SetPoint("CENTER", 0, 0)
		frame.ThreatIndicator = threat

		frame.ClassIndicator = self:CreateClassIndicator(frame)

		local shadow = borderParent:CreateTexture(nil, "BACKGROUND", nil, -1)
		shadow:SetAllPoints(health)
		shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
		shadow:AddMaskTexture(mask)

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
			self:UpdateInsets()
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
		else
			if self:IsEnabled() then
				self:Disable()
			end
		end
	end

	function UF:CreateHorizontalPlayerFrame(frame)
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

		function frame.Insets.Top:Refresh(sender, visible, slots)
			if (slots == self._slots and visible == self._visible)
				or (not visible and sender ~= self._sender) then return end

			self._slots = slots
			self._visible = visible
			self._sender = sender

			if visible then
				self:Expand()

				for i = 1, 9 do
					if i < slots then
						self.Seps[i]:SetPoint("LEFT", sender[i], "RIGHT", -5, 0)
						self.Seps[i]:Show()
					else
						self.Seps[i]:Hide()
					end
				end
			else
				self:Collapse()
			end
		end

		frame.Insets.Top:Refresh(nil, false, 0)

		-- health
		local health = self:CreateHealth(frame, textParent)
		health:SetFrameLevel(level + 1)
		health:SetPoint("LEFT", frame.Insets.Left, "RIGHT", 0, 0)
		health:SetPoint("RIGHT", frame.Insets.Right, "LEFT", 0, 0)
		health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
		health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
		health:SetClipsChildren(true)
		frame.Health = health

		frame.HealthPrediction = self:CreateHealthPrediction(frame, health, textParent)

		frame.Portrait = self:CreatePortrait(frame)

		-- power
		local power = self:CreatePower(frame, textParent)
		power:SetFrameLevel(level + 1)
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

		frame.Insets.Bottom:Capture(power, 0, 0, -2, 0)

		-- additional power
		local addPower = self:CreateAdditionalPower(frame)
		addPower:SetFrameLevel(level + 1)
		frame.AdditionalPower = addPower

		addPower:HookScript("OnHide", function(self)
			frame.Insets.Top:Refresh(self, false, 0)
		end)
		addPower:HookScript("OnShow", function(self)
			frame.Insets.Top:Refresh(self, true, 1)
		end)

		frame.Insets.Top:Capture(addPower, 0, 0, 0, 2)

		-- power cost prediction
		frame.PowerPrediction = self:CreatePowerPrediction(frame, power, addPower)

		-- class power
		if E.PLAYER_CLASS == "MONK" then
			local stagger = self:CreateStagger(frame)
			stagger:SetFrameLevel(level + 1)
			frame.Stagger = stagger

			stagger:HookScript("OnHide", function(self)
				frame.Insets.Top:Refresh(self, false, 0)
			end)
			stagger:HookScript("OnShow", function(self)
				frame.Insets.Top:Refresh(self, true, 1)
			end)

			frame.Insets.Top:Capture(stagger, 0, 0, 0, 2)
		elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
			local runes = self:CreateRunes(frame)
			runes:SetFrameLevel(level + 1)
			frame.Runes = runes

			runes:HookScript("OnHide", function(self)
				frame.Insets.Top:Refresh(self, false, 0)
			end)
			runes:HookScript("OnShow", function(self)
				frame.Insets.Top:Refresh(self, true, 6)
			end)

			frame.Insets.Top:Capture(runes, 0, 0, 0, 2)
		end

		local classPower = self:CreateClassPower(frame)
		classPower:SetFrameLevel(level + 1)
		frame.ClassPower = classPower

		classPower:HookScript("OnHide", function(self)
			frame.Insets.Top:Refresh(self, false, 0)
		end)
		classPower:HookScript("OnShow", function(self)
			frame.Insets.Top:Refresh(self, true, self.__max)
		end)

		frame.Insets.Top:Capture(classPower, 0, 0, 0, 2)

		-- castbar
		frame.Castbar = self:CreateCastbar(frame)

		frame.Name = self:CreateName(frame, textParent)

		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, textParent)

		-- pvp indicator
		local pvp = self:CreatePvPIndicator(frame, textureParent)
		frame.PvPIndicator = pvp

		pvp.Holder.PostExpand = function()
			if not frame.Castbar._config.detached then
				frame.Castbar.Holder:SetWidth(frame.Castbar.Holder._width - 52)
			end
		end

		pvp.Holder.PostCollapse = function()
			if not frame.Castbar._config.detached then
				frame.Castbar.Holder:SetWidth(frame.Castbar.Holder._width)
			end
		end

		local pvpTimer = pvp.Holder:CreateFontString(nil, "ARTWORK", "LSFont10_Outline")
		pvpTimer:SetPoint("TOPRIGHT", pvp, "TOPRIGHT", 0, 0)
		pvpTimer:SetTextColor(1, 0.82, 0)
		pvpTimer:SetJustifyH("RIGHT")
		pvpTimer.frequentUpdates = 0.1

		-- debuff indicator
		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, textParent)

		-- threat
		frame.ThreatIndicator = self:CreateThreatIndicator(frame)

		-- auras
		frame.Auras = self:CreateAuras(frame, "player")

		local status = textParent:CreateFontString(nil, "ARTWORK")
		status:SetFont(GameFontNormal:GetFont(), 16)
		status:SetJustifyH("RIGHT")
		status:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, -1)
		frame:Tag(status, "[ls:combatresticon][ls:leadericon][ls:lfdroleicon]")

		local border = E:CreateBorder(textureParent)
		border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
		border:SetOffset(-6)
		frame.Border = border

		frame.ClassIndicator = self:CreateClassIndicator(frame)

		local glass = textureParent:CreateTexture(nil, "OVERLAY", nil, 0)
		glass:SetAllPoints(health)
		glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")

		local shadow = textureParent:CreateTexture(nil, "OVERLAY", nil, -1)
		shadow:SetAllPoints(health)
		shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")

		frame.Update = frame_Update

		isInit = true
	end
end
