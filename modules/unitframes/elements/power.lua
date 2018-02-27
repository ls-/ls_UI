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
-- .Power
do
	local function element_PostUpdate(element, unit, cur, _, max)
		local shouldShown = element:IsShown() and max and max ~= 0

		if element.UpdateContainer then
			element:UpdateContainer(shouldShown)
		end

		if shouldShown then
			local unitGUID = UnitGUID(unit)

			element:UpdateGainLoss(cur, max, unitGUID == element._UnitGUID)

			element._UnitGUID = unitGUID

			element.Text:Show()
		else
			element.Text:Hide()
		end

		if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			element:SetMinMaxValues(0, 1)
			element:SetValue(0)
		end
	end

	local function frame_UpdatePower(self)
		local config = self._config.power
		local element = self.Power

		element:SetOrientation(config.orientation)

		if element.Text then
			element.Text:SetJustifyV(config.text.v_alignment or "MIDDLE")
			element.Text:SetJustifyH(config.text.h_alignment or "CENTER")
			element.Text:ClearAllPoints()

			local point1 = config.text.point1

			if point1 and point1.p then
				element.Text:SetPoint(point1.p, E:ResolveAnchorPoint(self, point1.anchor), point1.rP, point1.x, point1.y)
			end

			self:Tag(element.Text, config.enabled and config.text.tag or "")
		end

		E:ReanchorGainLossIndicators(element, config.orientation)

		if config.enabled and not self:IsElementEnabled("Power") then
			self:EnableElement("Power")
		elseif not config.enabled and self:IsElementEnabled("Power") then
			self:DisableElement("Power")
		end

		element:ForceUpdate()
	end

	function UF:CreatePower(frame, text, textFontObject, textParent)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")

		if text then
			text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
			element.Text = text
		end

		E:SmoothBar(element)
		E:CreateGainLossIndicators(element)

		element.colorPower = true
		element.colorDisconnected = true
		element.frequentUpdates = true
		element.PostUpdate = element_PostUpdate

		frame.UpdatePower = frame_UpdatePower

		return element
	end
end

-- .AdditionalPower
do
	local function element_PostUpdate(element, unit, cur, max)
		if element:IsShown() and max and max ~= 0 then
			element:UpdateGainLoss(cur, max)
		end

		if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			element:SetMinMaxValues(0, 1)
			element:SetValue(0)
		end
	end

	local function frame_UpdateAdditionalPower(frame)
		local config = frame._config.class_power
		local element = frame.AdditionalPower

		element:SetOrientation(config.orientation)

		E:ReanchorGainLossIndicators(element, config.orientation)

		if config.enabled and not frame:IsElementEnabled("AdditionalPower") then
			frame:EnableElement("AdditionalPower")
		elseif not config.enabled and frame:IsElementEnabled("AdditionalPower") then
			frame:DisableElement("AdditionalPower")
		end

		if frame:IsElementEnabled("AdditionalPower") then
			element:ForceUpdate()
		end
	end

	function UF:CreateAdditionalPower(frame)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:Hide()

		E:SmoothBar(element)
		E:CreateGainLossIndicators(element)

		element.colorPower = true
		element.PostUpdate = element_PostUpdate

		frame.UpdateAdditionalPower = frame_UpdateAdditionalPower

		return element
	end
end

-- .AlternativePower
do
	local function element_PostUpdate(element, unit, cur, _, max)
		local shouldShown = element:IsShown() and max and max ~= 0

		if element.UpdateContainer then
			element:UpdateContainer(shouldShown)
		end

		if shouldShown then
			local unitGUID = UnitGUID(unit)

			element:UpdateGainLoss(cur, max, unitGUID == element._UnitGUID)

			element._UnitGUID = unitGUID

			element.Text:Show()
		else
			element.Text:Hide()
		end

		if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			element:SetMinMaxValues(0, 1)
			element:SetValue(0)
		end
	end

	local function frame_UpdateAlternativePower(self)
		local config = self._config.alt_power
		local element = self.AlternativePower

		element:SetOrientation(config.orientation)

		if element.Text then
			element.Text:SetJustifyV(config.text.v_alignment or "MIDDLE")
			element.Text:SetJustifyH(config.text.h_alignment or "CENTER")
			element.Text:ClearAllPoints()

			local point1 = config.text.point1

			if point1 and point1.p then
				element.Text:SetPoint(point1.p, E:ResolveAnchorPoint(self, point1.anchor), point1.rP, point1.x, point1.y)
			end

			self:Tag(element.Text, config.text.tag)
		end

		E:ReanchorGainLossIndicators(element, config.orientation)

		if config.enabled and not self:IsElementEnabled("AlternativePower") then
			self:EnableElement("AlternativePower")
		elseif not config.enabled and self:IsElementEnabled("AlternativePower") then
			self:DisableElement("AlternativePower")
		end

		element:ForceUpdate()
	end

	function UF:CreateAlternativePower(frame, text, textFontObject, textParent)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetStatusBarColor(M.COLORS.INDIGO:GetRGB())

		if text then
			text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
			element.Text = text
		end

		E:SmoothBar(element)
		E:CreateGainLossIndicators(element)

		element.PostUpdate = element_PostUpdate

		frame.UpdateAlternativePower = frame_UpdateAlternativePower

		return element
	end
end

-- .PowerPrediction
do
	local function frame_UpdatePowerPrediction(self)
		local config1 = self._config.power
		local config2 = self._config.class_power
		local element = self.PowerPrediction

		if config1.prediction.enabled then
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

		if config2.prediction.enabled then
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

		local isEnabled = config1.prediction.enabled or config2.prediction.enabled

		if isEnabled and not self:IsElementEnabled("PowerPrediction") then
			self:EnableElement("PowerPrediction")
		elseif not isEnabled and self:IsElementEnabled("PowerPrediction") then
			self:DisableElement("PowerPrediction")
		end

		element:ForceUpdate()
	end

	function UF:CreatePowerPrediction(frame, parent1, parent2)
		local mainBar = CreateFrame("StatusBar", nil, parent1)
		mainBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		mainBar:SetStatusBarColor(0.55, 0.75, 0.95) -- MOVE TO CONSTANTS!
		mainBar:SetReverseFill(true)
		parent1.CostPrediction = mainBar

		local altBar = CreateFrame("StatusBar", nil, parent2)
		altBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		altBar:SetStatusBarColor(0.55, 0.75, 0.95) -- MOVE TO CONSTANTS!
		altBar:SetReverseFill(true)
		parent2.CostPrediction = altBar

		E:SmoothBar(mainBar)
		E:SmoothBar(altBar)

		frame.UpdatePowerPrediction = frame_UpdatePowerPrediction

		return {
			mainBar_ = mainBar,
			mainBar = mainBar,
			altBar_ = altBar,
			altBar = altBar,
		}
	end
end
