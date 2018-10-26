local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next

-- Blizz
local UnitGUID = _G.UnitGUID
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local function updateFontObject(_, fontString, config)
	fontString:SetFontObject("LSFont" .. config.size .. (config.outline and "_Outline" or ""))
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

-- .Health
do
	local ignoredKeys = {
		prediction = true,
	}

	local function setStatusBarColorHook(self, r, g, b)
		self._texture:SetColorTexture(r, g, b)
	end

	local function element_PostUpdate(self, unit, cur, max)
		local unitGUID = UnitGUID(unit)
		self.GainLossIndicators:Update(cur, max, unitGUID == self.GainLossIndicators._UnitGUID)
		self.GainLossIndicators._UnitGUID = unitGUID

		if not (self:IsShown() and max and max ~= 0) or not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			self:SetMinMaxValues(0, 1)
			self:SetValue(0)
		end
	end

	local function element_UpdateConfig(self)
		local unit = self.__owner._unit
		self._config = E:CopyTable(C.db.profile.units[unit].health, self._config, ignoredKeys)
	end

	local function element_UpdateColors(self)
		self.colorClass = self._config.color.class
		self.colorReaction = self._config.color.reaction
		self.colorSelection = self.__owner._unit ~= "player"
		self:ForceUpdate()
	end

	local function element_UpdateFontObjects(self)
		updateFontObject(self.__owner, self.Text, self._config.text)
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

	local function frame_UpdateHealth(self)
		local element = self.Health
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColors()
		element:UpdateFontObjects()
		element:UpdateTextPoints()
		element:UpdateTags()
		element:UpdateGainLossColors()
		element:UpdateGainLossPoints()
		element:UpdateGainLossThreshold()
		element:ForceUpdate()
	end

	function UF:CreateHealth(frame, textParent)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		E:SmoothBar(element)

		element._texture = element:CreateTexture(nil, "ARTWORK")
		element._texture:SetAllPoints(element:GetStatusBarTexture())
		hooksecurefunc(element, "SetStatusBarColor", setStatusBarColorHook)

		element.Text = (textParent or element):CreateFontString(nil, "ARTWORK", "LSFont12")

		element.GainLossIndicators = E:CreateGainLossIndicators(element)
		element.GainLossIndicators.Gain = nil

		element.colorHealth = true
		element.colorTapping = true
		element.colorDisconnected = true
		element.PostUpdate = element_PostUpdate
		element.UpdateColors = element_UpdateColors
		element.UpdateConfig = element_UpdateConfig
		element.UpdateFontObjects = element_UpdateFontObjects
		element.UpdateGainLossColors = element_UpdateGainLossColors
		element.UpdateGainLossPoints = element_UpdateGainLossPoints
		element.UpdateGainLossThreshold = element_UpdateGainLossThreshold
		element.UpdateTags = element_UpdateTags
		element.UpdateTextPoints = element_UpdateTextPoints

		frame.UpdateHealth = frame_UpdateHealth

		return element
	end
end

-- .HealthPrediction
do
	local function element_UpdateConfig(self)
		local unit = self.__owner._unit
		self._config = E:CopyTable(C.db.profile.units[unit].health.prediction, self._config)
		self._config.orientation = C.db.profile.units[unit].health.orientation
	end

	local function element_UpdateFontObjects(self)
		updateFontObject(self.__owner, self.absorbBar.Text, self._config.absorb_text)
		updateFontObject(self.__owner, self.healAbsorbBar.Text, self._config.heal_absorb_text)
	end

	local function element_UpdateTextPoints(self)
		updateTextPoint(self.__owner, self.absorbBar.Text, self._config.absorb_text.point1)
		updateTextPoint(self.__owner, self.healAbsorbBar.Text, self._config.heal_absorb_text.point1)
	end

	local function element_UpdateTags(self)
		updateTag(self.__owner, self.absorbBar.Text, self._config.enabled and self._config.absorb_text.tag or "")
		updateTag(self.__owner, self.healAbsorbBar.Text, self._config.enabled and self._config.heal_absorb_text.tag or "")
	end

	local function element_UpdateColors(self)
		self.myBar._texture:SetColorTexture(E:GetRGBA(C.db.profile.colors.prediction.my_heal))
		self.otherBar._texture:SetColorTexture(E:GetRGBA(C.db.profile.colors.prediction.other_heal))
		self.healAbsorbBar._texture:SetColorTexture(E:GetRGBA(C.db.profile.colors.prediction.heal_absorb))
	end

	local function frame_UpdateHealthPrediction(self)
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
		element:UpdateFontObjects()
		element:UpdateTextPoints()
		element:UpdateTags()

		if config.enabled and not self:IsElementEnabled("HealthPrediction") then
			self:EnableElement("HealthPrediction")
		elseif not config.enabled and self:IsElementEnabled("HealthPrediction") then
			self:DisableElement("HealthPrediction")
		end

		if self:IsElementEnabled("HealthPrediction") then
			element:ForceUpdate()
		end
	end

	function UF:CreateHealthPrediction(frame, parent, textParent)
		local level = parent:GetFrameLevel()

		local myBar = CreateFrame("StatusBar", nil, parent)
		myBar:SetFrameLevel(level)
		myBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		myBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		E:SmoothBar(myBar)
		parent.MyHeal = myBar

		myBar._texture = myBar:CreateTexture(nil, "ARTWORK")
		myBar._texture:SetAllPoints(myBar:GetStatusBarTexture())

		local otherBar = CreateFrame("StatusBar", nil, parent)
		otherBar:SetFrameLevel(level)
		otherBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		otherBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		E:SmoothBar(otherBar)
		parent.OtherHeal = otherBar

		otherBar._texture = otherBar:CreateTexture(nil, "ARTWORK")
		otherBar._texture:SetAllPoints(otherBar:GetStatusBarTexture())

		local absorbBar = CreateFrame("StatusBar", nil, parent)
		absorbBar:SetFrameLevel(level + 1)
		absorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		absorbBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		E:SmoothBar(absorbBar)
		parent.DamageAbsorb = absorbBar

		local overlay = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		overlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\absorb", "REPEAT", "REPEAT")
		overlay:SetHorizTile(true)
		overlay:SetVertTile(true)
		overlay:SetAllPoints(absorbBar:GetStatusBarTexture())
		absorbBar.Overlay = overlay

		absorbBar.Text = (textParent or parent):CreateFontString(nil, "ARTWORK", "LSFont10")

		local healAbsorbBar = CreateFrame("StatusBar", nil, parent)
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetFrameLevel(level + 1)
		healAbsorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		healAbsorbBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		E:SmoothBar(healAbsorbBar)
		parent.HealAbsorb = healAbsorbBar

		healAbsorbBar._texture = healAbsorbBar:CreateTexture(nil, "ARTWORK")
		healAbsorbBar._texture:SetAllPoints(healAbsorbBar:GetStatusBarTexture())

		healAbsorbBar.Text = (textParent or parent):CreateFontString(nil, "ARTWORK", "LSFont10")

		frame.UpdateHealthPrediction = frame_UpdateHealthPrediction

		return {
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
			maxOverflow = 1,
			UpdateColors = element_UpdateColors,
			UpdateConfig = element_UpdateConfig,
			UpdateFontObjects = element_UpdateFontObjects,
			UpdateTags = element_UpdateTags,
			UpdateTextPoints = element_UpdateTextPoints,
		}
	end
end
