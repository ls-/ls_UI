local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

local function PartyHolder_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if GetCVarBool("useCompactPartyFrames") then
			self:Hide()
		else
			self:Show()
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

function UF:CreatePartyHolder()
	local holder = CreateFrame("Frame", "LSPartyHolder", UIParent, "SecureHandlerStateTemplate")
	holder:SetSize(110, (36 + 18) * 5 + 40 * 3)
	holder:RegisterEvent("PLAYER_ENTERING_WORLD")
	holder:SetScript("OnEvent", PartyHolder_OnEvent)

	if CompactRaidFrameManager then
		holder:SetPoint(unpack(C.units.party.point1))
	else
		holder:SetPoint(unpack(C.units.party.point2))
	end

	E:CreateMover(holder)
end

function UF:ConstructPartyFrame(frame, ...)
	tinsert(UF.framesByUnit["party"], frame)

	local level = frame:GetFrameLevel()

	frame.mouseovers = {}

	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	bg:SetTexCoord(0 / 512, 110 / 512, 130 / 256, 166 / 256)
	bg:SetAllPoints()

	local cover = CreateFrame("Frame", "$parentCover", frame)
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
	powerText:SetDrawLayer("OVERLAY")
	powerText:SetJustifyH("LEFT")
	powerText:SetPoint("LEFT")

	local status_left = E:CreateFontString(cover, 16, "$parentLeftStatusIcons")
	status_left:SetDrawLayer("ARTWORK", 3)
	status_left:SetJustifyH("LEFT")
	status_left:SetPoint("TOPLEFT", 4, 2)
	frame:Tag(status_left, "[ls:lfdroleicon][ls:leadericon]")

	local status_right = E:CreateFontString(cover, 16, "$parentRightStatusIcons")
	status_right:SetDrawLayer("ARTWORK", 3)
	status_right:SetJustifyH("LEFT")
	status_right:SetPoint("TOPRIGHT", -4, 2)
	status_right:Hide()
	frame:Tag(status_right, "[ls:classicon][ls:phaseicon]")
	tinsert(frame.mouseovers, status_right)

	frame.ReadyCheck = cover:CreateTexture("$parentReadyCheckIcon", "BACKGROUND")
	frame.ReadyCheck:SetSize(32, 32)
	frame.ReadyCheck:SetPoint("CENTER")

	frame.RaidIcon = cover:CreateTexture("$parentRaidIcon", "ARTWORK", nil, 3)
	frame.RaidIcon:SetSize(24, 24)
	frame.RaidIcon:SetPoint("TOP", 0, 22)

	local name = E:CreateFontString(cover, 12, "$parentNameText", true)
	name:SetDrawLayer("ARTWORK", 4)
	name:SetPoint("LEFT", frame, "LEFT", 2, 0)
	name:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
	name:SetPoint("BOTTOM", frame, "TOP", 0, 1)
	frame:Tag(name, "[custom:difficulty][custom:effectivelevel]|r [custom:name]")

	local debuffStatus = E:CreateFontString(cover, 12, "$parentDebuffStatus")
	debuffStatus:SetDrawLayer("OVERLAY")
	debuffStatus:SetPoint("LEFT", 12, 0)
	frame:Tag(debuffStatus, "[ls:debuffstatus]")

	local threat = UF:CreateThreat(frame)
	threat:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_other")
	threat:SetTexCoord(210 / 512, 326 / 512, 200 / 256, 230 / 256)
	threat:SetSize(116, 30)
	threat:SetPoint("CENTER", 0, 6)
	frame.Threat = threat

	frame.Debuffs = UF:CreateDebuffs(frame, "party", 4)
	frame.Debuffs:SetPoint("TOP", frame, "BOTTOM", 0, 0)
end
