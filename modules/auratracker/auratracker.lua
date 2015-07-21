local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L

E.AT = {}

local AT = E.AT

local tremove, tinsert, tcontains, tonumber = tremove, tinsert, tContains, tonumber
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local AT_CONFIG

local function ScanAuras(auras, index, filter)
	local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitAura("player", index, filter)
	if name and tcontains(AT_CONFIG[AT.Spec][filter], spellId) then
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

local function AT_Update(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" or event == "FORCE_INIT" then
		local num = GetNumSpecializations()

		for i = 0, num do
			i = tostring(i)

			local overflow = #AT_CONFIG[i].HELPFUL + #AT_CONFIG[i].HARMFUL > 12

			HandleDataCorruption("HELPFUL", i, overflow)
			HandleDataCorruption("HARMFUL", i, overflow)
		end

		if event == "PLAYER_ENTERING_WORLD" then
			AT:Enable()

			self:UnregisterEvent("PLAYER_ENTERING_WORLD")

			return
		end
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		local oldSpec = AT.Spec
		local newSpec = tostring(GetSpecialization() or 0)

		if oldSpec ~= newSpec then
			if #AT_CONFIG[newSpec].HELPFUL + #AT_CONFIG[newSpec].HARMFUL == 0 then
				AT_CONFIG[newSpec].HELPFUL = {unpack(AT_CONFIG[oldSpec].HELPFUL)}
				AT_CONFIG[newSpec].HARMFUL = {unpack(AT_CONFIG[oldSpec].HARMFUL)}
			end

			if oldSpec == "0" then
				AT_CONFIG[oldSpec].HELPFUL = {}
				AT_CONFIG[oldSpec].HARMFUL = {}
			end
		end

		AT.Spec = newSpec
	end

	self.auras = wipe(self.auras or {})

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
		local color

		button:Show()
		button:SetID(aura.index)
		button.Icon:SetTexture(aura.icon)
		button.debuffType = aura.debuffType
		button.filter = aura.filter
		button.expire = aura.expire
		button.stacks = aura.count

		CooldownFrame_SetTimer(button.CD, aura.expire - aura.duration, aura.duration, true)

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

function AT:IsRunning()
	return not not AT.Tracker
end

function AT:Enable()
 	if InCombatLockdown() then
 		return false, "|cffe52626Error!|r Can't be done, while in combat."
 	end
	if not AT:IsRunning() then
 		AT:Initialize()
 	end

	AT.Tracker:Show()
	AT.Tracker:ClearAllPoints()
	AT.Tracker:SetPoint(unpack(AT_CONFIG.point))
	AT.Tracker:RegisterEvent("UNIT_AURA")
	AT.Tracker:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

	AT.Spec = tostring(GetSpecialization() or 0)

	if not AT:IsRunning() then
		AT_Update(AT.Tracker, "FORCE_INIT")
	else
		AT_Update(AT.Tracker, "ENABLE")
	end

	if AT_CONFIG.locked then AT.Header:Hide() end

 	return true, "|cff26a526Success!|r AT is on."
end

function AT:Disable()
	if AT:IsRunning() then
		if InCombatLockdown() then
	 		return false, "|cffe52626Error!|r Can't be done, while in combat."
	 	end

		AT.Tracker:Hide()
		AT.Tracker:UnregisterEvent("UNIT_AURA")
		AT.Tracker:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")

	 	return true, "|cff26a526Success!|r AT will be disabled on next UI reload."
	 else
	 	return true, "|cff26a526Success!|r AT is off."
	 end
end

function AT:AddToList(filter, ID)
	if #AT_CONFIG[AT.Spec].HELPFUL + #AT_CONFIG[AT.Spec].HARMFUL == 12 then
		return false, "|cffe52626Error!|r Can\'t add aura. List is full. Max of 12."
	end

	if not AT_CONFIG.enabled then
		return false, "|cffe52626Error!|r Can\'t add aura. Module is disabled."
	end

	local name = GetSpellInfo(ID)
	if not name then
		return false, "|cffe52626Error!|r Can\'t add aura, that doesn't exist."
	end

	if tcontains(AT_CONFIG[AT.Spec][filter], ID) then
		return false, "|cffe52626Error!|r Can\'t add aura. Already in the list."
	end

	tinsert(AT_CONFIG[AT.Spec][filter], ID)

	AT_Update(AT.Tracker, "ADD_TO_LIST")

	return true, "|cff26a526Success!|r Added "..name.." ("..ID..")."
end

function AT:RemoveFromList(filter, ID)
	for i, v in next, AT_CONFIG[AT.Spec][filter] do
		if v == ID then
			tremove(AT_CONFIG[AT.Spec][filter], i)

			AT_Update(AT.Tracker, "REMOVE_FROM_LIST")

			return true, "|cff26a526Success!|r Removed "..GetSpellInfo(ID).." ("..ID..")."
		end
	end
end

local function ATHeader_OnEnter(self)
	self.Text:SetAlpha(1)
end

local function ATHeader_OnLeave(self)
	self.Text:SetAlpha(0.2)
end

local function ATHeader_OnDragStart(self)
	self:GetParent():StartMoving()
end

local function ATHeader_OnDragStop(self)
	self:GetParent():StopMovingOrSizing()

	AT_CONFIG.point = {E:GetCoords(self:GetParent())}
end

function AT:Initialize()
	AT_CONFIG = C.auratracker

	local tracker = CreateFrame("Frame", "LSAuraTracker", UIParent)
	tracker:SetClampedToScreen(true)
	tracker:SetMovable(true)
	tracker:RegisterEvent("PLAYER_ENTERING_WORLD")
	tracker:SetScript("OnEvent", AT_Update)
	AT.Tracker = tracker

	local buttons = {}

	for i = 1, 12 do
		local button = CreateFrame("Frame", nil, UIParent)
		button:SetFrameLevel(tracker:GetFrameLevel() + 1)
		button:Hide()
		button:SetScript("OnEnter", ATButton_OnEnter)
		button:SetScript("OnLeave", ATButton_OnLeave)
		button:SetScript("OnUpdate", ATButton_OnUpdate)
		E:CreateBorder(button)
		buttons[i] = button

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
	end

	tracker.buttons = buttons

	if AT_CONFIG.direction == "RIGHT" or AT_CONFIG.direction == "LEFT" then
		tracker:SetSize(36 * 12 + 4 * 12, 36 + 4)
	else
		tracker:SetSize(36 + 4, 36 * 12 + 4 * 12)
	end

	E:SetButtonPosition(buttons, 36, 4, tracker, AT_CONFIG.direction)

	local header = CreateFrame("Button", nil, tracker)
	header:SetClampedToScreen(true)
	header:SetPoint("BOTTOMLEFT", tracker, "TOPLEFT", 0, 0)
	header:RegisterForDrag("LeftButton")
	header:SetScript("OnEnter", ATHeader_OnEnter)
	header:SetScript("OnLeave", ATHeader_OnLeave)
	header:SetScript("OnDragStart", ATHeader_OnDragStart)
	header:SetScript("OnDragStop", ATHeader_OnDragStop)
	AT.Header = header

	local label = E:CreateFontString(header, 12, nil, true, nil, nil, 1, 0.82, 0)
	label:SetPoint("LEFT", 2, 0)
	label:SetAlpha(0.2)
	label:SetText(BUFFOPTIONS_LABEL)
	header.Text = label

	header:SetSize(label:GetWidth(), 22)
end
