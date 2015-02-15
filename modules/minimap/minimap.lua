local _, ns = ...
local M = ns.M

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

local function SetButtonStyle(button, border, icon, bg)
	local highlight = button:GetHighlightTexture()
	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()

	button:SetSize(32, 32)

	if border then
		border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
		border:SetDrawLayer("BORDER", 0)
		border:ClearAllPoints()
		border:SetAllPoints(button)
	else
		local border = button:CreateTexture(nil, "BACKGROUND", 0)
		border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
		border:SetDrawLayer("BORDER", 0)
		border:ClearAllPoints()
		border:SetAllPoints(button)
	end

	if icon then
		icon:SetDrawLayer("ARTWORK", 0)
		icon:ClearAllPoints()
		icon:SetPoint("CENTER", 0, 0)
	end

	if bg and not bg == "create" then
		bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
		bg:SetVertexColor(0, 0, 0, 0.8)
		bg:SetDrawLayer("BACKGROUND", 0)
		bg:ClearAllPoints()
		bg:SetAllPoints(button)
	elseif bg == "create" then
		local bg = button:CreateTexture(nil, "BACKGROUND", 0)
		bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
		bg:SetVertexColor(0, 0, 0, 0.8)
		bg:SetAllPoints(button)
	end

	if normal then
		normal:SetTexture("")
	end

	if pushed then
		pushed:SetTexture("")
	end

	if highlight then
		highlight:ClearAllPoints()
		highlight:SetAllPoints(button)
	end
end

local function SetElementsStyle()
	for i, k in next, {
		MiniMapTracking = {"CENTER", "Minimap", "CENTER", 72, 30},
		GameTimeFrame = {"CENTER", "Minimap", "CENTER", 55, 55},
		MiniMapInstanceDifficulty = {"BOTTOM", "Minimap", "BOTTOM", -1, -38},
		GuildInstanceDifficulty = {"BOTTOM", "Minimap", "BOTTOM", -6, -38},
		QueueStatusMinimapButton = {"CENTER", "Minimap", "CENTER", 55, -55},
		GarrisonLandingPageMinimapButton = {"CENTER", "Minimap", "CENTER", -57, -57},
	} do
		_G[i]:ClearAllPoints()
		_G[i]:SetParent(Minimap)
		_G[i]:SetPoint(unpack(k))
	end

	for _, f in next, {
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
	} do
		if not _G[f]:IsObjectType("Texture") then
			_G[f]:UnregisterAllEvents()
		end

		_G[f]:SetParent(M.hiddenParent)
	end

	for _, child in next, {Minimap:GetChildren()} do
		child:SetFrameLevel(Minimap:GetFrameLevel() + 1)
	end

	-- Tracking
	SetButtonStyle(MiniMapTrackingButton, MiniMapTrackingButtonBorder, nil, MiniMapTrackingBackground)

	MiniMapTrackingIcon:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_search")
	MiniMapTrackingIcon:SetSize(18, 18)
	MiniMapTrackingIcon:SetVertexColor(0.6, 0.6, 0.6, 1)

	-- Queue
	SetButtonStyle(QueueStatusMinimapButton, QueueStatusMinimapButtonBorder)

	-- Calendar
	SetButtonStyle(GameTimeFrame, nil, nil, "create")

	local text = select(5, GameTimeFrame:GetRegions())
	text:SetTextColor(0.52, 0.46, 0.36)
	text:SetFont(M.font, 12, "THINOUTLINE")
	text:ClearAllPoints()
	text:SetPoint("CENTER", 0, 0)

	-- Garrison
	GarrisonLandingPageMinimapButton:SetSize(40, 40)
end

function ns.lsMinimap_Initialize()
	Minimap:SetParent("UIParent")
	Minimap:ClearAllPoints()
	Minimap:SetPoint(unpack(ns.C.minimap.point))
	RegisterStateDriver(Minimap, "visibility", "[petbattle] hide; show")

	CreateMapOverlay()
	CreateMapZoom()
	SetElementsStyle()
end
