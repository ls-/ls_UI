local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

local function updateFont(fontString, config)
	fontString:UpdateFont(config.size)
	fontString:SetJustifyH(config.h_alignment)
	fontString:SetJustifyV(config.v_alignment)
	fontString:SetWordWrap(config.word_wrap)
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

	local element_proto = {
		colorHealth = true,
		colorTapping = true,
		colorDisconnected = true,
	}

	function element_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].health, self._config, ignoredKeys)
	end

	function element_proto:UpdateColors()
		self.colorClass = self._config.color.class
		self.colorReaction = self._config.color.reaction
		self:ForceUpdate()
	end

	function element_proto:UpdateFonts()
		updateFont(self.Text, self._config.text)
	end

	function element_proto:UpdateTextPoints()
		updateTextPoint(self.__owner, self.Text, self._config.text.point1)
	end

	function element_proto:UpdateTags()
		updateTag(self.__owner, self.Text, self._config.enabled and self._config.text.tag or "")
	end

	function element_proto:UpdateTextures()
		self:UpdateStatusBarTexture()
	end

	function element_proto:UpdateSmoothing()
		if C.db.profile.units.change.smooth then
			E.StatusBars:Smooth(self)
			E.StatusBars:Smooth(self.TempLoss_)
		else
			E.StatusBars:Desmooth(self)
			E.StatusBars:Desmooth(self.TempLoss_)
		end
	end

	function element_proto:UpdateMaxHealthReduction()
		if self._config.reduction.enabled then
			self.TempLoss = self.TempLoss_
		else
			self.TempLoss = nil
		end

		self.TempLoss_:SetValue(0)
		self.TempLoss_:Show()
	end

	local frame_proto = {}

	function frame_proto:UpdateHealth()
		local element = self.Health
		element:UpdateConfig()
		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateFonts()
		element:UpdateTextPoints()
		element:UpdateSmoothing()
		element:UpdateTags()
		element:UpdateMaxHealthReduction()
		element:ForceUpdate()
	end

	function UF:CreateHealth(frame, textParent)
		Mixin(frame, frame_proto)

		local element = Mixin(CreateFrame("StatusBar", nil, frame), element_proto)
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E.StatusBars:Capture(element, "health")
		element:SetFrameLevel(frame:GetFrameLevel() + 1)
		element:SetClipsChildren(true)
		element._texture = element:GetStatusBarTexture()

		local tempLoss = CreateFrame("StatusBar", nil, frame)
		tempLoss:SetReverseFill(true)
		tempLoss:SetMinMaxValues(0, 1)
		tempLoss:SetFrameLevel(frame:GetFrameLevel() + 1)
		element.TempLoss_ = tempLoss

		tempLoss:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		tempLoss._texture = tempLoss:GetStatusBarTexture()
		tempLoss._texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\reduction", "REPEAT", "REPEAT")
		tempLoss._texture:SetHorizTile(true)
		tempLoss._texture:SetVertTile(true)

		local text = (textParent or element):CreateFontString(nil, "ARTWORK")
		E.FontStrings:Capture(text, "unit")
		element.Text = text

		return element
	end
end

-- .HealthPrediction
do
	local element_proto = {
		maxOverflow = 1,
	}

	function element_proto:UpdateConfig()
		local unit = self.__owner.__unit
		self._config = E:CopyTable(C.db.profile.units[unit].health.prediction, self._config)
	end

	function element_proto:UpdateColors()
		self.myBar:SetStatusBarColor(C.db.global.colors.prediction.my_heal:GetRGB())
		self.otherBar:SetStatusBarColor(C.db.global.colors.prediction.other_heal:GetRGB())
		self.healAbsorbBar:SetStatusBarColor(C.db.global.colors.prediction.heal_absorb:GetRGB())
	end

	function element_proto:UpdateTextures()
		self.myBar:UpdateStatusBarTexture()
		self.otherBar:UpdateStatusBarTexture()
		self.healAbsorbBar:UpdateStatusBarTexture()
	end

	function element_proto:UpdateSmoothing()
		if C.db.profile.units.change.smooth then
			E.StatusBars:Smooth(self.myBar)
			E.StatusBars:Smooth(self.otherBar)
			E.StatusBars:Smooth(self.absorbBar)
			E.StatusBars:Smooth(self.healAbsorbBar)
		else
			E.StatusBars:Desmooth(self.myBar)
			E.StatusBars:Desmooth(self.otherBar)
			E.StatusBars:Desmooth(self.absorbBar)
			E.StatusBars:Desmooth(self.healAbsorbBar)
		end
	end

	local frame_proto = {}

	function frame_proto:UpdateHealthPrediction()
		local element = self.HealthPrediction
		element:UpdateConfig()

		local config = element._config

		local width = self.Health:GetWidth()
		width = width > 0 and width or self:GetWidth()

		element.myBar:SetWidth(width)
		element.otherBar:SetWidth(width)
		element.absorbBar:SetWidth(width)
		element.healAbsorbBar:SetWidth(width)

		element:UpdateColors()
		element:UpdateTextures()
		element:UpdateSmoothing()

		if config.enabled and not self:IsElementEnabled("HealthPrediction") then
			self:EnableElement("HealthPrediction")
		elseif not config.enabled and self:IsElementEnabled("HealthPrediction") then
			self:DisableElement("HealthPrediction")
		end

		if self:IsElementEnabled("HealthPrediction") then
			element:ForceUpdate()
		end
	end

	function UF:CreateHealthPrediction(frame, parent)
		Mixin(frame, frame_proto)

		local level = parent:GetFrameLevel()

		local myBar = CreateFrame("StatusBar", nil, parent)
		myBar:SetFrameLevel(level)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", frame.Health:GetStatusBarTexture(), "RIGHT")
		parent.MyHeal = myBar

		myBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E.StatusBars:Capture(myBar, "health")
		myBar._texture = myBar:GetStatusBarTexture()

		local otherBar = CreateFrame("StatusBar", nil, parent)
		otherBar:SetFrameLevel(level)
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		parent.OtherHeal = otherBar

		otherBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E.StatusBars:Capture(otherBar, "health")
		otherBar._texture = otherBar:GetStatusBarTexture()

		local absorbBar = CreateFrame("StatusBar", nil, parent)
		absorbBar:SetFrameLevel(level + 1)
		absorbBar:SetPoint("TOP")
		absorbBar:SetPoint("BOTTOM")
		absorbBar:SetPoint("LEFT", otherBar:GetStatusBarTexture(), "RIGHT")
		parent.DamageAbsorb = absorbBar

		absorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		absorbBar._texture = absorbBar:GetStatusBarTexture()
		absorbBar._texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\absorb", "REPEAT", "REPEAT")
		absorbBar._texture:SetHorizTile(true)
		absorbBar._texture:SetVertTile(true)

		local healAbsorbBar = CreateFrame("StatusBar", nil, parent)
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetFrameLevel(level + 1)
		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetPoint("RIGHT", frame.Health:GetStatusBarTexture(), "RIGHT")
		parent.HealAbsorb = healAbsorbBar

		healAbsorbBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		E.StatusBars:Capture(healAbsorbBar, "health")
		healAbsorbBar._texture = healAbsorbBar:GetStatusBarTexture()

		return Mixin({
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
		}, element_proto)
	end
end
