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
local function inset_Collapse(self)
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

local function inset_Expand(self)
	self:SetHeight(self._height)

	self.Left:Show()
	self.Mid:Show()
	self.Right:Show()
	self.Glass:Show()
	self.GlassShadow:Show()

	for _, sep in next, self.Seps do
		sep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, self._height / 4)
		sep:SetSize(12, self._height)
	end

	self._expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

local function inset_IsExpanded(self)
	return self._expanded
end

local function inset_GetVertexColor(self)
	return self.Top.Left:GetVertexColor()
end

local function inset_SetVertexColor(self, r, g, b, a)
	self.Top.Left:SetVertexColor(r, g, b, a)
	self.Top.Mid:SetVertexColor(r, g, b, a)
	self.Top.Right:SetVertexColor(r, g, b, a)

	self.Bottom.Left:SetVertexColor(r, g, b, a)
	self.Bottom.Mid:SetVertexColor(r, g, b, a)
	self.Bottom.Right:SetVertexColor(r, g, b, a)
end

local function updateInset(inset, height)
	inset._height = height

	if inset:IsExpanded() then
		inset:SetHeight(height)

		for _, sep in next, inset.Seps do
			sep:SetTexCoord(1 / 32, 25 / 32, 0 / 8, height / 4)
			sep:SetSize(12, height)
		end
	end
end

local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].insets, self._config)
end

local function element_UpdateTopInset(self)
	updateInset(self.Top, self._config.t_height)
end

local function element_UpdateBottomInset(self)
	updateInset(self.Bottom, self._config.b_height)
end

local function frame_UpdateInsets(self)
	local element = self.Insets
	element:UpdateConfig()
	element:UpdateBottomInset()
	element:UpdateTopInset()
end

function UF:CreateInsets(frame, texParent)
	local level = frame:GetFrameLevel()

	-- Top
	local topInset = CreateFrame("Frame", nil, frame)
	topInset:SetFrameLevel(level)
	topInset:SetPoint("TOPLEFT", 0, 0)
	topInset:SetPoint("TOPRIGHT", 0, 0)

	local left = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	left:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	left:SetTexCoord(1 / 64, 17 / 64, 11 / 32, 23 / 32)
	left:SetSize(16 / 2, 12 / 2)
	left:SetPoint("BOTTOMLEFT", topInset, "BOTTOMLEFT", 0, -2)

	local right = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	right:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", true)
	right:SetTexCoord(18 / 64, 34 / 64, 11 / 32, 23 / 32)
	right:SetSize(16 / 2, 12 / 2)
	right:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 0, -2)

	local mid = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	mid:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", true)
	mid:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	mid:SetHorizTile(true)
	mid:SetPoint("TOPLEFT", left, "TOPRIGHT", 0, 0)
	mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT", 0, 0)

	local glass = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
	glass:SetPoint("TOPLEFT", topInset, "TOPLEFT", 0, 0)
	glass:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 0, 2)

	local shadow = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
	shadow:SetPoint("TOPLEFT", topInset, "TOPLEFT", 0, 0)
	shadow:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 0, 2)

	local seps, sep = {}
	for i = 1, 9 do
		sep = (texParent or frame):CreateTexture(nil, "ARTWORK", nil, 1)
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
	topInset.Expand = inset_Expand
	topInset.Collapse = inset_Collapse
	topInset.IsExpanded = inset_IsExpanded

	topInset:Collapse()

	-- Bottom
	local bottomInset = CreateFrame("Frame", nil, frame)
	bottomInset:SetFrameLevel(level)
	bottomInset:SetPoint("BOTTOMLEFT", 0, 0)
	bottomInset:SetPoint("BOTTOMRIGHT", 0, 0)

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
	bottomInset.Expand = inset_Expand
	bottomInset.Collapse = inset_Collapse
	bottomInset.IsExpanded = inset_IsExpanded

	bottomInset:Collapse()

	frame.UpdateInsets = frame_UpdateInsets

	return {
		__owner = frame,
		Bottom = bottomInset,
		GetVertexColor = inset_GetVertexColor,
		SetVertexColor = inset_SetVertexColor,
		Top = topInset,
		UpdateBottomInset = element_UpdateBottomInset,
		UpdateConfig = element_UpdateConfig,
		UpdateTopInset = element_UpdateTopInset,
	}
end
