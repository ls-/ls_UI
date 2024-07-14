local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

local function onValueChanged(self, value)
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
			self:SetAlpha(0.5)

			self._active = false
		end
	end
end

local function createElement(parent, num, name, ...)
	local element = Mixin(CreateFrame("Frame", nil, parent), ...)
	element:SetScript("OnSizeChanged", element.Layout)
	element:SetFrameLevel(parent:GetFrameLevel() + 1)
	element:Hide()

	for i = 1, num do
		local bar = CreateFrame("StatusBar", "$parent" .. name .. i, element)
		bar:SetFrameLevel(element:GetFrameLevel())
		bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E.StatusBars:Capture(bar, "power")
		bar:SetScript("OnValueChanged", onValueChanged)
		bar:SetPoint("TOP", 0, 0)
		bar:SetPoint("BOTTOM", 0, 0)
		bar:SetAlpha(0.5)
		element[i] = bar

		if i == 1 then
			bar:SetPoint("LEFT", 0, 0)
		else
			bar:SetPoint("LEFT", element[i - 1], "RIGHT", 2, 0)
		end

		local hl = element:CreateTexture(nil, "BACKGROUND", nil, -8)
		hl:SetAllPoints(bar)
		hl:SetColorTexture(0, 0, 0, 0)
		bar.Highlight = hl

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

		if i < num then
			local sep = element:CreateTexture(nil, "OVERLAY")
			sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
			sep:SetVertTile(true)
			sep:SetTexCoord(2 / 16, 14 / 16, 0 / 8, 8 / 8)
			sep:SetSize(12 / 2, 0)
			sep:SetPoint("TOP", 0, 0)
			sep:SetPoint("BOTTOM", 0, 0)
			sep:SetPoint("LEFT", bar, "RIGHT", -2, 0)
			sep:SetSnapToPixelGrid(false)
			sep:SetTexelSnappingBias(0)
			sep:Hide()
			bar.Sep = sep
		end
	end

	return element
end

local element_proto = {}

function element_proto:Layout()
	local num = self.__max or #self

	local sizes = E:CalcSegmentsSizes(self:GetWidth(), 2, num)

	for i = 1, num do
		self[i]:SetWidth(sizes[i])
	end

	for i = 1, #self - 1 do
		self[i].Sep:SetShown(i < num)
	end
end

function element_proto:UpdateTextures()
	for i = 1, #self do
		self[i]:UpdateStatusBarTexture()
	end
end

-- .Runes
do
	local ignoredKeys = {
		prediction = true,
	}

	local runes_proto = {}

	function runes_proto:PostUpdate()
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

	function runes_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
	end

	function runes_proto:UpdateColors()
		self.colorSpec = self._config.runes.color_by_spec

		if self.__owner:IsElementEnabled("Runes") then
			self:ForceUpdate()
		end
	end

	function runes_proto:UpdateSortOrder()
		self.sortOrder = self._config.runes.sort_order

		if self.__owner:IsElementEnabled("Runes") then
			self:ForceUpdate()
		end
	end

	local frame_proto = {}

	function frame_proto:UpdateRunes()
		local element = self.Runes
		element:UpdateConfig()
		element:Layout()
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSortOrder()

		self.Insets.Top:Release(element)

		if element._config.enabled and not self:IsElementEnabled("Runes") then
			self:EnableElement("Runes")
		elseif not element._config.enabled and self:IsElementEnabled("Runes") then
			self:DisableElement("Runes")
		end

		if self:IsElementEnabled("Runes") then
			self.Insets.Top:Capture(element, 0, 0, 0, 2)

			element.isEnabled = true

			element:ForceUpdate()
		else
			element.isEnabled = false
			element._active = nil

			element:Hide()
		end
	end

	function UF:CreateRunes(frame)
		Mixin(frame, frame_proto)

		return createElement(frame, 6, "Rune", element_proto, runes_proto)
	end
end

-- .ClassPower
do
	local ignoredKeys = {
		prediction = true,
		runes = true,
	}

	local class_power_proto = {}

	function class_power_proto:PostUpdate(_, max, maxChanged, powerType, ...)
		if self._active ~= self.__isEnabled or self._powerID ~= powerType or maxChanged then
			if not self.__isEnabled then
				self:Hide()
			else
				self:Show()
				self:Layout()
			end

			self._active = self.__isEnabled
			self._powerID = powerType
		end

		if self._active then
			for i = 1, max do
				self[i]:SetStatusBarColor(C.db.global.colors.power[powerType]:GetRGB())
				self[i].Highlight:SetColorTexture(0, 0, 0, 0)
			end

			-- charged points
			for _, i in next, {...} do
				self[i]:SetStatusBarColor(C.db.global.colors.power.COMBO_POINTS_CHARGED:GetRGB())
				self[i].Highlight:SetColorTexture(C.db.global.colors.power.COMBO_POINTS_CHARGED:GetRGBA(0.4))
			end
		end
	end

	function class_power_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
	end

	function class_power_proto:UpdateColors()
		if self._powerID then
			for i = 1, #self do
				self[i]:SetStatusBarColor(C.db.global.colors.power[self._powerID]:GetRGB())
			end
		end
	end

	local frame_proto = {}

	function frame_proto:UpdateClassPower()
		local element = self.ClassPower
		element:UpdateConfig()
		element:Layout()
		element:UpdateColors()
		element:UpdateTextures()

		self.Insets.Top:Release(element)

		if element._config.enabled and not self:IsElementEnabled("ClassPower") then
			self:EnableElement("ClassPower")
		elseif not element._config.enabled and self:IsElementEnabled("ClassPower") then
			self:DisableElement("ClassPower")
		end

		if self:IsElementEnabled("ClassPower") then
			self.Insets.Top:Capture(element, 0, 0, 0, 2)

			element:ForceUpdate()
		else
			element._active = nil
			element._powerID = nil

			element:Hide()
		end
	end

	function UF:CreateClassPower(frame)
		Mixin(frame, frame_proto)

		return createElement(frame, 10, "ClassPower", element_proto, class_power_proto)
	end
end

-- .Stagger
do
	local ignoredKeys = {
		runes = true,
	}

	local stagger_proto = {}

	function stagger_proto:UpdateColor(_, unit)
		if unit and unit ~= self.unit then return end
		local element = self.Stagger

		element:SetStatusBarColor(E:GetGradientAsRGB((element.cur or 0) / (element.max or 1), C.db.global.colors.power.STAGGER))
	end

	function stagger_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].class_power, self._config, ignoredKeys)
	end

	function stagger_proto:UpdateColors()
		if self.__owner:IsElementEnabled("Stagger") then
			self:ForceUpdate()
		end
	end

	function stagger_proto:UpdateTextures()
		self:UpdateStatusBarTexture()
	end

	function stagger_proto:UpdateSmoothing()
		if C.db.profile.units.change.smooth then
			E:SmoothBar(self)
		else
			E:DesmoothBar(self)
		end
	end

	local frame_proto = {}

	function frame_proto:UpdateStagger()
		local element = self.Stagger
		element:UpdateConfig()
		element:UpdateTextures()
		element:UpdateSmoothing()

		self.Insets.Top:Release(element)

		if element._config.enabled and not self:IsElementEnabled("Stagger") then
			self:EnableElement("Stagger")
		elseif not element._config.enabled and self:IsElementEnabled("Stagger") then
			self:DisableElement("Stagger")
		end

		if self:IsElementEnabled("Stagger") then
			self.Insets.Top:Capture(element, 0, 0, 0, 2)

			element:ForceUpdate()
		end
	end

	function UF:CreateStagger(frame)
		Mixin(frame, frame_proto)

		local element = Mixin(CreateFrame("StatusBar", nil, frame), stagger_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E.StatusBars:Capture(element, "power")
		element:SetFrameLevel(frame:GetFrameLevel() + 1)
		element:Hide()

		return element
	end
end
