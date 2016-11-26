local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

--Lua
local _G = _G
local math = _G.math
local unpack = _G.unpack

-- Mine
local function PostCastStart(castbar)
	if castbar.notInterruptible then
		castbar:SetStatusBarColor(unpack(M.colors.gray))
		castbar.Icon:SetDesaturated(true)
	else
		castbar:SetStatusBarColor(unpack(M.colors.yellow))
		castbar.Icon:SetDesaturated(false)
	end
end

local function PostCastFailed(castbar)
	castbar:SetMinMaxValues(0, 1)
	castbar:SetValue(1)
	castbar:SetStatusBarColor(unpack(M.colors.red))

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
		castbar.Time:SetFormattedText("%.1f|cffe52626+%.1f|r ", duration, math.abs(castbar.delay))
	elseif castbar.channeling then
		castbar.Time:SetFormattedText("%.1f|cffe52626-%.1f|r ", duration, math.abs(castbar.delay))
	end
end

function UF:CreateCastBar(parent, width, safezone, delay)
	local holder = _G.CreateFrame("Frame", parent:GetName().."CastBarHolder", parent, "SecureHandlerStateTemplate")
	holder:SetSize(width, 32)

	local bar = E:CreateStatusBar(holder, parent:GetName().."CastBar", "HORIZONTAL")
	bar:SetSize(width - 46, 12)
	bar:SetPoint("TOPRIGHT", -6, -2)
	E:SetStatusBarSkin(bar, "HORIZONTAL-BIG")

	bar.Text:SetPoint("TOPLEFT", 1, 0)
	bar.Text:SetPoint("BOTTOMRIGHT", -1, 0)

	local spark = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	spark:SetSize(24, 24)
	spark:SetBlendMode("ADD")
	bar.Spark = spark

	local iconHolder = _G.CreateFrame("Frame", "$parentIconHolder", bar)
	iconHolder:SetSize(28, 28)
	iconHolder:SetPoint("TOPRIGHT", bar, "TOPLEFT", -8, 0)
	E:CreateBorder(iconHolder)
	iconHolder:SetBorderColor(unpack(M.colors.yellow))

	bar.Icon = E:UpdateIcon(iconHolder)

	local time = E:CreateFontString(bar, 10, nil, true)
	time:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 3, -2)
	bar.Time = time

	if safezone then
		local zone = bar:CreateTexture(nil, "ARTWORK", nil, 1)
		zone:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		zone:SetVertexColor(unpack(M.colors.red))
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
