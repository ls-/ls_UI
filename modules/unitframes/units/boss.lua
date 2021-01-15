local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local unpack = _G.unpack

--[[ luacheck: globals
	CreateFrame
	UIParent
]]

-- Mine
local isInit = false
local holder

function UF:CreateBossHolder()
	holder = CreateFrame("Frame", "LSBossHolder", UIParent)
	holder:SetPoint(unpack(C.db.profile.units.boss.point[E.UI_LAYOUT]))
	E.Movers:Create(holder)
	holder._buttons = {}

	return holder
end

function UF:UpdateBossHolder()
	if not holder._config then
		holder._config = {
			num = 5,
		}
	end

	holder._config.width = C.db.profile.units.boss.width
	holder._config.height = C.db.profile.units.boss.height
	holder._config.per_row = C.db.profile.units.boss.per_row
	holder._config.spacing = C.db.profile.units.boss.spacing
	holder._config.x_growth = C.db.profile.units.boss.x_growth
	holder._config.y_growth = C.db.profile.units.boss.y_growth

	E:UpdateBarLayout(holder)
end

local function frame_Update(self)
	self:UpdateConfig()

	if self._config.enabled then
		if not self:IsEnabled() then
			self:Enable()
		end

		self:UpdateSize()
		self:UpdateInsets()
		self:UpdateHealth()
		self:UpdateHealthPrediction()
		self:UpdatePortrait()
		self:UpdatePower()
		self:UpdateAlternativePower()
		self:UpdateCastbar()
		self:UpdateName()
		self:UpdateRaidTargetIndicator()
		self:UpdateDebuffIndicator()
		self:UpdateThreatIndicator()
		self:UpdateAuras()
		self:UpdateClassIndicator()
		self:UpdateCustomTexts()
	else
		if self:IsEnabled() then
			self:Disable()
		end
	end
end

function UF:HasBossFrame()
	return isInit
end

function UF:CreateBossFrame(frame)
	local level = frame:GetFrameLevel()

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-bg", true)
	bg:SetHorizTile(true)

	local textureParent = CreateFrame("Frame", nil, frame)
	textureParent:SetFrameLevel(level + 7)
	textureParent:SetAllPoints()
	frame.TextureParent = textureParent

	local textParent = CreateFrame("Frame", nil, frame)
	textParent:SetFrameLevel(level + 9)
	textParent:SetAllPoints()
	frame.TextParent = textParent

	frame.Insets = self:CreateInsets(frame, textureParent)

	local health = self:CreateHealth(frame, textParent)
	health:SetFrameLevel(level + 1)
	health:SetPoint("LEFT", frame.Insets.Left, "RIGHT", 0, 0)
	health:SetPoint("RIGHT", frame.Insets.Right, "LEFT", 0, 0)
	health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
	health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	frame.HealthPrediction = self:CreateHealthPrediction(frame, health, textParent)

	frame.Portrait = self:CreatePortrait(frame)

	local power = self:CreatePower(frame, textParent)
	power:SetFrameLevel(level + 1)
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

	frame.Insets.Bottom:Capture(power, 0, 0, -2, 0)

	local altPower = self:CreateAlternativePower(frame, textParent)
	altPower:SetFrameLevel(level + 1)
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

	frame.Insets.Top:Capture(altPower, 0, 0, 0, 2)

	frame.Castbar = self:CreateCastbar(frame)
	frame.Castbar.Holder:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 3, -6)

	frame.Name = self:CreateName(frame, textParent)

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, textParent)

	frame.DebuffIndicator = self:CreateDebuffIndicator(frame, textParent)

	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	frame.Auras = self:CreateAuras(frame, "boss")

	local border = E:CreateBorder(textureParent)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
	border:SetOffset(-6)
	frame.Border = border

	frame.ClassIndicator = self:CreateClassIndicator(frame)

	frame.CustomTexts = self:CreateCustomTexts(frame, textParent)

	local glass = textureParent:CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetAllPoints(health)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")

	local shadow = textureParent:CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetAllPoints(health)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")

	frame.Update = frame_Update

	isInit = true
end
