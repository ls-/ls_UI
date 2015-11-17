local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")
local COLORS = M.colors
local INLINE_ICONS = M.textures.inlineicons

local wipe, unpack, tcontains = wipe, unpack, tContains

local UnitAura = UnitAura
local GetArenaOpponentSpec, GetSpecializationInfoByID = GetArenaOpponentSpec, GetSpecializationInfoByID
local CooldownFrame_SetTimer, GetTime = CooldownFrame_SetTimer, GetTime

local CROWDCONTROL = {
	-- hex
	51514,
	-- polymorphs
	118,
	28271,
	28272,
	61305,
	61721,
	61780,
	126819,
	161353,
	161354,
	161355,
	161372,
	-- test
	-- 41425,
}

-- local TESTSPECS = {
-- 	[1] = 64,
-- 	[2] = 262,
-- 	[3] = 258,
-- 	[4] = 269,
-- 	[5] = 105
-- }

local function ArenaFrame_OnEvent(self, event, ...)
	if event == "UNIT_AURA" then
		local unit = ...
		for i = 1, 16 do
			local name, _, iconTexture, _, _, duration, expirationTime, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
			if name and tcontains(CROWDCONTROL, spellId) then
				self.SpecInfo.Icon:SetTexture(iconTexture)

				return CooldownFrame_SetTimer(self.SpecInfo.CD, expirationTime - duration, duration, true)
			end
		end
	end

	local specID, gender = GetArenaOpponentSpec(self:GetID())
	if specID and specID > 0 then
		local _, specName, _, specIcon, _, role, class = GetSpecializationInfoByID(specID)
		local className = gender == 3 and LOCALIZED_CLASS_NAMES_FEMALE[class] or LOCALIZED_CLASS_NAMES_MALE[class]

		self.SpecInfo.Icon:SetTexture(specIcon)
		self.SpecInfo.tooltipInfo = {INLINE_ICONS[role], className, specName, E:RGBToHEX(COLORS.class[class])}
	end
end

local function SpecInfo_OnEnter(self)
	if self.tooltipInfo and #self.tooltipInfo > 0 then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		GameTooltip:AddLine("|cff"..self.tooltipInfo[4]..self.tooltipInfo[2].." ("..self.tooltipInfo[3]..")|r ".. self.tooltipInfo[1])
		GameTooltip:Show()
	end
end

local function SpecInfo_OnLeave(self)
	GameTooltip:Hide()
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
	holder:SetSize(110 + 2 + 124 + 2 + 28 + 6 + 28 + 2 * 2, 36 * 5 + 14 * 5 + 2)
	holder:SetPoint(unpack(C.units.arena.point))
	E:CreateMover(holder)
end

function UF:ConstructArenaFrame(frame)
	local level = frame:GetFrameLevel()

	-- frame:SetID(strmatch(frame.unit, "arena(%d)"))
	-- frame.unit = "player"
	frame.mouseovers = {}
	frame:SetSize(110, 36)
	frame:RegisterEvent("UNIT_AURA", ArenaFrame_OnEvent)
	frame:RegisterEvent("UNIT_NAME_UPDATE", ArenaFrame_OnEvent)
	frame:RegisterEvent("ARENA_OPPONENT_UPDATE", ArenaFrame_OnEvent)
	frame:SetID(strmatch(frame.unit, "arena(%d)"))

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	bg:SetTexCoord(0 / 512, 110 / 512, 130 / 256, 166 / 256)
	bg:SetAllPoints()

	local cover = CreateFrame("Frame", nil, frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local gloss = cover:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\oUF_LS\\media\\statusbar_horizontal")
	gloss:SetTexCoord(0, 1, 0 / 64, 20 / 64)
	gloss:SetSize(94, 20)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	fg:SetTexCoord(112 / 512, 218 / 512, 160 / 256, 190 / 256)
	fg:SetSize(106, 30)
	fg:SetPoint("BOTTOM", 0, 3)
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

	frame.Health = UF:CreateHealthBar(frame, 12, true)
	frame.Health:SetFrameLevel(level + 1)
	frame.Health:SetSize(90, 20)
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
	frame.Power:SetSize(62, 2)
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

	if C.units.arena.castbar then
		frame.Castbar = UF:CreateCastBar(frame, 124, {"RIGHT", frame, "LEFT", -2, 2}, "12")
	end

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
	specinfo:SetScript("OnEnter", SpecInfo_OnEnter)
	specinfo:SetScript("OnLeave", SpecInfo_OnLeave)

	local icon = specinfo:CreateTexture()
	icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	E:TweakIcon(icon)
	specinfo.Icon = icon

	local cd = CreateFrame("Cooldown", nil, specinfo, "CooldownFrameTemplate")
	cd:ClearAllPoints()
	cd:SetPoint("TOPLEFT", 1, -1)
	cd:SetPoint("BOTTOMRIGHT", -1, 1)
	E:HandleCooldown(cd, 12)
	specinfo.CD = cd

	local trinket = CreateFrame("Frame", nil, frame)
	trinket:SetSize(28, 28)
	trinket:SetPoint("LEFT", specinfo, "RIGHT", 6, 0)
	trinket:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", frame.unit)
	trinket:SetScript("OnEvent", Trinket_OnEvent)
	E:CreateBorder(trinket)
	frame.Trinket = trinket

	icon = trinket:CreateTexture()
	icon:SetTexture(UnitFactionGroup("player") == "Horde" and "Interface\\ICONS\\INV_Jewelry_TrinketPVP_02" or "Interface\\ICONS\\INV_Jewelry_TrinketPVP_01")
	E:TweakIcon(icon)
	trinket.Icon = icon

	cd = CreateFrame("Cooldown", nil, trinket, "CooldownFrameTemplate")
	cd:ClearAllPoints()
	cd:SetPoint("TOPLEFT", 1, -1)
	cd:SetPoint("BOTTOMRIGHT", -1, 1)
	E:HandleCooldown(cd, 12)
	trinket.CD = cd

	-- frame.unit = "player"
	-- E:ForceShow(frame)
end

local function ArenaPrepFrameHandler_OnEvent(self, event, ...)
	if event == "ARENA_OPPONENT_UPDATE" then
		return self:Hide()
	end

	self:Show()

	local numOpps = GetNumArenaOpponentSpecs()
	for i = 1, 5 do
		local frame = self[i]
		if i <= numOpps then
			local specID, gender = GetArenaOpponentSpec(i)
			if specID and specID > 0 then
				local _, specName, _, specIcon, _, role, class = GetSpecializationInfoByID(specID)
				local className = gender == 3 and LOCALIZED_CLASS_NAMES_FEMALE[class] or LOCALIZED_CLASS_NAMES_MALE[class]

				frame.Icon:SetTexture(specIcon)
				frame.tooltipInfo = {INLINE_ICONS[role], className, specName, E:RGBToHEX(COLORS.class[class])}
				frame:Show()
			else
				frame:Hide()
			end
		else
			frame:Hide()
		end
	end
end

local function ConstructArenaPrepFrame(index, parent)
	local frame = CreateFrame("Frame", "LSArenaPreparation"..index, parent)
	frame:SetSize(28, 28)
	E:CreateBorder(frame)
	frame:SetScript("OnEnter", SpecInfo_OnEnter)
	frame:SetScript("OnLeave", SpecInfo_OnLeave)

	local icon = frame:CreateTexture()
	icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
	E:TweakIcon(icon)
	frame.Icon = icon

	return frame
end

function UF:SetupArenaPrepFrames()
	local frame = CreateFrame("Frame", "LSArenaPrepFrameHandler", UIParent)
	frame:SetSize(12, 12)
	frame:RegisterEvent("ARENA_OPPONENT_UPDATE")
	frame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	frame:SetScript("OnEvent", ArenaPrepFrameHandler_OnEvent)
	frame:Hide()

	local label = E:CreateFontString(frame, 12, "$parentLabel", true, nil, nil, 1, 0.82, 0)
	label:SetPoint("TOPLEFT", 2, -2)
	label:SetText(UNIT_NAME_ENEMY)
	frame.Label = label

	for i = 1, 5 do
		frame[i] = ConstructArenaPrepFrame(i, frame)
	end

	return frame
end
