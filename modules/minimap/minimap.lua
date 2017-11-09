local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Minimap")

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor
local next = _G.next
local s_match = _G.string.match
local unpack = _G.unpack

-- Mine
local isInit = false

local DELAY = 337.5 -- 256 * 337.5 = 86400 = 24H
local STEP = 0.00390625 -- 1 / 256

local TEXTURES = {
	BIG = {
		size = {88 / 2, 88 / 2},
		coords = {1 / 256, 89 / 256, 1 / 256, 89 / 256},
	},
	SMALL = {
		size = {72 / 2, 72 / 2},
		coords = {90 / 256, 162 / 256, 1 / 256, 73 / 256},
	},
}

local WIDGETS = {
	GameTimeFrame = {"CENTER", 60, 60},
	GarrisonLandingPageMinimapButton = {"CENTER", -57, -57},
	GuildInstanceDifficulty = {"TOP", "Minimap", "BOTTOM", -2, 8},
	MiniMapChallengeMode = {"TOP", "Minimap", "BOTTOM", 0, 2},
	MiniMapInstanceDifficulty = {"TOP", "Minimap", "BOTTOM", 0, 7},
	MiniMapMailFrame = {"CENTER", -57, 57},
	MiniMapTracking = {"CENTER", 74, 32},
	QueueStatusMinimapButton = {"CENTER", 57, -57},
	TimeManagerClockButton = {"BOTTOM", "Minimap", "TOP", 0, -14},
}

local ZONE_COLORS = {
	arena = M.COLORS.RED,
	combat = M.COLORS.RED,
	contested = M.COLORS.YELLOW,
	friendly = M.COLORS.GREEN,
	hostile = M.COLORS.RED,
	other = M.COLORS.YELLOW,
	sanctuary = M.COLORS.LIGHT_BLUE,
}

local handledButtons = {}
local ignoredButtons = {}

local function HandleMinimapButton(button, recursive)
	local regions = {button:GetRegions()}
	local children = {button:GetChildren()}
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	local pushed = button.GetPushedTexture and button:GetPushedTexture()
	local hl, icon, border, bg, thl, ticon, tborder, tbg, tnormal, tpushed

	-- print("====|cffff0000", button:GetDebugName(), "|r:", #children, #regions,"====")

	for _, region in next, regions do
		if region:IsObjectType("Texture") then
			local name = region:GetDebugName()
			local texture = region:GetTexture()
			local layer = region:GetDrawLayer()
			-- print("|cffffff00", name, "|r:", texture, layer)

			if not normal and not pushed then
				if layer == "ARTWORK" or layer == "BACKGROUND" then
					if button.icon and region == button.icon then
						-- print("|cffffff00", name, "|ris |cff00ff00.icon|r", region, button.icon)
						icon = region
					elseif button.Icon and region == button.Icon then
						-- print("|cffffff00", name, "|ris |cff00ff00.Icon|r")
						icon = region
						-- ignore all LDBIcons
					elseif name and not s_match(name, "^LibDBIcon") and s_match(name, "[iI][cC][oO][nN]") then
						-- print("|cffffff00", name, "|ris |cff00ff00icon|r")
						icon = region
					elseif texture and s_match(texture, "[iI][cC][oO][nN]") then
						-- print("|cffffff00", name, "|ris |cff00ff00-icon|r")
						icon = region
					elseif texture and texture == 136467 then
						bg = region
					elseif texture and s_match(texture, "[bB][aA][cC][kK][gG][rR][oO][uU][nN][dD]") then
						-- print("|cffffff00", name, "|ris |cff00ff00-background|r")
						bg = region
					end
				end
			end

			if layer == "HIGHLIGHT" then
				hl = region
			else
				if button.border and button.border == region then
					-- print("|cffffff00", name, "|ris |cff00ff00.border|r")
					border = region
				elseif button.Border and button.Border == region then
					-- print("|cffffff00", name, "|ris |cff00ff00.Border|r")
					border = region
				elseif s_match(name, "[bB][oO][rR][dD][eE][rR]") then
					-- print("|cffffff00", name, "|ris |cff00ff00border|r")
					border = region
				elseif texture and texture == 136430 then
					-- print("|cffffff00", name, "|ris |cff00ff00#136430|r")
					border = region
				elseif texture and s_match(texture, "[bB][oO][rR][dD][eE][rR]") then
					-- print("|cffffff00", name, "|ris |cff00ff00-TrackingBorder|r")
					border = region
				end
			end
		end
	end

	for _, child in next, children do
		local name = child:GetDebugName()
		local oType = child:GetObjectType()
		-- print("|cffffff00", name, "|r:", oType)

		if oType == "Frame" then
			if name and s_match(name, "[iI][cC][oO][nN]") then
				icon = child
			end
		elseif oType == "Button" then
			thl, ticon, tborder, tbg, tnormal, tpushed = HandleMinimapButton(child, true)
		end
	end

	normal = normal or tnormal
	pushed = pushed or tpushed
	hl = hl or thl
	icon = icon or ticon
	border = border or tborder
	bg = bg or tbg

	if not recursive then
		-- These aren't the dro- buttons you're looking for
		if not icon and not (normal and pushed) then
			ignoredButtons[button] = true

			return
		end

		handledButtons[button] = true

		local t = button == GameTimeFrame and "BIG" or "SMALL"
		local offset = button == GarrisonLandingPageMinimapButton and 0 or 8

		button:SetSize(unpack(TEXTURES[t].size))
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetFlattensRenderLayers(true)

		local mask = button:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetPoint("TOPLEFT", 6, -6)
		mask:SetPoint("BOTTOMRIGHT", -6, 6)
		button.MaskTexture = mask

		if hl then
			hl:ClearAllPoints()
			hl:SetAllPoints(button)
		end

		if normal and pushed then
			normal:SetDrawLayer("ARTWORK", 0)
			normal:ClearAllPoints()
			normal:SetPoint("TOPLEFT", offset, -offset)
			normal:SetPoint("BOTTOMRIGHT", -offset, offset)
			normal:AddMaskTexture(mask)
			button.NormalTexture = normal

			pushed:SetDrawLayer("ARTWORK", 0)
			pushed:ClearAllPoints()
			pushed:SetPoint("TOPLEFT", offset, -offset)
			pushed:SetPoint("BOTTOMRIGHT", -offset, offset)
			pushed:AddMaskTexture(mask)
			button.PushedTexture = pushed
		elseif icon then
			if icon:IsObjectType("Texture") then
				icon:SetDrawLayer("ARTWORK", 0)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", offset, -offset)
				icon:SetPoint("BOTTOMRIGHT", -offset, offset)
				icon:AddMaskTexture(mask)
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

		border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		border:SetTexCoord(unpack(TEXTURES[t].coords))
		border:SetDrawLayer("ARTWORK", 1)
		border:SetAllPoints(button)
		button.Border = border

		if not bg then
			bg = button:CreateTexture()
		end

		bg:SetColorTexture(M.COLORS.BLACK:GetRGB())
		bg:SetDrawLayer("BACKGROUND", 0)
		bg:SetAllPoints()
		bg:SetAlpha(0.8)
		bg:AddMaskTexture(mask)
		button.Background = bg

		return button
	else
		return hl, icon, border, bg, normal, pushed
	end
end

local function UpdateZoneInfo()
	Minimap.ZoneText:SetText(ZONE_COLORS[GetZonePVPInfo() or "other"]:WrapText(GetMinimapZoneText() or L["UNKNOWN"]))
end

local function CheckTexPoint(point, base)
	if point then
		return point >= base / 256 + 1 and base / 256 or point
	else
		return base / 256
	end
end

local function ScrollTexture(t, delay, offset)
	t.l = CheckTexPoint(t.l, 64) + offset
	t.r = CheckTexPoint(t.r, 192) + offset

	t:SetTexCoord(t.l, t.r, 0 / 128, 128 / 128)

	C_Timer.After(delay, function() ScrollTexture(t, DELAY, STEP) end)
end

local function Minimap_OnEnter(self)
	self.ZoneText:Show()
end

local function Minimap_OnLeave(self)
	self.ZoneText:Hide()
end

function MODULE.IsInit()
	return isInit
end

function MODULE.Init()
	if not isInit and C.db.char.minimap.enabled then
		if not IsAddOnLoaded("Blizzard_TimeManager") then
			LoadAddOn("Blizzard_TimeManager")
		end

		local holder = CreateFrame("Frame", "LSMinimapHolder", UIParent)
		holder:SetSize(332 / 2, 332 / 2)
		holder:SetPoint(unpack(C.db.profile.minimap[E.UI_LAYOUT].point))
		E:CreateMover(holder)

		Minimap:EnableMouseWheel()
		Minimap:SetParent(holder)
		Minimap:ClearAllPoints()
		Minimap:SetPoint("CENTER")
		Minimap:SetSize(146, 146)
		Minimap:RegisterEvent("ZONE_CHANGED")
		Minimap:RegisterEvent("ZONE_CHANGED_INDOORS")
		Minimap:RegisterEvent("ZONE_CHANGED_NEW_AREA")

		Minimap:HookScript("OnEvent", function(_, event)
			if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
				UpdateZoneInfo()
			end
		end)

		Minimap:SetScript("OnMouseWheel", function(_, direction)
			if direction > 0 then
				Minimap_ZoomIn()
			else
				Minimap_ZoomOut()
			end
		end)

		RegisterStateDriver(Minimap, "visibility", "[petbattle] hide; show")

		local border = Minimap:CreateTexture(nil, "BORDER")
		border:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap")
		border:SetTexCoord(1 / 512, 333 / 512, 1 / 512, 333 / 512)
		border:SetSize(332 / 2, 332 / 2)
		border:SetPoint("CENTER", 0, 0)

		for name, coords in next, WIDGETS do
			_G[name]:ClearAllPoints()
			_G[name]:SetParent(Minimap)
			_G[name]:SetPoint(unpack(coords))
		end

		for _, name in next, {
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
		} do
			E:ForceHide(_G[name])
		end

		-- Queue
		local queue = HandleMinimapButton(QueueStatusMinimapButton)
		queue.Background:SetAlpha(0)
		queue.Icon:SetAllPoints()
		QueueStatusFrame:ClearAllPoints()
		QueueStatusFrame:SetPoint("BOTTOMRIGHT", queue, "TOPLEFT", 8, -8)

		-- Calendar
		local calendar = HandleMinimapButton(GameTimeFrame)
		calendar:SetNormalFontObject("LS16Font_Outline")
		calendar:SetPushedTextOffset(1, -1)
		calendar.NormalTexture:SetTexture("")
		calendar.PushedTexture:SetTexture("")
		calendar.pendingCalendarInvites = 0

		calendar:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT", 4, -4)

			if self.pendingCalendarInvites > 0 then
				GameTooltip:AddLine(L["CALENDAR_PENDING_INVITES"])
			end

			GameTooltip:AddLine(L["TOGGLE_CALENDAR"])
			GameTooltip:Show()
		end)

		calendar:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		calendar:SetScript("OnEvent", function(self, event, ...)
			if event == "CALENDAR_UPDATE_PENDING_INVITES" or event == "PLAYER_ENTERING_WORLD" then
				local pendingCalendarInvites = CalendarGetNumPendingInvites()

				if pendingCalendarInvites > self.pendingCalendarInvites then
					if not CalendarFrame or (CalendarFrame and not CalendarFrame:IsShown()) then
						E:Blink(self.InvIndicator, nil, 0, 1)

						self.pendingCalendarInvites = pendingCalendarInvites
					end
				elseif pendingCalendarInvites == 0 then
					E:StopBlink(self.InvIndicator)
				end
			elseif event == "CALENDAR_EVENT_ALARM" then
				local title = ...
				local info = ChatTypeInfo["SYSTEM"]

				DEFAULT_CHAT_FRAME:AddMessage(L["CALENDAR_EVENT_ALARM_MESSAGE"]:format(title), info.r, info.g, info.b, info.id)
			end
		end)

		calendar:SetScript("OnClick", function(self)
			if self.InvIndicator.Blink and self.InvIndicator.Blink:IsPlaying() then
				E:StopBlink(self.InvIndicator, 1)

				self.pendingCalendarInvites = 0
			end

			ToggleCalendar()
		end)

		calendar:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed

			if self.elapsed > 1 then
				local _, _, day = CalendarGetDate()
				self:SetText(day)

				self.elapsed = 0
			end
		end)

		local indicator = calendar:CreateTexture(nil, "BACKGROUND", nil, 1)
		indicator:SetTexture("Interface\\Minimap\\HumanUITile-TimeIndicator", true)
		indicator:AddMaskTexture(calendar.MaskTexture)
		indicator:SetPoint("TOPLEFT", 6, -6)
		indicator:SetPoint("BOTTOMRIGHT", -6, 6)
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
		date:SetPoint("TOPLEFT", 9, -8)
		date:SetPoint("BOTTOMRIGHT", -8, 9)
		date:SetVertexColor(M.COLORS.WHITE:GetRGB())
		date:SetDrawLayer("BACKGROUND")
		date:SetJustifyH("CENTER")
		date:SetJustifyV("MIDDLE")

		-- Zone Text
		local zoneText = MinimapZoneText
		zoneText:SetFontObject("LS12Font_Shadow")
		zoneText:SetParent(Minimap)
		zoneText:SetWidth(0)
		zoneText:ClearAllPoints()
		zoneText:SetPoint("TOPLEFT", 2, 28)
		zoneText:SetPoint("TOPRIGHT", -2, 28)
		zoneText:Hide()
		Minimap.ZoneText = zoneText

		-- Clock
		local clock = TimeManagerClockButton
		clock:SetSize(104/ 2, 56 / 2)
		clock:SetHitRectInsets(0, 0, 0, 0)
		clock:SetScript("OnMouseUp", nil)
		clock:SetScript("OnMouseDown", nil)
		clock:SetHighlightTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons", "ADD")
		clock:GetHighlightTexture():SetTexCoord(106 / 256, 210 / 256, 90 / 256, 146 / 256)
		clock:SetPushedTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		clock:GetPushedTexture():SetBlendMode("ADD")
		clock:GetPushedTexture():SetTexCoord(1 / 256, 105 / 256, 147 / 256, 203 / 256)

		local bg, ticker
		bg, ticker, glow = clock:GetRegions()

		bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		bg:SetTexCoord(1 / 256, 105 / 256, 90 / 256, 146 / 256)

		ticker:ClearAllPoints()
		ticker:SetPoint("TOPLEFT", 8, -8)
		ticker:SetPoint("BOTTOMRIGHT", -8, 8)
		ticker:SetJustifyH("CENTER")
		ticker:SetJustifyV("MIDDLE")
		clock.Ticker = ticker

		glow:SetTexture("Interface\\AddOns\\ls_UI\\media\\minimap-buttons")
		glow:SetTexCoord(1 / 256, 105 / 256, 147 / 256, 203 / 256)

		-- Compass
		MinimapCompassTexture:SetParent(Minimap)
		MinimapCompassTexture:ClearAllPoints()
		MinimapCompassTexture:SetPoint("CENTER", 0, 0)

		-- Misc
		HandleMinimapButton(GarrisonLandingPageMinimapButton)
		HandleMinimapButton(MiniMapMailFrame)
		HandleMinimapButton(MiniMapTracking)
		HandleMinimapButton(MiniMapVoiceChatFrame)

		for _, child in next, {Minimap:GetChildren()} do
			child:SetFrameLevel(Minimap:GetFrameLevel() + 1)

			if child:IsObjectType("Button") and not (handledButtons[child] or ignoredButtons[child] or WIDGETS[child] or not child:GetName()) then
				HandleMinimapButton(child)
			end
		end

		C_Timer.NewTicker(5, function()
			for _, child in next, {Minimap:GetChildren()} do
				if child:IsObjectType("Button") and not (handledButtons[child] or ignoredButtons[child] or WIDGETS[child] or not child:GetName()) then
					child:SetFrameLevel(Minimap:GetFrameLevel() + 1)

					HandleMinimapButton(child)
				end
			end
		end)

		local h, m = GetGameTime()
		local s = (h * 60 + m) * 60
		local mult = m_floor(s / DELAY)

		ScrollTexture(indicator, (mult + 1) * DELAY - s, STEP * mult)

		UpdateZoneInfo()

		isInit = true

		MODULE:Update()
	end
end

function MODULE.Update()
	if isInit then
		local config = C.db.profile.minimap[E.UI_LAYOUT]

		if config.zone_text.mode == 0 then
			Minimap:SetScript("OnEnter", nil)
			Minimap:SetScript("OnLeave", nil)

			Minimap.ZoneText:Hide()
		elseif config.zone_text.mode == 1 then
			Minimap:SetScript("OnEnter", Minimap_OnEnter)
			Minimap:SetScript("OnLeave", Minimap_OnLeave)

			Minimap.ZoneText:Hide()
		elseif config.zone_text.mode == 2 then
			Minimap:SetScript("OnEnter", nil)
			Minimap:SetScript("OnLeave", nil)

			Minimap.ZoneText:Show()
		end
	end
end
