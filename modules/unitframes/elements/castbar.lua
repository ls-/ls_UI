local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")
local COLORS = M.colors

local abs, unpack = abs, unpack

local PRESETS = {
	["14"] = {
		sparkSize = {26, 26},
		iconGap = 14,
		spacing = 49,
		anchorPoint = {"TOPRIGHT", -7, -2},
	},
	["12"] = {
		sparkSize = {24, 24},
		iconGap = 12,
		spacing = 46,
		anchorPoint = {"TOPRIGHT", -6, -2},
	},
}

local function PostCastStart(self, unit, name, castid)
	if self.interrupt then
		self:SetStatusBarColor(unpack(COLORS.gray))
		self.Icon:SetDesaturated(true)
	else
		self:SetStatusBarColor(unpack(COLORS.yellow))
		self.Icon:SetDesaturated(false)
	end
end

local function PostChannelStart(self, unit, name)
	if self.interrupt then
		self:SetStatusBarColor(unpack(COLORS.gray))
		self.Icon:SetDesaturated(true)
	else
		self:SetStatusBarColor(unpack(COLORS.yellow))
		self.Icon:SetDesaturated(false)
	end
end

local function CustomTimeText(self, duration)
	if self.casting then
		duration = self.max - duration
	end

	self.Time:SetFormattedText("%.1f ", duration)
end

local function CustomDelayText(self, duration)
	if self.casting then
		duration = self.max - duration
	end

	if self.casting then
		self.Time:SetFormattedText("%.1f|cffe52626+%.1f|r ", duration, abs(self.delay))
	elseif self.channeling then
		self.Time:SetFormattedText("%.1f|cffe52626-%.1f|r ", duration, abs(self.delay))
	end
end

function UF:CreateCastBar(parent, width, coords, preset, safezone, delay)
	local holder = CreateFrame("Frame", parent:GetName().."CastBarHolder", parent, "SecureHandlerStateTemplate")
	holder:SetSize(width, 28)

	local PRESET = PRESETS[preset or "14"]

	if coords then
		holder:SetPoint(unpack(coords))
	end

	local bar = E:CreateStatusBar(holder, parent:GetName().."CastBar", width - PRESET.spacing, preset or "14", true)
	bar:SetPoint(unpack(PRESET.anchorPoint))

	local spark = bar:CreateTexture(nil, "BORDER", nil, 1)
	spark:SetSize(unpack(PRESET.sparkSize))
	spark:SetBlendMode("ADD")
	bar.Spark = spark

	local iconHolder = CreateFrame("Frame", "$parentIconHolder", bar)
	iconHolder:SetSize(28, 28)
	iconHolder:SetPoint("TOPRIGHT", bar, "TOPLEFT", -PRESET.iconGap, 0)
	E:CreateBorder(iconHolder, 8)
	iconHolder:SetBorderColor(unpack(COLORS.yellow))

	bar.Icon = E:UpdateIcon(iconHolder)

	local time = E:CreateFontString(bar, 10, nil, true)
	time:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 3, -2)
	bar.Time = time

	if safezone then
		local zone = bar:CreateTexture(nil, "BACKGROUND", nil, 2)
		zone:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		zone:SetVertexColor(unpack(COLORS.red))
		zone:SetAlpha(0.6)
		bar.SafeZone = zone
	end

	bar.Holder = holder
	bar.PostCastStart = PostCastStart
	bar.PostChannelStart = PostChannelStart
	bar.CustomTimeText = CustomTimeText
	bar.CustomDelayText = delay and CustomDelayText

	return bar
end
