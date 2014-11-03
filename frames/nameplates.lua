local _, ns = ...
local format, match, floor = string.format, string.match, math.floor

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
	local healthbar = self.health

	self.overlay:SetScale(scale)

	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", self.overlay:GetWidth()))
	if sw < ow then
		self.overlay:SetScale(scale * 0.4)
	end

	healthbar:SetSize(120, 12)
	healthbar:ClearAllPoints()
	healthbar:SetPoint("TOP", self.overlay, "TOP", 0, 0)

	healthbar.interval = nil
	
	if healthbar.text then
		healthbar.text:SetText(ns.NumFormat(healthbar:GetValue()))
	end

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
	self.bar:Show()

	self.bar.icon:SetTexture(self.icon:GetTexture())
end

local function lsNamePlateCastBar_OnHide(self)
	self.bar:Hide()
end

local function lsNamePlateCastBar_OnValueChanged(self, value)
	self.bar:SetMinMaxValues(self:GetMinMaxValues())
	self.bar:SetValue(value)

	if self.shield:IsShown() then
		self.bar.icon:SetDesaturated(true)
		self.bar:SetStatusBarColor(0.6, 0.6, 0.6)
		self.bar.bg:SetTexture(0.2, 0.2, 0.2)
	else
		self.bar.icon:SetDesaturated(false)
		self.bar:SetStatusBarColor(0.15, 0.15, 0.15)
		self.bar.bg:SetTexture(self:GetStatusBarColor())
	end
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

	local overlay = CreateFrame("Frame", "ls"..self:GetName().."Overlay", WorldFrame)
	overlay:SetSize(120, 32)
	overlay:Hide()
	self.overlay = overlay

	ns.nameplates[self] = overlay

	-- Health
	self.health:SetParent(overlay)
	self.health:SetStatusBarTexture(ns.M.textures.statusbar)

	local healthBar = self.health
	healthBar.bg = healthBar:CreateTexture(nil, "BACKGROUND", nil, 0)
	healthBar.bg:SetAllPoints(healthBar)
	healthBar.bg:SetTexture(0.15, 0.15, 0.15)

	healthBar.fg = healthBar:CreateTexture(nil, "OVERLAY", nil, 0)
	healthBar.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	healthBar.fg:SetTexCoord(319 / 512, 449 / 512, 5 / 64, 27 / 64)
	healthBar.fg:SetSize(130, 22)
	healthBar.fg:SetPoint("CENTER", 0, 0)

	if ns.C.nameplates.showText then
		healthBar.text = healthBar:CreateFontString(nil, "OVERLAY", "lsUnitFrame10Text")
		healthBar.text:SetPoint("LEFT", healthBar, 2, 0)
		healthBar.text:SetPoint("RIGHT", healthBar, -2, 0)
		healthBar.text:SetJustifyH("RIGHT")

		healthBar:HookScript("OnValueChanged", function(self, value)
			if self.text then
				self.text:SetText(ns.NumFormat(value))
			end
		end)
	end

	healthBar:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > (self.interval or 0.1) then
			self:SetStatusBarColor(lsNamePlate_GetColor(self:GetStatusBarColor()))

			self.interval = 1
		end 
	end)

	-- Castbar
	self.cast:SetStatusBarTexture(nil)

	local castBar = CreateFrame("StatusBar", nil, overlay)
	castBar:SetStatusBarTexture(ns.M.textures.statusbar)
	castBar:SetSize(120, 12)
	castBar:SetPoint("BOTTOM", overlay, "BOTTOM", 0, 0)
	castBar:SetStatusBarTexture(ns.M.textures.statusbar)
	castBar:SetStatusBarColor(0.15, 0.15, 0.15)

	castBar.bg = castBar:CreateTexture(nil, "BACKGROUND", nil, 0)
	castBar.bg:SetAllPoints(castBar)
	castBar.bg:SetTexture(0.15, 0.15, 0.15)

	castBar.fg = castBar:CreateTexture(nil, "OVERLAY", nil, 0)
	castBar.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	castBar.fg:SetTexCoord(63 / 512, 193 / 512, 5 / 64, 27 / 64)
	castBar.fg:SetSize(130, 22)
	castBar.fg:SetPoint("CENTER", 0, 0)

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

	self.cast:HookScript("OnShow", lsNamePlateCastBar_OnShow)
	self.cast:HookScript("OnHide", lsNamePlateCastBar_OnHide)
	self.cast:HookScript("OnValueChanged", lsNamePlateCastBar_OnValueChanged)

	if self.cast:IsShown() then
		lsNamePlateCastBar_OnShow(self.cast)
	else
		castBar:Hide()
	end

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

	lsNamePlate_OnShow(self)

	self.styled = true
end

function lsNamePlates_Initialize()
	local interval = 0
	local prevNumChildren, curNumChildren = 0

	WorldFrame:HookScript("OnUpdate", function(self, elapsed)
		interval = interval + elapsed

		if interval > 0.1 then
			curNumChildren = WorldFrame:GetNumChildren()

			if curNumChildren ~= prevNumChildren  then
				for _, f in next, {self:GetChildren()} do
					if not ns.nameplates[f] then
						local name = f:GetName()
						if not f.isNotNamePlate and (name and match(name, "^NamePlate%d")) then
							lsSetNamePlateStyle(f)
						else
							f.isNotNamePlate = true
						end
					end
				end
			end

			interval = 0
		end

		for plate, overlay in pairs(ns.nameplates) do
			if plate:IsShown() then
				overlay:SetAlpha(plate:GetAlpha())
			end
		end
	end)
end
