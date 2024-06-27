local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next
local unpack = _G.unpack

-- Mine
local LibKeyBound = LibStub("LibKeyBound-1.0")

local isInit = false

local BOTTOM_POINT = {"BOTTOM", "UIParent", "BOTTOM", 0, 127}
local TOP_POINT = {"BOTTOM", "UIParent", "BOTTOM", 0, 155}

local LAYOUT = {
	["DEATHKNIGHT"] = BOTTOM_POINT,
	["DEMONHUNTER"] = BOTTOM_POINT,
	["DRUID"] = TOP_POINT,
	["EVOKER"] = BOTTOM_POINT,
	["HUNTER"] = BOTTOM_POINT,
	["MAGE"] = BOTTOM_POINT,
	["MONK"] = TOP_POINT,
	["PALADIN"] = TOP_POINT,
	["PRIEST"] = TOP_POINT,
	["ROGUE"] = BOTTOM_POINT,
	["SHAMAN"] = BOTTOM_POINT,
	["WARLOCK"] = BOTTOM_POINT,
	["WARRIOR"] = TOP_POINT,
}

local function getBarPoint()
	return LAYOUT[E.PLAYER_CLASS]
end

local bar_proto = {}

function bar_proto:Update()
	self:UpdateConfig()
	self:UpdateVisibility()
	self:UpdateButtonConfig()
	self:ForEach("UpdateHotKeyFont")
	self:UpdateCooldownConfig()
	self:UpdateFading()
	E.Layout:Update(self)
end

function bar_proto:UpdateButtonConfig()
	if not self.buttonConfig then
		self.buttonConfig = {
			tooltip = "enabled",
			colors = {
				normal = {},
				unusable = {},
				mana = {},
				range = {},
				equipped = {},
			},
			desaturation = {},
		}
	end

	for k, v in next, C.db.global.colors.button do
		self.buttonConfig.colors[k][1], self.buttonConfig.colors[k][2], self.buttonConfig.colors[k][3] = v:GetRGB()
	end

	self.buttonConfig.clickOnDown = true
	self.buttonConfig.desaturation = E:CopyTable(self._config.desaturation, self.buttonConfig.desaturation)
	self.buttonConfig.outOfRangeColoring = self._config.range_indicator
	self.buttonConfig.showGrid = self._config.grid

	for _, button in next, self._buttons do
		button:UpdateConfig(self.buttonConfig)
	end
end

function bar_proto:OnEvent(event, arg1)
	if event == "PET_BAR_UPDATE" or event == "PET_SPECIALIZATION_CHANGED" or event == "PET_UI_UPDATE"
		or (event == "UNIT_PET" and arg1 == "player")
		or ((event == "UNIT_FLAGS" or event == "UNIT_AURA") and arg1 == "pet")
		or event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED"
		or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" then
		self:ForEach("Update")
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		self:ForEach("UpdateCooldown")
	elseif event == "PET_BAR_SHOWGRID" then
		self:ForEach("ShowGrid")
	elseif event == "PET_BAR_HIDEGRID" then
		self:ForEach("HideGrid")
	end
end

local button_proto = {}

function button_proto:UpdateGrid(state)
	if state ~= nil then
		self._parent._config.grid = state
	end

	self:ShowGrid()
	self:HideGrid()
end

function button_proto:ShowGrid()
	self.showgrid = self.showgrid + 1
	self:SetAlpha(1)
end

function button_proto:HideGrid()
	if self.showgrid > 0 then
		self.showgrid = self.showgrid - 1
	end

	if not self.config.showGrid and self.showgrid == 0 and not GetPetActionInfo(self:GetID()) then
		self:SetAlpha(0)
	end
end

function button_proto:UpdateHotKey(state)
	if state ~= nil then
		self._parent._config.hotkey.enabled = state
	end

	if self._parent._config.hotkey.enabled then
		self.HotKey:SetParent(self)
		self.HotKey:SetFormattedText("%s", self:GetHotkey())
		self.HotKey:Show()
	else
		self.HotKey:SetParent(E.HIDDEN_PARENT)
	end
end

function button_proto:UpdateHotKeyFont()
	self.HotKey:UpdateFont(self._parent._config.hotkey.size)
end

function button_proto:UpdateUsable()
	if self.config.outOfRangeColoring == "button" and self.outOfRange then
		self.icon:SetDesaturated(self.config.desaturation.range == true)
		self.icon:SetVertexColor(unpack(self.config.colors.range))
	else
		if PetHasActionBar() and GetPetActionSlotUsable(self:GetID()) then
			self.icon:SetDesaturated(false)
			self.icon:SetVertexColor(unpack(self.config.colors.normal))
		else
			self.icon:SetDesaturated(self.config.desaturation.unusable == true)
			self.icon:SetVertexColor(unpack(self.config.colors.unusable))
		end
	end
end

function button_proto:UpdateCooldown()
	local start, duration, enable, modRate = GetPetActionCooldown(self:GetID())

	CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate)
end

function button_proto:UpdateConfig(config)
	self.config = E:CopyTable(config, self.config)

	if self.config.outOfRangeColoring == "button" and self.config.outOfManaColoring == "button" then
		self.HotKey:SetVertexColor(unpack(self.config.colors.normal))
	end

	self.checksRange = nil
	self.outOfRange = nil

	self:Update()
end

function button_proto:Update()
	local id = self:GetID()
	local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(id)

	if not isToken then
		self.icon:SetTexture(texture)
		self.tooltipName = name
	else
		self.icon:SetTexture(_G[texture])
		self.tooltipName = _G[name]
	end

	self.isToken = isToken

	if spellID then
		self.tooltipSubtext = GetSpellSubtext(spellID)
	end

	if PetHasActionBar() and isActive then
		if IsPetAttackAction(id) then
			self:StartFlash()
			self:GetCheckedTexture():SetAlpha(0.5)
		else
			self:StopFlash()
			self:GetCheckedTexture():SetAlpha(1.0)
		end

		self:SetChecked(true)
	else
		self:StopFlash()
		self:GetCheckedTexture():SetAlpha(1.0)
		self:SetChecked(false)
	end

	self.AutoCastOverlay:SetShown(autoCastAllowed)
	self.AutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled)

	if texture then
		self:UpdateUsable()

		self.icon:Show()
	else
		self.icon:Hide()
	end

	self:UpdateGrid()
	self:UpdateHotKey()
	self:UpdateCooldown()
end

function button_proto:OnEnterHook()
	if LibKeyBound then
		LibKeyBound:Set(self)
	end
end

function MODULE:CreatePetActionBar()
	if not isInit then
		local bar = Mixin(self:Create("pet", "LSPetBar"), bar_proto)

		for i = 1, 10 do
			local button = Mixin(CreateFrame("CheckButton", "$parentButton" .. i, bar, "PetActionButtonTemplate"), button_proto)
			button:SetID(i)
			button:SetScript("OnEvent", nil)
			button:SetScript("OnUpdate", nil)
			button:HookScript("OnEnter", button.OnEnterHook)
			button:UnregisterAllEvents()
			button._parent = bar
			button._command = "BONUSACTIONBUTTON" .. i
			button.showgrid = 0
			bar._buttons[i] = button

			E:SkinPetActionButton(button)
		end

		bar:SetScript("OnEvent", bar.OnEvent)

		bar:RegisterEvent("PET_BAR_HIDEGRID")
		bar:RegisterEvent("PET_BAR_SHOWGRID")
		bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
		bar:RegisterEvent("PET_BAR_UPDATE")
		bar:RegisterEvent("PET_SPECIALIZATION_CHANGED")
		bar:RegisterEvent("PLAYER_CONTROL_GAINED")
		bar:RegisterEvent("PLAYER_CONTROL_LOST")
		bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
		bar:RegisterEvent("UNIT_AURA")
		bar:RegisterEvent("UNIT_FLAGS")
		bar:RegisterEvent("UNIT_PET")

		bar:SetPoint(unpack(getBarPoint()))
		E.Movers:Create(bar)

		bar:Update()

		local flashTime = 0
		local rangeTimer = -1
		local updater = CreateFrame("Frame", "LSPetActionBarUpdater")
		updater:SetScript("OnUpdate", function(_, elapsed)
			flashTime = flashTime - elapsed
			rangeTimer = rangeTimer - elapsed

			if rangeTimer <= 0 or flashTime <= 0 then
				if PetHasActionBar() then
					for _, button in next, bar._buttons do
						if button.flashing and flashTime <= 0 then
							if button.Flash:IsShown() then
								button.Flash:Hide()
							else
								button.Flash:Show()
							end
						end

						if rangeTimer <= 0 then
							local _, _, _, _, _, _, _, checksRange, inRange = GetPetActionInfo(button:GetID())
							local oldRange = button.outOfRange
							button.outOfRange = (checksRange and inRange == false or false)

							local oldCheck = button.checksRange
							button.checksRange = checksRange

							if oldCheck ~= button.checksRange or oldRange ~= button.outOfRange then
								if button.config.outOfRangeColoring == "button" then
									button:UpdateUsable()
								end

								if button.config.outOfRangeColoring == "hotkey" then
									if checksRange then
										local hotkey = button.HotKey

										if inRange == false then
											if hotkey:GetText() == RANGE_INDICATOR then
												hotkey:Show()
											end
											hotkey:SetVertexColor(unpack(button.config.colors.range))
										else
											if hotkey:GetText() == RANGE_INDICATOR then
												hotkey:Hide()
											end
											hotkey:SetVertexColor(unpack(button.config.colors.normal))
										end
									else
										button.HotKey:SetVertexColor(unpack(button.config.colors.normal))
									end
								end
							end
						end
					end
				end

				if flashTime <= 0 then
					flashTime = flashTime + ATTACK_BUTTON_FLASH_TIME
				end

				if rangeTimer <= 0 then
					rangeTimer = TOOLTIP_UPDATE_TIME
				end
			end
		end)

		isInit = true
	end
end
