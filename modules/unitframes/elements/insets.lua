local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local next = _G.next

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local function horizInset_Collapse(self)
	self:SetHeight(0.001)

	self.Left:Hide()
	self.Mid:Hide()
	self.Right:Hide()
	self.Glass:Hide()
	self.GlassShadow:Hide()

	for _, sep in next, self.Seps do
		sep:Hide()
	end

	self._expanded = false

	if self.PostCollapse then
		self:PostCollapse()
	end
end

local function horizInset_Expand(self)
	self:SetHeight(self._height)

	self.Left:Show()
	self.Mid:Show()
	self.Right:Show()
	self.Glass:Show()
	self.GlassShadow:Show()

	for _, sep in next, self.Seps do
		sep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, self._height / 4)
		sep:SetSize(12, self._height - 2)
	end

	self._expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

local function updateHorizInset(self, size)
	self._height = size

	local tile = (self:GetWidth() - 16) / 32

	self.Mid:SetTexCoord(0, tile, 0, 0.375)

	if self:IsExpanded() then
		self:SetHeight(size)

		for _, sep in next, self.Seps do
			sep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, size / 4)
			sep:SetSize(12, size - 2)
		end
	end
end

local function vertInset_Collapse(self)
	self:SetWidth(0.001)

	self.Top:Hide()
	self.Mid:Hide()
	self.Bottom:Hide()
	self.Glass:Hide()
	self.GlassShadow:Hide()

	self._expanded = false

	if self.PostCollapse then
		self:PostCollapse()
	end
end

local function vertInset_Expand(self)
	self:SetWidth(self._width)

	self.Top:Show()
	self.Mid:Show()
	self.Bottom:Show()
	self.Glass:Show()
	self.GlassShadow:Show()

	self._expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

local function updateVertInset(self, size)
	self._width = size

	local tile = (self:GetHeight() - 16) / 32

	self.Mid:SetTexCoord(tile, 0, 0, 0, tile, 0.375, 0, 0.375)

	if self:IsExpanded() then
		self:SetWidth(size)
	end
end

local function inset_Capture(self, object, l, r, t, b)
	object:ClearAllPoints()
	object:SetPoint("LEFT", self, "LEFT", l or 0, 0)
	object:SetPoint("RIGHT", self, "RIGHT", r or 0, 0)
	object:SetPoint("TOP", self, "TOP", 0, t or 0)
	object:SetPoint("BOTTOM", self, "BOTTOM", 0, b or 0)
end

local function inset_IsExpanded(self)
	return self._expanded
end

local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].insets, self._config)
	self._config.l_width = C.db.profile.units[unit].height
	self._config.r_width = C.db.profile.units[unit].height
end

local function element_UpdateLeftInset(self)
	updateVertInset(self.Left, self._config.l_width)
end

local function element_UpdateRightInset(self)
	updateVertInset(self.Right, self._config.r_width)
end

local function element_UpdateTopInset(self)
	updateHorizInset(self.Top, self._config.t_height)
end

local function element_UpdateBottomInset(self)
	updateHorizInset(self.Bottom, self._config.b_height)
end

local function element_GetVertexColor(self)
	return self.Top.Left:GetVertexColor()
end

local function element_SetVertexColor(self, r, g, b, a)
	self.Left.Top:SetVertexColor(r, g, b, a)
	self.Left.Mid:SetVertexColor(r, g, b, a)
	self.Left.Bottom:SetVertexColor(r, g, b, a)

	self.Right.Top:SetVertexColor(r, g, b, a)
	self.Right.Mid:SetVertexColor(r, g, b, a)
	self.Right.Bottom:SetVertexColor(r, g, b, a)

	self.Top.Left:SetVertexColor(r, g, b, a)
	self.Top.Mid:SetVertexColor(r, g, b, a)
	self.Top.Right:SetVertexColor(r, g, b, a)

	self.Bottom.Left:SetVertexColor(r, g, b, a)
	self.Bottom.Mid:SetVertexColor(r, g, b, a)
	self.Bottom.Right:SetVertexColor(r, g, b, a)
end

local function frame_UpdateInsets(self)
	local element = self.Insets

	element:UpdateConfig()
	element:UpdateLeftInset()
	element:UpdateRightInset()
	element:UpdateTopInset()
	element:UpdateBottomInset()
end

function UF:CreateInsets(frame, texParent)
	local level = frame:GetFrameLevel()

	-- Left
	local leftInset = CreateFrame("Frame", nil, frame)
	leftInset:SetFrameLevel(level)
	leftInset:SetPoint("TOPLEFT", 0, 0)
	leftInset:SetPoint("BOTTOMLEFT", 0, 0)

	local top = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	top:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	top:SetTexCoord(0.53125, 0.34375, 0.28125, 0.34375, 0.53125, 0.71875, 0.28125, 0.71875)
	top:SetSize(12 / 2, 16 / 2)
	top:SetPoint("TOPRIGHT", leftInset, "TOPRIGHT", 2, 0)

	local bottom = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	bottom:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	bottom:SetTexCoord(0.265625, 0.34375, 0.015625, 0.34375, 0.265625, 0.71875, 0.015625, 0.71875)
	bottom:SetSize(12 / 2, 16 / 2)
	bottom:SetPoint("BOTTOMRIGHT", leftInset, "BOTTOMRIGHT", 2, 0)

	local mid = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	mid:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", "REPEAT", "REPEAT")
	mid:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, 0)
	mid:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT", 0, 0)

	local glass = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
	glass:SetPoint("TOPLEFT", leftInset, "TOPLEFT", 0, 0)
	glass:SetPoint("BOTTOMRIGHT", leftInset, "BOTTOMRIGHT", -2, 0)

	local shadow = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
	shadow:SetPoint("TOPLEFT", leftInset, "TOPLEFT", 0, 0)
	shadow:SetPoint("BOTTOMRIGHT", leftInset, "BOTTOMRIGHT", -2, 0)


	leftInset.Top = top
	leftInset.Mid = mid
	leftInset.Bottom = bottom
	leftInset.Glass = glass
	leftInset.GlassShadow = shadow
	leftInset.Collapse = vertInset_Collapse
	leftInset.Expand = vertInset_Expand
	leftInset.IsExpanded = inset_IsExpanded
	leftInset.Capture = inset_Capture

	leftInset:Collapse()

	-- Right
	local rightInset = CreateFrame("Frame", nil, frame)
	rightInset:SetFrameLevel(level)
	rightInset:SetPoint("TOPRIGHT", 0, 0)
	rightInset:SetPoint("BOTTOMRIGHT", 0, 0)

	top = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	top:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	top:SetTexCoord(0.53125, 0.34375, 0.28125, 0.34375, 0.53125, 0.71875, 0.28125, 0.71875)
	top:SetSize(12 / 2, 16 / 2)
	top:SetPoint("TOPLEFT", rightInset, "TOPLEFT", -2, 0)

	bottom = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	bottom:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	bottom:SetTexCoord(0.265625, 0.34375, 0.015625, 0.34375, 0.265625, 0.71875, 0.015625, 0.71875)
	bottom:SetSize(12 / 2, 16 / 2)
	bottom:SetPoint("BOTTOMLEFT", rightInset, "BOTTOMLEFT", -2, 0)

	mid = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	mid:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", "REPEAT", "REPEAT")
	mid:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, 0)
	mid:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT", 0, 0)

	glass = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
	glass:SetPoint("TOPLEFT", rightInset, "TOPLEFT", 2, 0)
	glass:SetPoint("BOTTOMRIGHT", rightInset, "BOTTOMRIGHT", 0, 0)

	shadow = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
	shadow:SetPoint("TOPLEFT", rightInset, "TOPLEFT", 2, 0)
	shadow:SetPoint("BOTTOMRIGHT", rightInset, "BOTTOMRIGHT", 0, 0)

	rightInset.Top = top
	rightInset.Mid = mid
	rightInset.Bottom = bottom
	rightInset.Glass = glass
	rightInset.GlassShadow = shadow
	rightInset.Collapse = vertInset_Collapse
	rightInset.Expand = vertInset_Expand
	rightInset.IsExpanded = inset_IsExpanded
	rightInset.Capture = inset_Capture

	-- rightInset._expanded = true
	rightInset:Collapse()

	-- Top
	local topInset = CreateFrame("Frame", nil, frame)
	topInset:SetFrameLevel(level)
	topInset:SetPoint("TOPLEFT", leftInset, "TOPRIGHT", 0, 0)
	topInset:SetPoint("TOPRIGHT", rightInset, "TOPLEFT", 0, 0)

	local left = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	left:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	left:SetTexCoord(1 / 64, 17 / 64, 11 / 32, 23 / 32)
	left:SetSize(16 / 2, 12 / 2)
	left:SetPoint("BOTTOMLEFT", topInset, "BOTTOMLEFT", 0, -2)

	local right = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	right:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	right:SetTexCoord(18 / 64, 34 / 64, 11 / 32, 23 / 32)
	right:SetSize(16 / 2, 12 / 2)
	right:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 0, -2)

	mid = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	mid:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", "REPEAT", "REPEAT")
	-- mid:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	mid:SetHorizTile(true)
	mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
	mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)

	glass = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
	glass:SetPoint("TOPLEFT", topInset, "TOPLEFT", 0, 0)
	glass:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 0, 2)

	shadow = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
	shadow:SetPoint("TOPLEFT", topInset, "TOPLEFT", 0, 0)
	shadow:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 0, 2)

	local seps, sep = {}
	for i = 1, 9 do
		sep = (texParent or frame):CreateTexture(nil, "ARTWORK", nil, 1)
		sep:SetPoint("TOP", topInset, "TOP", 0, 0)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
		sep:Hide()
		seps[i] = sep
	end

	topInset.Left = left
	topInset.Mid = mid
	topInset.Right = right
	topInset.Glass = glass
	topInset.GlassShadow = shadow
	topInset.Seps = seps
	topInset.Expand = horizInset_Expand
	topInset.Collapse = horizInset_Collapse
	topInset.IsExpanded = inset_IsExpanded
	topInset.Capture = inset_Capture

	topInset:Collapse()

	-- Bottom
	local bottomInset = CreateFrame("Frame", nil, frame)
	bottomInset:SetFrameLevel(level)
	bottomInset:SetPoint("BOTTOMLEFT", leftInset, "BOTTOMRIGHT", 0, 0)
	bottomInset:SetPoint("BOTTOMRIGHT", rightInset, "BOTTOMLEFT", 0, 0)

	left = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	left:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	left:SetTexCoord(1 / 64, 17 / 64, 11 / 32, 23 / 32)
	left:SetSize(16 / 2, 12 / 2)
	left:SetPoint("TOPLEFT", bottomInset, "TOPLEFT", 0, 2)

	right = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	right:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", true)
	right:SetTexCoord(18 / 64, 34 / 64, 11 / 32, 23 / 32)
	right:SetSize(16 / 2, 12 / 2)
	right:SetPoint("TOPRIGHT", bottomInset, "TOPRIGHT", 0, 2)

	mid = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	mid:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", true)
	mid:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	mid:SetHorizTile(true)
	mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
	mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)

	glass = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
	glass:SetPoint("TOPLEFT", bottomInset, "TOPLEFT", 0, -2)
	glass:SetPoint("BOTTOMRIGHT", bottomInset, "BOTTOMRIGHT", 0, 0)

	shadow = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
	shadow:SetPoint("TOPLEFT", bottomInset, "TOPLEFT", 0, -2)
	shadow:SetPoint("BOTTOMRIGHT", bottomInset, "BOTTOMRIGHT", 0, 0)

	seps = {}
	for i = 1, 9 do
		sep = (texParent or frame):CreateTexture(nil, "ARTWORK", nil, 1)
		sep:SetPoint("BOTTOM", bottomInset, "BOTTOM", 0, 0)
		sep:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-sep", "REPEAT", "REPEAT")
		sep:Hide()
		seps[i] = sep
	end

	bottomInset.Left = left
	bottomInset.Mid = mid
	bottomInset.Right = right
	bottomInset.Glass = glass
	bottomInset.GlassShadow = shadow
	bottomInset.Seps = seps
	bottomInset.Expand = horizInset_Expand
	bottomInset.Collapse = horizInset_Collapse
	bottomInset.IsExpanded = inset_IsExpanded
	bottomInset.Capture = inset_Capture

	bottomInset:Collapse()

	frame.UpdateInsets = frame_UpdateInsets

	return {
		__owner = frame,
		GetVertexColor = element_GetVertexColor,
		SetVertexColor = element_SetVertexColor,
		Left = leftInset,
		Right = rightInset,
		Bottom = bottomInset,
		Top = topInset,
		UpdateConfig = element_UpdateConfig,
		UpdateLeftInset = element_UpdateLeftInset,
		UpdateRightInset = element_UpdateRightInset,
		UpdateTopInset = element_UpdateTopInset,
		UpdateBottomInset = element_UpdateBottomInset,
	}
end
