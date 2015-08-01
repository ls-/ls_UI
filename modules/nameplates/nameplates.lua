local _, ns = ...
local E, M = ns.E, ns.M

E.NP = {}

local NP = E.NP

local tonumber, format, match = tonumber, format, strmatch
local prevNumChildren = 0

NP.plates = {}

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

local function NamePlate_OnShow(self)
	local scale = UIParent:GetEffectiveScale()
	local healthbar, overlay = self.Health.Bar, self.Overlay

	overlay:SetScale(scale)

	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", overlay:GetWidth()))
	if sw < ow then
		overlay:SetScale(scale * 0.7)
	end

	if healthbar.Text:IsShown() then
		healthbar.Text:SetText(E:NumberFormat(self.Health:GetValue()))
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

local function NamePlateCastBar_OnShow(self)
	local bar = self.Bar
	bar:Show()
	bar.Icon:SetTexture(self.Icon:GetTexture())
	bar.Text:SetText(self.Text:GetText())
end

local function NamePlateCastBar_OnHide(self)
	self.Bar:Hide()
end

local function NamePlateHealthBar_OnValueChanged(self, value)
	local bar = self.Bar
	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(value)

	if bar.Text:IsShown() then
		bar.Text:SetText(E:NumberFormat(value))
	end
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

local function NamePlate_CreateStatusBar(parent, isCastBar)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetSize(120, 14)
	bar:SetPoint(isCastBar and "BOTTOM" or "TOP", parent, isCastBar and "BOTTOM" or "TOP", 0, 0)
	bar:SetStatusBarTexture(M.textures.statusbar)
	bar:SetStatusBarColor(0.15, 0.15, 0.15)
	bar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 1)
	E:CreateBorder(bar, 8)

	if not isCastBar then
		bar:SetBorderColor(E:HEXToRGB("dfb21b"))
	end

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetAllPoints(bar)
	bg:SetTexture(M.textures.statusbar)
	bg:SetVertexColor(0.15, 0.15, 0.15)
	bar.Bg = bg

	local text = E:CreateFontString(bar, 10, nil, true, nil)
	text:SetPoint("LEFT", bar, 2, 0)
	text:SetPoint("RIGHT", bar, -2, 0)
	text:SetJustifyH(isCastBar and "CENTER" or "RIGHT")
	bar.Text = text

	return bar
end

local function Sizer_OnSizeChanged(self, x, y)
	local parent = self.Parent
	parent:Hide()
	parent:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", E:Round(x), E:Round(y - 24))
	parent:Show()
end

local function HandleNamePlate(self)
	local barFrame, nameFrame = self:GetChildren()
	self.Health, self.Cast = barFrame:GetChildren()
	
	local border, raidIcon
	self.Threat, border, self.Highlight, self.Level, self.BossIcon, raidIcon, self.EliteIcon = barFrame:GetRegions()
	self.Name = nameFrame:GetRegions()
	local healthTexture = self.Health:GetRegions()
	local castTexture, castBorder, castTextShadow
	castTexture, castBorder, self.Cast.Shield, self.Cast.Icon, self.Cast.Text, castTextShadow = self.Cast:GetRegions()

	self.Threat:SetTexture(nil)
	self.Level:SetSize(0.001, 0.001)
	self.Level:Hide()
	self.BossIcon:SetTexture(nil)
	self.EliteIcon:SetAlpha(0)
	self.Highlight:SetTexture(nil)
	self.Name:Hide()
	self.Cast.Shield:SetTexture(nil)
	self.Cast.Icon:SetTexCoord(0, 0, 0, 0)
	self.Cast.Icon:SetSize(0.001, 0.001)
	self.Cast.Text:Hide()
	border:SetTexture(nil)
	castBorder:SetTexture(nil)
	castTextShadow:SetTexture(nil)

	local overlay = CreateFrame("Frame", "LS"..self:GetName().."Overlay", WorldFrame)
	overlay:SetSize(120, 32)
	self.Overlay = overlay
	NP.plates[self] = overlay

	-- Health
	healthTexture:SetTexture(nil)

	local healthBar = NamePlate_CreateStatusBar(overlay)
	healthBar.Text:Hide()
	self.Health.Bar = healthBar
	self.Health:HookScript("OnValueChanged", NamePlateHealthBar_OnValueChanged)

	-- Castbar
	castTexture:SetTexture(nil)

	local castBar = NamePlate_CreateStatusBar(overlay, true)
	self.Cast.Bar = castBar
	self.Cast:HookScript("OnShow", NamePlateCastBar_OnShow)
	self.Cast:HookScript("OnHide", NamePlateCastBar_OnHide)
	self.Cast:HookScript("OnValueChanged", NamePlateCastBar_OnValueChanged)

	if self.Cast:IsShown() then
		NamePlateCastBar_OnShow(self.Cast)
	else
		castBar:Hide()
	end

	local iconHolder = CreateFrame("Frame", nil, castBar)
	iconHolder:SetSize(32, 32)
	iconHolder:SetPoint("RIGHT", overlay, "LEFT", -8, 0)
	E:CreateBorder(iconHolder)

	local icon = iconHolder:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	icon:SetAllPoints()
	castBar.Icon = icon

	-- Name
	local name = E:CreateFontString(overlay, 14, nil, true, nil)
	name:SetPoint("BOTTOM", overlay, "TOP", 0, 6)
	name:SetPoint("LEFT", overlay, -24, 0)
	name:SetPoint("RIGHT", overlay, 24, 0)
	overlay.Name = name

	-- RaidIcon
	raidIcon:SetParent(overlay)
	raidIcon:SetSize(32, 32)
	raidIcon:ClearAllPoints()
	raidIcon:SetPoint("LEFT", overlay, "RIGHT", 8, 0)

	-- Threat
	local threat = healthBar:CreateTexture(nil, "OVERLAY", nil, 1)
	threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	threat:SetTexCoord(62 / 512, 194 / 512, 36 / 64, 52 / 64)
	-- threat:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -5, 5)
	-- threat:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 5, 8)
	threat:SetVertexColor(0.15, 0.15, 0.15)
	threat:Hide()
	overlay.Threat = threat

	-- Position
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

				plate.Health.Bar:SetStatusBarColor(NamePlate_GetColor(plate.Health:GetStatusBarColor()))

				if plate.Threat:IsShown() then
					-- overlay.threat:Show()
					-- plate.Health.bar:SetBorderColor(plate.Threat:GetVertexColor())
					-- overlay.threat:SetVertexColor(plate.Threat:GetVertexColor())
				else
					-- overlay.threat:Hide()

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

function NP:Initialize()
	WorldFrame:HookScript("OnUpdate", WorldFrame_OnUpdate)
end
