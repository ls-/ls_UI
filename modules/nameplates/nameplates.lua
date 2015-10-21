local _, ns = ...
local C, E, M = ns.C, ns.E, ns.M
local COLORS = M.colors

E.NP = CreateFrame("Frame")

local NP = E.NP

local tonumber, format, match, unpack, select = tonumber, format, strmatch, unpack, select

local WorldFrame = WorldFrame

local Plates = {}
local GUIDs = {}
local playerGUID
local prevNumChildren = 0
local targetExists, mouseoverExists = false, false
local targetName = ""
local updateRequired = false

local FS_PATTERN = gsub(FOREIGN_SERVER_LABEL, "[*()]", "%%%1")

local function IsTargetNamePlate(self, ignoreAlpha)
	local name = gsub(self.NameText:GetText(), FS_PATTERN, "")
	return (ignoreAlpha and true or self:GetAlpha() == 1) and targetExists and name == targetName
end

local function NamePlate_CreateStatusBar(parent, isCastBar, npName)
	local bar

	if isCastBar then
		bar = E:CreateStatusBar(parent, npName, 112, "12", true)
		bar:SetPoint("BOTTOM", parent, "BOTTOM", 0, 1)

		local spark = bar:CreateTexture(nil, "BORDER", nil, 1)
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
		spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
		spark:SetSize(24, 24)
		spark:SetBlendMode("ADD")
		bar.Spark = spark
	else
		bar = E:CreateStatusBar(parent, npName, 120, "12")
		bar:SetPoint("TOP", parent, "TOP", 0, -16)

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

	if bar.Text:IsShown() then
		bar.Text:SetText(E:NumberToPerc(self:GetValue(), 1).."%")
	end
end

local function NamePlateCastBar_OnShow(self)
	local bar = self.Bar
	bar.Icon:SetTexture(self.Icon:GetTexture())
	bar.Text:SetText(self.Text:GetText())
	bar:Show()
end

local function NamePlateCastBar_OnHide(self)
	self.Bar:Hide()
end

local function NamePlateCastBar_OnValueChanged(self, value)
	local bar = self.Bar
	bar:SetMinMaxValues(self:GetMinMaxValues())
	bar:SetValue(value)

	if self.Shield:IsShown() then
		bar:SetStatusBarColor(unpack(COLORS.gray))
		bar.Icon:SetDesaturated(true)
	else
		bar:SetStatusBarColor(unpack(COLORS.yellow))
		bar.Icon:SetDesaturated(false)
	end
end

local function Sizer_OnSizeChanged(self, x, y)
	local parent = self.Parent
	if parent:IsShown() then
		parent.Overlay:Hide()
		parent.Overlay:SetPoint("CENTER", WorldFrame, "BOTTOMLEFT", E:Round(x), E:Round(y - 20))
		parent.Overlay:Show()
	end
end

local function NamePlate_OnShow(self)
	local overlay = self.Overlay
	local healthBarFg = self.HealthBar.Bar.Fg

	local scale = UIParent:GetEffectiveScale()
	local sw, ow = tonumber(format("%d", self:GetWidth())), tonumber(format("%d", overlay:GetWidth()))

	local name = self.NameText:GetText() or UNKNOWNOBJECT
	local level = self.HighLevelIcon:IsShown() and "??" or tonumber(self.LevelText:GetText())
	local color = E:GetCreatureDifficultyColor(level == "??" and -1 or level)

	if self.EliteIcon:IsShown() then
		level = level.."+"

		healthBarFg:SetTexCoord(130 / 512, 262 / 512, 0 / 64, 26 / 64)
		healthBarFg:SetSize(132, 26)
		healthBarFg:SetPoint("CENTER", 0, 1)

		overlay.NameText:SetPoint("TOP", overlay, "TOP", 0, 3)
	else
		healthBarFg:SetTexCoord(0 / 512, 130 / 512, 0 / 64, 22 / 64)
		healthBarFg:SetSize(130, 22)
		healthBarFg:SetPoint("CENTER", 0, 0)

		overlay.NameText:SetPoint("TOP", overlay, "TOP", 0, 2)
	end

	overlay.NameText:SetText("|cff"..color.hex..level.."|r "..name)

	if IsTargetNamePlate(self, true) then
		updateRequired = true
		isOddIteration = true
	end

	overlay:SetScale(sw < ow and (scale * 0.75) or scale)
	overlay:Show()
end

local function NamePlate_OnHide(self)
	self.Overlay:Hide()
	self.TargetMark:Hide()
	-- self.ComboBar:Hide()
	-- E:StopBlink(self.ComboBar.Glow, true)
	self.unit = nil

	if self.GUID then
		GUIDs[self.GUID] = nil
		self.GUID = nil
	end
end

local function HandleNamePlate(self)
	local ArtContainer, NameContainer = self:GetChildren()
	local HealthBar, AbsorbBar, CastBar = ArtContainer:GetChildren() -- AbsorbBar doesn't seem to work yet

	local Threat, Border, Highlight, LevelText, HighLevelIcon, RaidTargetIcon, EliteIcon = ArtContainer:GetRegions()
	local NameText = NameContainer:GetRegions()
	local HealthBarTexture, OverAbsorb = HealthBar:GetRegions()
	local AbsorbBarTexture, AbsorbBarOverlay = AbsorbBar:GetRegions()
	local CastBarTexture, CastBarBorder, CastBarFrameShield, CastBarSpellIcon, CastBarText, CastBarTextBG = CastBar:GetRegions()

	----------------
	-- NEED BEGIN --
	----------------

	self.HealthBar = HealthBar -- frame.ArtContainer.HealthBar
	self.CastBar = CastBar -- self.ArtContainer.CastBar

	E:ForceHide(Threat) -- self.ArtContainer.AggroWarningTexture
	self.Threat = Threat

	E:ForceHide(LevelText) -- self.ArtContainer.LevelText
	self.LevelText = LevelText

	E:ForceHide(NameText) -- self.NameContainer.NameText
	self.NameText = NameText

	E:ForceHide(CastBarSpellIcon) -- self.ArtContainer.CastBarSpellIcon
	CastBar.Icon = CastBarSpellIcon

	E:ForceHide(CastBarText) -- self.ArtContainer.CastBarText
	CastBar.Text = CastBarText

	HealthBarTexture:SetTexture("")
	HealthBar.StatusBarTexture = HealthBarTexture

	HighLevelIcon:SetTexture("") -- self.ArtContainer.HighLevelIcon
	HighLevelIcon:SetTexCoord(0, 0, 0, 0)
	HighLevelIcon:SetSize(0.001, 0.001)
	self.HighLevelIcon = HighLevelIcon

	EliteIcon:SetTexture("") -- self.ArtContainer.EliteIcon
	EliteIcon:SetTexCoord(0, 0, 0, 0)
	EliteIcon:SetSize(0.001, 0.001)
	self.EliteIcon = EliteIcon

	Highlight:SetTexture("") -- self.ArtContainer.Highlight
	Highlight:SetTexCoord(0, 0, 0, 0)
	Highlight:SetSize(0.001, 0.001)
	self.Highlight = Highlight

	CastBarFrameShield:SetTexture("") -- self.ArtContainer.CastBarFrameShield
	CastBarFrameShield:SetTexCoord(0, 0, 0, 0)
	CastBarFrameShield:SetSize(0.001, 0.001)
	CastBar.Shield = CastBarFrameShield

	--------------
	-- NEED END --
	--------------

	--------------------
	-- NEED NOT BEGIN --
	--------------------

	E:ForceHide(Border) -- self.ArtContainer.Border
	E:ForceHide(OverAbsorb) -- self.ArtContainer.HealthBar.OverAbsorb
	E:ForceHide(AbsorbBarOverlay) -- self.ArtContainer.AbsorbBar.Overlay
	E:ForceHide(CastBarBorder) -- self.ArtContainer.CastBarBorder
	E:ForceHide(CastBarTextBG) -- self.ArtContainer.CastBarTextBG
	AbsorbBarTexture:SetTexture("")
	CastBarTexture:SetTexture("")

	------------------
	-- NEED NOT END --
	------------------

	local overlay = CreateFrame("Frame", "LS"..self:GetName().."Overlay", WorldFrame)
	overlay:SetFrameStrata(self:GetFrameStrata())
	overlay:SetSize(120, 48)
	overlay:Hide()
	self.Overlay = overlay
	Plates[self] = overlay

	local myHealthBar = NamePlate_CreateStatusBar(overlay, nil, self:GetName())
	HealthBar.Bar = myHealthBar
	HealthBar:HookScript("OnShow", NamePlateHealthBar_Update)
	HealthBar:HookScript("OnValueChanged", NamePlateHealthBar_Update)

	if not C.nameplates.showText then
		myHealthBar.Text:Hide()
	end

	if HealthBar:IsShown() then
		NamePlateHealthBar_Update(HealthBar)
	end

	local myCastBar = NamePlate_CreateStatusBar(overlay, true, self:GetName())
	myCastBar:Hide()
	CastBar.Bar = myCastBar

	local holder = CreateFrame("Frame", nil, myCastBar)
	holder:SetSize(32, 32)
	holder:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMLEFT", -8, 1)
	E:CreateBorder(holder)
	holder:SetBorderColor(unpack(COLORS.yellow))

	local icon = holder:CreateTexture(nil, "BACKGROUND", nil, 1)
	icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
	icon:SetAllPoints()
	myCastBar.Icon = icon

	CastBar:HookScript("OnShow", NamePlateCastBar_OnShow)
	CastBar:HookScript("OnHide", NamePlateCastBar_OnHide)
	CastBar:HookScript("OnValueChanged", NamePlateCastBar_OnValueChanged)

	if CastBar:IsShown() then
		NamePlateCastBar_OnShow(CastBar)
	end

	RaidTargetIcon:SetParent(overlay)
	RaidTargetIcon:SetSize(32, 32)
	RaidTargetIcon:ClearAllPoints()
	RaidTargetIcon:SetPoint("LEFT", overlay, "RIGHT", 8, 0)

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

	local targetMark = overlay:CreateTexture(nil, "OVERLAY", nil, 2)
	targetMark:SetTexture(1,0,0)
	targetMark:SetPoint("TOP", 0, 10)
	targetMark:Hide()
	self.TargetMark = targetMark

	--[[

	local r, g, b = unpack(COLORS.power["COMBO_POINTS"])

	local comboBar = CreateFrame("StatusBar", self:GetName().."ComboBar", overlay)
	comboBar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	comboBar:SetStatusBarColor(r, g, b)
	comboBar:SetFrameLevel(myHealthBar:GetFrameLevel() + 1)
	comboBar:SetSize(80, 2)
	comboBar:SetMinMaxValues(0, 5)
	comboBar:SetPoint("TOP", myHealthBar, "BOTTOM", 0, 0)
	comboBar:Hide()
	self.ComboBar = comboBar

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


]]
	self:HookScript("OnShow", NamePlate_OnShow)
	self:HookScript("OnHide", NamePlate_OnHide)

	if self:IsShown() then
		NamePlate_OnShow(self)
	end

	local sizer = CreateFrame("Frame", nil, overlay)
	sizer:SetPoint("BOTTOMLEFT", WorldFrame)
	sizer:SetPoint("TOPRIGHT", self, "CENTER")
	sizer:SetScript("OnSizeChanged", Sizer_OnSizeChanged)
	sizer.Parent = self
end

local function UpdateUnitInfo(self)
	local isTarget = IsTargetNamePlate(self)
	local isMouseover = self.isMouseover

	local GUID
	if isTarget then
		self.unit = "target"
		GUID = UnitGUID("target")
	elseif isMouseover then
		self.unit = "mouseover"
		GUID = UnitGUID("mouseover")
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


local function UpdateComboBarByGUID(GUID)
	local plate = GUIDs[GUID]
	if plate then
		local cp
		if UnitHasVehicleUI("player") then
			cp = UnitPower("vehicle", 4)
		else
			cp = UnitPower("player", 4)
		end

		plate.ComboBar:SetValue(cp)

		if cp > 0 then
			plate.ComboBar:Show()

			if cp == 5 then
				E:Blink(plate.ComboBar.Glow, 0.5)
			else
				E:StopBlink(plate.ComboBar.Glow)
			end
		else
			E:StopBlink(plate.ComboBar.Glow, true)

			plate.ComboBar:Hide()
		end
	end
end

local function UpdateTargetPlate(self)
	if self.unit == "target" then
		self.TargetMark:Show()
		-- UpdateComboBarByGUID(UnitGUID("target"))
	else
		self.TargetMark:Hide()
		-- self.ComboBar:Hide()
	end
end


local isOddIteration = true
local function WorldFrame_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		local curNumChildren = WorldFrame:GetNumChildren()
		if curNumChildren ~= prevNumChildren  then
			for i = prevNumChildren + 1, curNumChildren do
				local f = select(i, WorldFrame:GetChildren())
				local name = f:GetName()
				if (name and match(name, "^NamePlate%d")) and not Plates[f] then
					HandleNamePlate(f)
				end
			end

			prevNumChildren = curNumChildren
		end

		for plate, overlay in next, Plates do
			if plate:IsShown() then
				overlay:SetAlpha(plate:GetAlpha())
				if plate.Threat:IsShown() then
					overlay.Threat:Show()
					overlay.Threat:SetVertexColor(plate.Threat:GetVertexColor())
				else
					overlay.Threat:Hide()
				end

				if plate.Highlight:IsShown() then
					UpdateUnitInfo(plate)
					-- print(plate:GetName(), plate.unit, "|cff00ccff"..plate.NameText:GetText().."|r")

					overlay.NameText:SetTextColor(unpack(COLORS.yellow))
				else
					overlay.NameText:SetTextColor(1, 1, 1)
				end

				if not isOddIteration then
					if updateRequired then
						-- print("everything begin")
						UpdateUnitInfo(plate)
						-- print("running update for:", plate:GetName(), plate.unit, "|cff00ccff"..plate.NameText:GetText().."|r")
						UpdateTargetPlate(plate)
						-- print("everything end")
					end
				end
			end
		end

		if not isOddIteration then
			updateRequired = false
		end

		isOddIteration = not isOddIteration

		self.elapsed = 0
	end
end

function NP:ToggleHealthText()
	for plate, overlay in next, Plates do
		if not C.nameplates.showText then
			overlay.HealthBar.Text:Hide()
		else
			overlay.HealthBar.Text:Show()
		end
	end
end

function NP:PLAYER_TARGET_CHANGED(...)
	if UnitGUID("target") and UnitExists("target") and not UnitIsUnit("target", "player") and not UnitIsDead("target") then
		targetExists = true
		targetName = UnitName("target")
	else
		targetExists = false
		targetName = ""
	end

	updateRequired = true
	isOddIteration = true
end

function NP:UPDATE_MOUSEOVER_UNIT(...)
	if UnitGUID("mouseover") and UnitExists("mouseover") and not UnitIsUnit("mouseover", "player") and not UnitIsDead("mouseover") then
		mouseoverExists = true
	else
		mouseoverExists = false
	end
end

function NP:UNIT_COMBO_POINTS(unit)
	if unit == "player" or unit == "vehicle" then
		UpdateComboBarByGUID(UnitGUID("target"))
	end
end

function NP:Initialize()
	WorldFrame:HookScript("OnUpdate", WorldFrame_OnUpdate)

	if UnitGUID("player") then
		playerGUID = UnitGUID("player")
	end

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	-- self:RegisterEvent("UNIT_COMBO_POINTS")
	self:SetScript("OnEvent", E.EventHandler)
end
