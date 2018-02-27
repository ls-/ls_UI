local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

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

	self._expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

local function inset_IsExpanded(self)
	return self._expanded
end

local function inset_SetVertexColor(self, r, g, b, a)
	self.Top.Left:SetVertexColor(r, g, b, a)
	self.Top.Mid:SetVertexColor(r, g, b, a)
	self.Top.Right:SetVertexColor(r, g, b, a)

	self.Bottom.Left:SetVertexColor(r, g, b, a)
	self.Bottom.Mid:SetVertexColor(r, g, b, a)
	self.Bottom.Right:SetVertexColor(r, g, b, a)
end

local function frame_UpdateInsets(self)
	local top = self.Insets.Top
	local bottom = self.Insets.Bottom

	top._height = self._config.insets.t_height + 2
	bottom._height = self._config.insets.b_height + 2

	if top:IsExpanded() then
		top:SetHeight(top._height)
	end

	if bottom:IsExpanded() then
		bottom:SetHeight(bottom._height)
	end
end

function UF:CreateInsets(frame, texParent)
	local level = frame:GetFrameLevel()

	-- Top
	local topInset = CreateFrame("Frame", nil, frame)
	topInset:SetFrameLevel(level)
	topInset:SetPoint("TOPLEFT", 0, 0)
	topInset:SetPoint("TOPRIGHT", 0, 0)

	local texture1 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	texture1:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	texture1:SetTexCoord(1 / 64, 15 / 64, 11 / 32, 23 / 32)
	texture1:SetSize(14 / 2, 12 / 2)
	texture1:SetPoint("BOTTOMLEFT", topInset, "BOTTOMLEFT", -1, -2)

	local texture2 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	texture2:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", true)
	texture2:SetTexCoord(16 / 64, 30 / 64, 11 / 32, 23 / 32)
	texture2:SetSize(14 / 2, 12 / 2)
	texture2:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 1, -2)

	local texture3 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	texture3:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", true)
	texture3:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	texture3:SetHorizTile(true)
	texture3:SetPoint("TOPLEFT", texture1, "TOPRIGHT", 0, 0)
	texture3:SetPoint("BOTTOMRIGHT", texture2, "BOTTOMLEFT", 0, 0)

	local texture4 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 0)
	texture4:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
	texture4:SetPoint("TOPLEFT", topInset, "TOPLEFT", 0, 0)
	texture4:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 0, 2)

	local texture5 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, -1)
	texture5:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
	texture5:SetPoint("TOPLEFT", topInset, "TOPLEFT", 0, 0)
	texture5:SetPoint("BOTTOMRIGHT", topInset, "BOTTOMRIGHT", 0, 2)

	topInset.Left = texture1
	topInset.Mid = texture3
	topInset.Right = texture2
	topInset.Glass = texture4
	topInset.GlassShadow = texture5
	topInset.Expand = inset_Expand
	topInset.Collapse = inset_Collapse
	topInset.IsExpanded = inset_IsExpanded

	topInset:Collapse()

	-- Bottom
	local bottomInset = CreateFrame("Frame", nil, frame)
	bottomInset:SetFrameLevel(level)
	bottomInset:SetPoint("BOTTOMLEFT", 0, 0)
	bottomInset:SetPoint("BOTTOMRIGHT", 0, 0)

	texture1 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	texture1:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz")
	texture1:SetTexCoord(1 / 64, 15 / 64, 11 / 32, 23 / 32)
	texture1:SetSize(14 / 2, 12 / 2)
	texture1:SetPoint("TOPLEFT", bottomInset, "TOPLEFT", -1, 2)

	texture2 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	texture2:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", true)
	texture2:SetTexCoord(16 / 64, 30 / 64, 11 / 32, 23 / 32)
	texture2:SetSize(14 / 2, 12 / 2)
	texture2:SetPoint("TOPRIGHT", bottomInset, "TOPRIGHT", 1, 2)

	texture3 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 4)
	texture3:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz", true)
	texture3:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	texture3:SetHorizTile(true)
	texture3:SetPoint("TOPLEFT", texture1, "TOPRIGHT", 0, 0)
	texture3:SetPoint("BOTTOMRIGHT", texture2, "BOTTOMLEFT", 0, 0)

	texture4 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, 0)
	texture4:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
	texture4:SetPoint("TOPLEFT", bottomInset, "TOPLEFT", 0, -2)
	texture4:SetPoint("BOTTOMRIGHT", bottomInset, "BOTTOMRIGHT", 0, 0)

	texture5 = (texParent or frame):CreateTexture(nil, "OVERLAY", nil, -1)
	texture5:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
	texture5:SetPoint("TOPLEFT", bottomInset, "TOPLEFT", 0, -2)
	texture5:SetPoint("BOTTOMRIGHT", bottomInset, "BOTTOMRIGHT", 0, 0)

	bottomInset.Left = texture1
	bottomInset.Mid = texture3
	bottomInset.Right = texture2
	bottomInset.Glass = texture4
	bottomInset.GlassShadow = texture5
	bottomInset.Expand = inset_Expand
	bottomInset.Collapse = inset_Collapse
	bottomInset.IsExpanded = inset_IsExpanded

	bottomInset:Collapse()

	frame.UpdateInsets = frame_UpdateInsets

	return {
		Top = topInset,
		Bottom = bottomInset,
		SetVertexColor = inset_SetVertexColor
	}
end
