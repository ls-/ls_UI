local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

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
			self:SetAlpha(0.5)

			self._active = false
		end
	end
end

local function createElement(parent, num, name, ...)
	local element = Mixin(CreateFrame("Frame", nil, parent), ...)
	element:SetScript("OnSizeChanged", element.Layout)
	element:Hide()

	for i = 1, num do
		local bar = CreateFrame("StatusBar", "$parent" .. name .. i, element)
		bar:SetFrameLevel(element:GetFrameLevel())
		bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		bar:SetScript("OnValueChanged", bar_OnValueChanged)
		element[i] = bar

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
	local orientation = self._config.orientation
	local num = self.__max or #self

	local sizes
	if orientation == "HORIZONTAL" then
		sizes = E:CalcSegmentsSizes(self:GetWidth(), 2, num)
	else
		sizes = E:CalcSegmentsSizes(self:GetHeight(), 2, num)
	end

	local bar, sep
	for i = 1, num do
		bar = self[i]
		bar:SetOrientation(orientation)
		bar:ClearAllPoints()

		if orientation == "HORIZONTAL" then
			bar:SetWidth(sizes[i])
			bar:SetPoint("TOP", 0, 0)
			bar:SetPoint("BOTTOM", 0, 0)

			if i == 1 then
				bar:SetPoint("LEFT", 0, 0)
			else
				bar:SetPoint("LEFT", self[i - 1], "RIGHT", 2, 0)
			end

			if i < num then
				sep = bar.Sep
				sep:ClearAllPoints()
				sep:SetPoint("TOP", 0, 0)
				sep:SetPoint("BOTTOM", 0, 0)
				sep:SetPoint("LEFT", bar, "RIGHT", -2, 0)
				sep:SetWidth(12 / 2)
				sep:SetTexCoord(0.0625, 0, 0.0625, 1, 0.8125, 0, 0.8125, 1)
				sep:Show()
			end
		else
			bar:SetHeight(sizes[i])
			bar:SetPoint("LEFT", 0, 0)
			bar:SetPoint("RIGHT", 0, 0)

			if i == 1 then
				bar:SetPoint("BOTTOM", 0, 0)
			else
				bar:SetPoint("BOTTOM", self[i - 1], "TOP", 0, 2)
			end

			if i < num then
				sep = bar.Sep
				sep:ClearAllPoints()
				sep:SetPoint("LEFT", 0, 0)
				sep:SetPoint("RIGHT", 0, 0)
				sep:SetPoint("BOTTOM", bar, "TOP", 0, -2)
				sep:SetHeight(12 / 2)
				sep:SetTexCoord(0.8125, 0, 0.0625, 0, 0.8125, 1, 0.0625, 1)
				sep:Show()
			end
		end
	end
end

function element_proto:UpdateTextures()
	for i = 1, #self do
		if self._config.orientation == "HORIZONTAL" then
			self[i]:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.horiz))
		else
			self[i]:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.vert))
		end
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
		self:ForceUpdate()
	end

	function runes_proto:UpdateSortOrder()
		self.sortOrder = self._config.runes.sort_order
		self:ForceUpdate()
	end

	local frame_proto = {}

	function frame_proto:UpdateRunes()
		local element = self.Runes
		element:UpdateConfig()
		element:Layout()
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSortOrder()

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

				local orientation = self[1]:GetOrientation()

				local sizes
				if orientation == "HORIZONTAL" then
					sizes = E:CalcSegmentsSizes(self:GetWidth(), 2, max)
				else
					sizes = E:CalcSegmentsSizes(self:GetHeight(), 2, max)
				end

				for i = 1, max do
					if orientation == "HORIZONTAL" then
						self[i]:SetWidth(sizes[i])
					else
						self[i]:SetHeight(sizes[i])
					end

					if i < max then
						self[i].Sep:Show()
					end
				end

				for i = max, #self - 1 do
					if i > 0 then
						self[i].Sep:Hide()
					end
				end
			end

			self._active = self.__isEnabled
			self._powerID = powerType
		end

		if self._active then
			for i = 1, max do
				self[i]:SetStatusBarColor(E:GetRGB(C.db.global.colors.power[powerType]))
				self[i].Highlight:SetColorTexture(0, 0, 0, 0)
			end

			for _, i in next, {...} do
				self[i]:SetStatusBarColor(E:GetRGB(C.db.global.colors.power.CHI))
				self[i].Highlight:SetColorTexture(E:GetRGBA(C.db.global.colors.power.CHI, 0.4))
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
				self[i]:SetStatusBarColor(E:GetRGB(C.db.global.colors.power[self._powerID]))
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
		self:ForceUpdate()
	end

	function stagger_proto:UpdateTextures()
		if self._config.orientation == "HORIZONTAL" then
			self:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.horiz))
		else
			self:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.vert))
		end
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
		element:SetOrientation(element._config.orientation)
		element:UpdateTextures()
		element:UpdateSmoothing()

		if element._config.enabled and not self:IsElementEnabled("Stagger") then
			self:EnableElement("Stagger")
		elseif not element._config.enabled and self:IsElementEnabled("Stagger") then
			self:DisableElement("Stagger")
		end

		if self:IsElementEnabled("Stagger") then
			element:ForceUpdate()
		end
	end

	function UF:CreateStagger(frame)
		Mixin(frame, frame_proto)

		local element = Mixin(CreateFrame("StatusBar", nil, frame), stagger_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:Hide()

		return element
	end
end
