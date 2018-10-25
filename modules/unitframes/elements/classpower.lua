local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local UnitHealthMax = _G.UnitHealthMax
local UnitStagger = _G.UnitStagger

--[[ luacheck:globals
	CreateFrame UnitHasVehicleUI
]]

-- Mine
local function bar_OnValueChanged(self, value)
	local _, max = self:GetMinMaxValues()

	if value == max then
		if not self._active then
			if not self.InAnim:IsPlaying() then
				self.InAnim:Play()
			end

			self:SetAlpha(1)

			self._active = true
		end
	else
		self.InAnim:Stop()

		if self._active then
			self:SetAlpha(0.65)

			self._active = false
		end
	end
end

local function createElement(parent, num, name)
	local element = CreateFrame("Frame", nil, parent)
	local level = element:GetFrameLevel()

	for i = 1, num do
		local bar = CreateFrame("StatusBar", "$parent" .. name .. i, element)
		bar:SetFrameLevel(level)
		bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		bar:SetScript("OnValueChanged", bar_OnValueChanged)
		element[i] = bar

		local glow = bar:CreateTexture(nil, "ARTWORK", nil, 7)
		glow:SetAllPoints()
		glow:SetColorTexture(1, 1, 1)
		glow:SetAlpha(0)
		bar.Glow = glow

		local ag = glow:CreateAnimationGroup()
		bar.InAnim = ag

		local anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetDuration(0.25)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		anim:SetSmoothing("OUT")

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetDuration(0.25)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetSmoothing("IN")
	end

	return element
end

-- .Runes
do
	local ignoredKeys = {
		prediction = true,
	}

	local function element_PostUpdate(self)
		if self.isEnabled then
			local hasVehicle = UnitHasVehicleUI("player")
			if hasVehicle and self._active then
				self:Hide()

				self._active = false
			elseif not hasVehicle and not self._active then
				self:Show()

				self._active = true
			end
		end
	end

	local function element_UpdateConfig(self)
		local unit = self.__owner._unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
	end

	local function element_UpdateColors(self)
		self.colorSpec = self._config.runes.color_by_spec
		self:ForceUpdate()
	end

	local function element_UpdateSortOrder(self)
		self.sortOrder = self._config.runes.sort_order
		self:ForceUpdate()
	end

	local function frame_UpdateRunes(self)
		local element = self.Runes
		element:UpdateConfig()
		element:UpdateColors()
		element:UpdateSortOrder()

		local orientation = element._config.orientation
		local layout

		if orientation == "HORIZONTAL" then
			layout = E:CalcSegmentsSizes(element:GetWidth(), 2, 6)
		else
			layout = E:CalcSegmentsSizes(element:GetHeight(), 2, 6)
		end

		for i = 1, 6 do
			local bar = element[i]
			bar:SetOrientation(orientation)
			bar:ClearAllPoints()

			if orientation == "HORIZONTAL" then
				bar:SetWidth(layout[i])
				bar:SetPoint("TOP", 0, 0)
				bar:SetPoint("BOTTOM", 0, 0)

				if i == 1 then
					bar:SetPoint("LEFT", 0, 0)
				else
					bar:SetPoint("LEFT", element[i - 1], "RIGHT", 2, 0)
				end
			else
				bar:SetHeight(layout[i])
				bar:SetPoint("LEFT", 0, 0)
				bar:SetPoint("RIGHT", 0, 0)

				if i == 1 then
					bar:SetPoint("BOTTOM", 0, 0)
				else
					bar:SetPoint("BOTTOM", element[i - 1], "TOP", 0, 2)
				end
			end
		end

		if element._config.enabled and not self:IsElementEnabled("Runes") then
			self:EnableElement("Runes")
		elseif not element._config.enabled and self:IsElementEnabled("Runes") then
			self:DisableElement("Runes")
		end

		if self:IsElementEnabled("Runes") then
			element.isEnabled = true

			element:ForceUpdate()
		else
			element.isEnabled = false
			element._active = nil

			element:Hide()
		end
	end

	function UF:CreateRunes(frame)
		local element = createElement(frame, 6, "Rune")
		element:Hide()

		element.PostUpdate = element_PostUpdate
		element.UpdateColors = element_UpdateColors
		element.UpdateConfig = element_UpdateConfig
		element.UpdateSortOrder = element_UpdateSortOrder

		frame.UpdateRunes = frame_UpdateRunes

		return element
	end
end

-- .ClassPower
do
	local ignoredKeys = {
		prediction = true,
		runes = true,
	}

	local function element_PostUpdate(self, _, max, maxChanged, powerType)
		if self._active ~= self.isEnabled or self._powerID ~= powerType or maxChanged then
			if not self.isEnabled then
				self:Hide()
			else
				self:Show()

				local orientation = self[1]:GetOrientation()
				local layout

				if orientation == "HORIZONTAL" then
					layout = E:CalcSegmentsSizes(self:GetWidth(), 2, max)
				else
					layout = E:CalcSegmentsSizes(self:GetHeight(), 2, max)
				end

				for i = 1, max do
					if orientation == "HORIZONTAL" then
						self[i]:SetWidth(layout[i])
					else
						self[i]:SetHeight(layout[i])
					end

					self[i]:SetStatusBarColor(E:GetRGB(C.db.profile.colors.power[powerType]))
				end
			end

			self._active = self.isEnabled
			self._powerID = powerType
		end
	end

	local function element_UpdateConfig(self)
		local unit = self.__owner._unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
	end

	local function element_UpdateColors(self)
		if self._powerID then
			for i = 1, 10 do
				self[i]:SetStatusBarColor(E:GetRGB(C.db.profile.colors.power[self._powerID]))
			end
		end
	end

	local function frame_UpdateClassPower(self)
		local element = self.ClassPower
		element:UpdateConfig()

		local orientation = element._config.orientation
		local max = element.__max
		local layout

		if max then
			if orientation == "HORIZONTAL" then
				layout = E:CalcSegmentsSizes(element:GetWidth(), 2, max)
			else
				layout = E:CalcSegmentsSizes(element:GetHeight(), 2, max)
			end
		end

		for i = 1, 10 do
			local bar = element[i]
			bar:SetOrientation(orientation)
			bar:ClearAllPoints()

			if orientation == "HORIZONTAL" then
				if layout and i <= max then
					bar:SetWidth(layout[i])
				end

				bar:SetPoint("TOP", 0, 0)
				bar:SetPoint("BOTTOM", 0, 0)

				if i == 1 then
					bar:SetPoint("LEFT", 0, 0)
				else
					bar:SetPoint("LEFT", element[i - 1], "RIGHT", 2, 0)
				end
			else
				if layout and i <= max then
					bar:SetHeight(layout[i])
				end

				bar:SetPoint("LEFT", 0, 0)
				bar:SetPoint("RIGHT", 0, 0)

				if i == 1 then
					bar:SetPoint("BOTTOM", 0, 0)
				else
					bar:SetPoint("BOTTOM", element[i - 1], "TOP", 0, 2)
				end
			end
		end

		element:UpdateColors()

		if element._config.enabled and not self:IsElementEnabled("ClassPower") then
			self:EnableElement("ClassPower")
		elseif not element._config.enabled and self:IsElementEnabled("ClassPower") then
			self:DisableElement("ClassPower")
		end

		if self:IsElementEnabled("ClassPower") then
			element:ForceUpdate()
		else
			element._active = nil
			element._powerID = nil

			element:Hide()
		end
	end

	function UF:CreateClassPower(frame)
		local element = createElement(frame, 10, "ClassPower")
		element:Hide()

		element.PostUpdate = element_PostUpdate
		element.UpdateColors = element_UpdateColors
		element.UpdateConfig = element_UpdateConfig

		frame.UpdateClassPower = frame_UpdateClassPower

		return element
	end
end

-- .Stagger
do
	local ignoredKeys = {
		runes = true,
	}

	local function element_Override(self, _, unit)
		if unit and unit ~= self.unit then return end

		local element = self.Stagger

		local max = UnitHealthMax("player")
		local cur = UnitStagger("player")

		element:SetMinMaxValues(0, max)
		element:SetValue(cur)
		element:SetStatusBarColor(E:GetGradientAsRGB(cur / max, C.db.profile.colors.power.STAGGER))

		element.GainLossIndicators:Update(cur, max)
	end

	local function element_UpdateConfig(self)
		local unit = self.__owner._unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
	end

	local function element_UpdateGainLossThreshold(self)
		self.GainLossIndicators.threshold = self._config.change_threshold
	end

	local function frame_UpdateStagger(self)
		local element = self.Stagger
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)

		element.GainLossIndicators:UpdatePoints(element._config.orientation)
		element:UpdateGainLossThreshold()

		if element._config.enabled and not self:IsElementEnabled("Stagger") then
			self:EnableElement("Stagger")
		elseif not element._config.enabled and self:IsElementEnabled("Stagger") then
			self:DisableElement("Stagger")
		end

		if self:IsElementEnabled("Stagger") then
			element:ForceUpdate()
		else
			element:Hide()
		end
	end

	function UF:CreateStagger(frame)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E:SmoothBar(element)
		element:Hide()

		element.GainLossIndicators = E:CreateGainLossIndicators(element)

		element.Override = element_Override
		element.UpdateConfig = element_UpdateConfig
		element.UpdateGainLossThreshold = element_UpdateGainLossThreshold

		frame.UpdateStagger = frame_UpdateStagger

		return element
	end
end
