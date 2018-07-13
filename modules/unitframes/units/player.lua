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
		if self._config.enabled then
			if not self:IsEnabled() then
				self:Enable()
			end

			self:UpdateConfig()
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
		else
			if self:IsEnabled() then
				self:Disable()
			end
		end
	end

	function UF:CreateVerticalPlayerFrame(frame)
		local level = frame:GetFrameLevel()

		frame._config = C.db.profile.units[E.UI_LAYOUT].player
		frame._unit = "player"

		-- Note: can't touch this
		-- 1: frame
			-- 2: frame.Health
				-- 3: frame.HealthPrediction
			-- 2: frame.AdditionalPower
				-- 3: frame.PowerPrediction.altBar
			-- 4: border_parent
			-- 5: frame.Power
				-- 6: frame.PowerPrediction.mainBar
			-- 5: frame.Stagger, frame.Runes, frame.ClassIcons
			-- 7: frame.LeftTube, frame.RightTube
			-- 8: frame.FGParent
			-- 9: frame.TextParent
			-- 10: frame.FloatingCombatFeedback

		-- bg
		local texture = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(667 / 1024, 999 / 1024, 1 / 512, 333 / 512)

		-- border
		local border_parent = CreateFrame("Frame", nil, frame)
		border_parent:SetFrameLevel(level + 3)
		border_parent:SetAllPoints()
		frame.BorderParent = border_parent

		texture = border_parent:CreateTexture(nil, "BACKGROUND")
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(1 / 1024, 333 / 1024, 1 / 512, 333 / 512)

		-- fg
		local fg_parent = CreateFrame("Frame", nil, frame)
		fg_parent:SetFrameLevel(level + 7)
		fg_parent:SetAllPoints()
		frame.FGParent = fg_parent

		texture = fg_parent:CreateTexture(nil, "ARTWORK", nil, 2)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame")
		texture:SetTexCoord(334 / 1024, 666 / 1024, 1 / 512, 333 / 512)

		-- text
		local text_parent = CreateFrame("Frame", nil, frame)
		text_parent:SetFrameLevel(level + 8)
		text_parent:SetAllPoints()
		frame.TextParent = text_parent

		-- class power tube
		local left_tube = CreateFrame("Frame", nil, frame)
		left_tube:SetFrameLevel(level + 6)
		left_tube:SetSize(12, 128)
		left_tube:SetPoint("LEFT", 23, 0)
		frame.LeftTube = left_tube

		E:SetStatusBarSkin(left_tube, "VERTICAL-12")

		local seps = {}

		for i = 1, 9 do
			local sep = left_tube:CreateTexture(nil, "ARTWORK", nil, 1)
			sep:SetSize(12, 12)
			sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
			sep:SetTexCoord(0.03125, 3, 0.78125, 3, 0.03125, 0, 0.78125, 0)
			seps[i] = sep
		end

		left_tube.Refresh = function(self, sender, visible, slots)
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

		left_tube:Refresh(nil, false, 0)

		-- power tube
		local right_tube = CreateFrame("Frame", nil, frame)
		right_tube:SetFrameLevel(level + 6)
		right_tube:SetSize(12, 128)
		right_tube:SetPoint("RIGHT", -23, 0)
		frame.RightTube = right_tube

		E:SetStatusBarSkin(right_tube, "VERTICAL-12")

		-- mask
		local mask = fg_parent:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetSize(312 / 2, 312 / 2)
		mask:SetPoint("CENTER")

		-- health
		local health = self:CreateHealth(frame, true, "LSFont16_Shadow", text_parent)
		health:SetFrameLevel(level + 1)
		health:SetSize(180 / 2, 280 / 2)
		health:SetPoint("CENTER")
		health:SetClipsChildren(true)
		frame.Health = health

		-- health prediction
		local health_prediction = self:CreateHealthPrediction(frame, health, true, "LSFont12_Shadow", text_parent)
		frame.HealthPrediction = health_prediction

		-- masking
		health._texture:AddMaskTexture(mask)
		health_prediction.myBar._texture:AddMaskTexture(mask)
		health_prediction.otherBar._texture:AddMaskTexture(mask)
		health_prediction.absorbBar.Overlay:AddMaskTexture(mask)
		health_prediction.healAbsorbBar._texture:AddMaskTexture(mask)

		-- power
		local power = self:CreatePower(frame, true, "LSFont14_Shadow", text_parent)
		power:SetFrameLevel(level + 4)
		power:SetSize(12, 128)
		power:SetPoint("RIGHT", -23, 0)
		power:Hide()
		frame.Power = power

		power:HookScript("OnHide", function()
			right_tube:Hide()
		end)
		power:HookScript("OnShow", function()
			right_tube:Show()
		end)

		-- additional power
		local add_power = self:CreateAdditionalPower(frame)
		add_power:SetFrameLevel(level + 4)
		add_power:SetSize(12, 128)
		add_power:SetPoint("LEFT", 23, 0)
		add_power:Hide()
		frame.AdditionalPower = add_power

		add_power:HookScript("OnHide", function(self)
			left_tube:Refresh(self, false, 0)
		end)

		add_power:HookScript("OnShow", function(self)
			left_tube:Refresh(self, true, 1)
		end)

		-- power cost prediction
		frame.PowerPrediction = self:CreatePowerPrediction(frame, power, add_power)

		-- class power
		if E.PLAYER_CLASS == "MONK" then
			local stagger = self:CreateStagger(frame)
			stagger:SetFrameLevel(level + 4)
			stagger:SetPoint("LEFT", 23, 0)
			stagger:SetSize(12, 128)
			frame.Stagger = stagger

			stagger:HookScript("OnHide", function(self)
				left_tube:Refresh(self, false, 0)
			end)
			stagger:HookScript("OnShow", function(self)
				left_tube:Refresh(self, true, 1)
			end)
		elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
			local runes = self:CreateRunes(frame)
			runes:SetFrameLevel(level + 4)
			runes:SetPoint("LEFT", 23, 0)
			runes:SetSize(12, 128)
			frame.Runes = runes

			runes:HookScript("OnHide", function(self)
				left_tube:Refresh(self, false, 0)
			end)
			runes:HookScript("OnShow", function(self)
				left_tube:Refresh(self, true, 6)
			end)
		end

		local class_power = self:CreateClassPower(frame)
		class_power:SetFrameLevel(level + 4)
		class_power:SetPoint("LEFT", 23, 0)
		class_power:SetSize(12, 128)
		frame.ClassPower = class_power

		class_power.UpdateContainer = function(self, isVisible, slots)
			left_tube:Refresh(self, isVisible, slots)
		end

		-- pvp
		frame.PvPIndicator = self:CreatePvPIndicator(frame, fg_parent)

		local pvp_timer = frame.PvPIndicator.Holder:CreateFontString(nil, "ARTWORK", "LSFont10_Outline")
		pvp_timer:SetPoint("TOPRIGHT", frame.PvPIndicator, "TOPRIGHT", 0, 0)
		pvp_timer:SetTextColor(1, 0.82, 0)
		pvp_timer:SetJustifyH("RIGHT")
		frame.PvPIndicator.Timer = pvp_timer

		-- raid target
		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, text_parent)

		-- castbar
		frame.Castbar = self:CreateCastbar(frame)

		frame.Name = self:CreateName(frame, "LSFont12_Shadow", text_parent)

		-- status icons/texts
		local status = text_parent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
		status:SetWidth(24)
		status:SetPoint("LEFT", frame, "LEFT", 2, 0)
		status:SetNonSpaceWrap(true)

		frame:Tag(status, "[ls:leadericon][ls:lfdroleicon]")

		status = text_parent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
		status:SetWidth(24)
		status:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
		status:SetNonSpaceWrap(true)

		frame:Tag(status, "[ls:combatresticon]")

		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, text_parent)
		frame.DebuffIndicator:SetWidth(18)

		-- floating combat text
		local feeback = self:CreateCombatFeedback(frame)
		feeback:SetFrameLevel(level + 9)
		feeback:SetPoint("CENTER", 0, 0)
		frame.FloatingCombatFeedback = feeback

		-- threat
		local threat = self:CreateThreatIndicator(frame, border_parent, true)
		threat:SetTexture("Interface\\AddOns\\ls_UI\\assets\\player-frame-glow")
		threat:SetTexCoord(1 / 512, 337 / 512, 1 / 512, 337 / 512)
		threat:SetSize(336 / 2, 336 / 2)
		threat:SetPoint("CENTER", 0, 0)
		frame.ThreatIndicator = threat

		frame.Update = frame_Update

		isInit = true
	end
end

do
	local function frame_Update(self)
		if self._config.enabled then
			if not self:IsEnabled() then
				self:Enable()
			end

			self:UpdateConfig()
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

		frame._config = C.db.profile.units[E.UI_LAYOUT].player
		frame._unit = "player"

		local bg = frame:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-bg", true)
		bg:SetHorizTile(true)

		local fg_parent = CreateFrame("Frame", nil, frame)
		fg_parent:SetFrameLevel(level + 7)
		fg_parent:SetAllPoints()
		frame.FGParent = fg_parent

		local text_parent = CreateFrame("Frame", nil, frame)
		text_parent:SetFrameLevel(level + 9)
		text_parent:SetAllPoints()
		frame.TextParent = text_parent

		frame.Insets = self:CreateInsets(frame, fg_parent)

		local seps = {}

		for i = 1, 9 do
			local sep = fg_parent:CreateTexture(nil, "ARTWORK", nil, 1)
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
		local health = self:CreateHealth(frame, true, "LSFont12_Shadow", text_parent)
		health:SetFrameLevel(level + 1)
		health:SetPoint("LEFT", frame, "LEFT", 0, 0)
		health:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
		health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
		health:SetClipsChildren(true)
		frame.Health = health

		frame.HealthPrediction = self:CreateHealthPrediction(frame, health, true, "LSFont10_Shadow", text_parent)

		-- power
		local power = self:CreatePower(frame, true, "LSFont12_Shadow", text_parent)
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
		local add_power = self:CreateAdditionalPower(frame)
		add_power:SetFrameLevel(level + 1)
		add_power:SetPoint("LEFT", frame, "LEFT", 0, 0)
		add_power:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		add_power:SetPoint("TOP", frame.Insets.Top, "TOP", 0, 0)
		add_power:SetPoint("BOTTOM", frame.Insets.Top, "BOTTOM", 0, 2)
		frame.AdditionalPower = add_power

		add_power:HookScript("OnHide", function(self)
			frame.Insets.Top:Refresh(self, false, 0)
		end)

		add_power:HookScript("OnShow", function(self)
			frame.Insets.Top:Refresh(self, true, 1)
		end)

		-- power cost prediction
		frame.PowerPrediction = self:CreatePowerPrediction(frame, power, add_power)

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

		local class_power = self:CreateClassPower(frame)
		class_power:SetFrameLevel(level + 1)
		class_power:SetPoint("LEFT", frame, "LEFT", 0, 0)
		class_power:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
		class_power:SetPoint("TOP", frame.Insets.Top, "TOP", 0, 0)
		class_power:SetPoint("BOTTOM", frame.Insets.Top, "BOTTOM", 0, 2)
		frame.ClassPower = class_power

		class_power.UpdateContainer = function(self, isVisible, slots)
			frame.Insets.Top:Refresh(self, isVisible, slots)
		end

		-- castbar
		frame.Castbar = self:CreateCastbar(frame)
		-- frame.Castbar.Holder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -3, -6)

		frame.Name = self:CreateName(frame, "LSFont12_Shadow", text_parent)

		frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, text_parent)

		-- pvp indicator
		local pvp = self:CreatePvPIndicator(frame, fg_parent)
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

		local pvp_timer = pvp.Holder:CreateFontString(nil, "ARTWORK", "LSFont10_Outline")
		pvp_timer:SetPoint("TOPRIGHT", pvp, "TOPRIGHT", 0, 0)
		pvp_timer:SetTextColor(1, 0.82, 0)
		pvp_timer:SetJustifyH("RIGHT")
		pvp_timer.frequentUpdates = 0.1

		-- debuff indicator
		frame.DebuffIndicator = self:CreateDebuffIndicator(frame, text_parent)

		-- threat
		frame.ThreatIndicator = self:CreateThreatIndicator(frame)

		-- auras
		frame.Auras = self:CreateAuras(frame, "player")

		-- floating combat text
		local feeback = self:CreateCombatFeedback(frame)
		feeback:SetFrameLevel(level + 9)
		feeback:SetPoint("CENTER", 0, 0)
		frame.FloatingCombatFeedback = feeback

		local status = text_parent:CreateFontString(nil, "ARTWORK", "LSStatusIcon16Font")
		status:SetJustifyH("RIGHT")
		status:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, -1)
		frame:Tag(status, "[ls:combatresticon][ls:leadericon][ls:lfdroleicon]")

		local border = E:CreateBorder(fg_parent)
		border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
		border:SetSize(16)
		border:SetOffset(-6)
		frame.Border = border

		local glass = fg_parent:CreateTexture(nil, "OVERLAY", nil, 0)
		glass:SetAllPoints(health)
		glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")

		local shadow = fg_parent:CreateTexture(nil, "OVERLAY", nil, -1)
		shadow:SetAllPoints(health)
		shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")

		self:CreateClassIndicator(frame)

		frame.Update = frame_Update

		isInit = true
	end
end
