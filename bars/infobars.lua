local _, ns = ...
local L = ns.L
local infoBarColors = ns.cfg.globals.colors.infobar

local PERFORMANCEBAR_MEDIUM_LATENCY = PERFORMANCEBAR_MEDIUM_LATENCY
local PERFORMANCEBAR_LOW_LATENCY = PERFORMANCEBAR_LOW_LATENCY
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

function oUF_LocationInfoBar_OnEnter(self)
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
		GameTooltip:AddLine(subzoneName, unpack(infoBarColors.blue))
		GameTooltip:AddLine(SANCTUARY_TERRITORY, unpack(infoBarColors.blue))
	elseif pvpType == "arena" then
		GameTooltip:AddLine(subzoneName, unpack(infoBarColors.red))
		GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, unpack(infoBarColors.red))
	elseif pvpType == "friendly" then
		GameTooltip:AddLine(subzoneName, unpack(infoBarColors.green))
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), unpack(infoBarColors.green))
	elseif pvpType == "hostile" then
		GameTooltip:AddLine(subzoneName, unpack(infoBarColors.red))
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), unpack(infoBarColors.red))
	elseif pvpType == "contested" then
		GameTooltip:AddLine(subzoneName, unpack(infoBarColors.yellow))
		GameTooltip:AddLine(CONTESTED_TERRITORY, unpack(infoBarColors.yellow))
	elseif pvpType == "combat" then
		GameTooltip:AddLine(subzoneName, unpack(infoBarColors.red))
		GameTooltip:AddLine(COMBAT_ZONE, unpack(infoBarColors.red))
	else
		GameTooltip:AddLine(subzoneName, unpack(infoBarColors.yellow))
	end
	if coords then
		GameTooltip:AddLine(coords)
	end
	GameTooltip:Show()
end

function oUF_LocationInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 0.2
		self.text:SetText(GetMinimapZoneText())
		local pvpType = GetZonePVPInfo()
		if pvpType == "sanctuary" then
			self.filling:SetVertexColor(unpack(infoBarColors.blue))
		elseif pvpType == "arena" then
			self.filling:SetVertexColor(unpack(infoBarColors.red))
		elseif pvpType == "friendly" then
			self.filling:SetVertexColor(unpack(infoBarColors.green))
		elseif pvpType == "hostile" then
			self.filling:SetVertexColor(unpack(infoBarColors.red))
		elseif pvpType == "contested" then
			self.filling:SetVertexColor(unpack(infoBarColors.yellow))
		else
			self.filling:SetVertexColor(unpack(infoBarColors.yellow))
		end
		if GameTooltip:IsOwned(self) then
			oUF_LocationInfoBar_OnEnter(self)
		end
	end
end

function oUF_MemoryInfoBar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
	GameTooltip:AddLine(L["Memory"]..":")
	sort(self.activeAddons, function(a, b)
		if a and b then
			return a[2] > b[2]
		end
	end)
	for i = 1, #self.activeAddons do
		if self.activeAddons[i][3] then 
			local r = self.activeAddons[i][2] / self.usedMemory * 3
			local g = 2 - r
			GameTooltip:AddDoubleLine(self.activeAddons[i][1], format("%.3f "..L["MB"], 
				self.activeAddons[i][2] / 1024), 1, 1, 1, r, g, 0)
		end
	end
	GameTooltip:Show()
end

function oUF_MemoryInfoBar_OnUpdate(self, elapsed)
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
		self.text:SetText(format("%.1f "..L["MB"], self.usedMemory / 1024))
		if GameTooltip:IsOwned(self) then
			oUF_MemoryInfoBar_OnEnter(self)
		end
	end
end

function oUF_MemoryInfoBar_OnClick(self)
	UpdateAddOnMemoryUsage()
	collectgarbage()
	self.updateInterval = 2
end

function oUF_FPSInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 0.2
		local fps = GetFramerate()
		if fps > 35 then 
			self.filling:SetVertexColor(unpack(infoBarColors.green))
		elseif fps > 20 then
			self.filling:SetVertexColor(unpack(infoBarColors.yellow))
		else
			self.filling:SetVertexColor(unpack(infoBarColors.red))
		end
		self.text:SetText(floor(fps).." fps")
	end
end

function oUF_LatencyInfoBar_OnEnter(self)
	_, _, latencyHome, latencyWorld = GetNetStats()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
	GameTooltip:AddLine(L["Latency"]..":")
	GameTooltip:AddLine(format(L["Home"]..": %d "..L["ms"], latencyHome), 1, 1, 1)
	GameTooltip:AddLine(format(L["World"]..": %d "..L["ms"], latencyWorld), 1, 1, 1)
	GameTooltip:Show()
end

function oUF_LatencyInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 15
		local latency = select(4, GetNetStats())
		if latency > PERFORMANCEBAR_MEDIUM_LATENCY then 
			self.filling:SetVertexColor(unpack(infoBarColors.red))
		elseif latency > PERFORMANCEBAR_LOW_LATENCY then
			self.filling:SetVertexColor(unpack(infoBarColors.yellow))
		else
			self.filling:SetVertexColor(unpack(infoBarColors.green))
		end
		self.text:SetText(latency.." "..L["ms"])
		if GameTooltip:IsOwned(self) then
			oUF_LatencyInfoBar_OnEnter(self)
		end
	end
end

function oUF_BagsInfoBar_OnEvent(self) 
	local free, total, used = 0, 0, 0
	for i = 0, NUM_BAG_SLOTS do
		slots, bagType = GetContainerNumFreeSlots(i)
		if bagType == 0 then
			free, total = free + slots, total + GetContainerNumSlots(i)
		end
	end
	used = total - free
	self.text:SetText(used.."/"..total)
	if floor((used / total) * 100) > 85 then
		self.filling:SetVertexColor(unpack(infoBarColors.red))
	elseif floor((used / total) * 100) > 50 then
		self.filling:SetVertexColor(unpack(infoBarColors.yellow))
	else
		self.filling:SetVertexColor(unpack(infoBarColors.green))
	end
end

function oUF_BagsInfoBar_OnClick(self, button)
	if button == "RightButton" then
		if new_BagFrame:IsShown() then
			new_BagFrame:Hide()
		else
			new_BagFrame:Show()
		end
	else
		ToggleAllBags()
	end
end

function oUF_ClockInfoBar_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
		GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true),
		infoBarColors.yellow[1], infoBarColors.yellow[2], infoBarColors.yellow[3], 1, 1, 1)
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true),
		infoBarColors.yellow[1], infoBarColors.yellow[2], infoBarColors.yellow[3], 1, 1, 1)
	GameTooltip:Show()
end

function oUF_ClockInfoBar_OnUpdate(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 1
		self.text:SetText(GameTime_GetTime(true))
		if GameTooltip:IsOwned(self) then
			oUF_ClockInfoBar_OnEnter(self)
		end
		if TimeManagerClockButton.alarmFiring then
			self.filling:SetVertexColor(unpack(infoBarColors.red))
		else
			self.filling:SetVertexColor(unpack(infoBarColors.black))
		end
	end
end

function oUF_MailInfoBar_OnLoad(self)
	self.text:SetText(L["Mail"])
end

function oUF_MailInfoBar_OnEnter(self)
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

function oUF_MailInfoBar_OnEvent(self)
	if HasNewMail() then
		self.filling:SetVertexColor(unpack(infoBarColors.green))
	else
		self.filling:SetVertexColor(unpack(infoBarColors.black))
	end
end