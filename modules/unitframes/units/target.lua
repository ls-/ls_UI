local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

function UF:ConstructTargetFrame(frame)
	tinsert(UF.framesByUnit["target"], frame)

	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(204, 36)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	bg:SetTexCoord(0 / 512, 204 / 512, 0 / 256, 36 / 256)
	bg:SetAllPoints()

	local bgIndicatorLeft = frame:CreateTexture(nil, "BACKGROUND", nil, 3)
	bgIndicatorLeft:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	frame.BgIndicatorLeft = bgIndicatorLeft

	local bgIndicatorMiddle = frame:CreateTexture(nil, "BACKGROUND", nil, 3)
	bgIndicatorMiddle:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	frame.BgIndicatorMiddle = bgIndicatorMiddle

	local bgIndicatorRight = frame:CreateTexture(nil, "BACKGROUND", nil, 3)
	bgIndicatorRight:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	frame.BgIndicatorRight = bgIndicatorRight

	local cover = CreateFrame("Frame", "$parentCover", frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local gloss = cover:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	gloss:SetTexCoord(0, 1, 0 / 64, 20 / 64)
	gloss:SetSize(188, 20)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	frame.Fg = fg

	local fgLeft = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fgLeft:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	fgLeft:SetTexCoord(116 / 512, 130 / 512, 66 / 256, 92 / 256)
	fgLeft:SetSize(14, 26)
	fgLeft:SetPoint("LEFT", 5, 0)

	local fgRight = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fgRight:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	fgRight:SetTexCoord(130 / 512, 144 / 512, 66 / 256, 92 / 256)
	fgRight:SetSize(14, 26)
	fgRight:SetPoint("RIGHT", -5, 0)

	UF:SetupRarityIndication(frame, "long")

	local health = UF:CreateHealthBar(frame, 12, true)
	health:SetFrameLevel(level + 1)
	health:SetSize(184, 20)
	health:SetPoint("CENTER")
	tinsert(frame.mouseovers, health)
	frame.Health = health

	local healthValue = E:CreateFontString(cover, 12, "$parentHealthValue", true)
	healthValue:SetJustifyH("RIGHT")
	healthValue:SetPoint("RIGHT", -12, 0)
	frame.Health.Value = healthValue

	frame.HealPrediction = UF:CreateHealPrediction(frame)

	local absrobGlow = cover:CreateTexture(nil, "ARTWORK", nil, 3)
	absrobGlow:SetTexture("Interface\\RAIDFRAME\\Shield-Overshield")
	absrobGlow:SetBlendMode("ADD")
	absrobGlow:SetSize(10, 18)
	absrobGlow:SetPoint("RIGHT", -6, 0)
	absrobGlow:SetAlpha(0)
	frame.AbsorbGlow = absrobGlow

	frame.Power = UF:CreatePowerBar(frame, 10, true)
	frame.Power:SetFrameLevel(level + 4)
	frame.Power:SetSize(156, 2)
	frame.Power:SetPoint("CENTER", 0, -11)
	frame.Power.Value:SetJustifyH("LEFT")
	frame.Power.Value:SetPoint("LEFT")
	frame.Power.Value:SetDrawLayer("OVERLAY", 2)
	tinsert(frame.mouseovers, frame.Power)

	local firstCap = frame.Power:CreateTexture(nil, "BORDER")
	firstCap:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	firstCap:SetTexCoord(1 / 64, 12 / 64, 25 / 64, 35 / 64)
	firstCap:SetSize(11, 10)
	firstCap:SetPoint("RIGHT", "$parent", "LEFT", 3, 0)

	local firstMid = frame.Power:CreateTexture(nil, "BORDER")
	firstMid:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	firstMid:SetTexCoord(0 / 64, 64 / 64, 21 / 64, 24 / 64)
	firstMid:SetHeight(3)
	firstMid:SetPoint("TOPLEFT", 0, 3)
	firstMid:SetPoint("TOPRIGHT", 0, 3)

	local tubeGloss = frame.Power:CreateTexture(nil, "BORDER", nil, -8)
	tubeGloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeGloss:SetTexCoord(0 / 64, 64 / 64, 0 / 64, 20 / 64)
	tubeGloss:SetAllPoints()

	local secondMid = frame.Power:CreateTexture(nil, "BORDER")
	secondMid:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	secondMid:SetTexCoord(0 / 64, 64 / 64, 24 / 64, 21 / 64)
	secondMid:SetHeight(3)
	secondMid:SetPoint("BOTTOMLEFT", 0, -3)
	secondMid:SetPoint("BOTTOMRIGHT", 0, -3)

	local secondCap = frame.Power:CreateTexture(nil, "BORDER")
	secondCap:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	secondCap:SetTexCoord(1 / 64, 12 / 64, 36 / 64, 46 / 64)
	secondCap:SetSize(11, 10)
	secondCap:SetPoint("LEFT", "$parent", "RIGHT", -3, 0)

	frame.Power.Tube = {
		[1] = firstCap,
		[2] = firstMid,
		[3] = secondMid,
		[4] = secondCap,
		[5] = tubeGloss,
	}

	if C.units.target.castbar then
		frame.Castbar = UF:CreateCastBar(frame, 196, {"TOP", frame, "BOTTOM", 0, -2})
	end

	frame.ReadyCheck = cover:CreateTexture("$parentReadyCheckIcon", "BACKGROUND")
	frame.ReadyCheck:SetSize(32, 32)
	frame.ReadyCheck:SetPoint("CENTER")

	frame.RaidIcon = cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)
	frame.RaidIcon:SetSize(24, 24)
	frame.RaidIcon:SetPoint("TOPRIGHT", -4, 26)

	local name = E:CreateFontString(cover, 12, "$parentNameText", true)
	name:SetDrawLayer("ARTWORK", 4)
	name:SetPoint("LEFT", frame, "LEFT", 4, 0)
	name:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
	name:SetPoint("BOTTOM", frame, "TOP", 0, 1)
	frame:Tag(name, "[ls:questicon][custom:difficulty][custom:effectivelevel][shortclassification]|r [custom:name]")

	local status_top_left = E:CreateFontString(cover, 16, "$parentTopLeftStatusIcons")
	status_top_left:SetDrawLayer("ARTWORK", 3)
	status_top_left:SetJustifyH("LEFT")
	status_top_left:SetPoint("TOPLEFT", 4, 2)
	frame:Tag(status_top_left, "[ls:sheepicon][ls:pvpicon]")

	local status_top_right = E:CreateFontString(cover, 16, "$parentTopRightStatusIcons")
	status_top_right:SetDrawLayer("ARTWORK", 3)
	status_top_right:SetJustifyH("RIGHT")
	status_top_right:SetPoint("TOPRIGHT", -4, 2)
	status_top_right:Hide()
	frame:Tag(status_top_right, "[ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]")
	tinsert(frame.mouseovers, status_top_right)

	local debuffStatus = E:CreateFontString(cover, 12, "$parentDebuffStatus")
	debuffStatus:SetDrawLayer("OVERLAY")
	debuffStatus:SetPoint("LEFT", 12, 0)
	frame:Tag(debuffStatus, "[ls:debuffstatus]")

	frame.Threat = UF:CreateThreat(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_other", 0 / 512, 103 / 512, 36 / 256, 66 / 256)
	frame.Threat:SetSize(103, 30)
	frame.Threat:SetPoint("TOPLEFT", -3, 3)

	frame.Buffs = UF:CreateBuffs(frame, "target", 16)
	frame.Buffs:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 16)

	frame.Debuffs = UF:CreateDebuffs(frame, "target", 16, "LEFT", "BOTTOMRIGHT")
	frame.Debuffs:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 16)
end
