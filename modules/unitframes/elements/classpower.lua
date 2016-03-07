local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")
local COLORS = M.colors
local POWERCOLORS = COLORS.power

local unpack, pairs, gsub = unpack, pairs, gsub

local UnitHealthMax, UnitStagger = UnitHealthMax, UnitStagger

local LAYOUT = {
	[0] = {
		sep = {0, 1 / 512, 0, 1 / 256},
	},
	[1] = {
		[1] = {
			size = 128,
			point = {"CENTER"},
			glow = {232 / 512, 248 / 512, 16 / 256, 144 / 256},
		},
		sep = {0, 1 / 512, 0, 1 / 256},
	},
	[2] = {
		[1] = {
			size = 64,
			point = {"CENTER", 0 , -112},
			glow = {264 / 512, 280 / 512, 80 / 256, 144 / 256},
		},
		[2] = {
			size = 64,
			point = {"CENTER", 0 , 112},
			glow = {264 / 512, 280 / 512, 16 / 256, 80 / 256},
		},
		sep = {38 / 512, 58 / 512, 16 / 256, 144 / 256},
	},
	[3] = {
		[1] = {
			size = 42,
			point = {"CENTER", 0 , -43},
			glow = {296 / 512, 312 / 512, 102 / 256, 144 / 256},
		},
		[2] = {
			size = 44,
			point = {"CENTER", 0, 0},
			glow = {296 / 512, 312 / 512, 58 / 256, 102 / 256},
		},
		[3] = {
			size = 42,
			point = {"CENTER", 0 , 43},
			glow = {296 / 512, 312 / 512, 16 / 256, 58 / 256},
		},
		sep = {70 / 512, 90 / 512, 16 / 256, 144 / 256},
	},
	[4] = {
		[1] = {
			size = 32,
			point = {"CENTER", 0 , -48},
			glow = {328 / 512, 344 / 512, 112 / 256, 144 / 256},
		},
		[2] = {
			size = 32,
			point = {"CENTER", 0 , -16},
			glow = {328 / 512, 344 / 512, 80 / 256, 112 / 256},
		},
		[3] = {
			size = 32,
			point = {"CENTER", 0 , 16},
			glow = {328 / 512, 344 / 512, 48 / 256, 80 / 256},
		},
		[4] = {
			size = 32,
			point = {"CENTER", 0 , 48},
			glow = {328 / 512, 344 / 512, 16 / 256, 48 / 256},
		},
		sep = {102 / 512, 122 / 512, 16 / 256, 144 / 256},
	},
	[5] = {
		[1] = {
			size = 25,
			point = {"CENTER", 0, -52},
			glow = {360 / 512, 376 / 512, 119 / 256, 144 / 256},
		},
		[2] = {
			size = 25,
			point = {"CENTER", 0, -27},
			glow = {360 / 512, 376 / 512, 94 / 256, 119 / 256},
		},
		[3] = {
			size = 28,
			point = {"CENTER", 0, 0},
			glow = {360 / 512, 376 / 512, 66 / 256, 94 / 256},
		},
		[4] = {
			size = 25,
			point = {"CENTER", 0, 27},
			glow = {360 / 512, 376 / 512, 41 / 256, 66 / 256},
		},
		[5] = {
			size = 25,
			point = {"CENTER", 0, 52},
			glow = {360 / 512, 376 / 512, 16 / 256, 41 / 256},
		},
		sep = {134 / 512, 154 / 512, 16 / 256, 144 / 256},
	},
	[6] = {
		[1] = {
			size = 21,
			point = {"CENTER", 0, -54},
			glow = {392 / 512, 408 / 512, 123 / 256, 144 / 256},
		},
		[2] = {
			size = 21,
			point = {"CENTER", 0, -33},
			glow = {392 / 512, 408 / 512, 102 / 256, 123 / 256},
		},
		[3] = {
			size = 22,
			point = {"CENTER", 0, -11},
			glow = {392 / 512, 408 / 512, 80 / 256, 102 / 256},
		},
		[4] = {
			size = 22,
			point = {"CENTER", 0, 11},
			glow = {392 / 512, 408 / 512, 58 / 256, 80 / 256},
		},
		[5] = {
			size = 21,
			point = {"CENTER", 0, 32},
			glow = {392 / 512, 408 / 512, 37 / 256, 58 / 256},
		},
		[6] = {
			size = 21,
			point = {"CENTER", 0, 53},
			glow = {392 / 512, 408 / 512, 16 / 256, 37 / 256},
		},
		sep = {166 / 512, 186 / 512, 16 / 256, 144 / 256},
	},
	["sun"] = {416 / 512, 428 / 512, 16 / 256, 144 / 256},
	["moon"] = {428 / 512, 440 / 512, 16 / 256, 144 / 256},
	["none"] = {0, 1 / 512, 0, 1 / 256},
}

local COMBO_BAR_PRESETS ={
	["VERTICAL"] = {
		bar_size = {26, 100},
		point = {"LEFT", "LSPlayerFrame" , "RIGHT", 2, 0},
		bg_size = {8, 100},
		fg_size = {26, 118},
		fg_coords = {0 / 256, 26 / 256, 0 / 128, 118 / 128},
		glow_size = {12, 102},
		glow_coords = {26 / 256, 38 / 256, 0 / 128, 102 / 128},
		cp_size = {8, 20},
		cp_point1 = "BOTTOM",
		cp_point2 = "TOP",
	},
	["HORIZONTAL"] = {
		bar_size = {100, 26},
		point = {"BOTTOM", "LSPlayerFrame" , "TOP", 0, 2},
		bg_size = {100, 8},
		fg_size = {118, 26},
		fg_coords = {38 / 256, 156 / 256, 0 / 128, 26 / 128},
		glow_size = {102, 12},
		glow_coords = {38 / 256, 140 / 256, 26 / 128, 38 / 128},
		cp_size = {20, 8},
		cp_point1 = "LEFT",
		cp_point2 = "RIGHT",
	},
}

local MAX_COMBO_POINTS = MAX_COMBO_POINTS
local MAX_TOTEMS = MAX_TOTEMS

local prevInUse = "NONE"
local curInUse = {
	["RUNE"] = {visible = false, slots = 0},
	["TOTEMS"] = {visible = false, slots = 0},
	["CHI"] = {visible = false, slots = 0},
	["HOLY_POWER"] = {visible = false, slots = 0},
	["SOUL_SHARDS"] = {visible = false, slots = 0},
	["SHADOW_ORBS"] = {visible = false, slots = 0},
	["BURNING_EMBERS"] = {visible = false, slots = 0},
	["DEMONIC_FURY"] = {visible = false, slots = 0},
	["ECLIPSE"] = {visible = false, slots = 0},
	["NONE"] = {visible = false, slots = 0},
}

function UF:Reskin(frame, powerType, visible, slots, sentBy)
	local cur, prev = curInUse[powerType], curInUse[prevInUse]

	if (cur.visible == visible and cur.slots == slots) or (powerType == "NONE" and prevInUse ~= "NONE" and prevInUse ~= sentBy) then return end
	prev.visible = false
	prev.slots = 0

	cur.visible = visible
	cur.slots = slots

	for ptype, pdata in pairs(curInUse) do
		if pdata.visible then
			frame.Cover.Sep:SetTexCoord(unpack(LAYOUT[slots].sep))
		end
	end

	if powerType == "NONE" then
		frame.Cover.Tube:SetTexCoord(198 / 512, 218 / 512, 8 / 256, 152 / 256)
	else
		frame.Cover.Tube:SetTexCoord(6 / 512, 26 / 512, 8 / 256, 152 / 256)
	end

	prevInUse = powerType
end

local function PostUpdateClassPower(bar, cur, max, changed, event)
	if event == "ClassPowerDisable" then
		bar:Hide()

		for i = 1, #bar do
			E:StopBlink(bar[i].Glow, true)
		end

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	else
		if event == "ClassPowerEnable" or changed then
			bar:Show()
			UF:Reskin(bar:GetParent(), bar.__type, true, max or 5)

			local r, g, b = unpack(POWERCOLORS[bar.__type])
			for i = 1, max do
				local element = bar[i]
				element:SetSize(12, LAYOUT[max][i].size)
				element:SetPoint(unpack(LAYOUT[max][i].point))
				element:SetVertexColor(r, g, b)

				local glow = element.Glow
				glow:SetSize(16, LAYOUT[max][i].size)
				glow:SetPoint("CENTER", element, "CENTER", 0, 0)
				glow:SetTexCoord(unpack(LAYOUT[max][i].glow))
				glow:SetVertexColor(E:ColorLighten(r, g, b, 0.35))
			end
		end

		if cur / max == 1 then
			for i = 1, max do
				E:Blink(bar[i].Glow, 0.5, 0, 1)
			end
		else
			for i = 1, max do
				E:StopBlink(bar[i].Glow)
			end
		end
	end
end

function UF:CreateClassPowerBar(parent, max, cpType, level)
	local bar = CreateFrame("Frame", "$parent"..gsub(cpType, "_", "").."Bar", parent)
	bar.__type = strupper(cpType)
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	for i = 1, max do
		element = bar:CreateTexture(nil, "BACKGROUND", nil, 3)
		element:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		bar[i] = element

		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
		glow:SetAlpha(0)
		element.Glow = glow
	end

	bar.PostUpdate = PostUpdateClassPower

	return bar
end

local function Rune_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		self.animState = self.Glow.Blink:GetLoopState()

		if self.animState == "REVERSE" then
			self.initStop = true
		end

		if self.initStop then
			self.initStop = false

			E:StopBlink(self.Glow)

			return self:SetScript("OnUpdate", nil)
		end

		self.elapsed = 0
	end
end

local function PostUpdateRuneBar(bar, rune, rid, start, duration, runeReady)
	if rune.Glow.Blink and rune.Glow.Blink:IsPlaying() and rune:GetScript("OnUpdate") then
		E:StopBlink(rune.Glow, true)
	end

	if runeReady and start == 0 then
		local r, g, b = rune:GetStatusBarColor()

		rune.Glow:SetVertexColor(E:ColorLighten(r, g, b, 0.35))

		E:Blink(rune.Glow, 0.5, 0, 1)

		rune:SetScript("OnUpdate", Rune_OnUpdate)
	end

	if UnitHasVehicleUI("player") then
		bar:Hide()

		for i = 1, 6 do
			E:StopBlink(bar[i].Glow, true)
		end

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	else
		bar:Show()
		UF:Reskin(bar:GetParent(), "RUNE", true, 6)
	end
end

function UF:CreateRuneBar(parent, level)
	local bar = CreateFrame("Frame", "$parentRuneBar", parent)
	bar.__type = "RUNE"
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	for i = 1, 6 do
		local element = CreateFrame('StatusBar', "$parentRune"..i, bar)
		element:SetFrameLevel(bar:GetFrameLevel())
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetOrientation("VERTICAL")
		element:SetSize(12, LAYOUT[6][i].size)
		element:SetPoint(unpack(LAYOUT[6][i].point))
		bar[i] = element

		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetSize(16, LAYOUT[6][i].size)
		glow:SetPoint("CENTER", element, "CENTER", 0, 0)
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
		glow:SetTexCoord(unpack(LAYOUT[6][i].glow))
		glow:SetAlpha(0)
		element.Glow = glow
	end

	bar.PostUpdateRune = PostUpdateRuneBar

	return bar
end

local function UpdateEclipseBarVisibility(bar, unit)
	if bar:IsShown() then
		bar.Dir:SetAlpha(1)

		UF:Reskin(bar:GetParent(), "ECLIPSE", true, 1)
	else
		E:StopBlink(bar.Glow, true)
		E:StopBlink(bar.Sun, true)
		E:StopBlink(bar.Moon, true)

		bar.Dir:SetAlpha(0)

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	end
end

local function UpdateEclipseBarGlow(bar, unit)
	if bar.hasLunarEclipse == true or bar.hasSolarEclipse == true then
		local r, g, b

		if bar.hasSolarEclipse == true then
			r, g, b = unpack(POWERCOLORS["ECLIPSE"].positive)
			E:Blink(bar.Sun, 0.5, 0, 1)
		else
			r, g, b = unpack(POWERCOLORS["ECLIPSE"].negative)
			E:Blink(bar.Moon, 0.5, 0, 1)
		end

		bar.Glow:SetVertexColor(E:ColorLighten(r, g, b, 0.35))
		E:Blink(bar.Glow, 0.5, 0, 1)
	else
		E:StopBlink(bar.Glow)
		E:StopBlink(bar.Sun)
		E:StopBlink(bar.Moon)
	end
end

local function UpdateEclipseBarDirection(bar, unit)
	if bar.direction then
		bar.Dir:SetTexCoord(unpack(LAYOUT[bar.direction]))
	else
		bar.Dir:SetTexCoord(unpack(LAYOUT["none"]))
	end
end

function UF:CreateEclipseBar(parent, level)
	local bar = CreateFrame("Frame", "$parentEclipseBar", parent)
	bar.__type = "ECLIPSE"
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	local lunar = CreateFrame("StatusBar", "$parentLunarBar", bar)
	lunar:SetFrameLevel(bar:GetFrameLevel())
	lunar:SetOrientation("VERTICAL")
	lunar:SetSize(12, 128)
	lunar:SetPoint("BOTTOM", bar, "BOTTOM")
	lunar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	lunar:SetStatusBarColor(unpack(POWERCOLORS["ECLIPSE"].negative))
	bar.LunarBar = lunar

	local solar = CreateFrame("StatusBar", "$parentSolarBar", bar)
	solar:SetFrameLevel(bar:GetFrameLevel())
	solar:SetOrientation("VERTICAL")
	solar:SetSize(12, 128)
	solar:SetPoint("BOTTOM", lunar:GetStatusBarTexture(), "TOP")
	solar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	solar:SetStatusBarColor(unpack(POWERCOLORS["ECLIPSE"].positive))
	bar.SolarBar = solar

	local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
	glow:SetSize(16, LAYOUT[1][1].size)
	glow:SetPoint("CENTER", bar, "CENTER", 0, 0)
	glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
	glow:SetTexCoord(unpack(LAYOUT[1][1].glow))
	glow:SetAlpha(0)
	bar.Glow = glow

	local moon = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
	moon:SetPoint("BOTTOMLEFT", -12, -8)
	moon:SetSize(36, 36)
	moon:SetTexture("Interface\\PlayerFrame\\UI-DruidEclipse")
	moon:SetTexCoord(0.73437500, 0.90234375, 0.00781250, 0.35937500)
	moon:SetAlpha(0)
	bar.Moon = moon

	local sun = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
	sun:SetPoint("TOPLEFT", -12, 8)
	sun:SetSize(36, 36)
	sun:SetTexture("Interface\\PlayerFrame\\UI-DruidEclipse")
	sun:SetTexCoord(0.55859375, 0.72656250, 0.00781250, 0.35937500)
	sun:SetAlpha(0)
	bar.Sun = sun

	local dir = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 2)
	dir:SetAllPoints(bar)
	dir:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
	bar.Dir = dir

	bar.PostUpdateVisibility = UpdateEclipseBarVisibility
	bar.PostUnitAura = UpdateEclipseBarGlow
	bar.PostDirectionChange = UpdateEclipseBarDirection

	return bar
end

local function Totem_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		local duration = self.start + self.duration - GetTime()
		local time, color, abbr = E:TimeFormat(duration, true)

		self:SetValue(duration)

		if duration >= 0.1 then
			if duration <= 10 then
				E:Blink(self.Glow, 0.5, 0, 1)
				E:Blink(self.Timer, 0.5, 0, 1)
				self.Timer:SetFormattedText("%s"..abbr.."|r", color, time)
			else
				E:StopBlink(self.Glow)
				E:StopBlink(self.Timer)
			end
		else
			E:StopBlink(self.Glow)
			E:StopBlink(self.Timer)

			return self:SetScript("OnUpdate", nil)
		end

		self.elapsed = 0
	end
end

local function UpdateTotemBar(bar, priorities, haveTotem, name, start, duration)
	local totem = bar[priorities]

	totem.start, totem.duration = start, duration

	totem:SetMinMaxValues(0, duration)

	if duration > 0.1 then
		totem:SetScript("OnUpdate", Totem_OnUpdate)
	else
		E:StopBlink(totem.Glow)
		E:StopBlink(totem.Timer)

		totem:SetScript("OnUpdate", nil)
	end

	if UnitHasVehicleUI("player") then
		bar:Hide()

		for i = 1, MAX_TOTEMS do
			E:StopBlink(bar[i].Glow, true)
		end

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	else
		bar:Show()
		UF:Reskin(bar:GetParent(), bar.__type, true, 4)
	end
end

function UF:CreateTotemBar(parent, level)
	local bar = CreateFrame("Frame", "$parentTotemBar", parent)
	bar.__type = "TOTEMS"
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	for i = 1, MAX_TOTEMS do
		local r, g, b = unpack(POWERCOLORS["TOTEMS"][i])

		local element = CreateFrame("StatusBar", "$parentTotem"..i, bar)
		element:SetFrameLevel(bar:GetFrameLevel())
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetOrientation("VERTICAL")
		element:SetSize(12, LAYOUT[MAX_TOTEMS][i].size)
		element:SetPoint(unpack(LAYOUT[MAX_TOTEMS][i].point))
		element:SetStatusBarColor(r, g, b)
		bar[i] = element

		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetSize(16, LAYOUT[MAX_TOTEMS][i].size)
		glow:SetPoint("CENTER", element, "CENTER", 0, 0)
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
		glow:SetTexCoord(unpack(LAYOUT[MAX_TOTEMS][i].glow))
		glow:SetVertexColor(E:ColorLighten(r, g, b, 0.35))
		glow:SetAlpha(0)
		element.Glow = glow

		local timer = E:CreateFontString(parent.Cover, 14, nil, nil, true)
		timer:SetDrawLayer("ARTWORK", 4)
		timer:SetPoint("CENTER", element, "CENTER", 0, 0)
		timer:SetAlpha(0)
		element.Timer = timer
	end

	bar.PostUpdate = UpdateTotemBar

	return bar
end

local function UpdateDemonicFury(bar, cur, max, isActivated, event)
	if event ~= "DemonicFuryDisable" then
		if cur == max then
			E:Blink(bar.Glow, 0.5)
		else
			E:StopBlink(bar.Glow)
		end

		if event == "DemonicFuryEnable" then
			UF:Reskin(bar:GetParent(), bar.__type, true, 1)
		end
	else
		E:StopBlink(bar.Glow, true)

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	end
end

function UF:CreateDemonicFury(parent, level)
	local bar = CreateFrame("StatusBar", "$parentFuryBar", parent)
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	bar:SetOrientation("VERTICAL")
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)
	bar.__type = "DEMONIC_FURY"
	E:SmoothBar(bar)

	local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
	glow:SetSize(16, LAYOUT[1][1].size)
	glow:SetPoint("CENTER", bar, "CENTER", 0, 0)
	glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
	glow:SetTexCoord(unpack(LAYOUT[1][1].glow))
	glow:SetVertexColor(E:ColorLighten(0, 1, 0.1, 0.45))
	glow:SetAlpha(0)
	bar.Glow = glow

	bar.PostUpdate = UpdateDemonicFury

	return bar
end

local function UpdateBurningEmbers(bar, cur, max, num, full, changed, event)
	if event == "BurningEmbersDisable" then
		bar:Hide()

		for i = 1, 4 do
			E:StopBlink(bar[i].Glow, true)
		end

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	else
		if changed then
			for i = 1, num do
				E:StopBlink(bar[i].Glow, true)
			end
		end

		if full > 0 then
			for i = 1, full do
				E:Blink(bar[i].Glow, 0.5)
			end
		end

		if event == "BurningEmbersEnable" then
			bar:Show()
			UF:Reskin(bar:GetParent(), bar.__type, true, 4)
		end
	end
end

function UF:CreateBurningEmbers(parent, level)
	local bar = CreateFrame("Frame", "$parentEmberBar", parent)
	bar.__type = "BURNING_EMBERS"
	bar:SetFrameLevel(level)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	for i = 1, 4 do
		local element = CreateFrame("StatusBar", "$parentEmber"..i, bar)
		element:SetFrameLevel(bar:GetFrameLevel())
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetOrientation("VERTICAL")
		element:SetSize(12, LAYOUT[4][i].size)
		element:SetPoint(unpack(LAYOUT[4][i].point))
		E:SmoothBar(element)
		bar[i] = element

		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetSize(16, LAYOUT[4][i].size)
		glow:SetPoint("CENTER", element, "CENTER", 0, 0)
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
		glow:SetTexCoord(unpack(LAYOUT[4][i].glow))
		glow:SetVertexColor(E:ColorLighten(0.9, 0.4, 0.1, 0.35))
		glow:SetAlpha(0)
		element.Glow = glow
	end

	bar.PostUpdate = UpdateBurningEmbers

	return bar
end

local function OverrideComboBar(self, event, unit)
	if unit == "pet" then return end
	local bar = self.CPoints

	local cp
	if UnitHasVehicleUI("player") then
		cp = UnitPower("vehicle", 4)
	else
		cp = UnitPower("player", 4)
	end

	for i = 1, MAX_COMBO_POINTS do
		if i <= cp then
			bar[i]:Show()
		else
			bar[i]:Hide()
		end
	end

	if cp > 0 then
		bar:Show()

		if cp == 5 then
			E:Blink(bar.Glow, 0.5)
		else
			E:StopBlink(bar.Glow)
		end
	else
		E:StopBlink(bar.Glow, true)

		bar:Hide()
	end
end

function UF:CreateComboBar(parent, level)
	local PRESET = COMBO_BAR_PRESETS[C.units.player.combo_bar_type]

	local bar = CreateFrame("Frame", "$parentComboPointsBar", parent)
	bar:SetFrameLevel(level)
	bar:SetSize(unpack(PRESET.bar_size))
	bar:SetPoint(unpack(PRESET.point))
	E:CreateMover(bar)

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetTexture(unpack(COLORS.darkgray))
	bg:SetSize(unpack(PRESET.bg_size))
	bg:SetPoint("CENTER")

	local fg = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\combo_bar")
	fg:SetTexCoord(unpack(PRESET.fg_coords))
	fg:SetSize(unpack(PRESET.fg_size))
	fg:SetPoint("CENTER")

	local r, g, b = unpack(POWERCOLORS["COMBO_POINTS"])

	local glow  = bar:CreateTexture(nil, "ARTWORK", nil, 4)
	glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\combo_bar")
	glow:SetTexCoord(unpack(PRESET.glow_coords))
	glow:SetSize(unpack(PRESET.glow_size))
	glow:SetPoint("CENTER")
	glow:SetVertexColor(E:ColorLighten(r, g, b, 0.35))
	glow:SetAlpha(0)
	bar.Glow = glow

	for i = 1, MAX_COMBO_POINTS do
		local element = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
		element:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetVertexColor(r, g, b)
		element:SetSize(unpack(PRESET.cp_size))
		bar[i] = element

		if i == 1 then
			element:SetPoint(PRESET.cp_point1, 0, 0)
		else
			element:SetPoint(PRESET.cp_point1, bar[i - 1], PRESET.cp_point2, 0, 0)
		end
	end

	bar.Override = OverrideComboBar

	return bar
end

local function OverrideStaggerBar(self, event, unit)
	if unit and unit ~= self.unit then return end
	local bar = self.Stagger

	local maxHealth = UnitHealthMax("player")
	local stagger = UnitStagger("player")

	bar:SetMinMaxValues(0, maxHealth)
	bar:SetValue(stagger)

	local r, g, b = E:ColorGradient(stagger / maxHealth, unpack(POWERCOLORS["STAGGER"]))
	local hex = E:RGBToHEX(r, g, b)

	bar:SetStatusBarColor(r, g, b)

	if bar.__owner.isMouseOver then
		bar.Value:SetFormattedText("%s / |cff"..hex.."%s|r", E:NumberFormat(stagger), E:NumberFormat(maxHealth))
	else
		if stagger > 0 then
			bar.Value:SetFormattedText("|cff"..hex.."%s|r", E:NumberFormat(stagger))
		else
			bar.Value:SetText(nil)
		end
	end
end

function UF:CreateStaggerBar(parent, level)
	local bar = CreateFrame("StatusBar", "$parentStaggerBar", parent)
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	bar:SetOrientation("VERTICAL")
	bar:SetFrameLevel(level)
	bar:SetSize(8, 100)
	bar:SetPoint("LEFT", 7, 0)
	E:SmoothBar(bar)

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
	bg:SetTexCoord(128 / 512, 160 / 512, 149 / 256, 251 / 256)
	bg:SetSize(32, 102)
	bg:SetPoint("CENTER")

	local fg1 = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	fg1:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
	fg1:SetTexCoord(440 / 512, 472 / 512, 16 / 256, 144 / 256)
	fg1:SetSize(32, 128)
	fg1:SetPoint("CENTER")

	local fg1 = bar:CreateTexture(nil, "ARTWORK", nil, 2)
	fg1:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
	fg1:SetTexCoord(96 / 512, 128 / 512, 149 / 256, 251 / 256)
	fg1:SetSize(32, 102)
	fg1:SetPoint("CENTER")

	local value = E:CreateFontString(bar, 12, "$parentStaggerValue", true)
	bar.Value = value

	bar.Override = OverrideStaggerBar

	return bar
end
