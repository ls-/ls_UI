local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

local function updateFont(fontString, config)
	fontString:UpdateFont(config.size)
	fontString:SetJustifyH(config.h_alignment)
	fontString:SetJustifyV(config.v_alignment)
end

local function updateTextPoint(frame, fontString, config)
	fontString:ClearAllPoints()

	if config and config.p then
		fontString:SetPoint(config.p, E:ResolveAnchorPoint(frame, config.anchor), config.rP, config.x, config.y)
	end
end

local function updateTag(frame, fontString, tag)
	if tag ~= "" then
		frame:Tag(fontString, tag)
		fontString:UpdateTag()
	else
		frame:Untag(fontString)
		fontString:SetText("")
	end
end

-- .Health
do
	local ignoredKeys = {
		prediction = true,
	}

	local element_proto = {
		colorHealth = true,
		colorTapping = true,
		colorDisconnected = true,
	}

	function element_proto:PostUpdate(unit, cur, max)
		if self._config and self._config.animated_change then
			local unitGUID = UnitGUID(unit)
			self.GainLossIndicators:Update(cur, max, unitGUID == self._UnitGUID)
			self._UnitGUID = unitGUID
		end
	end

	function element_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].health, self._config, ignoredKeys)
		self._config.animated_change = C.db.profile.units.change.animated
	end

	function element_proto:UpdateColors()
		self.colorClass = self._config.color.class
		self.colorReaction = self._config.color.reaction
		self:ForceUpdate()
	end

	function element_proto:UpdateFonts()
		updateFont(self.Text, self._config.text)
	end

	function element_proto:UpdateTextPoints()
		updateTextPoint(self.__owner, self.Text, self._config.text.point1)
	end

	function element_proto:UpdateTags()
		updateTag(self.__owner, self.Text, self._config.enabled and self._config.text.tag or "")
	end

	function element_proto:UpdateTextures()
		self:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar))
	end

	function element_proto:UpdateSmoothing()
		if C.db.profile.units.change.smooth then
			E:SmoothBar(self)
		else
			E:DesmoothBar(self)
		end
	end

	function element_proto:UpdateGainLossPoints()
		self.GainLossIndicators:UpdatePoints(self._config.orientation)
	end

	function element_proto:UpdateGainLossColors()
		self.GainLossIndicators:UpdateColors()
	end

	local frame_proto = {}

	function frame_proto:UpdateHealth()
		local element = self.Health
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateFonts()
		element:UpdateTextPoints()
		element:UpdateSmoothing()
		element:UpdateTags()
		element:UpdateGainLossColors()
		element:UpdateGainLossPoints()
		element:ForceUpdate()
	end

	function UF:CreateHealth(frame, textParent)
		Mixin(frame, frame_proto)

		local element = Mixin(CreateFrame("StatusBar", nil, frame), element_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element._texture = element:GetStatusBarTexture()

		local text = (textParent or element):CreateFontString(nil, "ARTWORK")
		E.FontStrings:Capture(text, "unit")
		text:SetWordWrap(false)
		element.Text = text

		element.GainLossIndicators = E:CreateGainLossIndicators(element)
		element.GainLossIndicators:UpdateThreshold(0.001)
		element.GainLossIndicators.Gain = nil

		return element
	end
end

-- .HealthPrediction
do
	local element_proto = {
		maxOverflow = 1,
	}

	function element_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].health.prediction, self._config)
		self._config.orientation = C.db.profile.units[unit].health.orientation
	end

	function element_proto:UpdateColors()
		self.myBar:SetStatusBarColor(E:GetRGBA(C.db.global.colors.prediction.my_heal))
		self.otherBar:SetStatusBarColor(E:GetRGBA(C.db.global.colors.prediction.other_heal))
		self.healAbsorbBar:SetStatusBarColor(E:GetRGBA(C.db.global.colors.prediction.heal_absorb))
	end

	function element_proto:UpdateTextures()
		self.myBar:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar))
		self.otherBar:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar))
		self.healAbsorbBar:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar))
	end

	function element_proto:UpdateSmoothing()
		if C.db.profile.units.change.smooth then
			E:SmoothBar(self.myBar)
			E:SmoothBar(self.otherBar)
			E:SmoothBar(self.absorbBar)
			E:SmoothBar(self.healAbsorbBar)
		else
			E:DesmoothBar(self.myBar)
			E:DesmoothBar(self.otherBar)
			E:DesmoothBar(self.absorbBar)
			E:DesmoothBar(self.healAbsorbBar)
		end
	end

	local frame_proto = {}

	function frame_proto:UpdateHealthPrediction()
		local element = self.HealthPrediction
		element:UpdateConfig()

		local config = element._config
		local myBar = element.myBar
		local otherBar = element.otherBar
		local absorbBar = element.absorbBar
		local healAbsorbBar = element.healAbsorbBar

		myBar:SetOrientation(config.orientation)
		otherBar:SetOrientation(config.orientation)
		absorbBar:SetOrientation(config.orientation)
		healAbsorbBar:SetOrientation(config.orientation)

		if config.orientation == "HORIZONTAL" then
			local width = self.Health:GetWidth()
			width = width > 0 and width or self:GetWidth()

			myBar:ClearAllPoints()
			myBar:SetPoint("TOP")
			myBar:SetPoint("BOTTOM")
			myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
			myBar:SetWidth(width)

			otherBar:ClearAllPoints()
			otherBar:SetPoint("TOP")
			otherBar:SetPoint("BOTTOM")
			otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
			otherBar:SetWidth(width)

			absorbBar:ClearAllPoints()
			absorbBar:SetPoint("TOP")
			absorbBar:SetPoint("BOTTOM")
			absorbBar:SetPoint("LEFT", otherBar:GetStatusBarTexture(), "RIGHT")
			absorbBar:SetWidth(width)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetPoint("TOP")
			healAbsorbBar:SetPoint("BOTTOM")
			healAbsorbBar:SetPoint("RIGHT", self.Health:GetStatusBarTexture(), "RIGHT")
			healAbsorbBar:SetWidth(width)
		else
			local height = self.Health:GetHeight()
			height = height > 0 and height or self:GetHeight()

			myBar:ClearAllPoints()
			myBar:SetPoint("LEFT")
			myBar:SetPoint("RIGHT")
			myBar:SetPoint("BOTTOM", self.Health:GetStatusBarTexture(), "TOP")
			myBar:SetHeight(height)

			otherBar:ClearAllPoints()
			otherBar:SetPoint("LEFT")
			otherBar:SetPoint("RIGHT")
			otherBar:SetPoint("BOTTOM", myBar:GetStatusBarTexture(), "TOP")
			otherBar:SetHeight(height)

			absorbBar:ClearAllPoints()
			absorbBar:SetPoint("LEFT")
			absorbBar:SetPoint("RIGHT")
			absorbBar:SetPoint("BOTTOM", otherBar:GetStatusBarTexture(), "TOP")
			absorbBar:SetHeight(height)

			healAbsorbBar:ClearAllPoints()
			healAbsorbBar:SetPoint("LEFT")
			healAbsorbBar:SetPoint("RIGHT")
			healAbsorbBar:SetPoint("TOP", self.Health:GetStatusBarTexture(), "TOP")
			healAbsorbBar:SetHeight(height)
		end

		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSmoothing()

		if config.enabled and not self:IsElementEnabled("HealthPrediction") then
			self:EnableElement("HealthPrediction")
		elseif not config.enabled and self:IsElementEnabled("HealthPrediction") then
			self:DisableElement("HealthPrediction")
		end

		if self:IsElementEnabled("HealthPrediction") then
			element:ForceUpdate()
		end
	end

	function UF:CreateHealthPrediction(frame, parent)
		Mixin(frame, frame_proto)

		local level = parent:GetFrameLevel()

		local myBar = CreateFrame("StatusBar", nil, parent)
		myBar:SetFrameLevel(level)
		myBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		myBar._texture = myBar:GetStatusBarTexture()
		parent.MyHeal = myBar

		local otherBar = CreateFrame("StatusBar", nil, parent)
		otherBar:SetFrameLevel(level)
		otherBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		otherBar._texture = otherBar:GetStatusBarTexture()
		parent.OtherHeal = otherBar

		local absorbBar = CreateFrame("StatusBar", nil, parent)
		absorbBar:SetFrameLevel(level + 1)
		absorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		parent.DamageAbsorb = absorbBar

		absorbBar._texture = absorbBar:GetStatusBarTexture()
		absorbBar._texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\absorb", "REPEAT", "REPEAT")
		absorbBar._texture:SetHorizTile(true)
		absorbBar._texture:SetVertTile(true)

		local healAbsorbBar = CreateFrame("StatusBar", nil, parent)
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetFrameLevel(level + 1)
		healAbsorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		healAbsorbBar._texture = healAbsorbBar:GetStatusBarTexture()
		parent.HealAbsorb = healAbsorbBar

		return Mixin({
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
		}, element_proto)
	end
end
