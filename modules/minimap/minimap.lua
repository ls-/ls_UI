local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Minimap")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_atan2 = _G.math.atan2
local m_cos = _G.math.cos
local m_deg = _G.math.deg
local m_floor = _G.math.floor
local m_rad = _G.math.rad
local m_sin = _G.math.sin
local next = _G.next
local s_match = _G.string.match
local select = _G.select
local unpack = _G.unpack

--[[ luacheck: globals
	CalendarFrame ChatTypeInfo CreateFrame DEFAULT_CHAT_FRAME DropDownList1 GameTimeFrame GameTooltip
	GarrisonLandingPageMinimapButton GarrisonLandingPageMinimapButton_UpdateIcon GetGameTime GetMinimapZoneText
	GetZonePVPInfo GuildInstanceDifficulty IsAddOnLoaded LoadAddOn Minimap Minimap_ZoomIn Minimap_ZoomOut
	MiniMapChallengeMode MinimapCompassTexture MiniMapInstanceDifficulty MiniMapMailFrame MiniMapTracking
	MiniMapTrackingBackground MiniMapTrackingButton MiniMapTrackingDropDown MiniMapTrackingIcon MinimapZoneText
	MinimapZoneTextButton QueueStatusFrame QueueStatusMinimapButton RegisterStateDriver TimeManagerClockButton
	ToggleCalendar UIDropDownMenu_GetCurrentDropDown UIParent

	LE_GARRISON_TYPE_8_0
]]

-- Blizz
local C_Calendar = _G.C_Calendar
local C_Garrison = _G.C_Garrison
local C_Timer = _G.C_Timer
local GetCursorPosition = _G.GetCursorPosition

-- Mine
local isInit = false

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

local BUTTONS = {
	MiniMapTrackingButton = 22.5,
	GameTimeFrame = 45,
	MiniMapMailFrame = 135,
	GarrisonLandingPageMinimapButton = 210,
	QueueStatusMinimapButton = 320,
}

local PVP_COLOR_MAP = {
	["arena"] = "hostile",
	["combat"] = "hostile",
	["contested"] = "contested",
	["friendly"] = "friendly",
	["hostile"] = "hostile",
	["sanctuary"] = "sanctuary",
}

local handledChildren = {}
local ignoredChildren = {}

local function hasTrackingBorderRegion(self)
	for i = 1, select("#", self:GetRegions()) do
		local region = select(i, self:GetRegions())

		if region:IsObjectType("Texture") then
			local texture = region:GetTexture()
			if texture and (texture == 136430 or s_match(texture, "[tT][rR][aA][cC][kK][iI][nN][gG][bB][oO][rR][dD][eE][rR]")) then
				return true
			end
		end
	end

	return false
end

local function isMinimapButton(self)
	if hasTrackingBorderRegion(self) then
		return true
	end

	for i = 1, select("#", self:GetChildren()) do
		if hasTrackingBorderRegion(select(i, self:GetChildren())) then
			return true
		end
	end

	return false
end

local function updateGarrisonButton(self)
	if C_Garrison.GetLandingPageGarrisonType() == LE_GARRISON_TYPE_8_0 then
		self.NormalTexture:RemoveMaskTexture(self.MaskTexture)
		self.PushedTexture:RemoveMaskTexture(self.MaskTexture)
		self.Border:Hide()
		self.Background:Hide()
	else
		self:SetSize(unpack(TEXTURES.SMALL.size))
		self.NormalTexture:RemoveMaskTexture(self.MaskTexture)
		self.PushedTexture:RemoveMaskTexture(self.MaskTexture)
		self.Border:Show()
		self.Background:Show()
	end
end

local function handleMinimapButton(button, recursive)
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	local pushed = button.GetPushedTexture and button:GetPushedTexture()
	local hl, icon, border, bg, thl, ticon, tborder, tbg, tnormal, tpushed
	-- print("====|cffff0000", button:GetDebugName(), "|r:", #children, #regions,"====")

	for i = 1, select("#", button:GetRegions()) do
		local region = select(i, button:GetRegions())
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
				elseif texture and (texture == 136430 or s_match(texture, "[tT][rR][aA][cC][kK][iI][nN][gG][bB][oO][rR][dD][eE][rR]")) then
					-- print("|cffffff00", name, "|ris |cff00ff00-TrackingBorder|r")
					border = region
				end
			end
		end
	end

	for i = 1, select("#", button:GetChildren()) do
		local child = select(i, button:GetChildren())
		local name = child:GetDebugName()
		local oType = child:GetObjectType()
		-- print("|cffffff00", name, "|r:", oType)

		if oType == "Frame" then
			if name and s_match(name, "[iI][cC][oO][nN]") then
				icon = child
			end
		elseif oType == "Button" then
			thl, ticon, tborder, tbg, tnormal, tpushed = handleMinimapButton(child, true)
			button.Button = child
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
			ignoredChildren[button] = true

			return button
		end

		handledChildren[button] = true

		local t = button == GameTimeFrame and "BIG" or "SMALL"
		local offset = button == GarrisonLandingPageMinimapButton and 0 or 8

		button:SetSize(unpack(TEXTURES[t].size))
		button:SetHitRectInsets(0, 0, 0, 0)
		button:SetFlattensRenderLayers(true)

		local mask = button:CreateMaskTexture()
		mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMaskSmall", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
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

		border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-buttons")
		border:SetTexCoord(unpack(TEXTURES[t].coords))
		border:SetDrawLayer("ARTWORK", 1)
		border:SetAllPoints(button)
		button.Border = border

		if not bg then
			bg = button:CreateTexture()
		end

		bg:SetAlpha(1)
		bg:SetColorTexture(0, 0, 0, 0.6)
		bg:SetDrawLayer("BACKGROUND", 0)
		bg:SetAllPoints()
		bg:AddMaskTexture(mask)
		button.Background = bg

		if button == GarrisonLandingPageMinimapButton then
			hooksecurefunc(button, "SetSize", updateGarrisonButton)
			GarrisonLandingPageMinimapButton_UpdateIcon(button)
		end

		return button
	else
		return hl, icon, border, bg, normal, pushed
	end
end

local function updatePosition(button, degrees)
	local angle = m_rad(degrees)
	button:SetPoint("CENTER", Minimap, "CENTER", m_cos(angle) * 80, m_sin(angle) * 80)
end

local function button_OnUpdate(self)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	local degrees = m_deg(m_atan2( py / scale - my, px / scale - mx)) % 360

	C.db.profile.minimap.buttons[self:GetName()] = degrees

	updatePosition(self, degrees)
end

local function button_OnDragStart(self)
	self.OnUpdate = self:GetScript("OnUpdate")
	self:SetScript("OnUpdate", button_OnUpdate)
end

local function button_OnDragStop(self)
	self:SetScript("OnUpdate", self.OnUpdate)
	self.OnUpdate = nil
end

local function getTooltipPoint(self)
	local quadrant = E:GetScreenQuadrant(self)
	local p, rP, x, y = "TOPLEFT", "BOTTOMRIGHT", -4, 4

	if quadrant == "BOTTOMLEFT" or quadrant == "BOTTOM" then
		p, rP, x, y = "BOTTOMLEFT", "TOPRIGHT", -4, -4
	elseif quadrant == "TOPRIGHT" or quadrant == "RIGHT" then
		p, rP, x, y = "TOPRIGHT", "BOTTOMLEFT", 4, 4
	elseif quadrant == "BOTTOMRIGHT" then
		p, rP, x, y = "BOTTOMRIGHT", "TOPLEFT", 4, -4
	end

	return p, rP, x, y
end

local function minimap_OnEnter(self)
	if self._config.zone_text.mode == 1 then
		self.Zone.Text:Show()
	end

	if self._config.clock.mode == 1 then
		self.Clock:Show()
	end

	if self._config.flag.mode == 1 then
		self.ChallengeModeFlag:SetParent(self)
		self.DifficultyFlag:SetParent(self)
		self.GuildDifficultyFlag:SetParent(self)
	end
end

local function minimap_OnLeave(self)
	if self._config.zone_text.mode ~= 2 then
		self.Zone.Text:Hide()
	end

	if self._config.clock.mode ~= 2 then
		self.Clock:Hide()
	end

	if self._config.flag.mode ~= 2 then
		self.ChallengeModeFlag:SetParent(E.HIDDEN_PARENT)
		self.DifficultyFlag:SetParent(E.HIDDEN_PARENT)
		self.GuildDifficultyFlag:SetParent(E.HIDDEN_PARENT)
	end
end

local function minimap_UpdateConfig(self)
	self._config = E:CopyTable(C.db.profile.minimap[E.UI_LAYOUT], self._config)
	self._config.color = E:CopyTable(C.db.profile.minimap.color, self._config.color)
end

local function minimap_UpdateBorderColor(self)
	if self._config.color.border then
		self.Border:SetVertexColor(E:GetRGB(C.db.profile.colors.zone[PVP_COLOR_MAP[GetZonePVPInfo()]] or C.db.profile.colors.zone.contested))
	else
		self.Border:SetVertexColor(1, 1, 1)
	end
end

local function minimap_UpdateZone(self)
	local config = self._config
	local zone = self.Zone

	if config.zone_text.mode == 0 then
		zone:ClearAllPoints()
		zone:Hide()
	elseif config.zone_text.mode == 1 or config.zone_text.mode == 2 then
		zone:Show()

		if config.zone_text.mode == 1 then
			zone.BG:Hide()
			zone.Border:Hide()
			zone.Text:Hide()
		else
			if config.zone_text.border then
				zone.BG:Show()
				zone.Border:Show()
			else
				zone.BG:Hide()
				zone.Border:Hide()
			end

			zone.Text:Show()
		end

		if config.zone_text.position == 0 then
			zone:ClearAllPoints()
			zone:SetPoint("BOTTOM", self, "TOP", 0, 12)
		else
			zone:ClearAllPoints()
			zone:SetPoint("TOP", self, "BOTTOM", 0, -12)
		end
	end

	if self._config.zone_text.mode == 1 or self._config.clock.mode == 1 or self._config.flag.mode == 1 then
		Minimap:SetScript("OnEnter", minimap_OnEnter)
		Minimap:SetScript("OnLeave", minimap_OnLeave)
	else
		Minimap:SetScript("OnEnter", nil)
		Minimap:SetScript("OnLeave", nil)
	end

	self:UpdateZoneColor()
end

local function minimap_UpdateZoneColor(self)
	if self._config.color.zone_text then
		self.Zone.Text:SetVertexColor(E:GetRGB(C.db.profile.colors.zone[PVP_COLOR_MAP[GetZonePVPInfo()]] or C.db.profile.colors.zone.contested))
	else
		self.Zone.Text:SetVertexColor(1, 1, 1)
	end
end

local function minimap_UpdateZoneText(self)
	self.Zone.Text:SetText(GetMinimapZoneText())
end

local function minimap_UpdateClock(self)
	local config = self._config
	local clock = Minimap.Clock

	if config.clock.mode == 0 then
		clock:ClearAllPoints()
		clock:Hide()
	elseif config.clock.mode == 1 or config.clock.mode == 2 then
		if config.clock.mode == 1 then
			clock:Hide()
		else
			clock:Show()
		end

		if config.clock.position == 0 then
			clock:ClearAllPoints()
			clock:SetPoint("BOTTOM", Minimap, "TOP", 0, -14)
		else
			clock:ClearAllPoints()
			clock:SetPoint("TOP", Minimap, "BOTTOM", 0, 14)
		end
	end

	if self._config.zone_text.mode == 1 or self._config.clock.mode == 1 or self._config.flag.mode == 1 then
		Minimap:SetScript("OnEnter", minimap_OnEnter)
		Minimap:SetScript("OnLeave", minimap_OnLeave)
	else
		Minimap:SetScript("OnEnter", nil)
		Minimap:SetScript("OnLeave", nil)
	end
end

local function minimap_UpdateFlag(self)
	local config = self._config
	local challengeModeFlag = self.ChallengeModeFlag
	local difficultyFlag = self.DifficultyFlag
	local guildDifficultyFlag = self.GuildDifficultyFlag

	if config.flag.mode == 0 then
		challengeModeFlag:ClearAllPoints()
		challengeModeFlag:SetParent(E.HIDDEN_PARENT)

		difficultyFlag:ClearAllPoints()
		difficultyFlag:SetParent(E.HIDDEN_PARENT)

		guildDifficultyFlag:ClearAllPoints()
		guildDifficultyFlag:SetParent(E.HIDDEN_PARENT)
	elseif config.flag.mode == 1 or config.flag.mode == 2 then
		if config.flag.mode == 1 then
			challengeModeFlag:SetParent(E.HIDDEN_PARENT)
			difficultyFlag:SetParent(E.HIDDEN_PARENT)
			guildDifficultyFlag:SetParent(E.HIDDEN_PARENT)
		else
			challengeModeFlag:SetParent(Minimap)
			difficultyFlag:SetParent(Minimap)
			guildDifficultyFlag:SetParent(Minimap)
		end

		if config.flag.position == 0 then
			challengeModeFlag:ClearAllPoints()
			challengeModeFlag:SetPoint("TOPLEFT", Minimap.Zone, "BOTTOMLEFT", 3, 4)

			difficultyFlag:ClearAllPoints()
			difficultyFlag:SetPoint("TOPLEFT", Minimap.Zone, "BOTTOMLEFT", 3, 4)

			guildDifficultyFlag:ClearAllPoints()
			guildDifficultyFlag:SetPoint("TOPLEFT", Minimap.Zone, "BOTTOMLEFT", 3, 5)
		elseif config.flag.position == 1 then
			challengeModeFlag:ClearAllPoints()
			challengeModeFlag:SetPoint("TOP", Minimap.Clock, "BOTTOM", 0, 11)

			difficultyFlag:ClearAllPoints()
			difficultyFlag:SetPoint("TOP", Minimap.Clock, "BOTTOM", 0, 11)

			guildDifficultyFlag:ClearAllPoints()
			guildDifficultyFlag:SetPoint("TOP", Minimap.Clock, "BOTTOM", -2, 12)
		else
			challengeModeFlag:ClearAllPoints()
			challengeModeFlag:SetPoint("TOP", Minimap, "BOTTOM", 0, 7)

			difficultyFlag:ClearAllPoints()
			difficultyFlag:SetPoint("TOP", Minimap, "BOTTOM", 0, 7)

			guildDifficultyFlag:ClearAllPoints()
			guildDifficultyFlag:SetPoint("TOP", Minimap, "BOTTOM", -2, 8)
		end
	end

	if self._config.zone_text.mode == 1 or self._config.clock.mode == 1 or self._config.flag.mode == 1 then
		Minimap:SetScript("OnEnter", minimap_OnEnter)
		Minimap:SetScript("OnLeave", minimap_OnLeave)
	else
		Minimap:SetScript("OnEnter", nil)
		Minimap:SetScript("OnLeave", nil)
	end
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
		E.Movers:Create(holder)

		Minimap:EnableMouseWheel()
		Minimap:ClearAllPoints()
		Minimap:SetParent(holder)
		Minimap:SetPoint("CENTER")
		Minimap:SetSize(146, 146)
		Minimap:RegisterEvent("ZONE_CHANGED")
		Minimap:RegisterEvent("ZONE_CHANGED_INDOORS")
		Minimap:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		Minimap:SetMaskTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")

		Minimap:HookScript("OnEvent", function(self, event)
			if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
				self:UpdateBorderColor()
				self:UpdateZoneColor()
				self:UpdateZoneText()
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

		local border = Minimap:CreateTexture(nil, "BORDER", nil, 1)
		border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap")
		border:SetTexCoord(1 / 1024, 333 / 1024, 1 / 512, 333 / 512)
		border:SetSize(332 / 2, 332 / 2)
		border:SetPoint("CENTER", 0, 0)
		E:SmoothColor(border)
		Minimap.Border = border

		local foreground = Minimap:CreateTexture(nil, "BORDER", nil, 3)
		foreground:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap")
		foreground:SetTexCoord(334 / 1024, 666 / 1024, 1 / 512, 333 / 512)
		foreground:SetSize(332 / 2, 332 / 2)
		foreground:SetPoint("CENTER", 0, 0)

		local glass = Minimap:CreateTexture(nil, "BORDER", nil, 2)
		glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap")
		glass:SetTexCoord(667 / 1024, 999 / 1024, 1 / 512, 333 / 512)
		glass:SetSize(332 / 2, 332 / 2)
		glass:SetPoint("CENTER", 0, 0)

		-- .Queue
		do
			local button = handleMinimapButton(QueueStatusMinimapButton)
			button:RegisterForDrag("LeftButton")
			button:SetParent(Minimap)
			button:ClearAllPoints()
			Minimap.Queue = button

			button:HookScript("OnEnter", function(self)
				local p, rP, x, y = getTooltipPoint(self)

				QueueStatusFrame:ClearAllPoints()
				QueueStatusFrame:SetPoint(p, self, rP, x, y)
			end)
			button:HookScript("OnClick", function(self)
				local menu = UIDropDownMenu_GetCurrentDropDown()
				if menu and menu == self.DropDown then
					local p, rP, x, y = getTooltipPoint(self)

					DropDownList1:ClearAllPoints()
					DropDownList1:SetPoint(p, self, rP, x, y)

					QueueStatusFrame:Hide()
				end
			end)
			button:SetScript("OnDragStart", button_OnDragStart)
			button:SetScript("OnDragStop", button_OnDragStop)

			button.Background:SetAlpha(0)
			button.Icon:SetAllPoints()
		end

		-- .Calendar
		do
			local DELAY = 337.5 -- 256 * 337.5 = 86400 = 24H
			local STEP = 0.00390625 -- 1 / 256

			local function checkTexPoint(point, base)
				if point then
					return point >= base / 256 + 1 and base / 256 or point
				else
					return base / 256
				end
			end

			local function scrollTexture(t, delay, offset)
				t.l = checkTexPoint(t.l, 64) + offset
				t.r = checkTexPoint(t.r, 192) + offset

				t:SetTexCoord(t.l, t.r, 0 / 128, 128 / 128)

				C_Timer.After(delay, function() scrollTexture(t, DELAY, STEP) end)
			end

			local button = handleMinimapButton(GameTimeFrame)
			button:RegisterForDrag("LeftButton")
			button:SetParent(Minimap)
			button:ClearAllPoints()
			button:SetNormalFontObject("LSFont16_Outline")
			button:SetPushedTextOffset(1, -1)
			Minimap.Calendar = button

			button:SetScript("OnEnter", function(self)
				local p, rP, x, y = getTooltipPoint(self)

				GameTooltip:SetOwner(self, "ANCHOR_NONE")
				GameTooltip:SetPoint(p, self, rP, x, y)
				GameTooltip:AddLine(L["CALENDAR"], 1, 1, 1)
				GameTooltip:AddLine(L["CALENDAR_TOGGLE_TOOLTIP"])

				if self.pendingCalendarInvites > 0 then
					GameTooltip:AddLine(L["CALENDAR_PENDING_INVITES_TOOLTIP"])
				end

				GameTooltip:Show()
			end)
			button:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			button:SetScript("OnEvent", function(self, event, ...)
				if event == "CALENDAR_UPDATE_PENDING_INVITES" or event == "PLAYER_ENTERING_WORLD" then
					local pendingCalendarInvites = C_Calendar.GetNumPendingInvites()

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
			button:SetScript("OnClick", function(self)
				if self.InvIndicator.Blink and self.InvIndicator.Blink:IsPlaying() then
					E:StopBlink(self.InvIndicator, 1)

					self.pendingCalendarInvites = 0
				end

				ToggleCalendar()
			end)
			button:SetScript("OnUpdate", function(self, elapsed)
				self.elapsed = (self.elapsed or 0) + elapsed

				if self.elapsed > 1 then
					local date = C_Calendar.GetDate()

					self:SetText(date.monthDay)

					self.elapsed = 0
				end
			end)
			button:SetScript("OnDragStart", button_OnDragStart)
			button:SetScript("OnDragStop", button_OnDragStop)

			button.NormalTexture:SetTexture("")
			button.PushedTexture:SetTexture("")
			button.pendingCalendarInvites = 0

			local indicator = button:CreateTexture(nil, "BACKGROUND", nil, 1)
			indicator:SetTexture("Interface\\Minimap\\HumanUITile-TimeIndicator", true)
			indicator:AddMaskTexture(button.MaskTexture)
			indicator:SetPoint("TOPLEFT", 6, -6)
			indicator:SetPoint("BOTTOMRIGHT", -6, 6)
			button.DayTimeIndicator = indicator

			local _, mark, glow, _, date = button:GetRegions()
			mark:SetDrawLayer("OVERLAY", 2)
			mark:SetTexCoord(7 / 128, 81 / 128, 7 / 128, 109 / 128)
			mark:SetSize(22, 30)
			mark:SetPoint("CENTER", 0, 0)
			mark:Show()
			mark:SetAlpha(0)
			button.InvIndicator = mark

			glow:SetTexture("")

			date:ClearAllPoints()
			date:SetPoint("TOPLEFT", 9, -8)
			date:SetPoint("BOTTOMRIGHT", -8, 9)
			date:SetVertexColor(1, 1, 1)
			date:SetDrawLayer("BACKGROUND")
			date:SetJustifyH("CENTER")
			date:SetJustifyV("MIDDLE")

			local h, m = GetGameTime()
			local s = (h * 60 + m) * 60
			local mult = m_floor(s / DELAY)

			scrollTexture(indicator, (mult + 1) * DELAY - s, STEP * mult)
		end

		-- .Zone
		do
			local frame = MinimapZoneTextButton
			frame:SetParent(Minimap)
			frame:SetFrameLevel(Minimap:GetFrameLevel())
			frame:SetSize(160, 16)
			frame:EnableMouse(false)
			Minimap.Zone = frame

			local bg = frame:CreateTexture(nil, "BACKGROUND")
			bg:SetColorTexture(0, 0, 0, 0.6)
			bg:SetAllPoints()
			bg:Hide()
			frame.BG = bg

			local border = E:CreateBorder(frame)
			border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
			border:SetSize(16)
			border:SetOffset(-6)
			border:Hide()
			frame.Border = border

			local text = MinimapZoneText
			text:SetFontObject("LSFont12_Shadow")
			text:SetSize(0, 0)
			text:ClearAllPoints()
			text:SetPoint("TOPLEFT", 2, 0)
			text:SetPoint("BOTTOMRIGHT", -2, 0)
			text:SetJustifyH("CENTER")
			text:SetJustifyV("MIDDLE")
			text:Hide()
			frame.Text = text

			ignoredChildren[frame] = true
		end

		-- .Clock
		do
			local button = TimeManagerClockButton
			button:SetFlattensRenderLayers(true)
			button:SetFrameLevel(Minimap:GetFrameLevel() + 2)
			button:SetSize(52, 28)
			button:SetHitRectInsets(0, 0, 0, 0)
			button:SetScript("OnMouseUp", nil)
			button:SetScript("OnMouseDown", nil)
			button:SetHighlightTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-buttons", "ADD")
			button:GetHighlightTexture():SetTexCoord(106 / 256, 210 / 256, 90 / 256, 146 / 256)
			button:SetPushedTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-buttons")
			button:GetPushedTexture():SetBlendMode("ADD")
			button:GetPushedTexture():SetTexCoord(1 / 256, 105 / 256, 147 / 256, 203 / 256)
			Minimap.Clock = button

			button:HookScript("OnEnter", function(self)
				if GameTooltip:IsOwned(self) then
					local p, rP, x, y = getTooltipPoint(self)

					GameTooltip:SetOwner(self, "ANCHOR_NONE")
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint(p, self, rP, x, y)
				end
			end)

			local bg, ticker, glow = button:GetRegions()

			bg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-buttons")
			bg:SetTexCoord(1 / 256, 105 / 256, 90 / 256, 146 / 256)

			ticker:ClearAllPoints()
			ticker:SetPoint("TOPLEFT", 8, -8)
			ticker:SetPoint("BOTTOMRIGHT", -8, 8)
			ticker:SetJustifyH("CENTER")
			ticker:SetJustifyV("MIDDLE")
			button.Ticker = ticker

			glow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-buttons")
			glow:SetTexCoord(1 / 256, 105 / 256, 147 / 256, 203 / 256)

			ignoredChildren[button] = true
		end

		-- .Garrison
		do
			local button = handleMinimapButton(GarrisonLandingPageMinimapButton)
			button:RegisterForDrag("LeftButton")
			button:SetParent(Minimap)
			button:ClearAllPoints()
			Minimap.Garrison = button

			button:HookScript("OnEnter", function(self)
				if GameTooltip:IsOwned(self) then
					local p, rP, x, y = getTooltipPoint(self)

					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint(p, self, rP, x, y)
				end
			end)
			button:SetScript("OnDragStart", button_OnDragStart)
			button:SetScript("OnDragStop", button_OnDragStop)
		end

		-- .Mail
		do
			local button = handleMinimapButton(MiniMapMailFrame)
			button:RegisterForDrag("LeftButton")
			button:SetParent(Minimap)
			button:ClearAllPoints()
			Minimap.Mail = button

			button:HookScript("OnEnter", function(self)
				if GameTooltip:IsOwned(self) then
					local p, rP, x, y = getTooltipPoint(self)

					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint(p, self, rP, x, y)
				end
			end)
			button:SetScript("OnDragStart", button_OnDragStart)
			button:SetScript("OnDragStop", button_OnDragStop)
		end

		-- .Tracking
		do
			MiniMapTrackingButton:SetParent(Minimap)
			MiniMapTrackingButton:ClearAllPoints()

			MiniMapTracking:SetParent(MiniMapTrackingButton)
			MiniMapTracking:SetAllPoints()
			MiniMapTrackingIcon:SetParent(MiniMapTrackingButton)
			MiniMapTrackingBackground:SetParent(MiniMapTrackingButton)

			local button = handleMinimapButton(MiniMapTrackingButton)
			button:RegisterForDrag("LeftButton")
			Minimap.Tracking = button

			button:HookScript("OnEnter", function(self)
				if GameTooltip:IsOwned(self) then
					local p, rP, x, y = getTooltipPoint(self)

					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint(p, self, rP, x, y)
				end
			end)
			button:HookScript("OnClick", function(self)
				local menu = UIDropDownMenu_GetCurrentDropDown()
				if menu and menu == MiniMapTrackingDropDown then
					local p, rP, x, y = getTooltipPoint(self)

					DropDownList1:ClearAllPoints()
					DropDownList1:SetPoint(p, self, rP, x, y)

					GameTooltip:Hide()
				end
			end)
			button:SetScript("OnDragStart", button_OnDragStart)
			button:SetScript("OnDragStop", button_OnDragStop)
		end

		-- .Compass
		MinimapCompassTexture:SetParent(Minimap)
		MinimapCompassTexture:ClearAllPoints()
		MinimapCompassTexture:SetPoint("CENTER", 0, 0)
		MinimapCompassTexture:SetSize(272, 272)
		Minimap.Compass = MinimapCompassTexture

		-- .ChallengeModeFlag, .DifficultyFlag, .GuildDifficultyFlag
		MiniMapChallengeMode:SetSize(38, 46)
		Minimap.ChallengeModeFlag = MiniMapChallengeMode

		Minimap.DifficultyFlag = MiniMapInstanceDifficulty
		Minimap.GuildDifficultyFlag = GuildInstanceDifficulty

		-- Misc
		for _, name in next, {
			"MinimapBackdrop",
			"MinimapBorder",
			"MinimapBorderTop",
			"MinimapCluster",
			"MiniMapRecordingButton",
			"MiniMapTrackingIconOverlay",
			"MiniMapVoiceChatFrame",
			"MiniMapWorldMapButton",
			"MinimapZoomIn",
			"MinimapZoomOut",
		} do
			E:ForceHide(_G[name])
		end

		for i = 1, select("#", Minimap:GetChildren()) do
			local child = select(i, Minimap:GetChildren())

			if not ignoredChildren[child] then
				child:SetFrameLevel(Minimap:GetFrameLevel() + 1)
			end

			if not (ignoredChildren[child] or handledChildren[child] or BUTTONS[child]) and isMinimapButton(child) then
				handleMinimapButton(child)
			else
				ignoredChildren[child] = true
			end
		end

		C_Timer.NewTicker(5, function()
			for i = 1, select("#", Minimap:GetChildren()) do
				local child = select(i, Minimap:GetChildren())

				if not (ignoredChildren[child] or handledChildren[child] or BUTTONS[child]) and isMinimapButton(child) then
					child:SetFrameLevel(Minimap:GetFrameLevel() + 1)

					handleMinimapButton(child)
				else
					ignoredChildren[child] = true
				end
			end
		end)

		Minimap.UpdateBorderColor = minimap_UpdateBorderColor
		Minimap.UpdateClock = minimap_UpdateClock
		Minimap.UpdateConfig = minimap_UpdateConfig
		Minimap.UpdateFlag = minimap_UpdateFlag
		Minimap.UpdateZone = minimap_UpdateZone
		Minimap.UpdateZoneColor = minimap_UpdateZoneColor
		Minimap.UpdateZoneText = minimap_UpdateZoneText

		isInit = true

		MODULE:Update()
	end
end

function MODULE.Update()
	if isInit then
		Minimap:UpdateConfig()
		Minimap:UpdateBorderColor()
		Minimap:UpdateClock()
		Minimap:UpdateFlag()
		Minimap:UpdateZone()

		for name, degrees in next, BUTTONS do
			updatePosition(_G[name], C.db.profile.minimap.buttons[name] or degrees)
		end
	end
end

function MODULE:GetMinimap()
	return Minimap
end
