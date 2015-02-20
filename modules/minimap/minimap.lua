local _, ns = ...
local E, M = ns.E, ns.M

E.Minimap = {}

local MM = E.Minimap

local Minimap = Minimap

local WIDGETS = {
	MiniMapTracking = {"CENTER", "Minimap", "CENTER", 72, 30},
	GameTimeFrame = {"CENTER", "Minimap", "CENTER", 55, 55},
	MiniMapInstanceDifficulty = {"BOTTOM", "Minimap", "BOTTOM", -1, -38},
	GuildInstanceDifficulty = {"BOTTOM", "Minimap", "BOTTOM", -6, -38},
	QueueStatusMinimapButton = {"CENTER", "Minimap", "CENTER", 55, -55},
	GarrisonLandingPageMinimapButton = {"CENTER", "Minimap", "CENTER", -57, -57},
	MiniMapVoiceChatFrame = {"CENTER", "Minimap", "CENTER", 30, 72}
}

local HandleMinimapButton
function HandleMinimapButton(button, cascade)
	local children = {button:GetChildren()}
	local regions = {button:GetRegions()}

	local normal = button.GetNormalTexture and button:GetNormalTexture()
	local pushed = button.GetPushedTexture and button:GetPushedTexture()

	local texture, layer, name, oType, icon, highlight, border, background

	-- print("====",button:GetName(), #children, #regions,"====")

	for _, region in next, regions do
		if region:IsObjectType("Texture") then
			texture, layer, name = region:GetTexture(), region:GetDrawLayer(), region:GetName()
			-- print(texture, layer)
			-- print(layer == "HIGHLIGHT" and "|cff00ccffis highlight texture|r" or "")
			-- print(region == normal and "|cffff5c7fis normal texture|r" or "")
			-- print(region == pushed and "|cffff7f5cis pushed texture|r" or "")
			-- print((texture and strfind(texture, "TrackingBorder")) and "|cffff7f5cis border texture|r" or (name and strfind(name, "Border")) and "|cffff7f5cis border texture|r" or "")
			-- print((name and strfind(name, "icon")) and "|cfff45c7fis icon texture|r" or (name and strfind(name, "Icon")) and "|cfff45c7fis Icon texture|r" or 
			-- 	(button.icon and button.icon == region) and "|cfff45c7fis .icon texture|r" or (button.Icon and button.Icon == region) and "|cfff45c7fis .Icon texture|r" or "")
			-- print((layer == "BACKGROUND" and (texture and strfind(texture, "Background"))) and "|cffff11bbis background texture|r" or "")
			if layer == "HIGHLIGHT" then
				highlight = region
			elseif not normal and not pushed then
				if layer == "ARTWORK" or layer == "BACKGROUND" then
					if button.icon and button.icon == region then
						icon = region
					elseif button.Icon and button.Icon == region then
						icon = region
					elseif name and strfind(name, "icon") then
						icon = region
					elseif name and strfind(name, "Icon") then
						icon = region
					elseif texture and strfind(texture, "Background") then
						background = region
					end
				elseif layer == "OVERLAY" or layer == "BORDER" then
					if texture and strfind(texture, "TrackingBorder") then
						border = region
					end
				end
			end

		end
	end

	local thighlight, ticon, tborder, tbackground, tnormal, tpushed

	for _, child in next, children do
		name, oType = child:GetName(), child:GetObjectType()
		local strata, level = child:GetFrameStrata(), child:GetFrameLevel()
		-- print("|cffffff7f"..name.."|r", strata, level, child:GetObjectType())
		-- print((name and strfind(name, "icon")) and "|cfff45c7fis icon texture|r" or (name and strfind(name, "Icon")) and "|cfff45c7fis Icon texture|r" or "")
		if oType == "Frame" and oType ~= "Button" then
			if name and strfind(name, "icon") then
				icon = child
			elseif name and strfind(name, "Icon") then
				icon = child
			end
		elseif oType == "Button" then
			thighlight, ticon, tborder, tbackground, tnormal, tpushed = HandleMinimapButton(child, true)
		end
	end

	normal = normal or tnormal
	pushed = pushed or tpushed
	highlight = highlight or thighlight
	icon = icon or ticon
	border = border or tborder
	background = background or tbackground

	-- print(cascade and "CASCADE!!" or "")
	-- print("|cffffff7fHL|r", not not highlight, "|cffffff7fI|r", (not not icon or not not (normal and pushed)), "|cffffff7fB|r", not not border, "|cffffff7fBG|r", not not background)

	if not cascade then
		button:SetSize(32, 32)

		highlight:ClearAllPoints()
		highlight:SetAllPoints(button)

		local size = normal and normal:GetSize() or icon:GetSize()
		local offset = size >= 42 and -2 or size >= 28 and 0 or 5

		if normal and pushed then
			normal:SetDrawLayer("ARTWORK", 0)
			normal:ClearAllPoints()
			normal:SetPoint("TOPLEFT", offset, -offset)
			normal:SetPoint("BOTTOMRIGHT", -offset, offset)

			button.NormalTexture = normal

			pushed:SetDrawLayer("ARTWORK", 0)
			pushed:ClearAllPoints()
			pushed:SetPoint("TOPLEFT", offset, -offset)
			pushed:SetPoint("BOTTOMRIGHT", -offset, offset)

			button.PushedTexture = pushed
		elseif icon then
			if icon:IsObjectType("Texture") then
				icon:SetDrawLayer("ARTWORK", 0)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", offset, -offset)
				icon:SetPoint("BOTTOMRIGHT", -offset, offset)
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

		border:SetTexture("Interface\\AddOns\\oUF_LS\\media\\minimap_button")
		border:SetDrawLayer("OVERLAY", 0)
		border:SetAllPoints(button)

		button.Border = border

		if not background then
			background = button:CreateTexture()
		end

		background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
		background:SetVertexColor(0, 0, 0, 0.8)
		background:SetDrawLayer("BACKGROUND", 0)
		background:SetAllPoints(button)

		button.Background = background
	else
		return highlight, icon , border, background, normal, pushed 
	end
end

local function Minimap_OnEventHook(self, event)
	if event == "PLAYER_ENTERING_WORLD" and not self.handled then
		for _, child in next, {self:GetChildren()} do
			child:SetFrameLevel(self:GetFrameLevel() + 1)

			if child:IsObjectType("Button") then
				if not WIDGETS[child:GetName()] then
					HandleMinimapButton(child)
				end
			end
		end

		self.handled = true
	end
end

local function Minimap_OnMouseWheel(self, direction)
	if direction > 0 then
		Minimap_ZoomIn()
	else
		Minimap_ZoomOut()
	end
end

function MM:Initialize()
	Minimap:SetParent("UIParent")
	Minimap:ClearAllPoints()
	Minimap:SetPoint(unpack(ns.C.minimap.point))

	Minimap:RegisterEvent("PLAYER_ENTERING_WORLD")
	Minimap:HookScript("OnEvent", Minimap_OnEventHook)

	Minimap:EnableMouseWheel()
	Minimap:SetScript("OnMouseWheel", Minimap_OnMouseWheel)

	RegisterStateDriver(Minimap, "visibility", "[petbattle] hide; show")

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

	for i, k in next, WIDGETS do
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

	HandleMinimapButton(GarrisonLandingPageMinimapButton)
	HandleMinimapButton(MiniMapVoiceChatFrame)

	HandleMinimapButton(MiniMapTracking)
	MiniMapTracking.Icon:SetVertexColor(0.72, 0.66, 0.56)

	HandleMinimapButton(QueueStatusMinimapButton)
	QueueStatusMinimapButton.Background:SetTexture("")

	HandleMinimapButton(GameTimeFrame)
	GameTimeFrame.NormalTexture:SetVertexColor(0.6, 0.6, 0.6, 0.65)

	local _, _, _, _, text = GameTimeFrame:GetRegions()
	text:SetDrawLayer("OVERLAY", 1)
	text:SetTextColor(0.57, 0.51, 0.41)
	text:SetFont(M.font, 14, "THINOUTLINE")
	text:ClearAllPoints()
	text:SetPoint("CENTER", 0, 0)
end
