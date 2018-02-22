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
local CreateFrame = _G.CreateFrame
local GetSpellInfo = _G.GetSpellInfo
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local UnitAura = _G.UnitAura

local DEBUFF_TYPE_COLORS = _G.DebuffTypeColor

--Mine
local isInit = false
local activeAuras = {}
local bar

local function VerifyList(filter)
	local auraList = C.db.char.auratracker.filter[filter]

	for k in next, auraList do
		if not GetSpellInfo(k) then
			auraList[k] = nil
		end
	end
end

local function GetActiveAuras(index, filter)
	local name, _, texture, count, dType, duration, expirationTime, _, _, _, spellID = UnitAura("player", index, filter)

	if name	and C.db.char.auratracker.filter[filter][spellID] then
		t_insert(activeAuras, {
			index = index,
			icon = texture,
			count = count,
			debuffType = dType,
			duration = duration,
			expire = expirationTime,
			filter = filter,
		})
	end

	return not not name
end

local function Button_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
		end

		self.elapsed = 0
	end
end

local function Button_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura("player", self:GetID(), self.filter)
	GameTooltip:Show()

	self:SetScript("OnUpdate", Button_OnUpdate)
end

local function Button_OnLeave(self)
	GameTooltip:Hide()

	self:SetScript("OnUpdate", nil)
end

local function Update(self)
	t_wipe(activeAuras)

	for i = 1, BUFF_MAX_DISPLAY do
		if not GetActiveAuras(i, "HELPFUL") then
			break
		end
	end

	for i = 1, DEBUFF_MAX_DISPLAY do
		if not GetActiveAuras(i, "HARMFUL") then
			break
		end
	end

	for i = 1, C.db.char.auratracker.num do
		local button, aura = self._buttons[i], activeAuras[i]

		if button then
			if aura then
				button:SetID(aura.index)
				button.Icon:SetTexture(aura.icon)
				button.Count:SetText(aura.count > 1 and aura.count)
				button.filter = aura.filter

				CooldownFrame_Set(button.CD, aura.expire - aura.duration, aura.duration, true)

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

function MODULE.IsInit()
	return isInit
end

function MODULE.Init()
	if not isInit and C.db.char.auratracker.enabled then
		VerifyList("HELPFUL")
		VerifyList("HARMFUL")

		local header = CreateFrame("Frame", "LSAuraTrackerHeader", UIParent)
		header:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		local label = E:CreateFontString(header, 12, nil, true)
		label:SetPoint("LEFT", 2, 0)
		label:SetAlpha(0.4)
		label:SetText(M.COLORS.BLIZZ_YELLOW:WrapText(L["AURA_TRACKER"]))
		header.Text = label

		header:SetSize(label:GetWidth() + 10, 22)
		E:CreateMover(header, true, function()
			return C.db.char.auratracker.drag_key == "NONE"
				or C.db.char.auratracker.drag_key == (IsShiftKeyDown() and "SHIFT" or IsControlKeyDown() and "CTRL" or IsAltKeyDown() and "ALT")
		end)

		bar = CreateFrame("Frame", nil, UIParent)
		bar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
		bar:SetMovable(true)
		bar:SetClampedToScreen(true)
		bar:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
		bar:SetScript("OnEvent", Update)
		bar.Update = function(self)
			Update(self)
		end
		bar.Header = header
		bar._buttons = {}

		for i = 1, 12 do
			local button = E:CreateButton(bar, nil, true)
			button:SetPushedTexture("")
			button:SetHighlightTexture("")
			button:SetScript("OnEnter", Button_OnEnter)
			button:SetScript("OnLeave", Button_OnLeave)
			button:Hide()
			bar._buttons[i] = button

			if button.CD.SetTimerTextHeight then
				button.CD.Timer:SetJustifyV("BOTTOM")
			end

			button.Count:SetFontObject("LSFont12_Outline")

			local auraType = button.Cover:CreateTexture(nil, "OVERLAY", nil, 3)
			auraType:SetSize(16, 16)
			auraType:SetPoint("TOPLEFT", -2, 2)
			button.AuraType = auraType

			button._parent = bar
		end

		isInit = true

		MODULE:Update()
	end
end

function MODULE.Update()
	if isInit then
		bar._config = C.db.char.auratracker

		E:UpdateBarLayout(bar)

		bar:Update()

		local locked = C.db.char.auratracker.locked

		bar.Header:SetShown(not locked)

		if not locked then
			E:EnableMover(bar.Header)
		else
			E:DisableMover(bar.Header)
		end
	end
end
