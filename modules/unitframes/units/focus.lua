local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

function UF:ConstructFocusFrame(frame)
	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame.rearrangeables = {}
	frame:SetSize(206, 38)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_long")
	bg:SetTexCoord(0 / 512, 206 / 512, 0 / 128, 38 / 128)
	bg:SetAllPoints()

	local cover = CreateFrame("Frame", nil, frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local gloss = cover:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_long")
	gloss:SetTexCoord(174 / 512, 362 / 512, 38 / 128, 58 / 128)
	gloss:SetSize(188, 20)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_long")
	fg:SetTexCoord(206 / 512, 406 / 512, 4 / 128, 34 / 128)
	fg:SetSize(200, 30)
	fg:SetPoint("CENTER")

	frame.Health = UF:CreateHealthBar(frame, 12, true)
	frame.Health:SetFrameLevel(level + 1)
	frame.Health:SetSize(184, 20)
	frame.Health:SetPoint("CENTER")
	frame.Health.Value:SetJustifyH("RIGHT")
	frame.Health.Value:SetParent(cover)
	frame.Health.Value:SetPoint("RIGHT", -12, 0)
	tinsert(frame.mouseovers, frame.Health)

	frame.HealPrediction = UF:CreateHealPrediction(frame)

	local absrobGlow = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	absrobGlow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_long")
	absrobGlow:SetTexCoord(362 / 512, 378 / 512, 38 / 128, 64 / 128)
	absrobGlow:SetVertexColor(E:ColorLighten(0, 0.7, 0.95, 0.35))
	absrobGlow:SetSize(16, 26)
	absrobGlow:SetPoint("CENTER", 89, 0)
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

	local tube = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tube:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_long")
	tube:SetTexCoord(0 / 512, 174 / 512, 38 / 128, 48 / 128)
	tube:SetSize(174, 10)
	tube:SetPoint("CENTER")
	frame.Power.Tube = tube

	frame.Castbar = UF:CreateCastBar(frame, 196, {"TOP", frame, "BOTTOM", 0, 0})

	frame.PvP = UF:CreateIcon(cover, "PvP", 14)
	tinsert(frame.mouseovers, frame.PvP)
	tinsert(frame.rearrangeables, frame.PvP)

	frame.PhaseIcon = UF:CreateIcon(cover, "Phase", 14)
	tinsert(frame.mouseovers, frame.PhaseIcon)
	tinsert(frame.rearrangeables, frame.PhaseIcon)

	frame.Leader = UF:CreateIcon(cover, "Leader", 14)
	tinsert(frame.mouseovers, frame.Leader)
	tinsert(frame.rearrangeables, frame.Leader)

	frame.LFDRole = UF:CreateIcon(cover, "LFDRole", 14)
	tinsert(frame.mouseovers, frame.LFDRole)
	tinsert(frame.rearrangeables, frame.LFDRole)

	frame.QuestIcon = UF:CreateIcon(frame, "Quest", 14)
	frame.QuestIcon:SetPoint("TOPLEFT", 4, 12)

	frame.ReadyCheck = cover:CreateTexture("$parentReadyCheckIcon", "BACKGROUND")
	frame.ReadyCheck:SetSize(32, 32)
	frame.ReadyCheck:SetPoint("CENTER")

	frame.RaidIcon = cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)
	frame.RaidIcon:SetSize(24, 24)
	frame.RaidIcon:SetPoint("TOPRIGHT", -4, 22)

	local name = E:CreateFontString(cover, 14, "$parentNameText", true)
	name:SetDrawLayer("ARTWORK", 4)
	name:SetPoint("LEFT", frame, "LEFT", 2, 0)
	name:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
	name:SetPoint("BOTTOM", frame, "TOP", 0, 14)
	frame:Tag(name, "[custom:name]")

	local class = E:CreateFontString(cover, 12, "$parentClassText", true)
	class:SetDrawLayer("ARTWORK", 4)
	class:SetPoint("LEFT", frame, "LEFT", 2, 0)
	class:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
	class:SetPoint("BOTTOM", frame, "TOP", 0, 0)
	frame:Tag(class, "[difficulty][level][shortclassification]|r [custom:racetype]")

	frame.Threat = UF:CreateThreat(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_other_long", 0 / 512, 105 / 512, 59 / 128, 92 / 128)
	frame.Threat:SetSize(105, 33)
	frame.Threat:SetPoint("CENTER", -53, 4)

	frame.DebuffHighlight = UF:CreateDebuffHighlight(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_other_long", 105 / 512, 210 / 512, 59 / 128, 92 / 128)
	frame.DebuffHighlight:SetSize(105, 33)
	frame.DebuffHighlight:SetPoint("CENTER", 53, 4)

	frame.Buffs = UF:CreateBuffs(frame, {"BOTTOMRIGHT", frame, "TOPRIGHT", 0, 30}, 8)
	frame.Debuffs = UF:CreateDebuffs(frame, {"BOTTOMLEFT", frame, "TOPLEFT", 0, 30}, 8)
end
