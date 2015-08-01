local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF


local function ArenaFrame_OnEvent(self, event, ...)
	local specID = GetArenaOpponentSpec(self:GetID())

	if specID and specID > 0 then
		local _, _, _, icon = GetSpecializationInfoByID(specID)

		self.SpecInfo.Icon:SetTexture(icon)
	end
end

local function Trinket_OnEvent(self, event, ...)
	local _, name, _, _, spellID = ...

	if spellID == 42292 or spellID == 59752 then
		CooldownFrame_SetTimer(self.CD, GetTime(), 120, 1)
		self.CD.start = GetTime()
	elseif spellID == 7744 then
		if 120 - (GetTime() - (self.CD.start or 0)) < 30 then
			CooldownFrame_SetTimer(self.CD, GetTime(), 30, 1)
		end
	end
end

function UF:CreateArenaHolder()
	local holder = CreateFrame("Frame", "LSArenaHolder", UIParent)
	holder:SetSize(112 + 2 + 124 + 2 + 28 + 6 + 28 + 2 * 2, 38 * 5 + 12 * 5 + 2)
	holder:SetPoint(unpack(C.units.arena.point))
	E:CreateMover(holder)
end

function UF:ConstructArenaFrame(frame)
	local level = frame:GetFrameLevel()

	frame.mouseovers = {}
	frame:SetSize(112, 38)
	frame:RegisterEvent("UNIT_NAME_UPDATE", ArenaFrame_OnEvent)
	frame:RegisterEvent("ARENA_OPPONENT_UPDATE", ArenaFrame_OnEvent)
	frame:SetID(strmatch(frame.unit, "arena(%d)"))

	-- frame.unit = "player"
	-- E:AlwaysShow(frame)

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_short")
	bg:SetTexCoord(0 / 256, 112 / 256, 0 / 128, 38 / 128)
	bg:SetAllPoints()

	local cover = CreateFrame("Frame", nil, frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local gloss = cover:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_short")
	gloss:SetTexCoord(80 / 256, 174 / 256, 38 / 128, 58 / 128)
	gloss:SetSize(94, 20)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_short")
	fg:SetTexCoord(112 / 256, 218 / 256, 4 / 128, 34 / 128)
	fg:SetSize(106, 30)
	fg:SetPoint("CENTER")

	frame.Health = UF:CreateHealthBar(frame, 12, true)
	frame.Health:SetFrameLevel(level + 1)
	frame.Health:SetSize(90, 20)
	frame.Health:SetPoint("CENTER")
	frame.Health.Value:SetJustifyH("RIGHT")
	frame.Health.Value:SetParent(cover)
	frame.Health.Value:SetPoint("RIGHT", -12, 0)
	tinsert(frame.mouseovers, frame.Health)

	frame.HealPrediction = UF:CreateHealPrediction(frame)

	local absrobGlow = cover:CreateTexture(nil, "ARTWORK", nil, 1)
	absrobGlow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_short")
	absrobGlow:SetTexCoord(218 / 256, 234 / 256, 4 / 128, 30 / 128)
	absrobGlow:SetVertexColor(E:ColorLighten(0, 0.7, 0.95, 0.35))
	absrobGlow:SetSize(16, 26)
	absrobGlow:SetPoint("CENTER", 42, 0)
	absrobGlow:SetAlpha(0)
	frame.AbsorbGlow = absrobGlow

	frame.Power = UF:CreatePowerBar(frame, 10, true)
	frame.Power:SetFrameLevel(level + 4)
	frame.Power:SetSize(62, 2)
	frame.Power:SetPoint("CENTER", 0, -11)
	frame.Power.Value:SetJustifyH("LEFT")
	frame.Power.Value:SetPoint("LEFT")
	frame.Power.Value:SetDrawLayer("OVERLAY", 2)
	tinsert(frame.mouseovers, frame.Power)

	local tube = frame.Power:CreateTexture(nil, "OVERLAY", nil, 0)
	tube:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other_short")
	tube:SetTexCoord(0 / 256, 80 / 256, 38 / 128, 48 / 128)
	tube:SetSize(80, 10)
	tube:SetPoint("CENTER")
	frame.Power.Tube = tube

	frame.Castbar = UF:CreateCastBar(frame, 124, {"RIGHT", frame, "LEFT", -2, 0}, 10)

	frame.RaidIcon = cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)
	frame.RaidIcon:SetSize(24, 24)
	frame.RaidIcon:SetPoint("TOPRIGHT", -4, 22)

	local name = E:CreateFontString(cover, 12, "$parentNameText", true)
	name:SetDrawLayer("ARTWORK", 4)
	name:SetPoint("LEFT", frame, "LEFT", 2, 0)
	name:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
	name:SetPoint("BOTTOM", frame, "TOP", 0, 0)
	frame:Tag(name, "[custom:name]")

	local specinfo = CreateFrame("Frame", nil, frame)
	specinfo:SetSize(28, 28)
	specinfo:SetPoint("LEFT", frame, "RIGHT", 2, 0)
	frame.SpecInfo = specinfo

	E:CreateBorder(specinfo)

	local icon = specinfo:CreateTexture()
	icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	E:TweakIcon(icon)
	specinfo.Icon = icon

	local trinket = CreateFrame("Frame", nil, frame)
	trinket:SetSize(28, 28)
	trinket:SetPoint("LEFT", specinfo, "RIGHT", 6, 0)
	trinket:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", frame.unit)
	trinket:SetScript("OnEvent", Trinket_OnEvent)
	frame.Trinket = trinket

	E:CreateBorder(trinket)

	icon = trinket:CreateTexture()
	icon:SetTexture(UnitFactionGroup("player") == "Horde" and "Interface\\ICONS\\INV_Jewelry_TrinketPVP_02" or "Interface\\ICONS\\INV_Jewelry_TrinketPVP_01")
	E:TweakIcon(icon)
	trinket.Icon = icon

	local cd = CreateFrame("Cooldown", nil, trinket, "CooldownFrameTemplate")
	cd:ClearAllPoints()
	cd:SetPoint("TOPLEFT", 1, -1)
	cd:SetPoint("BOTTOMRIGHT", -1, 1)
	E:HandleCooldown(cd, 12)
	trinket.CD = cd
end
