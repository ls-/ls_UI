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
local m_max = _G.math.max
local m_min = _G.math.min
local m_rad = _G.math.rad
local m_sin = _G.math.sin
local next = _G.next
local s_match = _G.string.match
local select = _G.select
local t_insert = _G.table.insert
local t_sort = _G.table.sort
local t_wipe = _G.table.wipe
local unpack = _G.unpack

--[[ luacheck: globals
	CalendarFrame ChatTypeInfo CreateFrame DropDownList1 GameTimeFrame GameTooltip GarrisonLandingPageMinimapButton
	GarrisonLandingPageMinimapButton_UpdateIcon GetGameTime GetMinimapShape GetMinimapZoneText GetZonePVPInfo
	GuildInstanceDifficulty IsAddOnLoaded LoadAddOn LSMinimapButtonCollection LSMinimapHolder Minimap Minimap_ZoomIn
	Minimap_ZoomOut MiniMapChallengeMode MinimapCompassTexture MiniMapInstanceDifficulty MiniMapMailFrame
	MiniMapTracking MiniMapTrackingBackground MiniMapTrackingButton MiniMapTrackingDropDown MiniMapTrackingIcon
	MinimapZoneText MinimapZoneTextButton nop QueueStatusFrame QueueStatusMinimapButton RegisterStateDriver
	TimeManagerClockButton ToggleCalendar UIDropDownMenu_GetCurrentDropDown UIParent

	DEFAULT_CHAT_FRAME LE_GARRISON_TYPE_8_0
]]

-- Blizz
local C_Calendar = _G.C_Calendar
local C_DateAndTime = _G.C_DateAndTime
local C_Garrison = _G.C_Garrison
local C_Timer = _G.C_Timer
local GetCursorPosition = _G.GetCursorPosition

-- Mine
local isInit = false
local isSquare = false

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

local BLIZZ_BUTTONS = {
	["MiniMapTracking"] = true,
	["QueueStatusMinimapButton"] = true,
	["MiniMapMailFrame"] = true,
	["GameTimeFrame"] = true,
	["GarrisonLandingPageMinimapButton"] = true,
}

local PVP_COLOR_MAP = {
	["arena"] = "hostile",
	["combat"] = "hostile",
	["contested"] = "contested",
	["friendly"] = "friendly",
	["hostile"] = "hostile",
	["sanctuary"] = "sanctuary",
}

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
	if BLIZZ_BUTTONS[self] then
		return true
	end

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

local handledChildren = {}
local ignoredChildren = {}

local function handleButton(button, isRecursive)
	if button == GarrisonLandingPageMinimapButton then
		return button
	end

	-- print("====|cff00ccff", button:GetDebugName(), "|r:====")
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	local pushed = button.GetPushedTexture and button:GetPushedTexture()
	local hl, icon, border, bg, thl, ticon, tborder, tbg, tnormal, tpushed

	for i = 1, select("#", button:GetRegions()) do
		local region = select(i, button:GetRegions())
		if region:IsObjectType("Texture") then
			local name = region:GetDebugName()
			local texture = region:GetTexture()
			local layer = region:GetDrawLayer()
			-- print("|cffffff00", name, "|r:", texture, layer)

			if not normal then
				if layer == "ARTWORK" or layer == "BACKGROUND" then
					if button.icon and region == button.icon then
						-- print("|cffffff00", name, "|ris |cff00ff00.icon|r")
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
				-- print("|cffffff00", name, "|ris |cff00ff00HIGHLIGHT|r")
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
			thl, ticon, tborder, tbg, tnormal, tpushed = handleButton(child, true)
			button.Button = child
			button.Button:SetAllPoints(button)
		end
	end

	normal = normal or tnormal
	pushed = pushed or tpushed
	hl = hl or thl
	icon = icon or ticon
	border = border or tborder
	bg = bg or tbg

	if isRecursive then
		return hl, icon, border, bg, normal, pushed
	else
		-- These aren't the dro- buttons you're looking for
		if not (icon or normal) then
			-- print("  |cffff2222", "BAILING OUT!", "|r")
			ignoredChildren[button] = true

			return button
		end

		-- local t = button == GameTimeFrame and "BIG" or "SMALL"
		local offset = 8

		button:SetSize(36, 36)
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
			hl:AddMaskTexture(mask)
			button.HighlightTexture = hl
		end

		if pushed then
			pushed:SetDrawLayer("ARTWORK", 0)
			pushed:ClearAllPoints()
			pushed:SetPoint("TOPLEFT", offset, -offset)
			pushed:SetPoint("BOTTOMRIGHT", -offset, offset)
			pushed:AddMaskTexture(mask)
			button.PushedTexture = pushed
		end

		if normal then
			normal:SetDrawLayer("ARTWORK", 0)
			normal:ClearAllPoints()
			normal:SetPoint("TOPLEFT", offset, -offset)
			normal:SetPoint("BOTTOMRIGHT", -offset, offset)
			normal:AddMaskTexture(mask)
			button.NormalTexture = normal
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
		border:SetTexCoord(90 / 256, 162 / 256, 1 / 256, 73 / 256)
		-- border:SetTexture(136430)
		-- border:SetTexCoord(1 / 64, 37 / 64, 0 / 64, 36 / 64)
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

		return button
	end
end

local buttonData = {}
local collectedButtons = {}
local consolidatedButtons = {}
local hiddenButtons = {}
local watchedButtons = {}

local buttonOrder = {
	["GameTimeFrame"] = 1,
	["GarrisonLandingPageMinimapButton"] = 2,
	["MiniMapTrackingButton"] = 3,
	["MiniMapMailFrame"] = 4,
	["QueueStatusMinimapButton"] = 5,
}

local function sortFunc(a, b)
	local aName, bName = a:GetDebugName(), b:GetDebugName()
	if buttonOrder[aName] and buttonOrder[bName] then
		return buttonOrder[aName] < buttonOrder[bName]
	elseif buttonOrder[aName] and not buttonOrder[bName] then
		return true
	elseif not buttonOrder[aName] and buttonOrder[bName] then
		return false
	else
		return aName > bName
	end
end

local function consolidateButtons()
	t_wipe(consolidatedButtons)

	for collectedButton in next, collectedButtons do
		if not hiddenButtons[collectedButton] then
			t_insert(consolidatedButtons, collectedButton)
		end
	end

	if #consolidatedButtons > 0 then
		t_sort(consolidatedButtons, sortFunc)

		local maxRows = m_floor(#consolidatedButtons / 8 + 0.9)

		LSMinimapButtonCollection.Shadow:SetSize(64 + 64 * maxRows, 64 + 64 * maxRows)

		for i, button in next, consolidatedButtons do
			local row = m_floor(i / 8 + 0.9)
			local angle = m_rad(90 - 45 * ((i - 1) % 8) + (30 * (row - 1))) -- 45 = 360 / 8

			button.AlphaIn:SetStartDelay(0.02 * (i - 1))
			button.AlphaOut:SetStartDelay(0.02 * (i - 1))

			button:ClearAllPoints_()
			button:SetPoint_("CENTER", LSMinimapButtonCollection, "CENTER",
			m_cos(angle) * (16 + 32 * row),
			m_sin(angle) * (16 + 32 * row))

			if not LSMinimapButtonCollection.isShown then
				button:Hide_()
			end
		end
	end
end

local function getPosition(scale, px, py)
	if not (px or py) then
		return 225
	end

	local mx, my = Minimap:GetCenter()
	scale = scale or Minimap:GetEffectiveScale()

	return m_deg(m_atan2( py / scale - my, px / scale - mx)) % 360
end

local function hookHide(self)
	if collectedButtons[self] then
		hiddenButtons[self] = true

		consolidateButtons()
	end
end

local function hookShow(self)
	if collectedButtons[self] then
		hiddenButtons[self] = false

		consolidateButtons()
	end
end

local function hookSetShown(self, state)
	if collectedButtons[self] then
		hiddenButtons[self] = state

		consolidateButtons()
	end
end

local function collectButton(button)
	if collectedButtons[button] or button == LSMinimapButtonCollection then
		return
	end

	button:SetFrameLevel(Minimap:GetFrameLevel() + 4)

	buttonData[button] = {
		OnDragStart = button:GetScript("OnDragStart"),
		OnDragStop = button:GetScript("OnDragStop"),
		position = getPosition(1, button:GetCenter()),
	}

	button:SetScript("OnDragStart", nil)
	button:SetScript("OnDragStop", nil)
	button:RegisterForDrag(false)

	-- some addon devs use strong voodoo to implement dragging/moving
	button.ClearAllPoints_ = button.ClearAllPoints
	button.SetPoint_ = button.SetPoint

	if not button:GetAttribute("ls-hooked") then
		button.Hide_ = button.Hide
		button.Show_ = button.Show

		hooksecurefunc(button, "Hide", hookHide)
		hooksecurefunc(button, "Show", hookShow)
		hooksecurefunc(button, "SetShown", hookSetShown)

		button:SetAttribute("ls-hooked", true)
	end

	hiddenButtons[button] = not button:IsShown()

	if not BLIZZ_BUTTONS[button:GetName()] then
		button.ClearAllPoints = nop
		button.SetPoint = nop
	end

	if not button.AlphaIn then
		local anim = LSMinimapButtonCollection.AGIn:CreateAnimation("Alpha")
		anim:SetOrder(2)
		anim:SetTarget(button)
		anim:SetFromAlpha(0)
		anim:SetToAlpha(1)
		anim:SetDuration(0.08)
		button.AlphaIn = anim
	else
		button.AlphaIn:SetParent(LSMinimapButtonCollection.AGIn)
		button.AlphaIn:SetOrder(2)
	end

	if not button.AlphaOut then
		local anim = LSMinimapButtonCollection.AGOut:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetTarget(button)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetDuration(0.08)
		button.AlphaOut = anim
	else
		button.AlphaOut:SetParent(LSMinimapButtonCollection.AGOut)
		button.AlphaOut:SetOrder(1)
	end

	collectedButtons[button] = true

	consolidateButtons()
end

local function releaseButton(button)
	if not collectedButtons[button] or button == LSMinimapButtonCollection then
		return
	end

	button:SetAlpha(1)
	button:SetFrameLevel(Minimap:GetFrameLevel() + 2)

	if buttonData[button].OnDragStart then
		button:SetScript("OnDragStart", buttonData[button].OnDragStart)
		button:SetScript("OnDragStop", buttonData[button].OnDragStop)
		button:RegisterForDrag("LeftButton")
	end

	if button.ClearAllPoints == nop then
		button.ClearAllPoints = button.ClearAllPoints_
		button.SetPoint = button.SetPoint_
	end

	button.AlphaIn:SetParent(LSMinimapButtonCollection.AGDisabled)
	button.AlphaOut:SetParent(LSMinimapButtonCollection.AGDisabled)

	if not hiddenButtons[button] then
		button:Show_()
	end

	button.ClearAllPoints_ = nil
	button.SetPoint_ = nil

	collectedButtons[button] = nil

	consolidateButtons()
end

local function updatePosition(button, degrees)
	local angle = m_rad(degrees)
	local w = Minimap:GetWidth() / 2 + 5
	local h = Minimap:GetHeight() / 2 + 5

	if isSquare then
		button:SetPoint("CENTER", Minimap, "CENTER",
			m_max(-w, m_min(m_cos(angle) * (1.4142135623731 * w - 10), w)), -- m_sqrt(2 * w ^ 2) = m_sqrt(2) * w = 1.4142135623731 * w
			m_max(-h, m_min(m_sin(angle) * (1.4142135623731 * h - 10), h))
		)
	else
		button:SetPoint("CENTER", Minimap, "CENTER",
			m_cos(angle) * w,
			m_sin(angle) * h
		)
	end
end

local function button_OnUpdate(self)
	local degrees = getPosition(nil, GetCursorPosition())

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

	if self._config.flag.mode ~= 2 then
		self.ChallengeModeFlag:SetParent(E.HIDDEN_PARENT)
		self.DifficultyFlag:SetParent(E.HIDDEN_PARENT)
		self.GuildDifficultyFlag:SetParent(E.HIDDEN_PARENT)
	end
end

local function minimap_UpdateConfig(self)
	self._config = E:CopyTable(C.db.profile.minimap[E.UI_LAYOUT], self._config)
	self._config.buttons = E:CopyTable(C.db.profile.minimap.buttons, self._config.buttons)
	self._config.collect = E:CopyTable(C.db.profile.minimap.collect, self._config.collect)
	self._config.color = E:CopyTable(C.db.profile.minimap.color, self._config.color)
	self._config.size = C.db.profile.minimap.size
end

local function minimap_UpdateBorderColor(self)
	if self._config.color.border then
		local color = C.db.global.colors.zone[PVP_COLOR_MAP[GetZonePVPInfo()]] or C.db.global.colors.zone.contested

		self.Border:SetVertexColor(E:GetRGB(color))

		if self.SepLeft then
			self.SepLeft:SetVertexColor(E:GetRGB(color))
			self.SepRight:SetVertexColor(E:GetRGB(color))
			self.SepMiddle:SetVertexColor(E:GetRGB(color))
		end
	else
		self.Border:SetVertexColor(1, 1, 1)

		if self.SepLeft then
			self.SepLeft:SetVertexColor(1, 1, 1)
			self.SepRight:SetVertexColor(1, 1, 1)
			self.SepMiddle:SetVertexColor(1, 1, 1)
		end
	end
end

local function minimap_UpdateZoneColor(self)
	if self._config.color.zone_text then
		self.Zone.Text:SetVertexColor(E:GetRGB(C.db.global.colors.zone[PVP_COLOR_MAP[GetZonePVPInfo()]] or C.db.global.colors.zone.contested))
	else
		self.Zone.Text:SetVertexColor(1, 1, 1)
	end
end

local function minimap_UpdateZoneText(self)
	self.Zone.Text:SetText(GetMinimapZoneText())
end

local function minimap_UpdateZone(self)
	if not isSquare then
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
				zone.Glass:Hide()
				zone.Text:Hide()
			else
				if config.zone_text.border then
					zone.BG:Show()
					zone.Border:Show()
					zone.Glass:Show()
				else
					zone.BG:Hide()
					zone.Border:Hide()
					zone.Glass:Hide()
				end

				zone.Text:Show()
			end
		end
	else
		self.Zone.Glass:Show()
	end

	self:UpdateZoneColor()
end

local function minimap_UpdateClock(self)
	if not isSquare then
		local config = self._config
		local clock = self.Clock

		if config.clock.enabled then
			if config.clock.position == 0 then
				clock:ClearAllPoints()
				clock:SetPoint("BOTTOM", self, "TOP", 0, -14)
			else
				clock:ClearAllPoints()
				clock:SetPoint("TOP", self, "BOTTOM", 0, 14)
			end

			clock:Show()
		else
			clock:ClearAllPoints()
			clock:Hide()
		end
	end
end

local function minimap_UpdateFlag(self)
	if not isSquare then
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
				challengeModeFlag:SetParent(self)
				difficultyFlag:SetParent(self)
				guildDifficultyFlag:SetParent(self)
			end

			if config.flag.position == 0 then
				challengeModeFlag:ClearAllPoints()
				challengeModeFlag:SetPoint("TOPLEFT", self.Zone, "BOTTOMLEFT", 3, 4)

				difficultyFlag:ClearAllPoints()
				difficultyFlag:SetPoint("TOPLEFT", self.Zone, "BOTTOMLEFT", 3, 4)

				guildDifficultyFlag:ClearAllPoints()
				guildDifficultyFlag:SetPoint("TOPLEFT", self.Zone, "BOTTOMLEFT", 3, 5)
			elseif config.flag.position == 1 then
				challengeModeFlag:ClearAllPoints()
				challengeModeFlag:SetPoint("TOP", self.Clock, "BOTTOM", 0, 11)

				difficultyFlag:ClearAllPoints()
				difficultyFlag:SetPoint("TOP", self.Clock, "BOTTOM", 0, 11)

				guildDifficultyFlag:ClearAllPoints()
				guildDifficultyFlag:SetPoint("TOP", self.Clock, "BOTTOM", -2, 12)
			else
				challengeModeFlag:ClearAllPoints()
				challengeModeFlag:SetPoint("TOP", self, "BOTTOM", 0, 7)

				difficultyFlag:ClearAllPoints()
				difficultyFlag:SetPoint("TOP", self, "BOTTOM", 0, 7)

				guildDifficultyFlag:ClearAllPoints()
				guildDifficultyFlag:SetPoint("TOP", self, "BOTTOM", -2, 8)
			end
		end
	end
end

local function minimap_UpdateScripts(self)
	if not isSquare and	(self._config.zone_text.mode == 1 or self._config.flag.mode == 1) then
		self:SetScript("OnEnter", minimap_OnEnter)
		self:SetScript("OnLeave", minimap_OnLeave)
	else
		self:SetScript("OnEnter", nil)
		self:SetScript("OnLeave", nil)
	end
end

local function minimap_UpdateSize(self)
	if isSquare then
		Minimap:SetSize(self._config.size, self._config.size)

		LSMinimapHolder:SetSize(self._config.size, self._config.size + 20)
		E.Movers:Get("LSMinimapHolder"):UpdateSize()
	else
		Minimap:SetSize(146, 146)

		LSMinimapHolder:SetSize(166, 166 + 20)
		E.Movers:Get("LSMinimapHolder"):UpdateSize()
	end
end

local function minimap_UpdateButtons(self)
	local config = self._config

	if config.collect.enabled then
		LSMinimapButtonCollection:Show()
		updatePosition(LSMinimapButtonCollection, config.buttons["LSMinimapButtonCollection"])
	else
		LSMinimapButtonCollection.isShown = false
		LSMinimapButtonCollection:Hide()
		LSMinimapButtonCollection.Shadow:SetScale(0.001)
	end

	if config.collect.enabled and config.collect.calendar then
		collectButton(GameTimeFrame)
	else
		releaseButton(GameTimeFrame)
		updatePosition(GameTimeFrame, config.buttons["GameTimeFrame"])
	end

	if config.collect.enabled and config.collect.garrison then
		collectButton(GarrisonLandingPageMinimapButton)
	else
		releaseButton(GarrisonLandingPageMinimapButton)
		updatePosition(GarrisonLandingPageMinimapButton, config.buttons["GarrisonLandingPageMinimapButton"])
	end

	if config.collect.enabled and config.collect.mail then
		collectButton(MiniMapMailFrame)
	else
		releaseButton(MiniMapMailFrame)
		updatePosition(MiniMapMailFrame, config.buttons["MiniMapMailFrame"])
	end

	if config.collect.enabled and config.collect.queue then
		collectButton(QueueStatusMinimapButton)
	else
		releaseButton(QueueStatusMinimapButton)
		updatePosition(QueueStatusMinimapButton, config.buttons["QueueStatusMinimapButton"])
	end

	if config.collect.enabled and config.collect.tracking then
		collectButton(MiniMapTrackingButton)
	else
		releaseButton(MiniMapTrackingButton)
		updatePosition(MiniMapTrackingButton, config.buttons["MiniMapTrackingButton"])
	end

	if config.collect.enabled then
		for button in next, watchedButtons do
			if not collectedButtons[button] then
				collectButton(button)
			end
		end
	else
		for button in next, watchedButtons do
			if collectedButtons[button] then
				releaseButton(button)
				updatePosition(button, buttonData[button].position)
			end
		end
	end
end

function MODULE:IsInit()
	return isInit
end

function MODULE:IsSquare()
	return isSquare
end

function MODULE:Init()
	if not isInit and C.db.char.minimap.enabled then
		if not IsAddOnLoaded("Blizzard_TimeManager") then
			LoadAddOn("Blizzard_TimeManager")
		end

		isSquare = C.db.char.minimap[E.UI_LAYOUT].square

		-- for LDBIcon-1.0
		function GetMinimapShape()
			return isSquare and "SQUARE" or "ROUND"
		end

		local level = Minimap:GetFrameLevel()

		local holder = CreateFrame("Frame", "LSMinimapHolder", UIParent)
		holder:SetSize(1, 1)
		holder:SetPoint(unpack(C.db.profile.minimap[E.UI_LAYOUT].point))
		E.Movers:Create(holder)

		Minimap:EnableMouseWheel()
		Minimap:ClearAllPoints()
		Minimap:SetParent(holder)
		Minimap:RegisterEvent("ZONE_CHANGED")
		Minimap:RegisterEvent("ZONE_CHANGED_INDOORS")
		Minimap:RegisterEvent("ZONE_CHANGED_NEW_AREA")

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

		local textureParent = CreateFrame("Frame", nil, Minimap)
		textureParent:SetFrameLevel(level + 1)
		textureParent:SetPoint("BOTTOMRIGHT", 0, 0)
		Minimap.TextureParent = textureParent

		ignoredChildren[textureParent] = true

		if isSquare then
			Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
			Minimap:SetPoint("BOTTOM", 0, 0)

			textureParent:SetPoint("TOPLEFT", 0, 20)

			local bg = Minimap:CreateTexture(nil, "BACKGROUND")
			bg:SetColorTexture(0.1, 0.1, 0.1)
			bg:SetPoint("TOPLEFT", 0, 20)
			bg:SetPoint("BOTTOMRIGHT", 0, 0)

			local border = E:CreateBorder(textureParent)
			border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
			border:SetOffset(-6)
			border:SetSize(16)
			Minimap.Border = border

			local left = textureParent:CreateTexture(nil, "OVERLAY", nil, 2)
			left:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
			left:SetTexCoord(1 / 64, 17 / 64, 11 / 32, 23 / 32)
			left:SetSize(16 / 2, 12 / 2)
			left:SetPoint("BOTTOMLEFT", Minimap, "TOPLEFT", 0, -2)
			Minimap.SepLeft = left

			local right = textureParent:CreateTexture(nil, "OVERLAY", nil, 2)
			right:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
			right:SetTexCoord(18 / 64, 34 / 64, 11 / 32, 23 / 32)
			right:SetSize(16 / 2, 12 / 2)
			right:SetPoint("BOTTOMRIGHT", Minimap, "TOPRIGHT", 0, -2)
			Minimap.SepRight = right

			local mid = textureParent:CreateTexture(nil, "OVERLAY", nil, 2)
			mid:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", "REPEAT", "REPEAT")
			mid:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
			mid:SetHorizTile(true)
			mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
			mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)
			Minimap.SepMiddle = mid
		else
			Minimap:SetMaskTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
			Minimap:SetPoint("BOTTOM", 0, 10)

			textureParent:SetPoint("TOPLEFT", 0, 0)

			local border = textureParent:CreateTexture(nil, "BORDER", nil, 1)
			border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap")
			border:SetTexCoord(1 / 1024, 333 / 1024, 1 / 512, 333 / 512)
			border:SetSize(332 / 2, 332 / 2)
			border:SetPoint("CENTER", 0, 0)
			E:SmoothColor(border)
			Minimap.Border = border

			local foreground = textureParent:CreateTexture(nil, "BORDER", nil, 3)
			foreground:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap")
			foreground:SetTexCoord(334 / 1024, 666 / 1024, 1 / 512, 333 / 512)
			foreground:SetSize(332 / 2, 332 / 2)
			foreground:SetPoint("CENTER", 0, 0)

			local glass = textureParent:CreateTexture(nil, "BORDER", nil, 2)
			glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap")
			glass:SetTexCoord(667 / 1024, 999 / 1024, 1 / 512, 333 / 512)
			glass:SetSize(332 / 2, 332 / 2)
			glass:SetPoint("CENTER", 0, 0)
		end

		-- .Collection
		do
			local button = CreateFrame("Button", "LSMinimapButtonCollection", Minimap)
			button:SetFrameLevel(level + 3)
			button:RegisterForDrag("LeftButton")
			button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
			button:SetScript("OnDragStart", button_OnDragStart)
			button:SetScript("OnDragStop", button_OnDragStop)
			Minimap.Collection = button

			button:SetScript("OnEnter", function(self)
				if C.db.profile.minimap.collect.tooltip then
					local p, rP, x, y = getTooltipPoint(self)

					GameTooltip:SetOwner(self, "ANCHOR_NONE")
					GameTooltip:SetPoint(p, self, rP, x, y)
					GameTooltip:AddLine(L["MINIMAP_BUTTONS"], 1, 1, 1)
					GameTooltip:AddLine(L["MINIMAP_BUTTONS_TOOLTIP"])
					GameTooltip:Show()
				end
			end)
			button:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			local border = button:CreateTexture(nil, "OVERLAY")
			border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

			local background = button:CreateTexture(nil, "BACKGROUND")
			background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

			local icon = button:CreateTexture(nil, "ARTWORK")
			icon:SetTexture("Interface\\LFGFRAME\\WaitAnim")
			icon:SetTexCoord(64 / 128, 128 / 128, 64 / 128, 128 / 128)
			button.Icon = icon

			handleButton(button)

			local shadow = button:CreateTexture(nil, "BACKGROUND")
			shadow:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
			shadow:SetVertexColor(0, 0, 0)
			shadow:SetPoint("CENTER")
			shadow:SetAlpha(0.6)
			shadow:SetScale(0.001)
			button.Shadow = shadow

			local agIn = button:CreateAnimationGroup()
			button.AGIn = agIn

			agIn:SetScript("OnPlay", function()
				shadow:SetScale(1)

				for i = 1, #consolidatedButtons do
					consolidatedButtons[i]:SetAlpha(0)
					consolidatedButtons[i]:Show_()
				end
			end)
			agIn:SetScript("OnStop", function()
				shadow:SetScale(1)

				for i = 1, #consolidatedButtons do
					consolidatedButtons[i]:SetAlpha(1)
				end
			end)
			agIn:SetScript("OnFinished", function()
				shadow:SetScale(1)

				for i = 1, #consolidatedButtons do
					consolidatedButtons[i]:SetAlpha(1)
				end
			end)

			local agOut = button:CreateAnimationGroup()
			button.AGOut = agOut

			agOut:SetScript("OnPlay", function()
				shadow:SetScale(1)

				for i = 1, #consolidatedButtons do
					consolidatedButtons[i]:SetAlpha(1)
				end
			end)
			agOut:SetScript("OnStop", function()
				shadow:SetScale(0.001)

				for i = 1, #consolidatedButtons do
					consolidatedButtons[i]:SetAlpha(0)
					consolidatedButtons[i]:Hide_()
				end
			end)
			agOut:SetScript("OnFinished", function()
				shadow:SetScale(0.001)

				for i = 1, #consolidatedButtons do
					consolidatedButtons[i]:SetAlpha(0)
					consolidatedButtons[i]:Hide_()
				end
			end)

			local anim = agIn:CreateAnimation("Scale")
			anim:SetTarget(shadow)
			anim:SetOrder(1)
			anim:SetFromScale(0.001, 0.001)
			anim:SetToScale(1, 1)
			anim:SetDuration(0.08)
			button.ScaleIn = anim

			anim = agOut:CreateAnimation("Scale")
			anim:SetTarget(shadow)
			anim:SetOrder(2)
			anim:SetToScale(0.001, 0.001)
			anim:SetFromScale(1, 1)
			anim:SetDuration(0.08)
			button.ScaleOut = anim

			button.AGDisabled = button:CreateAnimationGroup()

			button:SetScript("OnClick", function(self)
				if not self.isShown then
					agOut:Stop()
					agIn:Play()

					self.isShown = true
				else
					agIn:Stop()
					agOut:Play()

					self.isShown = false
				end
			end)

			ignoredChildren[button] = true
		end

		-- .Queue
		do
			local button = handleButton(QueueStatusMinimapButton)
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

			local button = handleButton(GameTimeFrame)
			button:SetSize(44, 44)
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
					local date = C_DateAndTime.GetCurrentCalendarTime()

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
			frame:SetFrameLevel(level)
			frame:EnableMouse(false)
			frame:ClearAllPoints()
			Minimap.Zone = frame

			local text = MinimapZoneText
			text:SetFontObject("LSFont12_Shadow")
			text:SetDrawLayer("OVERLAY")
			text:SetSize(0, 0)
			text:ClearAllPoints()
			text:SetPoint("TOPLEFT", 2, 0)
			text:SetPoint("BOTTOMRIGHT", -2, 1)
			text:SetJustifyH("CENTER")
			text:SetJustifyV("MIDDLE")
			frame.Text = text

			local glass = frame:CreateTexture(nil, "OVERLAY", nil, 0)
			glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
			glass:SetAllPoints()
			glass:Hide()
			frame.Glass = glass

			if isSquare then
				frame:SetPoint("TOPLEFT", textureParent, "TOPLEFT", 0, 0)
				frame:SetPoint("BOTTOMRIGHT", textureParent, "TOPRIGHT", 0, -18)
			else
				frame:SetPoint("TOPLEFT", textureParent, "TOPLEFT", -8, 30)
				frame:SetPoint("BOTTOMRIGHT", textureParent, "TOPRIGHT", 8, 12)

				local border = E:CreateBorder(frame)
				border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
				border:SetSize(16)
				border:SetOffset(-6)
				border:Hide()
				frame.Border = border

				local bg = frame:CreateTexture(nil, "BACKGROUND")
				bg:SetColorTexture(0, 0, 0, 0.66)
				bg:SetAllPoints()
				bg:Hide()
				frame.BG = bg

				text:Hide()
			end

			ignoredChildren[frame] = true
		end

		-- .Clock
		do
			local button = TimeManagerClockButton
			button:SetFlattensRenderLayers(true)
			button:SetFrameLevel(level + 2)
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

			if isSquare then
				button:ClearAllPoints()
				button:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", -4, 14)
			end

			ignoredChildren[button] = true
		end

		-- .Garrison
		do
			local button = handleButton(GarrisonLandingPageMinimapButton)
			button:RegisterForDrag("LeftButton")
			button:SetParent(Minimap)
			button:ClearAllPoints()
			hooksecurefunc(button, "SetPoint", function(self, _, parent)
				if parent == "MinimapBackdrop" then
					self:ClearAllPoints()
					updatePosition(self, C.db.profile.minimap.buttons["GarrisonLandingPageMinimapButton"])
				end
			end)
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
			local button = handleButton(MiniMapMailFrame)
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

			local button = handleButton(MiniMapTrackingButton)
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
		MinimapCompassTexture:SetParent(textureParent)
		MinimapCompassTexture:ClearAllPoints()
		MinimapCompassTexture:SetPoint("CENTER", 0, 0)
		MinimapCompassTexture:SetSize(272, 272)
		MinimapCompassTexture:SetScale(1)
		Minimap.Compass = MinimapCompassTexture

		-- .ChallengeModeFlag, .DifficultyFlag, .GuildDifficultyFlag
		MiniMapChallengeMode:SetSize(38, 46)
		Minimap.ChallengeModeFlag = MiniMapChallengeMode

		Minimap.DifficultyFlag = MiniMapInstanceDifficulty
		Minimap.GuildDifficultyFlag = GuildInstanceDifficulty

		if isSquare then
			MiniMapChallengeMode:SetParent(Minimap)
			MiniMapChallengeMode:ClearAllPoints()
			MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 7, 4)

			MiniMapInstanceDifficulty:SetParent(Minimap)
			MiniMapInstanceDifficulty:ClearAllPoints()
			MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 7, 5)

			GuildInstanceDifficulty:SetParent(Minimap)
			GuildInstanceDifficulty:ClearAllPoints()
			GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 7, 5)
		end

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

		local function handleChildren()
			local shouldCollect = C.db.profile.minimap.collect.enabled

			for i = 1, select("#", Minimap:GetChildren()) do
				local child = select(i, Minimap:GetChildren())
				if not ignoredChildren[child] then
					child:SetFrameLevel(level + 2)

					if not handledChildren[child] and isMinimapButton(child) then
						handleButton(child)

						watchedButtons[child] = true

						if shouldCollect then
							collectButton(child)
						end
					end

					ignoredChildren[child] = true
				end
			end
		end

		handleChildren()
		C_Timer.NewTicker(5, handleChildren)

		Minimap.UpdateBorderColor = minimap_UpdateBorderColor
		Minimap.UpdateButtons = minimap_UpdateButtons
		Minimap.UpdateClock = minimap_UpdateClock
		Minimap.UpdateConfig = minimap_UpdateConfig
		Minimap.UpdateFlag = minimap_UpdateFlag
		Minimap.UpdateScripts = minimap_UpdateScripts
		Minimap.UpdateSize = minimap_UpdateSize
		Minimap.UpdateZone = minimap_UpdateZone
		Minimap.UpdateZoneColor = minimap_UpdateZoneColor
		Minimap.UpdateZoneText = minimap_UpdateZoneText

		isInit = true

		self:Update()
	end
end

function MODULE:Update()
	if isInit then
		Minimap:UpdateConfig()
		Minimap:UpdateSize()
		Minimap:UpdateBorderColor()
		Minimap:UpdateButtons()
		Minimap:UpdateClock()
		Minimap:UpdateFlag()
		Minimap:UpdateZone()
		Minimap:UpdateScripts()
	end
end

function MODULE:GetMinimap()
	return Minimap
end
