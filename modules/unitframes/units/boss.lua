local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false
local holder

function UF:CreateBossHolder()
	holder = CreateFrame("Frame", "LSBossHolder", UIParent)
	holder:SetPoint(unpack(C.db.profile.units[E.UI_LAYOUT].boss.point))
	E:CreateMover(holder)
	holder._buttons = {}

	return holder
end

function UF:UpdateBossHolder()
	if not holder._config then
		holder._config = {
			num = 5
		}
	end

	holder._config.width = C.db.profile.units[E.UI_LAYOUT].boss.width
	holder._config.height = C.db.profile.units[E.UI_LAYOUT].boss.height
	holder._config.per_row = C.db.profile.units[E.UI_LAYOUT].boss.per_row
	holder._config.spacing = C.db.profile.units[E.UI_LAYOUT].boss.spacing
	holder._config.x_growth = C.db.profile.units[E.UI_LAYOUT].boss.x_growth
	holder._config.y_growth = C.db.profile.units[E.UI_LAYOUT].boss.y_growth

	E:UpdateBarLayout(holder)
end

function UF:HasBossFrame()
	return isInit
end

function UF:CreateBossFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.db.profile.units[E.UI_LAYOUT].boss

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-bg", true)
	bg:SetHorizTile(true)

	local fgParent = CreateFrame("Frame", nil, frame)
	fgParent:SetFrameLevel(level + 7)
	fgParent:SetAllPoints()
	frame.FGParent = fgParent

	local textParent = CreateFrame("Frame", nil, frame)
	textParent:SetFrameLevel(level + 9)
	textParent:SetAllPoints()
	frame.TextParent = textParent

	frame.Insets = self:CreateInsets(frame, fgParent)

	local health = self:CreateHealth(frame, true, "LSFont12_Shadow", textParent)
	health:SetFrameLevel(level + 1)
	health:SetPoint("LEFT", frame, "LEFT", 0, 0)
	health:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
	health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	frame.HealthPrediction = self:CreateHealthPrediction(health)

	local power = self:CreatePower(frame, true, "LSFont12_Shadow", textParent)
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

	local altPower = self:CreateAlternativePower(frame, true, "LSFont12_Shadow", textParent)
	altPower:SetFrameLevel(level + 1)
	altPower:SetPoint("LEFT", frame, "LEFT", 0, 0)
	altPower:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
	altPower:SetPoint("TOP", frame.Insets.Top, "TOP", 0, 0)
	altPower:SetPoint("BOTTOM", frame.Insets.Top, "BOTTOM", 0, 2)
	frame.AlternativePower = altPower

	altPower.UpdateContainer = function(_, shouldShow)
		if shouldShow then
			if not frame.Insets.Top:IsExpanded() then
				frame.Insets.Top:Expand()
			end
		else
			if frame.Insets.Top:IsExpanded() then
				frame.Insets.Top:Collapse()
			end
		end
	end

	frame.Castbar = self:CreateCastbar(frame)
	frame.Castbar.Holder:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 3, -6)

	frame.Name = self:CreateName(textParent, "LSFont12_Shadow")

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(textParent)

	frame.DebuffIndicator = self:CreateDebuffIndicator(textParent)

	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	frame.Auras = self:CreateAuras(frame, "boss")

	local border = E:CreateBorder(fgParent)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
	border:SetSize(16)
	border:SetOffset(-6)
	frame.Border = border

	local glass = fgParent:CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetAllPoints(health)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")

	local shadow = fgParent:CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetAllPoints(health)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")

	self:CreateClassIndicator(frame)

	isInit = true
end

function UF:UpdateBossFrame(frame)
	frame._config = C.db.profile.units[E.UI_LAYOUT].boss

	frame:SetSize(frame._config.width, frame._config.height)

	self:UpdateInsets(frame)
	self:UpdateHealth(frame)
	self:UpdateHealthPrediction(frame)
	self:UpdatePower(frame)
	self:UpdateAlternativePower(frame)
	self:UpdateCastbar(frame)
	self:UpdateName(frame)
	self:UpdateRaidTargetIndicator(frame)
	self:UpdateDebuffIndicator(frame)
	self:UpdateThreatIndicator(frame)
	self:UpdateAuras(frame)
	self:UpdateClassIndicator(frame)

	frame:UpdateAllElements("LSUI_BossFrameUpdate")
end
