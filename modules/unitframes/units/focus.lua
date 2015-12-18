local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

function UF:ConstructFocusFrame(frame)
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

	frame.Health = UF:CreateHealthBar(frame, 12, true)
	frame.Health:SetFrameLevel(level + 1)
	frame.Health:SetSize(184, 20)
	frame.Health:SetPoint("CENTER")
	frame.Health.Value:SetJustifyH("RIGHT")
	frame.Health.Value:SetParent(cover)
	frame.Health.Value:SetPoint("RIGHT", -12, 0)
	tinsert(frame.mouseovers, frame.Health)

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

	local tubeLeft = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeLeft:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeLeft:SetTexCoord(0 / 32, 12 / 32, 23 / 64, 33 / 64)
	tubeLeft:SetSize(12, 10)
	tubeLeft:SetPoint("LEFT", -10, 0)

	local tubeMiddleTop = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeMiddleTop:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeMiddleTop:SetTexCoord(0, 1, 20 / 64, 23 / 64)
	tubeMiddleTop:SetHeight(3)
	tubeMiddleTop:SetPoint("TOPLEFT", 0, 3)
	tubeMiddleTop:SetPoint("TOPRIGHT", 0, 3)

	local tubeGloss = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeMiddleTop:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeMiddleTop:SetTexCoord(0, 1, 0 / 64, 20 / 64)
	tubeMiddleTop:SetAllPoints()

	local tubeMiddleBottom = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeMiddleBottom:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeMiddleBottom:SetTexCoord(0, 1, 23 / 64, 20 / 64)
	tubeMiddleBottom:SetHeight(3)
	tubeMiddleBottom:SetPoint("BOTTOMLEFT", 0, -3)
	tubeMiddleBottom:SetPoint("BOTTOMRIGHT", 0, -3)

	local tubeRight = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tubeRight:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	tubeRight:SetTexCoord(20 / 32, 32 / 32, 23 / 64, 33 / 64)
	tubeRight:SetSize(12, 10)
	tubeRight:SetPoint("RIGHT", 10, 0)

	frame.Power.Tube = {
		[1] = tubeLeft,
		[2] = tubeMiddleTop,
		[3] = tubeMiddleBottom,
		[4] = tubeRight,
	}

	if C.units.focus.castbar then
		frame.Castbar = UF:CreateCastBar(frame, 196, {"TOP", frame, "BOTTOM", 0, -2})
	end

	frame.ReadyCheck = cover:CreateTexture("$parentReadyCheckIcon", "BACKGROUND")
	frame.ReadyCheck:SetSize(32, 32)
	frame.ReadyCheck:SetPoint("CENTER")

	frame.RaidIcon = cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)
	frame.RaidIcon:SetSize(24, 24)
	frame.RaidIcon:SetPoint("TOPRIGHT", -4, 22)

	local name = E:CreateFontString(cover, 12, "$parentNameText", true)
	name:SetDrawLayer("ARTWORK", 4)
	name:SetPoint("LEFT", frame, "LEFT", 4, 0)
	name:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
	name:SetPoint("BOTTOM", frame, "TOP", 0, 1)
	frame:Tag(name, "[ls:questicon][custom:difficulty][custom:effectivelevel][shortclassification]|r [custom:name]")

	local status_top_left = E:CreateNewFontString(cover, 16, "$parentTopLeftStatusIcons")
	status_top_left:SetDrawLayer("ARTWORK", 3)
	status_top_left:SetJustifyH("LEFT")
	status_top_left:SetPoint("TOPLEFT", 4, 2)
	frame:Tag(status_top_left, "[ls:sheepicon][ls:pvpicon]")

	local status_top_right = E:CreateNewFontString(cover, 16, "$parentTopRightStatusIcons")
	status_top_right:SetDrawLayer("ARTWORK", 3)
	status_top_right:SetJustifyH("RIGHT")
	status_top_right:SetPoint("TOPRIGHT", -4, 2)
	status_top_right:Hide()
	frame:Tag(status_top_right, "[ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]")
	tinsert(frame.mouseovers, status_top_right)

	frame.Threat = UF:CreateThreat(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_other", 0 / 512, 103 / 512, 36 / 256, 66 / 256)
	frame.Threat:SetSize(103, 30)
	frame.Threat:SetPoint("TOPLEFT", -3, 3)

	frame.DebuffHighlight = UF:CreateDebuffHighlight(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_other", 103 / 512, 206 / 512, 36 / 256, 66 / 256)
	frame.DebuffHighlight:SetSize(103, 30)
	frame.DebuffHighlight:SetPoint("TOPRIGHT", 3, 3)

	frame.Buffs = UF:CreateBuffs(frame, {"BOTTOMRIGHT", frame, "TOPRIGHT", 0, 30}, 8)
	frame.Debuffs = UF:CreateDebuffs(frame, {"BOTTOMLEFT", frame, "TOPLEFT", 0, 30}, 8)
end
