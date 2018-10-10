local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Blizz
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

	local function element_PostUpdate(element, unit)
		if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			element:SetMinMaxValues(0, 1)
			element:SetValue(0)
		end
	end

	local function element_UpdateConfig(element)
		element._config = E:CopyTable(element.__owner._config.health, element._config, ignoredKeys)
	end

	local function element_UpdateColorSettings(element)
		element.colorClass = element._config.color.class
		element.colorReaction = element._config.color.reaction
		element:ForceUpdate()
	end

	local function element_UpdateFontObjects(element)
		updateFontObject(element.__owner, element.Text, element._config.text)
	end

	local function element_UpdateTextPoints(element)
		updateTextPoint(element.__owner, element.Text, element._config.text.point1)
	end

	local function element_UpdateTags(element)
		updateTag(element.__owner, element.Text, element._config.enabled and element._config.text.tag or "")
	end

	local function frame_UpdateHealth(self)
		local element = self.Health
		element:UpdateConfig()
		element:SetOrientation(element._config.orientation)
		element:UpdateColorSettings()
		element:UpdateFontObjects()
		element:UpdateTextPoints()
		element:UpdateTags()

		if element.ForceUpdate then
			element:ForceUpdate()
		end
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

		element.colorHealth = true
		element.colorTapping = true
		element.colorDisconnected = true
		element.PostUpdate = element_PostUpdate
		element.UpdateColorSettings = element_UpdateColorSettings
		element.UpdateConfig = element_UpdateConfig
		element.UpdateFontObjects = element_UpdateFontObjects
		element.UpdateTags = element_UpdateTags
		element.UpdateTextPoints = element_UpdateTextPoints

		frame.UpdateHealth = frame_UpdateHealth

		return element
	end
end

-- .HealthPrediction
do
	local function element_UpdateConfig(element)
		element._config = E:CopyTable(element.__owner._config.health.prediction, element._config)
		element._config.orientation = element.__owner._config.health.orientation
	end

	local function element_UpdateFontObjects(element)
		updateFontObject(element.__owner, element.absorbBar.Text, element._config.absorb_text)
		updateFontObject(element.__owner, element.healAbsorbBar.Text, element._config.heal_absorb_text)
	end

	local function element_UpdateTextPoints(element)
		updateTextPoint(element.__owner, element.absorbBar.Text, element._config.absorb_text.point1)
		updateTextPoint(element.__owner, element.healAbsorbBar.Text, element._config.heal_absorb_text.point1)
	end

	local function element_UpdateTags(element)
		updateTag(element.__owner, element.absorbBar.Text, element._config.enabled and element._config.absorb_text.tag or "")
		updateTag(element.__owner, element.healAbsorbBar.Text, element._config.enabled and element._config.heal_absorb_text.tag or "")
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
		myBar:SetStatusBarColor(M.COLORS.HEALPREDICTION.MY_HEAL:GetRGB())
		E:SmoothBar(myBar)
		parent.MyHeal = myBar

		myBar._texture = myBar:CreateTexture(nil, "ARTWORK")
		myBar._texture:SetAllPoints(myBar:GetStatusBarTexture())
		myBar._texture:SetColorTexture(M.COLORS.HEALPREDICTION.MY_HEAL:GetRGB())

		local otherBar = CreateFrame("StatusBar", nil, parent)
		otherBar:SetFrameLevel(level)
		otherBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		otherBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		E:SmoothBar(otherBar)
		parent.OtherHeal = otherBar

		otherBar._texture = otherBar:CreateTexture(nil, "ARTWORK")
		otherBar._texture:SetAllPoints(otherBar:GetStatusBarTexture())
		otherBar._texture:SetColorTexture(M.COLORS.HEALPREDICTION.OTHER_HEAL:GetRGB())

		local absorbBar = CreateFrame("StatusBar", nil, parent)
		absorbBar:SetFrameLevel(level + 1)
		absorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		absorbBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		E:SmoothBar(absorbBar)
		parent.DamageAbsorb = absorbBar

		local overlay = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		overlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\absorb", true)
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
		healAbsorbBar:SetStatusBarColor(M.COLORS.HEALPREDICTION.HEAL_ABSORB:GetRGB())
		E:SmoothBar(healAbsorbBar)
		parent.HealAbsorb = healAbsorbBar

		healAbsorbBar._texture = healAbsorbBar:CreateTexture(nil, "ARTWORK")
		healAbsorbBar._texture:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
		healAbsorbBar._texture:SetColorTexture(M.COLORS.HEALPREDICTION.HEAL_ABSORB:GetRGB())

		healAbsorbBar.Text = (textParent or parent):CreateFontString(nil, "ARTWORK", "LSFont10")

		frame.UpdateHealthPrediction = frame_UpdateHealthPrediction

		return {
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
			maxOverflow = 1,
			UpdateConfig = element_UpdateConfig,
			UpdateFontObjects = element_UpdateFontObjects,
			UpdateTags = element_UpdateTags,
			UpdateTextPoints = element_UpdateTextPoints,
		}
	end
end
