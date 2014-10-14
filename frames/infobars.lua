local _, ns = ...
local ibcolors = ns.M.colors.infobar

ns.infobars = {}

local INFOBAR_INFO = {
	Location = {
		infobar_type = "Frame",
		length = "Long",
	},
	Memory = {
		infobar_type = "Button",
		length = "Short",
	},
	FPS = {
		infobar_type = "Frame",
		length = "Short",
	},
	Latency = {
		infobar_type = "Frame",
		length = "Short",
	},
	Bag = {
		infobar_type = "Button",
		length = "Short",
	},
	Clock = {
		infobar_type = "Button",
		length = "Short",
	},
	Mail = {
		infobar_type = "Frame",
		length = "Short",
	},
}

local function oUF_LSLocationInfoBar_OnEnter(self)
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
		GameTooltip:AddLine(subzoneName, unpack(ibcolors.blue))
		GameTooltip:AddLine(SANCTUARY_TERRITORY, unpack(ibcolors.blue))
	elseif pvpType == "arena" then
		GameTooltip:AddLine(subzoneName, unpack(ibcolors.red))
		GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, unpack(ibcolors.red))
	elseif pvpType == "friendly" then
		GameTooltip:AddLine(subzoneName, unpack(ibcolors.green))
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), unpack(ibcolors.green))
	elseif pvpType == "hostile" then
		GameTooltip:AddLine(subzoneName, unpack(ibcolors.red))
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), unpack(ibcolors.red))
	elseif pvpType == "contested" then
		GameTooltip:AddLine(subzoneName, unpack(ibcolors.yellow))
		GameTooltip:AddLine(CONTESTED_TERRITORY, unpack(ibcolors.yellow))
	elseif pvpType == "combat" then
		GameTooltip:AddLine(subzoneName, unpack(ibcolors.red))
		GameTooltip:AddLine(COMBAT_ZONE, unpack(ibcolors.red))
	else
		GameTooltip:AddLine(subzoneName, unpack(ibcolors.yellow))
	end
	if coords then
		GameTooltip:AddLine(coords)
	end
	GameTooltip:Show()
end

local function oUF_LSLocationInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 0.2
		self.text:SetText(GetMinimapZoneText())
		local pvpType = GetZonePVPInfo()
		if pvpType == "sanctuary" then
			self.filling:SetVertexColor(unpack(ibcolors.blue))
		elseif pvpType == "arena" then
			self.filling:SetVertexColor(unpack(ibcolors.red))
		elseif pvpType == "friendly" then
			self.filling:SetVertexColor(unpack(ibcolors.green))
		elseif pvpType == "hostile" then
			self.filling:SetVertexColor(unpack(ibcolors.red))
		elseif pvpType == "contested" then
			self.filling:SetVertexColor(unpack(ibcolors.yellow))
		else
			self.filling:SetVertexColor(unpack(ibcolors.yellow))
		end
		if GameTooltip:IsOwned(self) then
			oUF_LSLocationInfoBar_OnEnter(self)
		end
	end
end

local function oUF_LSMemoryInfoBar_Initialize()
	oUF_LSMemoryInfoBar.usedMemory = 0
	oUF_LSMemoryInfoBar.activeAddons = {}
end

local function oUF_LSMemoryInfoBar_OnClick(self)
	UpdateAddOnMemoryUsage()
	collectgarbage()
	self.updateInterval = 2
end

local function oUF_LSMemoryInfoBar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
	GameTooltip:AddLine(lsMEMORY..":")
	sort(self.activeAddons, function(a, b)
		if a and b then
			return a[2] > b[2]
		end
	end)
	for i = 1, #self.activeAddons do
		if self.activeAddons[i][3] then
			local r = self.activeAddons[i][2] / self.usedMemory * 3
			local g = 2 - r
			GameTooltip:AddDoubleLine(self.activeAddons[i][1], format("%.3f MB",
				self.activeAddons[i][2] / 1000), 1, 1, 1, r, g, 0)
		end
	end
	GameTooltip:Show()
end

local function oUF_LSMemoryInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 10
		self.usedMemory = 0
		UpdateAddOnMemoryUsage()
		for i = 1, GetNumAddOns() do
			self.activeAddons[i] = self.activeAddons[i] or {}
			self.activeAddons[i][1] = select(2, GetAddOnInfo(i))
			self.activeAddons[i][2] = GetAddOnMemoryUsage(i)
			self.activeAddons[i][3] = IsAddOnLoaded(i)
			self.usedMemory = self.usedMemory + self.activeAddons[i][2]
		end
		self.text:SetText(format("%.1f MB", self.usedMemory / 1000))
		if GameTooltip:IsOwned(self) then
			oUF_LSMemoryInfoBar_OnEnter(self)
		end
	end
end


local function oUF_LSFPSInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 0.2
		local fps = GetFramerate()
		if fps > 35 then
			self.filling:SetVertexColor(unpack(ibcolors.green))
		elseif fps > 20 then
			self.filling:SetVertexColor(unpack(ibcolors.yellow))
		else
			self.filling:SetVertexColor(unpack(ibcolors.red))
		end
		self.text:SetText(floor(fps).." "..FPS_ABBR)
	end
end

local function oUF_LSLatencyInfoBar_OnEnter(self)
	_, _, latencyHome, latencyWorld = GetNetStats()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
	GameTooltip:AddLine(lsLATENCY..":")
	GameTooltip:AddLine(format(lsHOME..": %d "..MILLISECONDS_ABBR, latencyHome), 1, 1, 1)
	GameTooltip:AddLine(format(lsWORLD..": %d "..MILLISECONDS_ABBR, latencyWorld), 1, 1, 1)
	GameTooltip:Show()
end

local function oUF_LSLatencyInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 10
		local latency = select(4, GetNetStats())
		if latency > PERFORMANCEBAR_MEDIUM_LATENCY then
			self.filling:SetVertexColor(unpack(ibcolors.red))
		elseif latency > PERFORMANCEBAR_LOW_LATENCY then
			self.filling:SetVertexColor(unpack(ibcolors.yellow))
		else
			self.filling:SetVertexColor(unpack(ibcolors.green))
		end
		self.text:SetText(latency.." "..MILLISECONDS_ABBR)
		if GameTooltip:IsOwned(self) then
			oUF_LSLatencyInfoBar_OnEnter(self)
		end
	end
end


local function oUF_LSBagInfoBar_Initialize()
	oUF_LSBagInfoBar:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	oUF_LSBagInfoBar:RegisterEvent("BAG_UPDATE")
	if not InCombatLockdown() then
		CharacterBag3Slot:Hide()
		CharacterBag2Slot:Hide()
		CharacterBag1Slot:Hide()
		CharacterBag0Slot:Hide()
		MainMenuBarBackpackButton:Hide()
	end
end

local function oUF_LSBagInfoBar_OnClick(self, button)
	if button == "RightButton" then
		if not InCombatLockdown() then
			if MainMenuBarBackpackButton:IsShown() then
				CharacterBag3Slot:Hide()
				CharacterBag2Slot:Hide()
				CharacterBag1Slot:Hide()
				CharacterBag0Slot:Hide()
				MainMenuBarBackpackButton:Hide()
			else
				CharacterBag3Slot:Show()
				CharacterBag2Slot:Show()
				CharacterBag1Slot:Show()
				CharacterBag0Slot:Show()
				MainMenuBarBackpackButton:Show()
			end
		end
	else
		ToggleAllBags()
	end
end

local function oUF_LSBagInfoBar_OnEvent(self)
	local free, total, used = 0, 0, 0
	for i = 0, NUM_BAG_SLOTS do
		slots, bagType = GetContainerNumFreeSlots(i)
		if bagType == 0 then
			free, total = free + slots, total + GetContainerNumSlots(i)
		end
	end
	used = total - free
	self.text:SetText(used.."/"..total)
	if total ~= 0 then
		if floor((used / total) * 100) > 85 then
			self.filling:SetVertexColor(unpack(ibcolors.red))
		elseif floor((used / total) * 100) > 50 then
			self.filling:SetVertexColor(unpack(ibcolors.yellow))
		else
			self.filling:SetVertexColor(unpack(ibcolors.green))
		end
	else
		self.filling:SetVertexColor(unpack(ibcolors.black))
	end
end

local function oUF_LSClockInfoBar_Initialize()
	oUF_LSClockInfoBar:RegisterForClicks("LeftButtonUp")
end

local function oUF_LSClockInfoBar_OnClick(...)
	TimeManager_Toggle()
end

local function oUF_LSClockInfoBar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
		GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true),
		ibcolors.yellow[1], ibcolors.yellow[2], ibcolors.yellow[3], 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true),
		ibcolors.yellow[1], ibcolors.yellow[2], ibcolors.yellow[3], 1, 1, 1)
	GameTooltip:Show()
end

local function oUF_LSClockInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 1
		self.text:SetText(GameTime_GetTime(true))
		if GameTooltip:IsOwned(self) then
			oUF_LSClockInfoBar_OnEnter(self)
		end
		if TimeManagerClockButton.alarmFiring then
			self.filling:SetVertexColor(unpack(ibcolors.red))
		else
			self.filling:SetVertexColor(unpack(ibcolors.black))
		end
	end
end

local function oUF_LSMailInfoBar_Initialize()
	oUF_LSMailInfoBar.text:SetText(BUTTON_LAG_MAIL)
	oUF_LSMailInfoBar:RegisterEvent("UPDATE_PENDING_MAIL")
end

local function oUF_LSMailInfoBar_OnEnter(self)
	if HasNewMail() then
		local sender1, sender2, sender3 = GetLatestThreeSenders()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
		if sender1 or sender2 or sender3 then
			GameTooltip:AddLine(HAVE_MAIL_FROM, 1, 1, 1)
		else
			GameTooltip:AddLine(HAVE_MAIL, 1, 1, 1)
		end
		if sender1 then
			GameTooltip:AddLine(sender1)
		end
		if sender2 then
			GameTooltip:AddLine(sender2)
		end
		if sender3 then
			GameTooltip:AddLine(sender3)
		end
		GameTooltip:Show()
	end
end

local function oUF_LSMailInfoBar_OnEvent(self)
	if HasNewMail() then
		self.filling:SetVertexColor(unpack(ibcolors.green))
	else
		self.filling:SetVertexColor(unpack(ibcolors.black))
	end
end

function oUF_LSInfobars_Initialize()
	for ib, ibdata in pairs(INFOBAR_INFO) do
		local ibar = CreateFrame(ibdata.infobar_type, "oUF_LS"..ib.."InfoBar", UIParent, "oUF_LSInfoBarButtonTemplate-"..ibdata.length)
		ibar:SetFrameStrata("LOW")
		ibar:SetFrameLevel(1)

		ns.infobars[strlower(ib)] = ibar
	end

	for ib, ibar in pairs(ns.infobars) do
		ibar:SetPoint(unpack(ns.C.infobars[ib].point))
	end

	oUF_LSLocationInfoBar:SetScript("OnEnter", oUF_LSLocationInfoBar_OnEnter)
	oUF_LSLocationInfoBar:SetScript("OnUpdate", oUF_LSLocationInfoBar_OnUpdate)

	oUF_LSMemoryInfoBar_Initialize()
	oUF_LSMemoryInfoBar:SetScript("OnClick", oUF_LSMemoryInfoBar_OnClick)
	oUF_LSMemoryInfoBar:SetScript("OnEnter", oUF_LSMemoryInfoBar_OnEnter)
	oUF_LSMemoryInfoBar:SetScript("OnUpdate", oUF_LSMemoryInfoBar_OnUpdate)

	oUF_LSFPSInfoBar:SetScript("OnUpdate", oUF_LSFPSInfoBar_OnUpdate)

	oUF_LSLatencyInfoBar:SetScript("OnEnter", oUF_LSLatencyInfoBar_OnEnter)
	oUF_LSLatencyInfoBar:SetScript("OnUpdate", oUF_LSLatencyInfoBar_OnUpdate)

	oUF_LSBagInfoBar_Initialize()
	oUF_LSBagInfoBar_OnEvent(oUF_LSBagInfoBar)
	oUF_LSBagInfoBar:SetScript("OnClick", oUF_LSBagInfoBar_OnClick)
	oUF_LSBagInfoBar:SetScript("OnEvent", oUF_LSBagInfoBar_OnEvent)

	oUF_LSClockInfoBar_Initialize()
	oUF_LSClockInfoBar:SetScript("OnClick", oUF_LSClockInfoBar_OnClick)
	oUF_LSClockInfoBar:SetScript("OnEnter", oUF_LSClockInfoBar_OnEnter)
	oUF_LSClockInfoBar:SetScript("OnUpdate", oUF_LSClockInfoBar_OnUpdate)

	oUF_LSMailInfoBar_Initialize()
	oUF_LSMailInfoBar:SetScript("OnEnter", oUF_LSMailInfoBar_OnEnter)
	oUF_LSMailInfoBar:SetScript("OnEvent", oUF_LSMailInfoBar_OnEvent)
end