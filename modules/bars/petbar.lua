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

local function GetBarPoint()
	return LAYOUT[E.PLAYER_CLASS]
end

function MODULE.CreatePetActionBar()
	if not isInit then
		local bar = CreateFrame("Frame", "LSPetBar", UIParent, "SecureHandlerStateTemplate")
		bar._id = "bar6"
		bar._buttons = {}

		for i = 1, #BUTTONS do
			local button = CreateFrame("CheckButton", "$parentButton"..i, bar, "PetActionButtonTemplate")
			button:SetID(i)
			button:SetScript("OnEvent", nil)
			button:SetScript("OnUpdate", nil)
			button:UnregisterAllEvents()
			button._parent = bar
			button._command = "BONUSACTIONBUTTON"..i
			button._forcegrid = false
			button.StartFlash = PetActionButton_StartFlash
			button.StopFlash = PetActionButton_StopFlash

			BUTTONS[i]:SetAllPoints(button)
			BUTTONS[i]:SetAttribute("statehidden", true)
			BUTTONS[i]:SetParent(E.HIDDEN_PARENT)
			BUTTONS[i]:SetScript("OnEvent", nil)
			BUTTONS[i]:SetScript("OnUpdate", nil)
			BUTTONS[i]:UnregisterAllEvents()

			E:SkinPetActionButton(button)

			bar._buttons[i] = button
		end

		function bar:ForceGrid(state)
			for _, button in next, self._buttons do
				button._forcegrid = state

				if state then
					button:SetAlpha(1)
				elseif not state and not GetPetActionInfo(button:GetID()) then
					button:SetAlpha(0)
				end
			end
		end

		bar:SetScript("OnEvent", function(self, event, arg1)
			if event == "PET_BAR_UPDATE" or event == "PET_SPECIALIZATION_CHANGED" or
				(event == "UNIT_PET" and arg1 == "player") or
				((event == "UNIT_FLAGS" or event == "UNIT_AURA") and arg1 == "pet") or
				event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED" then
				for i, button in next, self._buttons do
					local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)

					if not isToken then
						button.icon:SetTexture(texture)
						button.tooltipName = name;
					else
						button.icon:SetTexture(_G[texture])
						button.tooltipName = _G[name]
					end

					button.isToken = isToken
					button.tooltipSubtext = subtext

					button:SetChecked(isActive)

					if isActive then
						if IsPetAttackAction(i) then
							button:StartFlash()
							button:GetCheckedTexture():SetAlpha(0.5)
						else
							button:StopFlash()
							button:GetCheckedTexture():SetAlpha(1.0)
						end
					else
						button:StopFlash()
						button:GetCheckedTexture():SetAlpha(1.0)
					end

					if autoCastAllowed and not autoCastEnabled then
						button.AutoCastBorder:Show()
						AutoCastShine_AutoCastStop(button.AutoCastShine)
					elseif autoCastAllowed then
						button.AutoCastBorder:Hide()
						AutoCastShine_AutoCastStart(button.AutoCastShine)
					else
						button.AutoCastBorder:Hide()
						AutoCastShine_AutoCastStop(button.AutoCastShine)
					end

					if texture then
						if GetPetActionSlotUsable(i) then
							button.icon:SetDesaturated(false)
						else
							button.icon:SetDesaturated(true)
						end

						button.icon:Show()
						button:SetAlpha(1)
					else
						button.icon:Hide()

						if button._forcegrid then
							button:SetAlpha(1)
						else
							button:SetAlpha(0)
						end
					end

					if not PetHasActionBar() then
						button:SetChecked(false)
						button:StopFlash()
						button.icon:SetDesaturated(true)
					end

					button:UpdateHotKey(C.db.profile.bars.bar6.hotkey)
					CooldownFrame_Set(button.cooldown, GetPetActionCooldown(i))
				end
			elseif event == "PET_BAR_UPDATE_COOLDOWN" then
				for i, button in next, self._buttons do
					CooldownFrame_Set(button.cooldown, GetPetActionCooldown(i))
				end
			elseif event == "PET_BAR_SHOWGRID" then
				self:ForceGrid(true)
			elseif event == "PET_BAR_HIDEGRID" then
				self:ForceGrid(false)
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

		MODULE:AddBar("bar6", bar)

		local point = GetBarPoint()
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E:CreateMover(bar)

		bar._config = C.db.profile.bars.bar6

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
							if checksRange ~= button._checksrange or inRange ~= button._inrange then
								if checksRange then
									if C.db.profile.bars.icon_indicator then
										button.HotKey:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))

										if inRange == false then
											button.icon:SetDesaturated(true)
											button.icon:SetVertexColor(M.COLORS.BUTTON_ICON.OOR:GetRGBA(0.65))
										else
											button.icon:SetDesaturated(false)
											button.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
										end
									else
										button.icon:SetDesaturated(false)
										button.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))

										if inRange == false then
											button.HotKey:SetVertexColor(M.COLORS.BUTTON_ICON.OOR:GetRGBA(1))
										else
											button.HotKey:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
										end
									end
								else
									button.HotKey:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
									button.icon:SetDesaturated(false)
									button.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
								end

								button._checksrange = checksRange
								button._inrange = inRange
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
