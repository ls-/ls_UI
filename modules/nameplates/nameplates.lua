local _, ns = ...
local E = ns.E

local format, match, floor = format, strmatch, floor
local SCALE

ns.nameplates = {}

local function RGBToHEX(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	return format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function lsNamePlate_GetColor(r, g, b, a)
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

local function lsNamePlate_OnShow(self)
	local scale = UIParent:GetEffectiveScale()
	local healthbar, overlay = self.health.bar, self.overlay

	overlay:SetScale(scale)

	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", overlay:GetWidth()))
	if sw < ow then
		overlay:SetScale(scale * 0.7)
	end

	if healthbar.text then
		healthbar.text:SetText(E:NumFormat(self.health:GetValue()))
	end

	local name = self.name:GetText() or UNKNOWNOBJECT
	--[[ it's pretty weird, but cuz of nameplate re-usage,
		sometimes we can have both level number and bossIcon icon present ]]
	local level = self.bossIcon:IsShown() and -1 or tonumber(self.level:GetText())
	local color = RGBToHEX(GetQuestDifficultyColor((level > 0) and level or 99))

	if self.bossIcon:IsShown() then
		level = "??"
	end

	if self.eliteIcon:IsShown() then
		level = level.."+"
	end

	overlay.name:SetFormattedText("|cff%s%s|r %s", color, level, name)

	self.overlay:Show()
end

local function lsNamePlate_OnHide(self)
	self.overlay:Hide()
end

local function lsNamePlateCastBar_OnShow(self)
	self.bar:Show()

	self.bar.icon:SetTexture(self.icon:GetTexture())

	self.bar.text:SetText(self.text:GetText())
end

local function lsNamePlateCastBar_OnHide(self)
	self.bar:Hide()
end

local function lsNamePlateHealthBar_OnValueChanged(self, value)
	self.bar:SetMinMaxValues(self:GetMinMaxValues())
	self.bar:SetValue(value)

	if self.bar.text then
		self.bar.text:SetText(E:NumFormat(value))
	end
end

local function lsNamePlateCastBar_OnValueChanged(self, value)
	self.bar:SetMinMaxValues(self:GetMinMaxValues())
	self.bar:SetValue(value)

	if self.shield:IsShown() then
		self.bar.icon:SetDesaturated(true)
		self.bar:SetStatusBarColor(0.6, 0.6, 0.6)
		self.bar.bg:SetVertexColor(0.2, 0.2, 0.2)
	else
		self.bar.icon:SetDesaturated(false)
		self.bar:SetStatusBarColor(0.15, 0.15, 0.15)
		self.bar.bg:SetVertexColor(0.96, 0.7, 0)
	end
end

local function lsNamePlate_CreateStatusBar(parent, isCastBar)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetSize(120, 12)
	bar:SetPoint(isCastBar and "BOTTOM" or "TOP", parent, isCastBar and "BOTTOM" or "TOP", 0, 0)
	bar:SetStatusBarTexture(ns.M.textures.statusbar)
	bar:SetStatusBarColor(0.15, 0.15, 0.15)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture(ns.M.textures.statusbar)
	bar.bg:SetVertexColor(0.15, 0.15, 0.15)

	bar.fg = bar:CreateTexture(nil, "OVERLAY", nil, 0)
	bar.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	bar.fg:SetTexCoord((isCastBar and 63 or 319) / 512, (isCastBar and 193 or 449) / 512, 5 / 64, 27 / 64)
	bar.fg:SetSize(130, 22)
	bar.fg:SetPoint("CENTER", 0, 0)

	bar.text = bar:CreateFontString(nil, "OVERLAY", "lsUnitFrame10Text")
	bar.text:SetPoint("LEFT", bar, 2, 0)
	bar.text:SetPoint("RIGHT", bar, -2, 0)
	bar.text:SetJustifyH(isCastBar and "CENTER" or "RIGHT")

	return bar
end

local function lsSetNamePlateStyle(self)
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

	local overlay = CreateFrame("Frame", "ls"..self:GetName().."Overlay", WorldFrame)
	overlay:SetSize(120, 32)
	self.overlay = overlay

	ns.nameplates[self] = overlay

	-- Health
	self.health.texture:SetTexture(nil)

	local healthBar = lsNamePlate_CreateStatusBar(overlay)

	if not ns.C.nameplates.showText then
		healthBar.text = nil
	end

	self.health.bar = healthBar

	self.health:HookScript("OnValueChanged", lsNamePlateHealthBar_OnValueChanged)

	-- Castbar
	self.cast.texture:SetTexture(nil)

	local castBar = lsNamePlate_CreateStatusBar(overlay, true)

	castBar.icon = castBar:CreateTexture(nil, "BACKGROUND", nil, 1)
	castBar.icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	castBar.icon:SetSize(32, 32)
	castBar.icon:SetPoint("RIGHT", overlay, "LEFT", -8, 0)

	castBar.iconborder = castBar:CreateTexture(nil, "BACKGROUND", nil, 2)
	castBar.iconborder:SetTexture(ns.M.textures.button.normal)
	castBar.iconborder:SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
	castBar.iconborder:SetPoint("TOPLEFT", castBar.icon, "TOPLEFT", -4, 4)
	castBar.iconborder:SetPoint("BOTTOMRIGHT", castBar.icon, "BOTTOMRIGHT", 4, -4)

	self.cast.bar = castBar

	self.cast:HookScript("OnShow", lsNamePlateCastBar_OnShow)
	self.cast:HookScript("OnHide", lsNamePlateCastBar_OnHide)
	self.cast:HookScript("OnValueChanged", lsNamePlateCastBar_OnValueChanged)

	if self.cast:IsShown() then
		lsNamePlateCastBar_OnShow(self.cast)
	else
		castBar:Hide()
	end

	-- Name
	overlay.name = overlay:CreateFontString(nil, "OVERLAY", "lsUnitFrame14Text")
	overlay.name:SetPoint("BOTTOM", overlay, "TOP", 0, 6)
	overlay.name:SetPoint("LEFT", overlay, -24, 0)
	overlay.name:SetPoint("RIGHT", overlay, 24, 0)

	-- RaidIcon
	self.raidIcon:SetParent(overlay)
	self.raidIcon:SetSize(32, 32)
	self.raidIcon:ClearAllPoints()
	self.raidIcon:SetPoint("LEFT", overlay, "RIGHT", 8, 0)

	-- Threat
	overlay.threat = healthBar:CreateTexture(nil, "OVERLAY", nil, 1)
	overlay.threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	overlay.threat:SetTexCoord(62 / 512, 194 / 512, 36 / 64, 52 / 64)
	overlay.threat:SetPoint("TOPLEFT", healthBar.fg, "TOPLEFT", -1, 1)
	overlay.threat:SetPoint("BOTTOMRIGHT", healthBar.fg, "BOTTOMRIGHT", 1, 7)
	overlay.threat:SetVertexColor(0.15, 0.15, 0.15)
	overlay.threat:Hide()

	-- Highlight
	overlay.hl = healthBar:CreateTexture(nil, "OVERLAY", nil, 2)
	overlay.hl:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	overlay.hl:SetTexCoord(321 / 512, 447 / 512, 39 / 64, 57 / 64)
	overlay.hl:SetSize(126, 18)
	overlay.hl:SetPoint("CENTER", 0, 0)
	overlay.hl:SetBlendMode("ADD")
	overlay.hl:Hide()

	-- Position
	local sizer = CreateFrame("Frame", nil, overlay)
	sizer:SetPoint("BOTTOMLEFT", WorldFrame)
	sizer:SetPoint("TOPRIGHT", self, "CENTER")
	sizer:SetScript("OnSizeChanged", function(self, x, y)
		overlay:Hide()
		overlay:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", floor(x), floor(y - 24))
		overlay:Show()
	end)

	self:HookScript("OnShow", lsNamePlate_OnShow)
	self:HookScript("OnHide", lsNamePlate_OnHide)

	if self:IsShown() then
		lsNamePlate_OnShow(self)
	else
		overlay:Hide()
	end
end

function ns.lsNamePlates_Initialize()
	local prevNumChildren, curNumChildren = 0

	WorldFrame:HookScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			curNumChildren = WorldFrame:GetNumChildren()

			if curNumChildren ~= prevNumChildren  then
				for i = prevNumChildren + 1, curNumChildren do
					local f = select(i, WorldFrame:GetChildren())

					local name = f:GetName()
					if (name and match(name, "^NamePlate%d")) and not ns.nameplates[f] then
						lsSetNamePlateStyle(f)
					end
				end

				prevNumChildren = curNumChildren
			end

			for plate, overlay in next, ns.nameplates do
				if plate:IsShown() then
					overlay:SetAlpha(plate:GetAlpha())

					plate.health.bar:SetStatusBarColor(lsNamePlate_GetColor(plate.health:GetStatusBarColor()))

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
	end)
end
