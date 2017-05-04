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

	frame.Insets = UF:CreateInsets(frame, fg_parent, level)

	local health = self:CreateHealth(frame, true, "LS12Font_Shadow", text_parent)
	health:SetFrameLevel(level + 1)
	health:SetPoint("TOPLEFT", frame.Insets.Left, "TOPRIGHT", 0, 0)
	health:SetPoint("BOTTOMRIGHT", frame.Insets.Right, "BOTTOMLEFT", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health


	local power = self:CreatePower(frame, true, "LS12Font_Shadow", text_parent)
	power:SetFrameLevel(level + 1)
	power:SetPoint("TOPLEFT", frame.Insets.Bottom, "TOPLEFT", 0, -2)
	power:SetPoint("BOTTOMRIGHT", frame.Insets.Bottom, "BOTTOMRIGHT", 0, 0)
	E:SetStatusBarSkin(power, "HORIZONTAL-GLASS")
	power.Inset = frame.Insets.Bottom
	frame.Power = power




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


	local glass = health:CreateTexture(nil, "OVERLAY")
	glass:SetAllPoints()
	glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\unit-frame-glass", true)
	glass:SetHorizTile(true)



	frame.Name = UF:CreateName(text_parent, "LS12Font_Shadow")

	frame.RaidTargetIndicator = UF:CreateRaidTargetIndicator(text_parent)

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

	self:UpdateInsets(frame)
	self:UpdateHealth(frame)
	self:UpdateName(frame)
	self:UpdateCastbar(frame)
	self:UpdatePower(frame)
	self:UpdateAlternativePower(frame)
	self:UpdateRaidTargetIndicator(frame)

	frame:UpdateAllElements("LSUI_TargetFrameUpdate")
end
