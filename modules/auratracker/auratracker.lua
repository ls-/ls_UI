local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local AT = E:AddModule("AuraTracker")
local AT_CFG

local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local tremove, tinsert, tcontains, tonumber = tremove, tinsert, tContains, tonumber

local function ScanAuras(auras, index, filter)
	local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitAura("player", index, filter)
	if name and tcontains(AT_CFG[AT.Spec][filter], spellId) then
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
	local auraList, size = AT_CFG[spec][filter], #AT_CFG[spec][filter]

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

			local overflow = #AT_CFG[i].HELPFUL + #AT_CFG[i].HARMFUL > 12

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
			if #AT_CFG[newSpec].HELPFUL + #AT_CFG[newSpec].HARMFUL == 0 then
				AT_CFG[newSpec].HELPFUL = {unpack(AT_CFG[oldSpec].HELPFUL)}
				AT_CFG[newSpec].HARMFUL = {unpack(AT_CFG[oldSpec].HARMFUL)}
			end

			if oldSpec == "0" then
				AT_CFG[oldSpec].HELPFUL = {}
				AT_CFG[oldSpec].HARMFUL = {}
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
 		AT:Initialize(true)
 	end

	AT.Tracker:Show()
	AT.Tracker:ClearAllPoints()
	AT.Tracker:SetPoint(unpack(AT_CFG.point))
	AT.Tracker:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
	AT.Tracker:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")

	AT.Spec = tostring(GetSpecialization() or 0)

	if not AT:IsRunning() then
		AT_Update(AT.Tracker, "FORCE_INIT")
	else
		AT_Update(AT.Tracker, "ENABLE")
	end

	if AT_CFG.locked then AT.Header:Hide() end

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
	if #AT_CFG[AT.Spec].HELPFUL + #AT_CFG[AT.Spec].HARMFUL == 12 then
		return false, "|cffe52626Error!|r Can\'t add aura. List is full. Max of 12."
	end

	if not AT_CFG.enabled then
		return false, "|cffe52626Error!|r Can\'t add aura. Module is disabled."
	end

	local name = GetSpellInfo(ID)
	if not name then
		return false, "|cffe52626Error!|r Can\'t add aura, that doesn't exist."
	end

	if tcontains(AT_CFG[AT.Spec][filter], ID) then
		return false, "|cffe52626Error!|r Can\'t add aura. Already in the list."
	end

	tinsert(AT_CFG[AT.Spec][filter], ID)

	AT_Update(AT.Tracker, "ADD_TO_LIST")

	return true, "|cff26a526Success!|r Added "..name.." ("..ID..")."
end

function AT:RemoveFromList(filter, ID)
	for i, v in next, AT_CFG[AT.Spec][filter] do
		if v == ID then
			tremove(AT_CFG[AT.Spec][filter], i)

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

	AT_CFG.point = {E:GetCoords(self:GetParent())}
end

function AT:Initialize(forceInit)
	AT_CFG = C.auratracker

	if AT_CFG.enabled or forceInit then
		local tracker = CreateFrame("Frame", "LSAuraTracker", UIParent)
		tracker:SetClampedToScreen(true)
		tracker:SetMovable(true)
		tracker:RegisterEvent("PLAYER_ENTERING_WORLD")
		tracker:SetScript("OnEvent", AT_Update)
		AT.Tracker = tracker

		local buttons = {}

		for i = 1, 12 do
			local button = E:CreateButton(tracker, "$parentButton"..i, true)
			button:Hide()
			button:SetScript("OnEnter", ATButton_OnEnter)
			button:SetScript("OnLeave", ATButton_OnLeave)
			button:SetScript("OnUpdate", ATButton_OnUpdate)
			buttons[i] = button

			button.CD:SetTimerTextHeight(14)
			button.Count:SetFontObject("LS12Font_Outline")
		end

		tracker.buttons = buttons

		if AT_CFG.direction == "RIGHT" or AT_CFG.direction == "LEFT" then
			tracker:SetSize(36 * 12 + 4 * 12, 36 + 4)
		else
			tracker:SetSize(36 + 4, 36 * 12 + 4 * 12)
		end

		E:SetButtonPosition(buttons, 36, 4, tracker, AT_CFG.direction)

		local header = CreateFrame("Button", "$parentHeader", tracker)
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

		SLASH_ATBUFF1 = "/atbuff"
		SlashCmdList["ATBUFF"] = function(msg)
			local _, text = AT:AddToList("HELPFUL", tonumber(msg))

			print("|cff1ec77eAuraTracker|r: "..text)
		end

		SLASH_ATDEBUFF1 = "/atdebuff"
		SlashCmdList["ATDEBUFF"] = function(msg)
			local _, text = AT:AddToList("HARMFUL", tonumber(msg))

			print("|cff1ec77eAuraTracker|r: "..text)
		end
	end
end
