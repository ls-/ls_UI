local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function CollapseHoriz(self)
	self:SetHeight(0.001)

	self.Left:Hide()
	self.Mid:Hide()
	self.Right:Hide()
	self.Glass:Hide()

	self._expanded = false

	if self.PostCollapse then
		self:PostCollapse()
	end
end

local function ExpandHoriz(self)
	self:SetHeight(self._height)

	self.Left:Show()
	self.Mid:Show()
	self.Right:Show()
	self.Glass:Show()

	self._expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

local function IsExpanded(self)
	return self._expanded
end

local function SetVertexColor(self, r, g, b, a)
	self.Top.Left:SetVertexColor(r, g, b, a)
	self.Top.Mid:SetVertexColor(r, g, b, a)
	self.Top.Right:SetVertexColor(r, g, b, a)

	self.Bottom.Left:SetVertexColor(r, g, b, a)
	self.Bottom.Mid:SetVertexColor(r, g, b, a)
	self.Bottom.Right:SetVertexColor(r, g, b, a)
end

function UF:CreateInsets(parent, texParent)
	local level = parent:GetFrameLevel()

	-- Top
	local top_inset = _G.CreateFrame("Frame", nil, parent)
	top_inset:SetFrameLevel(level)
	top_inset:SetPoint("TOPLEFT", 0, 0)
	top_inset:SetPoint("TOPRIGHT", 0, 0)

	local texture1 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture1:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz")
	texture1:SetTexCoord(1 / 64, 15 / 64, 11 / 32, 23 / 32)
	texture1:SetSize(14 / 2, 12 / 2)
	texture1:SetPoint("BOTTOMLEFT", top_inset, "BOTTOMLEFT", -1, -2)

	local texture2 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture2:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture2:SetTexCoord(16 / 64, 30 / 64, 11 / 32, 23 / 32)
	texture2:SetSize(14 / 2, 12 / 2)
	texture2:SetPoint("BOTTOMRIGHT", top_inset, "BOTTOMRIGHT", 1, -2)

	local texture3 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture3:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture3:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	texture3:SetHorizTile(true)
	texture3:SetPoint("TOPLEFT", texture1, "TOPRIGHT", 0, 0)
	texture3:SetPoint("BOTTOMRIGHT", texture2, "BOTTOMLEFT", 0, 0)

	local texture4 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 0)
	texture4:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal", true)
	texture4:SetTexCoord(0 / 128, 128 / 128, 1 / 256, 25 / 256)
	texture4:SetHorizTile(true)
	texture4:SetPoint("TOPLEFT", top_inset, "TOPLEFT", 0, 0)
	texture4:SetPoint("BOTTOMRIGHT", top_inset, "BOTTOMRIGHT", 0, 2)

	top_inset.Left = texture1
	top_inset.Mid = texture3
	top_inset.Right = texture2
	top_inset.Glass = texture4
	top_inset.Expand = ExpandHoriz
	top_inset.Collapse = CollapseHoriz
	top_inset.IsExpanded = IsExpanded

	top_inset:Collapse()

	-- Bottom
	local bottom_inset = _G.CreateFrame("Frame", nil, parent)
	bottom_inset:SetFrameLevel(level)
	bottom_inset:SetPoint("BOTTOMLEFT", 0, 0)
	bottom_inset:SetPoint("BOTTOMRIGHT", 0, 0)

	texture1 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture1:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz")
	texture1:SetTexCoord(1 / 64, 15 / 64, 11 / 32, 23 / 32)
	texture1:SetSize(14 / 2, 12 / 2)
	texture1:SetPoint("TOPLEFT", bottom_inset, "TOPLEFT", -1, 2)

	texture2 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture2:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture2:SetTexCoord(16 / 64, 30 / 64, 11 / 32, 23 / 32)
	texture2:SetSize(14 / 2, 12 / 2)
	texture2:SetPoint("TOPRIGHT", bottom_inset, "TOPRIGHT", 1, 2)

	texture3 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture3:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture3:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	texture3:SetHorizTile(true)
	texture3:SetPoint("TOPLEFT", texture1, "TOPRIGHT", 0, 0)
	texture3:SetPoint("BOTTOMRIGHT", texture2, "BOTTOMLEFT", 0, 0)

	texture4 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 0)
	texture4:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal", true)
	texture4:SetTexCoord(0 / 128, 128 / 128, 1 / 256, 25 / 256)
	texture4:SetHorizTile(true)
	texture4:SetPoint("TOPLEFT", bottom_inset, "TOPLEFT", 0, -2)
	texture4:SetPoint("BOTTOMRIGHT", bottom_inset, "BOTTOMRIGHT", 0, 0)

	bottom_inset.Left = texture1
	bottom_inset.Mid = texture3
	bottom_inset.Right = texture2
	bottom_inset.Glass = texture4
	bottom_inset.Expand = ExpandHoriz
	bottom_inset.Collapse = CollapseHoriz
	bottom_inset.IsExpanded = IsExpanded

	bottom_inset:Collapse()

	return {
		Top = top_inset,
		Bottom = bottom_inset,
		SetVertexColor = SetVertexColor
	}
end

function UF:UpdateInsets(frame)
	local config = frame._config.insets
	local top = frame.Insets.Top
	local bottom = frame.Insets.Bottom

	top._height = config.t_height
	bottom._height = config.b_height

	if top:IsExpanded() then
		top:SetHeight(config.t_height)
	end

	if bottom:IsExpanded() then
		bottom:SetHeight(config.b_height)
	end
end
