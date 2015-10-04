local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

E.Minimap = {}

local MM = E.Minimap

local Minimap = Minimap

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
}

local ZONE_COLOR_CODES = {
	["sanctuary"] = "|cff68ccef",
	["arena"] = "|cffe52626",
	["combat"] = "|cffe52626",
	["hostile"] = "|cffe52626",
	["contested"] = "|cffe5a526",
	["friendly"] = "|cff26a526",
	["other"] = "|cffffffff",
}

local HandleMinimapButton
function HandleMinimapButton(button, cascade)
	local regions = {button:GetRegions()}
	local children = {button:GetChildren()}
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	local pushed = button.GetPushedTexture and button:GetPushedTexture()
	local texture, layer, name, oType, icon, highlight, border, background

	-- print("====",button:GetName(), #children, #regions,"====")

	for _, region in next, regions do
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
					end
				end
			end
		end
	end

	local thighlight, ticon, tborder, tbackground, tnormal, tpushed

	for _, child in next, children do
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

		border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap")
		border:SetTexCoord(462 / 512, 496 / 512, 0, 34 / 256)
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
	else
		return highlight, icon, border, background, normal, pushed
	end
end

local function UpdateZoneText(text)
	text:SetText(ZONE_COLOR_CODES[GetZonePVPInfo() or "other"]..(GetMinimapZoneText() or UNKNOWN).."|r")
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
	local h, m = GetGameTime()
	local s = (h * 60 + m) * 60
	local mult = math.modf(s / DELAY)

	return (mult + 1) * DELAY - s, STEP * mult -- delay, offset
end

local Step
function Step(t, delay, offset)
	t.l = CheckTexPoint(t.l, 64) + offset
	t.r = CheckTexPoint(t.r, 192) + offset

	t:SetMask(nil)
	t:SetTexCoord(t.l, t.r, 0 / 128, 128 / 128)
	t:SetMask("Interface\\Minimap\\UI-Minimap-Background")

	C_Timer.After(delay, function() Step(t, DELAY, STEP) end)
end

local function Calendar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 10, 10)

	if self.pendingInvites > 0 then
		GameTooltip:AddLine(GAMETIME_TOOLTIP_CALENDAR_INVITES)
	end

	GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CALENDAR)
	GameTooltip:Show()
end

local function Minimap_OnEventHook(self, event)
	if event == "PLAYER_ENTERING_WORLD" and not self.handled then
		for _, child in next, {self:GetChildren()} do
			child:SetFrameLevel(self:GetFrameLevel() + 1)

			if child:IsObjectType("Button") then
				if not WIDGETS[child:GetName()] then
					HandleMinimapButton(child)
				end
			end
		end

		Step(GameTimeFrame.daytime, GetDeltas())

		self.handled = true
	elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS"
		or event == "ZONE_CHANGED_NEW_AREA" then
		UpdateZoneText(self.zone)
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
	self.zone:Show()
end

local function Minimap_OnLeave(self)
	self.zone:Hide()
end

local function Calendar_OnLeave(self)
	GameTooltip:Hide()
end

local function Calendar_OnEvent(self, event, ...)
	if event == "CALENDAR_UPDATE_PENDING_INVITES" or event == "PLAYER_ENTERING_WORLD" then
		local pendingInvites = CalendarGetNumPendingInvites()

		if pendingInvites > self.pendingInvites then
			if not CalendarFrame or (CalendarFrame and not CalendarFrame:IsShown()) then
				E:Blink(self.mark, nil, 0, 1)

				self.pendingInvites = pendingInvites
			end
		elseif pendingInvites == 0 then
			E:StopBlink(self.mark)
		end
	elseif event == "CALENDAR_EVENT_ALARM" then
		local title = ...
		local info = ChatTypeInfo["SYSTEM"]

		DEFAULT_CHAT_FRAME:AddMessage(format(CALENDAR_EVENT_ALARM_MESSAGE, title), info.r, info.g, info.b, info.id)
	end
end

local function Calendar_OnClick(self)
	if self.mark.Blink and self.mark.Blink:IsPlaying() then
		E:StopBlink(self.mark, 1)

		self.pendingInvites = 0
	end

	ToggleCalendar()
end

local function Calendar_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 1 then
		local _, _, day = CalendarGetDate()
		self:SetText(day)

		self.elapsed = 0
	end
end

function MM:Initialize()
	if not IsAddOnLoaded("Blizzard_TimeManager") then
		E:ForceLoadAddOn("Blizzard_TimeManager")
	end

	local holder = CreateFrame("Frame", "LSMinimapHolder", UIParent)
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
	Minimap:SetScript("OnMouseWheel", Minimap_OnMouseWheel)
	Minimap:SetScript("OnEnter", Minimap_OnEnter)
	Minimap:SetScript("OnLeave", Minimap_OnLeave)

	RegisterStateDriver(Minimap, "visibility", "[petbattle] hide; show")

	local ring = Minimap:CreateTexture(nil, "BORDER", nil, 0)
	ring:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap")
	ring:SetTexCoord(0, 168 / 512, 0, 202 / 256)
	ring:SetSize(168, 202)
	ring:SetPoint("CENTER", 0, -17)

	local gloss = Minimap:CreateTexture(nil, "BORDER", nil, 1)
	gloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap")
	gloss:SetTexCoord(318 / 512, 462 / 512, 0, 144 / 256)
	gloss:SetSize(144, 144)
	gloss:SetPoint("CENTER", 0, 0)

	local fg = Minimap:CreateTexture(nil, "BORDER", nil, 2)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap")
	fg:SetTexCoord(168 / 512, 318 / 512, 0, 150 / 256)
	fg:SetSize(150, 150)
	fg:SetPoint("CENTER", 0, 0)

	for i, k in next, WIDGETS do
		_G[i]:ClearAllPoints()
		_G[i]:SetParent(Minimap)
		_G[i]:SetPoint(unpack(k))
	end

	for _, f in next, {
		"MinimapCluster",
		"MiniMapWorldMapButton",
		"MinimapZoomIn",
		"MinimapZoomOut",
		"MiniMapRecordingButton",
		"MinimapZoneTextButton",
		"MinimapBorder",
		"MinimapBorderTop",
		"MinimapBackdrop",
		"TimeManagerClockButton",
		"MiniMapTrackingIconOverlay",
	} do
		if not _G[f]:IsObjectType("Texture") then
			_G[f]:UnregisterAllEvents()
		end

		_G[f]:SetParent(M.hiddenParent)
	end

	HandleMinimapButton(MiniMapVoiceChatFrame)
	HandleMinimapButton(GarrisonLandingPageMinimapButton)

	HandleMinimapButton(MiniMapMailFrame)
	MiniMapMailFrame.Icon:SetPoint("TOPLEFT", 5, -5)
	MiniMapMailFrame.Icon:SetPoint("BOTTOMRIGHT", -5, 5)

	HandleMinimapButton(MiniMapTracking)
	MiniMapTracking.Icon:SetVertexColor(0.72, 0.66, 0.56)

	HandleMinimapButton(QueueStatusMinimapButton)
	QueueStatusMinimapButton.Background:SetTexture("")

	local calendar = GameTimeFrame

	HandleMinimapButton(calendar)
	calendar:SetSize(34, 34)
	calendar.NormalTexture:SetTexture("")
	calendar.PushedTexture:SetTexture("")
	calendar:SetHitRectInsets(-2, -2, -2, -2)

	calendar.pendingInvites = 0

	local texture = calendar:CreateTexture(nil, "BACKGROUND", nil, 1)
	texture:SetTexture("Interface\\Minimap\\HumanUITile-TimeIndicator", true)
	texture:SetPoint("TOPLEFT", 2, -2)
	texture:SetPoint("BOTTOMRIGHT", -2, 2)
	calendar.daytime = texture

	local _, mark, glow, _, date = calendar:GetRegions()

	mark:SetDrawLayer("OVERLAY", 2)
	mark:SetTexCoord(7 / 128, 81 / 128, 7 / 128, 109 / 128)
	mark:SetSize(22, 30)
	mark:SetPoint("CENTER", 0, 0)
	mark:Show()
	mark:SetAlpha(0)
	calendar.mark = mark

	glow:SetTexture("")

	date:SetFont(M.font, 14, "THINOUTLINE")
	date:ClearAllPoints()
	date:SetPoint("CENTER", 1, 0)
	date:SetVertexColor(1, 1, 1)
	date:SetDrawLayer("BACKGROUND", 2)
	date:SetJustifyH("CENTER")

	calendar:SetScript("OnEnter", Calendar_OnEnter)
	calendar:SetScript("OnLeave", Calendar_OnLeave)
	calendar:SetScript("OnEvent", Calendar_OnEvent)
	calendar:SetScript("OnClick", Calendar_OnClick)
	calendar:SetScript("OnUpdate", Calendar_OnUpdate)

	local zone = MinimapZoneText
	zone:SetFont(M.font, 12)
	zone:SetParent(Minimap)
	zone:ClearAllPoints()
	zone:SetPoint("TOP", 0, 32)
	zone:Hide()
	UpdateZoneText(zone)
	Minimap.zone = zone
end
