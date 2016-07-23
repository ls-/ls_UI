local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

function UF:ConstructPetFrame(frame)
	tinsert(UF.framesByUnit["pet"], frame)

	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(42, 134)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetSize(38, 114)
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-pet-bg")
	bg:SetTexCoord(1 / 64, 39 / 64, 1 / 128, 115 / 128)
	bg:SetPoint("CENTER", 0, 0)

	local cover = CreateFrame("Frame", "$parentCover", frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fg:SetSize(32, 70)
	fg:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-pet-fg")
	fg:SetTexCoord(1 / 64, 33 / 64, 1 / 128, 71 / 128)
	fg:SetPoint("CENTER", 0, 0)

	local health = UF:CreateHealthBar(frame, 12, nil, true)
	health:SetFrameLevel(level + 1)
	health:SetSize(8, 112)
	health:SetPoint("CENTER", -6, 0)
	E:SetBarSkin(health, "VERTICAL-M")
	tinsert(frame.mouseovers, health)
	frame.Health = health

	local healthText = health.Text
	healthText:SetJustifyH("RIGHT")
	healthText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 8, 26)

	frame.HealPrediction = UF:CreateHealPrediction(frame, true)

	local power = UF:CreatePowerBar(frame, 12, nil, true)
	power:SetFrameLevel(level + 2)
	power:SetSize(8, 102)
	power:SetPoint("CENTER", 6, 0)
	tinsert(frame.mouseovers, power)
	E:SetBarSkin(power, "VERTICAL-M")
	frame.Power = power

	local powerText = power.Text
	powerText:SetJustifyH("RIGHT")
	powerText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 8, 14)

	local status = E:CreateFontString(cover, 12, "$parentDebuffStatus")
	status:SetWidth(14)
	status:SetWordWrap(true)
	status:SetDrawLayer("OVERLAY")
	status:SetPoint("CENTER")
	frame:Tag(status, "[ls:debuffstatus]")

	if C.units.pet.castbar then
		frame.Castbar = UF:CreateCastBar(frame, 202, true, true)
		frame.Castbar.Holder:SetPoint("BOTTOM", LSPlayerFrameCastBarHolder, "TOP", 0, 4)
		RegisterStateDriver(frame.Castbar.Holder, "visibility", "[possessbar] show; hide")
	end

	local threat = UF:CreateThreat(frame)
	threat:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame-pet-threat")
	threat:SetTexCoord(1 / 64, 45 / 64, 1 / 64, 51 / 64)
	threat:SetSize(44, 50)
	threat:SetPoint("CENTER", 0, 0)
	frame.Threat = threat
end
