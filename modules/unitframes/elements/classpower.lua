local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

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
		sep = {},
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
		sep = {70 / 512, 91 / 512, 16 / 256, 144 / 256},
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
		sep = {104 / 512, 120 / 512, 16 / 256, 144 / 256},
	},
	[5] = {
		[1] = {
			size = 25,
			point = {},
			glow = {360 / 512, 376 / 512, 119 / 256, 144 / 256},
		},
		[2] = {
			size = 25,
			point = {},
			glow = {360 / 512, 376 / 512, 94 / 256, 119 / 256},
		},
		[3] = {
			size = 28,
			point = {},
			glow = {360 / 512, 376 / 512, 66 / 256, 94 / 256},
		},
		[4] = {
			size = 25,
			point = {},
			glow = {360 / 512, 376 / 512, 41 / 256, 66 / 256},
		},
		[5] = {
			size = 25,
			point = {},
			glow = {360 / 512, 376 / 512, 16 / 256, 41 / 256},
		},
		sep = {},
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
	["sun"] = {426 / 512, 438 / 512, 16 / 256, 144 / 256},
	["moon"] = {458 / 512, 470 / 512, 16 / 256, 144 / 256},
	["none"] = {0, 1 / 512, 0, 1 / 256},
}

local MAX_TOTEMS = MAX_TOTEMS

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
	if event == "ClassPowerEnable" or changed and max ~= 0 then
		local r, g, b = unpack(M.colors.classpower[bar.__type])
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

	if event == "ClassPowerDisable" then
		bar:Hide()

		for i = 1, #bar do
			E:StopBlink(bar[i].Glow, true)
		end

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	else
		bar:Show()
		UF:Reskin(bar:GetParent(), bar.__type, true, max or 5)
		
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

function UF:CreateClassPowerBar(parent, max, cpType)
	local bar = CreateFrame("Frame", "$parent"..cpType.."Bar", parent)
	bar.__type = strupper(cpType)
	bar:SetFrameLevel(4)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	for i = 1, max do
		element = bar:CreateTexture(nil, "BACKGROUND", nil, 3)
		element:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		bar[i] = element

		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
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

function UF:CreateRuneBar(parent)
	local bar = CreateFrame("Frame", "$parentRuneBar", parent)
	bar.__type = "RUNE"
	bar:SetFrameLevel(4)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	for i = 1, 6 do
		local element = CreateFrame('StatusBar', nil, bar)
		element:SetFrameLevel(bar:GetFrameLevel())
		element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		element:SetOrientation("VERTICAL")
		element:SetSize(12, LAYOUT[6][i].size)
		element:SetPoint(unpack(LAYOUT[6][i].point))
		bar[i] = element

		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetSize(16, LAYOUT[6][i].size)
		glow:SetPoint("CENTER", element, "CENTER", 0, 0)
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
		glow:SetTexCoord(unpack(LAYOUT[6][i].glow))
		glow:SetAlpha(0)
		element.Glow = glow
	end

	bar.PostUpdateRune = PostUpdateRuneBar

	return bar
end

local function UpdateEclipseBarVisibility(bar, unit)
	if bar:IsShown() then
		UF:Reskin(bar:GetParent(), "ECLIPSE", true, 1)
	else
		E:StopBlink(bar.Glow, true)

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	end
end

local function UpdateEclipseBarGlow(bar, unit)
	if bar.hasLunarEclipse == true or bar.hasSolarEclipse == true then
		local r, g, b

		if bar.hasSolarEclipse == true then
			r, g, b = unpack(M.colors.eclipse["sun"])
			E:Blink(bar.Sun, 0.5, 0, 1)
		else
			r, g, b = unpack(M.colors.eclipse["moon"])
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

function UF:CreateEclipseBar(parent)
	local bar = CreateFrame("Frame", "$parentEclipseBar", parent)
	bar.__type = "ECLIPSE"
	bar:SetFrameLevel(4)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	local lunar = CreateFrame("StatusBar", "lsLunarBar", bar)
	lunar:SetOrientation("VERTICAL")
	lunar:SetSize(12, 128)
	lunar:SetPoint("BOTTOM", bar, "BOTTOM")
	lunar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	lunar:SetStatusBarColor(unpack(M.colors.eclipse["moon"]))
	bar.LunarBar = lunar

	local solar = CreateFrame("StatusBar", "lsSolarBar", bar)
	solar:SetOrientation("VERTICAL")
	solar:SetSize(12, 128)
	solar:SetPoint("BOTTOM", lunar:GetStatusBarTexture(), "TOP")
	solar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	solar:SetStatusBarColor(unpack(M.colors.eclipse["sun"]))
	bar.SolarBar = solar

	local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
	glow:SetSize(16, LAYOUT[1][1].size)
	glow:SetPoint("CENTER", bar, "CENTER", 0, 0)
	glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
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
	dir:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
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

function UF:CreateTotemBar(parent)
	local bar = CreateFrame("Frame", "$parentTotemBar", parent)
	bar.__type = "TOTEM"
	bar:SetFrameLevel(4)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	for i = 1, MAX_TOTEMS do
		local r, g, b = unpack(M.colors.totem[i])

		local element = CreateFrame("StatusBar", nil, bar)
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
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
		glow:SetTexCoord(unpack(LAYOUT[MAX_TOTEMS][i].glow))
		glow:SetVertexColor(E:ColorLighten(r, g, b, 0.35))
		glow:SetAlpha(0)
		element.Glow = glow

		local timer = E:CreateFontString(parent.Cover, 14, false, "THINOUTLINE")
		timer:SetDrawLayer("ARTWORK", 4)
		timer:SetPoint("CENTER", element, "CENTER", 0, 0)
		timer:SetAlpha(0)
		element.Timer = timer
	end

	bar.PostUpdate = UpdateTotemBar

	return bar
end

local function UpdateDemonicFury(bar, cur, max)
	if cur == max then
		E:Blink(bar.Glow, 0.5)
	else
		E:StopBlink(bar.Glow)
	end

	if not bar:IsShown() then
		E:StopBlink(bar.Glow, true)

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	else
		UF:Reskin(bar:GetParent(), bar.__type, true, 1)
	end
end

function UF:CreateDemonicFury(parent)
	local bar = CreateFrame("StatusBar", "$parentFuryBar", parent)
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	bar:SetOrientation("VERTICAL")
	bar:SetFrameLevel(4)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)
	bar.__type = "FURY"
	E:SmoothBar(bar)

	local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
	glow:SetSize(16, LAYOUT[1][1].size)
	glow:SetPoint("CENTER", bar, "CENTER", 0, 0)
	glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
	glow:SetTexCoord(unpack(LAYOUT[1][1].glow))
	glow:SetVertexColor(0, 1, 0.1)
	glow:SetAlpha(0)
	bar.Glow = glow

	bar.PostUpdate = UpdateDemonicFury

	return bar
end

local function UpdateBurningEmbers(bar, full, count)
	local resetAnimation
	if bar.oldFull ~= full then
		bar.oldFull = full

		resetAnimation = true
	end

	if full > 0 then
		for i = 1, full do
			if resetAnimation then
				E:StopBlink(bar[i].Glow, true)
			end

			E:Blink(bar[i].Glow, 0.5)
		end

		for i = 4, full + 1, -1 do
			E:StopBlink(bar[i].Glow)
		end
	else
		for i = 1, 4 do
			E:StopBlink(bar[i].Glow)
		end
	end

	resetAnimation = false

	if not bar[1]:IsShown() then
		bar:Hide()

		for i = 1, 4 do
			E:StopBlink(bar[i].Glow, true)
		end

		UF:Reskin(bar:GetParent(), "NONE", true, 0, bar.__type)
	else
		bar:Show()
		UF:Reskin(bar:GetParent(), bar.__type, true, 4)
	end
end

function UF:CreateBurningEmbers(parent)
	local bar = CreateFrame("Frame", "$parentEmberBar", parent)
	bar.__type = "EMBER"
	bar:SetFrameLevel(4)
	bar:SetSize(12, 128)
	bar:SetPoint("LEFT", 19, 0)

	for i = 1, 4 do
		local r, g, b = unpack(M.colors.classpower.EMBER)

		local element = CreateFrame("StatusBar", nil, bar)
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
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
		glow:SetTexCoord(unpack(LAYOUT[4][i].glow))
		glow:SetVertexColor(E:ColorLighten(r, g, b, 0.35))
		glow:SetAlpha(0)
		element.Glow = glow
	end

	bar.PostUpdate = UpdateBurningEmbers

	return bar
end
