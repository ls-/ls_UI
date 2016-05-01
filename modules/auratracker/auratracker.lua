local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local AT = E:AddModule("AuraTracker", true)

-- Lua
local _G = _G
local pairs, unpack = pairs, unpack
local tonumber, tostring = tonumber, tostring
local tremove, tinsert, tcontains, twipe = table.remove, table.insert, tContains, table.wipe

-- Blizz
local BUFF_MAX_DISPLAY = BUFF_MAX_DISPLAY
local DEBUFF_MAX_DISPLAY = DEBUFF_MAX_DISPLAY
local GameTooltip = GameTooltip
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitAura = UnitAura
local CooldownFrame_SetTimer = CooldownFrame_SetTimer

--Mine
local AT_LABEL = "|cffffd100".. BUFFOPTIONS_LABEL.."|r"
local SUCCESS_TEXT = "|cff26a526Success!|r"
local ERROR_TEXT = "|cffe52626Error!|r"
local AT_CFG
local AuraTracker
local activeAuras = {}

local function PopulateActiveAurasTable(index, filter)
	local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitAura("player", index, filter)
	local playerSpec = E:GetPlayerSpecFlag()

	if name and AT_CFG[filter][spellId] and E:IsFilterApplied(AT_CFG[filter][spellId], playerSpec) then
		local aura = {
			index = index,
			icon = iconTexture,
			count = count,
			debuffType = debuffType,
			duration = duration,
			expire = expirationTime,
			filter = filter,
		}

		tinsert(activeAuras, aura)
	end
end

local function HandleDataCorruption(filter)
	local auraList = AT_CFG[filter]

	for k, v in pairs(auraList) do
		if not GetSpellInfo(k) then
			auraList[k] = nil
		end
	end

	-- DB converter
	for spec = 1, 4 do
		local auraList = AT_CFG[tostring(spec)][filter]
		for _, spellID in pairs(auraList) do
			AT_CFG[filter][spellID] = E:AddFilterToMask(AT_CFG[filter][spellID] or 0x00000000, E.PLAYER_SPEC_FLAGS[spec])
		end
		twipe(auraList)
	end
end

local function ATButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
end

local function ATButton_OnLeave(self)
	GameTooltip:Hide()
end

local function AT_OnEvent(self, event, ...)
	activeAuras = twipe(activeAuras)

	for i = 1, BUFF_MAX_DISPLAY do
		PopulateActiveAurasTable(i, "HELPFUL")
	end

	for i = 1, DEBUFF_MAX_DISPLAY do
		PopulateActiveAurasTable(i, "HARMFUL")
	end

	for i = 1, 12 do
		self.buttons[i]:Hide()
	end

	for i = 1, #activeAuras do
		local button, aura = self.buttons[i], activeAuras[i]

		if button then
			local color = {r = 1, g = 1, b = 1}

			button:Show()
			button:SetID(aura.index)
			button.Icon:SetTexture(aura.icon)
			button.filter = aura.filter
			button.expire = aura.expire
			button.stacks = aura.count

			CooldownFrame_SetTimer(button.CD, aura.expire - aura.duration, aura.duration, true)

			if button.filter == "HARMFUL" then
				color = {r = 0.8, g = 0, b = 0}

				if aura.debuffType then
					color = _G.DebuffTypeColor[aura.debuffType]
				end
			end

			button:SetBorderColor(color.r, color.g, color.b)
		end
	end
end

local function AT_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		for i = 1, 12 do
			local button = self.buttons[i]
			if button:IsShown() then
				if GameTooltip:IsOwned(button) then
					GameTooltip:SetUnitAura("player", button:GetID(), button.filter)
				end

				button.Count:SetText(button.stacks > 0 and button.stacks or "")

				local time = button.expire - GetTime()
				if time > 0.1 then
					if time <= 30 and not (button.Blink and button.Blink:IsPlaying()) then
						E:Blink(button, 0.8, nil, 0.25)
					elseif time >= 30 and (button.Blink and button.Blink:IsPlaying()) then
						E:StopBlink(button, true)
					end
				else
					E:StopBlink(button)
				end
			end
		end

		self.elapsed = 0
	end
end

function AT:IsRunning()
	return not not AuraTracker
end

function AT:Enable()
	if not AT:IsRunning() then
 		AT:Initialize(true)

		HandleDataCorruption("HELPFUL")
		HandleDataCorruption("HARMFUL")
 	else
		AuraTracker:Show()
		AuraTracker:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
 	end

	AT:ForceUpdate()

	if AT_CFG.locked then AT:HideHeader() end

 	return true, SUCCESS_TEXT.." AT is on."
end

function AT:Disable()
	if AT:IsRunning() then
		AuraTracker:Hide()
		AuraTracker:UnregisterEvent("UNIT_AURA")

	 	return true, SUCCESS_TEXT.." AT will be disabled on next UI reload."
	 else
	 	return true, SUCCESS_TEXT.." AT is off."
	 end
end

function AT:AddToList(filter, spellID)
	if not AT_CFG.enabled then
		return false, ERROR_TEXT.." Can\'t add aura. Module is disabled."
	end

	local name = GetSpellInfo(spellID)
	if not name then
		return false, ERROR_TEXT.." Can\'t add aura, that doesn't exist."
	end

	if AT_CFG[filter][spellID] then
		return false, ERROR_TEXT.." Can\'t add aura. Already in the list."
	end

	AT_CFG[filter][spellID] = E:GetPlayerSpecFlag()

	AT:ForceUpdate()

	return true, SUCCESS_TEXT.." Added "..name.." ("..spellID..")."
end

local function ATHeader_OnEnter(self)
	self.Text:SetAlpha(1)
end

local function ATHeader_OnLeave(self)
	self.Text:SetAlpha(0.2)
end

local function ATHeader_OnDragStart(self)
	AuraTracker:StartMoving()
end

local function ATHeader_OnDragStop(self)
	AuraTracker:StopMovingOrSizing()

	AT_CFG.point = {E:GetCoords(AuraTracker)}
end

function AT:GetAuraTracker()
	return AuraTracker
end

function AT:ShowHeader()
	AuraTracker.Header:Show()
end

function AT:HideHeader()
	AuraTracker.Header:Hide()
end

function AT:ForceUpdate()
	AT_OnEvent(AuraTracker, "FORCE_UPDATE")
end

function AT:PLAYER_LOGIN()
	HandleDataCorruption("HELPFUL")
	HandleDataCorruption("HARMFUL")

	if AT:IsRunning() then
		AT:ForceUpdate()
	end
end

function AT:Initialize(forceInit)
	AT_CFG = C.auratracker

	if AT_CFG.enabled or forceInit then
		AuraTracker = _G.CreateFrame("Frame", "LSAuraTracker", _G.UIParent)
		AuraTracker:SetPoint(unpack(AT_CFG.point))
		AuraTracker:SetMovable(true)
		AuraTracker:SetClampedToScreen(true)
		AuraTracker:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
		AuraTracker:SetScript("OnEvent", AT_OnEvent)
		AuraTracker:SetScript("OnUpdate", AT_OnUpdate)

		local buttons = {}
		for i = 1, 12 do
			local button = E:CreateButton(AuraTracker, "$parentButton"..i, true)
			button:SetPushedTexture("")
			button:SetHighlightTexture("")
			button:Hide()
			button:SetScript("OnEnter", ATButton_OnEnter)
			button:SetScript("OnLeave", ATButton_OnLeave)
			buttons[i] = button

			if button.CD.SetTimerTextHeight then
				button.CD:SetTimerTextHeight(14)
			end

			button.Count:SetFontObject("LS12Font_Outline")
		end

		AuraTracker.buttons = buttons

		E:SetupBar(buttons, AT_CFG.button_size, AT_CFG.button_gap, AuraTracker, AT_CFG.direction)

		local header = _G.CreateFrame("Button", "$parentHeader", AuraTracker)
		header:SetClampedToScreen(true)
		header:SetPoint("BOTTOMLEFT", AuraTracker, "TOPLEFT", 0, 0)
		header:RegisterForDrag("LeftButton")
		header:SetScript("OnEnter", ATHeader_OnEnter)
		header:SetScript("OnLeave", ATHeader_OnLeave)
		header:SetScript("OnDragStart", ATHeader_OnDragStart)
		header:SetScript("OnDragStop", ATHeader_OnDragStop)
		AuraTracker.Header = header

		local label = E:CreateFontString(header, 12, nil, true)
		label:SetPoint("LEFT", 2, 0)
		label:SetAlpha(0.2)
		label:SetText(AT_LABEL)
		header.Text = label

		header:SetSize(label:GetWidth(), 22)

		if AT_CFG.locked then AT:HideHeader() end

		SLASH_ATBUFF1 = "/atbuff"
		_G.SlashCmdList["ATBUFF"] = function(msg)
			local _, text = AT:AddToList("HELPFUL", tonumber(msg))

			print("|cff1ec77eAuraTracker|r: "..text)
		end

		SLASH_ATDEBUFF1 = "/atdebuff"
		_G.SlashCmdList["ATDEBUFF"] = function(msg)
			local _, text = AT:AddToList("HARMFUL", tonumber(msg))

			print("|cff1ec77eAuraTracker|r: "..text)
		end
	end
end

AT:RegisterEvent("PLAYER_LOGIN")
