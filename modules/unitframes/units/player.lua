local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

function UF:ConstructPlayerFrame(frame)
	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(164, 164)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
	bg:SetTexCoord(318 / 512, 422 / 512, 9 / 512, 159 / 512)
	bg:SetSize(104, 150)
	bg:SetPoint("CENTER")

	local mid = CreateFrame("Frame", nil, frame)
	mid:SetFrameLevel(level + 3)
	mid:SetAllPoints()

	local ring = mid:CreateTexture(nil, "BACKGROUND", nil, 1)
	ring:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
	ring:SetTexCoord(0 / 512, 168 / 512, 0 / 512, 202 / 512)
	ring:SetSize(168, 202)
	ring:SetPoint("CENTER", 0, -17)

	local cover = CreateFrame("Frame", nil, frame)
	cover:SetFrameLevel(level + 5)
	cover:SetAllPoints()
	frame.Cover = cover

	local tube1 = cover:CreateTexture(nil, "ARTWORK", nil, 0)
	tube1:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
	tube1:SetSize(20, 144)
	tube1:SetPoint("LEFT", 15, 0)
	cover.Tube = tube1

	local tube2 = cover:CreateTexture(nil, "ARTWORK", nil, 0)
	tube2:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
	tube2:SetTexCoord(6 / 512, 26 / 512, 8 / 256, 152 / 256)
	tube2:SetSize(20, 144)
	tube2:SetPoint("RIGHT", -15, 0)

	local sep = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	sep:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player_power")
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

	frame.Health = UF:CreateHealthBar(frame, 18, nil, true, true)
	frame.Health:SetFrameLevel(level + 1)
	frame.Health:SetSize(94, 132)
	frame.Health:SetPoint("CENTER")
	frame.Health.Value:SetParent(cover)
	frame.Health.Value:SetPoint("CENTER", 0, 8)
	tinsert(frame.mouseovers, frame.Health)

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

	frame.Power = UF:CreatePowerBar(frame, 14, nil, true)
	frame.Power:SetFrameLevel(level + 4)
	frame.Power:SetSize(12, 128)
	frame.Power:SetPoint("RIGHT", -19, 0)
	frame.Power.Value:SetParent(cover)
	frame.Power.Value:SetPoint("CENTER", 0, -8)
	tinsert(frame.mouseovers, frame.Power)

	frame.Castbar = UF:CreateCastBar(frame, 196, {"BOTTOM", "UIParent", "BOTTOM", 0, 190}, nil, true, true)

	frame.PvP = UF:CreateIcon(frame, "PvP")
	frame.PvP:SetPoint("BOTTOM", -28, -14)
	tinsert(frame.mouseovers, frame.PvP)

	frame.Resting = UF:CreateIcon(frame, "Resting")
	frame.Resting:SetPoint("BOTTOM", -10, -18)
	tinsert(frame.mouseovers, frame.Resting)

	frame.Combat = UF:CreateIcon(frame, "Combat")
	frame.Combat:SetPoint("BOTTOM", -10, -18)
	tinsert(frame.mouseovers, frame.Combat)

	frame.Leader = UF:CreateIcon(frame, "Leader")
	frame.Leader:SetPoint("BOTTOM", 10, -18)
	tinsert(frame.mouseovers, frame.Leader)

	frame.LFDRole = UF:CreateIcon(frame, "LFDRole")
	frame.LFDRole:SetPoint("BOTTOM", 28, -14)
	tinsert(frame.mouseovers, frame.LFDRole)

	UF:Reskin(frame, "NONE", true, 0, "NONE")

	if E.playerclass == "PRIEST" then
		frame.ClassIcons = UF:CreateClassPowerBar(frame, 5, "Shadow_Orbs", level + 4)
	elseif E.playerclass == "MONK" then
		frame.ClassIcons = UF:CreateClassPowerBar(frame, 6, "Chi", level + 4)
	elseif E.playerclass == "PALADIN" then
		frame.ClassIcons = UF:CreateClassPowerBar(frame, 5, "Holy_Power", level + 4)
	elseif ns.E.playerclass == "WARLOCK" then
		frame.ClassIcons = UF:CreateClassPowerBar(frame, 4, "Soul_Shards", level + 4)

		frame.BurningEmbers = UF:CreateBurningEmbers(frame, level + 4)

		frame.DemonicFury = UF:CreateDemonicFury(frame, level + 4)
	elseif E.playerclass == "DEATHKNIGHT" then
		frame.Runes = UF:CreateRuneBar(frame, level + 4)
	elseif E.playerclass == "DRUID" then
		frame.EclipseBar = UF:CreateEclipseBar(frame, level + 4)
	elseif E.playerclass == "SHAMAN" then
		frame.Totems = UF:CreateTotemBar(frame, level + 4)
	end

	frame.CPoints = UF:CreateComboBar(frame, level + 3)

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

	frame.Threat = UF:CreateThreat(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_player", 199 / 512, 286 / 512, 202 / 512, 340 / 512)
	frame.Threat:SetSize(87, 138)
	frame.Threat:SetPoint("CENTER", -44, 17)

	frame.DebuffHighlight = UF:CreateDebuffHighlight(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_player", 286 / 512, 373 / 512, 202 / 512, 340 / 512)
	frame.DebuffHighlight:SetSize(87, 138)
	frame.DebuffHighlight:SetPoint("CENTER", 44, 17)
end
