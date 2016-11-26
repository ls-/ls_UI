local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

--Lua
local _G = _G
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
end

local function CustomTimeText(castbar, duration)
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
	holder:SetSize(width, 32)

	local bar = E:CreateStatusBar(holder, nil, "HORIZONTAL")
	bar:SetSize(width - 46, 12)
	bar:SetPoint("TOPRIGHT", -6, -2)
	E:SetStatusBarSkin(bar, "HORIZONTAL-BIG")

	bar.Text:SetPoint("TOPLEFT", 1, 0)
	bar.Text:SetPoint("BOTTOMRIGHT", -1, 0)

	local spark = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	spark:SetSize(24, 24)
	spark:SetBlendMode("ADD")
	bar.Spark = spark

	local iconHolder = _G.CreateFrame("Frame", nil, bar)
	iconHolder:SetSize(28, 28)
	iconHolder:SetPoint("TOPRIGHT", bar, "TOPLEFT", -8, 0)
	E:CreateBorder(iconHolder)
	iconHolder:SetBorderColor(M.COLORS.YELLOW:GetRGB())

	bar.Icon = E:SetIcon(iconHolder)

	local time = E:CreateFontString(bar, 10, nil, true)
	time:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 3, -2)
	bar.Time = time

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
