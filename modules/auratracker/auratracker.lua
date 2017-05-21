local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local AURATRACKER = P:AddModule("AuraTracker")

-- Lua
local _G = getfenv(0)
local table = _G.table
local string = _G.string
local pairs = _G.pairs
local tonumber = _G.tonumber
local select = _G.select

-- Blizz
local BUFF_MAX_DISPLAY = _G.BUFF_MAX_DISPLAY
local DEBUFF_MAX_DISPLAY = _G.DEBUFF_MAX_DISPLAY
local CooldownFrame_Set = _G.CooldownFrame_Set
local DebuffTypeColor = _G.DebuffTypeColor
local GetSpellInfo = _G.GetSpellInfo
local UnitAura = _G.UnitAura

--Mine
local isInit = false
local activeAuras = {}
local AuraTracker

local function PopulateActiveAurasTable(index, filter)
	local name, _, iconTexture, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura("player", index, filter)
	local playerSpec = E:GetPlayerSpecFlag()

	if name and C.db.profile.auratracker[filter][spellID] and E:CheckFlag(C.db.profile.auratracker[filter][spellID], playerSpec) then
		table.insert(activeAuras, {
			index = index,
			icon = iconTexture,
			count = count,
			debuffType = debuffType,
			duration = duration,
			expire = expirationTime,
			filter = filter,
		})
	end
end

local function HandleDataCorruption(filter)
	local auraList = C.db.profile.auratracker[filter]

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
	table.wipe(activeAuras)

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
			button:SetID(aura.index)
			button.Icon:SetTexture(aura.icon)
			button.Count:SetText(aura.count > 1 and aura.count)
			button.filter = aura.filter

			CooldownFrame_Set(button.CD, aura.expire - aura.duration, aura.duration, true)

			if button.filter == "HARMFUL" then
				local color = DebuffTypeColor[aura.debuffType] or DebuffTypeColor.none

				button:SetBorderColor(color.r, color.g, color.b)

				button.AuraType:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Weak")

			else
				button:SetBorderColor(1, 1, 1)

				button.AuraType:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Strong")
			end

			button:Show()
		end
	end
end

local function AddToList(filter, spellID)
	if not (C.db.char.auratracker.enabled and filter and spellID) then return end

	local link = _G.GetSpellLink(spellID)

	if not link then
		return false, L["LOG_NOTHING_FOUND"]
	end

	if C.db.profile.auratracker[filter][spellID] then
		return false, string.format(L["LOG_ITEM_ADDED_ERR"], link)
	end

	C.db.profile.auratracker[filter][spellID] = E:GetPlayerSpecFlag()

	AURATRACKER:Refresh()

	return true, string.format(L["LOG_ITEM_ADDED"], link)
end

------------
-- PUBLIC --
------------

function AURATRACKER:ToggleHeader(state)
	AuraTracker.Header:SetShown(state)

	E:ToggleMover(AuraTracker.Header, state)
end

function AURATRACKER:Refresh()
	AT_OnEvent(AuraTracker, "FORCE_UPDATE")
end

function AURATRACKER:UpdateLayout()
	E:UpdateBarLayout(AuraTracker, AuraTracker.buttons, C.db.profile.auratracker.button_size, C.db.profile.auratracker.button_gap, C.db.profile.auratracker.init_anchor, C.db.profile.auratracker.buttons_per_row)
end

-----------------
-- INITIALISER --
-----------------

function AURATRACKER:IsInit()
	return isInit
end

function AURATRACKER:Init()
	if not isInit and C.db.char.auratracker.enabled then
		HandleDataCorruption("HELPFUL")
		HandleDataCorruption("HARMFUL")

		local header = _G.CreateFrame("Frame", "LSAuraTrackerHeader", _G.UIParent)
		header:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		local label = E:CreateFontString(header, 12, nil, true)
		label:SetPoint("LEFT", 2, 0)
		label:SetAlpha(0.4)
		label:SetText(M.COLORS.BLIZZ_YELLOW:WrapText(L["AURA_TRACKER"]))
		header.Text = label

		header:SetSize(label:GetWidth(), 22)
		E:CreateMover(header, true)

		-- FIX-ME: Remove it later
		C.db.profile.auratracker.point = nil
		C.db.profile.auratracker.direction = nil

		AuraTracker = _G.CreateFrame("Frame", nil, _G.UIParent)
		AuraTracker:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
		AuraTracker:SetMovable(true)
		AuraTracker:SetClampedToScreen(true)
		AuraTracker:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
		AuraTracker:SetScript("OnEvent", AT_OnEvent)

		AuraTracker.Header = header
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
				button.CD.Timer:SetJustifyV("BOTTOM")
			end

			button.Count:SetFontObject("LS12Font_Outline")

			local auraType = button.Cover:CreateTexture(nil, "OVERLAY", nil, 3)
			auraType:SetSize(16, 16)
			auraType:SetPoint("TOPLEFT", -2, 2)
			button.AuraType = auraType
		end

		E:UpdateBarLayout(AuraTracker, AuraTracker.buttons, C.db.profile.auratracker.button_size, C.db.profile.auratracker.button_gap, C.db.profile.auratracker.init_anchor, C.db.profile.auratracker.buttons_per_row)

		P:AddCommand("atbuff", function(arg)
			arg = tonumber(arg)

			if arg then
				P.print(select(2, AddToList("HELPFUL", arg)))
			end
		end)

		P:AddCommand("atdebuff", function(arg)
			arg = tonumber(arg)

			if arg then
				P.print(select(2, AddToList("HARMFUL", arg)))
			end
		end)

		-- Finalise
		self:ToggleHeader(not C.db.profile.auratracker.locked)
		self:Refresh()

		isInit = true

		return true
	end
end
