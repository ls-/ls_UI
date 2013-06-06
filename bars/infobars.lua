local _, ns = ...
local cfg = ns.cfg
local ibar = cfg.infobars
local glcolors = cfg.globals.colors
local L = ns.L
local infobar_module = CreateFrame("Frame")
local ttl
local memory = {}

local function CreateInfoBars(index)
	if index ==1 or index == 2 or index == 5 or index == 6 then
		_G["infobar_module.ibar"..index] = CreateFrame("Button","InfoBar"..index, UIParent)
	else
		_G["infobar_module.ibar"..index] = CreateFrame("Frame","InfoBar"..index, UIParent)
	end
end

local function SetInfoBarPosition(index)
	local ftype = ibar["ibar"..index].ftype
	_G["InfoBar"..index]:SetSize(unpack(ibar["size"..ftype]))
	if index == 1 or index == 6 then
		_G["InfoBar"..index]:SetPoint(unpack(ibar["ibar"..index].pos))
	else
		_G["InfoBar"..index]:SetPoint(
		ibar["ibar"..index].pos[1],
		_G["InfoBar"..index-1],
		ibar["ibar"..index].pos[2],
		ibar["ibar"..index].pos[3], 0)
	end

	_G["InfoBar"..index]:SetScale(0.9 * cfg.globals.scale)
	
	if index == 2 or index == 3 or index == 4 or index == 5 then
		RegisterStateDriver(_G["InfoBar"..index], "visibility", "[petbattle] hide; show")
	end
end

local function SetInfoBarStyle(index)
	local ftype = ibar["ibar"..index].ftype
	_G["InfoBar"..index].bg = _G["InfoBar"..index]:CreateTexture(nil, "ARTWORK", nil, -7)
	_G["InfoBar"..index].bg:SetPoint("CENTER", 0, 0)
	_G["InfoBar"..index].bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\infobar_"..ftype)

	_G["InfoBar"..index].fill = _G["InfoBar"..index]:CreateTexture(nil, "ARTWORK", nil, -6)
	_G["InfoBar"..index].fill:SetPoint("CENTER", 0, 0)
	_G["InfoBar"..index].fill:SetSize(unpack(ibar["fill"..ftype]))
	_G["InfoBar"..index].fill:SetTexture(cfg.globals.textures.statusbar)
	_G["InfoBar"..index].fill:SetVertexColor(unpack(glcolors.infobar.black))

	_G["InfoBar"..index].cover = _G["InfoBar"..index]:CreateTexture(nil, "ARTWORK", nil, -5)
	_G["InfoBar"..index].cover:SetPoint("CENTER", 0, 0)
	_G["InfoBar"..index].cover:SetTexture("Interface\\AddOns\\oUF_LS\\media\\infobar_"..ftype.."_cover")

	_G["InfoBar"..index].text = ns.CreateFontString(_G["InfoBar"..index], cfg.font, 16, "THINOUTLINE")
	_G["InfoBar"..index].text:SetPoint(unpack(ibar.text.pos1))
	_G["InfoBar"..index].text:SetPoint(unpack(ibar.text.pos2))

	_G["InfoBar"..index].updateInterval = 0
end

local function location_enter (self)
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
  	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
	GameTooltip:AddLine(zoneName, 1, 1, 1)
	if pvpType == "sanctuary" then
		GameTooltip:AddLine(subzoneName, unpack(glcolors.infobar.blue))
		GameTooltip:AddLine(SANCTUARY_TERRITORY, unpack(glcolors.infobar.blue))
	elseif pvpType == "arena" then
		GameTooltip:AddLine(subzoneName, unpack(glcolors.infobar.red))
		GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, unpack(glcolors.infobar.red))
	elseif pvpType == "friendly" then
		GameTooltip:AddLine(subzoneName, unpack(glcolors.infobar.green))
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), unpack(glcolors.infobar.green))
	elseif pvpType == "hostile" then
		GameTooltip:AddLine(subzoneName, unpack(glcolors.infobar.red))
		GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), unpack(glcolors.infobar.red))
	elseif pvpType == "contested" then
		GameTooltip:AddLine(subzoneName, unpack(glcolors.infobar.yellow))
		GameTooltip:AddLine(CONTESTED_TERRITORY, unpack(glcolors.infobar.yellow))
	elseif pvpType == "combat" then
		GameTooltip:AddLine(subzoneName, unpack(glcolors.infobar.red))
		GameTooltip:AddLine(COMBAT_ZONE, unpack(glcolors.infobar.red))
	else
		GameTooltip:AddLine(subzoneName, unpack(glcolors.infobar.yellow))
	end
	if coords then
		GameTooltip:AddLine(coords)
	end
	GameTooltip:Show()
end

local function location_update (self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 0.2
		self.text:SetText(GetMinimapZoneText())
		local pvpType = GetZonePVPInfo()
		if pvpType == "sanctuary" then
			self.fill:SetVertexColor(unpack(glcolors.infobar.blue))
		elseif pvpType == "arena" then
			self.fill:SetVertexColor(unpack(glcolors.infobar.red))
		elseif pvpType == "friendly" then
			self.fill:SetVertexColor(unpack(glcolors.infobar.green))
		elseif pvpType == "hostile" then
			self.fill:SetVertexColor(unpack(glcolors.infobar.red))
		elseif pvpType == "contested" then
			self.fill:SetVertexColor(unpack(glcolors.infobar.yellow))
		else
			self.fill:SetVertexColor(unpack(glcolors.infobar.yellow))
		end
		if GameTooltip:IsOwned(self) then
			location_enter(self)
		end
	end
end

local function mem_enter (self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
	GameTooltip:AddLine(L["Memory"]..":")
	sort(memory, function(a, b)
		if a and b then
			return a[2] > b[2]
		end
	end)
	for i = 1, #memory do
		if memory[i][3] then 
			local r = memory[i][2] / ttl * 3
			local g = 2 - r
			GameTooltip:AddDoubleLine(memory[i][1], format("%.3f "..L["MB"], memory[i][2] / 1024), 1, 1, 1, r, g, 0)
		end
	end
	GameTooltip:Show()
end

local function mem_update (self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 10
		ttl = 0
		UpdateAddOnMemoryUsage()
		for i = 1, GetNumAddOns() do
			if not memory[i] then memory[i] = {} end
			memory[i][1] = select(2, GetAddOnInfo(i))
			memory[i][2] = GetAddOnMemoryUsage(i)
			memory[i][3] = IsAddOnLoaded(i)
			ttl = ttl + memory[i][2]
		end
		self.text:SetText(format("%.1f "..L["MB"], ttl / 1024))
		if GameTooltip:IsOwned(self) then
			mem_enter(self)
		end
	end
end

local function mem_click (self)
	UpdateAddOnMemoryUsage()
	collectgarbage()
	self.updateInterval = 2
end

local function fps_update (self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 0.2
		fps = GetFramerate()
		if fps > 35 then 
			self.fill:SetVertexColor(unpack(glcolors.infobar.green))
		elseif fps > 20 then
			self.fill:SetVertexColor(unpack(glcolors.infobar.yellow))
		else
			self.fill:SetVertexColor(unpack(glcolors.infobar.red))
		end
		self.text:SetText(floor(fps).." fps")
	end
end

local function ms_enter (self)
	bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
	GameTooltip:AddLine(L["Latency"]..":")
	GameTooltip:AddLine(format(L["Home"]..": %d "..L["ms"], latencyHome), 1, 1, 1)
	GameTooltip:AddLine(format(L["World"]..": %d "..L["ms"], latencyWorld), 1, 1, 1)
	GameTooltip:Show()
end

local function ms_update (self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 15
		latency = select(4, GetNetStats())
		if latency > 600 then 
			self.fill:SetVertexColor(unpack(glcolors.infobar.red))
		elseif latency > 300 then
			self.fill:SetVertexColor(unpack(glcolors.infobar.yellow))
		else
			self.fill:SetVertexColor(unpack(glcolors.infobar.green))
		end
		self.text:SetText(latency.." "..L["ms"])
		if GameTooltip:IsOwned(self) then
			ms_enter(self)
		end
	end
end

local function bag_event (self, ...) 
	local free, total, used = 0, 0
	for i = 0, NUM_BAG_SLOTS do
		slots, BagType = GetContainerNumFreeSlots(i)
		if BagType == 0 then
			free, total = free + slots, total + GetContainerNumSlots(i)
		end
	end
	used = total - free
	self.text:SetText(used.."/"..total)
	if floor((used / total) * 100) > 85 then
		self.fill:SetVertexColor(unpack(glcolors.infobar.red))
	elseif floor((used / total) * 100) > 50 then
		self.fill:SetVertexColor(unpack(glcolors.infobar.yellow))
	else
		self.fill:SetVertexColor(unpack(glcolors.infobar.green))
	end
end

local function bag_click (self, button, event)
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

local function time_enter (self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
		GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, 1, 1, 1)
	-- realm time
	GameTooltip:AddDoubleLine(
		TIMEMANAGER_TOOLTIP_REALMTIME, GameTime_GetGameTime(true),
		glcolors.infobar.yellow[1], glcolors.infobar.yellow[2], glcolors.infobar.yellow[3], 1, 1, 1)
	-- local time
	GameTooltip:AddDoubleLine(
		TIMEMANAGER_TOOLTIP_LOCALTIME, GameTime_GetLocalTime(true),
		glcolors.infobar.yellow[1], glcolors.infobar.yellow[2], glcolors.infobar.yellow[3], 1, 1, 1)
	GameTooltip:Show()
end

local function time_update(self, elapsed)
	if self.updateInterval > 0 then
		self.updateInterval = self.updateInterval - elapsed
	else
		self.updateInterval = 0.2
		self.text:SetText(GameTime_GetTime(false))
		if GameTooltip:IsOwned(self) then
			time_enter(self)
		end
		if TimeManagerClockButton.alarmFiring then
			self.fill:SetVertexColor(unpack(glcolors.infobar.red))
		else
			self.fill:SetVertexColor(unpack(glcolors.infobar.black))
		end
	end
end

local function mail_enter (self)
	if HasNewMail() then
		local sender1, sender2, sender3 = GetLatestThreeSenders()
		local toolText = ""
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
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

local function mail_event (self, ...)
	self.text:SetText(L["Mail"])
	if HasNewMail() then
		self.fill:SetVertexColor(unpack(glcolors.infobar.green))
	else
		self.fill:SetVertexColor(unpack(glcolors.infobar.black))
	end
end

local function InitInfoBarScripts ()
	InfoBar1:RegisterForClicks("AnyUp")
	InfoBar1:SetScript("OnUpdate", location_update)
	InfoBar1:SetScript("OnEnter", location_enter)
	InfoBar1:SetScript("OnLeave", function() GameTooltip:Hide() end)
	InfoBar1:SetScript("OnClick", function() ToggleFrame(WorldMapFrame) end)

	InfoBar2:RegisterForClicks("AnyUp")
	InfoBar2:SetScript("OnUpdate", mem_update)
	InfoBar2:SetScript("OnEnter", mem_enter)
	InfoBar2:SetScript("OnLeave", function() GameTooltip:Hide() end)
	InfoBar2:SetScript("OnClick", mem_click)

	InfoBar3:SetScript("OnUpdate", fps_update)

	InfoBar4:SetScript("OnUpdate", ms_update)
	InfoBar4:SetScript("OnEnter", ms_enter)
	InfoBar4:SetScript("OnLeave", function() GameTooltip:Hide() end)

	InfoBar5:RegisterForClicks("AnyUp")
	InfoBar5:RegisterEvent("BAG_UPDATE")
	InfoBar5:RegisterEvent("PLAYER_ENTERING_WORLD")
	InfoBar5:SetScript("OnEvent", bag_event)
	InfoBar5:SetScript("OnClick", bag_click)

	InfoBar6:SetScript("OnUpdate", time_update)
	InfoBar6:SetScript("OnEnter", time_enter)
	InfoBar6:SetScript("OnLeave", function() GameTooltip:Hide() end)
	InfoBar6:SetScript("OnClick", function() TimeManager_Toggle() end)

	InfoBar7:RegisterEvent("UPDATE_PENDING_MAIL")
	InfoBar7:SetScript("OnEvent", mail_event)
	InfoBar7:SetScript("OnEnter", mail_enter)
	InfoBar7:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local function InitInfoBarParameters ()
	for i = 1, 7 do
		CreateInfoBars(i)
		SetInfoBarPosition(i)
		SetInfoBarStyle(i)
	end
	InitInfoBarScripts()
end

infobar_module:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		InitInfoBarParameters()
	end
end)

infobar_module:RegisterEvent("PLAYER_LOGIN")