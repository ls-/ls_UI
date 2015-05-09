local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

ns.objects, ns.headers = {}, {}

local prevInUse = "NONE"
local curInUse = {
	["RUNE"] = {visible = false, slots = 0},
	["TOTEM"] = {visible = false, slots = 0},
	["CHI"] = {visible = false, slots = 0},
	["HOLYPOWER"] = {visible = false, slots = 0},
	["SOULSHARD"] = {visible = false, slots = 0},
	["SHADOWORB"] = {visible = false, slots = 0},
	["EMBER"] = {visible = false, slots = 0},
	["FURY"] = {visible = false, slots = 0},
	["ECLIPSE"] = {visible = false, slots = 0},
	["NONE"] = {visible = false, slots = 0},
}

local function FrameReskin(frame, powerType, visible, slots, sentBy)
	if curInUse[powerType].visible == visible and curInUse[powerType].slots == slots or (powerType == "NONE" and prevInUse ~= sentBy) then return end
	curInUse[prevInUse].visible = false
	curInUse[prevInUse].slots = 0
	curInUse[powerType].visible = visible
	curInUse[powerType].slots = slots
	for ptype, pdata in pairs(curInUse) do
		if pdata.visible then
			frame.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_sep_"..pdata.slots)
		end
	end
	prevInUse = powerType
end

local function UpdateExperience(self, ...)
	self.text:UpdateTag()
end

local function UpdateReputation(self, unit, min, max, name, id, standingID)
	local color = FACTION_BAR_COLORS[standingID]
	self.bg:SetTexture(color.r * 0.5, color.g * 0.5, color.b * 0.5, 0.5)
	self.text:UpdateTag()
end

-----------------
-- CLASS POWER --
-----------------

local function CreateComboBar(self)
	local bar = CreateFrame("Frame", "$parentComboBar", self)
	bar:SetFrameStrata(self:GetFrameStrata())
	bar:SetFrameLevel(self:GetFrameLevel() + 4)
	bar:SetSize(96, 20)
	bar:SetPoint("TOPRIGHT", self, "TOPRIGHT", -16, 4.5)

	bar.fg = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	bar.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_combo")
	bar.fg:SetTexCoord(0, 96 / 128, 0, 20 / 32)
	bar.fg:SetAllPoints(bar)

	local r, g, b = unpack(M.colors.classpower.COMBO)
	for i = 1, MAX_COMBO_POINTS do
		bar[i] = bar:CreateTexture(nil, "BACKGROUND", nil, 3)
		bar[i]:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_combo")
		bar[i]:SetTexCoord(99 / 128, 113 / 128, 3 / 32, 17 / 32)
		bar[i]:SetVertexColor(r, g, b)
		bar[i]:SetSize(14, 14)
		if i == 1 then
			bar[i]:SetPoint("LEFT", bar, "LEFT", 3, 0)
		else
			bar[i]:SetPoint("LEFT", bar[i - 1], "RIGHT", 5, 0)
		end
		bar[i].bg = bar:CreateTexture(nil, "BACKGROUND", nil, 2)
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_combo")
		bar[i].bg:SetTexCoord(99 / 128, 113 / 128, 3 / 32, 17 / 32)
		bar[i].bg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)

		bar[i].glow = bar:CreateTexture(nil, "ARTWORK", nil, 2)
		bar[i].glow:SetAllPoints(bar[i])
		bar[i].glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_combo")
		bar[i].glow:SetTexCoord(113 / 128, 127 / 128, 17 / 32, 31 / 32)
		bar[i].glow:SetVertexColor(unpack(M.colors.classpower.GLOW))
		bar[i].glow:SetAlpha(0)
		lsCreateAlphaAnimation(bar[i].glow, 1, 0.5)
	end
	return bar
end

local function PostUpdateComboBar(self, cp)
	if not self[1]:IsShown() then
		self:Hide()
	else
		self:Show()
		if cp / MAX_COMBO_POINTS == 1 then
			for i = 1, MAX_COMBO_POINTS do
				self[i].glow.animation:Play()
			end
		else
			for i = 1, MAX_COMBO_POINTS do
				self[i].glow.animation:Finish()
			end
		end
	end
end

local function CreateClassPowerBar(self, max, cpType)
	local bar = CreateFrame("Frame", "bar"..cpType, self, "lsClassPowerFrameTemplate")
	bar.__cpower = cpType

	for i = 1, 5 do
		bar[i] = bar:CreateTexture("icon"..i..cpType, "BACKGROUND", nil, 3)

		bar[i].glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 2)
		bar[i].glow:SetAlpha(0)
		lsCreateAlphaAnimation(bar[i].glow, 1, 0.5)
	end

	return bar
end

local function UpdateClassPowerBar(self, cur, max, changed, event)
	if event == "ClassPowerEnable" or changed and max ~= 0 then
		local r, g, b = unpack(M.colors.classpower[self.__cpower])
		for i = 1, max do
			self[i]:SetTexCoord(0, 1, 0, 1)
			self[i]:SetSize(unpack(M.textures.cpower["total"..max]["cpower"..i].size))
			self[i]:SetPoint(unpack(M.textures.cpower["total"..max]["cpower"..i].point))
			self[i]:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
			self[i]:SetVertexColor(r, g, b)

			local left, right, top, bottom = unpack(M.textures.cpower["total"..max]["cpower"..i].glowcoord)
			self[i].glow:SetSize(abs(right - left) * 512, abs(bottom - top) * 256)
			self[i].glow:SetPoint(unpack(M.textures.cpower["total"..max]["cpower"..i].glowpoint))
			self[i].glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\cpower_glow")
			self[i].glow:SetTexCoord(left, right, top, bottom)
			self[i].glow:SetVertexColor(unpack(M.colors.classpower.GLOW))
		end
	end
	if event == "ClassPowerDisable" then
		self:Hide()
		FrameReskin(self:GetParent(), "NONE", true, 0, self.__cpower)
	else
		self:Show()
		FrameReskin(self:GetParent(), self.__cpower, true, max or 5)
		if cur / (max or 5) == 1 then
			for i = 1, max do
				self[i].glow.animation:Play()
			end
		else
			for i = 1, max do
				self[i].glow.animation:Finish()
			end
		end
	end
end

local function CreateDemonicFury(self)
	local bar = CreateFrame("StatusBar", "barFURY", self, "lsClassPowerFrameTemplate")
	bar:SetOrientation("VERTICAL")
	bar:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1")
	bar.__cpower = "FURY"

	local left, right, top, bottom = unpack(M.textures.cpower.total1.cpower1.glowcoord)
	bar.glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 2)
	bar.glow:SetSize(abs(right - left) * 512, abs(bottom - top) * 256)
	bar.glow:SetPoint(unpack(M.textures.cpower.total1.cpower1.glowpoint))
	bar.glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\cpower_glow")
	bar.glow:SetTexCoord(left, right, top, bottom)
	bar.glow:SetVertexColor(0, 1, 0.1)
	bar.glow:SetAlpha(0)
	lsCreateAlphaAnimation(bar.glow, 1, 0.5)

	return bar
end

local function UpdateDemonicFury(self, cur, max)
	if cur == max then
		self.glow.animation:Play()
	else
		self.glow.animation:Finish()
	end
	if not self:IsShown() then
		FrameReskin(self:GetParent(), "NONE", true, 0, self.__cpower)
	else
		FrameReskin(self:GetParent(), self.__cpower, true, 1)
	end
end

local function CreateBurningEmbers(self)
	local bar = CreateFrame("Frame", "barEMBERS", self, "lsClassPowerFrameTemplate")
	bar.__cpower = "EMBER"

	for i = 1, 4 do
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i]:SetFrameLevel(bar:GetFrameLevel())
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetSize(unpack(M.textures.cpower.total4["cpower"..i].size))
		bar[i]:SetPoint(unpack(M.textures.cpower.total4["cpower"..i].point))
		bar[i]:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_4\\"..i)

		local left, right, top, bottom = unpack(M.textures.cpower.total4["cpower"..i].glowcoord)
		bar[i].glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 2)
		bar[i].glow:SetSize(abs(right - left) * 512, abs(bottom - top) * 256)
		bar[i].glow:SetPoint(unpack(M.textures.cpower.total4["cpower"..i].glowpoint))
		bar[i].glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\cpower_glow")
		bar[i].glow:SetTexCoord(left, right, top, bottom)
		bar[i].glow:SetVertexColor(unpack(M.colors.classpower.GLOW))
		bar[i].glow:SetAlpha(0)
		lsCreateAlphaAnimation(bar[i].glow, 1, 0.5)
	end

	return bar
end

local function UpdateBurningEmbers(self, full, count)
	local resetAnimation
	if self.oldFull ~= full then
		self.oldFull = full
		resetAnimation = true
	end

	if full > 0 then
		for i = 1, full do
			if resetAnimation then
				self[i].glow.animation:Stop()
			end
			self[i].glow.animation:Play()
		end
		if full ~= count then
			for i = (full < 4 and full + 1 or full) , count do
				self[i].glow.animation:Finish()
			end
		end
	else
		for i = 1, count do
			self[i].glow.animation:Finish()
		end
	end

	resetAnimation = false

	if not self[1]:IsShown() then
		self:Hide()
		FrameReskin(self:GetParent(), "NONE", true, 0, self.__cpower)
	else
		self:Show()
		FrameReskin(self:GetParent(), self.__cpower, true, count or 4)
	end
end

local function CreateTotemBar(self)
	local bar = CreateFrame("Frame", "barTOTEM", self, "lsClassPowerFrameTemplate")
	bar.__cpower = "TOTEM"

	for i = 1, MAX_TOTEMS do
		local r, g, b = unpack(M.colors.totem[i])
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i]:SetFrameLevel(bar:GetFrameLevel())
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetSize(unpack(M.textures.cpower["total"..MAX_TOTEMS]["cpower"..i].size))
		bar[i]:SetPoint(unpack(M.textures.cpower["total"..MAX_TOTEMS]["cpower"..i].point))
		bar[i]:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..MAX_TOTEMS.."\\"..i)
		bar[i]:SetStatusBarColor(r, g, b)

		local left, right, top, bottom = unpack(M.textures.cpower["total"..MAX_TOTEMS]["cpower"..i].glowcoord)
		bar[i].glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 2)
		bar[i].glow:SetSize(abs(right - left) * 512, abs(bottom - top) * 256)
		bar[i].glow:SetPoint(unpack(M.textures.cpower["total"..MAX_TOTEMS]["cpower"..i].glowpoint))
		bar[i].glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\cpower_glow")
		bar[i].glow:SetTexCoord(left, right, top, bottom)
		bar[i].glow:SetVertexColor(r * 1.25, g * 1.25, b * 1.25)
		bar[i].glow:SetAlpha(0)
		lsCreateAlphaAnimation(bar[i].glow, 1, 0.5)

		bar[i].text = ns.CreateFontString(bar.cover, M.font, 14, "THINOUTLINE")
		bar[i].text:SetPoint(unpack(M.textures.cpower["total"..MAX_TOTEMS]["cpower"..i].glowpoint))
		bar[i].text:SetTextColor(r, g, b)
		lsCreateAlphaAnimation(bar[i].text, -0.5)
	end
	return bar
end

local function UpdateTotemBar(self, priorities, haveTotem, name, start, duration, icon)
	local totem = self[priorities]
	totem:SetMinMaxValues(0, duration)
	if duration > 0 then
		totem:SetScript("OnUpdate", function (self, elapsed)
			local timeLeft = start + duration - GetTime()
			self:SetValue(timeLeft)
			if timeLeft <= 15 then
				self.text:SetText(E:TimeFormat(timeLeft))
			end
			if timeLeft <= 0 then
				self.text:SetText("")
				self.glow.animation:Finish()
				self.text.animation:Finish()
				self:SetValue(0)
				return self:SetScript("OnUpdate", nil)
			else
				if timeLeft <= 10 then
					if not self.glow.animation:IsPlaying() and not self.text.animation:IsPlaying() then
						self.glow.animation:Play()
						self.text.animation:Play()
					end
				end
			end
		end)
	else
		totem.text:SetText("")
		totem.glow.animation:Finish()
		totem.text.animation:Finish()
		totem:SetScript("OnUpdate", nil)
	end
	if UnitHasVehicleUI("player") then
		self:Hide()
		FrameReskin(self:GetParent(), "NONE", true, 0, self.__cpower)
	else
		self:Show()
		FrameReskin(self:GetParent(), "TOTEM", true, 4)
	end
end

local function CreateRuneBar(self)
	local bar = CreateFrame("Frame", "barRUNE", self, "lsClassPowerFrameTemplate")
	bar.__cpower = "RUNE"

	for i = 1, 6 do
		bar[i] = CreateFrame('StatusBar', "Rune"..i, bar)
		bar[i]:SetFrameLevel(bar:GetFrameLevel())
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetSize(unpack(M.textures.cpower.total6["cpower"..i].size))
		bar[i]:SetPoint(unpack(M.textures.cpower.total6["cpower"..i].point))
		bar[i]:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_6\\"..i)

		local left, right, top, bottom = unpack(M.textures.cpower.total6["cpower"..i].glowcoord)
		bar[i].glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 2)
		bar[i].glow:SetSize(abs(right - left) * 512, abs(bottom - top) * 256)
		bar[i].glow:SetPoint(unpack(M.textures.cpower.total6["cpower"..i].glowpoint))
		bar[i].glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\cpower_glow")
		bar[i].glow:SetTexCoord(left, right, top, bottom)
		bar[i].glow:SetVertexColor(unpack(M.colors.classpower.GLOW))
		bar[i].glow:SetAlpha(0)
		lsCreateAlphaAnimation(bar[i].glow, 1, 0.5)
	end

	return bar
end

local function PostUpdateRuneBar(self, rune, rid, start, duration, runeReady)
	if runeReady and start == 0 then
		rune.glow.animation:Play()
		rune:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed > 0.1 then
				self.animState = self.glow.animation:GetLoopState()
				if self.animState == "REVERSE" then
					self.initStop = true
				end
				if self.initStop then
					self.glow.animation:Finish()
					self.initStop = false
					return self:SetScript("OnUpdate", nil)
				end
				self.elapsed = 0
			end
		end)
	else
		if rune.glow.animation:IsPlaying() then
			rune.glow.animation:Finish()
		end
	end

	if UnitHasVehicleUI("player") then
		self:Hide()
		FrameReskin(self:GetParent(), "NONE", true, 0, self.__cpower)
	else
		self:Show()
		FrameReskin(self:GetParent(), "RUNE", true, 6)
	end
end

local function CreateEclipseBar(self)
	local bar = CreateFrame("Frame", "barECLIPSE", self, "lsClassPowerFrameTemplate")
	bar.__cpower = "ECLIPSE"

	bar.LunarBar = CreateFrame("StatusBar", nil, bar)
	bar.LunarBar:SetFrameLevel(bar:GetFrameLevel())
	bar.LunarBar:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1")
	bar.LunarBar:SetStatusBarColor(unpack(M.colors.eclipse["moon"]))
	bar.LunarBar:SetOrientation("VERTICAL")
	bar.LunarBar:SetPoint("CENTER", 0, 0)
	bar.LunarBar:SetSize(64, 132)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints(bar.LunarBar)
	bar.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1")
	bar.bg:SetVertexColor(unpack(M.colors.eclipse["sun"]))

	local left, right, top, bottom = unpack(M.textures.cpower.total1.cpower1.glowcoord)
	bar.glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 2)
	bar.glow:SetSize(abs(right - left) * 512, abs(bottom - top) * 256)
	bar.glow:SetPoint(unpack(M.textures.cpower.total1.cpower1.glowpoint))
	bar.glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\cpower_glow")
	bar.glow:SetTexCoord(left, right, top, bottom)
	bar.glow:SetAlpha(0)
	lsCreateAlphaAnimation(bar.glow, 1)

	bar.sun = bar.cover:CreateTexture(nil, "ARTWORK", nil, 6)
	bar.sun:SetPoint("TOPLEFT", -10, 12)
	bar.sun:SetSize(36, 36)
	bar.sun:SetTexture("Interface\\PlayerFrame\\UI-DruidEclipse")
	bar.sun:SetTexCoord(0.55859375, 0.72656250, 0.00781250, 0.35937500)
	bar.sun:SetAlpha(0)
	lsCreateAlphaAnimation(bar.sun, 1)

	bar.moon = bar.cover:CreateTexture(nil, "ARTWORK", nil, 6)
	bar.moon:SetPoint("BOTTOMLEFT", -10, -12)
	bar.moon:SetSize(36, 36)
	bar.moon:SetTexture("Interface\\PlayerFrame\\UI-DruidEclipse")
	bar.moon:SetTexCoord(0.73437500, 0.90234375, 0.00781250, 0.35937500)
	bar.moon:SetAlpha(0)
	lsCreateAlphaAnimation(bar.moon, 1)

	bar.dir = bar.cover:CreateTexture(nil, "ARTWORK", nil, 7)
	bar.dir:SetPoint("CENTER", -7, 0)
	bar.dir:SetSize(32, 256)
	bar.dir:SetTexture(nil)

	return bar
end

local function UpdateEclipseBarDirection(self, unit)
	if self.direction and self.direction ~= "none" then
		self.dir:SetTexture("Interface\\AddOns\\oUF_LS\\media\\eclipse_"..self.direction)
	else
		self.dir:SetTexture(nil)
	end
end

local function UpdateEclipseBarGlow(self, unit)
	if self.hasLunarEclipse == true or self.hasSolarEclipse == true then
		local r, g, b
		if self.hasSolarEclipse == true then
			r, g, b = unpack(M.colors.eclipse["sun"])
			self.sun.animation:Play()
		else
			r, g, b = unpack(M.colors.eclipse["moon"])
			self.moon.animation:Play()
		end
		self.glow:SetVertexColor(r * 1.25, g * 1.25, b * 1.25)
		self.glow.animation:Play()
	else
		self.glow.animation:Finish()
		self.sun.animation:Finish()
		self.moon.animation:Finish()
	end
end

local function UpdateEclipseBarVisibility(self, unit)
	if self:IsShown() then
		if UnitHasVehicleUI(unit) == true then
			self:Hide()
			FrameReskin(self:GetParent(), "NONE", true, 0, self.__cpower)
		elseif UnitHasVehicleUI(unit) == false then
			self:Show()
			FrameReskin(self:GetParent(), "ECLIPSE", true, 1)
		end
	else
		FrameReskin(self:GetParent(), "NONE", true, 0, self.__cpower)
	end
end

local function CreateUnitFrameStyle(self, unit)
	local width, height, sbOrientation, hpTexture, ppTexture, hpTextTemplate, ppTextTemplate
	unit = gsub(unit, "%d", "")

	if unit == "pet" then
		self.frameType = "pet"
		width, height = 44, 140
		sbOrientation = "VERTICAL"
		hpTexture = "Interface\\AddOns\\oUF_LS\\media\\frame_pet_filling"
		ppTexture = "Interface\\AddOns\\oUF_LS\\media\\frame_pet_filling"
		hpTextTemplate = "lsUnitFrame14Text"
		ppTextTemplate = "lsUnitFrame14Text"
	else
		self.frameType = ns.C.units[unit].long and "long" or "short"
		width, height = ns.C.units[unit].long and 218 or 124, 42
		sbOrientation = "HORIZONTAL"
		hpTexture = M.textures.statusbar
		ppTexture = M.textures.statusbar
		hpTextTemplate = "lsUnitFrame14Text"
		ppTextTemplate = "lsUnitFrame12Text"
	end

	if unit ~= "party" then
		self:SetWidth(width)
		self:SetHeight(height)
	end

	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", ns.UnitFrame_OnEnter)
	self:HookScript("OnLeave", ns.UnitFrame_OnLeave)

	self.mouseovers = {}


	self.cover = CreateFrame("Frame", "$parentCover", self)
	self.cover:SetFrameStrata(self:GetFrameStrata())
	self.cover:SetFrameLevel(self:GetFrameLevel() + 3) -- +3
	if unit == "pet" then
		self.cover:SetSize(44, 140)
		self.cover:SetPoint("CENTER")
	else
		self.cover:SetPoint("TOP", 0, -8)
		self.cover:SetPoint("LEFT", 15, 0)
		self.cover:SetPoint("RIGHT", -15, 0)
		self.cover:SetPoint("BOTTOM", 0, 8)
	end

	self.fg = self.cover:CreateTexture("$parentForeground", "ARTWORK", nil, 1)
	self.fg:SetPoint("CENTER")
	if unit == "pet" then
		self.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	end

	self.bg = self:CreateTexture("$parentBackground", "BACKGROUND", nil, 0)
	self.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_"..self.frameType.."_bg")
	self.bg:SetPoint("CENTER")

	if unit ~= "focustarget" and unit ~= "targettarget" then
		self.Threat = self:CreateTexture("$parentThreatGlow", "BACKGROUND", nil, 1)
		self.Threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_"..self.frameType.."_threat")
		self.Threat.Override = ns.ThreatUpdateOverride

		self.DebuffHighlight = self:CreateTexture("$parentDebuffGlow", "BACKGROUND", nil, 1)
		self.DebuffHighlight:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_"..self.frameType.."_debuff")
		self.DebuffHighlight:SetAlpha(0)
		self.DebuffHighlightAlpha = 1
		self.DebuffHighlightFilter = false --MOVE TO CONFIG

		if unit == "pet" then
			self.Threat:SetSize(64, 256)
			self.Threat:SetPoint("CENTER")
			self.DebuffHighlight:SetSize(64, 256)
			self.DebuffHighlight:SetPoint("CENTER")
		else
			self.Threat:SetSize(128, 64)
			self.Threat:SetPoint("BOTTOMRIGHT", self, "CENTER", 0, -32.5)
			self.DebuffHighlight:SetSize(128, 64)
			self.DebuffHighlight:SetPoint("BOTTOMLEFT", self, "CENTER", 0, -32.5)
		end
	end

	self.Health = CreateFrame("StatusBar", "$parentHealth", self)
	self.Health:SetFrameStrata(self:GetFrameStrata())
	self.Health:SetFrameLevel(self:GetFrameLevel() + 1) -- +1
	self.Health:SetOrientation(sbOrientation)
	self.Health:SetStatusBarTexture(hpTexture)
	self.Health:SetStatusBarColor(1.0, 1.0, 1.0)
	if unit == "pet" then
		self.Health:SetSize(57, 114)
		self.Health:SetPoint("CENTER", -5, 0)
	else
		self.Health:SetPoint("TOP", 0, -8)
		self.Health:SetPoint("LEFT", 15, 0)
		self.Health:SetPoint("RIGHT", -15, 0)
		self.Health:SetPoint("BOTTOM", 0, 14)
	end
	self.Health.frequentUpdates = unit == "boss"
	self.Health.PostUpdate = ns.UpdateHealth
	self.Health.Smooth = true
	self.Health.colorHealth = true --MOVE TO CONFIG
	self.Health.colorDisconnected = true

	if unit ~= "party" then
		self.Health.colorReaction = true
	end

	self.Health.value = self.cover:CreateFontString("$parentHealthText", "ARTWORK", hpTextTemplate)
	if unit == "pet" then
		self.Health.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 2, 20)
	else
		self.Health.value:SetJustifyH("RIGHT")
		self.Health.value:SetPoint("TOP", self.Health, "TOP", 0, -1)
		self.Health.value:SetPoint("LEFT", self.Health, "LEFT", 1, 0)
		self.Health.value:SetPoint("RIGHT", self.Health, "RIGHT", -1, 0)
		self.Health.value:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, 0)
	end
	tinsert(self.mouseovers, self.Health)

	if unit ~= "focustarget" and unit ~= "targettarget" then
		self.Power = CreateFrame("StatusBar", "$parentPower", self)
		self.Power:SetFrameStrata(self:GetFrameStrata())
		self.Power:SetFrameLevel(self:GetFrameLevel() + 2) -- +2
		self.Power:SetOrientation(sbOrientation)
		self.Power:SetStatusBarTexture(ppTexture)
		if unit == "pet" then
			self.Power:SetSize(51, 102)
			self.Power:SetPoint("CENTER", 5, 0)
		else
			self.Power:SetPoint("TOP", 0, -30)
			self.Power:SetPoint("LEFT", 15, 0)
			self.Power:SetPoint("RIGHT", -15, 0)
			self.Power:SetPoint("BOTTOM", 0, 8)
		end

		self.Power.PostUpdate = ns.UpdatePower
		self.Power.Smooth = true
		self.Power.colorPower = true --MOVE TO CONFIG
		self.Power.colorDisconnected = true
		self.Power.frequentUpdates = true

		self.Power.value = self.cover:CreateFontString("$parentPowerText", "ARTWORK", ppTextTemplate)
		if unit == "pet" then
			self.Power.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", 8, 6)
		else
			self.Power.value:SetJustifyH("LEFT")
			self.Power.value:SetPoint("LEFT", self.Power, "LEFT", 1, 0)
			self.Power.value:SetPoint("RIGHT", self.Power, "RIGHT", -1, 0)
		end
		tinsert(self.mouseovers, self.Power)
	else
		ns.UnitFrameReskin(self, "sol")
	end

	self.HealPrediction = {}
	self.HealPrediction.myBar = CreateFrame("StatusBar", "$parentMyIncomingHeal", self.Health)
	self.HealPrediction.myBar:SetOrientation(sbOrientation)
	self.HealPrediction.myBar:SetStatusBarTexture(M.textures.statusbar)
	self.HealPrediction.myBar:SetStatusBarColor(0.0, 0.827, 0.765)
	self.HealPrediction.myBar:SetFrameStrata(self:GetFrameStrata())
	self.HealPrediction.myBar:SetFrameLevel(self:GetFrameLevel() + 1)
	self.HealPrediction.myBar:Hide()

	self.HealPrediction.otherBar = CreateFrame("StatusBar", "$parentOtherIncomingHeal", self.Health)
	self.HealPrediction.otherBar:SetOrientation(sbOrientation)
	self.HealPrediction.otherBar:SetStatusBarTexture(M.textures.statusbar)
	self.HealPrediction.otherBar:SetStatusBarColor(0.0, 0.631, 0.557)
	self.HealPrediction.otherBar:SetFrameStrata(self:GetFrameStrata())
	self.HealPrediction.otherBar:SetFrameLevel(self:GetFrameLevel() + 1)
	self.HealPrediction.otherBar:Hide()

	self.HealPrediction.healAbsorbBar = CreateFrame("StatusBar", "$parentHealAbsorb", self.Health)
	self.HealPrediction.healAbsorbBar:SetOrientation(sbOrientation)
	self.HealPrediction.healAbsorbBar:SetStatusBarTexture(M.textures.statusbar)
	self.HealPrediction.healAbsorbBar:SetStatusBarColor(0.9, 0.1, 0.3)
	self.HealPrediction.healAbsorbBar:SetFrameStrata(self:GetFrameStrata())
	self.HealPrediction.healAbsorbBar:SetFrameLevel(self:GetFrameLevel() + 1)
	self.HealPrediction.healAbsorbBar:Hide()

	self.HealPrediction.absorbBar = CreateFrame("StatusBar", "$parentTotalAbsorb", self.Health)
	self.HealPrediction.absorbBar:SetOrientation(sbOrientation)
	self.HealPrediction.absorbBar:SetStatusBarTexture(M.textures.statusbar)
	self.HealPrediction.absorbBar:SetStatusBarColor(0, 0.7, 0.95)
	self.HealPrediction.absorbBar:SetFrameStrata(self:GetFrameStrata())
	self.HealPrediction.absorbBar:SetFrameLevel(self:GetFrameLevel() + 1)
	self.HealPrediction.absorbBar:Hide()
	if sbOrientation == "VERTICAL" then
		self.HealPrediction.myBar:SetPoint("LEFT")
		self.HealPrediction.myBar:SetPoint("RIGHT")
		self.HealPrediction.myBar:SetHeight(self.Health:GetHeight())

		self.HealPrediction.otherBar:SetPoint("LEFT")
		self.HealPrediction.otherBar:SetPoint("RIGHT")
		self.HealPrediction.otherBar:SetHeight(self.Health:GetHeight())

		self.HealPrediction.healAbsorbBar:SetPoint("LEFT")
		self.HealPrediction.healAbsorbBar:SetPoint("RIGHT")
		self.HealPrediction.healAbsorbBar:SetHeight(self.Health:GetHeight())

		self.HealPrediction.absorbBar:SetPoint("LEFT")
		self.HealPrediction.absorbBar:SetPoint("RIGHT")
		self.HealPrediction.absorbBar:SetHeight(self.Health:GetHeight())
	else
		self.HealPrediction.myBar:SetPoint("TOP")
		self.HealPrediction.myBar:SetPoint("BOTTOM")
		self.HealPrediction.myBar:SetWidth(width - 30)

		self.HealPrediction.otherBar:SetPoint("TOP")
		self.HealPrediction.otherBar:SetPoint("BOTTOM")
		self.HealPrediction.otherBar:SetWidth(width - 30)

		self.HealPrediction.healAbsorbBar:SetPoint("TOP")
		self.HealPrediction.healAbsorbBar:SetPoint("BOTTOM")
		self.HealPrediction.healAbsorbBar:SetWidth(width - 30)

		self.HealPrediction.absorbBar:SetPoint("TOP")
		self.HealPrediction.absorbBar:SetPoint("BOTTOM")
		self.HealPrediction.absorbBar:SetWidth(width - 30)
	end
	self.HealPrediction.maxOverflow = 1.05
	self.HealPrediction.frequentUpdates = true
	self.HealPrediction.PostUpdate = ns.PostUpdateHealPrediction

	if unit ~= "pet" then
		self.NameText = E:CreateFontString(self.cover, 14, "$parentNameText", true)
		-- self.NameText = self.cover:CreateFontString("$parentNameText", "ARTWORK", "lsUnitFrame14Text")
		self.NameText:SetPoint("LEFT", self, "LEFT", 1, self.frameType == "long" and 18.5 or 2.5)
		self.NameText:SetPoint("RIGHT", self, "RIGHT", -1, self.frameType == "long" and 18.5 or 2.5)
		self.NameText:SetPoint("BOTTOM", self, "TOP", 0, self.frameType == "long" and 18.5 or 2.5)
		if self.frameType == "long" then
			self:Tag(self.NameText, "[custom:name]")
		else
			self:Tag(self.NameText, "[difficulty][level][shortclassification]|r [custom:name]")
		end

		if self.frameType == "long" then
			self.ClassText = self.cover:CreateFontString("$parentClassText", "ARTWORK", "lsUnitFrame14Text")
			self.ClassText:SetPoint("LEFT", self, "LEFT", 1, 2.5)
			self.ClassText:SetPoint("RIGHT", self, "RIGHT", -1, 2.5)
			self.ClassText:SetPoint("BOTTOM", self, "TOP", 0, 2.5)
			self:Tag(self.ClassText, "[difficulty][level][shortclassification]|r [custom:racetype]")
		end

		if unit ~= "party" then
			self.ThreatText = self.cover:CreateFontString("$parentThreatText", "ARTWORK", "lsUnitFrame14Text")
			self.ThreatText:SetJustifyH("LEFT")
			self.ThreatText:SetPoint("TOP", self.Health, "TOP", 0, -1)
			self.ThreatText:SetPoint("LEFT", self.Health, "LEFT", 1, 0)
			self.ThreatText:SetPoint("RIGHT", self.Health, "RIGHT", -1, 0)
			self.ThreatText:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, 0)
			self:Tag(self.ThreatText, "[custom:threat]")
		end
	end

	if unit == "focus" or unit == "target" or unit == "boss" then
		if self.frameType == "long" then
			self.Castbar = CreateFrame("StatusBar", "$parentCastingBar", self, "lsBigCastingBarTemplate")
		else
			self.Castbar = CreateFrame("StatusBar", "$parentCastingBar", self, "lsSmallCastingBarTemplate")
		end
		self.Castbar.CustomTimeText = ns.CustomTimeText
		self.Castbar.CustomDelayText = ns.CustomDelayText
		if unit == "boss" then
			self.Castbar:SetPoint("BOTTOM", 10, -26)
		else
			self.Castbar:SetPoint("BOTTOM", 10, -42)
		end
	end

	if self.frameType == "long" then
		self.banner = self.cover:CreateTexture(nil, "ARTWORK", nil, 2)
		self.banner:SetSize(120, 60)
		self.banner:SetPoint("TOP", self, "BOTTOM", 0, 26.5)
		hooksecurefunc(self, "Show", function(self)
			local class = UnitClassification(self.unit)
			if class ~= "normal" and class ~= "minus" and class ~= "trivial" then
				if class == "worldboss" or class == "elite" then
					self.banner:SetTexture("Interface\\AddOns\\oUF_LS\\media\\banner_elite")
				elseif class == "rareelite" then
					self.banner:SetTexture("Interface\\AddOns\\oUF_LS\\media\\banner_rareelite")
				elseif class == "rare" then
					self.banner:SetTexture("Interface\\AddOns\\oUF_LS\\media\\banner_rare")
				end
				self.banner:Show()
			else
				self.banner:Hide()
			end
		end)
	end

-- ICONS

	if unit == "target" or unit == "focus" or unit == "party" then
		self.Leader = self:CreateTexture("$parentLeaderIcon", "BACKGROUND")
		self.Leader:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icons")
		self.Leader:SetTexCoord(2 / 128, 20 / 128, 2 / 64, 20 / 64)
		self.Leader:SetSize(18, 18)

		self.LFDRole = self:CreateTexture("$parentLFDRoleIcon", "BACKGROUND")
		self.LFDRole:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icons")
		self.LFDRole:SetSize(18, 18)
		self.LFDRole.Override = ns.LFDOverride

		if unit ~= "party" then
			self.PvP = self:CreateTexture("$parentPvPIcon", "BACKGROUND")
			self.PvP:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icons")
			self.PvP:SetSize(18, 18)
			self.PvP.Override = ns.PvPOverride
		end

		self.ReadyCheck = self.cover:CreateTexture("$parentReadyCheckIcon", "ARTWORK", nil, 4)
		self.ReadyCheck:SetSize(32, 32)

		self.PhaseIcon = self:CreateTexture("$parentPhaseIcon", "BACKGROUND")
		self.PhaseIcon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icons")
		self.PhaseIcon:SetTexCoord(62 / 128, 80 / 128, 22 / 64, 40 / 64)
		self.PhaseIcon:SetSize(18, 18)

		if unit == "target" then
			self.QuestIcon = self:CreateTexture("$parentQuestIcon", "BACKGROUND")
			self.QuestIcon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\icons")
			self.QuestIcon:SetTexCoord(82 / 128, 100 / 128, 22 / 64, 40 / 64)
			self.QuestIcon:SetSize(18, 18)
			self.QuestIcon:SetPoint("TOPLEFT", 4, 20)
		end

		self.ReadyCheck:SetPoint("CENTER")

		if unit == "party" then
			self.Leader:SetPoint("TOPRIGHT", 18, 6)
			self.PhaseIcon:SetPoint("RIGHT", 24, 0)
			self.LFDRole:SetPoint("BOTTOMRIGHT", 18, -6)
		else
			self.PvP:SetPoint("BOTTOMLEFT", 16, -17.5)
			self.PhaseIcon:SetPoint("BOTTOMLEFT", 36, -17.5)
			self.Leader:SetPoint("BOTTOMRIGHT", -36, -17.5)
			self.LFDRole:SetPoint("BOTTOMRIGHT", -16, -17.5)
		end
	end

	if unit ~= "pet" then
		self.RaidIcon = self.cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 2)
		self.RaidIcon:SetSize(24, 24)
		if self.frameType == "long" then
			self.RaidIcon:SetPoint("TOPLEFT", 34, 18)
		else
			self.RaidIcon:SetPoint("TOP", 0, 18)
		end
	end

	if unit == "target" or unit == "focus" or unit == "party" then
		if unit ~= "party" then
			self.Buffs = ns.CreateBuff(self, unit)
		end
		self.Debuffs = ns.CreateDebuff(self, unit)
	end

	if unit == "target" then
		self.CPoints = CreateComboBar(self)
		self.CPoints.PostUpdate = PostUpdateComboBar
	end

	if unit == "player" then
		FrameReskin(self, "NONE", true, 0, "NONE")

		if ns.E.playerclass == "MONK" then
			self.ClassIcons = CreateClassPowerBar(self, 5, "CHI")
			self.ClassIcons.PostUpdate = UpdateClassPowerBar
		end

		if ns.E.playerclass == "DEATHKNIGHT" then
			self.Runes = CreateRuneBar(self)
			self.Runes.PostUpdateRune = PostUpdateRuneBar
		end

		if ns.E.playerclass == "SHAMAN" then
			self.Totems = CreateTotemBar(self)
			self.Totems.PostUpdate = UpdateTotemBar
		end

		if ns.E.playerclass == "PALADIN" then
			self.ClassIcons = CreateClassPowerBar(self, 5, "HOLYPOWER")
			self.ClassIcons.PostUpdate = UpdateClassPowerBar
		end

		if ns.E.playerclass == "WARLOCK" then
				self.ClassIcons = CreateClassPowerBar(self, 4, "SOULSHARD")
				self.ClassIcons.PostUpdate = UpdateClassPowerBar

				self.BurningEmbers = CreateBurningEmbers(self)
				self.BurningEmbers.PostUpdate = UpdateBurningEmbers
				self.BurningEmbers.Smooth = true

				self.DemonicFury = CreateDemonicFury(self)
				self.DemonicFury.PostUpdate = UpdateDemonicFury
				self.DemonicFury.Smooth = true
		end

		if ns.E.playerclass == "PRIEST" then
			self.ClassIcons = CreateClassPowerBar(self, 5, "SHADOWORB")
			self.ClassIcons.PostUpdate = UpdateClassPowerBar
		end

		if ns.E.playerclass == "DRUID" then
			self.EclipseBar = CreateEclipseBar(self)
			self.EclipseBar.PostDirectionChange = UpdateEclipseBarDirection
			self.EclipseBar.PostUnitAura = UpdateEclipseBarGlow
			self.EclipseBar.PostUpdateVisibility = UpdateEclipseBarVisibility
			self.EclipseBar.Smooth = true
		end
	end
end

function ns.lsFactory(oUF)
	oUF:RegisterStyle("LS", CreateUnitFrameStyle)
	oUF:SetActiveStyle("LS")

	for unit, udata in pairs(ns.C.units) do
		if unit ~= "player" and unit ~= "pet" and unit ~= "target" then
			if type(udata) == "table" and udata.enabled then
				if unit ~= "boss" then
					local name = "ls"..unit:gsub("%a", strupper, 1):gsub("target", "Target"):gsub("pet", "Pet").."Frame"
					if udata.attributes then
						ns.headers[unit] = oUF:SpawnHeader(name, nil, udata.visibility,
							"oUF-initialConfigFunction", [[self:SetWidth(124); self:SetHeight(42)]],
							unpack(udata.attributes))
					else
						ns.objects[unit] = oUF:Spawn(unit, name)
					end
				else
					for i = 1, 5 do
					-- "lsBoss"..i.."Frame"
					ns.objects["boss"..i] = oUF:Spawn("boss"..i, "lsBoss"..i.."Frame")
					end
				end
			end
		end
	end

	for unit, object in next, ns.objects do
		-- print(unit, object)
		if strmatch(unit, "^boss%d") then
			local id = tonumber(strmatch(unit, "boss(%d)"))
			if id == 1 then
				object:SetPoint(unpack(ns.C.units.boss.point))
			else
				object:SetPoint("TOP", "lsBoss"..(id - 1).."Frame", "BOTTOM", 0, -ns.C.units.boss.yOffset)
			end

			_G["Boss"..id.."TargetFramePowerBarAlt"]:ClearAllPoints()
			_G["Boss"..id.."TargetFramePowerBarAlt"]:SetParent(object)
			_G["Boss"..id.."TargetFramePowerBarAlt"]:SetPoint("RIGHT", object, "LEFT", -6, 0)
		else
			object:SetPoint(unpack(ns.C.units[unit].point))
		end
			E:CreateMover(object)
	end

	local header = ns.headers.party
	if header then
		header:SetPoint(unpack(ns.C.units["party"].point))

		if GetDisplayedAllyFrames() ~= "party" then
			RegisterAttributeDriver(header, "state-visibility", "hide")

			header.isVisible = false
		else
			header.isVisible = true
		end

		local _, condition = strsplit(" ", ns.C.units.party.visibility, 2)

		-- Compact Party Frames support
		hooksecurefunc("HidePartyFrame", function()
			if header.isVisible then
				if not InCombatLockdown() then
					RegisterAttributeDriver(header, "state-visibility", "hide")
				end
				header.isVisible = false
			end
		end)

		hooksecurefunc("ShowPartyFrame", function()
			if not header.isVisible then
				if not InCombatLockdown() then
					RegisterAttributeDriver(header, "state-visibility", condition)
				end
				header.isVisible = true
			end
		end)

		-- We can't show/hide frames, while in combat
		header:RegisterEvent("PLAYER_REGEN_ENABLED")
		header:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_ENABLED" then
				if self.isVisible and not self:IsShown() then
					RegisterAttributeDriver(self, "state-visibility", condition)
				elseif not self.isVisible and self:IsShown() then
					RegisterAttributeDriver(self, "state-visibility", "hide")
				end
			end
		 end)
	end
end
