local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local t_insert = _G.table.insert

-- Mine
function UF:ConstructTargetFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.units.target
	frame._mouseovers = {}

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-bg", true)
	bg:SetHorizTile(true)

	local fg_parent = _G.CreateFrame("Frame", nil, frame)
	fg_parent:SetFrameLevel(level + 7)
	fg_parent:SetAllPoints()
	frame.FGParent = fg_parent

	local text_parent = _G.CreateFrame("Frame", nil, frame)
	text_parent:SetFrameLevel(level + 9)
	text_parent:SetAllPoints()
	frame.TextParent = text_parent

	local top_inset = _G.CreateFrame("Frame", nil, frame)
	top_inset:SetFrameLevel(level)
	top_inset:SetPoint("TOPLEFT", 0, 0)
	top_inset:SetPoint("TOPRIGHT", 0, 0)
	top_inset.Expand = function(self)
		self:SetHeight(14)

		self.Left:Show()
		self.Right:Show()
		self.Mid:Show()

		self.expanded = true
	end
	top_inset.Collapse = function(self)
		self:SetHeight(0.001)

		self.Left:Hide()
		self.Right:Hide()
		self.Mid:Hide()

		self.expanded = false
	end
	top_inset.IsExpanded = function(self)
		return self.expanded
	end

	local texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 3)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz")
	texture:SetTexCoord(1 / 64, 15 / 64, 11 / 32, 23 / 32)
	texture:SetSize(14 / 2, 12 / 2)
	texture:SetPoint("BOTTOMLEFT", top_inset, "BOTTOMLEFT", -1, -2)
	top_inset.Left = texture

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 3)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture:SetTexCoord(16 / 64, 30 / 64, 11 / 32, 23 / 32)
	texture:SetSize(14 / 2, 12 / 2)
	texture:SetPoint("BOTTOMRIGHT", top_inset, "BOTTOMRIGHT", 1, -2)
	top_inset.Right = texture

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 3)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	texture:SetHorizTile(true)
	texture:SetPoint("TOPLEFT", top_inset.Left, "TOPRIGHT", 0, 0)
	texture:SetPoint("BOTTOMRIGHT", top_inset.Right, "BOTTOMLEFT", 0, 0)
	top_inset.Mid = texture

	top_inset:Collapse()

	local bottom_inset = _G.CreateFrame("Frame", nil, frame)
	bottom_inset:SetFrameLevel(level)
	bottom_inset:SetPoint("BOTTOMLEFT", 0, 0)
	bottom_inset:SetPoint("BOTTOMRIGHT", 0, 0)
	bottom_inset.Expand = function(self)
		self:SetHeight(14)

		self.Left:Show()
		self.Mid:Show()
		self.Right:Show()

		self.expanded = true
	end
	bottom_inset.Collapse = function(self)
		self:SetHeight(0.001)

		self.Left:Hide()
		self.Mid:Hide()
		self.Right:Hide()

		self.expanded = false
	end
	bottom_inset.IsExpanded = function(self)
		return self.expanded
	end

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 3)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz")
	texture:SetTexCoord(1 / 64, 15 / 64, 11 / 32, 23 / 32)
	texture:SetSize(14 / 2, 12 / 2)
	texture:SetPoint("TOPLEFT", bottom_inset, "TOPLEFT", -1, 2)
	bottom_inset.Left = texture

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 3)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture:SetTexCoord(16 / 64, 30 / 64, 11 / 32, 23 / 32)
	texture:SetSize(14 / 2, 12 / 2)
	texture:SetPoint("TOPRIGHT", bottom_inset, "TOPRIGHT", 1, 2)
	bottom_inset.Right = texture

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 3)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-horiz", true)
	texture:SetTexCoord(0 / 64, 64 / 64, 0 / 32, 12 / 32)
	texture:SetHorizTile(true)
	texture:SetPoint("TOPLEFT", bottom_inset.Left, "TOPRIGHT", 0, 0)
	texture:SetPoint("BOTTOMRIGHT", bottom_inset.Right, "BOTTOMLEFT", 0, 0)
	bottom_inset.Mid = texture

	bottom_inset:Collapse()

	local left_inset = _G.CreateFrame("Frame", nil, frame)
	left_inset:SetPoint("TOPLEFT", top_inset, "BOTTOMLEFT", 0, 0)
	left_inset:SetPoint("BOTTOMLEFT", bottom_inset, "TOPLEFT", 0, 0)
	left_inset.Expand = function(self)
		self:SetWidth(10)

		self.Top:Show()
		self.Mid:Show()
		self.Bottom:Show()

		self.expanded = true
	end
	left_inset.Collapse = function(self)
		self:SetWidth(0.001)

		self.Top:Hide()
		self.Mid:Hide()
		self.Bottom:Hide()

		self.expanded = false
	end
	left_inset.IsExpanded = function(self)
		return self.expanded
	end

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 4)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert")
	texture:SetTexCoord(11 / 32, 23 / 32, 1 / 64, 15 / 64)
	texture:SetSize(12 / 2, 14 / 2)
	texture:SetPoint("TOPRIGHT", left_inset, "TOPRIGHT", 2, 1)
	left_inset.Top = texture

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 4)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert", true)
	texture:SetTexCoord(11 / 32, 23 / 32, 16 / 64, 30 / 64)
	texture:SetSize(12 / 2, 14 / 2)
	texture:SetPoint("BOTTOMRIGHT", left_inset, "BOTTOMRIGHT", 2, -1)
	left_inset.Bottom = texture

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 4)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert", true)
	texture:SetTexCoord(0 / 32, 12 / 32, 0 / 64, 12 / 64)
	texture:SetVertTile(true)
	texture:SetPoint("TOPLEFT", left_inset.Top, "BOTTOMLEFT", 0, 0)
	texture:SetPoint("BOTTOMRIGHT", left_inset.Bottom, "TOPRIGHT", 0, 0)
	left_inset.Mid = texture

	left_inset:Collapse()

	local right_inset = _G.CreateFrame("Frame", nil, frame)
	right_inset:SetPoint("TOPRIGHT", top_inset, "BOTTOMRIGHT", 0, 0)
	right_inset:SetPoint("BOTTOMRIGHT", bottom_inset, "TOPRIGHT", 0, 0)
	right_inset:SetWidth(0.001)
	right_inset.Expand = function(self)
		self:SetWidth(10)

		self.Top:Show()
		self.Mid:Show()
		self.Bottom:Show()

		self.expanded = true
	end
	right_inset.Collapse = function(self)
		self:SetWidth(0.001)

		self.Top:Hide()
		self.Mid:Hide()
		self.Bottom:Hide()

		self.expanded = false
	end
	right_inset.IsExpanded = function(self)
		return self.expanded
	end

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 4)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert")
	texture:SetTexCoord(11 / 32, 23 / 32, 1 / 64, 15 / 64)
	texture:SetSize(12 / 2, 14 / 2)
	texture:SetPoint("TOPLEFT", right_inset, "TOPLEFT", -2, 1)
	right_inset.Top = texture

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 4)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert", true)
	texture:SetTexCoord(11 / 32, 23 / 32, 16 / 64, 30 / 64)
	texture:SetSize(12 / 2, 14 / 2)
	texture:SetPoint("BOTTOMLEFT", right_inset, "BOTTOMLEFT", -2, -1)
	right_inset.Bottom = texture

	texture = fg_parent:CreateTexture(nil, "OVERLAY", nil, 4)
	texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-sep-vert", true)
	texture:SetTexCoord(0 / 32, 12 / 32, 0 / 64, 12 / 64)
	texture:SetVertTile(true)
	texture:SetPoint("TOPLEFT", right_inset.Top, "BOTTOMLEFT", 0, 0)
	texture:SetPoint("BOTTOMRIGHT", right_inset.Bottom, "TOPRIGHT", 0, 0)
	right_inset.Mid = texture

	right_inset:Collapse()

	local pvp_banner_inset = _G.CreateFrame("Frame", nil, frame)
	pvp_banner_inset:SetFrameLevel(level + 8)
	pvp_banner_inset:SetHeight(48)
	pvp_banner_inset.Expand = function(self)
		self:SetWidth(46)

		local width = frame.Castbar.Holder._width - 48
		frame.Castbar.Holder._width = width

		frame.Castbar.Holder:SetWidth(width)

		self.expanded = true
	end
	pvp_banner_inset.Collapse = function(self)
		self:SetWidth(0.001)

		local width = frame.Castbar.Holder._width + 48
		frame.Castbar.Holder._width = width

		frame.Castbar.Holder:SetWidth(width)

		self.expanded = false
	end
	pvp_banner_inset.IsExpanded = function(self)
		return self.expanded
	end

	E:CreateBorder(fg_parent, true)

	local health = self:CreateHealth(frame, true, "LS12Font_Shadow", text_parent)
	health:SetFrameLevel(level + 1)
	health:SetPoint("TOPLEFT", left_inset, "TOPRIGHT", 0, 0)
	health:SetPoint("BOTTOMRIGHT", right_inset, "BOTTOMLEFT", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	health.Text:SetJustifyH("RIGHT")
	health.Text:SetPoint("RIGHT", health, "RIGHT", -2, 0)

	local glass = health:CreateTexture(nil, "OVERLAY")
	glass:SetAllPoints()
	glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-glass", true)
	glass:SetHorizTile(true)

	local power = self:CreatePower(frame, true, "LS12Font_Shadow", text_parent)
	power:SetFrameLevel(level + 1)
	power:SetPoint("TOPLEFT", bottom_inset, "TOPLEFT", 0, -2)
	power:SetPoint("BOTTOMRIGHT", bottom_inset, "BOTTOMRIGHT", 0, 0)
	E:SetStatusBarSkin(power, "HORIZONTAL-GLASS")
	frame.Power = power

	power.Inset = bottom_inset

	local alt_power = self:CreateAlternativePower(frame, true, "LS12Font_Shadow", text_parent)
	alt_power:SetFrameLevel(level + 1)
	alt_power:SetPoint("TOPLEFT", top_inset, "TOPLEFT", 0, 0)
	alt_power:SetPoint("BOTTOMRIGHT", top_inset, "BOTTOMRIGHT", 0, 2)
	E:SetStatusBarSkin(alt_power, "HORIZONTAL-GLASS")
	frame.AlternativePower = alt_power

	alt_power.Inset = top_inset

	frame.Name = UF:CreateName(text_parent, "LS12Font_Shadow")

	local statusIcons = text_parent:CreateFontString("$parentStatusIcons", "ARTWORK", "LSStatusIcon16Font")
	-- statusIcons:SetWidth(18)
	statusIcons:SetJustifyH("LEFT")
	statusIcons:SetPoint("LEFT", frame, "BOTTOMLEFT", 4, -1)
	frame:Tag(statusIcons, "[ls:questicon][ls:sheepicon][ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]")

	frame.PvPIndicator = self:CreatePvPIcon_new(pvp_banner_inset, "OVERLAY", 3)
	frame.PvPIndicator:SetPoint("TOPRIGHT", fg_parent, "BOTTOMRIGHT", -8, -2)
	frame.PvPIndicator.Inset = pvp_banner_inset

	frame.Castbar = self:CreateCastbar(frame)
	frame.Castbar.Holder:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 3, -6)

	frame.Auras = self:CreateAuras(frame, "target", 32, nil, nil, 8)
	frame.Auras:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -1, 7)
end

function UF:UpdateTargetFrame(frame)
	local config = frame._config

	frame:SetSize(config.width, config.height)

	self:UpdateHealth(frame)
	self:UpdateName(frame)
	self:UpdateCastbar(frame)
	self:UpdatePower(frame)
	self:UpdateAlternativePower(frame)

	frame:UpdateAllElements("LSUI_TargetFrameUpdate")
end
