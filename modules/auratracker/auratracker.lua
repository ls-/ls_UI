local _, ns = ...
local E, M = ns.E, ns.M

E.AT = {}

local AT = E.AT

local tremove, tinsert, tcontains, tonumber = tremove, tinsert, tContains, tonumber
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local AT_CONFIG, AT_LOCKED
local spec

local function ScanAuras(auras, index, filter)
	local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitAura("player", index, filter)
	if name and tcontains(AT_CONFIG[spec][filter], spellId) then
		local aura = {
			index = index,
			icon = iconTexture,
			count = count,
			debuffType = debuffType,
			duration = duration,
			expire = expirationTime,
			filter = filter,
		}

		tinsert(auras, aura)
	end
end

local function AddToList(filter, ID)
	if #AT_CONFIG[spec].HELPFUL + #AT_CONFIG[spec].HARMFUL == 8 then
		print("|cff1ec77eAuraTracker|r: Can\'t add aura. List is full. Max of 8.")
		return
	end

	if not AT_CONFIG.enabled then
		print("|cff1ec77eAuraTracker|r: Can\'t add aura. Module is disabled.")
		return
	end

	local name = GetSpellInfo(ID)
	if not name then
		print("|cff1ec77eAuraTracker|r: Can\'t add aura, that doesn't exist.")
		return
	end

	if tcontains(AT_CONFIG[spec][filter], ID) then
		print("|cff1ec77eAuraTracker|r: Can\'t add aura. Already in the list.")
		return
	end

	tinsert(AT_CONFIG[spec][filter], ID)

	print("|cff1ec77eAuraTracker|r: Added "..name.." ("..ID..").")
end

local function RemoveFromList(filter, ID)
	for i, v in next, AT_CONFIG[spec][filter] do
		if v == ID then
			tremove(AT_CONFIG[spec][filter], i)

			print("|cff1ec77eAuraTracker|r: Removed "..GetSpellInfo(ID).." ("..ID..").")
			return true
		end
	end
end

local function HandleDataCorruption(filter, spec, overflow)
	local auraList, size = AT_CONFIG[spec][filter], #AT_CONFIG[spec][filter]

	if size > 0 then
		for i, v in next, auraList do
			if not GetSpellInfo(v) then
				tremove(auraList, i)
			end
		end
	end

	if overflow and size > 4 then
		for i = 1, size - 4 do
			local ID = auraList[5]
			if ID then
				print("|cff1ec77eAuraTracker|r: Removed "..GetSpellInfo(ID).." ("..ID..").")

				tremove(auraList, 5)
			end
		end

		print("|cff1ec77eAuraTracker|r: Reduced number of entries to 4 auras per list.")
	end
end

local function ATButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
end

local function ATButton_OnLeave(self)
	GameTooltip:Hide()
end

local function ATButton_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
		end

		self.Count:SetText(self.stacks > 0 and self.stacks or "")

		local time = self.expire - GetTime()
		if time > 0.1 then
			if time <= 30 and not (self.Blink and self.Blink:IsPlaying()) then
				E:Blink(self, 0.8, -0.75)
			elseif time >= 30 and (self.Blink and self.Blink:IsPlaying()) then
				E:StopBlink(self, true)
			end
		else
			E:StopBlink(self)
		end

		self.elapsed = 0
	end
end

local function CreateATButton()
	local button = CreateFrame("Frame", nil, UIParent)
	button:SetFrameStrata("LOW")
	button:SetFrameLevel(2)
	button:Hide()

	button:SetScript("OnEnter", ATButton_OnEnter)
	button:SetScript("OnLeave", ATButton_OnLeave)
	button:SetScript("OnUpdate", ATButton_OnUpdate)

	E:CreateBorder(button)

	local icon = button:CreateTexture()
	E:TweakIcon(icon)

	button.Icon = icon

	local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	cd:ClearAllPoints()
	cd:SetPoint("TOPLEFT", 1, -1)
	cd:SetPoint("BOTTOMRIGHT", -1, 1)

	E:HandleCooldown(cd, 16)

	button.CD = cd

	local cover = CreateFrame("Frame", nil, button)
	cover:SetAllPoints()

	local count = E:CreateFontString(cover, 14, nil, true, "THINOUTLINE")
	count:SetPoint("TOPRIGHT", 2, 1)

	button.Count = count

	return button
end

local function AT_Update(self, event, ...)
	if event == "CUSTOM_ENABLE" then
		if not AT_CONFIG.enabled then
			self:Hide()

			print("|cff1ec77eAuraTracker|r is disabled. Type \"/at enable\" to enable the module.")
		else
			if not self:IsEventRegistered("UNIT_AURA") then self:RegisterUnitEvent("UNIT_AURA", "player", "vehicle") end
			if not self:IsEventRegistered("PLAYER_SPECIALIZATION_CHANGED") then self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") end

			self:SetPoint(unpack(AT_CONFIG.point))

			spec = tostring(GetSpecialization() or 0)

			-- TODO_BEGIN: Remove it later
			if #AT_CONFIG.HELPFUL > 0 then
				AT_CONFIG["0"].HELPFUL = {unpack(AT_CONFIG.HELPFUL)}

				AT_CONFIG.HELPFUL = {}
			end

			if #AT_CONFIG.HARMFUL > 0 then
				AT_CONFIG["0"].HARMFUL = {unpack(AT_CONFIG.HARMFUL)}

				AT_CONFIG.HARMFUL = {}
			end
			-- TODO_END

			AT_LOCKED = AT_CONFIG.locked
		end

		if not AT_CONFIG.showHeader then self.header:Hide() end

		return
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local oldSpec = spec
		spec = tostring(GetSpecialization() or 0)

		if oldSpec ~= spec then
			if #AT_CONFIG[spec].HELPFUL + #AT_CONFIG[spec].HARMFUL == 0 then
				AT_CONFIG[spec].HELPFUL = {unpack(AT_CONFIG[oldSpec].HELPFUL)}
				AT_CONFIG[spec].HARMFUL = {unpack(AT_CONFIG[oldSpec].HARMFUL)}
			end

			if oldSpec == "0" then
				AT_CONFIG[oldSpec].HELPFUL = {}
				AT_CONFIG[oldSpec].HARMFUL = {}
			end
		end

		return
	elseif event == "PLAYER_ENTERING_WORLD" then
		local num = GetNumSpecializations()

		for i = 0, num do
			i = tostring(i)

			local overflow = #AT_CONFIG[i].HELPFUL + #AT_CONFIG[i].HARMFUL > 8

			HandleDataCorruption("HELPFUL", i, overflow)
			HandleDataCorruption("HARMFUL", i, overflow)
		end

		spec = tostring(GetSpecialization() or 0)

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:Update("CUSTOM_FORCE_UPDATE")

		return
	end

	self.auras = {}
	for i = 1, 32 do
		ScanAuras(self.auras, i, "HELPFUL")
	end

	for i = 1, 16 do
		ScanAuras(self.auras, i, "HARMFUL")
	end

	for i = #self.auras + 1, 8 do
		if self.buttons[i] then
			self.buttons[i]:Hide()
		end
	end

	for i = 1, #self.auras do
		local button, aura = self.buttons[i], self.auras[i]

		button:Show()
		button:SetID(aura.index)
		button.Icon:SetTexture(aura.icon)
		button.debuffType = aura.debuffType
		button.filter = aura.filter
		button.expire = aura.expire
		button.stacks = aura.count

		CooldownFrame_SetTimer(button.CD, aura.expire - aura.duration, aura.duration, true)

		local color
		if button.filter == "HARMFUL" then
			color = {r = 0.8, g = 0, b = 0}

			if button.debuffType then
				color = DebuffTypeColor[button.debuffType]
			end
		else
			color = {r = 1, g = 1, b = 1}
		end

		button:SetBorderColor(color.r, color.g, color.b)
	end
end

local function ATHeader_OnEnter(self)
	self.text:SetAlpha(1)
end

local function ATHeader_OnLeave(self)
	self.text:SetAlpha(0.2)
end

local function ATHeader_OnClick(self)
	ToggleDropDownMenu(1, nil, self.menu, "cursor", 2, -2)
end

local function ATHeader_OnDragStart(self)
	if not AT_LOCKED then
		local frame = self:GetParent()
		frame:StartMoving()
	end
end

local function ATHeader_OnDragStop(self)
	if not AT_LOCKED then
		local frame = self:GetParent()
		frame:StopMovingOrSizing()

		AT_CONFIG.point = {E:GetCoords(frame)}
	end
end

local function ATHeader_PrintCommands()
	print([[|cff1ec77eAuraTracker|r: List of commands:
|cff00ccff/atbuff spellId|r - adds aura to the list of buffs;
|cff00ccff/atdebuff spellId|r - adds aura to the list of debuffs;
|cff00ccff/atrem spellId|r - removes aura from the list;
|cff00ccff/atlist|r - prints the list of tracked auras;
|cff00ccff/atwipe|r - wipes the list of tracked auras;
|cff00ccff/atheader|r - toggles AuraTracker header visibility;
|cff00ccff/at enable/disable|r - enables or disables the module.]])
end

local function ATHeaderDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = AT_LOCKED and UNLOCK_FRAME or LOCK_FRAME
	info.func = function()
		AT_LOCKED = not AT_LOCKED
		AT_CONFIG.locked = AT_LOCKED
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)

	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = lsLISTOFCOMMANDS
	info.func = ATHeader_PrintCommands
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

local function CreateSlashCommands()
	SLASH_ATBUFF1 = "/atbuff"
	SlashCmdList["ATBUFF"] = function(msg)
		AddToList("HELPFUL", tonumber(msg))

		LSAuraTracker:Update("CUSTOM_FORCE_UPDATE")
	end

	SLASH_ATDEBUFF1 = "/atdebuff"
	SlashCmdList["ATDEBUFF"] = function(msg)
		AddToList("HARMFUL", tonumber(msg))

		LSAuraTracker:Update("CUSTOM_FORCE_UPDATE")
	end

	SLASH_ATREM1 = "/atrem"
	SlashCmdList["ATREM"] = function(msg)
		if not AT_CONFIG.enabled then
			print("|cff1ec77eAuraTracker|r: Can\'t remove aura. Module is disabled.")
			return
		end

		local ID = tonumber(msg)
		if not GetSpellInfo(ID) then
			print("|cff1ec77eAuraTracker|r: Can\'t remove aura, that doesn't exist.")
			return
		end

		local br = RemoveFromList("HELPFUL", ID)
		local dr = RemoveFromList("HARMFUL", ID)

		if br or dr then
			LSAuraTracker:Update("CUSTOM_FORCE_UPDATE")
		end
	end

	SLASH_ATLIST1 = "/atlist"
	SlashCmdList["ATLIST"] = function(msg)
		if not AT_CONFIG.enabled then
			print("|cff1ec77eAuraTracker|r: Can\'t print the list. Module is disabled.")
			return
		end

		print("|cff1ec77eAuraTracker|r: List of auras:")

		for _, v in next, AT_CONFIG[spec].HELPFUL do
			local name = GetSpellInfo(v) or " "
			print("|cff00ccff+|r "..name.." ("..v..")")
		end

		for _, v in next, AT_CONFIG[spec].HARMFUL do
			local name = GetSpellInfo(v) or " "
			print("|cffd01717-|r "..name.." ("..v..")")
		end
	end

	SLASH_ATWIPE1 = "/atwipe"
	SlashCmdList["ATWIPE"] = function(msg)
		if not AT_CONFIG.enabled then
			print("|cff1ec77eAuraTracker|r: Can\'t wipe the list. Module is disabled.")
			return
		end

		AT_CONFIG[spec].HELPFUL = {}
		AT_CONFIG[spec].HARMFUL = {}

		print("|cff1ec77eAuraTracker|r: Wiped aura list.")

		LSAuraTracker:Update("CUSTOM_FORCE_UPDATE")
	end

	SLASH_AT1 = "/at"
	SlashCmdList["AT"] = function(msg)
		if msg == "enable" then
			if AT_CONFIG.enabled then
				print("|cff1ec77eAuraTracker|r is already enabled.")
				return
			end

			if InCombatLockdown() then
				print("|cff1ec77eAuraTracker|r can\'t be enabled, while in combat.")
				return
			end

			print("|cff1ec77eAuraTracker|r was enabled.")

			AT_CONFIG.enabled = true

			LSAuraTracker:Show()
			LSAuraTracker:Update("CUSTOM_ENABLE")
			LSAuraTracker:Update("CUSTOM_FORCE_UPDATE")
		elseif msg == "disable" then
			if not AT_CONFIG.enabled then
				print("|cff1ec77eAuraTracker|r is already disabled.")
				return
			end

			if InCombatLockdown() then
				print("|cff1ec77eAuraTracker|r can\'t be disabled, while in combat.")
				return
			end

			print("|cff1ec77eAuraTracker|r was disabled.")

			AT_CONFIG.enabled = false

			LSAuraTracker:Hide()
			LSAuraTracker:UnregisterEvent("UNIT_AURA")
			LSAuraTracker:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		else
			print("|cff1ec77eAuraTracker|r: Unknown command.")
		end
	end

	SLASH_ATHEADER1 = "/atheader"
	SlashCmdList["ATHEADER"] = function(msg)
		if InCombatLockdown() then
			print("|cff1ec77eAuraTracker|r\'s header visibility can\'t be toggled, while in combat.")
			return
		end

		if LSAuraTracker.header:IsShown() then
			LSAuraTracker.header:Hide()
			AT_CONFIG.showHeader = false
		else
			LSAuraTracker.header:Show()
			AT_CONFIG.showHeader = true
		end
	end
end

function AT:Initialize()
	AT_CONFIG = ns.C.auratracker

	local tracker = CreateFrame("Frame", "LSAuraTracker", UIParent)
	tracker:SetFrameStrata("LOW")
	tracker:SetFrameLevel(1)
	tracker:SetMovable(true)

	tracker:RegisterEvent("PLAYER_ENTERING_WORLD")

	tracker:SetScript("OnEvent", AT_Update)

	tracker.Update = AT_Update

	tracker:Update("CUSTOM_ENABLE")

	local buttons = {}

	for i = 1, AT_CONFIG.num_buttons do
		buttons[i] = CreateATButton()
	end

	tracker.buttons = buttons

	if AT_CONFIG.direction == "RIGHT" or AT_CONFIG.direction == "LEFT" then
		tracker:SetSize(AT_CONFIG.button_size * AT_CONFIG.num_buttons + AT_CONFIG.button_gap * AT_CONFIG.num_buttons,
			AT_CONFIG.button_size + AT_CONFIG.button_gap)
	else
		tracker:SetSize(AT_CONFIG.button_size + AT_CONFIG.button_gap,
			AT_CONFIG.button_size * AT_CONFIG.num_buttons + AT_CONFIG.button_gap * AT_CONFIG.num_buttons)
	end

	E:SetButtonPosition(buttons, AT_CONFIG.button_size, AT_CONFIG.button_gap, tracker, AT_CONFIG.direction)

	local header = CreateFrame("Button", nil, tracker)
	header:SetSize(66, 20)
	header:SetPoint("BOTTOMLEFT", tracker, "TOPLEFT", 0, 0)
	header:RegisterForDrag("LeftButton")
	header:RegisterForClicks("RightButtonUp")
	header:SetScript("OnEnter", ATHeader_OnEnter)
	header:SetScript("OnLeave", ATHeader_OnLeave)
	header:SetScript("OnClick", ATHeader_OnClick)
	header:SetScript("OnDragStart", ATHeader_OnDragStart)
	header:SetScript("OnDragStop", ATHeader_OnDragStop)

	tracker.header = header

	local label = E:CreateFontString(header, 12, nil, true, nil, 1, 0.75, 0.1)
	label:SetPoint("LEFT", 2, 0)
	label:SetAlpha(0.2)
	label:SetText(lsAURATRACKER)

	header.text = label

	local dropdown = CreateFrame("Frame", "LSAuraTrackerDropDown", header, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(dropdown, ATHeaderDropDown_Initialize, "MENU")

	header.menu = dropdown

	CreateSlashCommands()
end
