local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:ConstructPetFrame(frame)
	local level = frame:GetFrameLevel()

	frame._config = C.units.pet
	frame._mouseovers = {}

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetSize(38, 114)
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\pet-frame-bg")
	bg:SetTexCoord(1 / 64, 39 / 64, 1 / 128, 115 / 128)
	bg:SetPoint("CENTER", 0, 0)

	local fg_parent = _G.CreateFrame("Frame", nil, frame)
	fg_parent:SetFrameLevel(level + 4)
	fg_parent:SetAllPoints()
	frame.FGParent = fg_parent

	local fg = fg_parent:CreateTexture(nil, "ARTWORK", nil, 1)
	fg:SetSize(32, 70)
	fg:SetTexture("Interface\\AddOns\\ls_UI\\media\\pet-frame-fg")
	fg:SetTexCoord(1 / 64, 33 / 64, 1 / 128, 71 / 128)
	fg:SetPoint("CENTER", 0, 0)

	local health = self:CreateHealth(frame, true, "LS12Font_Shadow")
	health:SetFrameLevel(level + 1)
	health:SetSize(8, 112)
	health:SetPoint("CENTER", -6, 0)
	health:SetClipsChildren(true)
	frame.Health = health

	frame.HealthPrediction = self:CreateHealthPrediction(health)

	local power = self:CreatePower(frame, true, "LS12Font_Shadow")
	power:SetFrameLevel(level + 1)
	power:SetSize(8, 102)
	power:SetPoint("CENTER", 6, 0)
	frame.Power = power

	frame.Castbar = self:CreateCastbar(frame)
	frame.Castbar.Holder:SetPoint("BOTTOM", "LSPlayerFrameCastbarHolder", "TOP", 0, 6)
	_G.RegisterStateDriver(frame.Castbar.Holder, "visibility", "[possessbar] show; hide")

	frame.RaidTargetIndicator = self:CreateRaidTargetIndicator(fg_parent)

	frame.DebuffIndicator = self:CreateDebuffIndicator(fg_parent)
	frame.DebuffIndicator:SetWidth(14)

	local threat = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
	threat:SetTexture("Interface\\AddOns\\ls_UI\\media\\pet-frame-glow")
	threat:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 51 / 64)
	threat:SetSize(44, 50)
	threat:SetPoint("CENTER", 0, 0)
	frame.ThreatIndicator = threat

	local left_tube = _G.CreateFrame("Frame", nil, frame)
	left_tube:SetFrameLevel(level + 3)
	left_tube:SetAllPoints(health)
	frame.LeftTube = left_tube

	E:SetStatusBarSkin(left_tube, "VERTICAL-M")

	local right_tube = _G.CreateFrame("Frame", nil, frame)
	right_tube:SetFrameLevel(level + 3)
	right_tube:SetAllPoints(power)
	frame.RightTube = right_tube

	E:SetStatusBarSkin(right_tube, "VERTICAL-M")
end

function UF:UpdatePetFrame(frame)
	local config = frame._config

	frame:SetSize(config.width, config.height)

	self:UpdateHealth(frame)
	self:UpdateHealthPrediction(frame)
	self:UpdatePower(frame)
	self:UpdateCastbar(frame)
	self:UpdateRaidTargetIndicator(frame)
	self:UpdateDebuffIndicator(frame)
	self:UpdateThreatIndicator(frame)

	frame:UpdateAllElements("LSUI_PetFrameUpdate")
end
