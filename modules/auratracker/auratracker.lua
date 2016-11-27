local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local AURATRACKER = P:AddModule("AuraTracker", true)

-- Lua
local _G = _G
local table = _G.table
local pairs = _G.pairs
local tonumber = _G.tonumber

-- Blizz
local BUFF_MAX_DISPLAY = _G.BUFF_MAX_DISPLAY
local DEBUFF_MAX_DISPLAY = _G.DEBUFF_MAX_DISPLAY
local CooldownFrame_Set = _G.CooldownFrame_Set
local DebuffTypeColor = _G.DebuffTypeColor
local GetSpellInfo = _G.GetSpellInfo
local UnitAura = _G.UnitAura

--Mine
local isInit = false
local SUCCESS_TEXT = "|cff26a526Success!|r"
local ERROR_TEXT = "|cffe52626Error!|r"
local activeAuras = {}
local AuraTracker

local function PopulateActiveAurasTable(index, filter)
	local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura("player", index, filter)
	local playerSpec = E:GetPlayerSpecFlag()

	if name and C.auratracker[filter][spellID] and E:IsFilterApplied(C.auratracker[filter][spellID], playerSpec) then
		local aura = {
			index = index,
			icon = iconTexture,
			count = count,
			debuffType = debuffType,
			duration = duration,
			expire = expirationTime,
			filter = filter,
		}

		table.insert(activeAuras, aura)
	end
end

local function HandleDataCorruption(filter)
	local auraList = C.auratracker[filter]

	for k in pairs(auraList) do
		if not GetSpellInfo(k) then
			auraList[k] = nil
		end
	end
end

local function ATButton_OnEnter(self)
	_G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	_G.GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
end

local function ATButton_OnLeave()
	_G.GameTooltip:Hide()
end

local function AT_OnEvent()
	activeAuras = table.wipe(activeAuras)

	for i = 1, BUFF_MAX_DISPLAY do
		PopulateActiveAurasTable(i, "HELPFUL")
	end

	for i = 1, DEBUFF_MAX_DISPLAY do
		PopulateActiveAurasTable(i, "HARMFUL")
	end

	for i = 1, 12 do
		AuraTracker.buttons[i]:Hide()
	end

	for i = 1, #activeAuras do
		local button, aura = AuraTracker.buttons[i], activeAuras[i]

		if button then
			local color = {r = 1, g = 1, b = 1}

			button:SetID(aura.index)
			button.Icon:SetTexture(aura.icon)
			button.Count:SetText(aura.count > 1 and aura.count)
			button.filter = aura.filter

			CooldownFrame_Set(button.CD, aura.expire - aura.duration, aura.duration, true)

			if button.filter == "HARMFUL" then
				color = {M.COLORS.RED:GetRGB()}

				if aura.debuffType then
					color = DebuffTypeColor[aura.debuffType]
				end
			end

			button:SetBorderColor(color.r, color.g, color.b)
			button:Show()
		end
	end
end

-----------
-- UTILS --
-----------

function AURATRACKER:AddToList(filter, spellID)
	if not C.auratracker.enabled then
		return false, ERROR_TEXT.." Can\'t add aura. Module is disabled."
	end

	local name = GetSpellInfo(spellID)
	if not name then
		return false, ERROR_TEXT.." Can\'t add aura that doesn't exist."
	end

	if C.auratracker[filter][spellID] then
		return false, ERROR_TEXT.." Can\'t add aura. Already in the list."
	end

	C.auratracker[filter][spellID] = E:GetPlayerSpecFlag()

	AT_OnEvent(AuraTracker, "FORCE_UPDATE")

	return true, SUCCESS_TEXT.." Added "..name.." ("..spellID..")."
end

-----------------
-- INITIALISER --
-----------------

function AURATRACKER:IsInit()
	return isInit
end

function AURATRACKER:Init(isForced)
	if not isInit and (C.auratracker.enabled or isForced) then
		HandleDataCorruption("HELPFUL")
		HandleDataCorruption("HARMFUL")

		local header = _G.CreateFrame("Frame", "LSAuraTrackerHeader", _G.UIParent)
		header:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		local label = E:CreateFontString(header, 12, nil, true)
		label:SetPoint("LEFT", 2, 0)
		label:SetAlpha(0.4)
		label:SetText("|cffffd100".._G.BUFFOPTIONS_LABEL.."|r")
		header.Text = label

		header:SetSize(label:GetWidth(), 22)
		E:CreateMover(header, true)

		-- FIX-ME: Remove it later
		C.auratracker.point = nil
		C.auratracker.direction = nil

		AuraTracker = _G.CreateFrame("Frame", nil, _G.UIParent)
		AuraTracker:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
		AuraTracker:SetMovable(true)
		AuraTracker:SetClampedToScreen(true)
		AuraTracker:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
		AuraTracker:SetScript("OnEvent", AT_OnEvent)

		AuraTracker.buttons = {}

		for i = 1, 12 do
			local button = E:CreateButton(AuraTracker, nil, true)
			button:SetPushedTexture("")
			button:SetHighlightTexture("")
			button:Hide()
			button:SetScript("OnEnter", ATButton_OnEnter)
			button:SetScript("OnLeave", ATButton_OnLeave)
			AuraTracker.buttons[i] = button

			if button.CD.SetTimerTextHeight then
				button.CD:SetTimerTextHeight(14)
			end

			button.Count:SetFontObject("LS12Font_Outline")
		end

		E:UpdateBarLayout(AuraTracker, AuraTracker.buttons, C.auratracker.button_size, C.auratracker.button_gap, C.auratracker.init_anchor, C.auratracker.buttons_per_row)

		_G.SLASH_ATBUFF1 = "/atbuff"
		_G.SlashCmdList["ATBUFF"] = function(msg)
			P.print(select(2, AURATRACKER:AddToList("HELPFUL", tonumber(msg))))
		end

		_G.SLASH_ATDEBUFF1 = "/atdebuff"
		_G.SlashCmdList["ATDEBUFF"] = function(msg)
			P.print(select(2, AURATRACKER:AddToList("HARMFUL", tonumber(msg))))
		end

		-- Finalise
		isInit = true
	end
end
