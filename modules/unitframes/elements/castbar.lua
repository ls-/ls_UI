local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

local abs = abs

local function PostCastStart(self, unit, name, castid)
	if self.interrupt then
		self:SetStatusBarColor(0.6, 0.6, 0.6)
		self.Icon:SetDesaturated(true)
		self.bg:SetVertexColor(0.2, 0.2, 0.2)
	else
		self:SetStatusBarColor(0.15, 0.15, 0.15)
		self.Icon:SetDesaturated(false)
		self.bg:SetVertexColor(0.9, 0.65, 0.15)
	end
end

local function PostChannelStart(self, unit, name)
	if self.interrupt then
		self:SetStatusBarColor(0.6, 0.6, 0.6)
		self.Icon:SetDesaturated(true)
		self.bg:SetVertexColor(0.2, 0.2, 0.2)
	else
		self:SetStatusBarColor(0.15, 0.15, 0.15)
		self.Icon:SetDesaturated(false)
		self.bg:SetVertexColor(0.9, 0.65, 0.15)
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

function UF:CreateCastBar(parent, width, coords, textsize, safezone, delay)
	local holder = CreateFrame("Frame", parent:GetName().."CastBarHolder", parent)
	holder:SetSize(width, 26)
	holder:SetPoint(unpack(coords))

	local bar = CreateFrame("StatusBar", parent:GetName().."CastBar", holder)
	bar:SetStatusBarTexture(M.textures.statusbar)
	bar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 1)
	bar:SetSize(width - 32, 18)
	bar:SetPoint("TOPRIGHT")
	E:CreateBorder(bar, 8)

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetAllPoints()
	bg:SetTexture(1, 1, 1, 1)
	bar.bg = bg

	local spark = bar:CreateTexture(nil, "BORDER", nil, 1)
	spark:SetSize(18, 32)
	spark:SetBlendMode("ADD")
	bar.Spark = spark

	local text = E:CreateFontString(bar, 10, nil, true)
	text:SetDrawLayer("ARTWORK", 1)
	text:SetPoint("LEFT", 2, 0)
	text:SetPoint("RIGHT", -2, 0)
	bar.Text = text

	local iconHolder = CreateFrame("Frame", nil, bar)
	iconHolder:SetSize(26, 26)
	iconHolder:SetPoint("TOPRIGHT", bar, "TOPLEFT", -6, 0)
	E:CreateBorder(iconHolder, 8)

	local icon = iconHolder:CreateTexture()
	E:TweakIcon(icon)
	bar.Icon = icon

	local time = E:CreateFontString(bar, 10, nil, true)
	time:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 2, -1)
	bar.Time = time

	if safezone then
		local zone = bar:CreateTexture(nil, "BACKGROUND", nil, 2)
		zone:SetTexture(M.textures.statusbar)
		zone:SetVertexColor(0.6, 0, 0, 0.6)
		bar.SafeZone = zone
	end

	bar.PostCastStart = PostCastStart
	bar.PostChannelStart = PostChannelStart
	bar.CustomTimeText = CustomTimeText
	bar.CustomDelayText = delay and CustomDelayText

	return bar
end