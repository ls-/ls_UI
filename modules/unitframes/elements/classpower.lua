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
		local bar = CreateFrame("StatusBar", "$parent"..name..i, element)
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
	local function element_PostUpdate(self)
		if not self.isEnabled then
			self:Hide()

			self._active = false
		else
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

	local function frame_UpdateRunes(self)
		local config = self._config.class_power
		local element = self.Runes
		local width, height = element:GetSize()
		local layout

		if config.orientation == "HORIZONTAL" then
			layout = E:CalcSegmentsSizes(width, 2, 6)
		else
			layout = E:CalcSegmentsSizes(height, 2, 6)
		end

		for i = 1, 6 do
			local bar = element[i]

			bar:SetOrientation(config.orientation)
			bar:ClearAllPoints()

			if config.orientation == "HORIZONTAL" then
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

		if config.enabled and not self:IsElementEnabled("Runes") then
			self:EnableElement("Runes")

			element.isEnabled = true
		elseif not config.enabled and self:IsElementEnabled("Runes") then
			self:DisableElement("Runes")

			element.isEnabled = false
		end

		element:ForceUpdate()
	end

	function UF:CreateRunes(frame)
		local element = createElement(frame, 6, "Rune")
		element:Hide()

		element.isEnabled = true
		element.colorSpec = true
		element.PostUpdate = element_PostUpdate

		frame.UpdateRunes = frame_UpdateRunes

		return element
	end
end

do
	local function element_PostUpdate(self, _, max, maxChanged, powerType)
		if self._state ~= self.isEnabled or self._powerID ~= powerType or maxChanged then
			if not self.isEnabled then
				self:Hide()

				if self.UpdateContainer then
					self:UpdateContainer(false, 0)
				end
			elseif self.isEnabled or self._powerID ~= powerType or maxChanged then
				self:Show()

				local orientation = self[1]:GetOrientation()
				local layout

				if orientation == "HORIZONTAL" then
					layout = E:CalcSegmentsSizes(self:GetWidth(), 2, max)
				else
					layout = E:CalcSegmentsSizes(self:GetHeight(), 2, max)
				end

				for i = 1, max do
					local bar = self[i]

					if orientation == "HORIZONTAL" then
						bar:SetWidth(layout[i])
					else
						bar:SetHeight(layout[i])
					end

					bar:SetStatusBarColor(M.COLORS.POWER[powerType]:GetRGB())
				end

				if self.UpdateContainer then
					self:UpdateContainer(true, max)
				end
			end

			self._state = self.isEnabled
			self._powerID = powerType
		end
	end

	local function frame_UpdateClassPower(self)
		local config = self._config.class_power
		local element = self.ClassPower
		local width, height = element:GetSize()

		for i = 1, 10 do
			local bar = element[i]

			bar:SetOrientation(config.orientation)
			bar:ClearAllPoints()

			if config.orientation == "HORIZONTAL" then
				bar:SetHeight(height)
				bar:SetPoint("TOP", 0, 0)
				bar:SetPoint("BOTTOM", 0, 0)

				if i == 1 then
					bar:SetPoint("LEFT", 0, 0)
				else
					bar:SetPoint("LEFT", element[i - 1], "RIGHT", 2, 0)
				end
			else
				bar:SetWidth(width)
				bar:SetPoint("LEFT", 0, 0)
				bar:SetPoint("RIGHT", 0, 0)

				if i == 1 then
					element[i]:SetPoint("BOTTOM", 0, 0)
				else
					element[i]:SetPoint("BOTTOM", element[i - 1], "TOP", 0, 2)
				end
			end
		end

		if config.enabled and not self:IsElementEnabled("ClassPower") then
			self:EnableElement("ClassPower")
		elseif not config.enabled and self:IsElementEnabled("ClassPower") then
			self:DisableElement("ClassPower")
		end

		if element.isEnabled then
			element._state = nil
			element._powerID = nil
			element:ForceUpdate()
		end
	end

	function UF:CreateClassPower(frame)
		local element = createElement(frame, 10, "ClassPower")
		element:Hide()

		element.PostUpdate = element_PostUpdate

		frame.UpdateClassPower = frame_UpdateClassPower

		return element
	end
end

-- .Stagger
do
	local function element_Override(self, _, unit)
		if unit and unit ~= self.unit then return end

		local element = self.Stagger

		local max = UnitHealthMax("player")
		local cur = UnitStagger("player")
		local r, g, b = M.COLORS.POWER.STAGGER:GetRGB(cur / max)

		element:SetMinMaxValues(0, max)
		element:SetValue(cur)
		element:SetStatusBarColor(r, g, b)

		if element:IsShown() then
			element:UpdateGainLoss(cur, max)
		end
	end

	local function frame_UpdateStagger(self)
		local config = self._config.class_power
		local element = self.Stagger

		element:SetOrientation(config.orientation)

		E:ReanchorGainLossIndicators(element, config.orientation)

		if config.enabled and not self:IsElementEnabled("Stagger") then
			self:EnableElement("Stagger")

			element.isEnabled = true
		elseif not config.enabled and self:IsElementEnabled("Stagger") then
			self:DisableElement("Stagger")

			element.isEnabled = false
		end

		if element.isEnabled then
			element:ForceUpdate()
		end
	end

	function UF:CreateStagger(frame)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:Hide()

		E:SmoothBar(element)
		E:CreateGainLossIndicators(element)

		element.element_Override = element_Override

		frame.UpdateStagger = frame_UpdateStagger

		return element
	end
end
