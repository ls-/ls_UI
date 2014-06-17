local _, ns = ...
local C, M, L = ns.C, ns.M, ns.L

local LOCAL_CONFIG, AURATRACKER_LOCKED

local DEFAULT_CONFIG = {
	buffList = {},
	trackerPoint = {"CENTER", UIParent, "CENTER", 0, 0},
	trackerLocked = false,
	isUsed = true,
}

local BUTTON_LAYOUT = {
	{"BOTTOMLEFT", 2, 2},
	{"BOTTOMLEFT", 46, 2},
	{"BOTTOMLEFT", 90, 2},
	{"BOTTOMLEFT", 136, 2},
	{"BOTTOMLEFT", 180, 2},
	{"BOTTOMLEFT", 224, 2},
}

local AuraTracker = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
AuraTracker:SetSize(264, 44)
AuraTracker:SetClampedToScreen(true)
AuraTracker:SetMovable(1)
AuraTracker:RegisterEvent("PLAYER_LOGIN")
AuraTracker:RegisterEvent("ADDON_LOADED")
AuraTracker:RegisterEvent("PLAYER_LOGOUT")

local AuraTrackerHeader = CreateFrame("Button", nil, AuraTracker)
AuraTrackerHeader:SetSize(66, 20)
AuraTrackerHeader:SetPoint("BOTTOMLEFT", AuraTracker, "TOPLEFT", 0, 0)
AuraTrackerHeader:SetClampedToScreen(true)
AuraTrackerHeader:EnableMouse(true)
AuraTrackerHeader:RegisterForDrag("LeftButton")
AuraTrackerHeader:RegisterForClicks("RightButtonUp")

AuraTrackerHeader.text = AuraTrackerHeader:CreateFontString(nil, "OVERLAY", "GameFontNormal")
AuraTrackerHeader.text:SetPoint("LEFT", 2, 0)
AuraTrackerHeader.text:SetText(L.AuraTracker)
AuraTrackerHeader.text:SetAlpha(0.4)

local AuraTrackerHeaderDropDown = CreateFrame("Frame", "AuraTrackerHeaderDropDown", UIParent, "UIDropDownMenuTemplate")

AuraTracker.buffs = {}
AuraTracker.buttons = {}

-- taken from oUF aura module
local function oUF_LSAuraTackerButton_UpdateTooltip(self)
	GameTooltip:SetUnitAura("player", self:GetID(), "HELP")
end

local function oUF_LSAuraTackerButton_OnEnter(self)
	if not self:IsVisible() then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local function oUF_LSAuraTackerButton_OnLeave(self)
	GameTooltip:Hide()
end

local function oUF_LSAuraTacker_ButtonSpawn(count)
	count = count > 6 and 6 or count
	for i = 1, count do
		if not AuraTracker.buttons[i] then
			local button = CreateFrame("Frame", "AuraTrackerBuff"..i, AuraTracker)
			button:SetSize(40, 40)

			button.icon = button:CreateTexture(nil, "BACKGROUND", -8)
			button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
			button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)

			button.border = ns.CreateButtonBorder(button, 1)

			button.fg = CreateFrame("Frame", nil, button)
			button.fg:SetAllPoints(button)
			button.fg:SetFrameLevel(5)

			button.timer = ns.CreateFontString(button.fg, M.font, 16, "THINOUTLINE")
			button.timer:SetPoint("BOTTOM", button.fg, "BOTTOM", 1, 0)

			button.count = ns.CreateFontString(button.fg, M.font, 14, "THINOUTLINE")
			button.count:SetPoint("TOPRIGHT", button.fg, "TOPRIGHT", 1, 0)

			ns.CreateAlphaAnimation(button, -0.85, 0.75)

			button:Hide()

			button.UpdateTooltip = oUF_LSAuraTackerButton_UpdateTooltip

			button:SetScript("OnEnter", oUF_LSAuraTackerButton_OnEnter)
			button:SetScript("OnLeave", oUF_LSAuraTackerButton_OnLeave)

			table.insert(AuraTracker.buttons, button)
		end
	end

	for id, button in pairs(AuraTracker.buttons) do
		button:SetPoint(unpack(BUTTON_LAYOUT[id]))
	end
end

local function oUF_LSAuraButton_OnUpdate(self, elapsed)
	self.expire = AuraTracker.buffs[self.id].expire
	self.stacks = AuraTracker.buffs[self.id].count
	self:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed < 0.1 then return end
		self.elapsed = 0

		self.count:SetText(self.stacks > 0 and self.stacks or "")

		local timeLeft = self.expire - GetTime()
		if timeLeft > 0 then
			if timeLeft <= 30 and not self.animation:IsPlaying() then
				self.animation:Play()
			end
			if timeLeft > 30 and self.animation:IsPlaying() then
				self.animation:Stop()
				self:SetAlpha(1)
			end
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
			if self.animation:IsPlaying() then
				self.animation:Stop()
				self:SetAlpha(1)
			end
		end
	end)
end

local function oUF_LSAuraButton_OnEvent(...)
	local _, event, arg3 = ...
	if event == "ADDON_LOADED" then
		if arg3 ~= "oUF_LS" then return end

		local function initDB(db, defaults)
			if type(db) ~= "table" then db = {} end
			if type(defaults) ~= "table" then return db end
			for k, v in pairs(defaults) do
				if type(v) == "table" then
					db[k] = initDB(db[k], v)
				elseif type(v) ~= type(db[k]) then
					db[k] = v
				end
			end
			return db
		end

		oUF_LS_AURA_CONFIG = initDB(oUF_LS_AURA_CONFIG, DEFAULT_CONFIG)
		LOCAL_CONFIG = oUF_LS_AURA_CONFIG
	elseif event == "PLAYER_LOGOUT" then
		local function cleanDB(db, defaults)
			if type(db) ~= "table" then return {} end
			if type(defaults) ~= "table" then return db end
			for k, v in pairs(db) do
				if type(v) == "table" then
					if not next(cleanDB(v, defaults[k])) then
						db[k] = nil
					end
				elseif v == defaults[k] then
					db[k] = nil
				end
			end
			return db
		end

		oUF_LS_AURA_CONFIG = cleanDB(oUF_LS_AURA_CONFIG, DEFAULT_CONFIG)
	elseif event == "UNIT_AURA" or event == "PLAYER_LOGIN" or event == "CUSTOM_FORCE_UPDATE" or event == "CUSTOM_ENABLE" then
		if LOCAL_CONFIG.isUsed == false then
			AuraTracker:Hide()
			print("|cff1ec77eAuraTracker|r is disabled. Type \"/at enable\" to enable the module.")
			return
		end

		if not AuraTracker:IsEventRegistered("UNIT_AURA") then AuraTracker:RegisterUnitEvent("UNIT_AURA", "player", "vehicle") end

		if event == "PLAYER_LOGIN" or event == "CUSTOM_ENABLE" then
			AuraTracker:SetPoint(unpack(LOCAL_CONFIG.trackerPoint))
			oUF_LSAuraTacker_ButtonSpawn(#LOCAL_CONFIG.buffList)
			AURATRACKER_LOCKED = LOCAL_CONFIG.trackerLocked
			if #LOCAL_CONFIG.buffList > 6 then
				for i = 7, #LOCAL_CONFIG.buffList do
					table.remove(LOCAL_CONFIG.buffList, i)
				end
			end
		end
		AuraTracker.buffs = {}
		for i = 1, 32 do
			local name, _, iconTexture, count, _, _, expirationTime, _, _, _, spellId = UnitBuff("player", i)
			if name and tContains(LOCAL_CONFIG.buffList, spellId) then
				local aura = {}
				aura.id = spellId
				aura.index = i
				aura.icon = iconTexture
				aura.count = count
				aura.expire = expirationTime
				AuraTracker.buffs[#AuraTracker.buffs + 1] = aura
			end
		end
		for i = #AuraTracker.buffs + 1, 6 do
			if AuraTracker.buttons[i] then
				AuraTracker.buttons[i]:Hide()
				AuraTracker.buttons[i]:SetScript("OnUpdate", nil)
			end
		end
		for i = 1, #AuraTracker.buffs do
			AuraTracker.buttons[i]:Show()
			AuraTracker.buttons[i]:SetID(AuraTracker.buffs[i].index)
			AuraTracker.buttons[i].id = i
			AuraTracker.buttons[i].icon:SetTexture(AuraTracker.buffs[i].icon)
			AuraTracker.buttons[i]:SetScript("OnUpdate", oUF_LSAuraButton_OnUpdate)
		end
	end
end

AuraTracker:SetScript("OnEvent", oUF_LSAuraButton_OnEvent)

AuraTrackerHeader:SetScript("OnDragStart", function(self)
	if not AURATRACKER_LOCKED then
		local frame = self:GetParent()
		frame:StartMoving()
	end
end)

AuraTrackerHeader:SetScript("OnDragStop", function(self)
	if not AURATRACKER_LOCKED then
		local frame = self:GetParent()
		frame:StopMovingOrSizing()

		local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
		LOCAL_CONFIG.trackerPoint = {point, "UIParent", relativePoint, xOfs, yOfs}
	end
end)

AuraTrackerHeader:SetScript("OnEnter", function(self)
	self.text:SetAlpha(1)
end)

AuraTrackerHeader:SetScript("OnLeave", function(self)
	self.text:SetAlpha(0.4)
end)

local function AuraTrackerHeader_OnClick(self, button)
	if button == "RightButton" then
		ToggleDropDownMenu(1, nil, AuraTrackerHeaderDropDown, "cursor", 3, -3)
	end
end

AuraTrackerHeader:SetScript("OnClick", AuraTrackerHeader_OnClick)

local function ToggleDrag()
	AURATRACKER_LOCKED = not AURATRACKER_LOCKED
	LOCAL_CONFIG.trackerLocked = AURATRACKER_LOCKED
end

local function PrintSlashCommands()
	print("|cff1ec77eAuraTracker|r: List of commands:")
	print("|cff00ccff/atadd spellId|r - adds aura to the list;")
	print("|cff00ccff/atrem spellId|r - removes aura from the list;")
	print("|cff00ccff/atlist|r - prints the list of tracked auras;")
	print("|cff00ccff/atwipe|r - wipes the list of tracked auras;")
	print("|cff00ccff/at enable/disable|r - enables or disables the module.")
end

local function AuraTrackerHeaderDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo()
	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = AURATRACKER_LOCKED and UNLOCK_FRAME or LOCK_FRAME
	info.func = ToggleDrag
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = L.ListofCommands
	info.func = PrintSlashCommands
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

UIDropDownMenu_Initialize(AuraTrackerHeaderDropDown, AuraTrackerHeaderDropDown_Initialize, "MENU")

SLASH_ATADD1 = '/atadd'
local function AuraTracker_Add(msg)
	if #LOCAL_CONFIG.buffList == 6 then return end
	if not LOCAL_CONFIG.isUsed then print("|cff1ec77eAuraTracker|r: Can\'t add the aura. Module is disabled.") return end

	table.insert(LOCAL_CONFIG.buffList, tonumber(msg))
	local name = GetSpellInfo(tonumber(msg))
	print("|cff1ec77eAuraTracker|r: "..name.." ("..msg..") was added to the list.")
	oUF_LSAuraTacker_ButtonSpawn(#LOCAL_CONFIG.buffList)
	oUF_LSAuraButton_OnEvent(nil, "CUSTOM_FORCE_UPDATE")
end
SlashCmdList["ATADD"] = AuraTracker_Add

SLASH_ATREM1 = '/atrem'
local function AuraTracker_Remove(msg)
	if not LOCAL_CONFIG.isUsed then print("|cff1ec77eAuraTracker|r: Can\'t remove the aura. Module is disabled.") return end

	for k,v in pairs(LOCAL_CONFIG.buffList) do
		if v == tonumber(msg) then
			table.remove(LOCAL_CONFIG.buffList, k)
			local name = GetSpellInfo(v)
			print("|cff1ec77eAuraTracker|r: "..name.." ("..v..") was removed from the list.")
		end
	end
	oUF_LSAuraButton_OnEvent(nil, "CUSTOM_FORCE_UPDATE")
end
SlashCmdList["ATREM"] = AuraTracker_Remove

SLASH_ATLIST1 = '/atlist'
local function AuraTracker_List(msg)
	if not LOCAL_CONFIG.isUsed then print("|cff1ec77eAuraTracker|r: Can\'t print the list. Module is disabled.") return end

	print("|cff1ec77eAuraTracker|r: List of auras:")
	for k,v in pairs(LOCAL_CONFIG.buffList) do
		local name = GetSpellInfo(v)
		print("|cff00ccff-|r "..name.." ("..v..")")
	end
end
SlashCmdList["ATLIST"] = AuraTracker_List

SLASH_ATWIPE1 = '/atwipe'
local function AuraTracker_Wipe(msg)
	if not LOCAL_CONFIG.isUsed then print("|cff1ec77eAuraTracker|r: Can\'t wipe the list. Module is disabled.") return end

	LOCAL_CONFIG.buffList = {}
	print("|cff1ec77eAuraTracker|r: List of auras was wiped.")
end
SlashCmdList["ATWIPE"] = AuraTracker_Wipe

SLASH_AT1 = '/at'
local function AuraTracker_Toggle(msg)
	if msg == "enable" then
		if LOCAL_CONFIG.isUsed then print("|cff1ec77eAuraTracker|r is already enabled.") return end
		if InCombatLockdown() then print("|cff1ec77eAuraTracker|r can\'t be enabled, while in combat.") return end

		print("|cff1ec77eAuraTracker|r was enabled.")
		LOCAL_CONFIG.isUsed = true
		AuraTracker:Show()
		AuraTracker:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
		oUF_LSAuraButton_OnEvent(nil, "CUSTOM_ENABLE")
	elseif msg == "disable" then
		if not LOCAL_CONFIG.isUsed then print("|cff1ec77eAuraTracker|r is already disabled.") return end
		if InCombatLockdown() then print("|cff1ec77eAuraTracker|r can\'t be disabled, while in combat.") return end

		print("|cff1ec77eAuraTracker|r was disabled.")
		LOCAL_CONFIG.isUsed = false
		AuraTracker:Hide()
		AuraTracker:UnregisterEvent("UNIT_AURA")
	else
		print("|cff1ec77eAuraTracker|r: Unknown command.")
	end
end
SlashCmdList["AT"] = AuraTracker_Toggle