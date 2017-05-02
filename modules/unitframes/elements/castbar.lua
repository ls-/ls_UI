local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

--Lua
local _G = getfenv(0)
local math = _G.math

-- Mine
local function PostCastStart(castbar)
	if castbar.notInterruptible then
		castbar:SetStatusBarColor(M.COLORS.GRAY:GetRGB())
		castbar.Icon:SetDesaturated(true)
	else
		castbar:SetStatusBarColor(M.COLORS.YELLOW:GetRGB())
		castbar.Icon:SetDesaturated(false)
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
		castbar.Time:SetFormattedText("%.1f|cffdc4436+%.1f|r ", duration, math.abs(castbar.delay))
	elseif castbar.channeling then
		castbar.Time:SetFormattedText("%.1f|cffdc4436-%.1f|r ", duration, math.abs(castbar.delay))
	end
end

function UF:CreateCastbar(parent)
	local holder = _G.CreateFrame("Frame", parent:GetName().."CastbarHolder", parent)
	holder:SetHeight(12)


	local element = _G.CreateFrame("StatusBar", nil, holder)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	element:SetFrameLevel(holder:GetFrameLevel())
	element:SetPoint("TOPLEFT", 20, 0)
	element:SetPoint("BOTTOMRIGHT", 0, 0)

	local bg = element:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints(holder)
	bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())

	local icon = element:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetSize(18, 12)
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	element.Icon_ = icon

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
	element.Sep = sep

	local tex_parent = _G.CreateFrame("Frame", nil, element)
	tex_parent:SetAllPoints(holder)
	E:SetStatusBarSkin(tex_parent, "HORIZONTAL-L")

	local time = tex_parent:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
	time:SetWordWrap(false)
	time:SetPoint("RIGHT", -2, 0)
	element.Time = time

	local text = tex_parent:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
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

	element.Holder:SetWidth(config.width)

	if config.icon then
		element.Icon = element.Icon_
		element.Icon_:Show()

		element.Sep:Show()

		element:SetPoint("TOPLEFT", 20, 0)
	else
		element.Icon = nil
		element.Icon_:Hide()

		element.Sep:Hide()

		element:SetPoint("TOPLEFT", 0, 0)
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
end
