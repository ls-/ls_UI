local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:AddModule("AuraTracker")

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_insert = _G.table.insert
local t_wipe = _G.table.wipe

-- Blizz
local CooldownFrame_Set = _G.CooldownFrame_Set
local GetSpellInfo = _G.GetSpellInfo
local UnitAura = _G.UnitAura

local DEBUFF_TYPE_COLORS = _G.DebuffTypeColor

--[[ luacheck: globals
	CreateFrame GameTooltip IsAltKeyDown IsControlKeyDown IsShiftKeyDown UIParent

	BUFF_MAX_DISPLAY DEBUFF_MAX_DISPLAY
]]

--Mine
local isInit = false
local activeAuras = {}
local bar

local function verifyFilter(filter)
	local auraList = C.db.char.auratracker.filter[filter]

	for k in next, auraList do
		if not GetSpellInfo(k) then
			auraList[k] = nil
		end
	end
end

local function getActiveAuras(index, filter)
	local name, texture, count, dType, duration, expirationTime, _, _, _, spellID = UnitAura("player", index, filter)

	if name and bar._config.filter[filter][spellID] then
		t_insert(activeAuras, {
			index = index,
			icon = texture,
			count = count,
			debuffType = dType,
			duration = duration,
			expiration = expirationTime,
			filter = filter,
		})
	end

	return not not name
end

local function button_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
		end

		self.elapsed = 0
	end
end

local function button_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
	GameTooltip:Show()

	self:SetScript("OnUpdate", button_OnUpdate)
end

local function button_OnLeave(self)
	GameTooltip:Hide()

	self:SetScript("OnUpdate", nil)
end

local function button_UpdateCountFont(self)
	local config = self._parent._config.count
	self.Count:SetFontObject("LSFont" .. config.size .. config.flag)
	self.Count:SetWordWrap(false)
end

local function bar_OnEvent(self)
	t_wipe(activeAuras)

	for i = 1, BUFF_MAX_DISPLAY do
		if not getActiveAuras(i, "HELPFUL") then
			break
		end
	end

	for i = 1, DEBUFF_MAX_DISPLAY do
		if not getActiveAuras(i, "HARMFUL") then
			break
		end
	end

	for i = 1, self._config.num do
		local button, aura = self._buttons[i], activeAuras[i]
		if button then
			if aura then
				button:SetID(aura.index)
				button.Icon:SetTexture(aura.icon)
				button.Count:SetText(aura.count > 1 and aura.count)
				button.filter = aura.filter

				CooldownFrame_Set(button.CD, aura.expiration - aura.duration, aura.duration, true)

				if button.filter == "HARMFUL" then
					local color = DEBUFF_TYPE_COLORS[aura.debuffType] or DEBUFF_TYPE_COLORS.none

					button.Border:SetVertexColor(color.r, color.g, color.b)
					button.AuraType:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Weak")

				else
					button.Border:SetVertexColor(1, 1, 1)
					button.AuraType:SetTexture("Interface\\PETBATTLES\\BattleBar-AbilityBadge-Strong")
				end

				button:Show()
			else
				button.AuraType:SetTexture("")
				button.Count:SetText("")
				button.filter = nil
				button.Icon:SetTexture("")
				button:SetID(0)
				button:SetScript("OnUpdate", nil)
				button:Hide()
			end
		end
	end
end

local function bar_UpdateButtons(self, method, ...)
	for _, button in next, self._buttons do
		if button[method] then
			button[method](button, ...)
		end
	end
end

local function bar_UpdateConfig(self)
	self._config = E:CopyTable(C.db.char.auratracker, self._config)
end

local function bar_UpdateCooldownConfig(self)
	if not self.cooldownConfig then
		self.cooldownConfig = {
			colors = {},
			text = {},
		}
	end

	self.cooldownConfig.exp_threshold = self._config.cooldown.exp_threshold
	self.cooldownConfig.m_ss_threshold = self._config.cooldown.m_ss_threshold

	self.cooldownConfig.colors.enabled = self._config.cooldown.colors.enabled
	self.cooldownConfig.colors.expiration = E:CopyTable(self._config.cooldown.colors.expiration, self.cooldownConfig.colors.expiration)
	self.cooldownConfig.colors.second = E:CopyTable(self._config.cooldown.colors.second, self.cooldownConfig.colors.second)
	self.cooldownConfig.colors.minute = E:CopyTable(self._config.cooldown.colors.minute, self.cooldownConfig.colors.minute)
	self.cooldownConfig.colors.hour = E:CopyTable(self._config.cooldown.colors.hour, self.cooldownConfig.colors.hour)
	self.cooldownConfig.colors.day = E:CopyTable(self._config.cooldown.colors.day, self.cooldownConfig.colors.day)

	self.cooldownConfig.text.enabled = self._config.cooldown.text.enabled
	self.cooldownConfig.text.size = self._config.cooldown.text.size
	self.cooldownConfig.text.flag = self._config.cooldown.text.flag
	self.cooldownConfig.text.h_alignment = self._config.cooldown.text.h_alignment
	self.cooldownConfig.text.v_alignment = self._config.cooldown.text.v_alignment

	for _, button in next, self._buttons do
		if not button.CD.UpdateConfig then
			break
		end

		button.CD:UpdateConfig(self.cooldownConfig)
		button.CD:UpdateFontObject()
	end
end

function MODULE.IsInit()
	return isInit
end

function MODULE.Init()
	if not isInit and C.db.char.auratracker.enabled then
		verifyFilter("HELPFUL")
		verifyFilter("HARMFUL")

		local header = CreateFrame("Frame", "LSAuraTrackerHeader", UIParent)
		header:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		local label = header:CreateFontString(nil, "ARTWORK", "LSFont12_Shadow")
		label:SetAlpha(0.4)
		label:SetPoint("LEFT", 2, 0)
		label:SetWordWrap(false)
		label:SetText(M.COLORS.BLIZZ_YELLOW:WrapText(L["AURA_TRACKER"]))
		header.Text = label

		header:SetSize(label:GetWidth() + 10, 22)

		local mover = E.Movers:Create(header, true)
		mover.IsDragKeyDown = function()
			return C.db.char.auratracker.drag_key == "NONE"
				or C.db.char.auratracker.drag_key == (IsShiftKeyDown() and "SHIFT" or IsControlKeyDown() and "CTRL" or IsAltKeyDown() and "ALT")
		end

		bar = CreateFrame("Frame", "LSAuraTracker", UIParent)
		bar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
		bar:SetMovable(true)
		bar:SetClampedToScreen(true)
		bar:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
		bar:SetScript("OnEvent", bar_OnEvent)

		bar.Update = bar_OnEvent
		bar.UpdateButtons = bar_UpdateButtons
		bar.UpdateConfig = bar_UpdateConfig
		bar.UpdateCooldownConfig = bar_UpdateCooldownConfig

		bar.Header = header
		bar._buttons = {}

		for i = 1, 12 do
			local button = E:CreateButton(bar, nil, true)
			button:SetPushedTexture("")
			button:SetHighlightTexture("")
			button:SetScript("OnEnter", button_OnEnter)
			button:SetScript("OnLeave", button_OnLeave)
			button:Hide()
			bar._buttons[i] = button

			local auraType = button.FGParent:CreateTexture(nil, "OVERLAY", nil, 3)
			auraType:SetSize(16, 16)
			auraType:SetPoint("TOPLEFT", -2, 2)
			button.AuraType = auraType

			button._parent = bar
			button.UpdateCountFont = button_UpdateCountFont
		end

		isInit = true

		MODULE:Update()
	end
end

function MODULE.Update()
	if isInit then
		bar:UpdateConfig()
		bar:UpdateButtons("UpdateCountFont")
		bar:UpdateCooldownConfig()
		E:UpdateBarLayout(bar)
		bar:Update()

		bar.Header:SetShown(not bar._config.locked)

		if not bar._config.locked then
			E.Movers:Get(bar.Header, true):Enable()
		else
			local mover = E.Movers:Get(bar.Header)
			if mover then
				mover:Disable()
			end
		end
	end
end
