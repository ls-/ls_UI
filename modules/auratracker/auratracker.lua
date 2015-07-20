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

local function HandleDataCorruption(filter, spec, overflow)
	local auraList, size = AT_CONFIG[spec][filter], #AT_CONFIG[spec][filter]

	if size > 0 then
		for i, v in next, auraList do
			if not GetSpellInfo(v) then
				tremove(auraList, i)
			end
		end
	end

	if overflow and size > 6 then
		for i = 1, size - 6 do
			local ID = auraList[7]
			if ID then
				print("|cff1ec77eAuraTracker|r: Removed "..GetSpellInfo(ID).." ("..ID..").")

				tremove(auraList, 7)
			end
		end

		print("|cff1ec77eAuraTracker|r: Reduced number of entries to 7 auras per list.")
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
				E:Blink(self, 0.8, nil, 0.25)
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

	E:HandleCooldown(cd, 14)

	button.CD = cd

	local cover = CreateFrame("Frame", nil, button)
	cover:SetAllPoints()

	local count = E:CreateFontString(cover, 12, nil, true, "THINOUTLINE")
	count:SetPoint("TOPRIGHT", 2, 1)

	button.Count = count

	return button
end

local function AT_Update(self, event, ...)
	if event == "CUSTOM_ENABLE" then
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

			local overflow = #AT_CONFIG[i].HELPFUL + #AT_CONFIG[i].HARMFUL > 12

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

	for i = #self.auras + 1, 12 do
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

function AT:AddToList(filter, ID)
	if #AT_CONFIG[spec].HELPFUL + #AT_CONFIG[spec].HARMFUL == 12 then
		return false, "|cffe52626Error!|r Can\'t add aura. List is full. Max of 12."
	end

	if not AT_CONFIG.enabled then
		return false, "|cffe52626Error!|r Can\'t add aura. Module is disabled."
	end

	local name = GetSpellInfo(ID)
	if not name then
		return false, "|cffe52626Error!|r Can\'t add aura, that doesn't exist."
	end

	if tcontains(AT_CONFIG[spec][filter], ID) then
		return false, "|cffe52626Error!|r Can\'t add aura. Already in the list."
	end

	tinsert(AT_CONFIG[spec][filter], ID)

	LSAuraTracker:Update("CUSTOM_FORCE_UPDATE")

	return true, "|cff26a526Success!|r Added "..name.." ("..ID..")."
end

function AT:RemoveFromList(filter, ID)
	for i, v in next, AT_CONFIG[spec][filter] do
		if v == ID then
			tremove(AT_CONFIG[spec][filter], i)

			LSAuraTracker:Update("CUSTOM_FORCE_UPDATE")

			return true, "|cff26a526Success!|r Removed "..GetSpellInfo(ID).." ("..ID..")."
		end
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

local function ATHeaderDropDown_Initialize(self)
	local info = UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = AT_LOCKED and UNLOCK_FRAME or LOCK_FRAME
	info.func = function()
		AT_LOCKED = not AT_LOCKED
		AT_CONFIG.locked = AT_LOCKED
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

local function CreateSlashCommands()
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
	tracker:SetClampedToScreen(true)
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

	local label = E:CreateFontString(header, 12, nil, true, nil, nil, 1, 0.75, 0.1)
	label:SetPoint("LEFT", 2, 0)
	label:SetAlpha(0.2)
	label:SetText(lsAURATRACKER)

	header.text = label

	local dropdown = CreateFrame("Frame", "LSAuraTrackerDropDown", header, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(dropdown, ATHeaderDropDown_Initialize, "MENU")

	header.menu = dropdown

	-- CreateSlashCommands()
end
