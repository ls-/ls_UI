local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:CreateVerticalPetFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.db.profile.units[E.UI_LAYOUT].pet

	local fg_parent = _G.CreateFrame("Frame", nil, frame)
	fg_parent:SetFrameLevel(level + 4)
	fg_parent:SetAllPoints()
	frame.FGParent = fg_parent

	local fg = fg_parent:CreateTexture(nil, "ARTWORK", nil, 1)
	fg:SetSize(80 / 2, 148 / 2)
	fg:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pet-frame")
	fg:SetTexCoord(1 / 128, 81 / 128, 1 / 256, 149 / 256)
	fg:SetPoint("CENTER", 0, 0)

	local health = self:CreateHealth(frame, true, "LSFont12_Shadow", frame)
	health:SetFrameLevel(level + 1)
	health:SetSize(8, 112)
	health:SetPoint("CENTER", -6, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	local health_bg = health:CreateTexture(nil, "BACKGROUND")
	health_bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
	health_bg:SetAllPoints()

	frame.HealthPrediction = self:CreateHealthPrediction(health)

	local power = self:CreatePower(frame, true, "LSFont12_Shadow", frame)
	power:SetFrameLevel(level + 1)
	power:SetSize(8, 102)
	power:SetPoint("CENTER", 6, 0)
	frame.Power = power

	local power_bg = power:CreateTexture(nil, "BACKGROUND")
	power_bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
	power_bg:SetAllPoints()

	frame.Castbar = self:CreateCastbar(frame)
	-- frame.Castbar.Holder:SetPoint("BOTTOM", "LSPlayerFrameCastbarHolder", "TOP", 0, 6)
	-- _G.RegisterStateDriver(frame.Castbar.Holder, "visibility", "[possessbar] show; hide")

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(fg_parent)

	frame.DebuffIndicator = self:CreateDebuffIndicator(fg_parent)
	frame.DebuffIndicator:SetWidth(14)

	local threat = self:CreateThreatIndicator(frame, true)
	threat:SetTexture("Interface\\AddOns\\ls_UI\\assets\\pet-frame-glow")
	threat:SetTexCoord(1 / 128, 85 / 128, 1 / 128, 97 / 128)
	threat:SetSize(84 / 2, 96 / 2)
	threat:SetPoint("CENTER", 0, 0)
	frame.ThreatIndicator = threat

	local left_tube = _G.CreateFrame("Frame", nil, frame)
	left_tube:SetFrameLevel(level + 3)
	left_tube:SetAllPoints(health)
	frame.LeftTube = left_tube

	E:SetStatusBarSkin(left_tube, "VERTICAL-8")

	local right_tube = _G.CreateFrame("Frame", nil, frame)
	right_tube:SetFrameLevel(level + 3)
	right_tube:SetAllPoints(power)
	frame.RightTube = right_tube

	E:SetStatusBarSkin(right_tube, "VERTICAL-8")

	-- frame.unit = "player"
	-- E:ForceShow(frame)
end

function UF:CreateHorizontalPetFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.db.profile.units[E.UI_LAYOUT].pet

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
	frame.Castbar.Holder:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -3, -6)

	frame.Name = self:CreateName(text_parent, "LSFont12_Shadow")

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(text_parent)

	frame.ThreatIndicator = self:CreateThreatIndicator(frame)

	frame.DebuffIndicator = self:CreateDebuffIndicator(text_parent)

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
end

function UF:UpdatePetFrame(frame)
	frame._config = C.db.profile.units[E.UI_LAYOUT].pet

	frame:SetSize(frame._config.width, frame._config.height)

	if frame.Insets then
		self:UpdateInsets(frame)
	end

	self:UpdateHealth(frame)
	self:UpdateHealthPrediction(frame)
	self:UpdatePower(frame)
	self:UpdateCastbar(frame)
	self:UpdateRaidTargetIndicator(frame)
	self:UpdateDebuffIndicator(frame)
	self:UpdateThreatIndicator(frame)

	if frame.Name then
		self:UpdateName(frame)
	end

	if frame.ClassIndicator then
		self:UpdateClassIndicator(frame)
	end

	frame:UpdateAllElements("LSUI_PetFrameUpdate")
end
