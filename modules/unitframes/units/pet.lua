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

	frame:SetSize(42, 134)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetSize(38, 114)
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-pet-bg")
	bg:SetTexCoord(1 / 64, 39 / 64, 1 / 128, 115 / 128)
	bg:SetPoint("CENTER", 0, 0)

	local cover = _G.CreateFrame("Frame", "$parentCover", frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fg:SetSize(32, 70)
	fg:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-pet-fg")
	fg:SetTexCoord(1 / 64, 33 / 64, 1 / 128, 71 / 128)
	fg:SetPoint("CENTER", 0, 0)

	local health = UF:CreateHealth(frame, true, "LS12Font_Shadow")
	health:SetFrameLevel(level + 1)
	health:SetSize(8, 112)
	health:SetPoint("CENTER", -6, 0)
	E:SetStatusBarSkin(health, "VERTICAL-M")
	frame.Health = health

	frame.HealthPrediction = UF:CreateHealthPrediction(frame)

	local power = self:CreatePower(frame, true, "LS12Font_Shadow")
	power:SetFrameLevel(level + 2)
	power:SetSize(8, 102)
	power:SetPoint("CENTER", 6, 0)
	E:SetStatusBarSkin(power, "VERTICAL-M")
	frame.Power = power

	-- raid target
	frame.RaidTargetIndicator = UF:CreateRaidTargetIndicator(cover)

	local status = E:CreateFontString(cover, 12, "$parentDebuffStatus")
	status:SetWidth(14)
	status:SetWordWrap(true)
	status:SetDrawLayer("OVERLAY")
	status:SetPoint("CENTER")
	frame:Tag(status, "[ls:debuffstatus]")

	frame.Castbar = UF:CreateCastbar(frame)
	frame.Castbar.Holder:SetPoint("BOTTOM", "LSPlayerFrameCastbarHolder", "TOP", 0, 6)
	_G.RegisterStateDriver(frame.Castbar.Holder, "visibility", "[possessbar] show; hide")

	local threat = UF:CreateThreat(frame)
	threat:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-pet-threat")
	threat:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 51 / 64)
	threat:SetSize(44, 50)
	threat:SetPoint("CENTER", 0, 0)
	frame.ThreatIndicator = threat
end

function UF:UpdatePetFrame(frame)
	-- local config = frame._config

	self:UpdateHealth(frame)
	self:UpdateCastbar(frame)
	self:UpdateHealthPrediction(frame)
	self:UpdatePower(frame)
	self:UpdateRaidTargetIndicator(frame)

	frame:UpdateAllElements("LSUI_PetFrameUpdate")
end
