local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

--Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local unpack = _G.unpack

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

local pip_proto = {}

function pip_proto:OnShow()
	self.Texture:SetAlpha(0.33)
	self.Texture:Show()
end

function pip_proto:OnHide()
	self.Texture:Hide()
end

local element_proto = {
	timeToHold = 0.4,
}

function element_proto:CreatePip(stage)
	local pip = Mixin(CreateFrame("Frame", "$parentStage" .. stage, self), pip_proto)
	pip:SetScript("OnShow", pip.OnShow)
	pip:SetScript("OnHide", pip.OnHide)
	pip:SetFrameLevel(self:GetFrameLevel() + 1)
	pip:SetWidth(7)
	pip:Hide()

	local sep = pip:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetVertTile(true)
	sep:SetTexCoord(2 / 16, 14 / 16, 0 / 8, 8 / 8)
	sep:SetSize(12 / 2, 0)
	sep:SetPoint("TOP", 0, 0)
	sep:SetPoint("BOTTOM", 0, 0)
	sep:SetSnapToPixelGrid(false)
	sep:SetTexelSnappingBias(0)
	pip.Sep = sep

	local texture = self:CreateTexture(nil, "BACKGROUND")
	texture:SetAlpha(0.33)
	texture:SetPoint("LEFT", pip, "RIGHT", -2, 0)
	texture:SetPoint("TOP", 0, 0)
	texture:SetPoint("BOTTOM", 0, 0)
	texture:Hide()
	pip.Texture = texture

	local ag = texture:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	pip.InAnim = ag

	local anim = ag:CreateAnimation("Alpha")
	anim:SetOrder(1)
	anim:SetDuration(0.1)
	anim:SetFromAlpha(0.33)
	anim:SetToAlpha(0)
	anim:SetSmoothing("OUT")

	return pip
end

function element_proto:PostUpdatePips(numStages)
	for i = 1, numStages do
		self.Pips[i].Texture:SetColorTexture(unpack(self.stageColors[numStages][i]))

		if i == numStages then
			self.Pips[i].Texture:SetPoint("RIGHT", self, "RIGHT", -2, 0)
		else
			self.Pips[i].Texture:SetPoint("RIGHT", self.Pips[i + 1], "LEFT", 2, 0)
		end
	end
end

function element_proto:PostUpdateStage(stage)
	self:SetSmoothStatusBarColor(unpack(self.stageColors[self.numStages][stage]))

	self.Pips[stage].InAnim:Play()
end

function element_proto:PostCastStart()
	if self.notInterruptible then
		self:SetStatusBarColor(C.db.global.colors.castbar.notinterruptible:GetRGB())

		if self.Icon then
			self.Icon:SetDesaturated(true)
		end
	else
		if self.casting then
			self:SetStatusBarColor(C.db.global.colors.castbar.casting:GetRGB())
		elseif self.channeling then
			self:SetStatusBarColor(C.db.global.colors.castbar.channeling:GetRGB())
		elseif self.empowering then
			self.Text:SetText("")
			self:SetStatusBarColor(C.db.global.colors.castbar.empowering:GetRGB())
		end

		if self.Icon then
			self.Icon:SetDesaturated(false)
		end
	end
end

function element_proto:PostCastFail()
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetStatusBarColor(C.db.global.colors.castbar.failed:GetRGB())

	self.Time:SetText("")
end

function element_proto:CustomTimeText(duration)
	if self.max > 600 then
		return self.Time:SetText("")
	end

	if self.casting or self.empowering then
		duration = self.max - duration
	end

	self.Time:SetFormattedText("%.1f ", duration)
end

function element_proto:CustomDelayText(duration)
	if self.channeling then
		self.Time:SetFormattedText("%.1f|cffdc4436-%.1f|r ", duration, m_abs(self.delay))
	else
		self.Time:SetFormattedText("%.1f|cffdc4436+%.1f|r ", self.max - duration, m_abs(self.delay))
	end
end

function element_proto:SetSmoothStatusBarColor(r, g, b, a)
	local color = self.ColorAnim.color
	a = a or 1

	if color.r == r and color.g == g and color.b == b and color.a == a then return end

	color.r, color.g, color.b, color.a = self:GetStatusBarColor()
	self.ColorAnim.Anim:SetStartColor(color)

	color.r, color.g, color.b, color.a = r, g, b, a
	self.ColorAnim.Anim:SetEndColor(color)

	self.ColorAnim:Play()
end

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].castbar, self._config)
	self._config.width = (self._config.detached and self._config.width_override ~= 0)
		and self._config.width_override or C.db.profile.units[unit].width
end

function element_proto:UpdateFonts()
	self.Text:UpdateFont(self._config.text.size)
	self.Text:SetJustifyH("LEFT")

	self.Time:UpdateFont(self._config.text.size)
	self.Time:SetJustifyH("RIGHT")
end

function element_proto:UpdateTextures()
	self:SetStatusBarTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.horiz))
	self.SafeZone_:SetTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.horiz))
end

function element_proto:UpdateColors()
	local stages = {{}, {}}
	stages[1].r, stages[1].g, stages[1].b = C.db.global.colors.castbar.empowering:GetRGB()
	stages[2].r, stages[2].g, stages[2].b = C.db.global.colors.castbar.empowering_full:GetRGB()

	for i = 3, 4 do
		for j = 1, i do
			if j == i then
				self.stageColors[i][j] = {C.db.global.colors.castbar.empowering_full:GetRGB()}
			else
				self.stageColors[i][j] = {E:GetGradientAsRGB((1 / i) * j, stages)}
			end
		end
	end
end

function element_proto:UpdateIcon()
	local config = self._config
	local height = config.height

	if config.icon.position == "LEFT" then
		self.Icon = self.LeftIcon

		self.LeftIcon:SetSize(height * 1.5, height)
		self.RightIcon:SetSize(0.0001, height)

		self.LeftSep:SetSize(12 / 2, 0)
		self.RightSep:SetSize(0.0001, 0.0001)

		self:SetPoint("TOPLEFT", 2 + height * 1.5, 0) -- 4 + 2, offset + sep width
		self:SetPoint("BOTTOMRIGHT", 0, 0)
	elseif config.icon.position == "RIGHT" then
		self.Icon = self.RightIcon

		self.LeftIcon:SetSize(0.0001, height)
		self.RightIcon:SetSize(height * 1.5, height)

		self.LeftSep:SetSize(0.0001, 0.0001)
		self.RightSep:SetSize(12 / 2, 0)

		self:SetPoint("TOPLEFT", 0, 0)
		self:SetPoint("BOTTOMRIGHT", -2 - height * 1.5, 0) -- 4 + 2, offset + sep width
	else
		self.Icon = nil

		self.LeftIcon:SetSize(0.0001, height)
		self.RightIcon:SetSize(0.0001, height)

		self.LeftSep:SetSize(0.0001, 0.0001)
		self.RightSep:SetSize(0.0001, 0.0001)

		self:SetPoint("TOPLEFT", 0, 0)
		self:SetPoint("BOTTOMRIGHT", 0, 0)
	end
end

function element_proto:UpdateLatency()
	if self._config.latency then
		self.SafeZone = self.SafeZone_
		self.SafeZone_:Show()
	else
		self.SafeZone = nil
		self.SafeZone_:Hide()
	end
end

function element_proto:UpdateSize()
	local holder = self.Holder
	local frame = self.__owner
	local width = self._config.width
	local height = self._config.height

	holder:SetSize(width, height)

	local point1 = self._config.point1
	if point1 and point1.p then
		if self._config.detached then
			if frame.CastbarSlot then
				frame.CastbarSlot:Release(holder)
			end

			local mover = E.Movers:Get(holder, true)
			if not mover then
				holder:ClearAllPoints()
				holder:SetPoint(point1.p, E:ResolveAnchorPoint(nil, point1.detached_anchor == "FRAME" and frame:GetName() or point1.detached_anchor), point1.rP, point1.x, point1.y)

				E.Movers:Create(holder)
			else
				mover:Enable()
				mover:UpdateSize(width, height)
			end

			holder:SetParent(UIParent)
		else
			local mover = E.Movers:Get(holder)
			if mover then
				mover:Disable()
			end

			if frame.CastbarSlot then
				frame.CastbarSlot:UpdateSize(0, height)
				frame.CastbarSlot:Capture(holder)
			else
				holder:ClearAllPoints()
				holder:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y, true)
			end

			holder:SetParent(frame)
		end
	end
end

local frame_proto = {}

function frame_proto:UpdateCastbar()
	local element = self.Castbar
	element:UpdateConfig()
	element:UpdateSize()
	element:UpdateIcon()
	element:UpdateLatency()
	element:UpdateFonts()
	element:UpdateTextures()
	element:UpdateColors()

	if element._config.enabled and not self:IsElementEnabled("Castbar") then
		self:EnableElement("Castbar")
		element.Holder:Show()
	elseif not element._config.enabled and self:IsElementEnabled("Castbar") then
		self:DisableElement("Castbar")
		element.Holder:Hide()

		if self.__unit == "player" and not element._config.blizz_enabled then
			PlayerCastingBarFrame:SetUnit(nil)
			PetCastingBarFrame:SetUnit(nil)
		end
	end

	if self:IsElementEnabled("Castbar") then
		element:ForceUpdate()
	end
end

local gradientColorMin = {r = 0, g = 0, b = 0, a = 0}
local gradientColorMax = {r = 0, g = 0, b = 0, a = 0.4}

function UF:CreateCastbar(frame)
	Mixin(frame, frame_proto)

	local holder = CreateFrame("Frame", "$parentCastbarHolder", frame)

	local element = Mixin(CreateFrame("StatusBar", nil, holder), element_proto)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	element:SetFrameLevel(holder:GetFrameLevel())
	element.Holder = holder

	local ag = element:GetStatusBarTexture():CreateAnimationGroup()
	element.ColorAnim = ag

	local anim = ag:CreateAnimation("VertexColor")
	anim:SetDuration(0.125)
	ag.color = {a = 1}
	ag.Anim = anim

	local bg = element:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints(holder)
	bg:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
	bg:SetHorizTile(true)
	bg:SetVertTile(true)

	local icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	element.LeftIcon = icon

	local sep = element:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetVertTile(true)
	sep:SetTexCoord(2 / 16, 14 / 16, 0 / 8, 8 / 8)
	sep:SetVertexColor(1, 0.6, 0)
	sep:SetSize(12 / 2, 0)
	sep:SetPoint("TOP", 0, 0)
	sep:SetPoint("BOTTOM", 0, 0)
	sep:SetPoint("LEFT", icon, "RIGHT", -2, 0)
	sep:SetSnapToPixelGrid(false)
	sep:SetTexelSnappingBias(0)
	element.LeftSep = sep

	icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	icon:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
	element.RightIcon = icon

	sep = element:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetVertTile(true)
	sep:SetTexCoord(2 / 16, 14 / 16, 0 / 8, 8 / 8)
	sep:SetVertexColor(1, 0.6, 0)
	sep:SetSize(12 / 2, 0)
	sep:SetPoint("TOP", 0, 0)
	sep:SetPoint("BOTTOM", 0, 0)
	sep:SetPoint("RIGHT", icon, "LEFT", 2, 0)
	sep:SetSnapToPixelGrid(false)
	sep:SetTexelSnappingBias(0)
	element.RightSep = sep

	local safeZone = element:CreateTexture(nil, "ARTWORK", nil, 1)
	safeZone:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	safeZone:SetVertexColor(C.db.global.colors.red:GetRGBA(0.6))
	element.SafeZone_ = safeZone

	local texParent = CreateFrame("Frame", nil, element)
	texParent:SetFrameLevel(element:GetFrameLevel() + 2)
	texParent:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	texParent:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, 0)
	element.TextureParent = texParent

	local time = texParent:CreateFontString(nil, "ARTWORK")
	E.FontStrings:Capture(time, "statusbar")
	time:SetWordWrap(false)
	time:SetPoint("TOP", element, "TOP", 0, 0)
	time:SetPoint("BOTTOM", element, "BOTTOM", 0, 0)
	time:SetPoint("RIGHT", element, "RIGHT", 0, 0)
	element.Time = time

	local text = texParent:CreateFontString(nil, "ARTWORK")
	E.FontStrings:Capture(text, "statusbar")
	text:SetWordWrap(false)
	text:SetJustifyH("LEFT")
	text:SetPoint("TOP", element, "TOP", 0, 0)
	text:SetPoint("BOTTOM", element, "BOTTOM", 0, 0)
	text:SetPoint("LEFT", element, "LEFT", 2, 0)
	text:SetPoint("RIGHT", time, "LEFT", -2, 0)
	element.Text = text

	local border = E:CreateBorder(texParent, "BORDER")
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-statusbar")
	border:SetSize(16)
	border:SetOffset(-4)
	element.Border = border

	local gradient = texParent:CreateTexture(nil, "BORDER", nil, -1)
	gradient:SetAllPoints(texParent)
	gradient:SetSnapToPixelGrid(false)
	gradient:SetTexelSnappingBias(0)
	gradient:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	gradient:SetGradient("VERTICAL", gradientColorMin, gradientColorMax)
	element.Gradient = gradient

	element.stageColors = {
		[3] = {},
		[4] = {},
	}

	return element
end
