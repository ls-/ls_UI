local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local UnitGUID = _G.UnitGUID
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

-- Mine
-- Power
do
	local function PostUpdate(element, unit, cur, _, max)
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

	function UF:CreatePower(parent, text, textFontObject, textParent)
		local element = _G.CreateFrame("StatusBar", nil, parent)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")

		if text then
			text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
			text:SetWordWrap(false)
			E:ResetFontStringHeight(text)
			element.Text = text
		end

		E:SmoothBar(element)
		E:CreateGainLossIndicators(element)

		element.colorPower = true
		element.colorDisconnected = true
		element.frequentUpdates = true
		element.PostUpdate = PostUpdate

		return element
	end

	function UF:UpdatePower(frame)
		local config = frame._config.power
		local element = frame.Power

		element:SetOrientation(config.orientation)

		if element.Text then
			element.Text:SetJustifyV(config.text.v_alignment or "MIDDLE")
			element.Text:SetJustifyH(config.text.h_alignment or "CENTER")
			element.Text:ClearAllPoints()

			local point1 = config.text.point1

			if point1 and point1.p then
				element.Text:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)
			end

			frame:Tag(element.Text, config.text.tag)
		end

		E:ReanchorGainLossIndicators(element, config.orientation)

		if config.enabled and not frame:IsElementEnabled("Power") then
			frame:EnableElement("Power")
		elseif not config.enabled and frame:IsElementEnabled("Power") then
			frame:DisableElement("Power")
		end

		if frame:IsElementEnabled("Power") then
			element:ForceUpdate()
		end
	end
end

-- Additional Power
do
	local function PostUpdate(element, unit, cur, max)
		if element:IsShown() and max and max ~= 0 then
			element:UpdateGainLoss(cur, max)
		end

		if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			element:SetMinMaxValues(0, 1)
			element:SetValue(0)
		end
	end

	function UF:CreateAdditionalPower(parent)
		local element = _G.CreateFrame("StatusBar", nil, parent)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:Hide()

		E:SmoothBar(element)
		E:CreateGainLossIndicators(element)

		element.colorPower = true
		element.PostUpdate = PostUpdate

		return element
	end

	function UF:UpdateAdditionalPower(frame)
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
end

-- Alternative Power
do
	local function PostUpdate(element, unit, cur, _, max)
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

	function UF:CreateAlternativePower(parent, text, textFontObject, textParent)
		local element = _G.CreateFrame("StatusBar", nil, parent)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetStatusBarColor(M.COLORS.INDIGO:GetRGB())

		if text then
			text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
			text:SetWordWrap(false)
			E:ResetFontStringHeight(text)
			element.Text = text
		end

		E:SmoothBar(element)
		E:CreateGainLossIndicators(element)

		element.PostUpdate = PostUpdate

		return element
	end

	function UF:UpdateAlternativePower(frame)
		local config = frame._config.alt_power
		local element = frame.AlternativePower

		element:SetOrientation(config.orientation)

		if element.Text then
			element.Text:SetJustifyV(config.text.v_alignment or "MIDDLE")
			element.Text:SetJustifyH(config.text.h_alignment or "CENTER")
			element.Text:ClearAllPoints()

			local point1 = config.text.point1

			if point1 and point1.p then
				element.Text:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)
			end

			local point2 = config.text.point2

			if point2 and point2.p then
				element.Text:SetPoint(point2.p, E:ResolveAnchorPoint(frame, point2.anchor), point2.rP, point2.x, point2.y)
			end

			frame:Tag(element.Text, config.text.tag)
		end

		E:ReanchorGainLossIndicators(element, config.orientation)

		if config.enabled and not frame:IsElementEnabled("AlternativePower") then
			frame:EnableElement("AlternativePower")
		elseif not config.enabled and frame:IsElementEnabled("AlternativePower") then
			frame:DisableElement("AlternativePower")
		end

		if frame:IsElementEnabled("AlternativePower") then
			element:ForceUpdate()
		end
	end
end

-- Power Prediction
do
	function UF:CreatePowerPrediction(parent1, parent2)
		local mainBar = _G.CreateFrame("StatusBar", nil, parent1)
		mainBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		mainBar:SetStatusBarColor(0.55, 0.75, 0.95) -- MOVE TO CONSTANTS!
		mainBar:SetReverseFill(true)
		parent1.CostPrediction = mainBar

		local altBar = _G.CreateFrame("StatusBar", nil, parent2)
		altBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		altBar:SetStatusBarColor(0.55, 0.75, 0.95) -- MOVE TO CONSTANTS!
		altBar:SetReverseFill(true)
		parent2.CostPrediction = altBar

		E:SmoothBar(mainBar)
		E:SmoothBar(altBar)

		return {
			mainBar_ = mainBar,
			mainBar = mainBar,
			altBar_ = altBar,
			altBar = altBar,
		}
	end

	function UF:UpdatePowerPrediction(frame)
		local config1 = frame._config.power
		local config2 = frame._config.class_power
		local element = frame.PowerPrediction

		if config1.prediction.enabled then
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

		if config2.prediction.enabled then
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

		local isEnabled = config1.prediction.enabled or config2.prediction.enabled

		if isEnabled and not frame:IsElementEnabled("PowerPrediction") then
			frame:EnableElement("PowerPrediction")
		elseif not isEnabled and frame:IsElementEnabled("PowerPrediction") then
			frame:DisableElement("PowerPrediction")
		end

		if frame:IsElementEnabled("PowerPrediction") then
			element:ForceUpdate()
		end
	end
end
