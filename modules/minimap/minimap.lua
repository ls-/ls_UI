local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local MM = E:AddModule("MiniMap")

-- Lua
local _G = _G
local unpack, pairs = unpack, pairs
local strfind, strformat = string.find, string.format
local mmodf = math.modf

-- Blizz
local GameTooltip = GameTooltip
local Minimap = Minimap
local Minimap_ZoomIn = Minimap_ZoomIn
local Minimap_ZoomOut = Minimap_ZoomOut

-- Mine
local STEP = 0.00390625 -- 1 / 256
local DELAY = 337.5 -- 256 * 337.5 = 86400 = 24H

local WIDGETS = {
	MiniMapMailFrame = {"CENTER", -58, 58},
	MiniMapVoiceChatFrame = {"CENTER", 32, 74},
	GameTimeFrame = {"CENTER", 58, 58},
	MiniMapTracking = {"CENTER", 74, 32},
	QueueStatusMinimapButton = {"CENTER", 58, -58},
	MiniMapInstanceDifficulty = {"BOTTOM", -1, -38},
	GuildInstanceDifficulty = {"BOTTOM", -6, -38},
	MiniMapChallengeMode = {"BOTTOM", -1, -34},
	GarrisonLandingPageMinimapButton = {"CENTER", -58, -58},
	TimeManagerClockButton = {"TOP", 0, 12},
}

local ZONE_COLORS = {
	["sanctuary"] = {r = 0.41, g = 0.8, b = 0.94, hex = "|cff68ccef"},
	["arena"] = {r = 0.9, g = 0.15, b = 0.15, hex = "|cffe52626"},
	["combat"] = {r = 0.9, g = 0.15, b = 0.15, hex = "|cffe52626"},
	["hostile"] = {r = 0.9, g = 0.15, b = 0.15, hex = "|cffe52626"},
	["contested"] = {r = 0.9, g = 0.65, b = 0.15, hex = "|cffe5a526"},
	["friendly"] = {r = 0.15, g = 0.65, b = 0.15, hex = "|cff26a526"},
	["other"] = {r = 0.9, g = 0.65, b = 0.15, hex = "|cffffffff"},
}

local function HandleMinimapButton(button, cascade)
	local regions = {button:GetRegions()}
	local children = {button:GetChildren()}
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	local pushed = button.GetPushedTexture and button:GetPushedTexture()
	local texture, layer, name, oType, icon, highlight, border, background

	-- print("====",button:GetName(), #children, #regions,"====")

	for _, region in pairs(regions) do
		if region:IsObjectType("Texture") then
			texture, layer, name = region:GetTexture(), region:GetDrawLayer(), region:GetName()
			-- print(texture, layer)
			-- print(layer == "HIGHLIGHT" and "|cff00ccffis highlight texture|r" or "")
			-- print(region == normal and "|cffff5c7fis normal texture|r" or "")
			-- print(region == pushed and "|cffff7f5cis pushed texture|r" or "")
			-- print((texture and strfind(texture, "TrackingBorder")) and "|cffff7f5cis border texture|r" or (name and strfind(name, "Border")) and "|cffff7f5cis border texture|r" or "")
			-- print((name and strfind(name, "icon")) and "|cfff45c7fis icon texture|r" or (name and strfind(name, "Icon")) and "|cfff45c7fis Icon texture|r" or
			-- 	(button.icon and button.icon == region) and "|cfff45c7fis .icon texture|r" or (button.Icon and button.Icon == region) and "|cfff45c7fis .Icon texture|r" or "")
			-- print((layer == "BACKGROUND" and (texture and strfind(texture, "Background"))) and "|cffff11bbis background texture|r" or "")
			if layer == "HIGHLIGHT" then
				highlight = region
			elseif not normal and not pushed then
				if layer == "ARTWORK" or layer == "BACKGROUND" then
					if button.icon and button.icon == region then
						icon = region
					elseif button.Icon and button.Icon == region then
						icon = region
					elseif name and strfind(name, "icon") then
						icon = region
					elseif name and strfind(name, "Icon") then
						icon = region
					elseif texture and strfind(texture, "Background") then
						background = region
					end
				elseif layer == "OVERLAY" or layer == "BORDER" then
					if texture and strfind(texture, "TrackingBorder") then
						border = region
					elseif name and strfind(name, "border") then
						border = region
					elseif name and strfind(name, "Border") then
						border = region
					end
				end
			end
		end
	end

	local thighlight, ticon, tborder, tbackground, tnormal, tpushed

	for _, child in pairs(children) do
		name, oType = child:GetName(), child:GetObjectType()
		local strata, level = child:GetFrameStrata(), child:GetFrameLevel()
		-- print("|cffffff7f"..name.."|r", strata, level, child:GetObjectType())
		-- print((name and strfind(name, "icon")) and "|cfff45c7fis icon texture|r" or (name and strfind(name, "Icon")) and "|cfff45c7fis Icon texture|r" or "")
		if oType == "Frame" and oType ~= "Button" then
			if name and strfind(name, "icon") then
				icon = child
			elseif name and strfind(name, "Icon") then
				icon = child
			end
		elseif oType == "Button" then
			thighlight, ticon, tborder, tbackground, tnormal, tpushed = HandleMinimapButton(child, true)
		end
	end

	normal = normal or tnormal
	pushed = pushed or tpushed
	highlight = highlight or thighlight
	icon = icon or ticon
	border = border or tborder
	background = background or tbackground

	-- print(cascade and "CASCADE!!" or "")
	-- print("|cffffff7fHL|r", not not highlight, "|cffffff7fI|r", (not not icon or not not (normal and pushed)), "|cffffff7fB|r", not not border, "|cffffff7fBG|r", not not background)

	if not cascade then
		-- These aren't the dro- buttons you're looking for
		if not icon and not (normal and pushed) then return end

		button:SetSize(30, 30)
		button:SetHitRectInsets(0, 0, 0, 0)

		if highlight then
			highlight:ClearAllPoints()
			highlight:SetAllPoints(button)
		end

		local size = normal and normal:GetSize() or icon:GetSize()
		local offset = size >= 42 and -3 or size >= 28 and 0 or 6

		if normal and pushed then
			normal:SetDrawLayer("ARTWORK", 0)
			normal:ClearAllPoints()
			normal:SetPoint("TOPLEFT", offset, -offset)
			normal:SetPoint("BOTTOMRIGHT", -offset, offset)
			button.NormalTexture = normal

			pushed:SetDrawLayer("ARTWORK", 0)
			pushed:ClearAllPoints()
			pushed:SetPoint("TOPLEFT", offset, -offset)
			pushed:SetPoint("BOTTOMRIGHT", -offset, offset)
			button.PushedTexture = pushed
		elseif icon then
			if icon:IsObjectType("Texture") then
				icon:SetDrawLayer("ARTWORK", 0)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", offset, -offset)
				icon:SetPoint("BOTTOMRIGHT", -offset, offset)
			else
				icon:SetFrameLevel(4)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", offset, -offset)
				icon:SetPoint("BOTTOMRIGHT", -offset, offset)
			end

			button.Icon = icon
		end

		if not border then
			border = button:CreateTexture()
		end

		border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-button")
		border:SetTexCoord(1 / 64, 35 / 64, 1 / 64, 35 / 64)
		border:SetDrawLayer("ARTWORK", 1)
		border:SetAllPoints(button)
		button.Border = border

		if not background then
			background = button:CreateTexture()
		end

		background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
		background:SetVertexColor(0, 0, 0, 0.8)
		background:SetDrawLayer("BACKGROUND", 0)
		background:SetAllPoints(button)
		button.Background = background

		return button
	else
		return highlight, icon, border, background, normal, pushed
	end
end

local function UpdateZoneInfo()
	local color = ZONE_COLORS[_G.GetZonePVPInfo() or "other"]

	Minimap.ZoneText:SetText(color.hex..(_G.GetMinimapZoneText() or _G.UNKNOWN).."|r")
	Minimap.Spin1:SetVertexColor(color.r, color.g, color.b)
	Minimap.Spin2:SetVertexColor(color.r, color.g, color.b)
end

local function CheckTexPoint(point, base)
	if point then
		if point >= base / 256 + 1 then
			return base / 256
		else
			return point
		end
	else
		return base / 256
	end
end

local function GetDeltas()
	local h, m = _G.GetGameTime()
	local s = (h * 60 + m) * 60
	local mult = mmodf(s / DELAY)

	return (mult + 1) * DELAY - s, STEP * mult -- delay, offset
end

local function Step(t, delay, offset)
	t.l = CheckTexPoint(t.l, 64) + offset
	t.r = CheckTexPoint(t.r, 192) + offset

	t:SetMask(nil)
	t:SetTexCoord(t.l, t.r, 0 / 128, 128 / 128)
	t:SetMask("Interface\\Minimap\\UI-Minimap-Background")

	_G.C_Timer.After(delay, function() Step(t, DELAY, STEP) end)
end

local function Calendar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT", 4, -4)

	if self.pendingCalendarInvites > 0 then
		GameTooltip:AddLine(_G.GAMETIME_TOOLTIP_CALENDAR_INVITES)
	end

	GameTooltip:AddLine(_G.GAMETIME_TOOLTIP_TOGGLE_CALENDAR)
	GameTooltip:Show()
end

local function Minimap_OnEventHook(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		for _, child in pairs({self:GetChildren()}) do
			child:SetFrameLevel(self:GetFrameLevel() + 1)

			if child:IsObjectType("Button") and not WIDGETS[child:GetName()] then
				if not child:IsShown() then
					child:Show()

					HandleMinimapButton(child)

					child:Hide()
				else
					HandleMinimapButton(child)
				end
			end
		end

		Step(_G.GameTimeFrame.DayTimeIndicator, GetDeltas())

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
		UpdateZoneInfo()
	end
end

local function Minimap_OnMouseWheel(self, direction)
	if direction > 0 then
		Minimap_ZoomIn()
	else
		Minimap_ZoomOut()
	end
end

local function Minimap_OnEnter(self)
	self.ZoneText:Show()
end

local function Minimap_OnLeave(self)
	self.ZoneText:Hide()
end

local function Calendar_OnLeave(self)
	GameTooltip:Hide()
end

local function Calendar_OnEvent(self, event, ...)
	if event == "CALENDAR_UPDATE_PENDING_INVITES" or event == "PLAYER_ENTERING_WORLD" then
		local pendingCalendarInvites = _G.CalendarGetNumPendingInvites()

		if pendingCalendarInvites > self.pendingCalendarInvites then
			if not _G.CalendarFrame or (_G.CalendarFrame and not _G.CalendarFrame:IsShown()) then
				E:Blink(self.InvIndicator, nil, 0, 1)

				self.pendingCalendarInvites = pendingCalendarInvites
			end
		elseif pendingCalendarInvites == 0 then
			E:StopBlink(self.InvIndicator)
		end
	elseif event == "CALENDAR_EVENT_ALARM" then
		local title = ...
		local info = _G.ChatTypeInfo["SYSTEM"]

		_G.DEFAULT_CHAT_FRAME:AddMessage(strformat(_G.CALENDAR_EVENT_ALARM_MESSAGE, title), info.r, info.g, info.b, info.id)
	end
end

local function Calendar_OnClick(self)
	if self.InvIndicator.Blink and self.InvIndicator.Blink:IsPlaying() then
		E:StopBlink(self.InvIndicator, 1)

		self.pendingCalendarInvites = 0
	end

	_G.ToggleCalendar()
end

local function Calendar_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 1 then
		local _, _, day = _G.CalendarGetDate()
		self:SetText(day)

		self.elapsed = 0
	end
end

local function Clock_OnMouseUp(self)
	self.Ticker:SetPoint("CENTER", 0, 1)
end

local function Clock_OnMouseDown(self)
	self.Ticker:SetPoint("CENTER", 1, 0)
end

local function GarrisonMinimapButton_OnEnter(self)
	self.__mainType = nil
	self.__secondaryType = nil
	local cAvailable = _G.C_Garrison.GetGarrisonInfo(_G.LE_GARRISON_TYPE_7_0)
	local gAvailable = _G.C_Garrison.GetGarrisonInfo(_G.LE_GARRISON_TYPE_6_0)
	local lText, rText

	if cAvailable and gAvailable then
		lText = _G.ORDER_HALL_LANDING_PAGE_TITLE
		rText = _G.GARRISON_LANDING_PAGE_TITLE

		self.__mainType = _G.LE_GARRISON_TYPE_7_0
		self.__secondaryType = _G.LE_GARRISON_TYPE_6_0
	elseif cAvailable and not gAvailable then
		lText = _G.ORDER_HALL_LANDING_PAGE_TITLE

		self.__mainType = _G.LE_GARRISON_TYPE_7_0
	elseif not cAvailable and gAvailable then
		lText = _G.GARRISON_LANDING_PAGE_TITLE

		self.__mainType = _G.LE_GARRISON_TYPE_6_0
	end

	if lText then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText(_G.LANDING_PAGE_REPORT, 1, 1, 1)
		GameTooltip:AddLine("LMB: |cffffffff"..lText.."|r", nil, nil, nil, true)

		if rText then
			GameTooltip:AddLine("RMB: |cffffffff"..rText.."|r", nil, nil, nil, true)
		end

		GameTooltip:Show()
	end
end

local function GarrisonMinimapButton_OnClick(self, button)
	if self.__mainType then
		local garrTypeID = self.__mainType

		if button == "RightButton" and self.__secondaryType then
			garrTypeID = self.__secondaryType
		end

		if _G.GarrisonLandingPage and _G.GarrisonLandingPage:IsShown() then
			if _G.GarrisonLandingPage.garrTypeID == garrTypeID then
				_G.HideUIPanel(_G.GarrisonLandingPage)
			else
				_G.ShowGarrisonLandingPage(garrTypeID)
				_G.GarrisonLandingPageReport_OnShow(_G.GarrisonLandingPageReport)
			end
		else
			_G.ShowGarrisonLandingPage(garrTypeID)
		end
	end
end

function MM:Initialize()
	if C.minimap.enabled then
		if not _G.IsAddOnLoaded("Blizzard_TimeManager") then
			E:ForceLoadAddOn("Blizzard_TimeManager")
		end

		local holder = _G.CreateFrame("Frame", "LSMinimapHolder", _G.UIParent)
		holder:SetSize(164, 164)
		holder:SetPoint(unpack(C.minimap.point))
		E:CreateMover(holder)

		Minimap:EnableMouseWheel()
		Minimap:SetParent(holder)
		Minimap:ClearAllPoints()
		Minimap:SetPoint("CENTER")
		Minimap:SetSize(144, 144)
		Minimap:RegisterEvent("PLAYER_ENTERING_WORLD")
		Minimap:RegisterEvent("ZONE_CHANGED")
		Minimap:RegisterEvent("ZONE_CHANGED_INDOORS")
		Minimap:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		Minimap:HookScript("OnEvent", Minimap_OnEventHook)
		Minimap:SetScript("OnEnter", Minimap_OnEnter)
		Minimap:SetScript("OnLeave", Minimap_OnLeave)
		Minimap:SetScript("OnMouseWheel", Minimap_OnMouseWheel)

		_G.RegisterStateDriver(Minimap, "visibility", "[petbattle] hide; show")

		local spin1 = Minimap:CreateTexture(nil, "BORDER", nil, -2)
		spin1:SetTexture("Interface\\AddOns\\ls_UI\\media\\spinner-alt")
		spin1:SetTexCoord(1 / 256, 169 / 256, 1 / 256, 169 / 256)
		spin1:SetSize(172, 172)
		spin1:SetPoint("CENTER", 0, 0)
		Minimap.Spin1 = spin1

		local spin2 = Minimap:CreateTexture(nil, "BORDER", nil, -3)
		spin2:SetBlendMode("ADD")
		spin2:SetTexture("Interface\\AddOns\\ls_UI\\media\\spinner")
		spin2:SetTexCoord(169 / 256, 1 / 256, 1 / 256, 169 / 256)
		spin2:SetSize(168, 168)
		spin2:SetPoint("CENTER", 0, 0)
		Minimap.Spin2 = spin2

		local ag = Minimap:CreateAnimationGroup()
		ag:SetLooping("REPEAT")

		local anim = ag:CreateAnimation("Rotation")
		anim:SetChildKey("Spin1")
		anim:SetOrder(1)
		anim:SetDuration(60)
		anim:SetDegrees(-360)

		anim = ag:CreateAnimation("Rotation")
		anim:SetChildKey("Spin2")
		anim:SetOrder(1)
		anim:SetDuration(60)
		anim:SetDegrees(720)

		local border = Minimap:CreateTexture(nil, "BORDER")
		border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-main")
		border:SetTexCoord(1 / 256, 169 / 256, 1 / 256, 203 / 256)
		border:SetSize(168, 202)
		border:SetPoint("CENTER", 0, -17)

		for name, coords in pairs(WIDGETS) do
			_G[name]:ClearAllPoints()
			_G[name]:SetParent(Minimap)
			_G[name]:SetPoint(unpack(coords))
		end

		for _, name in pairs({
			"MinimapCluster",
			"MiniMapWorldMapButton",
			"MinimapZoomIn",
			"MinimapZoomOut",
			"MiniMapRecordingButton",
			"MinimapZoneTextButton",
			"MinimapBorder",
			"MinimapBorderTop",
			"MinimapBackdrop",
			"MiniMapTrackingIconOverlay",
		}) do
			E:ForceHide(_G[name])
		end

		-- Garrison
		local garrison = HandleMinimapButton(_G.GarrisonLandingPageMinimapButton)
		garrison:SetSize(34, 34)
		garrison:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		garrison:SetScript("OnEnter", GarrisonMinimapButton_OnEnter)
		garrison:SetScript("OnClick", GarrisonMinimapButton_OnClick)

		-- Mail
		local mail = HandleMinimapButton(_G.MiniMapMailFrame)
		mail.Icon:SetPoint("TOPLEFT", 5, -5)
		mail.Icon:SetPoint("BOTTOMRIGHT", -5, 5)

		-- Queue
		local queue = HandleMinimapButton(_G.QueueStatusMinimapButton)
		queue.Background:SetTexture("")
		_G.QueueStatusFrame:ClearAllPoints()
		_G.QueueStatusFrame:SetPoint("BOTTOMRIGHT", queue, "TOPLEFT", 8, -8)

		-- Calendar
		local calendar = HandleMinimapButton(_G.GameTimeFrame)
		calendar:SetSize(34, 34)
		calendar:SetNormalFontObject("LS14Font_Outline")
		calendar.NormalTexture:SetTexture("")
		calendar.PushedTexture:SetTexture("")
		calendar.pendingCalendarInvites = 0
		calendar:SetScript("OnEnter", Calendar_OnEnter)
		calendar:SetScript("OnLeave", Calendar_OnLeave)
		calendar:SetScript("OnEvent", Calendar_OnEvent)
		calendar:SetScript("OnClick", Calendar_OnClick)
		calendar:SetScript("OnUpdate", Calendar_OnUpdate)

		local indicator = calendar:CreateTexture(nil, "BACKGROUND", nil, 1)
		indicator:SetTexture("Interface\\Minimap\\HumanUITile-TimeIndicator", true)
		indicator:SetPoint("TOPLEFT", 2, -2)
		indicator:SetPoint("BOTTOMRIGHT", -2, 2)
		calendar.DayTimeIndicator = indicator

		local _, mark, glow, _, date = calendar:GetRegions()
		mark:SetDrawLayer("OVERLAY", 2)
		mark:SetTexCoord(7 / 128, 81 / 128, 7 / 128, 109 / 128)
		mark:SetSize(22, 30)
		mark:SetPoint("CENTER", 0, 0)
		mark:Show()
		mark:SetAlpha(0)
		calendar.InvIndicator = mark

		glow:SetTexture("")

		date:ClearAllPoints()
		date:SetPoint("CENTER", 1, 0)
		date:SetVertexColor(1, 1, 1)
		date:SetDrawLayer("BACKGROUND")
		date:SetJustifyH("CENTER")

		-- Zone Text
		local zone = _G.MinimapZoneText
		zone:SetFontObject("LS12Font_Shadow")
		zone:SetParent(Minimap)
		zone:ClearAllPoints()
		zone:SetPoint("TOP", 0, 32)
		zone:Hide()
		Minimap.ZoneText = zone

		-- Clock
		local clock = _G.TimeManagerClockButton
		local bg, ticker, glow = clock:GetRegions()

		clock:SetSize(46, 22)
		clock:SetHitRectInsets(0, 0, 0, 0)
		clock:SetHighlightTexture("Interface\\AddOns\\ls_UI\\media\\minimap-clock", "ADD")
		clock:GetHighlightTexture():SetTexCoord(1 / 64, 47 / 64, 24 / 64, 46 / 64)
		clock:SetScript("OnMouseUp", Clock_OnMouseUp)
		clock:SetScript("OnMouseDown", Clock_OnMouseDown)

		bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-clock")
		bg:SetTexCoord(1 / 64, 47 / 64, 1 / 64, 23 / 64)

		ticker:ClearAllPoints()
		ticker:SetPoint("CENTER", 0, 1)
		clock.Ticker = ticker

		glow:SetTexCoord(2 / 64, 52 / 64, 33 / 64, 55 / 64)
		glow:SetSize(50, 22)
		glow:ClearAllPoints()
		glow:SetPoint("CENTER", -1, 0)

		-- Compass
		local compass = _G.MinimapCompassTexture
		compass:SetParent(Minimap)
		compass:ClearAllPoints()
		compass:SetPoint("CENTER", 0, 0)

		-- Misc
		HandleMinimapButton(_G.MiniMapTracking)
		HandleMinimapButton(_G.MiniMapVoiceChatFrame)
		UpdateZoneInfo()
		ag:Play()

		-- Hacks
		_G.MovieFrame:HookScript("OnHide", function()
			indicator:SetMask(nil)
			indicator:SetMask("Interface\\Minimap\\UI-Minimap-Background")
		end)
	end
end
