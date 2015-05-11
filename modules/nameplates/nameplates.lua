local _, ns = ...
local E, M = ns.E, ns.M
E.NP = {}

local NP = E.NP

local format, match = format, strmatch
local prevNumChildren = 0

NP.plates = {}

local function NamePlate_GetColor(r, g, b, a)
	r, g, b, a = format("%.2f", r), format("%.2f", g), format("%.2f", b), format("%.2f", a)

	if g + b == 0 then
		return 0.9, 0.15, 0.15, 1
	elseif r + b == 0 then
		return 0.15, 0.65, 0.15, 1
	elseif r + g == 2 then
		return 1, 0.80, 0.10, 1
	elseif r + g == 0 then
		return 0.41, 0.8, 0.94, 1
	else
		return r, g, b, a
	end
end

local function NamePlate_OnShow(self)
	local scale = UIParent:GetEffectiveScale()
	local healthbar, overlay = self.health.bar, self.overlay

	overlay:SetScale(scale)

	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", overlay:GetWidth()))
	if sw < ow then
		overlay:SetScale(scale * 0.7)
	end

	if healthbar.text then
		healthbar.text:SetText(E:NumberFormat(self.health:GetValue()))
	end

	local name = self.name:GetText() or UNKNOWNOBJECT
	local level = self.bossIcon:IsShown() and -1 or tonumber(self.level:GetText())
	local color = E:RGBToHEX(GetQuestDifficultyColor((level > 0) and level or 99))

	if self.bossIcon:IsShown() then
		level = "??"
	end

	if self.eliteIcon:IsShown() then
		level = level.."+"
	end

	overlay.name:SetFormattedText("|cff%s%s|r %s", color, level, name)

	self.overlay:Show()
end

local function NamePlate_OnHide(self)
	self.overlay:Hide()
end

local function NamePlateCastBar_OnShow(self)
	local bar = self.bar

	bar:Show()

	bar.icon:SetTexture(self.icon:GetTexture())

	bar.text:SetText(self.text:GetText())
end

local function NamePlateCastBar_OnHide(self)
	self.bar:Hide()
end

local function NamePlateHealthBar_OnValueChanged(self, value)
	local bar = self.bar

	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(value)

	if bar.text then
		bar.text:SetText(E:NumberFormat(value))
	end
end

local function NamePlateCastBar_OnValueChanged(self, value)
	local bar = self.bar

	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(value)

	if self.shield:IsShown() then
		bar.icon:SetDesaturated(true)
		bar:SetStatusBarColor(0.6, 0.6, 0.6)
		bar.bg:SetVertexColor(0.2, 0.2, 0.2)
	else
		bar.icon:SetDesaturated(false)
		bar:SetStatusBarColor(0.15, 0.15, 0.15)
		bar.bg:SetVertexColor(0.96, 0.7, 0)
	end
end

local function NamePlate_CreateStatusBar(parent, isCastBar)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetSize(120, 12)
	bar:SetPoint(isCastBar and "BOTTOM" or "TOP", parent, isCastBar and "BOTTOM" or "TOP", 0, 0)
	bar:SetStatusBarTexture(M.textures.statusbar)
	bar:SetStatusBarColor(0.15, 0.15, 0.15)

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetAllPoints(bar)
	bg:SetTexture(M.textures.statusbar)
	bg:SetVertexColor(0.15, 0.15, 0.15)
	bar.bg = bg

	local fg = bar:CreateTexture(nil, "OVERLAY", nil, 0)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	fg:SetTexCoord((isCastBar and 63 or 319) / 512, (isCastBar and 193 or 449) / 512, 5 / 64, 27 / 64)
	fg:SetSize(130, 22)
	fg:SetPoint("CENTER", 0, 0)
	bar.fg = fg

	local text = E:CreateFontString(bar, 10, nil, true, nil)
	text:SetPoint("LEFT", bar, 2, 0)
	text:SetPoint("RIGHT", bar, -2, 0)
	text:SetJustifyH(isCastBar and "CENTER" or "RIGHT")
	bar.text = text

	return bar
end

local function Sizer_OnSizeChanged(self, x, y)
	self.parent:Hide()
	self.parent:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", E:Round(x), E:Round(y - 24))
	self.parent:Show()
end

local function HandleNamePlate(self)
	self.barFrame, self.nameFrame = self:GetChildren()
	self.health, self.cast = self.barFrame:GetChildren()

	self.threat, self.border, self.highlight, self.level, self.bossIcon, self.raidIcon, self.eliteIcon = self.barFrame:GetRegions()
	self.name = self.nameFrame:GetRegions()
	self.health.texture = self.health:GetRegions()
	self.cast.texture, self.cast.border, self.cast.shield, self.cast.icon, self.cast.text, self.cast.textShadow = self.cast:GetRegions()

	self.threat:SetTexture(nil)
	self.border:SetTexture(nil)
	self.level:SetSize(0.001, 0.001)
	self.level:Hide()
	self.bossIcon:SetTexture(nil)
	self.eliteIcon:SetAlpha(0)

	self.name:Hide()

	self.cast.border:SetTexture(nil)
	self.cast.shield:SetTexture(nil)
	self.cast.icon:SetTexCoord(0, 0, 0, 0)
	self.cast.icon:SetSize(0.001, 0.001)
	self.cast.text:Hide()
	self.cast.textShadow:SetTexture(nil)

	local overlay = CreateFrame("Frame", "LS"..self:GetName().."Overlay", WorldFrame)
	overlay:SetSize(120, 32)
	self.overlay = overlay

	NP.plates[self] = overlay

	-- Health
	self.health.texture:SetTexture(nil)

	local healthBar = NamePlate_CreateStatusBar(overlay)

	if not ns.C.nameplates.showText then
		healthBar.text = nil
	end

	self.health.bar = healthBar

	self.health:HookScript("OnValueChanged", NamePlateHealthBar_OnValueChanged)

	-- Castbar
	self.cast.texture:SetTexture(nil)

	local castBar = NamePlate_CreateStatusBar(overlay, true)

	local iconHolder = CreateFrame("Frame", nil, castBar)
	iconHolder:SetSize(32, 32)
	iconHolder:SetPoint("RIGHT", overlay, "LEFT", -8, 0)

	local icon = iconHolder:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	icon:SetAllPoints()
	castBar.icon = icon

	E:CreateBorder(iconHolder)

	self.cast.bar = castBar

	self.cast:HookScript("OnShow", NamePlateCastBar_OnShow)
	self.cast:HookScript("OnHide", NamePlateCastBar_OnHide)
	self.cast:HookScript("OnValueChanged", NamePlateCastBar_OnValueChanged)

	if self.cast:IsShown() then
		NamePlateCastBar_OnShow(self.cast)
	else
		castBar:Hide()
	end

	-- Name
	local name = E:CreateFontString(overlay, 14, nil, true, nil)
	name:SetPoint("BOTTOM", overlay, "TOP", 0, 6)
	name:SetPoint("LEFT", overlay, -24, 0)
	name:SetPoint("RIGHT", overlay, 24, 0)
	overlay.name = name

	-- RaidIcon
	self.raidIcon:SetParent(overlay)
	self.raidIcon:SetSize(32, 32)
	self.raidIcon:ClearAllPoints()
	self.raidIcon:SetPoint("LEFT", overlay, "RIGHT", 8, 0)

	-- Threat
	local threat = healthBar:CreateTexture(nil, "OVERLAY", nil, 1)
	threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	threat:SetTexCoord(62 / 512, 194 / 512, 36 / 64, 52 / 64)
	threat:SetPoint("TOPLEFT", healthBar.fg, "TOPLEFT", -1, 1)
	threat:SetPoint("BOTTOMRIGHT", healthBar.fg, "BOTTOMRIGHT", 1, 7)
	threat:SetVertexColor(0.15, 0.15, 0.15)
	threat:Hide()
	overlay.threat = threat

	-- Highlight
	local hl = healthBar:CreateTexture(nil, "OVERLAY", nil, 2)
	hl:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	hl:SetTexCoord(321 / 512, 447 / 512, 39 / 64, 57 / 64)
	hl:SetSize(126, 18)
	hl:SetPoint("CENTER", 0, 0)
	hl:SetBlendMode("ADD")
	hl:Hide()
	overlay.hl = hl

	-- Position
	local sizer = CreateFrame("Frame", nil, overlay)
	sizer:SetPoint("BOTTOMLEFT", WorldFrame)
	sizer:SetPoint("TOPRIGHT", self, "CENTER")
	sizer.parent = overlay
	sizer:SetScript("OnSizeChanged", Sizer_OnSizeChanged)

	self:HookScript("OnShow", NamePlate_OnShow)
	self:HookScript("OnHide", NamePlate_OnHide)

	if self:IsShown() then
		NamePlate_OnShow(self)
	else
		overlay:Hide()
	end
end

local function WorldFrame_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		local curNumChildren = WorldFrame:GetNumChildren()

		if curNumChildren ~= prevNumChildren  then
			for i = prevNumChildren + 1, curNumChildren do
				local f = select(i, WorldFrame:GetChildren())

				local name = f:GetName()
				if (name and match(name, "^NamePlate%d")) and not NP.plates[f] then
					HandleNamePlate(f)
				end
			end

			prevNumChildren = curNumChildren
		end

		for plate, overlay in next, NP.plates do
			if plate:IsShown() then
				overlay:SetAlpha(plate:GetAlpha())

				plate.health.bar:SetStatusBarColor(NamePlate_GetColor(plate.health:GetStatusBarColor()))

				if plate.threat:IsShown() then
					overlay.threat:Show()
					overlay.threat:SetVertexColor(plate.threat:GetVertexColor())
				else
					overlay.threat:Hide()
				end

				if plate.highlight:IsShown() then
					overlay.hl:Show()
				else
					overlay.hl:Hide()
				end
			end
		end

		self.elapsed = 0
	end
end

function NP:Initialize()
	WorldFrame:HookScript("OnUpdate", WorldFrame_OnUpdate)
end
