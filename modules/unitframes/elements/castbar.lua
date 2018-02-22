local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

--Lua
local _G = getfenv(0)
local m_abs = _G.math.abs

-- Mine
local function element_PostCastStart(self)
	if self.notInterruptible then
		self:SetStatusBarColor(M.COLORS.GRAY:GetRGB())

		if self.Icon then
			self.Icon:SetDesaturated(true)
		end
	else
		self:SetStatusBarColor(M.COLORS.YELLOW:GetRGB())

		if self.Icon then
			self.Icon:SetDesaturated(false)
		end
	end
end

local function element_PostCastFailed(self)
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetStatusBarColor(M.COLORS.RED:GetRGB())

	self.Time:SetText("")
end

local function element_CustomTimeText(self, duration)
	if self.max > 600 then
		return self.Time:SetText("")
	end

	if self.casting then
		duration = self.max - duration
	end

	self.Time:SetFormattedText("%.1f ", duration)
end

local function element_CustomDelayText(self, duration)
	if self.casting then
		duration = self.max - duration
	end

	if self.casting then
		self.Time:SetFormattedText("%.1f|cffdc4436+%.1f|r ", duration, m_abs(self.delay))
	elseif self.channeling then
		self.Time:SetFormattedText("%.1f|cffdc4436-%.1f|r ", duration, m_abs(self.delay))
	end
end

function UF:CreateCastbar(parent)
	local holder = CreateFrame("Frame", "$parentCastbarHolder", parent)
	holder._width = 0

	local element = CreateFrame("StatusBar", nil, holder)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	element:SetFrameLevel(holder:GetFrameLevel())

	local bg = element:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints(holder)
	bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())

	local icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 3, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	element.LeftIcon = icon

	local sep = element:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetPoint("LEFT", icon, "RIGHT", -5, 0)
	element.LeftSep = sep

	icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	icon:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -3, 0)
	element.RightIcon = icon

	sep = element:CreateTexture(nil, "OVERLAY")
	sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-sep", "REPEAT", "REPEAT")
	sep:SetPoint("RIGHT", icon, "LEFT", 5, 0)
	element.RightSep = sep

	local safeZone = element:CreateTexture(nil, "ARTWORK", nil, 1)
	safeZone:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	safeZone:SetVertexColor(M.COLORS.RED:GetRGBA(0.6))
	element.SafeZone_ = safeZone

	local tex_parent = CreateFrame("Frame", nil, element)
	tex_parent:SetPoint("TOPLEFT", holder, "TOPLEFT", 3, 0)
	tex_parent:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -3, 0)
	element.TexParent = tex_parent

	local time = tex_parent:CreateFontString(nil, "ARTWORK", "LSFont12_Shadow")
	time:SetWordWrap(false)
	time:SetPoint("RIGHT", element, "RIGHT", -2, 0)
	element.Time = time

	local text = tex_parent:CreateFontString(nil, "ARTWORK", "LSFont12_Shadow")
	text:SetWordWrap(false)
	text:SetJustifyH("LEFT")
	text:SetPoint("LEFT", element, "LEFT", 2, 0)
	text:SetPoint("RIGHT", time, "LEFT", -2, 0)
	element.Text = text

	element.Holder = holder
	element.PostCastStart = element_PostCastStart
	element.PostChannelStart = element_PostCastStart
	element.PostCastFailed = element_PostCastFailed
	element.PostCastInterrupted = element_PostCastFailed
	element.CustomTimeText = element_CustomTimeText
	element.CustomDelayText = element_CustomDelayText
	element.timeToHold = 0.4

	return element
end

function UF:UpdateCastbar(frame)
	local config = frame._config.castbar
	local element = frame.Castbar
	local holder = element.Holder
	local hasMover = E:HasMover(holder)
	local width = (config.detached and config.width_override ~= 0) and config.width_override or frame._config.width
	local height = config.height

	holder:SetSize(width, height)
	holder._width = width

	local point1 = config.point1

	if point1 and point1.p then
		if config.detached then
			if not hasMover then
				holder:SetPoint(point1.p, E:ResolveAnchorPoint(nil, point1.detached_anchor == "FRAME" and frame:GetName() or point1.detached_anchor), point1.rP, point1.x, point1.y)
				E:CreateMover(holder)
			else
				E:EnableMover(holder)
				E:UpdateMoverSize(holder, width, height)
			end
		else
			holder:ClearAllPoints()
			holder:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)

			if hasMover then
				E:DisableMover(holder)
			end
		end
	end

	if config.icon.enabled then
		if config.icon.position == "LEFT" then
			element.Icon = element.LeftIcon

			element.LeftIcon:SetSize(height * 1.5, height)
			element.RightIcon:SetSize(0.0001, height)

			element.LeftSep:SetSize(12, height)
			element.LeftSep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, height / 4)
			element.RightSep:SetSize(0.0001, height)

			element:SetPoint("TOPLEFT", 5 + height * 1.5, 0)
			element:SetPoint("BOTTOMRIGHT", -3, 0)
		elseif config.icon.position == "RIGHT" then
			element.Icon = element.RightIcon

			element.LeftIcon:SetSize(0.0001, height)
			element.RightIcon:SetSize(height * 1.5, height)

			element.LeftSep:SetSize(0.0001, height)
			element.RightSep:SetSize(12, height)
			element.RightSep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, height / 4)

			element:SetPoint("TOPLEFT", 3, 0)
			element:SetPoint("BOTTOMRIGHT", -5 - height * 1.5, 0)
		end
	else
		element.Icon = nil

		element.LeftIcon:SetSize(0.0001, height)
		element.RightIcon:SetSize(0.0001, height)

		element.LeftSep:SetSize(0.0001, height)
		element.RightSep:SetSize(0.0001, height)

		element:SetPoint("TOPLEFT", 3, 0)
		element:SetPoint("BOTTOMRIGHT", -3, 0)
	end

	if config.latency then
		element.SafeZone = element.SafeZone_
		element.SafeZone_:Show()
	else
		element.SafeZone = nil
		element.SafeZone_:Hide()
	end

	E:SetStatusBarSkin(element.TexParent, "HORIZONTAL-"..height)

	if config.enabled and not frame:IsElementEnabled("Castbar") then
		frame:EnableElement("Castbar")
	elseif not config.enabled and frame:IsElementEnabled("Castbar") then
		frame:DisableElement("Castbar")
	end

	if frame:IsElementEnabled("Castbar") then
		element:ForceUpdate()
	end
end
