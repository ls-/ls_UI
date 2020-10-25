local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local UnitGUID = _G.UnitGUID
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local ignoredKeys = {
	prediction = true,
	runes = true,
}

local function updateFont(fontString, config)
	fontString:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", config.font), config.size, config.outline and "OUTLINE" or nil)
	fontString:SetJustifyH(config.h_alignment)
	fontString:SetJustifyV(config.v_alignment)
	fontString:SetWordWrap(false)

	if config.shadow then
		fontString:SetShadowOffset(1, -1)
	else
		fontString:SetShadowOffset(0, 0)
	end
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

local function element_UpdateFonts(self)
	updateFont(self.Text, self._config.text)
end

local function element_UpdateTextPoints(self)
	updateTextPoint(self.__owner, self.Text, self._config.text.point1)
end

local function element_UpdateTags(self)
	updateTag(self.__owner, self.Text, self._config.enabled and self._config.text.tag or "")
end

local function element_UpdateGainLossPoints(self)
	self.GainLossIndicators:UpdatePoints(self._config.orientation)
end

local function element_UpdateGainLossThreshold(self)
	self.GainLossIndicators:UpdateThreshold(self._config.change_threshold)
end

local function element_UpdateGainLossColors(self)
	self.GainLossIndicators:UpdateColors()
end

-- .Power
do
	local function element_PostUpdate(self, unit, cur, _, max)
		local shouldShown = self:IsShown() and max and max ~= 0

		if self.UpdateContainer then
			self:UpdateContainer(shouldShown)
		end

		local unitGUID = UnitGUID(unit)
		self.GainLossIndicators:Update(cur, max, unitGUID == self.GainLossIndicators._UnitGUID)
		self.GainLossIndicators._UnitGUID = unitGUID

		if shouldShown then
			self.Text:Show()
		else
			self.Text:Hide()
		end

		if not shouldShown or not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			self:SetMinMaxValues(0, 1)
			self:SetValue(0)
		end
	end

	local function element_UpdateConfig(self)
		local unit = self.__owner._unit
		self._config = E:CopyTable(C.db.profile.units[unit].power, self._config, ignoredKeys)
		self._config.text = E:CopyTable(C.db.profile.units.text, self._config.text)
	end

	local function element_UpdateColors(self)
		self:ForceUpdate()
	end

	local function frame_UpdatePower(self)
		local element = self.Power
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColors()
		element:UpdateFonts()
		element:UpdateTextPoints()
		element:UpdateTags()
		element:UpdateGainLossColors()
		element:UpdateGainLossPoints()
		element:UpdateGainLossThreshold()

		if element._config.enabled and not self:IsElementEnabled("Power") then
			self:EnableElement("Power")
		elseif not element._config.enabled and self:IsElementEnabled("Power") then
			self:DisableElement("Power")
		end

		if self:IsElementEnabled("Power") then
			element:ForceUpdate()
		elseif element.UpdateContainer then
			element:UpdateContainer(false)
		end
	end

	function UF:CreatePower(frame, textParent)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E:SmoothBar(element)

		element.Text = (textParent or element):CreateFontString(nil, "ARTWORK")

		element.GainLossIndicators = E:CreateGainLossIndicators(element)

		element.colorDisconnected = true
		element.colorPower = true
		element.frequentUpdates = true
		element.PostUpdate = element_PostUpdate
		element.UpdateColors = element_UpdateColors
		element.UpdateConfig = element_UpdateConfig
		element.UpdateFonts = element_UpdateFonts
		element.UpdateGainLossColors = element_UpdateGainLossColors
		element.UpdateGainLossPoints = element_UpdateGainLossPoints
		element.UpdateGainLossThreshold = element_UpdateGainLossThreshold
		element.UpdateTags = element_UpdateTags
		element.UpdateTextPoints = element_UpdateTextPoints

		frame.UpdatePower = frame_UpdatePower

		return element
	end
end

-- .AdditionalPower
do
	local function element_PostUpdate(self, cur, max)
		if self:IsShown() and max and max ~= 0 then
			self.GainLossIndicators:Update(cur, max)
		end

		if not UnitIsConnected("player") or UnitIsDeadOrGhost("player") then
			self:SetMinMaxValues(0, 1)
			self:SetValue(0)
		end
	end

	local function element_UpdateConfig(self)
		local unit = self.__owner._unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
	end

	local function element_UpdateColors(self)
		self:ForceUpdate()
	end

	local function frame_UpdateAdditionalPower(frame)
		local element = frame.AdditionalPower
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColors()
		element:UpdateGainLossColors()
		element:UpdateGainLossPoints()
		element:UpdateGainLossThreshold()

		if element._config.enabled and not frame:IsElementEnabled("AdditionalPower") then
			frame:EnableElement("AdditionalPower")
		elseif not element._config.enabled and frame:IsElementEnabled("AdditionalPower") then
			frame:DisableElement("AdditionalPower")
		end

		element:ForceUpdate()
	end

	function UF:CreateAdditionalPower(frame)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E:SmoothBar(element)
		element:Hide()

		element.GainLossIndicators = E:CreateGainLossIndicators(element)

		element.colorPower = true
		element.PostUpdate = element_PostUpdate
		element.UpdateColors = element_UpdateColors
		element.UpdateConfig = element_UpdateConfig
		element.UpdateGainLossColors = element_UpdateGainLossColors
		element.UpdateGainLossPoints = element_UpdateGainLossPoints
		element.UpdateGainLossThreshold = element_UpdateGainLossThreshold

		frame.UpdateAdditionalPower = frame_UpdateAdditionalPower

		return element
	end
end

-- .AlternativePower
do
	local function element_PostUpdate(self, unit, cur, _, max)
		local shouldShown = self:IsShown() and max and max ~= 0

		if self.UpdateContainer then
			self:UpdateContainer(shouldShown)
		end

		local unitGUID = UnitGUID(unit)
		self.GainLossIndicators:Update(cur, max, unitGUID == self.GainLossIndicators._UnitGUID)
		self.GainLossIndicators._UnitGUID = unitGUID

		if shouldShown then
			self.Text:Show()
		else
			self.Text:Hide()
		end

		if not shouldShown or not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			self:SetMinMaxValues(0, 1)
			self:SetValue(0)
		end
	end

	local function element_UpdateConfig(self)
		local unit = self.__owner._unit
		self._config = E:CopyTable(C.db.profile.units[unit].alt_power, self._config)
		self._config.text = E:CopyTable(C.db.profile.units.text, self._config.text)
	end

	local function element_UpdateColors(self)
		self:SetStatusBarColor(E:GetRGB(C.db.global.colors.power.ALTERNATE))
	end

	local function frame_UpdateAlternativePower(self)
		local element = self.AlternativePower
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColors()
		element:UpdateFonts()
		element:UpdateTextPoints()
		element:UpdateTags()
		element:UpdateGainLossColors()
		element:UpdateGainLossPoints()
		element:UpdateGainLossThreshold()

		if element._config.enabled and not self:IsElementEnabled("AlternativePower") then
			self:EnableElement("AlternativePower")
		elseif not element._config.enabled and self:IsElementEnabled("AlternativePower") then
			self:DisableElement("AlternativePower")
		end

		if self:IsElementEnabled("AlternativePower") then
			element:ForceUpdate()
		elseif element.UpdateContainer then
			element:UpdateContainer(false)
		end
	end

	function UF:CreateAlternativePower(frame, textParent)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E:SmoothBar(element)

		element.Text = (textParent or element):CreateFontString(nil, "ARTWORK")

		element.GainLossIndicators = E:CreateGainLossIndicators(element)

		element.PostUpdate = element_PostUpdate
		element.UpdateColors = element_UpdateColors
		element.UpdateConfig = element_UpdateConfig
		element.UpdateFonts = element_UpdateFonts
		element.UpdateGainLossColors = element_UpdateGainLossColors
		element.UpdateGainLossPoints = element_UpdateGainLossPoints
		element.UpdateGainLossThreshold = element_UpdateGainLossThreshold
		element.UpdateTags = element_UpdateTags
		element.UpdateTextPoints = element_UpdateTextPoints

		frame.UpdateAlternativePower = frame_UpdateAlternativePower

		return element
	end
end

-- .PowerPrediction
do
	local function element_UpdateConfig(self)
		if not self._config then
			self._config = {
				power = {},
				class_power = {},
			}
		end

		local unit = self.__owner._unit
		self._config.power.enabled = C.db.profile.units[unit].power.prediction.enabled
		self._config.power.orientation = C.db.profile.units[unit].power.orientation
		self._config.class_power.enabled = C.db.profile.units[unit].class_power.prediction.enabled
		self._config.class_power.orientation = C.db.profile.units[unit].class_power.orientation
	end

	local function element_UpdateColors(self)
		self.mainBar_:SetStatusBarColor(E:GetRGB(C.db.global.colors.prediction.power_cost))
		self.altBar_:SetStatusBarColor(E:GetRGB(C.db.global.colors.prediction.power_cost))
	end

	local function frame_UpdatePowerPrediction(frame)
		local element = frame.PowerPrediction
		element:UpdateConfig()

		local config1 = element._config.power
		if config1.enabled then
			local mainBar_ = element.mainBar_
			mainBar_:SetOrientation(config1.orientation)
			mainBar_:ClearAllPoints()

			if config1.orientation == "HORIZONTAL" then
				local width = frame.Power:GetWidth()
				width = width > 0 and width or frame:GetWidth()

				mainBar_:SetPoint("TOP")
				mainBar_:SetPoint("BOTTOM")
				mainBar_:SetPoint("RIGHT", frame.Power:GetStatusBarTexture(), "RIGHT")
				mainBar_:SetWidth(width)
			else
				local height = frame.Power:GetHeight()
				height = height > 0 and height or frame:GetHeight()

				mainBar_:SetPoint("LEFT")
				mainBar_:SetPoint("RIGHT")
				mainBar_:SetPoint("TOP", frame.Power:GetStatusBarTexture(), "TOP")
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
				local width = frame.AdditionalPower:GetWidth()
				width = width > 0 and width or frame:GetWidth()

				altBar_:SetPoint("TOP")
				altBar_:SetPoint("BOTTOM")
				altBar_:SetPoint("RIGHT", frame.AdditionalPower:GetStatusBarTexture(), "RIGHT")
				altBar_:SetWidth(width)
			else
				local height = frame.AdditionalPower:GetHeight()
				height = height > 0 and height or frame:GetHeight()

				altBar_:SetPoint("LEFT")
				altBar_:SetPoint("RIGHT")
				altBar_:SetPoint("TOP", frame.AdditionalPower:GetStatusBarTexture(), "TOP")
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
		if isEnabled and not frame:IsElementEnabled("PowerPrediction") then
			frame:EnableElement("PowerPrediction")
		elseif not isEnabled and frame:IsElementEnabled("PowerPrediction") then
			frame:DisableElement("PowerPrediction")
		end

		if frame:IsElementEnabled("PowerPrediction") then
			element:ForceUpdate()
		end
	end

	function UF:CreatePowerPrediction(frame, parent1, parent2)
		local mainBar = CreateFrame("StatusBar", nil, parent1)
		mainBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		mainBar:SetReverseFill(true)
		E:SmoothBar(mainBar)
		parent1.CostPrediction = mainBar

		local altBar = CreateFrame("StatusBar", nil, parent2)
		altBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		altBar:SetReverseFill(true)
		E:SmoothBar(altBar)
		parent2.CostPrediction = altBar

		frame.UpdatePowerPrediction = frame_UpdatePowerPrediction

		return {
			mainBar_ = mainBar,
			altBar_ = altBar,
			UpdateColors = element_UpdateColors,
			UpdateConfig = element_UpdateConfig,
		}
	end
end
