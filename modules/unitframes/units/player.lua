local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

function UF:ConstructPlayerFrame(frame)
	tinsert(UF.framesByUnit["player"], frame)

	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(164, 164)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
	bg:SetTexCoord(318 / 512, 422 / 512, 9 / 512, 159 / 512)
	bg:SetSize(104, 150)
	bg:SetPoint("CENTER")

	local mid = CreateFrame("Frame", "$parentMiddle", frame)
	mid:SetFrameLevel(level + 3)
	mid:SetAllPoints()

	local ring = mid:CreateTexture(nil, "BACKGROUND", nil, 1)
	ring:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
	ring:SetTexCoord(0 / 512, 168 / 512, 0 / 512, 202 / 512)
	ring:SetSize(168, 202)
	ring:SetPoint("CENTER", 0, -17)

	local cover = CreateFrame("Frame", "$parentCover", frame)
	cover:SetFrameLevel(level + 5)
	cover:SetAllPoints()
	frame.Cover = cover

	local tube = cover:CreateTexture(nil, "ARTWORK", nil, 0)
	tube:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power_new")
	tube:SetTexCoord(1 / 512, 21 / 512, 1 / 512, 129 / 512)
	tube:SetSize(20, 128)
	tube:SetPoint("LEFT", 15, 0)
	cover.Tube = tube

	local sep = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	sep:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power_new")
	sep:SetSize(20, 128)
	sep:SetPoint("LEFT", 15, 0)
	cover.Sep = sep

	local gloss = cover:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
	gloss:SetTexCoord(0 / 512, 98 / 512, 202 / 512, 342 / 512)
	gloss:SetSize(98, 140)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
	fg:SetTexCoord(168 / 512, 318 / 512, 9 / 512, 159 / 512)
	fg:SetSize(150, 150)
	fg:SetPoint("CENTER")

	local health = UF:CreateHealthBar(frame, 18, nil, true)
	health:SetFrameLevel(level + 1)
	health:SetSize(94, 132)
	health:SetPoint("CENTER")
	tinsert(frame.mouseovers, health)
	frame.Health = health

	local healthText = health.Text
	healthText:SetParent(cover)
	healthText:SetJustifyH("RIGHT")
	healthText:SetPoint("CENTER", 0, 8)

	frame.HealPrediction = UF:CreateHealPrediction(frame, true)

	local absrobGlow = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	absrobGlow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
	absrobGlow:SetTexCoord(373 / 512, 475 / 512, 202 / 512, 241 / 512)
	absrobGlow:SetVertexColor(E:ColorLighten(0, 0.7, 0.95, 0.35))
	absrobGlow:SetSize(102, 39)
	absrobGlow:SetPoint("CENTER", 0, 54)
	absrobGlow:SetAlpha(0)
	frame.AbsorbGlow = absrobGlow

	local damageAbsorb = E:CreateFontString(cover, 12, "$parentDamageAbsorbsText", true)
	damageAbsorb:SetPoint("CENTER", 0, 24)
	frame:Tag(damageAbsorb, "[custom:damageabsorb]")

	local healAbsorb = E:CreateFontString(cover, 12, "$parentHealAbsorbsText", true)
	healAbsorb:SetPoint("CENTER", 0, 38)
	frame:Tag(healAbsorb, "[custom:healabsorb]")

	local power = UF:CreatePowerBar(frame, 14, nil, true)
	power:SetFrameLevel(level + 4)
	power:SetSize(12, 128)
	power:SetPoint("RIGHT", -19, 0)
	E:SetBarSkin(power, "VERTICAL-L")
	tinsert(frame.mouseovers, power)
	frame.Power = power

	local powerText = power.Text
	powerText:SetParent(cover)
	powerText:SetPoint("CENTER", 0, -8)

	if C.units.player.castbar then
		frame.Castbar = UF:CreateCastBar(frame, 202, true, true)

		frame.Castbar.Holder:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 190)
		E:CreateMover(frame.Castbar.Holder)
	end

	local status = cover:CreateFontString("$parentStatusIcons", "ARTWORK", "LSStatusIcon16Font")
	status:SetJustifyH("CENTER")
	status:SetPoint("BOTTOM", 0, -18)
	frame:Tag(status, "[ls:combatresticon][ls:pvpicon][ls:lfdroleicon][ls:leadericon]")

	local debuffStatus = cover:CreateFontString("$parentDebuffStatus", "OVERLAY", "LSStatusIcon12Font")
	debuffStatus:SetWidth(14)
	debuffStatus:SetDrawLayer("OVERLAY")
	debuffStatus:SetPoint("LEFT", health, "LEFT", 0, 0)
	frame:Tag(debuffStatus, "[ls:debuffstatus]")

	UF:Reskin(frame, "NONE", true, 0, "NONE")

	if E.PLAYER_CLASS == "MONK" then
		frame.Stagger = UF:CreateStaggerBar(frame, level + 4)
		frame.Stagger.Value:SetParent(cover)
		frame.Stagger.Value:SetPoint("CENTER", 0, -20)
		tinsert(frame.mouseovers, frame.Stagger)
	elseif E.PLAYER_CLASS == "DEATHKNIGHT" then
		frame.Runes = UF:CreateRuneBar(frame, level + 4)
	end

	frame.ClassIcons = UF:CreateClassPowerBar(frame, level + 4)

	local fcf = CreateFrame("Frame", "$parentFeedbackFrame", frame)
	fcf:SetFrameLevel(7)
	fcf:SetSize(94, 94)
	fcf:SetPoint("CENTER", 0, 78)
	frame.FloatingCombatFeedback =  fcf

	for i = 1, 4 do
		fcf[i] = E:CreateFontString(fcf, 18, nil, true)
	end

	fcf.Mode = "Fountain"
	fcf.YOffset = 20

	local threat = UF:CreateThreat(frame)
	threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
	threat:SetTexCoord(199 / 512, 373 / 512, 202 / 512, 340 / 512)
	threat:SetSize(174, 138)
	threat:SetPoint("CENTER", 0, 17)
	frame.Threat = threat
end
