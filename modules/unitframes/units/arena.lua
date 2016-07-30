local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")
local COLORS = M.colors
local INLINE_ICONS = M.textures.inlineicons

local wipe, unpack, tcontains = wipe, unpack, tContains

local UnitAura = UnitAura
local GetArenaOpponentSpec, GetSpecializationInfoByID = GetArenaOpponentSpec, GetSpecializationInfoByID
local CooldownFrame_Set, GetTime = CooldownFrame_Set, GetTime

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

				return CooldownFrame_Set(self.SpecInfo.CD, expirationTime - duration, duration, true)
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
		CooldownFrame_Set(self.CD, GetTime(), 120, 1)
		self.CD.start = GetTime()
	elseif spellID == 7744 then
		if 120 - (GetTime() - (self.CD.start or 0)) < 30 then
			CooldownFrame_Set(self.CD, GetTime(), 30, 1)
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
	tinsert(UF.framesByUnit["arena"], frame)

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
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	bg:SetTexCoord(0 / 512, 110 / 512, 130 / 256, 166 / 256)
	bg:SetAllPoints()

	local cover = CreateFrame("Frame", "$parentCover", frame)
	cover:SetFrameLevel(level + 3)
	cover:SetAllPoints()
	frame.Cover = cover

	local gloss = cover:CreateTexture(nil, "BACKGROUND", nil, 0)
	gloss:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
	gloss:SetTexCoord(0, 1, 0 / 64, 20 / 64)
	gloss:SetSize(94, 20)
	gloss:SetPoint("CENTER")

	local fg = cover:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetTexture("Interface\\AddOns\\ls_UI\\media\\frame_other")
	fg:SetTexCoord(112 / 512, 218 / 512, 160 / 256, 190 / 256)
	fg:SetSize(106, 30)
	fg:SetPoint("BOTTOM", 0, 3)
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

	local health = UF:CreateHealthBar(frame, 12, true)
	health:SetFrameLevel(level + 1)
	health:SetSize(90, 20)
	health:SetPoint("CENTER")
	tinsert(frame.mouseovers, health)
	frame.Health = health

	local healthText = health.Text
	healthText:SetParent(cover)
	healthText:SetJustifyH("RIGHT")
	healthText:SetPoint("RIGHT", -12, 0)

	frame.HealPrediction = UF:CreateHealPrediction(frame)

	local absrobGlow = cover:CreateTexture(nil, "ARTWORK", nil, 3)
	absrobGlow:SetTexture("Interface\\RAIDFRAME\\Shield-Overshield")
	absrobGlow:SetBlendMode("ADD")
	absrobGlow:SetSize(10, 18)
	absrobGlow:SetPoint("RIGHT", -6, 0)
	absrobGlow:SetAlpha(0)
	frame.AbsorbGlow = absrobGlow

	local power = UF:CreatePowerBar(frame, 10, true)
	power:SetFrameLevel(level + 4)
	power:SetSize(62, 2)
	power:SetPoint("CENTER", 0, -11)
	E:SetStatusBarSkin(power, "HORIZONTAL-SMALL")
	tinsert(frame.mouseovers, power)
	frame.Power = power

	local powerText = power.Text
	powerText:SetJustifyH("LEFT")
	powerText:SetPoint("LEFT")

	if C.units.arena.castbar then
		frame.Castbar = UF:CreateCastBar(frame, 124)

		frame.Castbar.Holder:SetPoint("RIGHT", frame, "LEFT", -2, 2)
	end

	frame.RaidIcon = cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)
	frame.RaidIcon:SetSize(24, 24)
	frame.RaidIcon:SetPoint("TOPRIGHT", -4, 22)

	local name = E:CreateFontString(cover, 12, "$parentNameText", true)
	name:SetDrawLayer("ARTWORK", 4)
	name:SetPoint("LEFT", frame, "LEFT", 2, 0)
	name:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
	name:SetPoint("BOTTOM", frame, "TOP", 0, 1)
	frame:Tag(name, "[ls:smartreaction][ls:name][ls:server]|r")

	local specinfo = CreateFrame("Frame", "$parentSpecInfo", frame)
	specinfo:SetSize(28, 28)
	specinfo:SetPoint("LEFT", frame, "RIGHT", 2, 0)
	frame.SpecInfo = specinfo
	E:CreateBorder(specinfo)
	specinfo:SetScript("OnEnter", SpecInfo_OnEnter)
	specinfo:SetScript("OnLeave", SpecInfo_OnLeave)

	specinfo.Icon = E:UpdateIcon(specinfo, "Interface\\ICONS\\INV_Misc_QuestionMark")
	specinfo.CD = E:CreateCooldown(specinfo, 12)

	local trinket = CreateFrame("Frame", "$parentTrinket", frame)
	trinket:SetSize(28, 28)
	trinket:SetPoint("LEFT", specinfo, "RIGHT", 6, 0)
	trinket:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", frame.unit)
	trinket:SetScript("OnEvent", Trinket_OnEvent)
	E:CreateBorder(trinket)
	frame.Trinket = trinket

	trinket.Icon = E:UpdateIcon(trinket, UnitFactionGroup("player") == "Horde" and "Interface\\ICONS\\INV_Jewelry_TrinketPVP_02" or "Interface\\ICONS\\INV_Jewelry_TrinketPVP_01")
	trinket.CD = E:CreateCooldown(trinket, 12)

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

	frame.Icon = E:UpdateIcon(frame, "Interface\\ICONS\\INV_Misc_QuestionMark")

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
