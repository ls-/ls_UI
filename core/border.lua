local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local collectgarbage = _G.collectgarbage
local debugprofilestop = _G.debugprofilestop
local next = _G.next
local type = _G.type
local unpack = _G.unpack

-- Mine
local sections = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}
local objectToWidget = {}

local function onSizeChanged(self, w, h)
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local border = objectToWidget[self]

	local tile = (w + 2 * border.__offset) / 16
	border.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
	border.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)

	tile = (h + 2 * border.__offset) / 16
	border.LEFT:SetTexCoord(0, 0.125, 0, tile)
	border.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":OnSizeChanged", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local border_proto = {}

function border_proto:SetOffset(offset)
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self.__offset = offset
	self.TOPLEFT:SetPoint("BOTTOMRIGHT", self.__parent, "TOPLEFT", -offset, offset)
	self.TOPRIGHT:SetPoint("BOTTOMLEFT", self.__parent, "TOPRIGHT", offset, offset)
	self.BOTTOMLEFT:SetPoint("TOPRIGHT", self.__parent, "BOTTOMLEFT", -offset, -offset)
	self.BOTTOMRIGHT:SetPoint("TOPLEFT", self.__parent, "BOTTOMRIGHT", offset, -offset)

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":SetOffset", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function border_proto:SetTexture(texture)
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if type(texture) == "table" then
		for _, v in next, sections do
			self[v]:SetColorTexture(unpack(texture))
		end
	else
		for i, v in next, sections do
			if i > 4 then
				self[v]:SetTexture(texture, "REPEAT", "REPEAT")
			else
				self[v]:SetTexture(texture)
			end
		end
	end

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":SetTexture", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function border_proto:SetSize(size)
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self.__size = size
	self.TOPLEFT:SetSize(size, size)
	self.TOPRIGHT:SetSize(size, size)
	self.BOTTOMLEFT:SetSize(size, size)
	self.BOTTOMRIGHT:SetSize(size, size)
	self.TOP:SetHeight(size)
	self.BOTTOM:SetHeight(size)
	self.LEFT:SetWidth(size)
	self.RIGHT:SetWidth(size)

	onSizeChanged(self.__parent, self.__parent:GetWidth(), self.__parent:GetHeight())

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":SetSize", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function border_proto:Hide()
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for _, v in next, sections do
		self[v]:Hide()
	end

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":Hide", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function border_proto:Show()
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for _, v in next, sections do
		self[v]:Show()
	end

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":Show", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function border_proto:SetShown(isShown)
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for _, v in next, sections do
		self[v]:SetShown(isShown)
	end

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":SetShown", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function border_proto:GetVertexColor()
	return self.TOPLEFT:GetVertexColor()
end

function border_proto:SetVertexColor(r, g, b, a)
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for _, v in next, sections do
		self[v]:SetVertexColor(r, g, b, a)
	end

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":SetVertexColor", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function border_proto:SetAlpha(a)
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	for _, v in next, sections do
		self[v]:SetAlpha(a)
	end

	if P.PROFILING then
		P:LogDebugInfo(self:GetDebugName() .. ":SetAlpha", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function border_proto:IsObjectType(t)
	return t == "Border"
end

function border_proto:GetDebugName()
	return self.__parent:GetDebugName() .. ".Border"
end

function E:CreateBorder(parent, drawLayer, drawSubLevel)
	local timeStart, memStart = 0, 0
	if P.PROFILING then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local border = P:Mixin({__parent = parent}, border_proto)

	for _, v in next, sections do
		border[v] = parent:CreateTexture(nil, drawLayer or "OVERLAY", nil, drawSubLevel or 1)
		border[v]:SetSnapToPixelGrid(false)
		border[v]:SetTexelSnappingBias(0)
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

	parent:HookScript("OnSizeChanged", onSizeChanged)
	objectToWidget[parent] = border

	border:SetOffset(-8)
	border:SetSize(16)

	if P.PROFILING then
		P:LogDebugInfo("E:CreateBorder", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end

	return border
end
