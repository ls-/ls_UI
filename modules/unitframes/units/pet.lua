local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

function UF:ConstructPetFrame(frame)
	frame.mouseovers = {}

	frame:SetFrameLevel(1)
	frame:SetSize(42, 134)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	bg:SetTexCoord(84 / 256, 126 / 256, 0, 134 / 256)
	
	local cover = CreateFrame("Frame", nil, frame)
	cover:SetFrameLevel(4)
	cover:SetAllPoints()
	frame.Cover = cover

	local tubes = cover:CreateTexture(nil, "ARTWORK", nil, 0)
	tubes:SetAllPoints()
	tubes:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	tubes:SetTexCoord(0, 42 / 256, 0, 134 / 256)

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	fg:SetAllPoints()
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	fg:SetTexCoord(42 / 256, 84 / 256, 0, 134 / 256)

	frame.Health = UF:CreateHealthBar(frame, true, 12)
	frame.Health:SetSize(8, 112)
	frame.Health:SetPoint("CENTER", 6, 0)
	frame.Health.Value:SetJustifyH("RIGHT")
	frame.Health.Value:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 8, 30)
	tinsert(frame.mouseovers, frame.Health)

	frame.HealPrediction = UF:CreateHealPrediction(frame, true)

	frame.Power = UF:CreatePowerBar(frame, true, 12)
	frame.Power:SetSize(8, 102)
	frame.Power:SetPoint("CENTER", -6, 0)
	frame.Power.Value:SetJustifyH("RIGHT")
	frame.Power.Value:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 8, 18)
	tinsert(frame.mouseovers, frame.Power)

	frame.Threat = UF:CreateThreat(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	frame.Threat:SetTexCoord(126 / 256, 147 / 256, 0, 134 / 256)
	frame.Threat:SetSize(21, 134)
	frame.Threat:SetPoint("CENTER", frame, "CENTER", -10, 0)

	local debuffhl = frame:CreateTexture("$parentDebuffGlow", "BACKGROUND", nil, 1)
	debuffhl:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	debuffhl:SetTexCoord(147 / 256, 168 / 256, 0, 134 / 256)
	debuffhl:SetSize(21, 134)
	debuffhl:SetPoint("CENTER", frame, "CENTER", 10, 0)
	debuffhl:SetAlpha(0)

	frame.DebuffHighlight = debuffhl
	frame.DebuffHighlightAlpha = 1
	frame.DebuffHighlightFilter = false
end
