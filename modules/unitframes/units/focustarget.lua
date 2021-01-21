local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local function frame_Update(self)
	self:UpdateConfig()

	if self._config.enabled then
		if not self:IsEnabled() then
			self:Enable()
		end

		self:UpdateSize()
		self:UpdateLayout()
		self:UpdateHealth()
		self:UpdateHealthPrediction()
		self:UpdatePortrait()
		self:UpdatePower()
		self:UpdateName()
		self:UpdateRaidTargetIndicator()
		self:UpdateThreatIndicator()
		self:UpdateClassIndicator()
		self:UpdateCustomTexts()
	else
		if self:IsEnabled() then
			self:Disable()
		end
	end
end

function UF:CreateFocusTargetFrame(frame)
	local level = frame:GetFrameLevel()

	-- .TextureParent
	-- .TextParent
	-- .Insets
	-- .Border
	self:CreateLayout(frame, level)

	local health = self:CreateHealth(frame, frame.TextParent)
	health:SetFrameLevel(level + 1)
	health:SetPoint("LEFT", frame.Insets.Left, "RIGHT", 0, 0)
	health:SetPoint("RIGHT", frame.Insets.Right, "LEFT", 0, 0)
	health:SetPoint("TOP", frame.Insets.Top, "BOTTOM", 0, 0)
	health:SetPoint("BOTTOM", frame.Insets.Bottom, "TOP", 0, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	frame.HealthPrediction = self:CreateHealthPrediction(frame, health, frame.TextParent)

	frame.Portrait = self:CreatePortrait(frame)

	local power = self:CreatePower(frame, frame.TextParent)
	power:SetFrameLevel(level + 1)
	frame.Power = power

	frame.Insets.Bottom:Capture(power, 0, 0, -2, 0)

	frame.Name = self:CreateName(frame, frame.TextParent)

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(frame, frame.TextParent)

	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	local status = frame.TextParent:CreateFontString(nil, "ARTWORK")
	status:SetFont(GameFontNormal:GetFont(), 16)
	status:SetJustifyH("RIGHT")
	status:SetPoint("RIGHT", frame, "BOTTOMRIGHT", -4, -1)
	frame:Tag(status, "[ls:questicon][ls:sheepicon][ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]")

	frame.ClassIndicator = self:CreateClassIndicator(frame)

	frame.CustomTexts = self:CreateCustomTexts(frame, frame.TextParent)

	frame.Update = frame_Update
end
