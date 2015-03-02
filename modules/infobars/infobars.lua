local _, ns = ...
local E, M = ns.E, ns.M

local COLORS = ns.M.colors

ns.infobars = {}

local INFOBAR_INFO = {
	Location = {
		infobar_type = "Frame",
		length = "Long",
	},
	Clock = {
		infobar_type = "Button",
		length = "Short",
	},
}

local function lsLocationInfoBar_OnEnter(self)
	local pvpType, _, factionName = GetZonePVPInfo()
	local x, y = GetPlayerMapPosition("player")
	local coords
	local zoneName = GetZoneText()
	local subzoneName = GetSubZoneText()
	if subzoneName == zoneName then
		subzoneName = ""
	end
	if x and y and x ~= 0 and y ~= 0 then
		coords = format("%.1f / %.1f", x * 100, y * 100)
	end
  	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
	GameTooltip:AddLine(zoneName, 1, 1, 1)
	if pvpType == "sanctuary" then
		GameTooltip:AddLine(subzoneName, unpack(COLORS.blue))
		GameTooltip:AddLine(SANCTUARY_TERRITORY, unpack(COLORS.blue))
	elseif pvpType == "arena" then
		GameTooltip:AddLine(subzoneName, unpack(COLORS.red))
		GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, unpack(COLORS.red))
	elseif pvpType == "friendly" then
		GameTooltip:AddLine(subzoneName, unpack(COLORS.green))
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), unpack(COLORS.green))
	elseif pvpType == "hostile" then
		GameTooltip:AddLine(subzoneName, unpack(COLORS.red))
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), unpack(COLORS.red))
	elseif pvpType == "contested" then
		GameTooltip:AddLine(subzoneName, unpack(COLORS.yellow))
		GameTooltip:AddLine(CONTESTED_TERRITORY, unpack(COLORS.yellow))
	elseif pvpType == "combat" then
		GameTooltip:AddLine(subzoneName, unpack(COLORS.red))
		GameTooltip:AddLine(COMBAT_ZONE, unpack(COLORS.red))
	else
		GameTooltip:AddLine(subzoneName, unpack(COLORS.yellow))
	end
	if coords then
		GameTooltip:AddLine(coords)
	end
	GameTooltip:Show()
end

local function lsLocationInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 0.2
		self.text:SetText(GetMinimapZoneText())
		local pvpType = GetZonePVPInfo()
		if pvpType == "sanctuary" then
			self.filling:SetVertexColor(unpack(COLORS.blue))
		elseif pvpType == "arena" then
			self.filling:SetVertexColor(unpack(COLORS.red))
		elseif pvpType == "friendly" then
			self.filling:SetVertexColor(unpack(COLORS.green))
		elseif pvpType == "hostile" then
			self.filling:SetVertexColor(unpack(COLORS.red))
		elseif pvpType == "contested" then
			self.filling:SetVertexColor(unpack(COLORS.yellow))
		else
			self.filling:SetVertexColor(unpack(COLORS.yellow))
		end
		if GameTooltip:IsOwned(self) then
			lsLocationInfoBar_OnEnter(self)
		end
	end
end

local function lsClockInfoBar_Initialize()
	lsClockInfoBar:RegisterForClicks("LeftButtonUp")
end

local function lsClockInfoBar_OnClick(...)
	TimeManager_Toggle()
end

local function lsClockInfoBar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
		GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true),
		COLORS.yellow[1], COLORS.yellow[2], COLORS.yellow[3], 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true),
		COLORS.yellow[1], COLORS.yellow[2], COLORS.yellow[3], 1, 1, 1)
	GameTooltip:Show()
end

local function lsClockInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 1
		self.text:SetText(GameTime_GetTime(true))
		if GameTooltip:IsOwned(self) then
			lsClockInfoBar_OnEnter(self)
		end
		if TimeManagerClockButton.alarmFiring then
			self.filling:SetVertexColor(unpack(COLORS.red))
		else
			self.filling:SetVertexColor(unpack(COLORS.black))
		end
	end
end

function ns.lsInfobars_Initialize()
	for ib, ibdata in next, INFOBAR_INFO do
		local ibar = CreateFrame(ibdata.infobar_type, "ls"..ib.."InfoBar", UIParent, "lsInfoBarButtonTemplate-"..ibdata.length)
		ibar:SetFrameStrata("LOW")
		ibar:SetFrameLevel(1)

		ns.infobars[strlower(ib)] = ibar
	end

	for ib, ibar in next, ns.infobars do
		ibar:SetPoint(unpack(ns.C.infobars[ib].point))
	end

	lsLocationInfoBar:SetScript("OnEnter", lsLocationInfoBar_OnEnter)
	lsLocationInfoBar:SetScript("OnUpdate", lsLocationInfoBar_OnUpdate)

	lsClockInfoBar_Initialize()
	lsClockInfoBar:SetScript("OnClick", lsClockInfoBar_OnClick)
	lsClockInfoBar:SetScript("OnEnter", lsClockInfoBar_OnEnter)
	lsClockInfoBar:SetScript("OnUpdate", lsClockInfoBar_OnUpdate)
end
