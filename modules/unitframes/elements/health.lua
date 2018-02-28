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
-- .Health
do
	local function setStatusBarColorHook(self, r, g, b)
		self._texture:SetColorTexture(r, g, b)
	end

	local function element_PostUpdate(element, unit)
		if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
			element:SetMinMaxValues(0, 1)
			element:SetValue(0)
		end
	end

	local function frame_UpdateHealth(self)
		local config = self._config.health
		local element = self.Health

		element:SetOrientation(config.orientation)

		if config.color then
			element.colorClass = config.color.class
			element.colorReaction = config.color.reaction
		end

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

		if element.ForceUpdate then
			element:ForceUpdate()
		end
	end

	function UF:CreateHealth(frame, text, textFontObject, textParent)
		local element = CreateFrame("StatusBar", nil, frame)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)

		E:SmoothBar(element)

		element._texture = element:CreateTexture(nil, "ARTWORK")
		element._texture:SetAllPoints(element:GetStatusBarTexture())

		hooksecurefunc(element, "SetStatusBarColor", setStatusBarColorHook)

		if text then
			text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
			element.Text = text
		end

		element.colorHealth = true
		element.colorTapping = true
		element.colorDisconnected = true
		element.PostUpdate = element_PostUpdate

		frame.UpdateHealth = frame_UpdateHealth

		return element
	end
end

-- .HealthPrediction
do
	local function frame_UpdateHealthPrediction(self)
		local config = self._config.health
		local element = self.HealthPrediction
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

		if absorbBar.Text then
			absorbBar.Text:SetJustifyV(config.prediction.absorb_text.v_alignment or "MIDDLE")
			absorbBar.Text:SetJustifyH(config.prediction.absorb_text.h_alignment or "CENTER")
			absorbBar.Text:ClearAllPoints()

			local point1 = config.prediction.absorb_text.point1

			if point1 and point1.p then
				absorbBar.Text:SetPoint(point1.p, E:ResolveAnchorPoint(self, point1.anchor), point1.rP, point1.x, point1.y)
			end

			self:Tag(absorbBar.Text, config.prediction.enabled and config.prediction.absorb_text.tag or "")
		end

		if healAbsorbBar.Text then
			healAbsorbBar.Text:SetJustifyV(config.prediction.heal_absorb_text.v_alignment or "MIDDLE")
			healAbsorbBar.Text:SetJustifyH(config.prediction.heal_absorb_text.h_alignment or "CENTER")
			healAbsorbBar.Text:ClearAllPoints()

			local point1 = config.prediction.heal_absorb_text.point1

			if point1 and point1.p then
				healAbsorbBar.Text:SetPoint(point1.p, E:ResolveAnchorPoint(self, point1.anchor), point1.rP, point1.x, point1.y)
			end

			self:Tag(healAbsorbBar.Text, config.prediction.enabled and config.prediction.heal_absorb_text.tag or "")
		end

		if config.prediction.enabled and not self:IsElementEnabled("HealthPrediction") then
			self:EnableElement("HealthPrediction")
		elseif not config.prediction.enabled and self:IsElementEnabled("HealthPrediction") then
			self:DisableElement("HealthPrediction")
		end

		if self:IsElementEnabled("HealthPrediction") then
			element:ForceUpdate()
		end
	end

	function UF:CreateHealthPrediction(frame, parent, text, textFontObject, textParent)
		local level = parent:GetFrameLevel()

		local myBar = CreateFrame("StatusBar", nil, parent)
		myBar:SetFrameLevel(level)
		myBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		myBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		myBar:SetStatusBarColor(M.COLORS.HEALPREDICTION.MY_HEAL:GetRGB())
		parent.MyHeal = myBar

		myBar._texture = myBar:CreateTexture(nil, "ARTWORK")
		myBar._texture:SetAllPoints(myBar:GetStatusBarTexture())
		myBar._texture:SetColorTexture(M.COLORS.HEALPREDICTION.MY_HEAL:GetRGB())

		local otherBar = CreateFrame("StatusBar", nil, parent)
		otherBar:SetFrameLevel(level)
		otherBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		otherBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		parent.OtherHeal = otherBar

		otherBar._texture = otherBar:CreateTexture(nil, "ARTWORK")
		otherBar._texture:SetAllPoints(otherBar:GetStatusBarTexture())
		otherBar._texture:SetColorTexture(M.COLORS.HEALPREDICTION.OTHER_HEAL:GetRGB())

		local absorbBar = CreateFrame("StatusBar", nil, parent)
		absorbBar:SetFrameLevel(level + 1)
		absorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		absorbBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		parent.DamageAbsorb = absorbBar

		local overlay = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		overlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\absorb", true)
		overlay:SetHorizTile(true)
		overlay:SetVertTile(true)
		overlay:SetAllPoints(absorbBar:GetStatusBarTexture())
		absorbBar.Overlay = overlay

		local healAbsorbBar = CreateFrame("StatusBar", nil, parent)
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetFrameLevel(level + 1)
		healAbsorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		healAbsorbBar:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
		healAbsorbBar:SetStatusBarColor(M.COLORS.HEALPREDICTION.HEAL_ABSORB:GetRGB())
		parent.HealAbsorb = healAbsorbBar

		healAbsorbBar._texture = healAbsorbBar:CreateTexture(nil, "ARTWORK")
		healAbsorbBar._texture:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
		healAbsorbBar._texture:SetColorTexture(M.COLORS.HEALPREDICTION.HEAL_ABSORB:GetRGB())

		E:SmoothBar(myBar)
		E:SmoothBar(otherBar)
		E:SmoothBar(healAbsorbBar)

		if text then
			text = (textParent or parent):CreateFontString(nil, "ARTWORK", textFontObject)
			absorbBar.Text = text

			text = (textParent or parent):CreateFontString(nil, "ARTWORK", textFontObject)
			healAbsorbBar.Text = text
		end

		frame.UpdateHealthPrediction = frame_UpdateHealthPrediction

		return {
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
			maxOverflow = 1,
		}
	end
end
