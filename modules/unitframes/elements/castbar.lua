local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M
local UF = E.UF
local COLORS = M.colors

local abs, unpack = abs, unpack

local function PostCastStart(self, unit, name, castid)
	if self.interrupt then
		self:SetStatusBarColor(unpack(COLORS.gray))
		self.Icon:SetDesaturated(true)
		self.Bg:SetTexture(unpack(COLORS.darkgray))
	else
		self:SetStatusBarColor(unpack(COLORS.darkgray))
		self.Icon:SetDesaturated(false)
		self.Bg:SetTexture(unpack(COLORS.yellow))
	end
end

local function PostChannelStart(self, unit, name)
	if self.interrupt then
		self:SetStatusBarColor(unpack(COLORS.gray))
		self.Icon:SetDesaturated(true)
		self.Bg:SetTexture(unpack(COLORS.darkgray))
	else
		self:SetStatusBarColor(unpack(COLORS.darkgray))
		self.Icon:SetDesaturated(false)
		self.Bg:SetTexture(unpack(COLORS.yellow))
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

function UF:CreateCastBar(parent, width, coords, textSize, safezone, delay)
	local holder = CreateFrame("Frame", parent:GetName().."CastBarHolder", parent, "SecureHandlerStateTemplate")
	holder:SetSize(width, 26)

	if coords then
		holder:SetPoint(unpack(coords))
	end

	local bar = E:CreateStatusBar(holder, parent:GetName().."CastBar", width - 43, 12, textSize, true)
	bar:SetPoint("TOPRIGHT", -6, -2)

	local spark = bar:CreateTexture(nil, "BORDER", nil, 1)
	spark:SetSize(18, 30)
	spark:SetBlendMode("ADD")
	bar.Spark = spark

	local iconHolder = CreateFrame("Frame", nil, bar)
	iconHolder:SetSize(26, 26)
	iconHolder:SetPoint("TOPRIGHT", bar, "TOPLEFT", -12, 0)
	E:CreateBorder(iconHolder, 8)
	iconHolder:SetBorderColor(unpack(COLORS.yellow))

	local icon = iconHolder:CreateTexture()
	E:TweakIcon(icon)
	bar.Icon = icon

	local time = E:CreateFontString(bar, 10, nil, true)
	time:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 3, -2)
	bar.Time = time

	if safezone then
		local zone = bar:CreateTexture(nil, "BACKGROUND", nil, 2)
		zone:SetTexture(M.textures.statusbar)
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
