local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

--Lua
local _G = getfenv(0)
local m_abs = _G.math.abs

-- Mine
local function PostCastStart(castbar)
	if castbar.notInterruptible then
		castbar:SetStatusBarColor(M.COLORS.GRAY:GetRGB())

		if castbar.Icon then
			castbar.Icon:SetDesaturated(true)
		end
	else
		castbar:SetStatusBarColor(M.COLORS.YELLOW:GetRGB())

		if castbar.Icon then
			castbar.Icon:SetDesaturated(false)
		end
	end
end

local function PostCastFailed(castbar)
	castbar:SetMinMaxValues(0, 1)
	castbar:SetValue(1)
	castbar:SetStatusBarColor(M.COLORS.RED:GetRGB())

	castbar.Spark:SetPoint("CENTER", castbar, "RIGHT")

	castbar.Time:SetText("")
end

local function CustomTimeText(castbar, duration)
	if castbar.max > 600 then
		return castbar.Time:SetText("")
	end

	if castbar.casting then
		duration = castbar.max - duration
	end

	castbar.Time:SetFormattedText("%.1f ", duration)
end

local function CustomDelayText(castbar, duration)
	if castbar.casting then
		duration = castbar.max - duration
	end

	if castbar.casting then
		castbar.Time:SetFormattedText("%.1f|cffdc4436+%.1f|r ", duration, m_abs(castbar.delay))
	elseif castbar.channeling then
		castbar.Time:SetFormattedText("%.1f|cffdc4436-%.1f|r ", duration, m_abs(castbar.delay))
	end
end

function UF:CreateCastbar(parent)
	local holder = _G.CreateFrame("Frame", "$parentCastbarHolder", parent)
	holder:SetHeight(12)

	local element = _G.CreateFrame("StatusBar", nil, holder)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	element:SetFrameLevel(holder:GetFrameLevel())

	local bg = element:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints(holder)
	bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())

	local icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetSize(18, 12)
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 3, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	element.LeftIcon = icon

	icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetSize(18, 12)
	icon:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -3, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	element.RightIcon = icon

	local safeZone = element:CreateTexture(nil, "ARTWORK", nil, 1)
	safeZone:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	safeZone:SetVertexColor(M.COLORS.RED:GetRGBA(0.6))
	element.SafeZone_ = safeZone

	local spark = element:CreateTexture(nil, "ARTWORK", nil, 2)
	spark:SetSize(24, 24)
	spark:SetBlendMode("ADD")
	element.Spark = spark

	local sep = element:CreateTexture(nil, "OVERLAY")
	sep:SetSize(24 / 2, 24 / 2)
	sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
	sep:SetTexCoord(1 / 64, 25 / 64, 18 / 64, 42 / 64)
	sep:SetPoint("RIGHT", element, "LEFT", 5, 0)
	element.LeftSep = sep

	sep = element:CreateTexture(nil, "OVERLAY")
	sep:SetSize(24 / 2, 24 / 2)
	sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
	sep:SetTexCoord(1 / 64, 25 / 64, 18 / 64, 42 / 64)
	sep:SetPoint("LEFT", element, "RIGHT", -5, 0)
	element.RightSep = sep

	local tex_parent = _G.CreateFrame("Frame", nil, element)
	tex_parent:SetPoint("TOPLEFT", holder, "TOPLEFT", 3, 0)
	tex_parent:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", -3, 0)
	E:SetStatusBarSkin(tex_parent, "HORIZONTAL-L")

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
	element.PostCastStart = PostCastStart
	element.PostChannelStart = PostCastStart
	element.PostCastFailed = PostCastFailed
	element.PostCastInterrupted = PostCastFailed
	element.CustomTimeText = CustomTimeText
	element.CustomDelayText = CustomDelayText
	element.timeToHold = 0.4

	return element
end

function UF:UpdateCastbar(frame)
	local config = frame._config.castbar
	local element = frame.Castbar
	local holder = element.Holder
	local hasMover = E:HasMover(holder)
	local width = (config.detached and config.width_override ~= 0) and config.width_override or frame._config.width

	holder:ClearAllPoints()
	holder:SetWidth(width)
	holder._width = width

	if hasMover then
		E:UpdateMoverSize(holder, width, 12)
	end

	local point1 = config.point1

	if point1 and point1.p then
		if config.detached then
			holder:SetPoint(point1.p,
				E:ResolveAnchorPoint(nil, point1.detached_anchor == "FRAME" and frame:GetName() or point1.detached_anchor),
				point1.rP, point1.x, point1.y)

			if not hasMover then
				E:CreateMover(holder)
			else
				E:EnableMover(holder)
			end
		else
			holder:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)

			if hasMover then
				E:DisableMover(holder)
			end
		end
	end

	if config.icon.enabled then
		if config.icon.position == "LEFT" then
			element.Icon = element.LeftIcon

			element.LeftIcon:Show()
			element.RightIcon:Hide()

			element.LeftSep:Show()
			element.RightSep:Hide()

			element:SetPoint("TOPLEFT", 23, 0)
			element:SetPoint("BOTTOMRIGHT", -3, 0)
		elseif config.icon.position == "RIGHT" then
			element.Icon = element.RightIcon

			element.LeftIcon:Hide()
			element.RightIcon:Show()

			element.LeftSep:Hide()
			element.RightSep:Show()

			element:SetPoint("TOPLEFT", 3, 0)
			element:SetPoint("BOTTOMRIGHT", -23, 0)
		end
	else
		element.Icon = nil

		element.LeftIcon:Hide()
		element.RightIcon:Hide()

		element.LeftSep:Hide()
		element.RightSep:Hide()

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

	if config.enabled and not frame:IsElementEnabled("Castbar") then
		frame:EnableElement("Castbar")
	elseif not config.enabled and frame:IsElementEnabled("Castbar") then
		frame:DisableElement("Castbar")
	end

	if frame:IsElementEnabled("Castbar") then
		element:ForceUpdate()
	end
end
