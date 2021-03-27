local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

--Lua
local _G = getfenv(0)
local m_abs = _G.math.abs

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

local element_proto = {
	timeToHold = 0.4,
}

function element_proto:PostCastStart()
	if self.notInterruptible then
		self:SetStatusBarColor(E:GetRGB(C.db.global.colors.castbar.notinterruptible))

		if self.Icon then
			self.Icon:SetDesaturated(true)
		end
	else
		if self.casting then
			self:SetStatusBarColor(E:GetRGB(C.db.global.colors.castbar.casting))
		elseif self.channeling then
			self:SetStatusBarColor(E:GetRGB(C.db.global.colors.castbar.channeling))
		end

		if self.Icon then
			self.Icon:SetDesaturated(false)
		end
	end
end

function element_proto:PostCastFail()
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetStatusBarColor(E:GetRGB(C.db.global.colors.castbar.failed))

	self.Time:SetText("")
end

function element_proto:CustomTimeText(duration)
	if self.max > 600 then
		return self.Time:SetText("")
	end

	if self.casting then
		duration = self.max - duration
	end

	self.Time:SetFormattedText("%.1f ", duration)
end

function element_proto:CustomDelayText(duration)
	if self.casting then
		duration = self.max - duration
	end

	if self.casting then
		self.Time:SetFormattedText("%.1f|cffdc4436+%.1f|r ", duration, m_abs(self.delay))
	elseif self.channeling then
		self.Time:SetFormattedText("%.1f|cffdc4436-%.1f|r ", duration, m_abs(self.delay))
	end
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

function element_proto:UpdateIcon()
	local config = self._config
	local height = config.height

	if config.icon.position == "LEFT" then
		self.Icon = self.LeftIcon

		self.LeftIcon:SetSize(height * 1.5, height)
		self.RightIcon:SetSize(0.0001, height)

		self.LeftSep:SetSize(12 / 2, height)
		self.LeftSep:SetTexCoord(1 / 16, 13 / 16, 0 / 8, height / 4)

		self.RightSep:SetSize(0.0001, height)

		self:SetPoint("TOPLEFT", 6 + height * 1.5, 0) -- 4 + 2, offset + sep width
		self:SetPoint("BOTTOMRIGHT", -4, 0)
	elseif config.icon.position == "RIGHT" then
		self.Icon = self.RightIcon

		self.LeftIcon:SetSize(0.0001, height)
		self.RightIcon:SetSize(height * 1.5, height)

		self.LeftSep:SetSize(0.0001, height)
		self.RightSep:SetHeight(12 / 2, height)
		self.RightSep:SetTexCoord(1 / 16, 13 / 16, 0 / 8, height / 4)

		self:SetPoint("TOPLEFT", 4, 0)
		self:SetPoint("BOTTOMRIGHT", -6 - height * 1.5, 0) -- 4 + 2, offset + sep width
	else
		self.Icon = nil

		self.LeftIcon:SetSize(0.0001, height)
		self.RightIcon:SetSize(0.0001, height)

		self.LeftSep:SetSize(0.0001, height)
		self.RightSep:SetSize(0.0001, height)

		self:SetPoint("TOPLEFT", 4, 0)
		self:SetPoint("BOTTOMRIGHT", -4, 0)
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
		end
	end

	E:SetStatusBarSkin(self.TexParent, "HORIZONTAL-" .. height)
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

	if element._config.enabled and not self:IsElementEnabled("Castbar") then
		self:EnableElement("Castbar")
		element.Holder:Show()
	elseif not element._config.enabled and self:IsElementEnabled("Castbar") then
		self:DisableElement("Castbar")
		element.Holder:Hide()

		if self.__unit == "player" then
			CastingBarFrame_SetUnit(CastingBarFrame, nil)
			CastingBarFrame_SetUnit(PetCastingBarFrame, nil)
		end
	end

	if self:IsElementEnabled("Castbar") then
		element:ForceUpdate()
	end
end

function UF:CreateCastbar(frame)
	P:Mixin(frame, frame_proto)

	local holder = CreateFrame("Frame", "$parentCastbarHolder", frame)

	local element = P:Mixin(CreateFrame("StatusBar", nil, holder), element_proto)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	element:SetFrameLevel(holder:GetFrameLevel())
	element.Holder = holder

	local bg = element:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints(holder)
	bg:SetColorTexture(E:GetRGB(C.db.global.colors.dark_gray))

	local icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 4, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	element.LeftIcon = icon

	local sep = element:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetVertTile(true)
	sep:SetPoint("LEFT", icon, "RIGHT", -2, 0)
	sep:SetSnapToPixelGrid(false)
	sep:SetTexelSnappingBias(0)
	element.LeftSep = sep

	icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	icon:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -4, 0)
	element.RightIcon = icon

	sep = element:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetVertTile(true)
	sep:SetPoint("RIGHT", icon, "LEFT", 2, 0)
	sep:SetSnapToPixelGrid(false)
	sep:SetTexelSnappingBias(0)
	element.RightSep = sep

	local safeZone = element:CreateTexture(nil, "ARTWORK", nil, 1)
	safeZone:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	safeZone:SetVertexColor(E:GetRGBA(C.db.global.colors.red, 0.6))
	element.SafeZone_ = safeZone

	local texParent = CreateFrame("Frame", nil, element)
	texParent:SetPoint("TOPLEFT", holder, "TOPLEFT", 4, 0)
	texParent:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -4, 0)
	element.TexParent = texParent

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

	return element
end
