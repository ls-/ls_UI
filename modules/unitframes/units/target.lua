local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local isInit = false

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
		self:UpdateCastbar()
		self:UpdateName()
		self:UpdateRaidTargetIndicator()
		self:UpdatePvPIndicator()
		self:UpdateDebuffIndicator()
		self:UpdateThreatIndicator()
		self:UpdateAuras()
		self:UpdateClassIndicator()
	else
		if self:IsEnabled() then
			self:Disable()
		end
	end
end

function UF:HasTargetFrame()
	return isInit
end

function UF:CreateTargetFrame(frame)
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

	frame.Castbar = self:CreateCastbar(frame)

	frame.Name = self:CreateName(frame, textParent)

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, textParent)

	local pvp = self:CreatePvPIndicator(frame, textureParent)
	frame.PvPIndicator = pvp

	pvp.Holder.PostExpand = function()
		if not frame.Castbar._config.detached then
			frame.Castbar.Holder:SetWidth(frame.Castbar.Holder._width - 52)
		end
	end

	pvp.Holder.PostCollapse = function()
		if not frame.Castbar._config.detached then
			frame.Castbar.Holder:SetWidth(frame.Castbar.Holder._width)
		end
	end

	frame.DebuffIndicator = self:CreateDebuffIndicator(frame, textParent)

	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	frame.Auras = self:CreateAuras(frame, "target")

	local status = textParent:CreateFontString(nil, "ARTWORK", "LSIcon16Font")
	status:SetJustifyH("LEFT")
	status:SetPoint("LEFT", frame, "BOTTOMLEFT", 4, -1)
	frame:Tag(status, "[ls:questicon][ls:sheepicon][ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]")

	local border = E:CreateBorder(textureParent)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thick")
	border:SetOffset(-6)
	frame.Border = border

	frame.ClassIndicator = self:CreateClassIndicator(frame)

	local glass = textureParent:CreateTexture(nil, "OVERLAY", nil, 0)
	glass:SetAllPoints(health)
	glass:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")

	local shadow = textureParent:CreateTexture(nil, "OVERLAY", nil, -1)
	shadow:SetAllPoints(health)
	shadow:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")

	frame.Update = frame_Update

	isInit = true
end
