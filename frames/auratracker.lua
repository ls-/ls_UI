local _, ns = ...
local C, M = ns.C, ns.M

local buffList = {
	-- 116257,
	-- 61316,
	-- 7302,
}

local BUTTON_LAYOUT = {
	{"BOTTOMLEFT", 2, 2},
	{"BOTTOMLEFT", 46, 2},
	{"BOTTOMLEFT", 90, 2},
	{"BOTTOMLEFT", 136, 2},
	{"BOTTOMLEFT", 180, 2},
	{"BOTTOMLEFT", 224, 2},
}

local auraTracker = CreateFrame("Frame", "oUF_LSAuraTackerBar", UIParent, "SecureHandlerStateTemplate")
auraTracker:SetSize(264, 64)
auraTracker:SetPoint("CENTER", 0, 0)
auraTracker:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
auraTracker:RegisterEvent("PLAYER_LOGIN")

auraTracker.buffs = {}
auraTracker.buttons = {}

local UpdateTooltip = function(self)
	GameTooltip:SetUnitAura("player", self:GetID(), "HELP")
end

local OnEnter = function(self)
	if(not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local function oUF_LSAuraTacker_ButtonSpawn(count)
	count = count > 5 and 5 or count
	for i =  1, count do
		if not auraTracker.buttons[i] then
			local button = CreateFrame("Frame", "AuraTrackerBuff"..i, auraTracker)
			button:SetSize(40, 40)

			button.icon = button:CreateTexture(nil, "BACKGROUND", -8)
			button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			button.icon:SetAllPoints(button)

			button.border = button:CreateTexture(nil, "BORDER")
			button.border:SetTexture(M.textures.button.normalmetal)
			button.border:SetTexCoord(14 / 64, 50 / 64, 14 / 64, 50 / 64)
			button.border:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 4)
			button.border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)

			button.fg = CreateFrame("Frame", nil, button)
			button.fg:SetAllPoints(button)
			button.fg:SetFrameLevel(5)

			button.timer = ns.CreateFontString(button.fg, M.font, 14, "THINOUTLINE")
			button.timer:SetPoint("BOTTOM", button.fg, "BOTTOM", 1, 0)

			button:Hide()

			button.UpdateTooltip = UpdateTooltip

			button:SetScript("OnEnter", OnEnter)
			button:SetScript("OnLeave", OnLeave)

			table.insert(auraTracker.buttons, button)
		end
	end

	for id, button in pairs(auraTracker.buttons) do
		button:SetPoint(unpack(BUTTON_LAYOUT[id]))
	end
end

local function oUF_LSAuraButton_OnUpdate(self, elapsed)
	self.expire = auraTracker.buffs[self.id].expire
	self:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed < 0.1 then return end
		self.elapsed = 0

		local timeLeft = self.expire - GetTime()
			if timeLeft > 0 then
				if timeLeft > 10 then
					self.timer:SetTextColor(0.9, 0.9, 0.9)
				elseif timeLeft > 5 and timeLeft <= 10 then
					self.timer:SetTextColor(1, 0.75, 0.1)
				elseif timeLeft <= 5 then
					self.timer:SetTextColor(0.9, 0.1, 0.1)
				end
				self.timer:SetText(ns.TimeFormat(timeLeft))
			else
				self.timer:SetText(nil)
			end
	end)
end

local function oUF_LSAuraButton_OnEvent(...)
	auraTracker.buffs = {}
	for i = 1, 32 do
		local name, _, iconTexture, count, buffType, duration, expirationTime, casterID, _, _, spellId = UnitBuff("player", i)
		if name and tContains(buffList, spellId) then
			local aura = {}
			aura.id = spellId
			aura.index = i
			aura.icon = iconTexture
			aura.expire = expirationTime
			auraTracker.buffs[#auraTracker.buffs + 1] = aura
		end
	end
	for i = #auraTracker.buffs + 1, 5 do
		if auraTracker.buttons[i] then
			auraTracker.buttons[i]:Hide()
			auraTracker.buttons[i]:SetScript("OnUpdate", nil)
		end
	end
	for i = 1, #auraTracker.buffs do
		auraTracker.buttons[i]:Show()
		auraTracker.buttons[i]:SetID(auraTracker.buffs[i].index)
		auraTracker.buttons[i].id = i
		auraTracker.buttons[i].icon:SetTexture(auraTracker.buffs[i].icon)
		auraTracker.buttons[i]:SetScript("OnUpdate", oUF_LSAuraButton_OnUpdate)
	end
end

auraTracker:SetScript("OnEvent", oUF_LSAuraButton_OnEvent)

ns.DebugTexture(auraTracker)

SLASH_ATADD1 = '/atadd'
local function AuraTracker_Add(msg)
	table.insert(buffList, tonumber(msg))
	oUF_LSAuraTacker_ButtonSpawn(#buffList)
	oUF_LSAuraButton_OnEvent()
end
SlashCmdList["ATADD"] = AuraTracker_Add

SLASH_ATREM1 = '/atrem'
local function AuraTracker_Remove(msg)
	for k,v in pairs(buffList) do
		if v == tonumber(msg) then
			table.remove(buffList, k)
		end
	end
	oUF_LSAuraButton_OnEvent()
end
SlashCmdList["ATREM"] = AuraTracker_Remove