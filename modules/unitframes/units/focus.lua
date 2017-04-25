local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

function UF:ConstructFocusFrame(frame)
	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(204, 36)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	bg:SetTexCoord(0 / 512, 204 / 512, 0 / 256, 36 / 256)
	bg:SetAllPoints()

	local bgIndicatorLeft = frame:CreateTexture(nil, "BACKGROUND", nil, 3)
	bgIndicatorLeft:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	frame.BgIndicatorLeft = bgIndicatorLeft

	local bgIndicatorMiddle = frame:CreateTexture(nil, "BACKGROUND", nil, 3)
	bgIndicatorMiddle:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	frame.BgIndicatorMiddle = bgIndicatorMiddle

	local bgIndicatorRight = frame:CreateTexture(nil, "BACKGROUND", nil, 3)
	bgIndicatorRight:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	frame.BgIndicatorRight = bgIndicatorRight

	local cover = CreateFrame("Frame", "$parentCover", frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local gloss = cover:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
	gloss:SetTexCoord(0, 1, 0 / 64, 20 / 64)
	gloss:SetSize(188, 20)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	frame.Fg = fg

	local fgLeft = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fgLeft:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	fgLeft:SetTexCoord(116 / 512, 130 / 512, 66 / 256, 92 / 256)
	fgLeft:SetSize(14, 26)
	fgLeft:SetPoint("LEFT", 5, 0)

	local fgRight = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fgRight:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
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

	local healthText = health.Text
	healthText:SetParent(cover)
	healthText:SetJustifyH("RIGHT")
	healthText:SetPoint("RIGHT", -12, 0)

	frame.HealthPrediction = UF:CreateHealPrediction(frame)

	local absrobGlow = cover:CreateTexture(nil, "ARTWORK", nil, 3)
	absrobGlow:SetTexture("Interface\\RAIDFRAME\\Shield-Overshield")
	absrobGlow:SetBlendMode("ADD")
	absrobGlow:SetSize(10, 18)
	absrobGlow:SetPoint("RIGHT", -6, 0)
	absrobGlow:SetAlpha(0)
	frame.AbsorbGlow = absrobGlow

	local power = UF:CreatePowerBar(frame, 10, true)
	power:SetFrameLevel(level + 4)
	power:SetSize(156, 2)
	power:SetPoint("CENTER", 0, -11)
	E:SetStatusBarSkin(power, "HORIZONTAL-SMALL")
	tinsert(frame.mouseovers, power)
	frame.Power = power

	local powerText = power.Text
	powerText:SetJustifyH("LEFT")
	powerText:SetPoint("LEFT")

	frame.PvPIndicator = UF:CreatePvPIcon(frame, "BACKGROUND", 2, true)
	frame.PvPIndicator:SetPoint("TOPLEFT", frame, "TOPRIGHT", 3, -14)

	frame.PvPIndicator.Hook:SetPoint("TOPLEFT", frame.PvPIndicator, "TOPLEFT", -16, 14)
	frame.PvPIndicator.Hook:SetTexCoord(34 / 64, 1 / 64, 1 / 64, 37 / 64)

	frame.Castbar = UF:CreateCastBar(frame, 188)
	frame.Castbar.Holder:SetPoint("TOP", frame, "BOTTOM", 0, -1)

	frame.ReadyCheckIndicator = cover:CreateTexture("$parentReadyCheckIcon", "BACKGROUND")
	frame.ReadyCheckIndicator:SetSize(32, 32)
	frame.ReadyCheckIndicator:SetPoint("CENTER")

	frame.RaidTargetIndicator = cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)
	frame.RaidTargetIndicator:SetSize(24, 24)
	frame.RaidTargetIndicator:SetPoint("TOPRIGHT", -4, 22)

	local name = E:CreateFontString(cover, 12, "$parentNameText", true)
	name:SetDrawLayer("ARTWORK", 4)
	name:SetPoint("LEFT", frame, "LEFT", 4, 0)
	name:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
	name:SetPoint("BOTTOM", frame, "TOP", 0, 1)
	frame:Tag(name, "[ls:questicon][ls:difficulty][ls:effectivelevel][shortclassification]|r [ls:unitcolor][ls:name][ls:server]|r")

	local statusTopLeft = cover:CreateFontString("$parentTopLeftStatusIcons", "ARTWORK", "LSStatusIcon16Font")
	statusTopLeft:SetJustifyH("LEFT")
	statusTopLeft:SetPoint("TOPLEFT", 4, 2)
	frame:Tag(statusTopLeft, "[ls:sheepicon][ls:phaseicon][ls:leadericon][ls:lfdroleicon][ls:classicon]")

	local debuffStatus = cover:CreateFontString("$parentDebuffStatus", "OVERLAY", "LSStatusIcon12Font")
	debuffStatus:SetPoint("LEFT", 12, 0)
	frame:Tag(debuffStatus, "[ls:debuffstatus]")

	local threat = UF:CreateThreat(frame, "player")
	threat:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	threat:SetTexCoord(0 / 512, 210 / 512, 200 / 256, 230 / 256)
	threat:SetSize(210, 30)
	threat:SetPoint("CENTER", 0, 6)
	frame.ThreatIndicator = threat

	frame.Auras = UF:CreateAuras(frame, "focus", 24)
	frame.Auras:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 8, 16)
end
