local _, ns = ...
local C, E, M = ns.C, ns.E, ns.M

E.NP = {}

local NP = E.NP

local tonumber, format, match = tonumber, format, strmatch
local prevNumChildren = 0

NP.plates = {}

local function NamePlate_CreateStatusBar(parent, isCastBar)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetSize(120, 14)
	bar:SetPoint(isCastBar and "BOTTOM" or "TOP", parent, isCastBar and "BOTTOM" or "TOP", 0, isCastBar and 0 or -16)
	bar:SetStatusBarTexture(M.textures.statusbar)
	bar:SetStatusBarColor(0.15, 0.15, 0.15)
	bar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 1)

	if isCastBar then
		E:CreateBorder(bar, 8)
	else
		local fg = bar:CreateTexture(nil, "OVERLAY", nil, 1)
		fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
		fg:SetTexCoord(319 / 512, 449 / 512, 5 / 64, 27 / 64)
		fg:SetSize(130, 22)
		fg:SetPoint("CENTER", 0, 0)
	end

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetAllPoints(bar)
	bg:SetTexture(M.textures.statusbar)
	bg:SetVertexColor(0.15, 0.15, 0.15)
	bar.Bg = bg

	local text = E:CreateFontString(bar, 12, nil, true, nil)
	text:SetAllPoints(bar)
	text:SetJustifyH(isCastBar and "CENTER" or "RIGHT")
	bar.Text = text

	return bar
end

local function NamePlate_GetColor(r, g, b, a)
	r, g, b, a = tonumber(format("%.2f", r)), tonumber(format("%.2f", g)), tonumber(format("%.2f", b)), tonumber(format("%.2f", a))

	if r == 1 and g == 0 and b == 0 then
		return 0.9, 0.15, 0.15, 1
	elseif r == 0 and g == 1 and b == 0 then
		return 0.15, 0.65, 0.15, 1
	elseif r == 1 and g == 1 and b == 0 then
		return 1, 0.80, 0.10, 1
	elseif r == 0 and g == 0 and b == 1 then
		return 0.41, 0.8, 0.94, 1
	else
		return r, g, b, a
	end
end

local function NamePlateHealthBar_Update(self)
	local bar = self.Bar
	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(self:GetValue())
	bar:SetStatusBarColor(NamePlate_GetColor(self:GetStatusBarColor()))

	if bar.Text:IsShown() then
		bar.Text:SetText(E:NumberFormat(self:GetValue()))
	end
end

local function NamePlateCastBar_OnShow(self)
	local bar = self.Bar
	bar.Icon:SetTexture(self.Icon:GetTexture())
	bar.Text:SetText(self.Text:GetText())
	bar:Show()
end

local function NamePlateCastBar_OnHide(self)
	self.Bar:Hide()
end

local function NamePlateCastBar_OnValueChanged(self, value)
	local bar = self.Bar
	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(value)

	if self.Shield:IsShown() then
		bar:SetStatusBarColor(0.6, 0.6, 0.6)
		bar.Icon:SetDesaturated(true)
		bar.Bg:SetVertexColor(0.2, 0.2, 0.2)
	else
		bar:SetStatusBarColor(0.15, 0.15, 0.15)
		bar.Icon:SetDesaturated(false)
		bar.Bg:SetVertexColor(0.96, 0.7, 0)
	end
end

local function Sizer_OnSizeChanged(self, x, y)
	local parent = self.Parent
	parent:Hide()
	parent:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", E:Round(x), E:Round(y - 20))
	parent:Show()
end

local function NamePlate_OnShow(self)
	local scale = UIParent:GetEffectiveScale()
	local overlay = self.Overlay

	overlay:SetScale(scale)

	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", overlay:GetWidth()))
	if sw < ow then
		overlay:SetScale(scale * 0.7)
	end

	local name = self.Name:GetText() or UNKNOWNOBJECT
	local level = self.BossIcon:IsShown() and -1 or tonumber(self.Level:GetText())
	local color = E:RGBToHEX(GetQuestDifficultyColor((level > 0) and level or 99))

	if self.BossIcon:IsShown() then
		level = "??"
	end

	if self.EliteIcon:IsShown() then
		level = level.."+"
	end

	overlay.Name:SetFormattedText("|cff%s%s|r %s", color, level, name)

	overlay:Show()
end

local function NamePlate_OnHide(self)
	self.Overlay:Hide()
end

local function HandleNamePlate(self)
	local barFrame, nameFrame = self:GetChildren()
	local health, cast = barFrame:GetChildren()

	local border, raidIcon
	self.Threat, border, self.Highlight, self.Level, self.BossIcon, raidIcon, self.EliteIcon = barFrame:GetRegions()
	self.Name = nameFrame:GetRegions()
	local healthTexture = health:GetRegions()
	local castTexture, castBorder, castTextShadow
	castTexture, castBorder, cast.Shield, cast.Icon, cast.Text, castTextShadow = cast:GetRegions()

	self.Threat:SetTexture(nil)
	self.Threat:Hide()
	self.Level:SetSize(0.001, 0.001)
	self.Level:Hide()
	self.BossIcon:SetTexture(nil)
	self.EliteIcon:SetAlpha(0)
	self.Highlight:SetTexture(nil)
	self.Name:Hide()
	cast.Shield:SetTexture(nil)
	cast.Icon:SetTexCoord(0, 0, 0, 0)
	cast.Icon:SetSize(0.001, 0.001)
	cast.Text:Hide()
	border:SetTexture(nil)
	castBorder:SetTexture(nil)
	castTextShadow:SetTexture(nil)

	local overlay = CreateFrame("Frame", "LS"..self:GetName().."Overlay", WorldFrame)
	overlay:SetFrameStrata(self:GetFrameStrata())
	overlay:SetSize(120, 48)
	self.Overlay = overlay
	NP.plates[self] = overlay

	healthTexture:SetTexture(nil)

	local healthBar = NamePlate_CreateStatusBar(overlay)
	overlay.Health = healthBar
	health.Bar = healthBar
	health:HookScript("OnShow", NamePlateHealthBar_Update)
	health:HookScript("OnValueChanged", NamePlateHealthBar_Update)

	if not C.nameplates.showText then
		healthBar.Text:Hide()
	end

	if health:IsShown() then
		NamePlateHealthBar_Update(health)
	end

	castTexture:SetTexture(nil)

	local castBar = NamePlate_CreateStatusBar(overlay, true)
	cast.Bar = castBar

	local iconHolder = CreateFrame("Frame", nil, castBar)
	iconHolder:SetSize(32, 32)
	iconHolder:SetPoint("RIGHT", overlay, "LEFT", -8, 0)
	E:CreateBorder(iconHolder)

	local icon = iconHolder:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	icon:SetAllPoints()
	castBar.Icon = icon

	cast:HookScript("OnShow", NamePlateCastBar_OnShow)
	cast:HookScript("OnHide", NamePlateCastBar_OnHide)
	cast:HookScript("OnValueChanged", NamePlateCastBar_OnValueChanged)

	if cast:IsShown() then
		NamePlateCastBar_OnShow(cast)
	else
		castBar:Hide()
	end

	local name = E:CreateFontString(overlay, 14, nil, true, nil)
	name:SetPoint("TOP", overlay, "TOP", 0, 2)
	name:SetPoint("LEFT", overlay, -24, 0)
	name:SetPoint("RIGHT", overlay, 24, 0)
	overlay.Name = name

	raidIcon:SetParent(overlay)
	raidIcon:SetSize(32, 32)
	raidIcon:ClearAllPoints()
	raidIcon:SetPoint("LEFT", overlay, "RIGHT", 8, 0)

	local threat = healthBar:CreateTexture(nil, "OVERLAY", nil, 0)
	threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	threat:SetTexCoord(62 / 512, 194 / 512, 36 / 64, 60 / 64)
	threat:SetSize(132, 24)
	threat:SetPoint("CENTER", 0, 0)
	threat:Hide()
	overlay.Threat = threat

	local sizer = CreateFrame("Frame", nil, overlay)
	sizer:SetPoint("BOTTOMLEFT", WorldFrame)
	sizer:SetPoint("TOPRIGHT", self, "CENTER")
	sizer:SetScript("OnSizeChanged", Sizer_OnSizeChanged)
	sizer.Parent = overlay

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

				if plate.Threat:IsShown() then
					overlay.Threat:Show()
					overlay.Threat:SetVertexColor(plate.Threat:GetVertexColor())
				else
					overlay.Threat:Hide()

					if plate.Highlight:IsShown() then
						overlay.Name:SetTextColor(1, 0.8, 0.1)
					else
						overlay.Name:SetTextColor(1, 1, 1)
					end
				end

			end
		end

		self.elapsed = 0
	end
end

function NP:ToggleHealthText()
	for plate, overlay in next, NP.plates do
		if not C.nameplates.showText then
			overlay.Health.Text:Hide()
		else
			overlay.Health.Text:Show()
		end
	end
end

function NP:Initialize()
	WorldFrame:HookScript("OnUpdate", WorldFrame_OnUpdate)
end
