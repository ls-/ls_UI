local _, ns = ...
local oUF = ns.oUF or oUF
local cfg = ns.cfg
local glcolors = cfg.globals.colors
local L = ns.L
local prevInUse = "NONE"
local InUse = {
	["RUNE"]		= { vis = false, slots = 0, },
	["TOTEM"]		= { vis = false, slots = 0, },
	["COMBO"]		= { vis = false, slots = 0, },
	["CHI"]			= { vis = false, slots = 0, },
	["HOLYPOWER"]	= { vis = false, slots = 0, },
	["SOULSHARD"]	= { vis = false, slots = 0, },
	["SHADOWORB"]	= { vis = false, slots = 0, },
	["EMBER"]		= { vis = false, slots = 0, },
	["FURY"]		= { vis = false, slots = 0, },
	["ECLIPSE"]		= { vis = false, slots = 0, },
	["NONE"]		= { vis = false, slots = 0, },
}

local function InitPlayerParameters(self)
	self:SetFrameStrata("BACKGROUND")
	self:SetFrameLevel(1)
	self.menu = ns.menu
	self:SetAttribute("*type2", "menu")
	self:SetAttribute("initial-width", 140)
	self:SetWidth(140)
	self:SetAttribute("initial-height", 140)
	self:SetHeight(140)
	self:SetAttribute("initial-scale", cfg.globals.scale)
	self:SetScale(cfg.globals.scale)
	self:SetPoint(unpack(cfg.units.player.pos))
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", ns.UnitFrame_OnEnter)
	self:SetScript("OnLeave", ns.UnitFrame_OnLeave)
end

local function FrameReskin(frame, visibile, slots)
	if InUse[frame].vis == visibile and InUse[frame].slots == slots then return end
	PlayerFrameFGTexture.fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_sep_"..slots)
	InUse[prevInUse].vis = false
	InUse[prevInUse].slots = 0
	InUse[frame].vis = visibile
	InUse[frame].slots = slots
	prevInUse = frame
end

local function CreateBottomLine()
	if not cfg.bottomline then return end

	local f = CreateFrame("Frame", nil, UIParent)
	f:SetFrameStrata("LOW")
	f:SetFrameLevel(5)
	f:SetSize(512, 64)
	f:SetScale(cfg.globals.scale)
	f:SetPoint(unpack(cfg.bottomline.pos))

	f.left = f:CreateTexture(nil, "ARTWORK", nil, 5)
	f.left:SetPoint("CENTER", -256, 0)
	f.left:SetTexture("Interface\\AddOns\\oUF_LS\\media\\bottom_left")

	f.right = f:CreateTexture(nil, "ARTWORK", nil, 5)
	f.right:SetPoint("CENTER", 256, 0)
	f.right:SetTexture("Interface\\AddOns\\oUF_LS\\media\\bottom_right")

	f.center = f:CreateTexture(nil, "BACKGROUND", nil, 4)
	f.center:SetAllPoints(f)
	f.center:SetTexture("Interface\\AddOns\\oUF_LS\\media\\bottom_center")

	local f2 = CreateFrame("Frame", nil, UIParent)
	f2:SetFrameStrata("LOW")
	f2:SetFrameLevel(3)
	f2:SetScale(cfg.globals.scale)
	f2:SetAllPoints(f)

	f2.actbar = f2:CreateTexture(nil, "BACKGROUND", nil, -8)
	f2.actbar:SetPoint("CENTER", 0, 32)
	f2.actbar:SetTexture("Interface\\AddOns\\oUF_LS\\media\\bottom_actbar")
end

local function CreateExpBar(self)
	local bar = CreateFrame("StatusBar", nil, UIParent)
	bar:SetFrameStrata("LOW")
	bar:SetFrameLevel(4)
	bar:SetSize(316, 8)
	bar:SetScale(cfg.globals.scale)
	bar:SetPoint("BOTTOM", 0, 5)
	bar:SetStatusBarTexture(cfg.globals.textures.statusbar)
	bar:SetStatusBarColor(unpack(cfg.bottomline.expbar.colors.experience))

	bar.Rested = CreateFrame("StatusBar", nil, bar)
	bar.Rested:SetAllPoints(bar)
	bar.Rested:SetStatusBarTexture(cfg.globals.textures.statusbar)
	bar.Rested:SetStatusBarColor(unpack(cfg.bottomline.expbar.colors.rested))

	bar.BG = bar:CreateTexture(nil, 'BACKGROUND')
	bar.BG:SetAllPoints(bar)
	bar.BG:SetTexture(unpack(cfg.bottomline.expbar.colors.bg))

	bar.Text = ns.CreateFontString(bar, cfg.font, 11, "THINOUTLINE")
	bar.Text:SetAllPoints(bar)
	bar.Text:Hide()

	self:Tag(bar.Text, COMBAT_XP_GAIN.." [curxp] / [maxxp]")

	bar:SetScript("OnEnter", function (self) self.Text:Show() end)
	bar:SetScript("OnLeave", function (self) self.Text:Hide() end)
	return bar
end

local function UpdateExperience(bar, ...)
	bar.Text:UpdateTag()
end

local function CreateRepBar(self)
	local bar = CreateFrame("StatusBar", nil, UIParent)
	bar:SetFrameStrata("LOW")
	bar:SetFrameLevel(4)
	bar:SetSize(412, 8)
	bar:SetScale(cfg.globals.scale)
	bar:SetPoint("BOTTOM", 0, 16)
	bar:SetStatusBarTexture(cfg.globals.textures.statusbar)

	bar.BG = bar:CreateTexture(nil, 'BACKGROUND')
	bar.BG:SetAllPoints(bar)

	bar.Text = ns.CreateFontString(bar, cfg.font, 11, "THINOUTLINE")
	bar.Text:SetAllPoints(bar)
	bar.Text:Hide()

	self:Tag(bar.Text, "[reputation] [currep] / [maxrep]")

	bar:SetScript("OnEnter", function (self) self.Text:Show() end)
	bar:SetScript("OnLeave", function (self) self.Text:Hide() end)
	return bar
end

local function UpdateReputation(bar, unit, name, standing, min, max, value)
	local color = FACTION_BAR_COLORS[standing]
	bar.BG:SetTexture(color.r * 0.5, color.g * 0.5, color.b * 0.5, 0.3)
	bar.Text:UpdateTag()
end

local function CreatePlayerArtwork(self)
	--bg textures for playerframe
	self.back = CreateFrame("Frame", "PlayerFrameBGTexture", self)
	self.back:SetFrameLevel(self:GetFrameLevel()-1)
	self.back:SetSize(116, 116)
	self.back:SetPoint("CENTER", 0, 0)
	--bg
	self.back.bg = self.back:CreateTexture(nil, "BACKGROUND", nil, -8)
	self.back.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_bg")
	self.back.bg:SetSize(256, 256)
	self.back.bg:SetPoint("CENTER", 0, 0)
	--stone ring
	self.back.ring = self.back:CreateTexture(nil, "ARTWORK")
	self.back.ring:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_ring")
	self.back.ring:SetSize(256, 256)
	self.back.ring:SetPoint("CENTER", 0, 0)
	--chains
	self.back.chain = self.back:CreateTexture(nil, "ARTWORK", nil, -1)
	self.back.chain:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_chain_left")
	self.back.chain:SetSize(128, 64)
	self.back.chain:SetPoint("CENTER", 0, -96)
	--fg textures for playerframe
	self.cover = CreateFrame("Frame", "PlayerFrameFGTexture", self)
	self.cover:SetFrameLevel(self:GetFrameLevel()+1)
	self.cover:SetSize(116, 116)
	self.cover:SetPoint("CENTER", 0, 0)
	--hp gloss (center)
	self.cover.cgloss = self.cover:CreateTexture(nil, "ARTWORK", nil, -8)
	self.cover.cgloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_filling_gloss")
	self.cover.cgloss:SetSize(108, 108)
	self.cover.cgloss:SetPoint("CENTER", 0, 0)
	self.cover.cgloss:SetAlpha(.75)
	--fg texture
	self.cover.fg = self.cover:CreateTexture(nil, "ARTWORK", nil, 2)
	self.cover.fg:SetSize(256, 256)
	self.cover.fg:SetPoint("CENTER", 0, 0)
end

local function CreatePlayerHealth(self)
	local r, g, b = unpack(glcolors.health.alt)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetFrameLevel(self:GetFrameLevel())
	bar:SetOrientation("VERTICAL")
	bar:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_filling")
	bar:SetStatusBarColor(r, g, b)
	bar:SetSize(108, 108) 
	bar:SetPoint("CENTER", 0, 0)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_filling")
	bar.bg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)

	bar.lowHP = bar:CreateTexture(nil, "BACKGROUND")
	bar.lowHP:SetPoint("CENTER", 0, 0)
	bar.lowHP:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_lowhp")
	bar.lowHP:SetVertexColor(0.9, 0.1, 0.1, 0.85)
	bar.lowHP:Hide()
	return bar
end

local function CreatePlayerPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetFrameLevel(self:GetFrameLevel())
	bar:SetOrientation("VERTICAL")
	bar:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_power")
	bar:SetSize(66, 132)
	bar:SetPoint("CENTER", 36, 0)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_power")
	bar.bg.multiplier = 0.25
	return bar
end
-----------------
-- CLASS POWER --
-----------------
local function CreateClassPowerBar(self, max, type, recolor, maxatcreate)
	local bar = CreateFrame("Frame", "bar"..type, self)
	bar:SetPoint("CENTER", -36, 0)
	bar:SetSize(66, 132)
	bar:SetFrameLevel(1)
	bar.cpower = type
	bar.recolor = recolor
	for i = 1, 5 do
		bar[i] = bar:CreateTexture("icon"..i..type, "BACKGROUND", nil, -6)
		bar[i].bg = bar:CreateTexture("icon"..i..type, "BACKGROUND", nil, -7)
		if maxatcreate == true then -- that's for combo
			bar[i]:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
			bar[i]:SetSize(unpack(cfg.units.player.cpower["cpower"..i]["size"..max]))
			bar[i]:SetPoint(unpack(cfg.units.player.cpower["cpower"..i]["pos"..max]))
			bar[i].bg:SetAllPoints(bar[i])
			bar[i].bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
		end
	end
	return bar
end

local function UpdateClassPowerBar(self, cur, max, changed)
	if changed == true then
		for i = 1, max do 
			self[i]:SetTexCoord(0, 1, 0, 1)
			self[i]:SetSize(unpack(cfg.units.player.cpower["cpower"..i]["size"..max]))
			self[i]:SetPoint(unpack(cfg.units.player.cpower["cpower"..i]["pos"..max]))
			self[i]:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
			self[i].bg:SetAllPoints(self[i])
			self[i].bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
		end
	end
	if not self[1]:IsShown() then
		self:Hide()
		FrameReskin(self.cpower, false, 0)
	else
		self:Show()
		if self.recolor then
			if cur/(max or 5) == 1 then
				for i = 1, cur do 
					self[i]:SetVertexColor(unpack(glcolors.classpower["FULL"]))
				end
			else
				for i = 1, cur do
					self[i]:SetVertexColor(unpack(glcolors.classpower[self.cpower]))
				end
			end
			local r, g, b = self[1]:GetVertexColor()
			for i = 1, (max or 5) do
				self[i].bg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
			end
		end
		FrameReskin(self.cpower, true, max or 5)
	end
end

local function CreateDemonicFury(self)
	local bar = CreateFrame("StatusBar", "barFURY", self)
	bar:SetOrientation("VERTICAL")
	bar:SetPoint("CENTER", -36, 0)
	bar:SetSize(66, 132)
	bar:SetFrameLevel(1)
	bar:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1")
	bar.cpower = "FURY"

	bar.cover = CreateFrame("Frame", nil, self)
	bar.cover:SetPoint("CENTER", -36, 0)
	bar.cover:SetSize(66, 132)
	bar.cover:SetFrameLevel(self.cover:GetFrameLevel()+1)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1")

	bar.glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 6)
	bar.glow:SetPoint("CENTER", 0.5, 0)
	bar.glow:SetSize(128, 256)
	bar.glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1_glow")
	bar.glow:SetVertexColor(0, 1, 0.1)
	bar.glow:SetAlpha(0)
	return bar
end

local function UpdateDemonicFury(self, cur, max)
	if cur == max then
		if not self:GetScript("OnUpdate") then
			self.flashValue = 0
			self:SetScript("OnUpdate", function (self, elapsed)
				self.flashValue = self.flashValue + elapsed * 90
				if self.flashValue >= 180 or self.flashValue <= 0 then
					self.flashValue = 0
				end
				self.glow:SetAlpha(sin(self.flashValue))
			end)
		end
	else
		self.glow:SetAlpha(0)
		self:SetScript("OnUpdate", nil)
	end
	if not self:IsShown() then
		FrameReskin(self.cpower, false, 0)
	else
		FrameReskin(self.cpower, true, 1)
	end
end

local function CreateBurningEmbers(self)
	local bar = CreateFrame("Frame", "barEMBERS", self)
	bar:SetPoint("CENTER", -36, 0)
	bar:SetSize(66, 132)
	bar:SetFrameLevel(1)
	bar.cpower = "EMBER"
	for i = 1, 4 do
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i]:SetOrientation("VERTICAL")
		bar[i].bg = bar[i]:CreateTexture(nil, "BACKGROUND")
	end
	return bar
end

local function UpdateBurningEmbers(self, cur, max, changed)
	if changed == true then
		for i = 1, max do
			self[i]:SetSize(unpack(cfg.units.player.cpower["cpower"..i]["size"..max]))
			self[i]:SetPoint(unpack(cfg.units.player.cpower["cpower"..i]["pos"..max]))
			self[i]:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
			self[i].bg:SetAllPoints(self[i])
			self[i].bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
		end
	end
	if not self[1]:IsShown() then
		self:Hide()
		FrameReskin(self.cpower, false, 0)
	else
		self:Show()
		FrameReskin(self.cpower, true, max or 4)
	end
end

local function CreateTotemBar(self)
	local bar = CreateFrame("Frame", nil, self)
	bar:SetPoint("CENTER", -36, 0)
	bar:SetSize(66, 132)
	bar:SetFrameLevel(1)

	bar.cover = CreateFrame("Frame", nil, self)
	bar.cover:SetPoint("CENTER", -36, 0)
	bar.cover:SetSize(66, 132)
	bar.cover:SetFrameLevel(self.cover:GetFrameLevel()+1)
	bar.cpower = "TOTEM"

	local max = MAX_TOTEMS
	for i = 1, max do
		local r, g, b = unpack(glcolors.totem[i])
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetSize(unpack(cfg.units.player.cpower["cpower"..i]["size"..max]))
		bar[i]:SetPoint(unpack(cfg.units.player.cpower["cpower"..i]["pos"..max]))
		bar[i]:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
		bar[i]:SetStatusBarColor(r, g, b)
		bar[i].bg = bar:CreateTexture(nil, "BACKGROUND")
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i)
		bar[i].bg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
		bar[i].glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 2)
		bar[i].glow:SetSize(64, 64)
		bar[i].glow:SetPoint(unpack(cfg.units.player.cpower["cpower"..i]["pos"..max.."glow"]))
		bar[i].glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_"..max.."\\"..i.."_glow")
		bar[i].glow:SetVertexColor(r * 1.25, g * 1.25, b * 1.25)
		bar[i].glow:SetAlpha(0)
		bar[i].text = ns.CreateFontString(bar.cover, cfg.font, 14, "THINOUTLINE")
		bar[i].text:SetPoint(unpack(cfg.units.player.cpower["cpower"..i]["pos"..max]))
		bar[i].text:SetTextColor(r, g, b)
	end
	FrameReskin(bar.cpower, true, max or 4)
	return bar
end

local function UpdateTotemBar(self, priorities, haveTotem, name, start, duration, icon)
	local totem = self[priorities]
	totem:SetMinMaxValues(0, duration)
	if duration > 0 then
		totem.flashValue = 0
		totem:SetScript("OnUpdate", function (self, elapsed)
			local timeLeft = start + duration - GetTime()
			self:SetValue(timeLeft)
			if timeLeft <= 0 then
				self.glow:SetAlpha(0)
				self.text:SetAlpha(0)
				self:SetValue(0)
				return
			else
				if timeLeft <= 10 then
					self.flashValue = self.flashValue + elapsed * 90
					if self.flashValue <= 0 or self.flashValue >= 180 then
						self.flashValue = 0
					end
					self.glow:SetAlpha(sin(self.flashValue))
					self.text:SetText(ns.FormatTime(timeLeft))
					self.text:SetAlpha(sin(self.flashValue))
				end
			end
		end)
	else 
		totem.glow:SetAlpha(0)
		totem.text:SetAlpha(0)
		totem:SetScript("OnUpdate", nil)
		totem:SetValue(0)
	end
	if UnitHasVehicleUI("player") == true then
		self:Hide()
		FrameReskin("TOTEM", false, 0)
	elseif UnitHasVehicleUI("player") == false then
		self:Show()
		FrameReskin("TOTEM", true, 4)
	end
end

local function CreateRuneBar(self)
	local bar = CreateFrame("Frame", nil, self)
	bar:SetPoint("CENTER", -36, 0)
	bar:SetSize(66, 132)
	bar:SetFrameLevel(1)
	for i = 1, 6 do
		bar[i] = CreateFrame('StatusBar', "Rune"..i, bar)
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetSize(unpack(cfg.units.player.cpower["cpower"..i]["size6"]))
		bar[i]:SetPoint(unpack(cfg.units.player.cpower["cpower"..i]["pos6"]))
		bar[i]:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_6\\"..i)
		bar[i].bg = bar[i]:CreateTexture(nil, "BACKGROUND")
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_6\\"..i)
		bar[i].bg.multiplier = 0.25
	end
	FrameReskin("RUNE", true, 6)
	return bar
end

local function UpdateRuneType (self, rune, rid, alt)
	local r, g, b = unpack(self:GetParent().colors.runes[GetRuneType(rid)])

	local _, _, runeReady = GetRuneCooldown(rid)
	if runeReady == false then 
		rune:SetStatusBarColor(r * 0.5, g * 0.5, b * 0.5)
	end
end

local function UpdateRuneBar (self, rune, rid, start, duration, runeReady)
	local r, g, b = unpack(self:GetParent().colors.runes[GetRuneType(rid)])
	if runeReady == false then 
		rune:SetStatusBarColor(r * 0.5, g * 0.5, b * 0.5)
	else
		rune:SetStatusBarColor(r, g, b)
	end
	if UnitHasVehicleUI("player") == true then
		self:Hide()
		FrameReskin("RUNE", false, 0)
	elseif UnitHasVehicleUI("player") == false then
		self:Show()
		FrameReskin("RUNE", true, 6)
	end
end

local function CreateEclipseBar(self)
	local bar = CreateFrame("Frame", nil, self)
	bar:SetPoint("CENTER", -36, 0)
	bar:SetSize(66, 132)
	bar:SetFrameLevel(1)
	bar.cpower = "ECLIPSE"

	bar.cover = CreateFrame("Frame", nil, self)
	bar.cover:SetPoint("CENTER", -36, 0)
	bar.cover:SetSize(66, 132)
	bar.cover:SetFrameLevel(self.cover:GetFrameLevel()+1)

	bar.LunarBar = CreateFrame('StatusBar', nil, bar)
	bar.LunarBar:SetFrameLevel(1)
	bar.LunarBar:SetStatusBarTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1")
	bar.LunarBar:SetStatusBarColor(unpack(glcolors.eclipse["moon"]))
	bar.LunarBar:SetOrientation("VERTICAL")
	bar.LunarBar:SetPoint("CENTER", 0, 0)
	bar.LunarBar:SetSize(64, 132)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints(bar.LunarBar)
	bar.bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1")
	bar.bg:SetVertexColor(unpack(glcolors.eclipse["sun"]))

	bar.glow = bar.cover:CreateTexture(nil, "ARTWORK", nil, 6)
	bar.glow:SetPoint("CENTER", 1, 0)
	bar.glow:SetSize(128, 256)
	bar.glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_cpower_1\\1_glow")
	bar.glow:SetAlpha(0)

	bar.direction = bar.cover:CreateTexture(nil, "ARTWORK", nil, 7)
	bar.direction:SetPoint("CENTER", -7, 0)
	bar.direction:SetSize(32, 256)
	bar.direction:SetTexture(nil)
	return bar
end

local function UpdateExlipseBar(self, unit)
	local direction = GetEclipseDirection()
	if direction ~= "none" then
		self.direction:SetTexture("Interface\\AddOns\\oUF_LS\\media\\eclipse_"..direction)
	else
		self.direction:SetTexture(nil)
	end
end

local function UpdateExlipseBarGlow(self, unit)
	if self.hasLunarEclipse == true or self.hasSolarEclipse == true then
		local r, g, b
		if self.hasSolarEclipse == true then
			r, g, b = unpack(glcolors.eclipse["sun"])
		else
			r, g, b = unpack(glcolors.eclipse["moon"])
		end
		self.glow:SetVertexColor(r * 1.25, g * 1.25, b * 1.25)
		if not self:GetScript("OnUpdate") then
			self.flashValue = 0
			self:SetScript("OnUpdate", function (self, elapsed)
				self.flashValue = self.flashValue + elapsed * 90
				if self.flashValue >= 180 or self.flashValue <= 0 then
					self.flashValue = 0
				end
				self.glow:SetAlpha(sin(self.flashValue))
			end)
		end
	else
		self.glow:SetAlpha(0)
		self:SetScript("OnUpdate", nil)
	end
end

local function UpdateExlipseBarVisibility(self, unit)
	if self:IsShown() then
		if UnitHasVehicleUI(unit) == true then
			self:Hide()
			FrameReskin("ECLIPSE", false, 0)
		elseif UnitHasVehicleUI(unit) == false then
			self:Show()
			FrameReskin("ECLIPSE", true, 1)
		end
	else
		self:Hide()
		FrameReskin("ECLIPSE", false, 0)
	end
end

local function CreateCombatFeedback(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetFrameLevel(4)
	frame:SetPoint("CENTER", 0, 78)
	frame:SetSize(116, 116)
	for i = 1, 4 do
		frame[i] = ns.CreateFontString(frame, cfg.font, 18, "THINOUTLINE", "fback"..i)
		frame[i]:SetAlpha(0)
		frame[i]:Hide()
	end
	return frame
end
 
local function CreatePlayerStrings(self)
	self.Health.value = ns.CreateFontString(self.cover, cfg.font, 18, "THINOUTLINE")
	self.Health.value:SetPoint("CENTER", 1, 10)

	self.Power.value = ns.CreateFontString(self.cover, cfg.font, 14, "THINOUTLINE")
	self.Power.value:SetPoint("CENTER", 1, -10)
end

local function CreateStyle(self)
	self.cfg = cfg.units[self.unit]

	self.mouseovers = {}

	InitPlayerParameters(self)

	CreatePlayerArtwork(self)

	self.Health = CreatePlayerHealth(self)
	self.Health.PostUpdate = ns.UpdateHealth
	self.Health.Smooth = true
	tinsert(self.mouseovers, self.Health)

	self.Power = CreatePlayerPower(self)
	self.Power.PostUpdate = ns.UpdatePower
	self.Power.Smooth = true
	self.Power.colorPower = true
	self.Power.frequentUpdates = true
	tinsert(self.mouseovers, self.Power)

	CreatePlayerStrings(self)

	self.Threat = ns.CreateThreat(self, "orb")
	self.Threat.Override = ns.ThreatUpdateOverride

	self.Experience = CreateExpBar(self)
	self.Experience.PostUpdate = UpdateExperience

	self.Reputation = CreateRepBar(self)
	self.Reputation.PostUpdate = UpdateReputation
	self.Reputation.colorStanding = true

	self.DebuffHighlight = ns.CreateDebuffHighlight(self, "orb")
	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightFilter = false

	CreateBottomLine()

	self.FloatingCombatFeedback = CreateCombatFeedback(self)
	self.FloatingCombatFeedback.Mode = "Fountain"

	FrameReskin("NONE", true, 0)

	if cfg.units.player.cpower.combo == true then
		self.CPoints = CreateClassPowerBar(self, 5, "COMBO", true, true)
		self.CPoints.PostUpdate = UpdateClassPowerBar
	end
	if cfg.playerclass == "MONK" and cfg.units.player.cpower.chi == true then
		self.ClassIcons = CreateClassPowerBar(self, 5, "CHI", true)
		self.ClassIcons.PostUpdate = UpdateClassPowerBar
	end
	if cfg.playerclass == "DEATHKNIGHT" and cfg.units.player.cpower.runes == true then
		self.Runes = CreateRuneBar(self)
		self.Runes.PostUpdateType = UpdateRuneType
		self.Runes.PostUpdateRune = UpdateRuneBar
	end
	if cfg.playerclass == "SHAMAN" and cfg.units.player.cpower.totems == true then
		self.Totems = CreateTotemBar(self)
		self.Totems.PostUpdate = UpdateTotemBar
	end
	if cfg.playerclass == "PALADIN" and cfg.units.player.cpower.holy == true then
		self.ClassIcons = CreateClassPowerBar(self, 5, "HOLYPOWER", true)
		self.ClassIcons.PostUpdate = UpdateClassPowerBar
	end
	if cfg.playerclass == "WARLOCK" then
		if cfg.units.player.cpower.shards == true then
			self.SoulShards = CreateClassPowerBar(self, 4, "SOULSHARD")
			self.SoulShards.PostUpdate = UpdateClassPowerBar
		end
		if cfg.units.player.cpower.embers == true then
			self.BurningEmbers = CreateBurningEmbers(self)
			self.BurningEmbers.PostUpdate = UpdateBurningEmbers
		end
		if cfg.units.player.cpower.fury == true then
			self.DemonicFury = CreateDemonicFury(self)
			self.DemonicFury.PostUpdate = UpdateDemonicFury
			self.DemonicFury.Smooth = true
		end
	end
	if cfg.playerclass == "PRIEST" and cfg.units.player.cpower.orbs == true then
		self.ClassIcons = CreateClassPowerBar(self, 5, "SHADOWORB", true)
		self.ClassIcons.PostUpdate = UpdateClassPowerBar
	end
	if cfg.playerclass == "DRUID" and cfg.units.player.cpower.eclipse == true then
		self.EclipseBar = CreateEclipseBar(self)
		self.EclipseBar.PostUpdatePower = UpdateExlipseBar
		self.EclipseBar.PostUnitAura = UpdateExlipseBarGlow
		self.EclipseBar.PostUpdateVisibility = UpdateExlipseBarVisibility
		self.EclipseBar.Smooth = true
	end
	self.Resting = ns.CreateIcon(self, unpack(cfg.units.player.icons.resting))
	self.Leader = ns.CreateIcon(self, unpack(cfg.units.player.icons.leader))
	self.PvP = ns.CreateIcon(self, unpack(cfg.units.player.icons.pvp))
	self.PvP.Override = ns.PvPOverride
	if cfg.units.player.castbar then
		PetCastingBarFrame:UnregisterAllEvents()
		PetCastingBarFrame:HookScript("OnShow", function(self) self:Hide() end)
		PetCastingBarFrame:Hide()
		
		self.Castbar = ns.CreateCastbar(self, cfg.units.player)
		self.Castbar.CustomTimeText = ns.CustomTimeText
		self.Castbar.CustomDelayText = ns.CustomDelayText
	end
end
if cfg.units.player then
	oUF:Factory(function(self)
		self:RegisterStyle("my:player", CreateStyle)
		self:SetActiveStyle("my:player")
		self:Spawn("player", "oUF_LSPlayer")
	end)
end