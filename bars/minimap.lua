
local _, ns = ...
local cfg = ns.cfg
local minimapModule = CreateFrame("Frame")

local hidenParentFrame = CreateFrame("Frame")
hidenParentFrame:Hide()

local elementsToHide = {
	"MinimapCluster",
	"MiniMapWorldMapButton",
	"MinimapZoomIn",
	"MinimapZoomOut",
	"MiniMapRecordingButton",
	"MinimapZoneTextButton",
	"MinimapBorder",
	"MiniMapMailFrame",
	"TimeManagerClockButton",
	"MiniMapTrackingIconOverlay",
}

local function SetElementPosition(f, a1, af, a2, x, y)
	_G[f]:ClearAllPoints()
	_G[f]:SetPoint(a1, _G[af], a2, x, y)
end

local function CreateMapOverlay()
	local t1 = Minimap:CreateTexture(nil, "BORDER", nil, 0)
	t1:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_filling_gloss")
	t1:SetPoint("CENTER", -2, 0)
	t1:SetSize(Minimap:GetSize())
	t1:SetAlpha(0.75)
	local t2 = Minimap:CreateTexture(nil, "BORDER", nil, 1)
	t2:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_chain_right")
	t2:SetPoint("CENTER", -2, -96)
	local t3 = Minimap:CreateTexture(nil, "BORDER", nil, 2)
	t3:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_ring_l_cracked")
	t3:SetPoint("CENTER", -2, 0)
	local t4 = Minimap:CreateTexture(nil, "BORDER", nil, 3)
	t4:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_sol")
	t4:SetPoint("CENTER", -2, 0)
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
	for _, f in pairs(elementsToHide) do
		if not _G[f]:IsObjectType("Texture") then _G[f]:UnregisterAllEvents() end
		_G[f]:SetParent(hidenParentFrame)
	end
	MiniMapTracking:SetSize(32, 32)
	MiniMapTrackingBackground:SetSize(32, 32)
	MiniMapTrackingBackground:ClearAllPoints()
	MiniMapTrackingBackground:SetPoint("CENTER", 0, 0)
	MiniMapTrackingBackground:SetVertexColor(0, 0, 0, 0.8)
	MiniMapTrackingButtonBorder:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
	MiniMapTrackingButtonBorder:SetTexture("")
	MiniMapTrackingButtonBorder:SetSize(32, 32)
	MiniMapTrackingIcon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_search")
	MiniMapTrackingIcon:SetSize(18, 18)
	MiniMapTrackingIcon:SetVertexColor(0.6, 0.6, 0.6, 1)
	--QUEUE
	QueueStatusMinimapButton:SetSize(32, 32)
	QueueStatusMinimapButtonIcon:SetPoint("CENTER", 0, -1)
	QueueStatusMinimapButtonIcon:SetSize(36, 36)
	QueueStatusMinimapButtonBorder:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
	QueueStatusMinimapButtonBorder:SetPoint("CENTER", 0, 0)
	QueueStatusMinimapButtonBorder:SetSize(32, 32)
	QueueStatusMinimapButton:GetHighlightTexture():ClearAllPoints()
	QueueStatusMinimapButton:GetHighlightTexture():SetPoint("CENTER", 1, -2)
	--CALENDAR
	local calendarFrame = _G["GameTimeFrame"]
	calendarFrame:SetSize(32, 32)
	calendarFrame:SetScript("OnEnter", nil)
	calendarFrame:SetScript("OnLeave", nil)
	calendarFrame:SetNormalTexture("")
	calendarFrame:SetPushedTexture("")
	local calendarText = select(5, GameTimeFrame:GetRegions())
	calendarText:SetTextColor(0.52, 0.46, 0.36)
	calendarText:SetFont(cfg.font, 13, "THINOUTLINE")
	calendarText:ClearAllPoints()
	calendarText:SetPoint("CENTER", 0, 0)
	local calendarBackground = calendarFrame:CreateTexture(nil,"BACKGROUND")
	calendarBackground:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	calendarBackground:SetVertexColor(0, 0, 0, 0.8)
	calendarBackground:SetPoint("CENTER", 0, 0)
	calendarBackground:SetSize(32, 32)
	local calendarBorder = calendarFrame:CreateTexture(nil,"BORDER")
	calendarBorder:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
	calendarBorder:SetSize(32, 32)
	calendarBorder:SetPoint("CENTER", 0, 0)
end

local function InitMinimapParameters()
	Minimap:SetParent("UIParent")
	for i, _ in ipairs(cfg.minimap.elemets) do 
		SetElementPosition(unpack(cfg.minimap.elemets[i]))
	end
	CreateMapOverlay()
	CreateMapZoom()
	SetElementStyle()
end

minimapModule:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		InitMinimapParameters()
	end
end)

minimapModule:RegisterEvent("PLAYER_LOGIN")