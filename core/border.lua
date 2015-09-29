-- Based on code from oUF_Phanx by Phanx <addons@phanx.net>

local _, ns = ...
local E, M = ns.E, ns.M

local sections = {"TOPLEFT", "TOP", "TOPRIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", "LEFT", "RIGHT"}

local function SetBorderColor(self, r, g, b, a)
	local t = self.BorderTextures
	if not t then return end

	for _, tex in pairs(t) do
		tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
	end
end

local function GetBorderColor(self)
	return self.BorderTextures and self.BorderTextures.TOPLEFT:GetVertexColor()
end

local function SetBorderSize(self, size, offset)
	local t = self.BorderTextures
	if not t then return end

	offset = offset or 0

	for _, tex in pairs(t) do
		tex:SetSize(size, size)
	end

	local d = E:Round(size * 5 / 10)
	local parent = t.TOPLEFT:GetParent()

	t.TOPLEFT:SetPoint("TOPLEFT", parent, -d - offset, d + offset)
	t.TOPRIGHT:SetPoint("TOPRIGHT", parent, d + offset, d + offset)
	t.BOTTOMLEFT:SetPoint("BOTTOMLEFT", parent, -d - offset, -d - offset)
	t.BOTTOMRIGHT:SetPoint("BOTTOMRIGHT", parent, d + offset, -d - offset)

	t.TOPLEFT.offset = offset
end

local function GetBorderSize(self)
	local t = self.BorderTextures
	if not t then return end

	return t.TOPLEFT:GetWidth(), t.TOPLEFT.offset
end

function E:CreateBorder(object, size, offset)
	if type(object) ~= "table" or not object.CreateTexture or object.BorderTextures then return end

	local t = {}

	for i = 1, #sections do
		local x = object:CreateTexture(nil, "BORDER", nil, 2)
		x:SetTexture(M.textures.button.normal)
		t[sections[i]] = x
	end

	t.TOPLEFT:SetTexCoord(0, 10 / 64, 0, 10 / 64)
	t.TOP:SetTexCoord(10 / 64, 54 / 64, 0, 10 / 64)
	t.TOPRIGHT:SetTexCoord(54 / 64, 1, 0, 10 / 64)

	t.BOTTOMLEFT:SetTexCoord(0, 10 / 64, 54 / 64, 1)
	t.BOTTOM:SetTexCoord(10 / 64, 54 / 64, 54 / 64, 1)
	t.BOTTOMRIGHT:SetTexCoord(54 / 64, 1, 54 / 64, 1)

	t.LEFT:SetTexCoord(0, 10 / 64, 10 / 64, 54 / 64)
	t.RIGHT:SetTexCoord(54 / 64, 1, 10 / 64, 54 / 64)

	t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT")
	t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT")

	t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT")
	t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT")

	t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT")
	t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT")

	t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT")
	t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT")

	object.BorderTextures = t

	object.SetBorderColor = SetBorderColor
	object.SetBorderSize = SetBorderSize

	object.GetBorderColor = GetBorderColor
	object.GetBorderSize = GetBorderSize

	object:SetBorderSize(size or 10, offset or 0)
end
