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

function UF:CreateCastBar(parent, width, safezone, delay)
	local holder = _G.CreateFrame("Frame", parent:GetName().."CastBarHolder", parent, "SecureHandlerStateTemplate")
	holder:SetSize(width, 12)

	local bar = E:CreateStatusBar(holder, nil, "HORIZONTAL")
	bar:SetFrameLevel(holder:GetFrameLevel())
	bar:SetSize(width - 20, 12)
	bar:SetPoint("TOPRIGHT", 0, 0)

	local spark = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	spark:SetSize(24, 24)
	spark:SetBlendMode("ADD")
	bar.Spark = spark

	local icon = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	icon:SetSize(18, 12)
	icon:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	icon:SetTexCoord(8 / 64, 56 / 64, 9 / 64, 41 / 64)
	bar.Icon = icon

	local cover = _G.CreateFrame("Frame", nil, bar)
	cover:SetAllPoints(holder)
	E:SetStatusBarSkin_new(cover, "HORIZONTAL-L")

	local sep = cover:CreateTexture(nil, "ARTWORK", nil, -7)
	sep:SetSize(24 / 2, 24 / 2)
	sep:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-seps")
	sep:SetTexCoord(1 / 64, 25 / 64, 18 / 64, 42 / 64)
	sep:SetPoint("RIGHT", bar, "LEFT", 5, 0)

	local time = E:CreateFontString(cover, 12, nil, true)
	time:SetJustifyV("MIDDLE")
	time:SetPoint("TOPRIGHT", 0, 0)
	time:SetPoint("BOTTOMRIGHT", 0, 0)
	bar.Time = time

	bar.Text:SetParent(cover)
	bar.Text:SetJustifyH("LEFT")
	bar.Text:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, 0)
	bar.Text:SetPoint("BOTTOMRIGHT", time, "BOTTOMLEFT", -2, 0)

	if safezone then
		local zone = bar:CreateTexture(nil, "ARTWORK", nil, 1)
		zone:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		zone:SetVertexColor(M.COLORS.RED:GetRGB())
		zone:SetAlpha(0.6)
		bar.SafeZone = zone
	end

	bar.Holder = holder
	bar.PostCastStart = PostCastStart
	bar.PostChannelStart = PostCastStart
	bar.PostCastFailed = PostCastFailed
	bar.PostCastInterrupted = PostCastFailed
	bar.CustomTimeText = CustomTimeText
	bar.CustomDelayText = delay and CustomDelayText
	bar.timeToHold = 0.4

	return bar
end
