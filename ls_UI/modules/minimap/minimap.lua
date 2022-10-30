local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:AddModule("Minimap")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_floor = _G.math.floor
local next = _G.next
local t_wipe = _G.table.wipe
local unpack = _G.unpack

-- Mine
local isInit = false

local zoneTypeToColor = {
	["arena"] = "hostile",
	["combat"] = "hostile",
	["contested"] = "contested",
	["friendly"] = "friendly",
	["hostile"] = "hostile",
	["sanctuary"] = "sanctuary",
}

local minimap_proto = {}

function minimap_proto:UpdateBorderColor()
	if self._config.color.border then
		self.Border:SetVertexColor((C.db.global.colors.zone[zoneTypeToColor[GetZonePVPInfo() or "contested"]]):GetRGB())
	else
		self.Border:SetVertexColor(1, 1, 1)
	end
end

function minimap_proto:OnEventHook(event)
	if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
		self:UpdateBorderColor()
	end
end

local function updateHybridMinimap()
	if C.db.profile.minimap.shape == "square" then
		HybridMinimap.CircleMask:SetTexture("Interface\\BUTTONS\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	else
		HybridMinimap.CircleMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	end

	HybridMinimap.MapCanvas:SetMaskTexture(HybridMinimap.CircleMask)
end

function minimap_proto:UpdateConfig()
	self._config = E:CopyTable(C.db.profile.minimap, self._config)

	MinimapCluster._config = t_wipe(MinimapCluster._config or {})
	MinimapCluster._config.fade = self._config.fade
end

local borderInfo = {
	[100] = {
		{1 / 1024, 433 / 1024, 1 / 512, 433 / 512}, -- outer
		{434 / 1024, 866 / 1024, 1 / 512, 433 / 512}, -- inner
		432 / 2,
	},
}

local flagBorderInfo = {
	["round"] = {97 / 512, 193 / 512, 1 / 256, 97 / 256},
	["square"] = {1 / 512, 97 / 512, 1 / 256, 97 / 256},
}

-- At odds with the fierce looking face...
local function theBodyIsRound()
	return "ROUND"
end

local function theBodyIsSquare()
	return "SQUARE"
end

function minimap_proto:UpdateLayout()
	local scale = self._config.scale
	local shape = self._config.shape
	local info = borderInfo[scale] or borderInfo[100]

	self.Border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-" .. shape .. "-" .. scale)
	self.Border:SetTexCoord(unpack(info[1]))
	self.Border:SetSize(info[3], info[3])

	self.Foreground:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-" .. shape .. "-" .. scale)
	self.Foreground:SetTexCoord(unpack(info[2]))
	self.Foreground:SetSize(info[3], info[3])

	self.DifficultyFlag.Border:SetTexCoord(unpack(flagBorderInfo[shape]))

	if shape == "round" then
		self:SetArchBlobRingScalar(1)
		self:SetQuestBlobRingScalar(1)
		self:SetTaskBlobRingScalar(1)
		self:SetMaskTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")

		self.Background:Hide()

		-- for LDBIcon-1.0
		GetMinimapShape = theBodyIsRound
	else
		self:SetArchBlobRingScalar(0)
		self:SetQuestBlobRingScalar(0)
		self:SetTaskBlobRingScalar(0)
		self:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")

		Minimap.Background:Show()

		-- for LDBIcon-1.0
		GetMinimapShape = theBodyIsSquare
	end

	MinimapCluster:SetSize(info[3] + 24, info[3] + 24)
	E.Movers:Get(MinimapCluster):UpdateSize()

	self:SetSize(info[3] - 22, info[3] - 22)
	self:ClearAllPoints()

	MinimapCluster.BorderTop:ClearAllPoints()
	MinimapCluster.BorderTop:SetPoint("LEFT", "Minimap", "LEFT", 1, 0)
	MinimapCluster.BorderTop:SetPoint("RIGHT", "Minimap", "RIGHT", -1, 0)

	if self._config.flip then
		self:SetPoint("CENTER", "MinimapCluster", "CENTER", 0, 8, true)

		MinimapCluster.BorderTop:SetPoint("BOTTOM", "MinimapCluster", "BOTTOM", 0, 1)

		MinimapCluster.MailFrame:ClearAllPoints()
		MinimapCluster.MailFrame:SetPoint("BOTTOMLEFT", MinimapCluster.Tracking, "TOPLEFT", -1, 2)
	else
		self:SetPoint("CENTER", "MinimapCluster", "CENTER", 0, -8, true)

		MinimapCluster.BorderTop:SetPoint("TOP", "MinimapCluster", "TOP", 0, -1)

		MinimapCluster.MailFrame:ClearAllPoints()
		MinimapCluster.MailFrame:SetPoint("TOPLEFT", MinimapCluster.Tracking, "BOTTOMLEFT", -1, -2)
	end

	if HybridMinimap then
		updateHybridMinimap()
	end
end

function minimap_proto:UpdateRotation()
	SetCVar("rotateMinimap", self._config.rotate)
end

local flag_proto = {
	["events"] = {
		"GROUP_ROSTER_UPDATE",
		"INSTANCE_GROUP_SIZE_CHANGED",
		"PARTY_MEMBER_DISABLE",
		"PARTY_MEMBER_ENABLE",
		"PLAYER_DIFFICULTY_CHANGED",
		"UPDATE_INSTANCE_INFO",
	},
}

do
	local GUILD_ACHIEVEMENTS_ELIGIBLE = _G.GUILD_ACHIEVEMENTS_ELIGIBLE:gsub("(%%.-[sd])", "|cffffffff%1|r")

	local flagInfo = {
		["lfr"] = {193 / 512, 257 / 512, 1 / 256, 65 / 256},
		["normal"] = {257 / 512, 321 / 512, 1 / 256, 65 / 256},
		["heroic"] = {321 / 512, 385 / 512, 1 / 256, 65 / 256},
		["mythic"] = {385 / 512, 449 / 512, 1 / 256, 65 / 256},
		["challenge"] = {193 / 512, 257 / 512, 65 / 256, 129 / 256},
	}

	function flag_proto:RegisterForEvents()
		for _, event in next, self.events do
			self:RegisterEvent(event)
		end
	end

	function flag_proto:OnEvent()
		self:Update()
	end

	function flag_proto:OnEnter()
		if self.instanceName then
			local p, rP, x, y = E:GetTooltipPoint(self)
			if p == "TOPRIGHT" then
				x, y = 24, 24
			end

			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint(p, self, rP, x, y)
			GameTooltip:SetText(self.instanceName, 1, 1, 1)
			GameTooltip:AddLine(self.difficultyName)

			local inGroup, _, numGuildRequired = InGuildParty()
			if inGroup then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(GUILD_ACHIEVEMENTS_ELIGIBLE:format(numGuildRequired, self.maxPlayers, GetGuildInfo()), nil, nil, nil, true)

			end

			GameTooltip:Show()
		end
	end

	function flag_proto:OnLeave()
		GameTooltip:Hide()
	end

	function flag_proto:UpdateFlag(t)
		self.Icon:SetTexCoord(unpack(flagInfo[t]))
	end

	function flag_proto:Update()
		self.instanceName = nil
		self.difficultyName = nil
		self.maxPlayers = nil
		self:Hide()

		local instanceName, instanceType, difficultyID, _, maxPlayers = GetInstanceInfo()
		if instanceType == "raid" or instanceType == "party" then
			local difficultyName, _, isHeroic, isChallengeMode, displayHeroic, displayMythic, _, isLFR = GetDifficultyInfo(difficultyID)

			self.instanceName = instanceName
			self.difficultyName = difficultyName
			self.maxPlayers = maxPlayers

			if isChallengeMode then
				self:UpdateFlag("challenge")
			elseif isLFR then
				self:UpdateFlag("lfr")
			elseif displayMythic then
				self:UpdateFlag("mythic")
			elseif isHeroic or displayHeroic then
				self:UpdateFlag("heroic")
			else
				self:UpdateFlag("normal")
			end

			self:Show()
		elseif instanceType == "scenario" then
			local difficultyName, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficultyID)
			if not (isHeroic or displayHeroic or displayMythic) then return end

			self.instanceName = instanceName
			self.difficultyName = difficultyName
			self.maxPlayers = maxPlayers

			if displayMythic then
				self:UpdateFlag("mythic")
			elseif isHeroic or displayHeroic then
				self:UpdateFlag("heroic")
			end

			self:Show()
		end
	end
end

function MODULE:IsInit()
	return isInit
end

function MODULE:Init()
	if not isInit and PrC.db.profile.minimap.enabled then
		if not IsAddOnLoaded("Blizzard_TimeManager") then
			LoadAddOn("Blizzard_TimeManager")
		end

		MinimapCluster:ClearAllPoints()
		MinimapCluster:SetPoint(unpack(C.db.profile.minimap.point))
		E.Movers:Create(MinimapCluster)

		Mixin(Minimap, minimap_proto)

		Minimap:RegisterEvent("ZONE_CHANGED")
		Minimap:RegisterEvent("ZONE_CHANGED_INDOORS")
		Minimap:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		Minimap:HookScript("OnEvent", Minimap.OnEventHook)

		local textureParent = CreateFrame("Frame", nil, Minimap)
		textureParent:SetFrameLevel(Minimap:GetFrameLevel() + 1)
		textureParent:SetPoint("BOTTOMRIGHT", 0, 0)
		textureParent:SetPoint("TOPLEFT", 0, 0)
		Minimap.TextureParent = textureParent

		local border = textureParent:CreateTexture(nil, "BORDER", nil, 1)
		border:SetPoint("CENTER", 0, 0)
		E:SmoothColor(border)
		Minimap.Border = border

		local foreground = textureParent:CreateTexture(nil, "BORDER", nil, 3)
		foreground:SetPoint("CENTER", 0, 0)
		Minimap.Foreground = foreground

		local background = Minimap:CreateTexture(nil, "BACKGROUND", nil, -7)
		background:SetAllPoints(Minimap)
		background:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
		background:SetHorizTile(true)
		background:SetVertTile(true)
		background:Hide()
		Minimap.Background = background

		local DELAY = 337.5 -- 256 * 337.5 = 86400 = 24H
		-- local DELAY = 0.05 -- 256 * 337.5 = 86400 = 24H
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

			t:SetTexCoord(t.l, t.r, 40 / 128, 68 / 128) -- 64, 14

			C_Timer.After(delay, function() scrollTexture(t, DELAY, STEP) end)
		end

		local mask = MinimapCluster.BorderTop:CreateMaskTexture()
		mask:SetTexture("Interface\\AddOns\\ls_UI\\assets\\daytime-mask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
		mask:SetPoint("TOPRIGHT", -1, -1)
		mask:SetPoint("BOTTOMLEFT", MinimapCluster.BorderTop, "BOTTOMRIGHT", -65, 2)

		local indicator = MinimapCluster.BorderTop:CreateTexture(nil, "BACKGROUND", nil, 1)
		indicator:SetTexture("Interface\\Minimap\\HumanUITile-TimeIndicator", true)
		indicator:SetPoint("TOPRIGHT", -1, -1)
		indicator:SetPoint("BOTTOMLEFT", MinimapCluster.BorderTop, "BOTTOMRIGHT", -65, 2)
		indicator:AddMaskTexture(mask)

		local h, m = GetGameTime()
		local s = (h * 60 + m) * 60
		local mult = m_floor(s / DELAY)

		scrollTexture(indicator, (mult + 1) * DELAY - s, STEP * mult)

		E:ForceHide(MinimapCluster.InstanceDifficulty)

		local difficultyFlag = Mixin(CreateFrame("Frame", nil, MinimapCluster), flag_proto)
		difficultyFlag:SetFrameLevel(Minimap:GetFrameLevel() + 2)
		difficultyFlag:RegisterForEvents()
		difficultyFlag:SetScript("OnEvent", difficultyFlag.OnEvent)
		difficultyFlag:SetScript("OnEnter", difficultyFlag.OnEnter)
		difficultyFlag:SetScript("OnLeave", difficultyFlag.OnLeave)
		difficultyFlag:SetMouseClickEnabled(false)
		difficultyFlag:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -0, -1)
		difficultyFlag:SetSize(48, 48)
		difficultyFlag:Hide()
		Minimap.DifficultyFlag = difficultyFlag

		local flagBorder = difficultyFlag:CreateTexture(nil, "OVERLAY")
		flagBorder:SetAllPoints()
		flagBorder:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-flags")
		difficultyFlag.Border = flagBorder

		local flagIcon = difficultyFlag:CreateTexture(nil, "BACKGROUND")
		flagIcon:SetPoint("TOPRIGHT", -5, -4)
		flagIcon:SetSize(32, 32)
		flagIcon:SetTexture("Interface\\AddOns\\ls_UI\\assets\\minimap-flags")
		difficultyFlag.Icon = flagIcon

		hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", function()
			Minimap:UpdateConfig()
			Minimap:UpdateLayout()
		end)

		hooksecurefunc(MinimapCluster, "SetRotateMinimap", function()
			Minimap:UpdateConfig()
			Minimap:UpdateRotation()
		end)

		hooksecurefunc(Minimap, "SetPoint", function(_, _, _, _, _, _, shouldIgnore)
			if not shouldIgnore then
				Minimap:UpdateLayout()
			end
		end)

		MinimapCompassTexture:SetTexture(0)

		MinimapCluster.BorderTop:SetWidth(0)
		MinimapCluster.BorderTop:SetHeight(17)

		MinimapCluster.Tracking:SetSize(18, 17)
		MinimapCluster.Tracking.Button:SetSize(14, 14)
		MinimapCluster.Tracking.Button:ClearAllPoints()
		MinimapCluster.Tracking.Button:SetPoint("TOPLEFT", 1, -1)

		MinimapCluster.ZoneTextButton:SetSize(0, 16)
		MinimapCluster.ZoneTextButton:ClearAllPoints()
		MinimapCluster.ZoneTextButton:SetPoint("TOPLEFT", MinimapCluster.BorderTop, "TOPLEFT", 4, 0)
		MinimapCluster.ZoneTextButton:SetPoint("TOPRIGHT", MinimapCluster.BorderTop, "TOPRIGHT", -48, 0)

		MinimapZoneText:SetSize(0, 16)
		MinimapZoneText:ClearAllPoints()
		MinimapZoneText:SetPoint("LEFT", 2, 1)
		MinimapZoneText:SetPoint("RIGHT", -2, 1)
		MinimapZoneText:SetJustifyH("LEFT")
		MinimapZoneText:SetJustifyV("MIDDLE")

		TimeManagerClockButton:ClearAllPoints()
		TimeManagerClockButton:SetPoint("TOPRIGHT", MinimapCluster.BorderTop, "TOPRIGHT", -4, 0)

		TimeManagerClockTicker:SetJustifyH("RIGHT")
		TimeManagerClockTicker:SetJustifyV("MIDDLE")
		TimeManagerClockTicker:SetFontObject("GameFontNormal")
		TimeManagerClockTicker:SetTextColor(1, 1, 1)
		TimeManagerClockTicker:SetSize(40, 16)
		TimeManagerClockTicker:ClearAllPoints()
		TimeManagerClockTicker:SetPoint("CENTER", 0, 1)

		GameTimeFrame:ClearAllPoints()
		GameTimeFrame:SetPoint("TOPLEFT", MinimapCluster.BorderTop, "TOPRIGHT", 4, 0)

		for _, obj in next, {
				Minimap.ZoomIn,
				Minimap.ZoomOut,
				Minimap.ZoomHitArea,
		} do
			E:ForceHide(obj)
		end

		if not HybridMinimap then
			E:AddOnLoadTask("Blizzard_HybridMinimap", updateHybridMinimap)
		end

		E:SetUpFading(MinimapCluster)

		isInit = true

		self:Update()
	end
end

function MODULE:Update()
	if isInit then
		Minimap:UpdateConfig()
		Minimap:UpdateLayout()
		Minimap:UpdateBorderColor()
		Minimap.DifficultyFlag:Update()
		MinimapCluster:UpdateFading()
	end
end

function MODULE:GetMinimap()
	return Minimap
end
