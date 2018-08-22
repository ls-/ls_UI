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
			self:UpdateCombatFeedback()
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
			-- 7: frame.LeftTube, frame.RightTube
			-- 8: frame.TextureParent
			-- 9: frame.TextParent
			-- 10: frame.FloatingCombatFeedback

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
		local leftTube = CreateFrame("Frame", nil, frame)
		leftTube:SetFrameLevel(level + 6)
		leftTube:SetSize(12, 128)
		leftTube:SetPoint("LEFT", 23, 0)
		frame.LeftTube = leftTube

		E:SetStatusBarSkin(leftTube, "VERTICAL-12")

		local seps = {}

		for i = 1, 9 do
			local sep = leftTube:CreateTexture(nil, "ARTWORK", nil, 1)
			sep:SetSize(12, 12)
			sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
			sep:SetTexCoord(0.03125, 3, 0.78125, 3, 0.03125, 0, 0.78125, 0)
			seps[i] = sep
		end

		leftTube.Refresh = function(self, sender, visible, slots)
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

		leftTube:Refresh(nil, false, 0)

		-- power tube
		local rightTube = CreateFrame("Frame", nil, frame)
		rightTube:SetFrameLevel(level + 6)
		rightTube:SetSize(12, 128)
		rightTube:SetPoint("RIGHT", -23, 0)
		frame.RightTube = rightTube

		E:SetStatusBarSkin(rightTube, "VERTICAL-12")

		-- mask
		local mask = textureParent:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetSize(312 / 2, 312 / 2)
		mask:SetPoint("CENTER")

		-- health
		local health = self:CreateHealth(frame, true, "LSFont16_Shadow", textParent)
		health:SetFrameLevel(level + 1)
		health:SetSize(180 / 2, 280 / 2)
		health:SetPoint("CENTER")
		health:SetClipsChildren(true)
		frame.Health = health

		-- health prediction
		local healthPrediction = self:CreateHealthPrediction(frame, health, true, "LSFont12_Shadow", textParent)
		frame.HealthPrediction = healthPrediction

		-- masking
		health._texture:AddMaskTexture(mask)
		healthPrediction.myBar._texture:AddMaskTexture(mask)
		healthPrediction.otherBar._texture:AddMaskTexture(mask)
		healthPrediction.absorbBar.Overlay:AddMaskTexture(mask)
		healthPrediction.healAbsorbBar._texture:AddMaskTexture(mask)

		-- power
		local power = self:CreatePower(frame, true, "LSFont14_Shadow", textParent)
		power:SetFrameLevel(level + 4)
		power:SetSize(12, 128)
		power:SetPoint("RIGHT", -23, 0)
		power:Hide()
		frame.Power = power

		power:HookScript("OnHide", function()
			rightTube:Hide()
		end)
		power:HookScript("OnShow", function()
			rightTube:Show()
		end)

		-- additional power
		local addPower = self:CreateAdditionalPower(frame)
		addPower:SetFrameLevel(level + 4)
		addPower:SetSize(12, 128)
		addPower:SetPoint("LEFT", 23, 0)
		addPower:Hide()
		frame.AdditionalPower = addPower

		addPower:HookScript("OnHide", function(self)
			leftTube:Refresh(self, false, 0)
		end)

		addPower:HookScript("OnShow", function(self)
			leftTube:Refresh(self, true, 1)
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

			stagger:HookScript("OnHide", function(self)
				leftTube:Refresh(self, false, 0)
			end)
			stagger:HookScript("OnShow", function(self)
				leftTube:Refresh(self, true, 1)
			end)
		elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
			local runes = self:CreateRunes(frame)
			runes:SetFrameLevel(level + 4)
			runes:SetPoint("LEFT", 23, 0)
			runes:SetSize(12, 128)
			frame.Runes = runes

			runes:HookScript("OnHide", function(self)
				leftTube:Refresh(self, false, 0)
			end)
			runes:HookScript("OnShow", function(self)
				leftTube:Refresh(self, true, 6)
			end)
		end

		local classPower = self:CreateClassPower(frame)
		classPower:SetFrameLevel(level + 4)
		classPower:SetPoint("LEFT", 23, 0)
		classPower:SetSize(12, 128)
		frame.ClassPower = classPower

		classPower.UpdateContainer = function(self, isVisible, slots)
			leftTube:Refresh(self, isVisible, slots)
		end

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

		frame.Name = self:CreateName(frame, "LSFont12_Shadow", textParent)

		-- status icons/texts
		local status = textParent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
		status:SetWidth(24)
		status:SetPoint("LEFT", frame, "LEFT", 2, 0)
		status:SetNonSpaceWrap(true)

		frame:Tag(status, "[ls:leadericon][ls:lfdroleicon]")

		status = textParent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
		status:SetWidth(24)
		status:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
		status:SetNonSpaceWrap(true)

		frame:Tag(status, "[ls:combatresticon]")

		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, textParent)
		frame.DebuffIndicator:SetWidth(18)

		-- floating combat text
		local feeback = self:CreateCombatFeedback(frame)
		feeback:SetFrameLevel(level + 9)
		feeback:SetPoint("CENTER", 0, 0)
		frame.FloatingCombatFeedback = feeback

		-- threat
		local threat = self:CreateThreatIndicator(frame, borderParent, true)
		threat:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame-glow")
		threat:SetTexCoord(1 / 512, 337 / 512, 1 / 512, 337 / 512)
		threat:SetSize(336 / 2, 336 / 2)
		threat:SetPoint("CENTER", 0, 0)
		frame.ThreatIndicator = threat

		local shadow = borderParent:CreateTexture(nil, "BACKGROUND", nil, -1)
		shadow:SetAllPoints(health)
		shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
		shadow:AddMaskTexture(mask)

		self:CreateClassIndicator(frame)

		frame.Update = frame_Update
		frame.UpdateConfig = frame_UpdateConfig

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
			self:UpdateCombatFeedback()
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

		local seps = {}

		for i = 1, 9 do
			local sep = textureParent:CreateTexture(nil, "ARTWORK", nil, 1)
			sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
			seps[i] = sep
		end

		function frame.Insets.Top:Refresh(sender, visible, slots)
			if (slots == self._slots and visible == self._visible)
				or (not visible and sender ~= self._sender) then return end

			self._slots = slots
			self._visible = visible
			self._sender = sender

			if visible then
				self:Expand()

				for i = 1, 9 do
					local sep = seps[i]

					if i < slots then
						sep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, (self:GetHeight() - 2) / 4)
						sep:SetPoint("LEFT", sender[i], "RIGHT", -5, 0)
						sep:SetSize(24 / 2, self:GetHeight() - 2)
						sep:Show()
					else
						sep:Hide()
					end
				end
			else
				self:Collapse()

				for i = 1, 9 do
					seps[i]:Hide()
				end
			end
		end

		-- health
		local health = self:CreateHealth(frame, true, "LSFont12_Shadow", textParent)
		health:SetFrameLevel(level + 1)
		health:SetPoint("LEFT", frame, "LEFT", 0, 0)
		health:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
		health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
		health:SetClipsChildren(true)
		frame.Health = health

		frame.HealthPrediction = self:CreateHealthPrediction(frame, health, true, "LSFont10_Shadow", textParent)

		-- power
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

		-- additional power
		local addPower = self:CreateAdditionalPower(frame)
		addPower:SetFrameLevel(level + 1)
		addPower:SetPoint("LEFT", frame, "LEFT", 0, 0)
		addPower:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		addPower:SetPoint("TOP", frame.Insets.Top, "TOP", 0, 0)
		addPower:SetPoint("BOTTOM", frame.Insets.Top, "BOTTOM", 0, 2)
		frame.AdditionalPower = addPower

		addPower:HookScript("OnHide", function(self)
			frame.Insets.Top:Refresh(self, false, 0)
		end)

		addPower:HookScript("OnShow", function(self)
			frame.Insets.Top:Refresh(self, true, 1)
		end)

		-- power cost prediction
		frame.PowerPrediction = self:CreatePowerPrediction(frame, power, addPower)

		-- class power
		if E.PLAYER_CLASS == "MONK" then
			local stagger = self:CreateStagger(frame)
			stagger:SetFrameLevel(level + 1)
			stagger:SetPoint("LEFT", frame, "LEFT", 0, 0)
			stagger:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
			stagger:SetPoint("TOP", frame.Insets.Top, "TOP", 0, 0)
			stagger:SetPoint("BOTTOM", frame.Insets.Top, "BOTTOM", 0, 2)
			frame.Stagger = stagger

			stagger:HookScript("OnHide", function(self)
				frame.Insets.Top:Refresh(self, false, 0)
			end)
			stagger:HookScript("OnShow", function(self)
				frame.Insets.Top:Refresh(self, true, 1)
			end)
		elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
			local runes = self:CreateRunes(frame)
			runes:SetFrameLevel(level + 1)
			runes:SetPoint("LEFT", frame, "LEFT", 0, 0)
			runes:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
			runes:SetPoint("TOP", frame.Insets.Top, "TOP", 0, 0)
			runes:SetPoint("BOTTOM", frame.Insets.Top, "BOTTOM", 0, 2)
			frame.Runes = runes

			runes:HookScript("OnHide", function(self)
				frame.Insets.Top:Refresh(self, false, 0)
			end)
			runes:HookScript("OnShow", function(self)
				frame.Insets.Top:Refresh(self, true, 6)
			end)
		end

		local classPower = self:CreateClassPower(frame)
		classPower:SetFrameLevel(level + 1)
		classPower:SetPoint("LEFT", frame, "LEFT", 0, 0)
		classPower:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		classPower:SetPoint("TOP", frame.Insets.Top, "TOP", 0, 0)
		classPower:SetPoint("BOTTOM", frame.Insets.Top, "BOTTOM", 0, 2)
		frame.ClassPower = classPower

		classPower.UpdateContainer = function(self, isVisible, slots)
			frame.Insets.Top:Refresh(self, isVisible, slots)
		end

		-- castbar
		frame.Castbar = self:CreateCastbar(frame)
		-- frame.Castbar.Holder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -3, -6)

		frame.Name = self:CreateName(frame, "LSFont12_Shadow", textParent)

		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, textParent)

		-- pvp indicator
		local pvp = self:CreatePvPIndicator(frame, textureParent)
		frame.PvPIndicator = pvp

		pvp.Holder.PostExpand = function()
			if not frame._config.castbar.detached then
				frame.Castbar.Holder:SetWidth(frame.Castbar.Holder._width - 52)
			end
		end

		pvp.Holder.PostCollapse = function()
			if not frame._config.castbar.detached then
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

		-- floating combat text
		local feeback = self:CreateCombatFeedback(frame)
		feeback:SetFrameLevel(level + 9)
		feeback:SetPoint("CENTER", 0, 0)
		frame.FloatingCombatFeedback = feeback

		local status = textParent:CreateFontString(nil, "ARTWORK", "LSStatusIcon16Font")
		status:SetJustifyH("RIGHT")
		status:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, -1)
		frame:Tag(status, "[ls:combatresticon][ls:leadericon][ls:lfdroleicon]")

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

		isInit = true
	end
end
