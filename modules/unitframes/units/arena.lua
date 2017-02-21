local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local unpack = unpack
local tcontains, tinsert = tContains, table.insert
local strmatch = string.match

-- Blizz
local CooldownFrame_Clear = CooldownFrame_Clear
local CooldownFrame_Set = CooldownFrame_Set
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetSpecializationInfoByID = GetSpecializationInfoByID
local UnitAura = UnitAura

-- Mine
local CROWDCONTROL = {
	118, -- sheep
	28271, -- turtle
	28272, -- pig
	51514, -- hex
	61305, -- black cat
	61721, -- rabbit
	61780, -- turkey
	126819, -- pig
	161353, -- polar bear cub
	161354, -- monkey
	161355, -- penguin
	161372, -- turtle
	-- 41425, -- hypothermia for testing
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
			local name, _, iconTexture, _, _, duration, expirationTime, _, _, _, spellID = UnitAura(unit, i, "HARMFUL")

			if name and tcontains(CROWDCONTROL, spellID) then
				self.SpecInfo.Icon:SetTexture(iconTexture)

				return CooldownFrame_Set(self.SpecInfo.CD, expirationTime - duration, duration, true)
			end
		end

		local specID, gender = GetArenaOpponentSpec(self:GetID())

		if specID and specID > 0 then
			local _, _, _, specIcon = GetSpecializationInfoByID(specID, gender)

			self.SpecInfo.Icon:SetTexture(specIcon)
		end
	else
		local specID, gender = GetArenaOpponentSpec(self:GetID())

		if specID and specID > 0 then
			local _, specName, _, specIcon, role, class = GetSpecializationInfoByID(specID, gender)
			local className = gender == 3 and _G.LOCALIZED_CLASS_NAMES_FEMALE[class] or _G.LOCALIZED_CLASS_NAMES_MALE[class]

			self.SpecInfo.Icon:SetTexture(specIcon)
			self.SpecInfo.tooltipInfo = {M.textures.inlineicons[role], className, specName, M.COLORS.CLASS[class]:GetHEX()}
		end
	end
end

local function SpecInfo_OnEnter(self)
	if self.tooltipInfo and #self.tooltipInfo > 0 then
		_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		_G.GameTooltip:AddLine("|cff"..self.tooltipInfo[4]..self.tooltipInfo[2].." ("..self.tooltipInfo[3]..")|r ".. self.tooltipInfo[1])
		_G.GameTooltip:Show()
	end
end

local function SpecInfo_OnLeave(self)
	_G.GameTooltip:Hide()
end

local function Trinket_OnEvent(self, event, ...)
	local _, name, _, _, spellID = ...

	if spellID == 195710 then -- Honorable Medallion
		CooldownFrame_Clear(self.CD)
		CooldownFrame_Set(self.CD, _G.GetTime(), 180, 1)

		self.CD.start = _G.GetTime()
	elseif spellID == 42292 or spellID == 59752 then -- PvP Trinket, Every Man for Himself
		CooldownFrame_Clear(self.CD)
		CooldownFrame_Set(self.CD, _G.GetTime(), 120, 1)

		self.CD.start = _G.GetTime()
	elseif spellID == 7744 then -- Will of the Forsaken
		if 120 - (_G.GetTime() - (self.CD.start or 0)) < 30 then
			CooldownFrame_Clear(self.CD)
			CooldownFrame_Set(self.CD, _G.GetTime(), 30, 1)
		end
	end
end

local function Trinket_OnShow(self)
	self.Icon:SetTexture(_G.UnitFactionGroup(self:GetParent().unit) == "Horde" and "Interface\\ICONS\\INV_Jewelry_TrinketPVP_02" or "Interface\\ICONS\\INV_Jewelry_TrinketPVP_01")
end

function UF:CreateArenaHolder()
	local holder = _G.CreateFrame("Frame", "LSArenaHolder", _G.UIParent)
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

	local cover = _G.CreateFrame("Frame", "$parentCover", frame)
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
	frame:Tag(name, "[ls:unitcolor][ls:name][ls:server]|r")

	local specinfo = _G.CreateFrame("Frame", "$parentSpecInfo", frame)
	specinfo:SetSize(28, 28)
	specinfo:SetPoint("LEFT", frame, "RIGHT", 2, 0)
	frame.SpecInfo = specinfo
	E:CreateBorder(specinfo)
	specinfo:SetScript("OnEnter", SpecInfo_OnEnter)
	specinfo:SetScript("OnLeave", SpecInfo_OnLeave)

	specinfo.Icon = E:SetIcon(specinfo, "Interface\\ICONS\\INV_Misc_QuestionMark")
	specinfo.CD = E:CreateCooldown(specinfo, 12)

	local trinket = _G.CreateFrame("Frame", "$parentTrinket", frame)
	trinket:SetSize(28, 28)
	trinket:SetPoint("LEFT", specinfo, "RIGHT", 6, 0)
	trinket:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", frame.unit)
	trinket:SetScript("OnEvent", Trinket_OnEvent)
	trinket:SetScript("OnShow", Trinket_OnShow)
	E:CreateBorder(trinket)
	frame.Trinket = trinket

	trinket.Icon = E:SetIcon(trinket, "Interface\\ICONS\\INV_Misc_QuestionMark")
	trinket.CD = E:CreateCooldown(trinket, 12)

	-- E:ForceShow(frame)
end

local function ArenaPrepFrameHandler_OnEvent(self, event, ...)
	if event == "ARENA_OPPONENT_UPDATE" then
		return self:Hide()
	end

	self:Show()

	local numOpps = _G.GetNumArenaOpponentSpecs()

	for i = 1, 5 do
		local frame = self[i]

		if i <= numOpps then
			local specID, gender = GetArenaOpponentSpec(i)

			if specID and specID > 0 then
				local _, specName, _, specIcon, role, class = GetSpecializationInfoByID(specID)
				local className = gender == 3 and _G.LOCALIZED_CLASS_NAMES_FEMALE[class] or _G.LOCALIZED_CLASS_NAMES_MALE[class]

				frame.Icon:SetTexture(specIcon)
				frame.tooltipInfo = {M.textures.inlineicons[role], className, specName, M.COLORS.CLASS[class]:GetHEX()}
			end

			frame:Show()
		else
			frame:Hide()
		end
	end
end

local function ConstructArenaPrepFrame(index, parent)
	local frame = _G.CreateFrame("Frame", "LSArenaPreparation"..index, parent)
	frame:SetSize(28, 28)
	E:CreateBorder(frame)
	frame:SetScript("OnEnter", SpecInfo_OnEnter)
	frame:SetScript("OnLeave", SpecInfo_OnLeave)

	frame.Icon = E:SetIcon(frame, "Interface\\ICONS\\INV_Misc_QuestionMark")

	return frame
end

function UF:SetupArenaPrepFrames()
	local frame = _G.CreateFrame("Frame", "LSArenaPrepFrameHandler", _G.UIParent)
	frame:SetSize(12, 12)
	frame:RegisterEvent("ARENA_OPPONENT_UPDATE")
	frame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	frame:SetScript("OnEvent", ArenaPrepFrameHandler_OnEvent)
	frame:Hide()

	local label = E:CreateFontString(frame, 12, "$parentLabel", true, nil, nil, 1, 0.82, 0)
	label:SetPoint("TOPLEFT", 2, -2)
	label:SetText(_G.UNIT_NAME_ENEMY)
	frame.Label = label

	for i = 1, 5 do
		frame[i] = ConstructArenaPrepFrame(i, frame)
	end

	return frame
end
