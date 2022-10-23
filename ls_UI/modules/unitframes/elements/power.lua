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
	if self.__owner:IsElementEnabled("Power") then
		self:ForceUpdate()
	end
end

function element_proto:UpdateTextures()
	self:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.horiz))
end

function element_proto:UpdateSmoothing()
	if C.db.profile.units.change.smooth then
		E:SmoothBar(self)
	else
		E:DesmoothBar(self)
	end
end

-- .Power
do
	local power_proto = {
		colorDisconnected = true,
		frequentUpdates = true,
	}

	function power_proto:PostUpdate(_, _, _, max)
		local shouldShow = max and max ~= 0
		local isShown = self:IsShown()
		if (shouldShow and not isShown) or (not shouldShow and isShown) then
			self:SetShown(shouldShow)
		end

		if shouldShow then
			self.Text:Show()
		else
			self.Text:Hide()
		end
	end

	function power_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].power, self._config, ignoredKeys)
	end

	local frame_proto = {}

	function frame_proto:UpdatePower()
		local element = self.Power
		element:UpdateConfig()
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSmoothing()
		element:UpdateFonts()
		element:UpdateTextPoints()
		element:UpdateTags()

		self.Insets.Bottom:Release(element)

		if element._config.enabled and not self:IsElementEnabled("Power") then
			self:EnableElement("Power")
		elseif not element._config.enabled and self:IsElementEnabled("Power") then
			self:DisableElement("Power")
		end

		if self:IsElementEnabled("Power") then
			self.Insets.Bottom:Capture(element, 0, 0, -2, 0)

			element:ForceUpdate()
		end
	end

	function UF:CreatePower(frame, textParent)
		Mixin(frame, frame_proto)

		local element = Mixin(CreateFrame("StatusBar", nil, frame), element_proto, power_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetFrameLevel(frame:GetFrameLevel() + 1)
		element:Hide()

		local text = (textParent or element):CreateFontString(nil, "ARTWORK")
		E.FontStrings:Capture(text, "unit")
		text:SetWordWrap(false)
		element.Text = text

		return element
	end
end

-- .AdditionalPower
do
	local power_proto = {}

	function power_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
	end

	local frame_proto = {}

	function frame_proto:UpdateAdditionalPower()
		local element = self.AdditionalPower
		element:UpdateConfig()
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSmoothing()

		self.Insets.Top:Release(element)

		if element._config.enabled and not self:IsElementEnabled("AdditionalPower") then
			self:EnableElement("AdditionalPower")
		elseif not element._config.enabled and self:IsElementEnabled("AdditionalPower") then
			self:DisableElement("AdditionalPower")
		end

		if self:IsElementEnabled("AdditionalPower") then
			self.Insets.Top:Capture(element, 0, 0, 0, 2)
		end

		element:ForceUpdate()
	end

	function UF:CreateAdditionalPower(frame)
		Mixin(frame, frame_proto)

		local element = Mixin(CreateFrame("StatusBar", nil, frame), element_proto, power_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetFrameLevel(frame:GetFrameLevel() + 1)
		element:Hide()

		return element
	end
end

-- .AlternativePower
do
	local power_proto = {}

	function power_proto:PostUpdate(_, _, _, max)
		if self:IsShown() and max and max ~= 0 then
			self.Text:Show()
		else
			self.Text:Hide()
		end
	end

	function power_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].alt_power, self._config)
	end

	function power_proto:UpdateColors()
		self:SetStatusBarColor(E:GetRGB(C.db.global.colors.power.ALTERNATE))
	end

	local frame_proto = {}

	function frame_proto:UpdateAlternativePower()
		local element = self.AlternativePower
		element:UpdateConfig()
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSmoothing()
		element:UpdateFonts()
		element:UpdateTextPoints()
		element:UpdateTags()

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
		Mixin(frame, frame_proto)

		local element = Mixin(CreateFrame("StatusBar", nil, frame), element_proto, power_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:Hide()

		local text = (textParent or element):CreateFontString(nil, "ARTWORK")
		E.FontStrings:Capture(text, "unit")
		text:SetWordWrap(false)
		element.Text = text

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
		self._config.class_power.enabled = C.db.profile.units[unit].class_power.prediction.enabled
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
			element.mainBar = element.mainBar_

			local width = self.Power:GetWidth()
			width = width > 0 and width or self:GetWidth()

			element.mainBar_:SetWidth(width)
		else
			element.mainBar = nil

			element.mainBar_:Hide()
		end

		local config2 = element._config.class_power
		if config2.enabled then
			element.altBar = element.altBar_

			local width = self.AdditionalPower:GetWidth()
			width = width > 0 and width or self:GetWidth()

			element.altBar_:SetWidth(width)
		else
			element.altBar = nil

			element.altBar_:Hide()
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
		Mixin(frame, frame_proto)

		local mainBar = CreateFrame("StatusBar", nil, parent1)
		mainBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		mainBar:SetReverseFill(true)
		mainBar:SetPoint("TOP")
		mainBar:SetPoint("BOTTOM")
		mainBar:SetPoint("RIGHT", frame.Power:GetStatusBarTexture(), "RIGHT")
		parent1.CostPrediction = mainBar

		local altBar = CreateFrame("StatusBar", nil, parent2)
		altBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		altBar:SetReverseFill(true)
		altBar:SetPoint("TOP")
		altBar:SetPoint("BOTTOM")
		altBar:SetPoint("RIGHT", frame.AdditionalPower:GetStatusBarTexture(), "RIGHT")
		parent2.CostPrediction = altBar

		return Mixin({
			mainBar_ = mainBar,
			altBar_ = altBar,
		}, power_proto)
	end
end
