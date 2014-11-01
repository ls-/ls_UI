local _, ns = ...

local function RGBToHEX(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function lsNamePlate_GetColor(r, g, b, a)
	r, g, b, a = string.format("%.2f", r), string.format("%.2f", g), string.format("%.2f", b), string.format("%.2f", a)

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
	local healthbar, scale = self.health.bar, self.overlay.scale
	local w, h = self:GetWidth(), self:GetHeight()

	self.overlay:SetSize(math.floor(w * scale), math.ceil(h * scale))
	healthbar:ClearAllPoints()
	healthbar:SetPoint("TOP", self.overlay, "TOP", 0, -math.ceil(h / 15 * scale))
	healthbar:SetPoint("LEFT", self.overlay, 0, 0)
	healthbar:SetPoint("RIGHT", self.overlay, 0, 0)
	healthbar:SetHeight(math.ceil(h / 3 * scale))
	healthbar:SetMinMaxValues(self.health:GetMinMaxValues())
	healthbar:SetStatusBarColor(lsNamePlate_GetColor(self.health:GetStatusBarColor()))

	-- healthbar.fg:SetPoint("TOPLEFT", -math.ceil(h / 10 * scale), math.ceil(h / 10 * scale))
	-- healthbar.fg:SetPoint("BOTTOMRIGHT", math.ceil(h / 10 * scale), -math.ceil(h / 10 * scale))
	healthbar.fg:SetSize(math.floor(w * 1.06 * scale), math.ceil(h * 0.6 * scale))
	print(healthbar.fg:GetSize())
	self.raid:ClearAllPoints()
	self.raid:SetSize(math.floor(h * 0.95 * scale), math.floor(h * 0.95 * scale))
	self.raid:SetPoint("LEFT", self.overlay, "RIGHT", math.ceil(w / 50 * scale), 0)

	self.name:SetPoint("LEFT", self.overlay, -math.ceil(w * 0.045 * scale), 0)
	self.name:SetPoint("RIGHT", self.overlay, math.ceil(w * 0.045 * scale), 0)

	local name = self.name:GetText() or UNKNOWNOBJECT
	local level = tonumber(self.level:GetText()) or -1
	local color = RGBToHEX(GetQuestDifficultyColor((level > 0) and level or 99))

	if self.boss:IsShown() then
		level = "??"
	end

	if self.dragon:IsShown() then
		level = level.."+"
	end

	self.name:SetFormattedText("|cff%s%s|r %s", color, level, name)
end

local function lsNamePlateCastBar_OnShow(self)
	local castbar, parent, scale = self.bar, self.parent, self.parent.overlay.scale
	local w, h = parent:GetWidth(), parent:GetHeight()

	castbar:ClearAllPoints()
	castbar:SetPoint("BOTTOM", parent.overlay, "BOTTOM", 0, math.ceil(h / 15 * scale))
	castbar:SetPoint("LEFT", parent.overlay, 0, 0)
	castbar:SetPoint("RIGHT", parent.overlay, 0, 0)
	castbar:SetHeight(math.ceil(h / 3 * scale))
	castbar:SetMinMaxValues(self:GetMinMaxValues())

	castbar.fg:SetPoint("TOPLEFT", -math.ceil(h / 10 * scale), math.ceil(h / 10 * scale))
	castbar.fg:SetPoint("BOTTOMRIGHT", math.ceil(h / 10 * scale), -math.ceil(h / 10 * scale))

	castbar.icon:SetTexture(self.icon:GetTexture())
	castbar.icon:SetSize(math.ceil(h * 0.95 * scale), math.ceil(h * 0.95 * scale))
	castbar.icon:SetPoint("RIGHT", parent.overlay, "LEFT", -math.ceil(w / 50 * scale), 0)

	castbar.iconborder:SetPoint("TOPLEFT", castbar.icon, "TOPLEFT", -math.ceil(h / 15 * scale), math.ceil(h / 15 * scale))
	castbar.iconborder:SetPoint("BOTTOMRIGHT", castbar.icon, "BOTTOMRIGHT", math.ceil(h / 15 * scale), -math.ceil(h / 15 * scale))

	self.name:ClearAllPoints()
	self.name:SetPoint("LEFT", castbar, 2, 0)
	self.name:SetPoint("RIGHT", castbar, -2, 0)
	self.name:SetJustifyH("LEFT")
end

local function lsSetNamePlateStyle(self)
	if self.styled then return end

	self.barFrame, self.nameFrame = self:GetChildren()
	self.health, self.cast = self.barFrame:GetChildren()

	self.name = self.nameFrame:GetRegions()
	self.threat, self.border, _, self.level, self.boss, self.raid, self.dragon = self.barFrame:GetRegions()
	_, self.cast.border, self.cast.shield, self.cast.icon, self.cast.name, self.cast.nameShadow = self.cast:GetRegions()

	self.level:SetParent(ns.hiddenParentFrame)
	self.dragon:SetParent(ns.hiddenParentFrame)
	self.boss:SetTexture(nil)
	self.border:SetTexture(nil)

	self.cast.icon:SetParent(ns.hiddenParentFrame)
	self.cast.nameShadow:SetTexture(nil)
	self.cast.border:SetTexture(nil)
	self.cast.shield:SetTexture(nil)

	self.overlay = CreateFrame("Frame", self:GetName().."Overlay", self)
	self.overlay.scale = 0.77
	self.overlay:SetPoint("TOP", self, "CENTER", 0, -2)

	-- health
	self.health:GetStatusBarTexture():SetTexture(nil)

	self.health.bar = CreateFrame("Statusbar", nil, self)
	self.health.bar:SetStatusBarTexture(ns.M.textures.statusbar)
	self.health.bar:SetStatusBarColor(0.15, 0.15, 0.15)

	self.health.bar.bg = self.health.bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	self.health.bar.bg:SetAllPoints(self.health.bar)
	self.health.bar.bg:SetTexture(0.15, 0.15, 0.15)

	self.health.bar.fg = self.health.bar:CreateTexture(nil, "OVERLAY", nil, 0)
	self.health.bar.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	self.health.bar.fg:SetTexCoord(45 / 512, 211 / 512, 3 / 64, 29 / 64)
	self.health.bar.fg:SetPoint("CENTER")

	self.health:HookScript("OnMinMaxChanged", function(self, min, max)
		self.bar:SetMinMaxValues(min, max)
	end)

	self.health:HookScript("OnValueChanged", function(self, value)
		self.bar:SetValue(value)

		self.bar:SetStatusBarColor(lsNamePlate_GetColor(self:GetStatusBarColor()))
	end)

	-- castbar
	self.cast:GetStatusBarTexture():SetTexture(nil)
	self.cast.parent = self

	self.cast.bar = CreateFrame("Statusbar", nil, self.cast)
	self.cast.bar:SetStatusBarTexture(ns.M.textures.statusbar)

	self.cast.bar.bg = self.cast.bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	self.cast.bar.bg:SetAllPoints(self.cast.bar)
	self.cast.bar.bg:SetTexture(0.96, 0.7, 0)

	self.cast.bar.fg = self.cast.bar:CreateTexture(nil, "OVERLAY", nil, 0)
	self.cast.bar.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	self.cast.bar.fg:SetTexCoord(45 / 512, 211 / 512, 3 / 64, 29 / 64)
	-- self.cast.bar.fg:SetPoint("TOPLEFT", -2, 2)
	-- self.cast.bar.fg:SetPoint("BOTTOMRIGHT", 2, -2)

	self.cast.bar.icon = self.cast.bar:CreateTexture(nil, "BACKGROUND", nil, 1)
	self.cast.bar.icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)

	self.cast.bar.iconborder = self.cast.bar:CreateTexture(nil, "BACKGROUND", nil, 2)
	self.cast.bar.iconborder:SetTexture(ns.M.textures.button.normal)
	self.cast.bar.iconborder:SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)

	self.cast.name:SetFont(ns.M.font, 8)
	self.cast.name:SetParent(self.cast.bar)
	self.cast.name:SetShadowColor(0, 0, 0)
	self.cast.name:SetShadowOffset(1, -1)

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

	self.name:SetFont(ns.M.font, 8)

	self:HookScript("OnShow", lsNamePlate_OnShow)
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
				if name and (not f.isNotNamePlate and string.match(name, "NamePlate%d")) then
					lsSetNamePlateStyle(f)
				else
					f.isNotNamePlate = true
				end
			end

			interval = 0
		end
	end)
end
