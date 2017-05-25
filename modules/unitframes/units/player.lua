local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

-- Mine
function UF:ConstructVerticalPlayerFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.db.profile.units[E.UI_LAYOUT].player

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
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\player-frame")
	texture:SetTexCoord(667 / 1024, 999 / 1024, 1 / 512, 333 / 512)

	-- border
	local border_parent = _G.CreateFrame("Frame", nil, frame)
	border_parent:SetFrameLevel(level + 3)
	border_parent:SetAllPoints()
	frame.BorderParent = border_parent

	texture = border_parent:CreateTexture(nil, "BACKGROUND")
	texture:SetAllPoints()
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\player-frame")
	texture:SetTexCoord(1 / 1024, 333 / 1024, 1 / 512, 333 / 512)

	-- fg
	local fg_parent = _G.CreateFrame("Frame", nil, frame)
	fg_parent:SetFrameLevel(level + 7)
	fg_parent:SetAllPoints()
	frame.FGParent = fg_parent

	texture = fg_parent:CreateTexture(nil, "ARTWORK", nil, 2)
	texture:SetAllPoints()
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\player-frame")
	texture:SetTexCoord(334 / 1024, 666 / 1024, 1 / 512, 333 / 512)

	-- text
	local text_parent = _G.CreateFrame("Frame", nil, frame)
	text_parent:SetFrameLevel(level + 8)
	text_parent:SetAllPoints()
	frame.TextParent = text_parent

	-- class power tube
	local left_tube = _G.CreateFrame("Frame", nil, frame)
	left_tube:SetFrameLevel(level + 6)
	left_tube:SetSize(12, 128)
	left_tube:SetPoint("LEFT", 23, 0)
	frame.LeftTube = left_tube

	E:SetStatusBarSkin(left_tube, "VERTICAL-L")

	local seps = {}

	for i = 1, 9 do
		local sep = left_tube:CreateTexture(nil, "ARTWORK", nil, 1)
		sep:SetSize(24 / 2, 24 / 2)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
		sep:SetTexCoord(26 / 64, 50 / 64, 26 / 64, 50 / 64)
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
	local right_tube = _G.CreateFrame("Frame", nil, frame)
	right_tube:SetFrameLevel(level + 6)
	right_tube:SetSize(12, 128)
	right_tube:SetPoint("RIGHT", -23, 0)
	frame.RightTube = right_tube

	E:SetStatusBarSkin(right_tube, "VERTICAL-L")

	-- mask
	local mask = fg_parent:CreateMaskTexture()
	mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	mask:SetSize(312 / 2, 312 / 2)
	mask:SetPoint("CENTER")

	-- health
	local health = self:CreateHealth(frame, true, "LS16Font_Shadow", text_parent)
	health:SetFrameLevel(level + 1)
	health:SetSize(180 / 2, 280 / 2)
	health:SetPoint("CENTER")
	health:SetClipsChildren(true)
	frame.Health = health

	-- health prediction
	local health_prediction = self:CreateHealthPrediction(health, true, "LS12Font_Shadow", text_parent)
	frame.HealthPrediction = health_prediction

	-- masking
	health._texture:AddMaskTexture(mask)
	health_prediction.myBar._texture:AddMaskTexture(mask)
	health_prediction.otherBar._texture:AddMaskTexture(mask)
	health_prediction.absorbBar.Overlay:AddMaskTexture(mask)
	health_prediction.healAbsorbBar._texture:AddMaskTexture(mask)

	-- power
	local power = self:CreatePower(frame, true, "LS14Font_Shadow", text_parent)
	power:SetFrameLevel(level + 4)
	power:SetSize(12, 128)
	power:SetPoint("RIGHT", -23, 0)
	frame.Power = power

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
	frame.PowerPrediction = self:CreatePowerPrediction(power, add_power)

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
	frame.PvPIndicator = self:CreatePvPIndicator(fg_parent)

	local pvp_timer = frame.PvPIndicator.Holder:CreateFontString(nil, "ARTWORK", "LS10Font_Outline")
	pvp_timer:SetPoint("TOPRIGHT", frame.PvPIndicator, "TOPRIGHT", 0, 0)
	pvp_timer:SetTextColor(1, 0.82, 0)
	pvp_timer:SetJustifyH("RIGHT")
	pvp_timer.frequentUpdates = 0.1

	frame:Tag(pvp_timer, "[ls:pvptimer]")

	-- raid target
	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(text_parent)

	-- castbar
	frame.Castbar = self:CreateCastbar(frame)
	frame.Castbar.Holder:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 190)

	E:CreateMover(frame.Castbar.Holder)

	-- status icons/texts
	local status = text_parent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
	status:SetWidth(18)
	status:SetPoint("LEFT", frame, "LEFT", 5, 0)

	frame:Tag(status, "[ls:leadericon][ls:lfdroleicon]")

	status = text_parent:CreateFontString(nil, "OVERLAY", "LSStatusIcon16Font")
	status:SetWidth(18)
	status:SetPoint("RIGHT", frame, "RIGHT", -5, 0)

	frame:Tag(status, "[ls:combatresticon]")

	frame.DebuffIndicator = self:CreateDebuffIndicator(text_parent)
	frame.DebuffIndicator:SetWidth(14)

	-- floating combat text
	local feeback = self:CreateCombatFeedback(frame)
	feeback:SetFrameLevel(level + 9)
	feeback:SetPoint("CENTER", 0, 0)
	frame.FloatingCombatFeedback = feeback

	-- threat
	local threat = self:CreateThreatIndicator(border_parent, true)
	threat:SetTexture("Interface\\AddOns\\ls_UI\\media\\player-frame-glow")
	threat:SetTexCoord(1 / 512, 337 / 512, 1 / 512, 337 / 512)
	threat:SetSize(336 / 2, 336 / 2)
	threat:SetPoint("CENTER", 0, 0)
	frame.ThreatIndicator = threat

	-- totems
	do
		local TOTEM_LAYOUT = {
			[1] = {"TOP", -43, 20},
			[2] = {"TOP", -15, 30},
			[3] = {"TOP", 15, 30},
			[4] = {"TOP", 43, 20},
		}

		local function OnEnter(self)
			local quadrant = E:GetScreenQuadrant(self)
			local p, rP, sign = "BOTTOMLEFT", "CENTER", 1

			if quadrant == "TOPLEFT" or quadrant == "TOP" or quadrant == "TOPRIGHT" then
				p, sign = "TOPLEFT", -1
			end

			_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
			_G.GameTooltip:SetPoint(p, self, rP, 0, sign * 2)
			_G.GameTooltip:SetTotem(self.slot)
		end

		for i = 1, _G.MAX_TOTEMS do
			local totem = _G["TotemFrameTotem"..i]
			local iconFrame, border = totem:GetChildren()
			local background = _G["TotemFrameTotem"..i.."Background"]
			local duration = _G["TotemFrameTotem"..i.."Duration"]
			local icon = _G["TotemFrameTotem"..i.."IconTexture"]
			local cd = _G["TotemFrameTotem"..i.."IconCooldown"]

			E:ForceHide(background)
			E:ForceHide(border)
			E:ForceHide(duration)
			E:ForceHide(iconFrame)

			totem:SetParent(frame)
			totem:SetSize(72 / 2, 72 / 2)
			totem:ClearAllPoints()
			totem:SetPoint(unpack(TOTEM_LAYOUT[i]))
			totem:SetScript("OnEnter", OnEnter)

			border = totem:CreateTexture(nil, "OVERLAY")
			border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
			border:SetTexCoord(90 / 256, 162 / 256, 1 / 256, 73 / 256)
			border:SetAllPoints()

			icon:SetParent(totem)
			icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", 6, -6)
			icon:SetPoint("BOTTOMRIGHT", -6, 6)

			cd:SetParent(totem)
			cd:SetSwipeTexture("Interface\\PlayerFrame\\ClassOverlay-RuneCooldown")
			cd:SetReverse(false)
			cd:ClearAllPoints()
			cd:SetPoint("TOPLEFT", 6, -6)
			cd:SetPoint("BOTTOMRIGHT", -6, 6)

			E:HandleCooldown(cd, 10)

			if cd.Timer then
				cd.Timer:SetJustifyV("BOTTOM")
			end
		end
	end
end

function UF:ConstructHorizontalPlayerFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.db.profile.units[E.UI_LAYOUT].player

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-bg", true)
	bg:SetHorizTile(true)

	local fg_parent = _G.CreateFrame("Frame", nil, frame)
	fg_parent:SetFrameLevel(level + 7)
	fg_parent:SetAllPoints()
	frame.FGParent = fg_parent

	local text_parent = _G.CreateFrame("Frame", nil, frame)
	text_parent:SetFrameLevel(level + 9)
	text_parent:SetAllPoints()
	frame.TextParent = text_parent

	frame.Insets = self:CreateInsets(frame, fg_parent)

	local seps = {}

	for i = 1, 9 do
		local sep = fg_parent:CreateTexture(nil, "ARTWORK", nil, 1)
		sep:SetSize(24 / 2, 24 / 2)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
		sep:SetTexCoord(1 / 64, 25 / 64, 18 / 64, 42 / 64)
		seps[i] = sep
	end

	function frame.Insets.Top:Refresh(sender, visible, slots)
		if (slots == self._slots and visible == self._visible)
			or (not visible and sender ~= self._sender) then return end

		self._slots = slots
		self._visible = visible
		self._sender = sender

		if visible then
			local height = self._height

			self:Expand()

			for i = 1, 9 do
				local sep = seps[i]

				if i < slots then
					sep:SetSize(24 / 2, height - 2)

					if height == 14 then
						sep:SetTexCoord(1 / 64, 25 / 64, 18 / 64, 42 / 64)
					else
						sep:SetTexCoord(1 / 64, 25 / 64, 1 / 64, 17 / 64)
					end

					sep:SetPoint("LEFT", sender[i], "RIGHT", -5, 0)
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
	local health = self:CreateHealth(frame, true, "LS12Font_Shadow", text_parent)
	health:SetFrameLevel(level + 1)
	health:SetPoint("LEFT", frame, "LEFT", 0, 0)
	health:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
	health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	frame.HealthPrediction = self:CreateHealthPrediction(health, true, "LS10Font_Shadow", text_parent)

	-- -- damage absorb text
	-- local damage_absorb = text_parent:CreateFontString(nil, "ARTWORK", "LS10Font_Shadow")
	-- damage_absorb:SetWordWrap(false)
	-- damage_absorb:SetPoint("BOTTOMRIGHT", health, "RIGHT", -2, 1)

	-- E:ResetFontStringHeight(damage_absorb)

	-- frame:Tag(damage_absorb, "[ls:absorb:damage]")

	-- -- heal absorb text
	-- local heal_absorb = text_parent:CreateFontString(nil, "ARTWORK", "LS10Font_Shadow")
	-- heal_absorb:SetPoint("TOPRIGHT", health, "RIGHT", -2, -1)

	-- E:ResetFontStringHeight(heal_absorb)

	-- frame:Tag(heal_absorb, "[ls:absorb:heal]")

	-- power
	local power = self:CreatePower(frame, true, "LS12Font_Shadow", text_parent)
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
	frame.PowerPrediction = self:CreatePowerPrediction(power, add_power)

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

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(text_parent)

	-- pvp indicator
	local pvp = self:CreatePvPIndicator(fg_parent)
	frame.PvPIndicator = pvp

	pvp.Holder.PostExpand = function()
		local width = frame.Castbar.Holder._width - 48
		frame.Castbar.Holder._width = width

		frame.Castbar.Holder:SetWidth(width)
	end

	pvp.Holder.PostCollapse = function()
		local width = frame.Castbar.Holder._width + 48
		frame.Castbar.Holder._width = width

		frame.Castbar.Holder:SetWidth(width)
	end

	local pvp_timer = pvp.Holder:CreateFontString(nil, "ARTWORK", "LS10Font_Outline")
	pvp_timer:SetPoint("TOPRIGHT", pvp, "TOPRIGHT", 0, 0)
	pvp_timer:SetTextColor(1, 0.82, 0)
	pvp_timer:SetJustifyH("RIGHT")
	pvp_timer.frequentUpdates = 0.1

	-- debuff indicator
	frame.DebuffIndicator = self:CreateDebuffIndicator(text_parent)

	-- threat
	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	-- auras
	-- frame.Auras = self:CreateAuras(frame, "player")

	-- floating combat text
	local feeback = self:CreateCombatFeedback(frame)
	feeback:SetFrameLevel(level + 9)
	feeback:SetPoint("CENTER", 0, 0)
	frame.FloatingCombatFeedback = feeback

	local status = text_parent:CreateFontString(nil, "ARTWORK", "LSStatusIcon16Font")
	status:SetJustifyH("RIGHT")
	status:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, -1)
	frame:Tag(status, "[ls:combatresticon][ls:leadericon][ls:lfdroleicon]")

	E:CreateBorder(fg_parent, true)

	local glass = fg_parent:CreateTexture(nil, "OVERLAY")
	glass:SetAllPoints(health)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-glass", true)
	glass:SetHorizTile(true)

	self:CreateClassIndicator(frame)
end

function UF:UpdatePlayerFrame(frame)
	local config = frame._config

	frame:SetSize(config.width, config.height)

	if frame.Insets then
		self:UpdateInsets(frame)

		frame.AdditionalPower:SetSize(config.width, config.insets.t_height - 2)
		frame.ClassPower:SetSize(config.width, config.insets.t_height - 2)

		if frame.Runes then
			frame.Runes:SetSize(config.width, config.insets.t_height - 2)
		end

		if frame.Stagger then
			frame.Stagger:SetSize(config.width, config.insets.t_height - 2)
		end
	end

	self:UpdateHealth(frame)
	self:UpdateHealthPrediction(frame)
	self:UpdatePower(frame)
	self:UpdateAdditionalPower(frame)
	self:UpdatePowerPrediction(frame)
	self:UpdateClassPower(frame)
	self:UpdateCastbar(frame)
	self:UpdateRaidTargetIndicator(frame)
	self:UpdatePvPIndicator(frame)
	self:UpdateDebuffIndicator(frame)
	self:UpdateCombatFeedback(frame)
	self:UpdateThreatIndicator(frame)

	if frame.Runes then
		self:UpdateRunes(frame)
	end

	if frame.Stagger then
		self:UpdateStagger(frame)
	end

	if frame.ClassIndicator then
		self:UpdateClassIndicator(frame)
	end

	frame:UpdateAllElements("LSUI_PlayerFrameUpdate")
end
