local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_max = _G.math.max
local next = _G.next
local unpack = _G.unpack

-- Mine
local hooked = {}
local objectToWidget = {}

local function hook(self)
	if objectToWidget[self] then
		objectToWidget[self]:Refresh()
	end
end

local frame_proto = {}

function frame_proto:UpdateLayout()
	local insets = self.Insets
	insets:UpdateConfig()

	insets.Left:UpdateSize(insets._config.l_size)
	insets.Left:Refresh()

	insets.Right:UpdateSize(insets._config.r_size)
	insets.Right:Refresh()

	insets.Top:UpdateSize(insets._config.t_size)
	insets.Top:Refresh()

	insets.Bottom:UpdateSize(insets._config.b_size)
	insets.Bottom:Refresh()
end

function frame_proto:UpdateInlay()
	self.Inlay:SetAlpha(C.db.profile.units.inlay.gloss)
end

local gradientColorMin = {r = 0, g = 0, b = 0, a = 0}
local gradientColorMax = {r = 0, g = 0, b = 0, a = 0.35}

function frame_proto:UpdateGradient()
	gradientColorMax.a = C.db.profile.units.inlay.gradient

	self.Insets.Left[4]:SetGradient("VERTICAL", gradientColorMin, gradientColorMax)
	self.Insets.Right[4]:SetGradient("VERTICAL", gradientColorMin, gradientColorMax)
	self.Insets.Top[4]:SetGradient("VERTICAL", gradientColorMin, gradientColorMax)
	self.Insets.Bottom[4]:SetGradient("VERTICAL", gradientColorMin, gradientColorMax)

	self.Inlay.Gradient:SetGradient("VERTICAL", gradientColorMin, gradientColorMax)
end

function frame_proto:SetSmoothBorderColor(r, g, b, a)
	local color = self.ColorAnim.color
	a = a or 1

	if color.r == r and color.g == g and color.b == b and color.a == a then return end

	color.r, color.g, color.b, color.a = self.Border:GetVertexColor()

	for i = 1, #self.ColorAnim do
		self.ColorAnim[i]:SetStartColor(color)
	end

	color.r, color.g, color.b, color.a = r, g, b, a

	for i = 1, #self.ColorAnim do
		self.ColorAnim[i]:SetEndColor(color)
	end

	self.ColorAnim:Play()
end

local insets_proto = {}

function insets_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].insets, self._config)
	self._config.l_size = C.db.profile.units[unit].height
	self._config.r_size = self._config.l_size
	self._config.t_size = m_max(6, E:Round(C.db.profile.units[unit].height * self._config.t_size))
	self._config.b_size = m_max(6, E:Round(C.db.profile.units[unit].height * self._config.b_size))
end

function insets_proto:GetVertexColor()
	return self.Left[1]:GetVertexColor()
end

function insets_proto:SetVertexColor(...)
	self.Left[1]:SetVertexColor(...)
	self.Left[2]:SetVertexColor(...)
	self.Left[3]:SetVertexColor(...)

	self.Right[1]:SetVertexColor(...)
	self.Right[2]:SetVertexColor(...)
	self.Right[3]:SetVertexColor(...)
end

local inset_proto = {
	__size = 0, -- to avoid any errors on load
}

function inset_proto:IsExpanded()
	return self.__expanded
end

function inset_proto:Capture(object, l, r, t, b)
	object:ClearAllPoints()
	object:SetPoint("TOPLEFT", self, "TOPLEFT", l or 0, t or 0)
	object:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", r or 0, b or 0)

	self.__children[object] = true
	objectToWidget[object] = self

	if not hooked[object] then
		hooksecurefunc(object, "Hide", hook)
		hooksecurefunc(object, "Show", hook)
		hooksecurefunc(object, "SetShown", hook)

		hooked[object] = true
	end

	self:Refresh()
end

function inset_proto:Release(object)
	if self.__children[object] then
		object:ClearAllPoints()

		self.__children[object] = nil
		objectToWidget[object] = nil
	end

	self:Refresh()
end

function inset_proto:Refresh()
	local shouldShow = 0
	for child in next, self.__children do
		if child:IsShown() then
			shouldShow = shouldShow + 1
		end
	end

	if shouldShow > 0 then
		self:Expand()
	else
		self:Collapse()
	end
end

local vert_inset_proto = {}

function vert_inset_proto:OnSizeChanged(_, h)
	local tile = (h - 16) / 16 --[[ * self:GetEffectiveScale() ]]
	if tile < 0 then
		tile = 0
	end

	self[2]:SetTexCoord(1 / 64, 13 / 64, 0 / 32, tile)
end

function vert_inset_proto:Collapse()
	self:SetWidth(0.001)

	self[1]:Hide()
	self[2]:Hide()
	self[3]:Hide()
	self[4]:Hide()

	self.__expanded = false

	if self.PostCollapse then
		self:PostCollapse()
	end
end

function vert_inset_proto:Expand()
	self:SetWidth(self.__size)

	self[1]:Show()
	self[2]:Show()
	self[3]:Show()
	self[4]:Show()

	self.__expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

function vert_inset_proto:UpdateSize(size)
	self.__size = size or self.__size

	if self:IsExpanded() then
		self:SetWidth(self.__size)
	end
end

local horiz_inset_proto = {}

function horiz_inset_proto:OnSizeChanged(w)
	local tile = (w - 16) / 16 --[[ * self:GetEffectiveScale() ]]
		if tile < 0 then
			tile = 0
		end

	self[2]:SetTexCoord(0 / 32, tile, 1 / 64, 13 / 64)
end

function horiz_inset_proto:Collapse()
	self:SetHeight(0.001)

	self[1]:Hide()
	self[2]:Hide()
	self[3]:Hide()
	self[4]:Hide()

	self.__expanded = false

	if self.PostCollapse then
		self:PostCollapse()
	end
end

function horiz_inset_proto:Expand()
	self:SetHeight(self.__size)

	self[1]:Show()
	self[2]:Show()
	self[3]:Show()
	self[4]:Show()

	self.__expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

function horiz_inset_proto:UpdateSize(size)
	self.__size = size or self.__size

	if self:IsExpanded() then
		self:SetHeight(self.__size)
	end
end

local DATA = {
	Left = {
		texture = {
			path = "Interface\\AddOns\\ls_UI\\assets\\border-thick-sep",
			coords = {
				[1] = {14 / 64, 26 / 64, 1 / 32, 17 / 32},
				-- [2] = {1 / 64, 13 / 64, 0 / 32, 32 / 32},
				[3] = {27 / 64, 39 / 64, 1 / 32, 17 / 32},
			},
			points = {
				[1] = {
					p = "TOPRIGHT",
					rP = "TOPRIGHT",
					x = 2,
					y = 0,
				},
				[2] = {
					[1] = {
						p = "TOPLEFT",
						rP = "BOTTOMLEFT",
						x = 0,
						y = 0,
					},
					[2] = {
						p = "BOTTOMRIGHT",
						rP = "TOPRIGHT",
						x = 0,
						y = 0,
					},
				},
				[3] = {
					p = "BOTTOMRIGHT",
					rP = "BOTTOMRIGHT",
					x = 2,
					y = 0,
				},
			},
			sizes = {
				[1] = {12 / 2, 16 / 2},
				[3] = {12 / 2, 16 / 2},
			},
		},
		mixins = {inset_proto, vert_inset_proto},
	},
	Right = {
		texture = {
			path = "Interface\\AddOns\\ls_UI\\assets\\border-thick-sep",
			coords = {
				[1] = {14 / 64, 26 / 64, 1 / 32, 17 / 32},
				-- [2] = {1 / 64, 13 / 64, 0 / 32, 32 / 32},
				[3] = {27 / 64, 39 / 64, 1 / 32, 17 / 32},
			},
			points = {
				[1] = {
					p = "TOPLEFT",
					rP = "TOPLEFT",
					x = -2,
					y = 0,
				},
				[2] = {
					[1] = {
						p = "TOPLEFT",
						rP = "BOTTOMLEFT",
						x = 0,
						y = 0,
					},
					[2] = {
						p = "BOTTOMRIGHT",
						rP = "TOPRIGHT",
						x = 0,
						y = 0,
					},
				},
				[3] = {
					p = "BOTTOMLEFT",
					rP = "BOTTOMLEFT",
					x = -2,
					y = 0,
				},
			},
			sizes = {
				[1] = {12 / 2, 16 / 2},
				[3] = {12 / 2, 16 / 2},
			},
		},
		mixins = {inset_proto, vert_inset_proto},
	},
	Top = {
		texture = {
			path = "Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz",
			coords = {
				[1] = {1 / 32, 17 / 32, 14 / 64, 26 / 64},
				[3] = {1 / 32, 17 / 32, 27 / 64, 39 / 64},
			},
			points = {
				[1] = {
					p = "BOTTOMLEFT",
					rP = "BOTTOMLEFT",
					x = 0,
					y = -2,
				},
				[2] = {
					[1] = {
						p = "TOPLEFT",
						rP = "TOPRIGHT",
						x = 0,
						y = 0,
					},
					[2] = {
						p = "BOTTOMRIGHT",
						rP = "BOTTOMLEFT",
						x = 0,
						y = 0,
					},
				},
				[3] = {
					p = "BOTTOMRIGHT",
					rP = "BOTTOMRIGHT",
					x = 0,
					y = -2,
				},
			},
			sizes = {
				[1] = {16 / 2, 12 / 2},
				[3] = {16 / 2, 12 / 2},
			},
		},
		mixins = {inset_proto, horiz_inset_proto},
	},
	Bottom = {
		texture = {
			path = "Interface\\AddOns\\ls_UI\\assets\\unit-frame-sep-horiz",
			coords = {
				[1] = {1 / 32, 17 / 32, 14 / 64, 26 / 64},
				[3] = {1 / 32, 17 / 32, 27 / 64, 39 / 64},
			},
			points = {
				[1] = {
					p = "TOPLEFT",
					rP = "TOPLEFT",
					x = 0,
					y = 2,
				},
				[2] = {
					[1] = {
						p = "TOPLEFT",
						rP = "TOPRIGHT",
						x = 0,
						y = 0,
					},
					[2] = {
						p = "BOTTOMRIGHT",
						rP = "BOTTOMLEFT",
						x = 0,
						y = 0,
					},
				},
				[3] = {
					p = "TOPRIGHT",
					rP = "TOPRIGHT",
					x = 0,
					y = 2,
				},
			},
			sizes = {
				[1] = {16 / 2, 12 / 2},
				[3] = {16 / 2, 12 / 2},
			},
		},
		mixins = {inset_proto, horiz_inset_proto},
	},
}

function UF:CreateLayout(frame, level)
	Mixin(frame, frame_proto)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
	bg:SetAllPoints()
	bg:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
	bg:SetHorizTile(true)
	bg:SetVertTile(true)

	local inlayParent = CreateFrame("Frame", nil, frame)
	inlayParent:SetFrameLevel(level + 7)

	local inlay = E:CreateBorder(inlayParent)
	inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-both")
	frame.Inlay = inlay

	local textureParent = CreateFrame("Frame", nil, frame)
	textureParent:SetFrameLevel(level + 8)
	textureParent:SetAllPoints()
	frame.TextureParent = textureParent

	local textParent = CreateFrame("Frame", nil, frame)
	textParent:SetFrameLevel(level + 9)
	textParent:SetAllPoints()
	frame.TextParent = textParent

	local insets = Mixin({__owner = frame}, insets_proto)
	frame.Insets = insets

	for _, v in next, {"Left", "Right", "Top", "Bottom"} do
		local inset = Mixin(CreateFrame("Frame", nil, frame), unpack(DATA[v].mixins))
		inset:SetFrameLevel(level)
		inset:SetScript("OnSizeChanged", inset.OnSizeChanged)
		inset.__owner = insets
		inset.__children = {}

		local tex1 = textureParent:CreateTexture(nil, "OVERLAY", nil, 4)
		tex1:SetTexture(DATA[v].texture.path)
		tex1:SetTexCoord(unpack(DATA[v].texture.coords[1]))
		tex1:SetSize(unpack(DATA[v].texture.sizes[1]))
		tex1:SetPoint(DATA[v].texture.points[1].p, inset, DATA[v].texture.points[1].rP, DATA[v].texture.points[1].x, DATA[v].texture.points[1].y)
		tex1:SetSnapToPixelGrid(false)
		tex1:SetTexelSnappingBias(0)
		inset[1] = tex1

		local tex3 = textureParent:CreateTexture(nil, "OVERLAY", nil, 4)
		tex3:SetTexture(DATA[v].texture.path)
		tex3:SetTexCoord(unpack(DATA[v].texture.coords[3]))
		tex3:SetSize(unpack(DATA[v].texture.sizes[3]))
		tex3:SetPoint(DATA[v].texture.points[3].p, inset, DATA[v].texture.points[3].rP, DATA[v].texture.points[3].x, DATA[v].texture.points[3].y)
		tex3:SetSnapToPixelGrid(false)
		tex3:SetTexelSnappingBias(0)
		inset[3] = tex3

		local tex2 = textureParent:CreateTexture(nil, "OVERLAY", nil, 4)
		tex2:SetTexture(DATA[v].texture.path, "REPEAT", "REPEAT")
		tex2:SetPoint(DATA[v].texture.points[2][1].p, tex1, DATA[v].texture.points[2][1].rP, DATA[v].texture.points[2][1].x, DATA[v].texture.points[2][1].y)
		tex2:SetPoint(DATA[v].texture.points[2][2].p, tex3, DATA[v].texture.points[2][2].rP, DATA[v].texture.points[2][2].x, DATA[v].texture.points[2][2].y)
		tex2:SetSnapToPixelGrid(false)
		tex2:SetTexelSnappingBias(0)
		inset[2] = tex2

		-- it needs to appear under the inlay glass
		local gradient = inlayParent:CreateTexture(nil, "OVERLAY", nil, 0)
		gradient:SetPoint("TOPLEFT", inset, "TOPLEFT", 0, -1)
		gradient:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", 0, 1)
		gradient:SetSnapToPixelGrid(false)
		gradient:SetTexelSnappingBias(0)
		gradient:SetTexture("Interface\\BUTTONS\\WHITE8X8")
		inset[4] = gradient

		inset:Collapse()

		insets[v] = inset
	end

	insets.Left:SetPoint("TOPLEFT", 0, 0)
	insets.Left:SetPoint("BOTTOMLEFT", 0, 0)

	function insets.Left:PostExpand()
		if insets.Right:IsExpanded() then
			inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-none")
		else
			inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-right")
		end
	end

	function insets.Left:PostCollapse()
		if insets.Right:IsExpanded() then
			inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-left")
		else
			inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-both")
		end
	end

	insets.Right:SetPoint("TOPRIGHT", 0, 0)
	insets.Right:SetPoint("BOTTOMRIGHT", 0, 0)

	function insets.Right:PostExpand()
		if insets.Left:IsExpanded() then
			inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-none")
		else
			inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-left")
		end
	end

	function insets.Right:PostCollapse()
		if insets.Left:IsExpanded() then
			inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-right")
		else
			inlay:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-inlay-both")
		end
	end

	insets.Top:SetPoint("TOPLEFT", insets.Left, "TOPRIGHT", 0, 0)
	insets.Top:SetPoint("TOPRIGHT", insets.Right, "TOPLEFT", 0, 0)

	insets.Bottom:SetPoint("BOTTOMLEFT", insets.Left, "BOTTOMRIGHT", 0, 0)
	insets.Bottom:SetPoint("BOTTOMRIGHT", insets.Right, "BOTTOMLEFT", 0, 0)

	inlayParent:SetPoint("TOPLEFT", insets.Left, "TOPRIGHT", 0, 0)
	inlayParent:SetPoint("BOTTOMRIGHT", insets.Right, "BOTTOMLEFT", 0, 0)

	local gradient = textureParent:CreateTexture(nil, "OVERLAY", nil, 0)
	gradient:SetPoint("LEFT", insets.Left, "RIGHT", 0, 0)
	gradient:SetPoint("RIGHT", insets.Right, "LEFT", 0, 0)
	gradient:SetPoint("TOP", insets.Top, "BOTTOM", 0, 0)
	gradient:SetPoint("BOTTOM", insets.Bottom, "TOP", 0, 0)
	gradient:SetSnapToPixelGrid(false)
	gradient:SetTexelSnappingBias(0)
	gradient:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	inlay.Gradient = gradient -- it's not, but it is now

	local border = E:CreateBorder(textureParent)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
	frame.Border = border

	local ag = frame:CreateAnimationGroup()
	ag.color = {a = 1}
	frame.ColorAnim = ag

	for i, target in next, {
		insets.Left[1],
		insets.Left[2],
		insets.Left[3],
		insets.Right[1],
		insets.Right[2],
		insets.Right[3],
		border.TOPLEFT,
		border.TOPRIGHT,
		border.BOTTOMLEFT,
		border.BOTTOMRIGHT,
		border.TOP,
		border.BOTTOM,
		border.LEFT,
		border.RIGHT,
	} do
		local anim = ag:CreateAnimation("VertexColor")
		anim:SetDuration(0.125)
		anim:SetTarget(target)
		ag[i] = anim
	end
end

local slot_proto = {
	IsExpanded = inset_proto.IsExpanded,
	Refresh = inset_proto.Refresh,
	Capture = inset_proto.Capture,
	Release = inset_proto.Release,
	__width = 0,
	__height = 0,
}

function slot_proto:Expand()
	self:SetSize(self.__width, self.__height)
	self:Show()

	self.__expanded = true

	if self.PostExpand then
		self:PostExpand()
	end
end

function slot_proto:Collapse()
	self:SetSize(0.001, 0.001)
	self:Hide()

	self.__expanded = false

	if self.PostCollapse then
		self:PostCollapse()
	end
end

function slot_proto:UpdateSize(w, h)
	self.__width = w or self.__width
	self.__height = h or self.__height

	if self:IsExpanded() then
		self:SetSize(self.__width, self.__height)
	end
end

function UF:CreateSlot(frame, level)
	local slot = Mixin(CreateFrame("Frame", nil, frame), slot_proto)
	slot:SetFrameLevel(level)
	slot.__children = {}

	slot:Collapse()

	return slot
end
