local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

function UF:ConstructPetFrame(frame)
	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(42, 134)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetAllPoints()
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_pet")
	bg:SetTexCoord(84 / 256, 126 / 256, 0, 134 / 256)

	local cover = CreateFrame("Frame", nil, frame)
	cover:SetFrameLevel(level + 3)
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

	frame.Health = UF:CreateHealthBar(frame, 12, nil, true)
	frame.Health:SetFrameLevel(level + 1)
	frame.Health:SetSize(8, 112)
	frame.Health:SetPoint("CENTER", -6, 0)
	frame.Health.Value:SetJustifyH("RIGHT")
	frame.Health.Value:SetParent(cover)
	frame.Health.Value:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 8, 26)
	tinsert(frame.mouseovers, frame.Health)

	frame.HealPrediction = UF:CreateHealPrediction(frame, true)

	frame.Power = UF:CreatePowerBar(frame, 12, nil, true)
	frame.Power:SetFrameLevel(level + 2)
	frame.Power:SetSize(8, 102)
	frame.Power:SetPoint("CENTER", 6, 0)
	frame.Power.Value:SetJustifyH("RIGHT")
	frame.Power.Value:SetParent(cover)
	frame.Power.Value:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 8, 14)
	tinsert(frame.mouseovers, frame.Power)

	frame.Castbar = UF:CreateCastBar(frame, 196, {"BOTTOM", "UIParent", "BOTTOM", 0, 190}, nil, true, true)
	RegisterStateDriver(frame.Castbar, "visibility", "[possessbar] show; hide")

	frame.Threat = UF:CreateThreat(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_pet", 126 / 256, 147 / 256, 0, 134 / 256)
	frame.Threat:SetSize(21, 134)
	frame.Threat:SetPoint("CENTER", -10, 0)

	frame.DebuffHighlight = UF:CreateDebuffHighlight(frame, "Interface\\AddOns\\oUF_LS\\media\\frame_pet", 147 / 256, 168 / 256, 0, 134 / 256)
	frame.DebuffHighlight:SetSize(21, 134)
	frame.DebuffHighlight:SetPoint("CENTER", 10, 0)
end
