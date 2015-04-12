local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

function UF:ConstructPlayerFrame(frame)
	frame.mouseovers = {}

	frame:SetFrameLevel(3)
	frame:SetSize(164, 164)
	frame:SetPoint("BOTTOM", "UIParent", "BOTTOM", -306 , 80)

	local chains = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
	chains:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_orb_chain_left")
	chains:SetSize(128, 64)
	chains:SetPoint("CENTER", 0, -96)

	local ring = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	ring:SetTexture("Interface\\AddOns\\oUF_LS\\media\\ring_cracked_r")
	ring:SetSize(256, 256)
	ring:SetPoint("CENTER")

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetPoint("CENTER")
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_bg_2")

	local cover = CreateFrame("Frame", nil, frame)
	cover:SetFrameLevel(6)
	cover:SetAllPoints()
	frame.Cover = cover

	local tube = cover:CreateTexture(nil, "ARTWORK", nil, 0)
	tube:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
	tube:SetSize(20, 144)
	tube:SetPoint("LEFT", 15, 0)
	cover.Tube = tube

	local sep = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	sep:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
	sep:SetSize(20, 128)
	sep:SetPoint("LEFT", 15, 0)
	cover.Sep = sep

	local gloss = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_gloss")
	gloss:SetSize(140, 140)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetPoint("CENTER")
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_fg")

	frame.Health = UF:CreateHealthBar(frame, true, nil, true)
	tinsert(frame.mouseovers, frame.Health)

	frame.HealPrediction = UF:CreateHealPrediction(frame, true)

	local damageAbsorb = E:CreateFontString(cover, 12, "$parentDamageAbsorbsText", true)
	damageAbsorb:SetPoint("CENTER", 0, 24)
	frame:Tag(damageAbsorb, "[custom:damageabsorb]")

	local healAbsorb = E:CreateFontString(cover, 12, "$parentHealAbsorbsText", true)
	healAbsorb:SetPoint("CENTER", 0, 38)
	frame:Tag(healAbsorb, "[custom:healabsorb]")

	bg = frame.Health:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetPoint("CENTER")
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_bg_1")

	frame.Power = UF:CreatePowerBar(frame, true)
	tinsert(frame.mouseovers, frame.Power)

	frame.Castbar = UF:CreateCastBar(frame, 188, {"BOTTOM", "UIParent", "BOTTOM", 0, 190}, true, true)

	frame.PvP = UF:CreateIcon(frame, "PvP")
	frame.PvP:SetPoint("BOTTOM", -28, -14)

	frame.Resting = UF:CreateIcon(frame, "Resting")
	frame.Resting:SetPoint("BOTTOM", -10, -18)

	frame.Leader = UF:CreateIcon(frame, "Leader")
	frame.Leader:SetPoint("BOTTOM", 10, -18)

	frame.LFDRole = UF:CreateIcon(frame, "LFDRole")
	frame.LFDRole:SetPoint("BOTTOM", 28, -14)

	UF:Reskin(frame, "NONE", true, 0, "NONE")

	if E.playerclass == "PRIEST" then
		frame.ClassIcons = UF:CreateClassPowerBar(frame, 5, "ShadowOrb")
	elseif E.playerclass == "MONK" then
		frame.ClassIcons = UF:CreateClassPowerBar(frame, 5, "Chi")
	elseif E.playerclass == "PALADIN" then
		frame.ClassIcons = UF:CreateClassPowerBar(frame, 5, "Holypower")
	elseif ns.E.playerclass == "WARLOCK" then
		frame.ClassIcons = UF:CreateClassPowerBar(frame, 4, "SoulShard")

		frame.BurningEmbers = UF:CreateBurningEmbers(frame)

		frame.DemonicFury = UF:CreateDemonicFury(frame)
	elseif E.playerclass == "DEATHKNIGHT" then
		frame.Runes = UF:CreateRuneBar(frame)
	elseif E.playerclass == "DRUID" then
		frame.EclipseBar = UF:CreateEclipseBar(frame)
	elseif E.playerclass == "SHAMAN" then
		frame.Totems = UF:CreateTotemBar(frame)
	end

	frame.Experience = UF:CreateRepExpBar(frame, "Exp")
	frame.Experience:SetPoint("BOTTOM", "UIParent","BOTTOM", 0, 52)
	E:CreateMover(frame.Experience)

	frame.Reputation = UF:CreateRepExpBar(frame, "Rep")
	frame.Reputation:SetPoint("BOTTOM", "UIParent","BOTTOM", 0, 2)
	E:CreateMover(frame.Reputation)

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

	frame.Threat = UF:CreateThreat(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_player_threat")
	frame.Threat:SetSize(128, 256)
	frame.Threat:SetPoint("BOTTOMRIGHT", frame, "CENTER", 0, -128)

	local debuffhl = frame:CreateTexture("$parentDebuffGlow", "BACKGROUND", nil, 1)
	debuffhl:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_debuff")
	debuffhl:SetSize(128, 256)
	debuffhl:SetPoint("BOTTOMLEFT", frame, "CENTER", 0, -128)
	debuffhl:SetAlpha(0)
	frame.DebuffHighlight = debuffhl
	frame.DebuffHighlightAlpha = 1
	frame.DebuffHighlightFilter = false --MOVE TO CONFIG
end
