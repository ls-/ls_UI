local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

local ignoredKeys = {
	prediction = true,
	runes = true,
}

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

local element_proto = {
	colorPower = true,
}

function element_proto:UpdateFonts()
	updateFont(self.Text, self._config.text)
end

function element_proto:UpdateTextPoints()
	updateTextPoint(self.__owner, self.Text, self._config.text.point1)
end

function element_proto:UpdateTags()
	updateTag(self.__owner, self.Text, self._config.enabled and self._config.text.tag or "")
end

function element_proto:UpdateColors()
	self:ForceUpdate()
end

function element_proto:UpdateTextures()
	if self._config.orientation == "HORIZONTAL" then
		self:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.horiz))
	else
		self:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.vert))
	end
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

-- .Power
do
	local power_proto = {
		colorDisconnected = true,
		frequentUpdates = true,
	}

	function power_proto:PostUpdate(unit, cur, _, max)
		local shouldShow = max and max ~= 0
		local isShown = self:IsShown()
		if (shouldShow and not isShown) or (not shouldShow and isShown) then
			self:SetShown(shouldShow)
		end

		if shouldShow then
			if self._config and self._config.animated_change then
				local unitGUID = UnitGUID(unit)
				self.GainLossIndicators:Update(cur, max, unitGUID == self._UnitGUID)
				self._UnitGUID = unitGUID
			end

			self.Text:Show()
		else
			self.Text:Hide()
		end
	end

	function power_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].power, self._config, ignoredKeys)
		self._config.animated_change = C.db.profile.units.change.animated
	end

	local frame_proto = {}

	function frame_proto:UpdatePower()
		local element = self.Power
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSmoothing()
		element:UpdateFonts()
		element:UpdateTextPoints()
		element:UpdateTags()
		element:UpdateGainLossColors()
		element:UpdateGainLossPoints()

		if element._config.enabled and not self:IsElementEnabled("Power") then
			self:EnableElement("Power")
		elseif not element._config.enabled and self:IsElementEnabled("Power") then
			self:DisableElement("Power")
		end

		if self:IsElementEnabled("Power") then
			element:ForceUpdate()
		end
	end

	function UF:CreatePower(frame, textParent)
		P:Mixin(frame, frame_proto)

		local element = P:Mixin(CreateFrame("StatusBar", nil, frame), element_proto, power_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:Hide()

		local text = (textParent or element):CreateFontString(nil, "ARTWORK")
		E.FontStrings:Capture(text, "unit")
		text:SetWordWrap(false)
		element.Text = text

		element.GainLossIndicators = E:CreateGainLossIndicators(element)
		element.GainLossIndicators:UpdateThreshold(0.01)

		return element
	end
end

-- .AdditionalPower
do
	local power_proto = {}

	function power_proto:PostUpdate(cur, max)
		if self:IsShown() and max and max ~= 0 then
			if self._config and self._config.animated_change then
				self.GainLossIndicators:Update(cur, max)
			end
		end
	end

	function power_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
		self._config.animated_change = C.db.profile.units.change.animated
	end

	local frame_proto = {}

	function frame_proto:UpdateAdditionalPower()
		local element = self.AdditionalPower
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSmoothing()
		element:UpdateGainLossColors()
		element:UpdateGainLossPoints()

		if element._config.enabled and not self:IsElementEnabled("AdditionalPower") then
			self:EnableElement("AdditionalPower")
		elseif not element._config.enabled and self:IsElementEnabled("AdditionalPower") then
			self:DisableElement("AdditionalPower")
		end

		element:ForceUpdate()
	end

	function UF:CreateAdditionalPower(frame)
		P:Mixin(frame, frame_proto)

		local element = P:Mixin(CreateFrame("StatusBar", nil, frame), element_proto, power_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:Hide()

		element.GainLossIndicators = E:CreateGainLossIndicators(element)
		element.GainLossIndicators:UpdateThreshold(0.01)

		return element
	end
end

-- .AlternativePower
do
	local power_proto = {}

	function power_proto:PostUpdate(unit, cur, _, max)
		if self:IsShown() and max and max ~= 0 then
			if self._config and self._config.animated_change then
				local unitGUID = UnitGUID(unit)
				self.GainLossIndicators:Update(cur, max, unitGUID == self._UnitGUID)
				self._UnitGUID = unitGUID
			end

			self.Text:Show()
		else
			self.Text:Hide()
		end
	end

	function power_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].alt_power, self._config)
		self._config.animated_change = C.db.profile.units.change.animated
	end

	function power_proto:UpdateColors()
		self:SetStatusBarColor(E:GetRGB(C.db.global.colors.power.ALTERNATE))
	end

	local frame_proto = {}

	function frame_proto:UpdateAlternativePower()
		local element = self.AlternativePower
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSmoothing()
		element:UpdateFonts()
		element:UpdateTextPoints()
		element:UpdateTags()
		element:UpdateGainLossColors()
		element:UpdateGainLossPoints()

		if element._config.enabled and not self:IsElementEnabled("AlternativePower") then
			self:EnableElement("AlternativePower")
		elseif not element._config.enabled and self:IsElementEnabled("AlternativePower") then
			self:DisableElement("AlternativePower")
		end

		if self:IsElementEnabled("AlternativePower") then
			element:ForceUpdate()
		end
	end

	function UF:CreateAlternativePower(frame, textParent)
		P:Mixin(frame, frame_proto)

		local element = P:Mixin(CreateFrame("StatusBar", nil, frame), element_proto, power_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:Hide()

		local text = (textParent or element):CreateFontString(nil, "ARTWORK")
		E.FontStrings:Capture(text, "unit")
		text:SetWordWrap(false)
		element.Text = text

		element.GainLossIndicators = E:CreateGainLossIndicators(element)
		element.GainLossIndicators:UpdateThreshold(0.01)

		return element
	end
end

-- .PowerPrediction
do
	local power_proto = {}

	function power_proto:UpdateConfig()
		if not self._config then
			self._config = {
				power = {},
				class_power = {},
			}
		end

		local unit = self.__owner.__unit
		self._config.power.enabled = C.db.profile.units[unit].power.prediction.enabled
		self._config.power.orientation = C.db.profile.units[unit].power.orientation
		self._config.class_power.enabled = C.db.profile.units[unit].class_power.prediction.enabled
		self._config.class_power.orientation = C.db.profile.units[unit].class_power.orientation
	end

	function power_proto:UpdateColors()
		self.mainBar_:SetStatusBarColor(E:GetRGB(C.db.global.colors.prediction.power_cost))
		self.altBar_:SetStatusBarColor(E:GetRGB(C.db.global.colors.prediction.power_cost))
	end

	function power_proto:UpdateSmoothing()
		if C.db.profile.units.change.smooth then
			E:SmoothBar(self.mainBar_)
			E:SmoothBar(self.altBar_)
		else
			E:DesmoothBar(self.mainBar_)
			E:DesmoothBar(self.altBar_)
		end
	end

	local frame_proto = {}

	function frame_proto:UpdatePowerPrediction()
		local element = self.PowerPrediction
		element:UpdateConfig()

		local config1 = element._config.power
		if config1.enabled then
			local mainBar_ = element.mainBar_
			mainBar_:SetOrientation(config1.orientation)
			mainBar_:ClearAllPoints()

			if config1.orientation == "HORIZONTAL" then
				local width = self.Power:GetWidth()
				width = width > 0 and width or self:GetWidth()

				mainBar_:SetPoint("TOP")
				mainBar_:SetPoint("BOTTOM")
				mainBar_:SetPoint("RIGHT", self.Power:GetStatusBarTexture(), "RIGHT")
				mainBar_:SetWidth(width)
			else
				local height = self.Power:GetHeight()
				height = height > 0 and height or self:GetHeight()

				mainBar_:SetPoint("LEFT")
				mainBar_:SetPoint("RIGHT")
				mainBar_:SetPoint("TOP", self.Power:GetStatusBarTexture(), "TOP")
				mainBar_:SetHeight(height)
			end

			element.mainBar = mainBar_
		else
			element.mainBar = nil

			element.mainBar_:Hide()
			element.mainBar_:ClearAllPoints()
		end

		local config2 = element._config.class_power
		if config2.enabled then
			local altBar_ = element.altBar_
			altBar_:SetOrientation(config2.orientation)
			altBar_:ClearAllPoints()

			if config2.orientation == "HORIZONTAL" then
				local width = self.AdditionalPower:GetWidth()
				width = width > 0 and width or self:GetWidth()

				altBar_:SetPoint("TOP")
				altBar_:SetPoint("BOTTOM")
				altBar_:SetPoint("RIGHT", self.AdditionalPower:GetStatusBarTexture(), "RIGHT")
				altBar_:SetWidth(width)
			else
				local height = self.AdditionalPower:GetHeight()
				height = height > 0 and height or self:GetHeight()

				altBar_:SetPoint("LEFT")
				altBar_:SetPoint("RIGHT")
				altBar_:SetPoint("TOP", self.AdditionalPower:GetStatusBarTexture(), "TOP")
				altBar_:SetHeight(height)
			end

			element.altBar = altBar_
		else
			element.altBar = nil

			element.altBar_:Hide()
			element.altBar_:ClearAllPoints()
		end

		element:UpdateColors()

		local isEnabled = config1.enabled or config2.enabled
		if isEnabled and not self:IsElementEnabled("PowerPrediction") then
			self:EnableElement("PowerPrediction")
		elseif not isEnabled and self:IsElementEnabled("PowerPrediction") then
			self:DisableElement("PowerPrediction")
		end

		if self:IsElementEnabled("PowerPrediction") then
			element:ForceUpdate()
		end
	end

	function UF:CreatePowerPrediction(frame, parent1, parent2)
		P:Mixin(frame, frame_proto)

		local mainBar = CreateFrame("StatusBar", nil, parent1)
		mainBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		mainBar:SetReverseFill(true)
		parent1.CostPrediction = mainBar

		local altBar = CreateFrame("StatusBar", nil, parent2)
		altBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		altBar:SetReverseFill(true)
		parent2.CostPrediction = altBar

		return P:Mixin({
			mainBar_ = mainBar,
			altBar_ = altBar,
		}, power_proto)
	end
end
