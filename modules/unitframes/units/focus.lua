local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function UF:HasFocusFrame()
	return isInit
end

function UF:CreateFocusFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.db.profile.units[E.UI_LAYOUT].focus

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-bg", true)
	bg:SetHorizTile(true)

	local fg_parent = _G.CreateFrame("Frame", nil, frame)
	fg_parent:SetFrameLevel(level + 7)
	fg_parent:SetAllPoints()
	frame.FGParent = fg_parent

	local text_parent = _G.CreateFrame("Frame", nil, frame)
	text_parent:SetFrameLevel(level + 9)
	text_parent:SetAllPoints()
	frame.TextParent = text_parent

	frame.Insets = self:CreateInsets(frame, fg_parent)

	local health = self:CreateHealth(frame, true, "LSFont12_Shadow", text_parent)
	health:SetFrameLevel(level + 1)
	health:SetPoint("LEFT", frame, "LEFT", 0, 0)
	health:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
	health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	frame.HealthPrediction = self:CreateHealthPrediction(health)

	local power = self:CreatePower(frame, true, "LSFont12_Shadow", text_parent)
	power:SetFrameLevel(level + 1)
	power:SetPoint("LEFT", frame, "LEFT", 0, 0)
	power:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	power:SetPoint("TOP", frame.Insets.Bottom, "TOP", 0, -2)
	power:SetPoint("BOTTOM", frame.Insets.Bottom, "BOTTOM", 0, 0)
	frame.Power = power

	power.UpdateContainer = function(_, shouldShow)
		if shouldShow then
			if not frame.Insets.Bottom:IsExpanded() then
				frame.Insets.Bottom:Expand()
			end
		else
			if frame.Insets.Bottom:IsExpanded() then
				frame.Insets.Bottom:Collapse()
			end
		end
	end

	frame.Castbar = self:CreateCastbar(frame)

	frame.Name = self:CreateName(text_parent, "LSFont12_Shadow")

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(text_parent)

	local pvp = self:CreatePvPIndicator(fg_parent)
	frame.PvPIndicator = pvp

	pvp.Holder.PostExpand = function()
		if not frame._config.castbar.detached then
			frame.Castbar.Holder:SetWidth(frame.Castbar.Holder._width - 52)
		end
	end

	pvp.Holder.PostCollapse = function()
		if not frame._config.castbar.detached then
			frame.Castbar.Holder:SetWidth(frame.Castbar.Holder._width)
		end
	end

	frame.DebuffIndicator = self:CreateDebuffIndicator(text_parent)

	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	frame.Auras = self:CreateAuras(frame, "focus")

	local status = text_parent:CreateFontString(nil, "ARTWORK", "LSStatusIcon16Font")
	status:SetJustifyH("RIGHT")
	status:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, -1)
	frame:Tag(status, "[ls:questicon][ls:sheepicon][ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]")

	local border = E:CreateBorder(fg_parent)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
	border:SetSize(16)
	border:SetOffset(-6)
	frame.Border = border

	local glass = fg_parent:CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetAllPoints(health)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")

	local shadow = fg_parent:CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetAllPoints(health)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")

	self:CreateClassIndicator(frame)

	isInit = true
end

function UF:UpdateFocusFrame(frame)
	frame._config = C.db.profile.units[E.UI_LAYOUT].focus

	frame:SetSize(frame._config.width, frame._config.height)

	self:UpdateInsets(frame)
	self:UpdateHealth(frame)
	self:UpdateHealthPrediction(frame)
	self:UpdatePower(frame)
	self:UpdateCastbar(frame)
	self:UpdateName(frame)
	self:UpdateRaidTargetIndicator(frame)
	self:UpdatePvPIndicator(frame)
	self:UpdateDebuffIndicator(frame)
	self:UpdateThreatIndicator(frame)
	self:UpdateAuras(frame)
	self:UpdateClassIndicator(frame)

	frame:UpdateAllElements("LSUI_FocusFrameUpdate")
end
