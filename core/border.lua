local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next
local type = _G.type
local unpack = _G.unpack

-- Mine
local sections = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}

local function border_SetOffset(self, offset)
	self.offset = offset
	self.TOPLEFT:SetPoint("BOTTOMRIGHT", self.parent, "TOPLEFT", -offset, offset)
	self.TOPRIGHT:SetPoint("BOTTOMLEFT", self.parent, "TOPRIGHT", offset, offset)
	self.BOTTOMLEFT:SetPoint("TOPRIGHT", self.parent, "BOTTOMLEFT", -offset, -offset)
	self.BOTTOMRIGHT:SetPoint("TOPLEFT", self.parent, "BOTTOMRIGHT", offset, -offset)
end

local function border_SetTexture(self, texture)
	if type(texture) == "table" then
		self.calcTile = false

		for _, v in next, sections do
			self[v]:SetColorTexture(unpack(texture))
		end
	else
		self.calcTile = true

		for i, v in next, sections do
			if i > 4 then
				self[v]:SetTexture(texture, "REPEAT", "REPEAT")
			else
				self[v]:SetTexture(texture)
			end
		end
	end
end

local function border_SetSize(self, size)
	if size < 1 then
		size = 1
	end

	self.size = size
	self.TOPLEFT:SetSize(size, size)
	self.TOPRIGHT:SetSize(size, size)
	self.BOTTOMLEFT:SetSize(size, size)
	self.BOTTOMRIGHT:SetSize(size, size)
	self.TOP:SetHeight(size)
	self.BOTTOM:SetHeight(size)
	self.LEFT:SetWidth(size)
	self.RIGHT:SetWidth(size)

	if self.calcTile then
		local tile = (self.parent:GetWidth() + 2 * self.offset) / size
		self.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
		self.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)
		self.LEFT:SetTexCoord(0, 0.125, 0, tile)
		self.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)
	end
end

local function border_Hide(self)
	for _, v in next, sections do
		self[v]:Hide()
	end
end

local function border_Show(self)
	for _, v in next, sections do
		self[v]:Show()
	end
end

local function border_SetVertexColor(self, r, g, b, a)
	for _, v in next, sections do
		self[v]:SetVertexColor(r, g, b, a)
	end
end

local function border_IsObjectType()
	return false
end

function E:CreateBorder(parent, drawLayer, drawSubLevel)
	local border = {
		calcTile = true,
		offset = 0,
		parent = parent,
		size = 1,
	}

	for _, v in next, sections do
		border[v] = parent:CreateTexture(nil, drawLayer or "OVERLAY", nil, drawSubLevel or 1)
	end

	border.TOPLEFT:SetTexCoord(0.5, 0.625, 0, 1)
	border.TOPRIGHT:SetTexCoord(0.625, 0.75, 0, 1)
	border.BOTTOMLEFT:SetTexCoord(0.75, 0.875, 0, 1)
	border.BOTTOMRIGHT:SetTexCoord(0.875, 1, 0, 1)

	border.TOP:SetPoint("TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	border.TOP:SetPoint("TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)

	border.BOTTOM:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

	border.LEFT:SetPoint("TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)

	border.RIGHT:SetPoint("TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	border.RIGHT:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	border.Hide = border_Hide
	border.IsObjectType = border_IsObjectType
	border.SetOffset = border_SetOffset
	border.SetSize = border_SetSize
	border.SetTexture = border_SetTexture
	border.SetVertexColor = border_SetVertexColor
	border.Show = border_Show

	return border
end
