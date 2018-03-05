local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

local BUTTONS = {
	PetActionButton1, PetActionButton2, PetActionButton3, PetActionButton4, PetActionButton5,
	PetActionButton6, PetActionButton7, PetActionButton8, PetActionButton9, PetActionButton10,
}

local TOP_POINT = {
	p = "BOTTOM",
	anchor = "UIParent",
	rP = "BOTTOM",
	x = 0,
	y = 152,
}

local BOTTOM_POINT = {
	p = "BOTTOM",
	anchor = "UIParent",
	rP = "BOTTOM",
	x = 0,
	y = 124,
}

local LAYOUT = {
	WARRIOR = TOP_POINT,
	PALADIN = TOP_POINT,
	HUNTER = BOTTOM_POINT,
	ROGUE = BOTTOM_POINT,
	PRIEST = TOP_POINT,
	DEATHKNIGHT = BOTTOM_POINT,
	SHAMAN = BOTTOM_POINT,
	MAGE = BOTTOM_POINT,
	WARLOCK = BOTTOM_POINT,
	MONK = TOP_POINT,
	DRUID = TOP_POINT,
	DEMONHUNTER = BOTTOM_POINT,
}

local function getBarPoint()
	return LAYOUT[E.PLAYER_CLASS]
end

local function button_UpdateGrid(self, state)
	if state ~= nil then
		self._parent._config.grid = state
	end

	self:ShowGrid()
	self:HideGrid()
end

local function button_ShowGrid(self)
	self.showgrid = self.showgrid + 1
	self:SetAlpha(1)
end

local function button_HideGrid(self)
	if self.showgrid > 0 then
		self.showgrid = self.showgrid - 1
	end

	if self.showgrid == 0 and not GetPetActionInfo(self:GetID()) and not self._parent._config.grid then
		self:SetAlpha(0)
	end
end

local function button_UpdateHotKey(self, state)
	if state ~= nil then
		self._parent._config.hotkey.enabled = state
	end

	if self._parent._config.hotkey.enabled then
		self.HotKey:SetParent(self)
		self.HotKey:SetFormattedText("%s", self:GetBindingKey())
		self.HotKey:Show()
	else
		self.HotKey:SetParent(E.HIDDEN_PARENT)
	end
end

local function button_UpdateHotKeyFont(self)
	local config = self._parent._config.hotkey
	self.HotKey:SetFontObject("LSFont"..config.size..(config.flag ~= "" and "_"..config.flag or ""))
	self.HotKey:SetWordWrap(false)
end

local function button_UpdateUsable(self)
	if C.db.profile.bars.range_indicator == "button" and self.outOfRange then
		self.icon:SetDesaturated(true)
		self.icon:SetVertexColor(M.COLORS.BUTTON_ICON.OOR:GetRGBA(0.65))
	elseif C.db.profile.bars.desaturate_on_cd and self.onCooldown then
		self.icon:SetDesaturated(true)
		self.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(0.65))
	else
		local isUsable = PetHasActionBar() and GetPetActionSlotUsable(self:GetID()) or false
		if isUsable then
			self.icon:SetDesaturated(false)
			self.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
		else
			self.icon:SetDesaturated(true)
			self.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(0.65))
		end
	end
end

local function onCooldownDone(self)
	self:SetScript("OnCooldownDone", nil)
	self:GetParent():UpdateCooldown()
end

local function button_UpdateCooldown(self)
	local start, duration, enable, modRate = GetPetActionCooldown(self:GetID())

	self.cooldown:SetDrawBling(C.db.profile.bars.draw_bling and self.cooldown:GetEffectiveAlpha() > 0.5)
	CooldownFrame_Set(self.cooldown, start, duration, enable, false, modRate)

	local oldOnCooldown = self.onCooldown
	self.onCooldown = enable and enable ~= 0 and start > 0 and duration > 1.5
	if C.db.profile.bars.desaturate_on_cd and self.onCooldown ~= oldOnCooldown then
		self:UpdateUsable()
		if self.onCooldown then
			self.cooldown:SetScript("OnCooldownDone", onCooldownDone)
		end
	end
end

local function button_Reset(self)
	self.HotKey:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGB())
	self.icon:SetDesaturated(false)
	self.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))

	self.checksRange = nil
	self.onCooldown = nil
	self.outOfRange = nil

	self:Update()
end

local function button_Update(self)
	local id = self:GetID()
	local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(id)

	if not isToken then
		self.icon:SetTexture(texture)
		self.tooltipName = name
	else
		self.icon:SetTexture(_G[texture])
		self.tooltipName = _G[name]
	end

	self.isToken = isToken
	self.tooltipSubtext = subtext

	self:SetChecked(PetHasActionBar() and isActive or false)

	if PetHasActionBar() and isActive then
		if IsPetAttackAction(id) then
			self:StartFlash()
			self:GetCheckedTexture():SetAlpha(0.5)
		else
			self:StopFlash()
			self:GetCheckedTexture():SetAlpha(1.0)
		end
	else
		self:StopFlash()
		self:GetCheckedTexture():SetAlpha(1.0)
	end

	if autoCastAllowed and not autoCastEnabled then
		self.AutoCastBorder:Show()
		AutoCastShine_AutoCastStop(self.AutoCastShine)
	elseif autoCastAllowed then
		self.AutoCastBorder:Hide()
		AutoCastShine_AutoCastStart(self.AutoCastShine)
	else
		self.AutoCastBorder:Hide()
		AutoCastShine_AutoCastStop(self.AutoCastShine)
	end

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

function MODULE.CreatePetActionBar()
	if not isInit then
		local bar = CreateFrame("Frame", "LSPetBar", UIParent, "SecureHandlerStateTemplate")
		bar._id = "bar6"
		bar._buttons = {}

		MODULE:AddBar(bar._id, bar)

		bar.Update = function(self)
			self:UpdateConfig()
			self:UpdateVisibility()
			self:UpdateButtons("Reset")
			self:UpdateButtons("UpdateHotKeyFont")
			self:UpdateFading()
			E:UpdateBarLayout(self)
		end

		for i = 1, #BUTTONS do
			local button = CreateFrame("CheckButton", "$parentButton"..i, bar, "PetActionButtonTemplate")
			button:SetID(i)
			button:SetScript("OnEvent", nil)
			button:SetScript("OnUpdate", nil)
			button:UnregisterAllEvents()
			button._parent = bar
			button._command = "BONUSACTIONBUTTON"..i
			button.showgrid = 0

			button.HideGrid = button_HideGrid
			button.Reset = button_Reset
			button.ShowGrid = button_ShowGrid
			button.StartFlash = PetActionButton_StartFlash
			button.StopFlash = PetActionButton_StopFlash
			button.Update = button_Update
			button.UpdateCooldown = button_UpdateCooldown
			button.UpdateGrid = button_UpdateGrid
			button.UpdateHotKey = button_UpdateHotKey
			button.UpdateHotKeyFont = button_UpdateHotKeyFont
			button.UpdateUsable = button_UpdateUsable

			BUTTONS[i]:SetAllPoints(button)
			BUTTONS[i]:SetAttribute("statehidden", true)
			BUTTONS[i]:SetParent(E.HIDDEN_PARENT)
			BUTTONS[i]:SetScript("OnEvent", nil)
			BUTTONS[i]:SetScript("OnUpdate", nil)
			BUTTONS[i]:UnregisterAllEvents()

			E:SkinPetActionButton(button)

			bar._buttons[i] = button
		end

		bar:SetScript("OnEvent", function(self, event, arg1)
			if event == "PET_BAR_UPDATE" or event == "PET_SPECIALIZATION_CHANGED" or
				(event == "UNIT_PET" and arg1 == "player") or
				((event == "UNIT_FLAGS" or event == "UNIT_AURA") and arg1 == "pet") or
				event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" then
				self:UpdateButtons("Update")
			elseif event == "PET_BAR_UPDATE_COOLDOWN" then
				self:UpdateButtons("UpdateCooldown")
			elseif event == "PET_BAR_SHOWGRID" then
				self:UpdateButtons("ShowGrid")
			elseif event == "PET_BAR_HIDEGRID" then
				self:UpdateButtons("HideGrid")
			end
		end)

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

		local point = getBarPoint()
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		bar:Update()

		local flashTime = 0
		local rangeTimer = -1
		local updater = CreateFrame("Frame")
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
							local _, _, _, _, _, _, _, _, checksRange, inRange = GetPetActionInfo(button:GetID())
							local oldRange = button.outOfRange
							button.outOfRange = (checksRange and inRange == false or false)

							local oldCheck = button.checksRange
							button.checksRange = checksRange

							if oldCheck ~= button.checksRange or oldRange ~= button.outOfRange then
								if C.db.profile.bars.range_indicator == "button" then
									button:UpdateUsable()
								end

								if C.db.profile.bars.range_indicator == "hotkey" then
									if checksRange then
										local hotkey = button.HotKey

										if inRange == false then
											if hotkey:GetText() == RANGE_INDICATOR then
												hotkey:Show()
											end
											hotkey:SetVertexColor(M.COLORS.BUTTON_ICON.OOR:GetRGBA(1))
										else
											if hotkey:GetText() == RANGE_INDICATOR then
												hotkey:Hide()
											end
											hotkey:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGB())
										end
									else
										button.HotKey:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGB())
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
