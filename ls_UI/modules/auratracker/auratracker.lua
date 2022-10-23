local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:AddModule("AuraTracker")

-- Lua
local _G = getfenv(0)
local next = _G.next
local t_insert = _G.table.insert
local t_wipe = _G.table.wipe
local unpack = _G.unpack

--Mine
local isInit = false
local activeAuras = {}
local bar

local function verifyFilter(filter)
	local auraList = PrC.db.profile.auratracker.filter[filter]
	local toRemove = {}

	for k in next, auraList do
		if not GetSpellInfo(k) then
			toRemove[k] = true
		end
	end

	for k in next, toRemove do
		auraList[k] = nil
	end
end

local function button_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			if self.isHarmful then
				GameTooltip:SetUnitDebuffByAuraInstanceID("player", self.auraInstanceID)
			else
				GameTooltip:SetUnitBuffByAuraInstanceID("player", self.auraInstanceID)
			end
		end

		self.elapsed = 0
	end
end

local function button_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")

	if self.isHarmful then
		GameTooltip:SetUnitDebuffByAuraInstanceID("player", self.auraInstanceID)
	else
		GameTooltip:SetUnitBuffByAuraInstanceID("player", self.auraInstanceID)
	end

	GameTooltip:Show()

	self:SetScript("OnUpdate", button_OnUpdate)
end

local function button_OnLeave(self)
	GameTooltip:Hide()

	self:SetScript("OnUpdate", nil)
end

local bar_proto = {}

function bar_proto:Update()
	t_wipe(activeAuras)

	for spellID in next, self._config.filter.HELPFUL do
		local data = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
		if data then
			t_insert(activeAuras, data)
		end
	end

	for spellID in next, self._config.filter.HARMFUL do
		local data = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
		if data then
			t_insert(activeAuras, data)
		end
	end

	for i = 1, self._config.num do
		local button, aura = self._buttons[i], activeAuras[i]
		if button then
			if aura then
				button.Icon:SetTexture(aura.icon)
				button.Count:SetText(aura.applications > 1 and aura.applications or "")
				button.auraInstanceID = aura.auraInstanceID
				button.isHarmful = aura.isHarmful

				if aura.duration and aura.duration > 0 then
					button.CD:SetCooldown(aura.expirationTime - aura.duration, aura.duration)
				else
					button.CD:Clear()
				end

				if button.isHarmful then
					button.Border:SetVertexColor((C.db.global.colors.debuff[aura.dispelName] or C.db.global.colors.debuff.None):GetRGB())

					if self._config.type.enabled then
						button.AuraType:SetTexCoord(unpack(M.textures.aura_icons[aura.dispelName] or M.textures.aura_icons.Debuff))
					end
				else
					button.Border:SetVertexColor((C.db.global.colors.buff[aura.dispelName] or C.db.global.colors.white):GetRGB())

					if self._config.type.enabled then
						button.AuraType:SetTexCoord(unpack(M.textures.aura_icons.Buff))
					end
				end

				button:Show()
			else
				button.Count:SetText("")
				button.Icon:SetTexture("")
				button:SetScript("OnUpdate", nil)
				button:Hide()
			end
		end
	end
end

function bar_proto:UpdateConfig()
	self._config = E:CopyTable(PrC.db.profile.auratracker, self._config)
	self._config.height = self._config.height ~= 0 and self._config.height or self._config.width
end

function bar_proto:UpdateCooldownConfig()
	if not self.cooldownConfig then
		self.cooldownConfig = {
			swipe = {},
			text = {},
		}
	end

	self.cooldownConfig = E:CopyTable(self._config.cooldown, self.cooldownConfig)

	for _, button in next, self._buttons do
		if not button.CD.UpdateConfig then
			break
		end

		button.CD:UpdateConfig(self.cooldownConfig)
		button.CD:UpdateFont()
		button.CD:UpdateSwipe()
	end
end

function bar_proto:UpdateLock()
	self.Header:SetShown(not self._config.locked)

	if not self._config.locked then
		E.Movers:Get(self.Header, true):Enable()
	else
		local mover = E.Movers:Get(self.Header)
		if mover then
			mover:Disable()
		end
	end
end

function bar_proto:UpdateCountFont()
	local config = self._config.count

	for _, button in next, self._buttons do
		button.Count:UpdateFont(config.size)
	end
end

function bar_proto:UpdateAuraTypeIcons()
	local config = self._config.type
	local auraType

	for _, button in next, self._buttons do
		auraType = button.AuraType
		auraType:ClearAllPoints()
		auraType:SetPoint(config.position, 0, 0)
		auraType:SetSize(config.size, config.size)
		auraType:SetShown(config.enabled)
	end
end

function bar_proto:UpdateLayout()
	E.Layout:Update(self)
end

function MODULE:IsInit()
	return isInit
end

function MODULE:Init()
	if not isInit and PrC.db.profile.auratracker.enabled then
		verifyFilter("HELPFUL")
		verifyFilter("HARMFUL")

		local header = CreateFrame("Frame", "LSAuraTrackerHeader", UIParent)
		header:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)

		local label = header:CreateFontString(nil, "ARTWORK")
		label:SetFontObject("GameFontNormal")
		label:SetWordWrap(false)
		label:SetAlpha(0.4)
		label:SetPoint("LEFT", 2, 0)
		label:SetFormattedText("|cffffd200%s|r", L["AURA_TRACKER"])
		header.Text = label

		header:SetSize(label:GetWidth() + 10, 22)

		local mover = E.Movers:Create(header, true)
		mover.IsDragKeyDown = function()
			return PrC.db.profile.auratracker.drag_key == "NONE"
				or PrC.db.profile.auratracker.drag_key == (IsShiftKeyDown() and "SHIFT" or IsControlKeyDown() and "CTRL" or IsAltKeyDown() and "ALT")
		end

		bar = Mixin(CreateFrame("Frame", "LSAuraTracker", UIParent), bar_proto)
		bar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
		bar:SetMovable(true)
		bar:SetClampedToScreen(true)
		bar:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
		bar:SetScript("OnEvent", bar.Update)

		bar.Header = header

		bar._buttons = {}
		for i = 1, 12 do
			local button = E:CreateButton(bar, "$parentButton" .. i, true, true, true)
			button:SetPushedTexture(0)
			button:SetHighlightTexture(0)
			button:SetScript("OnEnter", button_OnEnter)
			button:SetScript("OnLeave", button_OnLeave)
			button:Hide()
			bar._buttons[i] = button

			local auraType = button.TextureParent:CreateTexture(nil, "OVERLAY", nil, 3)
			auraType:SetTexture("Interface\\AddOns\\ls_UI\\assets\\unit-frame-aura-icons")
			button.AuraType = auraType

			button._parent = bar
		end

		isInit = true

		MODULE:Update()
	end
end

function MODULE:Update()
	if isInit then
		bar:UpdateConfig()
		bar:UpdateCooldownConfig()
		bar:UpdateAuraTypeIcons()
		bar:UpdateCountFont()
		E.Layout:Update(bar)
		bar:UpdateLock()
		bar:Update()
	end
end

function MODULE:GetTracker()
	return bar
end
