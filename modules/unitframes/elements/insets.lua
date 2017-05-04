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

	self._expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

local function CollapseVert(self)
	self:SetWidth(0.001)

	self.Top:Hide()
	self.Mid:Hide()
	self.Bottom:Hide()

	self._expanded = false

	if self.PostCollapse then
		self:PostCollapse()
	end
end

local function ExpandVert(self)
	self:SetWidth(self._width)

	self.Top:Show()
	self.Mid:Show()
	self.Bottom:Show()

	self._expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

local function IsExpanded(self)
	return self._expanded
end

function UF:CreateInsets(parent, texParent, frameLevel)
	-- Top
	local top_inset = _G.CreateFrame("Frame", nil, parent)
	top_inset:SetFrameLevel(frameLevel)
	top_inset:SetPoint("TOPLEFT", 0, 0)
	top_inset:SetPoint("TOPRIGHT", 0, 0)

	local texture1 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 3)
	texture1:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz")
	texture1:SetTexCoord(1 / 64, 15 / 64, 11 / 32, 23 / 32)
	texture1:SetSize(14 / 2, 12 / 2)
	texture1:SetPoint("BOTTOMLEFT", top_inset, "BOTTOMLEFT", -1, -2)

	local texture2 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 3)
	texture2:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture2:SetTexCoord(16 / 64, 30 / 64, 11 / 32, 23 / 32)
	texture2:SetSize(14 / 2, 12 / 2)
	texture2:SetPoint("BOTTOMRIGHT", top_inset, "BOTTOMRIGHT", 1, -2)

	local texture3 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 3)
	texture3:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture3:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	texture3:SetHorizTile(true)
	texture3:SetPoint("TOPLEFT", texture1, "TOPRIGHT", 0, 0)
	texture3:SetPoint("BOTTOMRIGHT", texture2, "BOTTOMLEFT", 0, 0)

	-- top_inset._height = tHeight
	top_inset.Left = texture1
	top_inset.Mid = texture3
	top_inset.Right = texture2
	top_inset.Expand = ExpandHoriz
	top_inset.Collapse = CollapseHoriz
	top_inset.IsExpanded = IsExpanded

	top_inset:Collapse()

	-- Bottom
	local bottom_inset = _G.CreateFrame("Frame", nil, parent)
	bottom_inset:SetFrameLevel(frameLevel)
	bottom_inset:SetPoint("BOTTOMLEFT", 0, 0)
	bottom_inset:SetPoint("BOTTOMRIGHT", 0, 0)

	texture1 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 3)
	texture1:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz")
	texture1:SetTexCoord(1 / 64, 15 / 64, 11 / 32, 23 / 32)
	texture1:SetSize(14 / 2, 12 / 2)
	texture1:SetPoint("TOPLEFT", bottom_inset, "TOPLEFT", -1, 2)

	texture2 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 3)
	texture2:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture2:SetTexCoord(16 / 64, 30 / 64, 11 / 32, 23 / 32)
	texture2:SetSize(14 / 2, 12 / 2)
	texture2:SetPoint("TOPRIGHT", bottom_inset, "TOPRIGHT", 1, 2)

	texture3 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 3)
	texture3:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture3:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	texture3:SetHorizTile(true)
	texture3:SetPoint("TOPLEFT", texture1, "TOPRIGHT", 0, 0)
	texture3:SetPoint("BOTTOMRIGHT", texture2, "BOTTOMLEFT", 0, 0)

	-- bottom_inset._height = bHeight
	bottom_inset.Left = texture1
	bottom_inset.Mid = texture3
	bottom_inset.Right = texture2
	bottom_inset.Expand = ExpandHoriz
	bottom_inset.Collapse = CollapseHoriz
	bottom_inset.IsExpanded = IsExpanded

	bottom_inset:Collapse()

	-- Left
	local left_inset = _G.CreateFrame("Frame", nil, parent)
	left_inset:SetFrameLevel(frameLevel)
	left_inset:SetPoint("TOPLEFT", top_inset, "BOTTOMLEFT", 0, 0)
	left_inset:SetPoint("BOTTOMLEFT", bottom_inset, "TOPLEFT", 0, 0)

	texture1 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture1:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert")
	texture1:SetTexCoord(11 / 32, 23 / 32, 1 / 64, 15 / 64)
	texture1:SetSize(12 / 2, 14 / 2)
	texture1:SetPoint("TOPRIGHT", left_inset, "TOPRIGHT", 2, 1)

	texture2 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture2:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert", true)
	texture2:SetTexCoord(11 / 32, 23 / 32, 16 / 64, 30 / 64)
	texture2:SetSize(12 / 2, 14 / 2)
	texture2:SetPoint("BOTTOMRIGHT", left_inset, "BOTTOMRIGHT", 2, -1)

	texture3 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture3:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert", true)
	texture3:SetTexCoord(0 / 32, 12 / 32, 0 / 64, 12 / 64)
	texture3:SetVertTile(true)
	texture3:SetPoint("TOPLEFT", texture1, "BOTTOMLEFT", 0, 0)
	texture3:SetPoint("BOTTOMRIGHT", texture2, "TOPRIGHT", 0, 0)

	-- left_inset._width = lWidth
	left_inset.Top = texture1
	left_inset.Mid = texture3
	left_inset.Bottom = texture2
	left_inset.Expand = ExpandVert
	left_inset.Collapse = CollapseVert
	left_inset.IsExpanded = IsExpanded

	left_inset:Collapse()

	-- Right
	local right_inset = _G.CreateFrame("Frame", nil, parent)
	right_inset:SetFrameLevel(frameLevel)
	right_inset:SetPoint("TOPRIGHT", top_inset, "BOTTOMRIGHT", 0, 0)
	right_inset:SetPoint("BOTTOMRIGHT", bottom_inset, "TOPRIGHT", 0, 0)

	texture1 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture1:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert")
	texture1:SetTexCoord(11 / 32, 23 / 32, 1 / 64, 15 / 64)
	texture1:SetSize(12 / 2, 14 / 2)
	texture1:SetPoint("TOPLEFT", right_inset, "TOPLEFT", -2, 1)

	texture2 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture2:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert", true)
	texture2:SetTexCoord(11 / 32, 23 / 32, 16 / 64, 30 / 64)
	texture2:SetSize(12 / 2, 14 / 2)
	texture2:SetPoint("BOTTOMLEFT", right_inset, "BOTTOMLEFT", -2, -1)

	texture3 = (texParent or parent):CreateTexture(nil, "OVERLAY", nil, 4)
	texture3:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert", true)
	texture3:SetTexCoord(0 / 32, 12 / 32, 0 / 64, 12 / 64)
	texture3:SetVertTile(true)
	texture3:SetPoint("TOPLEFT", texture1, "BOTTOMLEFT", 0, 0)
	texture3:SetPoint("BOTTOMRIGHT", texture2, "TOPRIGHT", 0, 0)

	-- right_inset._width = rWidth
	right_inset.Top = texture1
	right_inset.Mid = texture3
	right_inset.Bottom = texture2
	right_inset.Expand = ExpandVert
	right_inset.Collapse = CollapseVert
	right_inset.IsExpanded = IsExpanded

	right_inset:Collapse()

	return {
		Top = top_inset,
		Bottom = bottom_inset,
		Left = left_inset,
		Right = right_inset
	}
end

function UF:UpdateInsets(frame)
	local config = frame._config.insets
	local element = frame.Insets

	element.Top._height = config.t_height
	element.Bottom._height = config.b_height
	element.Left._width = config.l_width
	element.Right._width = config.r_width
end
