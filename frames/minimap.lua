local _, ns = ...

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

local function SetElementsStyle()
	local elementsToShow = {
		MiniMapTracking = {"CENTER", "Minimap", "CENTER", 72, 30},
		GameTimeFrame = {"CENTER", "Minimap", "CENTER", 55, 55},
		MiniMapInstanceDifficulty = {"BOTTOM", "Minimap", "BOTTOM", -1, -38},
		GuildInstanceDifficulty = {"BOTTOM", "Minimap", "BOTTOM", -6, -38},
		QueueStatusMinimapButton = {"CENTER", "Minimap", "CENTER", 55, -55},
	}

	for i, k in pairs(elementsToShow) do
		_G[i]:ClearAllPoints()
		_G[i]:SetParent(Minimap)
		_G[i]:SetPoint(unpack(k))
	end

	local elementsToHide = {
		"MinimapCluster",
		"MiniMapWorldMapButton",
		"MinimapZoomIn",
		"MinimapZoomOut",
		"MiniMapRecordingButton",
		"MinimapZoneTextButton",
		"MinimapBorder",
		"MinimapBorderTop",
		"MiniMapMailFrame",
		"MinimapBackdrop",
		"TimeManagerClockButton",
		"MiniMapTrackingIconOverlay",
	}

	for _, f in pairs(elementsToHide) do
		if not _G[f]:IsObjectType("Texture") then _G[f]:UnregisterAllEvents() end
		_G[f]:SetParent(ns.hiddenParentFrame)
	end

	local children = {Minimap:GetChildren()}
	for _, child in pairs(children) do
		child:SetFrameLevel(Minimap:GetFrameLevel() + 1)
	end

	MiniMapTracking:SetSize(32, 32)
	MiniMapTrackingBackground:SetSize(32, 32)
	MiniMapTrackingBackground:ClearAllPoints()
	MiniMapTrackingBackground:SetPoint("CENTER", 0, 0)
	MiniMapTrackingBackground:SetVertexColor(0, 0, 0, 0.8)
	MiniMapTrackingButtonBorder:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
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
	local CalendarFrame = _G["GameTimeFrame"]
	CalendarFrame:SetSize(32, 32)
	CalendarFrame:SetScript("OnEnter", nil)
	CalendarFrame:SetScript("OnLeave", nil)
	CalendarFrame:SetNormalTexture("")
	CalendarFrame:SetPushedTexture("")

	local CalendarText = select(5, GameTimeFrame:GetRegions())
	CalendarText:SetTextColor(0.52, 0.46, 0.36)
	CalendarText:SetFont(ns.M.font, 13, "THINOUTLINE")
	CalendarText:ClearAllPoints()
	CalendarText:SetPoint("CENTER", 0, 0)

	local CalendarBackground = CalendarFrame:CreateTexture(nil, "BACKGROUND")
	CalendarBackground:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	CalendarBackground:SetVertexColor(0, 0, 0, 0.8)
	CalendarBackground:SetPoint("CENTER", 0, 0)
	CalendarBackground:SetSize(32, 32)

	local CalendarBorder = CalendarFrame:CreateTexture(nil, "BORDER")
	CalendarBorder:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
	CalendarBorder:SetSize(32, 32)
	CalendarBorder:SetPoint("CENTER", 0, 0)
end

function lsMinimap_Initialize()
	Minimap:SetParent("UIParent")
	Minimap:ClearAllPoints()
	Minimap:SetPoint(unpack(ns.C.minimap.point))

	CreateMapOverlay()
	CreateMapZoom()
	SetElementsStyle()
end