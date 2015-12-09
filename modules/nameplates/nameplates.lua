local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS = M.colors
local NP = E:AddModule("NamePlates", true)
local NP_CFG

local tonumber, format, match, unpack, select, setmetatable, next	=
	tonumber, format, strmatch, unpack, select, setmetatable, next
local UnitGUID, UnitCanAttack, UnitHasVehicleUI, UnitPower, UnitExists, UnitIsUnit, UnitIsDead =
	UnitGUID, UnitCanAttack, UnitHasVehicleUI, UnitPower, UnitExists, UnitIsUnit, UnitIsDead
local WorldFrame = WorldFrame
local UNKNOWNOBJECT = UNKNOWNOBJECT

local Plates = {}
local GUIDs = {}
-- local playerGUID
local plateIndex
local targetExists, mouseoverExists = false, false
local targetName = ""
local updateRequired = false
local FS_PATTERN = gsub(FOREIGN_SERVER_LABEL, "[*()]", "%%%1")

local PlateMeta = setmetatable({}, {__index = function(t, frame)
		t[frame] = setmetatable({}, {
			__index = function(t, key)
				if key == "NameText" then
					t[key] = frame.NameContainer.NameText
				elseif key == "Threat" then
					t[key] = frame.ArtContainer.AggroWarningTexture
				elseif key == "SkullIcon" then
					t[key] = frame.ArtContainer.HighLevelIcon
				elseif key == "RaidIcon" then
					t[key] = frame.ArtContainer.RaidTargetIcon
				elseif key == "HBTexture" then
					t[key] = frame.ArtContainer.HealthBar:GetRegions()
				elseif key == "HBOverAbsorb" then
					t[key] = frame.ArtContainer.HealthBar.OverAbsorb
				elseif key == "ABTexture" then
					t[key] = frame.ArtContainer.AbsorbBar:GetRegions()
				elseif key == "ABOverlay" then
					t[key] = frame.ArtContainer.AbsorbBar.Overlay
				elseif key == "CBTexture" then
					t[key] = frame.ArtContainer.CastBar:GetRegions()
				elseif key == "CBShield" then
					t[key] = frame.ArtContainer.CastBarFrameShield
				elseif key == "CBIcon" then
					t[key] = frame.ArtContainer.CastBarSpellIcon
				else
					t[key] = frame.ArtContainer[key] or false
				end

				if not t[key] then
					print("|cffe56619Unknown index:|r ", key)
				end

				return t[key]
			end
		})
		return t[frame]
	end
})

local function IsTargetNamePlate(self, ignoreAlpha)
	local name = gsub(PlateMeta[self].NameText:GetText(), FS_PATTERN, "")
	return (ignoreAlpha and true or self:GetAlpha() == 1) and targetExists and name == targetName
end

local function IsMouseoverNamePlate(self)
	return mouseoverExists and PlateMeta[self].Highlight:IsShown()
end

local function NamePlate_CreateStatusBar(parent, isCastBar, npName)
	local bar

	if isCastBar then
		bar = E:CreateStatusBar(parent, npName.."CastBar", 112, "12", true)
		bar:SetPoint("BOTTOM", parent, "BOTTOM", 0, 1)

		local spark = bar:CreateTexture(nil, "BORDER", nil, 1)
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
		spark:SetSize(24, 24)
		spark:SetBlendMode("ADD")
		bar.Spark = spark
	else
		bar = E:CreateStatusBar(parent, npName.."HealthBar", 120, "12")
		bar:SetPoint("TOP", parent, "TOP", 0, -16)

		bar.Text:SetFontObject("LS12Font")
		bar.Text:SetJustifyH("RIGHT")

		local fg = bar:CreateTexture(nil, "OVERLAY", nil, 1)
		fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
		bar.Fg = fg
	end

	bar:SetStatusBarColor(unpack(COLORS.darkgray))

	return bar
end

local function NamePlate_GetColor(r, g, b, a)
	r, g, b, a = tonumber(format("%.2f", r)), tonumber(format("%.2f", g)), tonumber(format("%.2f", b)), tonumber(format("%.2f", a))

	if r == 1 and g == 0 and b == 0 then
		return unpack(COLORS.red)
	elseif r == 0 and g == 1 and b == 0 then
		return unpack(COLORS.green)
	elseif r == 1 and g == 1 and b == 0 then
		return unpack(COLORS.yellow)
	elseif r == 0 and g == 0 and b == 1 then
		return unpack(COLORS.blue)
	else
		return r, g, b, a
	end
end

local function NamePlateHealthBar_Update(self)
	local bar = self.Bar
	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(self:GetValue())
	bar:SetStatusBarColor(NamePlate_GetColor(self:GetStatusBarColor()))
	bar.Text:SetText(E:NumberToPerc(self:GetValue(), 1).."%")
end

local function NamePlateCastBar_OnShow(self)
	local bar = self.Bar
	local plateTable = PlateMeta[self.ParentPlate]
	bar.Icon:SetTexture(plateTable.CBIcon:GetTexture())
	bar.Text:SetText(plateTable.CastBarText:GetText())
	bar:Show()
end

local function NamePlateCastBar_OnHide(self)
	self.Bar:Hide()
end

local function NamePlateCastBar_OnValueChanged(self, value)
	local bar = self.Bar
	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(value)

	if PlateMeta[self.ParentPlate].CBShield:IsShown() then
		bar:SetStatusBarColor(unpack(COLORS.gray))
		bar.Icon:SetDesaturated(true)
	else
		bar:SetStatusBarColor(unpack(COLORS.yellow))
		bar.Icon:SetDesaturated(false)
	end
end

local function Sizer_OnSizeChanged(self, x, y)
	local parent = self.ParentFrame
	if parent:IsShown() then
		local overlay = Plates[parent]
		overlay:Hide()
		overlay:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", E:Round(x), E:Round(y - 20))
		overlay:Show()
	end
end

local function NamePlate_OnShow(self)
	local plateTable = PlateMeta[self]
	local overlay = Plates[self]
	local hbFg = plateTable.HealthBar.Bar.Fg

	local scale = UIParent:GetEffectiveScale()
	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", overlay:GetWidth()))

	local name = plateTable.NameText:GetText() or UNKNOWNOBJECT
	local level = plateTable.SkullIcon:IsShown() and "??" or tonumber(plateTable.LevelText:GetText())
	local color = E:GetCreatureDifficultyColor(level == "??" and -1 or level)

	if plateTable.EliteIcon:IsShown() then
		level = level.."+"

		hbFg:SetTexCoord(130 / 512, 262 / 512, 0 / 64, 26 / 64)
		hbFg:SetSize(132, 26)
		hbFg:SetPoint("CENTER", 0, 1)

		overlay.NameText:SetPoint("TOP", overlay, "TOP", 0, 3)
	else
		hbFg:SetTexCoord(0 / 512, 130 / 512, 0 / 64, 22 / 64)
		hbFg:SetSize(130, 22)
		hbFg:SetPoint("CENTER", 0, 0)

		overlay.NameText:SetPoint("TOP", overlay, "TOP", 0, 2)
	end

	overlay.NameText:SetText("|cff"..color.hex..level.."|r "..name)

	self.updateMe = true

	overlay:SetScale(sw < ow and (scale * 0.75) or scale)
	overlay:Show()
end

local function NamePlate_OnHide(self)
	Plates[self]:Hide()
	-- Plates[self].TargetMark:Hide()
	E:StopBlink(Plates[self].ComboBar.Glow, true)
	Plates[self].ComboBar:Hide()
	Plates[self].Threat:Hide()
	self.isMouseover = nil
	self.isTarget = nil
	self.unit = nil

	if self.GUID then
		GUIDs[self.GUID] = nil
		self.GUID = nil
	end
end

local function HandleNamePlate(self)
	local plateTable = PlateMeta[self]

	plateTable.LevelText:SetSize(0.001, 0.001)
	plateTable.LevelText:Hide()
	plateTable.NameText:SetSize(0.001, 0.001)
	plateTable.NameText:Hide()
	plateTable.CastBarText:SetSize(0.001, 0.001)
	plateTable.CastBarText:Hide()

	plateTable.Threat:SetTexture("")
	plateTable.Threat:SetTexCoord(0, 0, 0, 0)
	plateTable.Threat:SetSize(0.001, 0.001)

	plateTable.Border:SetTexture("")
	plateTable.Border:SetTexCoord(0, 0, 0, 0)
	plateTable.Border:SetSize(0.001, 0.001)
	plateTable.Border:Hide()

	plateTable.Highlight:SetTexture("")
	plateTable.Highlight:SetTexCoord(0, 0, 0, 0)
	plateTable.Highlight:SetSize(0.001, 0.001)

	plateTable.SkullIcon:SetTexture("")
	plateTable.SkullIcon:SetTexCoord(0, 0, 0, 0)
	plateTable.SkullIcon:SetSize(0.001, 0.001)

	plateTable.EliteIcon:SetTexture("")
	plateTable.EliteIcon:SetTexCoord(0, 0, 0, 0)
	plateTable.EliteIcon:SetSize(0.001, 0.001)

	plateTable.CastBarBorder:SetTexture("")
	plateTable.CastBarBorder:SetTexCoord(0, 0, 0, 0)
	plateTable.CastBarBorder:SetSize(0.001, 0.001)
	plateTable.CastBarBorder:Hide()

	plateTable.CBShield:SetTexture("")
	plateTable.CBShield:SetTexCoord(0, 0, 0, 0)
	plateTable.CBShield:SetSize(0.001, 0.001)

	plateTable.CastBarTextBG:SetTexture("")
	plateTable.CastBarTextBG:SetTexCoord(0, 0, 0, 0)
	plateTable.CastBarTextBG:SetSize(0.001, 0.001)
	plateTable.CastBarTextBG:Hide()

	plateTable.HBTexture:SetTexture("")
	plateTable.ABTexture:SetTexture("")
	plateTable.CBTexture:SetTexture("")

	plateTable.RaidIcon:SetAlpha(0)

	E:ForceHide(plateTable.CBIcon)

	local overlay = CreateFrame("Frame", "LS"..self:GetName().."OverlayFrame", WorldFrame)
	overlay:SetSize(120, 48)
	overlay:Hide()
	self.OverlayFrame = overlay
	Plates[self] = overlay

	local healthBar = plateTable.HealthBar

	local myHealthBar = NamePlate_CreateStatusBar(overlay, nil, self:GetName())
	healthBar.Bar = myHealthBar
	healthBar:HookScript("OnShow", NamePlateHealthBar_Update)
	healthBar:HookScript("OnValueChanged", NamePlateHealthBar_Update)

	if not NP_CFG.show_text then
		myHealthBar.Text:Hide()
	end

	if healthBar:IsShown() then
		NamePlateHealthBar_Update(healthBar)
	end

	local castBar = plateTable.CastBar
	castBar.ParentPlate = self

	local myCastBar = NamePlate_CreateStatusBar(overlay, true, self:GetName())
	myCastBar:Hide()
	castBar.Bar = myCastBar

	local holder = CreateFrame("Frame", "$parentIconHolder", myCastBar)
	holder:SetSize(32, 32)
	holder:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMLEFT", -8, 1)
	E:CreateBorder(holder)
	holder:SetBorderColor(unpack(COLORS.yellow))

	local icon = holder:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	icon:SetAllPoints()
	myCastBar.Icon = icon

	castBar:HookScript("OnShow", NamePlateCastBar_OnShow)
	castBar:HookScript("OnHide", NamePlateCastBar_OnHide)
	castBar:HookScript("OnValueChanged", NamePlateCastBar_OnValueChanged)

	if castBar:IsShown() then
		NamePlateCastBar_OnShow(castBar)
	end

	local raidIcon = overlay:CreateTexture(nil, "OVERLAY", nil, 0)
	raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	raidIcon:SetSize(32, 32)
	raidIcon:SetPoint("BOTTOMLEFT", overlay, "BOTTOMRIGHT", 8, 1)
	raidIcon:Hide()
	overlay.RaidIcon = raidIcon

	local name = E:CreateFontString(overlay, 14, nil, true, nil)
	name:SetPoint("LEFT", overlay, -24, 0)
	name:SetPoint("RIGHT", overlay, 24, 0)
	overlay.NameText = name

	local threat = myHealthBar:CreateTexture(nil, "OVERLAY", nil, 0)
	threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\nameplate")
	threat:SetTexCoord(0 / 512, 136 / 512, 26 / 64, 44 / 64)
	threat:SetSize(136, 18)
	threat:SetPoint("TOP", myHealthBar, "TOP", 0, 8)
	threat:Hide()
	overlay.Threat = threat

	-- local targetMark = overlay:CreateTexture(nil, "OVERLAY", nil, 2)
	-- targetMark:SetTexture(1,0,0)
	-- targetMark:SetPoint("TOP", 0, 10)
	-- targetMark:Hide()
	-- overlay.TargetMark = targetMark

	local r, g, b = unpack(COLORS.power["COMBO_POINTS"])

	local comboBar = CreateFrame("StatusBar", self:GetName().."ComboBar", overlay)
	comboBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	comboBar:SetStatusBarColor(r, g, b)
	comboBar:SetFrameLevel(myHealthBar:GetFrameLevel() + 1)
	comboBar:SetSize(80, 2)
	comboBar:SetMinMaxValues(0, 5)
	comboBar:SetPoint("TOP", myHealthBar, "BOTTOM", 0, 0)
	comboBar:Hide()
	overlay.ComboBar = comboBar

	local cbFG = comboBar:CreateTexture(nil, "OVERLAY", nil, 0)
	cbFG:SetTexture("Interface\\AddOns\\oUF_LS\\media\\combo_bar")
	cbFG:SetTexCoord(38 / 256, 136 / 256, 38 / 128, 48 / 128)
	cbFG:SetSize(98, 10)
	cbFG:SetPoint("CENTER")

	local cbGlow = comboBar:CreateTexture(nil, "OVERLAY", nil, 1)
	cbGlow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\combo_bar")
	cbGlow:SetTexCoord(38 / 256, 122 / 256, 48 / 128, 54 / 128)
	cbGlow:SetSize(84, 6)
	cbGlow:SetPoint("CENTER")
	cbGlow:SetVertexColor(E:ColorLighten(r, g, b, 0.35))
	cbGlow:SetAlpha(0)
	comboBar.Glow = cbGlow

	self:HookScript("OnShow", NamePlate_OnShow)
	self:HookScript("OnHide", NamePlate_OnHide)

	if self:IsShown() then
		NamePlate_OnShow(self)
	end

	local sizer = CreateFrame("Frame", "$parentSizer", overlay)
	sizer:SetPoint("BOTTOMLEFT", WorldFrame)
	sizer:SetPoint("TOPRIGHT", self, "CENTER")
	sizer:SetScript("OnSizeChanged", Sizer_OnSizeChanged)
	sizer.ParentFrame = self

	plateIndex = plateIndex + 1
end

local function UpdateUnitInfo(self)
	self.isMouseover = IsMouseoverNamePlate(self)
	self.isTarget = IsTargetNamePlate(self)

	local GUID
	if self.isMouseover then
		self.unit = "mouseover"
		GUID = UnitGUID("mouseover")
	elseif self.isTarget then
		self.unit = "target"
		GUID = UnitGUID("target")
	else
		self.unit = nil
	end

	if self.GUID then
		if GUID and self.GUID ~= GUID then
			GUIDs[self.GUID] = nil
			GUIDs[GUID] = self
			self.GUID = GUID
		end
	else
		if GUID then
			GUIDs[GUID] = self
			self.GUID = GUID
		end
	end
end

local function ShowComboBarAtGUID(GUID)
	local plate = GUIDs[GUID]
	if plate then
		local comboBar = Plates[plate].ComboBar

		if not plate.unit or (plate.unit and not UnitCanAttack("player", plate.unit)) then
			return comboBar:Hide()
		end

		local cp
		if UnitHasVehicleUI("player") then
			cp = UnitPower("vehicle", 4)
		else
			cp = UnitPower("player", 4)
		end

		comboBar:SetValue(cp)

		if cp > 0 then
			comboBar:Show()

			if cp == 5 then
				E:Blink(comboBar.Glow, 0.5)
			else
				E:StopBlink(comboBar.Glow)
			end
		else
			E:StopBlink(comboBar.Glow, true)

			comboBar:Hide()
		end
	end
end

local function HideComboBarAtGUID(GUID)
	local plate = GUIDs[GUID]
	if plate then
		E:StopBlink(Plates[plate].ComboBar.Glow, true)
		Plates[plate].ComboBar:Hide()
	end
end

local function UpdateTargetPlate(self)
	if self.unit == "target" then
		-- Plates[self].TargetMark:Show()
		ShowComboBarAtGUID(UnitGUID("target"))
	else
		-- Plates[self].TargetMark:Hide()
		E:StopBlink(Plates[self].ComboBar.Glow, true)
		Plates[self].ComboBar:Hide()
	end
end

local updateOnOddIteration
local isOddIteration = true
local function NP_OnUpdate(self, elapsed)
	if not plateIndex then
		for _, plate in next, {WorldFrame:GetChildren()} do
			local name = plate:GetName()
			if name and match(name, "^NamePlate%d+$") then
				plateIndex = match(name, "(%d+)")
				HandleNamePlate(plate)
				break
			end
		end
	else
		local plate = _G["NamePlate"..plateIndex]
		if plate and not Plates[plate] then
			HandleNamePlate(plate)
		end
	end

	for plate, overlay in next, Plates do
		if plate:IsShown() then
			local plateTable = PlateMeta[plate]

			overlay:SetAlpha(plate:GetAlpha())
			overlay:SetFrameStrata(plate:GetFrameStrata())

			if plateTable.Threat:IsShown() then
				overlay.Threat:Show()
				overlay.Threat:SetVertexColor(plateTable.Threat:GetVertexColor())
			else
				overlay.Threat:Hide()
			end

			if plateTable.Highlight:IsShown() then
				plate.updateMe = true

				overlay.NameText:SetTextColor(unpack(COLORS.yellow))
			else
				overlay.NameText:SetTextColor(1, 1, 1)
			end

			if plateTable.RaidIcon:IsShown() then
				overlay.RaidIcon:SetTexCoord(plateTable.RaidIcon:GetTexCoord())
				overlay.RaidIcon:Show()
			else
				overlay.RaidIcon:Hide()
			end

			if plate.updateMe or updateRequired then
				UpdateUnitInfo(plate)
				-- suddenly, a wild gamble appears!
				-- there might be our target, but we dun really know
				-- cuz alpha lies, so we ignore it
				if IsTargetNamePlate(plate, true) or updateRequired then
					updateOnOddIteration = not isOddIteration
				end
				plate.updateMe = false
			end
			-- update stuff on next iteration
			if updateOnOddIteration == isOddIteration then
				UpdateUnitInfo(plate)
				UpdateTargetPlate(plate)
			end
		end
	end

	if updateOnOddIteration == isOddIteration then
		updateOnOddIteration = nil
	end

	updateRequired = false

	isOddIteration = not isOddIteration
end

function NP:PLAYER_TARGET_CHANGED(...)
	if UnitGUID("target") and UnitExists("target") and
		not UnitIsUnit("target", "player") and not UnitIsDead("target") then
		targetExists = true
		targetName = UnitName("target")
	else
		targetExists = false
		targetName = ""
	end

	updateRequired = true
end

function NP:UPDATE_MOUSEOVER_UNIT(...)
	if UnitGUID("mouseover") and UnitExists("mouseover") and
		not UnitIsUnit("mouseover", "player") and not UnitIsDead("mouseover") then
		mouseoverExists = true
	else
		mouseoverExists = false
	end
end

function NP:UNIT_COMBO_POINTS(unit)
	if unit == "player" or unit == "vehicle" then
		ShowComboBarAtGUID(UnitGUID("target"))
	end
end

function NP:IsEnabled()
	return self.isRunning
end

function NP:Enable()
	if InCombatLockdown() then
		return false, "|cffe52626Error!|r Can't be done, while in combat."
	end

	if not self:IsEnabled() then
		self:Initialize(true)
	else
		return true, "|cffe56619Warning!|r NP is already enabled."
	end

	return true, "|cff26a526Success!|r NP is enabled."
end

function NP:IsComboBarEnabled()
	return self:IsEventRegistered("UNIT_COMBO_POINTS")
end

function NP:EnableComboBar(...)
	if not self:IsComboBarEnabled() then
		if InCombatLockdown() then
	 		return false, "|cffe52626Error!|r Can't be done, while in combat."
	 	end

		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		self:RegisterEvent("UNIT_COMBO_POINTS")

		if UnitGUID("target") and UnitExists("target") and
			not UnitIsUnit("target", "player") and not UnitIsDead("target") then
			targetExists = true
			targetName = UnitName("target")
			ShowComboBarAtGUID(UnitGUID("target"))
		end

	 	return true, "|cff26a526Success!|r NP combo bar is enabled."
	 else
	 	return true, "|cffe56619Warning!|r NP combo bar is already enabled."
	 end
end

function NP:DisableComboBar(...)
	if self:IsComboBarEnabled() then
		if InCombatLockdown() then
	 		return false, "|cffe52626Error!|r Can't be done, while in combat."
	 	end

		if targetExists then
			HideComboBarAtGUID(UnitGUID("target"))
		end

		self:UnregisterEvent("UNIT_COMBO_POINTS")
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")

	 	return true, "|cff26a526Success!|r NP combo bar is disabled."
	else
	 	return true, "|cffe56619Warning!|r NP combo bar is already disabled."
	end
end

function NP:ShowHealthText()
	for plate, _ in next, Plates do
		PlateMeta[plate].HealthBar.Bar.Text:Show()
	end

	return true, "|cff26a526Success!|r Health percentage is now shown."
end

function NP:HideHealthText()
	for plate, _ in next, Plates do
		PlateMeta[plate].HealthBar.Bar.Text:Hide()
	end

	return true, "|cff26a526Success!|r Health percentage is now hidden."
end

function NP:Initialize(forceInit)
	NP_CFG = C.nameplates

	if NP_CFG.enabled or forceInit then
		self:SetScript("OnUpdate", NP_OnUpdate)

		-- if UnitGUID("player") then
		-- 	playerGUID = UnitGUID("player")
		-- end

		if NP_CFG.show_combo then
			self:EnableComboBar()
		end

		self.isRunning = true
	end
end
