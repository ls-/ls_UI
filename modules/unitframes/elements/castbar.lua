local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")
local COLORS = M.colors

local abs, unpack = abs, unpack

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

function UF:CreateCastBar(parent, width, safezone, delay)
	local holder = CreateFrame("Frame", parent:GetName().."CastBarHolder", parent, "SecureHandlerStateTemplate")
	holder:SetSize(width, 32)

	local bar = E:CreateStatusBar(holder, "$parentCastBar", "HORIZONTAL")
	bar:SetSize(width - 46, 12)
	bar:SetPoint("TOPRIGHT", -6, -2)
	E:SetStatusBarSkin(bar, "HORIZONTAL-BIG")

	bar.Text:SetPoint("TOPLEFT", 1, 0)
	bar.Text:SetPoint("BOTTOMRIGHT", -1, 0)

	local spark = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	spark:SetSize(24, 24)
	spark:SetBlendMode("ADD")
	bar.Spark = spark

	local iconHolder = CreateFrame("Frame", "$parentIconHolder", bar)
	iconHolder:SetSize(28, 28)
	iconHolder:SetPoint("TOPRIGHT", bar, "TOPLEFT", -8, 0)
	E:CreateBorder(iconHolder, 8)
	iconHolder:SetBorderColor(unpack(COLORS.yellow))

	bar.Icon = E:UpdateIcon(iconHolder)

	local time = E:CreateFontString(bar, 10, nil, true)
	time:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 3, -2)
	bar.Time = time

	if safezone then
		local zone = bar:CreateTexture(nil, "ARTWORK", nil, 1)
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
