local _, ns = ...
local cfg = ns.cfg
local mapcfg = cfg.minimap
local map_module = CreateFrame("Frame")

local function SetElementPosition(f, a1, af, a2, x, y)
	_G[f]:ClearAllPoints()
	_G[f]:SetPoint(a1, _G[af], a2, x, y)
end

local function CreateMapOverlay()
	local t = Minimap:CreateTexture(nil,"ARTWORK",nil, -6)
	t:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_ring")
	t:SetPoint("CENTER", 0, 0)
	t:SetSize(256, 256)
	local t2 = Minimap:CreateTexture(nil,"ARTWORK",nil, -5)
	t2:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_sol")
	t2:SetPoint("CENTER", 0, 0)
	t2:SetSize(256, 256)
	local t3 = Minimap:CreateTexture(nil,"ARTWORK", nil, -8)
	t3:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_filling_gloss")
	t3:SetPoint("CENTER", 0, 0)
	t3:SetSize(Minimap:GetWidth(), Minimap:GetHeight())
	t3:SetAlpha(.75)
	local t4 = Minimap:CreateTexture(nil,"ARTWORK", nil, -7)
	t4:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_chain_right")
	t4:SetSize(128, 64)
	t4:SetPoint("CENTER", 0, -96)
end

local function CreateMapZoom()
	Minimap:EnableMouseWheel()
	Minimap:SetScript("OnMouseWheel", function(self, direction)
		if direction > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end)
end

local function SetElementStyle()
	MiniMapWorldMapButton:Hide()
	MinimapZoomOut:Hide()
	MinimapZoomIn:Hide()
	MinimapZoneTextButton:Hide()
	MinimapBorderTop:Hide()
	MinimapBorder:Hide()
	MiniMapMailFrame:UnregisterAllEvents()
	MiniMapMailFrame:Hide()
	TimeManagerClockButton:Hide()
	hooksecurefunc(TimeManagerClockButton, "Show", function(self) self:Hide() end)
	hooksecurefunc(TimeManagerAlarmFiredTexture, "Show", function(self) self:Hide() end)
	--tracking
	MiniMapTracking:SetSize(mapcfg.iconsize, mapcfg.iconsize)
	MiniMapTrackingBackground:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button_bg")
	MiniMapTrackingBackground:SetSize(mapcfg.iconsize, mapcfg.iconsize)
	MiniMapTrackingBackground:ClearAllPoints()
	MiniMapTrackingBackground:SetPoint("CENTER", 0, 0)
	MiniMapTrackingBackground:SetVertexColor(0, 0, 0, 0.8)
	MiniMapTrackingButtonBorder:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
	MiniMapTrackingButtonBorder:SetSize(mapcfg.iconsize, mapcfg.iconsize)
	MiniMapTrackingIcon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_search")
	MiniMapTrackingIcon:SetPoint("CENTER", 0, 0)
	MiniMapTrackingIcon:SetVertexColor(0.6, 0.6, 0.6, 1)
	MiniMapTrackingButton:SetScript("OnMouseDown", function() 
		MiniMapTrackingIcon:SetPoint("TOPLEFT", MiniMapTracking, "TOPLEFT", 7, -7) 
	end)
	MiniMapTrackingButton:SetScript("OnMouseUp", function() 
		MiniMapTrackingIcon:SetPoint("TOPLEFT", MiniMapTracking, "TOPLEFT", 6, -6) 
	end)
	--queue
	QueueStatusMinimapButton:SetSize(mapcfg.iconsize, mapcfg.iconsize)
	QueueStatusMinimapButton.Eye:SetPoint("CENTER", 0, -1)
	QueueStatusMinimapButton.Eye:SetScale(1.2)
	QueueStatusMinimapButtonBorder:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
	QueueStatusMinimapButtonBorder:SetPoint("CENTER", 0, 0)
	QueueStatusMinimapButtonBorder:SetSize(mapcfg.iconsize, mapcfg.iconsize)
	QueueStatusMinimapButton:GetHighlightTexture():ClearAllPoints()
	QueueStatusMinimapButton:GetHighlightTexture():SetPoint("CENTER", 1, -2)
	--calendar
	local calFrame = _G["GameTimeFrame"]
	calFrame:SetSize(mapcfg.iconsize, mapcfg.iconsize)
	calFrame:SetScript("OnEnter", nil)
	calFrame:SetScript("OnLeave", nil)
	calFrame:SetNormalTexture("")
	calFrame:SetPushedTexture("")
	local calText = select(5, GameTimeFrame:GetRegions())
	calText:SetTextColor(0.52, 0.46, 0.36)
	calText:SetFont(cfg.font, 13, "THINOUTLINE")
	calText:ClearAllPoints()
	calText:SetPoint("CENTER", 2, 0)
	local calBg = calFrame:CreateTexture(nil,"BACKGROUND")
	calBg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button_bg")
	calBg:SetVertexColor(0, 0, 0, 0.8)
	calBg:SetPoint("CENTER", 0, 0)
	calBg:SetSize(mapcfg.iconsize, mapcfg.iconsize)
	local calBorder = calFrame:CreateTexture(nil,"ARTWORK")
	calBorder:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
	calBorder:SetSize(mapcfg.iconsize, mapcfg.iconsize)
	calBorder:SetPoint("CENTER", 0, 0)
end

local function InitMapParameters()
	LoadAddOn("Blizzard_TimeManager")
	for index,_ in ipairs(mapcfg.elemets) do 
		SetElementPosition(unpack(mapcfg.elemets[index]))
	end
	CreateMapOverlay()
	CreateMapZoom() 
	SetElementStyle()
	Minimap:SetScale(cfg.globals.scale)
end

map_module:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		InitMapParameters()
	end
end)

map_module:RegisterEvent("PLAYER_LOGIN")