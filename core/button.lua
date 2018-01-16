--[[
ActionButtonTemplate Draw Layers:
BACKGROUND:
- Icon -- 0
BORDER:
-
ARTWORK:
- NormalTexture -- 0
- PushedTexture -- 0
- Flash -- 1
- FlyoutArrow -- 2 -> OVERLAY 2
- HotKey -- 2 -> OVERLAY 2
- Count -- 2 -> OVERLAY 2
OVERLAY:
- Name -- 0
- Border -- 0
- CheckedTexture -- 0
- NewActionTexture -- 1
HIGHLIGHT:
- HighlightTexture -- 0
]]

local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local s_format = _G.string.format
local s_gsub = _G.string.gsub
local s_match = _G.string.match
local s_utf8sub = _G.string.utf8sub

-- Blizz
local ATTACK_BUTTON_FLASH_TIME = _G.ATTACK_BUTTON_FLASH_TIME
local TOOLTIP_UPDATE_TIME = _G.TOOLTIP_UPDATE_TIME
local GetPetActionInfo = _G.GetPetActionInfo
local GetShapeshiftFormInfo = _G.GetShapeshiftFormInfo
local GetZoneAbilitySpellInfo = _G.GetZoneAbilitySpellInfo
local HasAction = _G.HasAction
local IsActionInRange = _G.IsActionInRange
local IsEquippedAction = _G.IsEquippedAction
local IsSpellInRange = _G.IsSpellInRange
local IsUsableAction = _G.IsUsableAction
local IsUsableSpell = _G.IsUsableSpell

-- Mine
local actionButtons = {} -- action bar buttons
local activeButtons = {} -- active action buttons
local handledButtons = {} -- all buttons

-- local function Button_HasAction(self)
-- 	if self:IsShown() then
-- 		if self.__type == "action" or self.__type == "extra" then
-- 			return self.action and HasAction(self.action)
-- 		elseif self.__type == "zone" then
-- 			return GetZoneAbilitySpellInfo() ~= 0
-- 		elseif self.__type == "flyout" then
-- 			return not not self.spellID
-- 		elseif self.__type == "stance" then
-- 			return not not GetShapeshiftFormInfo(self:GetID())
-- 		elseif self.__type == "petaction" then
-- 			return not not GetPetActionInfo(self:GetID())
-- 		end
-- 	else
-- 		return false
-- 	end
-- end

-- local function Button_GetActionInfo(self)
-- 	local isUsable, notEnoughMana, isEquipped, isInRange, _ = false, false, false

-- 	if self.__type == "action" or self.__type == "extra" then
-- 		if self.action then
-- 			isUsable, notEnoughMana = IsUsableAction(self.action)
-- 			isEquipped = IsEquippedAction(self.action)
-- 			isInRange =	IsActionInRange(self.action)
-- 		end
-- 	elseif self.__type == "zone" then
-- 		if self.currentSpellID or self.spellID then
-- 			isUsable, notEnoughMana = IsUsableSpell(self.currentSpellID or self.spellID)
-- 			isInRange = IsSpellInRange(self.currentSpellID or self.spellID)
-- 		end
-- 	elseif self.__type == "flyout" then
-- 		if self.spellID then
-- 			isUsable, notEnoughMana = IsUsableSpell(self.spellID)
-- 		end
-- 	elseif self.__type == "stance" then
-- 		_, _, _, isUsable = GetShapeshiftFormInfo(self:GetID())
-- 	elseif self.__type == "petaction" then
-- 		isUsable = not not GetPetActionInfo(self:GetID())
-- 	end

-- 	return isUsable, notEnoughMana, isEquipped, isInRange == nil and true or isInRange
-- end

-- local function Button_UpdateState(self)
-- 	local icon = self.icon or self.Icon
-- 	local hotKey = self.HotKey
-- 	local isUsable, notEnoughMana, isEquipped, isInRange = self:GetActionInfo()

-- 	if C.db.profile.bars.icon_indicator then
-- 		if not isUsable and not notEnoughMana then
-- 			icon:SetDesaturated(true)
-- 			icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(0.65))
-- 		elseif not isInRange then
-- 			icon:SetDesaturated(true)
-- 			icon:SetVertexColor(M.COLORS.BUTTON_ICON.OOR:GetRGBA(0.65))
-- 		elseif notEnoughMana then
-- 			icon:SetDesaturated(true)
-- 			icon:SetVertexColor(M.COLORS.BUTTON_ICON.OOM:GetRGBA(0.65))
-- 		else
-- 			icon:SetDesaturated(false)
-- 			icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
-- 		end

-- 		if hotKey then
-- 			if not isUsable and not notEnoughMana then
-- 				hotKey:SetVertexColor(M.COLORS.GRAY:GetRGBA(0.65))
-- 			else
-- 				hotKey:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
-- 			end
-- 		end
-- 	else
-- 		if not isUsable and not notEnoughMana then
-- 			icon:SetVertexColor(M.COLORS.GRAY:GetRGBA(0.65))
-- 			icon:SetDesaturated(false)
-- 		else
-- 			icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
-- 			icon:SetDesaturated(false)
-- 		end

-- 		if hotKey then
-- 			if not isUsable and not notEnoughMana then
-- 				hotKey:SetVertexColor(M.COLORS.GRAY:GetRGBA(0.65))
-- 			elseif not isInRange then
-- 				hotKey:SetVertexColor(M.COLORS.BUTTON_ICON.OOR:GetRGBA(1))
-- 			elseif notEnoughMana then
-- 				hotKey:SetVertexColor(M.COLORS.BUTTON_ICON.OOM:GetRGBA(1))
-- 			else
-- 				hotKey:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(1))
-- 			end
-- 		end
-- 	end

-- 	if isEquipped then
-- 		self:SetBorderColor(M.COLORS.GREEN:GetRGB())
-- 	else
-- 		self:SetBorderColor(1, 1, 1)
-- 	end
-- end

local function SetNormalTextureHook(self, texture)
	if texture then
		self:SetNormalTexture(nil)
	end
end

local function SetItemButtonBorderColor(self)
	local button = self:GetParent()

	if self:IsShown() then
		button:SetBorderColor(self:GetVertexColor())
	end
end

local function SetVertexColorHook(self, r, g, b)
	self:GetParent():SetBorderColor(r, g, b)
end

local function SetTextHook(self, text)
	if not text then return end

	self:SetFormattedText("%s", s_gsub(text, "[ .()]", ""))
end

local function SetFormattedTextHook(self, pattern, text)
	if not pattern then return end

	self:SetText(s_format(s_gsub(pattern, "[ .()]", ""), text))
end

local function SetHotKeyTextHook(self)
	local button = self:GetParent()
	local text = button._command and GetBindingKey(button._command) or ""

	if text and text ~= "" then
		text = s_gsub(text, "SHIFT%-", "S")
		text = s_gsub(text, "CTRL%-", "C")
		text = s_gsub(text, "ALT%-", "A")
		text = s_gsub(text, "BUTTON1", "LM")
		text = s_gsub(text, "BUTTON2", "RM")
		text = s_gsub(text, "BUTTON3", "MM")
		text = s_gsub(text, "BUTTON", "M")
		text = s_gsub(text, "MOUSEWHEELDOWN", "WD")
		text = s_gsub(text, "MOUSEWHEELUP", "WU")
		text = s_gsub(text, "NUMPADDECIMAL", "N.")
		text = s_gsub(text, "NUMPADDIVIDE", "N/")
		text = s_gsub(text, "NUMPADMINUS", "N-")
		text = s_gsub(text, "NUMPADMULTIPLY", "N*")
		text = s_gsub(text, "NUMPADPLUS", "N+")
		text = s_gsub(text, "NUMPAD", "N")
		text = s_gsub(text, "PAGEDOWN", "PD")
		text = s_gsub(text, "PAGEUP", "PU")
		text = s_gsub(text, "SPACE", "Sp")
		text = s_gsub(text, "DOWN", "Dn")
		text = s_gsub(text, "LEFT", "Lt")
		text = s_gsub(text, "RIGHT", "Rt")
		text = s_gsub(text, "UP", "Up")
	end

	self:SetFormattedText("%s", text or "")
end

local function SetMacroTextHook(self, text)
	local button = self:GetParent()
	local bName = button.Name

	if bName then
		text = text or bName:GetText()

		if text then
			bName:SetFormattedText("%s", s_utf8sub(text, 1, 4))
		end
	end
end

local function SetIcon(object, texture, l, r, t, b)
	local icon

	if object.CreateTexture then
		icon = object:CreateTexture(nil, "BACKGROUND", nil, 0)
	else
		icon = object
		icon:SetDrawLayer("BACKGROUND", 0)
	end

	if texture then
		icon:SetTexture(texture)
	end

	icon:SetAllPoints()
	icon:SetTexCoord(l or 0.0625, r or 0.9375, t or 0.0625, b or 0.9375)

	return icon
end

local function SetPushedTexture(button)
	if not button.SetPushedTexture then return end

	button:SetPushedTexture("Interface\\Buttons\\ButtonHilight-Square")
	button:GetPushedTexture():SetBlendMode("ADD")
	button:GetPushedTexture():SetDesaturated(true)
	button:GetPushedTexture():SetVertexColor(1.0, 0.82, 0.0)
	button:GetPushedTexture():SetAllPoints()
end

local function SetHighlightTexture(button)
	if not button.SetHighlightTexture then return end

	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	button:GetHighlightTexture():SetAllPoints()
end

local function SetCheckedTexture(button)
	if not button.SetCheckedTexture then return end

	button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	button:GetCheckedTexture():SetBlendMode("ADD")
	button:GetCheckedTexture():SetAllPoints()
end

local function SkinButton(button)
	local bIcon = button.icon or button.Icon
	local bFlash = button.Flash
	local bFOArrow = button.FlyoutArrow
	local bFOBorder = button.FlyoutBorder
	local bFOBorderShadow = button.FlyoutBorderShadow
	local bHotKey = button.HotKey
	local bCount = button.Count
	local bName = button.Name
	local bBorder = button.Border
	local bNewActionTexture = button.NewActionTexture
	local bCD = button.cooldown or button.Cooldown
	local bNormalTexture = button.GetNormalTexture and button:GetNormalTexture()
	local bPushedTexture = button.GetPushedTexture and button:GetPushedTexture()
	local bHighlightTexture = button.GetHighlightTexture and button:GetHighlightTexture()
	local bCheckedTexture = button.GetCheckedTexture and button:GetCheckedTexture()

	SetIcon(bIcon)

	if bFlash then
		bFlash:SetColorTexture(M.COLORS.RED:GetRGBA(0.65))
		bFlash:SetAllPoints()
	end

	if bFOArrow then
		bFOArrow:SetDrawLayer("OVERLAY", 2)
	end

	if bFOBorder then
		E:ForceHide(bFOBorder)
	end

	if bFOBorderShadow then
		E:ForceHide(bFOBorderShadow)
	end

	if bHotKey then
		-- BUG: SetFont prevents SetFontObject from working
		E:ForceHide(bHotKey)

		bHotKey = button:CreateFontString("$parentHotKey", "OVERLAY", "LS10Font_Outline")
		bHotKey:SetJustifyH("RIGHT")
		bHotKey:SetPoint("TOPRIGHT", 2, -2)
		button.HotKey = bHotKey

		SetHotKeyTextHook(bHotKey)
		hooksecurefunc(bHotKey, "SetText", SetHotKeyTextHook)
	end

	if bCount then
		-- BUG: SetFont prevents SetFontObject from working
		E:ForceHide(bCount)

		bCount = button:CreateFontString("$parentCount", "OVERLAY", "LS10Font_Outline")
		bCount:SetJustifyH("RIGHT")
		bCount:SetPoint("BOTTOMRIGHT", 2, 0)
		button.Count = bCount
	end

	if bName then
		bName:SetFontObject("LS10Font_Outline")
		bName:SetJustifyH("CENTER")
		bName:SetDrawLayer("OVERLAY")
		bName:ClearAllPoints()
		bName:SetSize(0, 0)
		bName:SetPoint("BOTTOM", 0, 0)

		SetMacroTextHook(bName)
		hooksecurefunc(bName, "SetText", SetMacroTextHook)
	end

	if bBorder then
		bBorder:SetTexture(nil)
	end

	if bNewActionTexture then
		bNewActionTexture:SetTexture(nil)
	end

	if bCD then
		bCD:ClearAllPoints()
		bCD:SetPoint("TOPLEFT", 1, -1)
		bCD:SetPoint("BOTTOMRIGHT", -1, 1)

		if bCD:IsObjectType("Frame") then
			E:HandleCooldown(bCD, 12)
		end
	end

	if bNormalTexture then
		bNormalTexture:SetTexture(nil)
		hooksecurefunc(button, "SetNormalTexture", SetNormalTextureHook)

		E:CreateBorder(button)
	end

	if bPushedTexture then
		SetPushedTexture(button)
	end

	if bHighlightTexture then
		SetHighlightTexture(button)
	end

	if bCheckedTexture then
		SetCheckedTexture(button)
	end

	handledButtons[button] = true
end

-------------
-- METHODS --
-------------

local function updateBorderColor(self)
	local button = self:GetParent()

	if button:IsEquipped() then
		button:SetBorderColor(M.COLORS.GREEN:GetRGB())
	else
		button:SetBorderColor(1, 1, 1)
	end
end

function E:SkinActionButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	local bBorder = button.Border
	local bFloatingBG = _G[button:GetName().."FloatingBG"]

	if bBorder then
		hooksecurefunc(bBorder, "Show", updateBorderColor)
		hooksecurefunc(bBorder, "Hide", updateBorderColor)
	end

	if bFloatingBG then
		bFloatingBG:SetAlpha(1)
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.25)
	else
		bFloatingBG = button:CreateTexture("$parentFloatingBG", "BACKGROUND", nil, -1)
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.25)
	end

	button.__styled = true

	actionButtons[button] = true
end

function E:SkinFlyoutButton(button)
	if button or not button.__styled then
		self:SkinActionButton(button)
	end
end

function E:SkinAuraButton(button)
	if not button or button.__styled then return end

	local name = button:GetName()
	local bIcon = _G[name.."Icon"]
	local bBorder = _G[name.."Border"]
	local bCount = _G[name.."Count"]
	local bDuration = _G[name.."Duration"]

	if bIcon then
		SetIcon(bIcon)
	end

	self:CreateBorder(button)

	if bBorder then
		bBorder:SetTexture(nil)

		if s_gsub(name, "%d", "") == "TempEnchant" then
			button:SetBorderColor(M.COLORS.PURPLE:GetRGB())
		else
			hooksecurefunc(bBorder, "SetVertexColor", SetVertexColorHook)
		end
	end

	if bCount then
		bCount:SetFontObject("LS10Font_Outline")
		bCount:SetJustifyH("RIGHT")
		bCount:SetDrawLayer("OVERLAY", 2)
		bCount:ClearAllPoints()
		bCount:SetPoint("TOPLEFT", -2, 0)
		bCount:SetPoint("TOPRIGHT", 2, 0)
		bCount:SetWidth(button:GetWidth())
	end

	if bDuration then
		bDuration:SetFontObject("LS10Font_Outline")
		bDuration:SetJustifyH("CENTER")
		bDuration:SetDrawLayer("OVERLAY", 2)
		bDuration:ClearAllPoints()
		bDuration:SetPoint("BOTTOMLEFT", -4, 0)
		bDuration:SetPoint("BOTTOMRIGHT", 4, 0)
		bDuration:SetWidth(button:GetWidth())

		hooksecurefunc(bDuration, "SetFormattedText", SetFormattedTextHook)
	end

	button.__styled = true
end

function E:SkinBagButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	local bCount = button.Count
	local bIconBorder = button.IconBorder

	if bCount then
		SetTextHook(bCount, bCount:GetText())
		hooksecurefunc(bCount, "SetText", SetTextHook)
	end

	if bIconBorder then
		bIconBorder:SetTexture(nil)

		hooksecurefunc(bIconBorder, "Hide", SetItemButtonBorderColor)
		hooksecurefunc(bIconBorder, "Show", SetItemButtonBorderColor)
		hooksecurefunc(bIconBorder, "SetVertexColor", SetItemButtonBorderColor)
	end

	button.__styled = true
	button.__type = "bag"
end

function E:SkinExtraActionButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	E:ForceHide(button.style or button.Style)

	local CD = button.cooldown or button.Cooldown

	if CD.SetTimerTextHeight then
		CD:SetTimerTextHeight(14)
	end

	button.__styled = true

	actionButtons[button] = true
end

function E:SkinZoneAbilityButton(button)
	if not button or button.__styled then return end

	self:SkinExtraActionButton(button)

	button.__type = "zone"
end

function E:SkinPetActionButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	local name = button:GetName()
	local bCD = button.cooldown
	local bAutoCast = _G[name.."AutoCastable"]
	local bShine = _G[name.."Shine"]
	local bHotKey = button.HotKey

	if bCD and bCD.SetTimerTextHeight then
		bCD:SetTimerTextHeight(10)
	end

	if bAutoCast then
		bAutoCast:SetDrawLayer("OVERLAY", 2)
		bAutoCast:ClearAllPoints()
		bAutoCast:SetPoint("TOPLEFT", -12, 12)
		bAutoCast:SetPoint("BOTTOMRIGHT", 12, -12)
	end

	if bShine then
		bShine:ClearAllPoints()
		bShine:SetPoint("TOPLEFT", 1, -1)
		bShine:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	if bHotKey then
		bHotKey:SetFontObject("LS8Font_Outline")

		if not C.db.profile.bars.hotkey then
			bHotKey:Hide()
		end
	end

	button.__styled = true

	actionButtons[button] = true
end

function E:SkinPetBattleButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	local bCDShadow = button.CooldownShadow
	local bCDFlash = button.CooldownFlash
	local bCD = button.Cooldown
	local bSelectedHighlight = button.SelectedHighlight
	local bLock = button.Lock
	local bBetterIcon = button.BetterIcon

	if bCDShadow then
		bCDShadow:SetAllPoints()
	end

	if bCDFlash then
		bCDFlash:SetAllPoints()
	end

	if bCD then
		bCD:SetFontObject("LS16Font_Outline")
		bCD:ClearAllPoints()
		bCD:SetPoint("CENTER", 0, -2)
	end

	if bSelectedHighlight then
		bSelectedHighlight:SetDrawLayer("OVERLAY", 2)
		bSelectedHighlight:ClearAllPoints()
		bSelectedHighlight:SetPoint("TOPLEFT", -8, 8)
		bSelectedHighlight:SetPoint("BOTTOMRIGHT", 8, -8)
	end

	if bLock then
		bLock:ClearAllPoints()
		bLock:SetPoint("TOPLEFT", 2, -2)
		bLock:SetPoint("BOTTOMRIGHT", -2, 2)
	end

	if bBetterIcon then
		bBetterIcon:SetDrawLayer("OVERLAY", 3)
		bBetterIcon:SetSize(18, 18)
		bBetterIcon:ClearAllPoints()
		bBetterIcon:SetPoint("BOTTOMRIGHT", 4, -4)
	end

	button.__styled = true
	button.__type = "petbattle"
	button.HasAction = Button_HasAction
	button.GetActionInfo = Button_GetActionInfo

	actionButtons[button] = true
end

function E:SkinStanceButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	local bFloatingBG = _G[button:GetName().."FloatingBG"]

	if bFloatingBG then
		bFloatingBG:SetAlpha(1)
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.25)
	end

	button.__styled = true

	actionButtons[button] = true
end

function E:SkinSquareButton(button)
	local icon = button.icon
	local texture = icon:GetTexture()
	local highlight = button:GetHighlightTexture()

	icon:SetSize(10, 10)

	highlight:SetTexture(texture)
	highlight:SetTexCoord(icon:GetTexCoord())
	highlight:ClearAllPoints()
	highlight:SetPoint("CENTER", 0, 0)
	highlight:SetSize(10, 10)

	button:SetNormalTexture("")
	button:SetPushedTexture("")
end

function E:SetIcon(...)
	return SetIcon(...)
end
function E:SetPushedTexture(...)
	SetPushedTexture(...)
end
function E:SetHighlightTexture(...)
	SetHighlightTexture(...)
end
function E:SetCheckedTexture(...)
	SetCheckedTexture(...)
end

function E:CreateButton(parent, name, isSandwich, isSecure)
	local button = _G.CreateFrame("Button", name, parent, isSecure and "SecureActionButtonTemplate")
	button:SetSize(28, 28)

	button.Icon = SetIcon(button)

	E:CreateBorder(button)

	local count = E:CreateFontString(button, 10, nil, nil, true)
	count:SetJustifyH("RIGHT")
	count:SetPoint("TOPRIGHT", 2, 0)
	button.Count = count

	button.CD = E:CreateCooldown(button, 12)

	SetPushedTexture(button)
	SetHighlightTexture(button)

	if isSandwich then
		local cover = _G.CreateFrame("Frame", nil, button)
		cover:SetFrameLevel(button:GetFrameLevel() + 2)
		cover:SetAllPoints()
		button.Cover = cover

		count:SetParent(cover)
	end

	return button
end

function E:CreateCheckButton(parent, name, isSandwich, isSecure)
	local button = _G.CreateFrame("CheckButton", name, parent, isSecure and "SecureActionButtonTemplate")
	button:SetSize(28, 28)

	button.Icon = SetIcon(button)

	E:CreateBorder(button)

	local count = E:CreateFontString(button, 10, nil, nil, true)
	count:SetJustifyH("RIGHT")
	count:SetPoint("TOPRIGHT", 2, 0)
	button.Count = count

	button.CD = E:CreateCooldown(button, 12)

	SetPushedTexture(button)
	SetHighlightTexture(button)
	SetCheckedTexture(button)

	if isSandwich then
		local cover = _G.CreateFrame("Frame", nil, button)
		cover:SetFrameLevel(button:GetFrameLevel() + 2)
		cover:SetAllPoints()
		button.Cover = cover

		count:SetParent(cover)
	end

	return button
end

function E:UpdateButtonState(...)
	-- Button_UpdateState(...)
end

function P:GetHandledButtons()
	return handledButtons
end

function P:GetActiveButtons()
	return activeButtons
end

function P:GetActionButtons()
	return actionButtons
end

-------------
-- UPDATES --
-------------

-- do
-- 	local function UpdateActionButtonsTable()
-- 		for button in next, actionButtons do
-- 			if button:HasAction() then
-- 				activeButtons[button] = true
-- 			else
-- 				button:SetBorderColor(1, 1, 1)

-- 				activeButtons[button] = nil
-- 			end
-- 		end
-- 	end

-- 	local function PLAYER_ENTERING_WORLD()
-- 		UpdateActionButtonsTable()

-- 		local flash_timer = 0
-- 		local state_timer = 0

-- 		_G.CreateFrame("Frame"):SetScript("OnUpdate", function (_, elapsed)
-- 			flash_timer = flash_timer - elapsed
-- 			state_timer = state_timer - elapsed

-- 			if flash_timer <= 0 or state_timer <= 0 then
-- 				for button in next, activeButtons do
-- 					if button.Flash and (button.flashing == true or button.flashing == 1) and flash_timer <= 0 then
-- 						if button.Flash:IsShown() then
-- 							button.Flash:Hide()
-- 						else
-- 							button.Flash:Show()
-- 						end
-- 					end

-- 					if state_timer <= 0 then
-- 						Button_UpdateState(button)
-- 					end
-- 				end

-- 				if flash_timer <= 0 then
-- 					flash_timer = ATTACK_BUTTON_FLASH_TIME
-- 				end

-- 				if state_timer <= 0 then
-- 					state_timer = TOOLTIP_UPDATE_TIME
-- 				end
-- 			end
-- 		end)

-- 		E:UnregisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)
-- 	end

-- 	E:RegisterEvent("PLAYER_ENTERING_WORLD", PLAYER_ENTERING_WORLD)
-- 	E:RegisterEvent("ACTIONBAR_SLOT_CHANGED", UpdateActionButtonsTable)
-- 	E:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", UpdateActionButtonsTable)
-- 	E:RegisterEvent("SPELL_UPDATE_ICON", UpdateActionButtonsTable)
-- 	E:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateActionButtonsTable)
-- 	E:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", UpdateActionButtonsTable)
-- end
