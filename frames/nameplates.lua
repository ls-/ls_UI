local _, ns = ...
local format, match = string.format, string.match

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
	self.overlay:SetScale(1)

	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", self.overlay:GetWidth()))
	if sw < ow then
		self.overlay:SetScale(0.65)
	end

	local healthbar = self.health.bar
	healthbar:SetMinMaxValues(self.health:GetMinMaxValues())
	healthbar:SetStatusBarColor(lsNamePlate_GetColor(self.health:GetStatusBarColor()))

	local name = self.name:GetText() or UNKNOWNOBJECT
	--[[ it's pretty weird, but cuz of nameplate re-usage,
		sometimes we can have both level number and boss icon present ]]
	local level = self.boss:IsShown() and -1 or tonumber(self.level:GetText())
	local color = RGBToHEX(GetQuestDifficultyColor((level > 0) and level or 99))

	if self.boss:IsShown() then
		level = "??"
	end

	if self.elite:IsShown() then
		level = level.."+"
	end

	self.name:SetFormattedText("|cff%s%s|r %s", color, level, name)

	self.threat:ClearAllPoints()
	self.threat:SetPoint("TOPLEFT", healthbar.fg, "TOPLEFT", -1, 1)
	self.threat:SetPoint("BOTTOMRIGHT", healthbar.fg, "BOTTOMRIGHT", 1, 7)

	self.overlay:Show()
end

local function lsNamePlate_OnHide(self)
	self.overlay:Hide()
end

local function lsNamePlateCastBar_OnShow(self)
	local castbar = self.bar
	castbar:Show()
	castbar:SetMinMaxValues(self:GetMinMaxValues())

	castbar.icon:SetTexture(self.icon:GetTexture())
end

local function lsNamePlateCastBar_OnHide(self)
	self.bar:Hide()
end

local function lsSetNamePlateStyle(self)
	if self.styled then return end

	self.barFrame, self.nameFrame = self:GetChildren()
	self.health, self.cast = self.barFrame:GetChildren()

	self.name = self.nameFrame:GetRegions()
	self.threat, self.border, _, self.level, self.boss, self.raid, self.elite = self.barFrame:GetRegions()
	_, self.castborder, self.cast.shield, self.cast.icon, self.castname, self.castnameShadow = self.cast:GetRegions()

	self.level:SetParent(ns.hiddenParentFrame)
	self.elite:SetParent(ns.hiddenParentFrame)
	self.boss:SetTexture(nil)
	self.border:SetTexture(nil)

	self.cast.icon:SetParent(ns.hiddenParentFrame)
	self.castnameShadow:SetTexture(nil)
	self.castborder:SetTexture(nil)
	self.cast.shield:SetTexture(nil)

	local overlay = CreateFrame("Frame", "ls"..self:GetName().."Overlay", UIParent)
	overlay:SetSize(120, 32)
	overlay:SetPoint("TOP", self, "CENTER", 0, -6)
	overlay:Hide()

	self.overlay = overlay

	-- Health
	self.health:GetStatusBarTexture():SetTexture(nil)

	local healthBar = CreateFrame("Statusbar", nil, overlay)
	healthBar:SetPoint("TOP", overlay, "TOP", 0, 0)
	healthBar:SetPoint("LEFT", overlay, 0, 0)
	healthBar:SetPoint("RIGHT", overlay, 0, 0)
	healthBar:SetHeight(12)
	healthBar:SetStatusBarTexture(ns.M.textures.statusbar)
	healthBar:SetStatusBarColor(0.15, 0.15, 0.15)

	healthBar.bg = healthBar:CreateTexture(nil, "BACKGROUND", nil, 0)
	healthBar.bg:SetAllPoints(healthBar)
	healthBar.bg:SetTexture(0.15, 0.15, 0.15)

	healthBar.fg = healthBar:CreateTexture(nil, "OVERLAY", nil, 0)
	healthBar.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	healthBar.fg:SetTexCoord(319 / 512, 449 / 512, 5 / 64, 27 / 64)
	healthBar.fg:SetPoint("TOPLEFT", -5, 5)
	healthBar.fg:SetPoint("BOTTOMRIGHT", 5, -5)

	self.health.bar = healthBar

	self.health:HookScript("OnMinMaxChanged", function(self, min, max)
		self.bar:SetMinMaxValues(min, max)
	end)

	self.health:HookScript("OnValueChanged", function(self, value)
		self.bar:SetValue(value)

		self.bar:SetStatusBarColor(lsNamePlate_GetColor(self:GetStatusBarColor()))
	end)

	-- Castbar
	self.cast:GetStatusBarTexture():SetTexture(nil)

	local castBar = CreateFrame("Statusbar", nil, overlay)
	castBar:SetStatusBarTexture(ns.M.textures.statusbar)
	castBar:SetPoint("BOTTOM", overlay, "BOTTOM", 0, 0)
	castBar:SetPoint("LEFT", overlay, 0, 0)
	castBar:SetPoint("RIGHT", overlay, 0, 0)
	castBar:SetHeight(12)
	castBar:SetStatusBarTexture(ns.M.textures.statusbar)
	castBar:SetStatusBarColor(0.15, 0.15, 0.15)
	castBar:Hide()

	castBar.bg = castBar:CreateTexture(nil, "BACKGROUND", nil, 0)
	castBar.bg:SetAllPoints(castBar)
	castBar.bg:SetTexture(0.15, 0.15, 0.15)

	castBar.fg = castBar:CreateTexture(nil, "OVERLAY", nil, 0)
	castBar.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	castBar.fg:SetTexCoord(63 / 512, 193 / 512, 5 / 64, 27 / 64)
	castBar.fg:SetPoint("TOPLEFT", -5, 5)
	castBar.fg:SetPoint("BOTTOMRIGHT", 5, -5)

	castBar.icon = castBar:CreateTexture(nil, "BACKGROUND", nil, 1)
	castBar.icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	castBar.icon:SetSize(32, 32)
	castBar.icon:SetPoint("RIGHT", overlay, "LEFT", -8, 0)

	castBar.iconborder = castBar:CreateTexture(nil, "BACKGROUND", nil, 2)
	castBar.iconborder:SetTexture(ns.M.textures.button.normal)
	castBar.iconborder:SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
	castBar.iconborder:SetPoint("TOPLEFT", castBar.icon, "TOPLEFT", -4, 4)
	castBar.iconborder:SetPoint("BOTTOMRIGHT", castBar.icon, "BOTTOMRIGHT", 4, -4)

	self.castname:SetParent(castBar)
	self.castname:SetFont(ns.M.font, 10)
	self.castname:SetShadowColor(0, 0, 0)
	self.castname:SetShadowOffset(1, -1)
	self.castname:ClearAllPoints()
	self.castname:SetPoint("LEFT", castBar, 2, 0)
	self.castname:SetPoint("RIGHT", castBar, -2, 0)
	self.castname:SetJustifyH("CENTER")
	castBar.name = self.castname

	self.cast.bar = castBar

	self.cast:HookScript("OnValueChanged", function(self, value)
		self.bar:SetValue(value)

		if self.shield:IsShown() then
			self.bar.icon:SetDesaturated(true)
			self.bar:SetStatusBarColor(0.6, 0.6, 0.6)
			self.bar.bg:SetTexture(0.2, 0.2, 0.2)
		else
			self.bar.icon:SetDesaturated(false)
			self.bar:SetStatusBarColor(0.15, 0.15, 0.15)
			self.bar.bg:SetTexture(0.96, 0.7, 0)
		end
	end)

	self.cast:HookScript("OnShow", lsNamePlateCastBar_OnShow)
	self.cast:HookScript("OnHide", lsNamePlateCastBar_OnHide)

	-- Name
	self.name:SetParent(overlay)
	self.name:SetFont(ns.M.font, 12)
	self.name:SetPoint("BOTTOM", overlay, "TOP", 0, 5)
	self.name:SetPoint("LEFT", self.overlay, -4, 0)
	self.name:SetPoint("RIGHT", self.overlay, 4, 0)

	--RaidIcon
	self.raid:SetParent(overlay)
	self.raid:SetSize(32, 32)
	self.raid:ClearAllPoints()
	self.raid:SetPoint("LEFT", overlay, "RIGHT", 8, 0)

	-- Threat
	self.threat:SetParent(overlay)
	self.threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	self.threat:SetTexCoord(62 / 512, 194 / 512, 36 / 64, 52 / 64)

	self:HookScript("OnShow", lsNamePlate_OnShow)
	self:HookScript("OnHide", lsNamePlate_OnHide)

	self:HookScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			self.overlay:SetAlpha(self:GetAlpha())

			self.elapsed = 0
		end
	end)

	lsNamePlate_OnShow(self)

	self.styled = true
end

function lsNamePlates_Initialize()
	local interval = 0
	WorldFrame:HookScript("OnUpdate", function(self, elapsed)
		interval = interval + elapsed

		if interval > 0.1 then
			for _, f in next, {self:GetChildren()} do
				local name = f:GetName()
				if not f.isNotNamePlate and (name and match(name, "^NamePlate%d")) then
					lsSetNamePlateStyle(f)
				else
					f.isNotNamePlate = true
				end
			end

			interval = 0
		end
	end)
end
