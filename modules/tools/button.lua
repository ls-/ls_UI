--[[
ActionButtonTemplate Draw Layers:
BACKGROUND:
- Icon -- 0
BORDER:

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
local E, C, M, L = ns.E, ns.C, ns.M, ns.L

-- Lua
local _G = _G
local unpack, next = unpack, next
local strgsub, strmatch, strformat = string.gsub, string.match, string.format

-- Blizz
local IsActionInRange = IsActionInRange
local IsQuestLogSpecialItemInRange = IsQuestLogSpecialItemInRange
local IsUsableAction = IsUsableAction
local ATTACK_BUTTON_FLASH_TIME = ATTACK_BUTTON_FLASH_TIME
local ALT_KEY_TEXT = ALT_KEY_TEXT.."%-"
local CTRL_KEY_TEXT = CTRL_KEY_TEXT.."%-"
local SHIFT_KEY_TEXT = SHIFT_KEY_TEXT.."%-"
local KEY_BUTTON1 = KEY_BUTTON1
local KEY_BUTTON2 = KEY_BUTTON2
local KEY_BUTTON3 = KEY_BUTTON3
local KEY_MOUSEWHEELDOWN = KEY_MOUSEWHEELDOWN
local KEY_MOUSEWHEELUP = KEY_MOUSEWHEELUP

-- Mine
local buttons = {}
local actionButtons = {}

local function Button_HasAction(self)
	if self.__type == "action" or self.__type == "extra" then
		return self.action and _G.HasAction(self.action)
	elseif self.__type == "petaction" then
		local name = _G.GetPetActionInfo(self:GetID())

		return name
	elseif self.__type == "objective" then
		return self:IsShown()
	end
end

local function GetContainerSlotByItemLink(itemLink)
	for i = 0, _G.NUM_BAG_SLOTS do
		for j = 1, _G.GetContainerNumSlots(i) do
			local _, _, _, _, _, _, link = _G.GetContainerItemInfo(i, j)
			if link == itemLink then
				return i, j
			end
		end
	end

	return
end

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
	local button = self:GetParent()
	local action = button.action
	local name = strgsub(button:GetName(), "%d", "")

	if action and _G.IsEquippedAction(action) then
		button:SetBorderColor(unpack(M.colors.green))

		return
	end

	if r == 1 and g == 1 and b == 1 then
		if name == "ActionButton" then
			button:SetBorderColor(unpack(M.colors.yellow))
		else
			button:SetBorderColor(r, g, b)
		end
	else
		button:SetBorderColor(r, g, b)
	end
end

local function SetTextHook(self, text)
	if not text then return end

	self:SetFormattedText("%s", strgsub(text, "[ .()]", ""))
end

local function SetFormattedTextHook(self, arg1, arg2)
	self:SetText(strformat(strgsub(arg1, "[ .()]", ""), arg2))
end

local function SetHotKeyTextHook(self)
	local button = self:GetParent()
	local name = button:GetName()
	local bType = button.buttonType

	if not bType then
		if name and not strmatch(name, "Stance") then
			if strmatch(name, "PetAction") then
				bType = "BONUSACTIONBUTTON"
			else
				bType = "ACTIONBUTTON"
			end
		end
	end

	local text = bType and _G.GetBindingText(_G.GetBindingKey(bType..button:GetID()))

	if text then
		text = strgsub(text, SHIFT_KEY_TEXT, "S")
		text = strgsub(text, CTRL_KEY_TEXT, "C")
		text = strgsub(text, ALT_KEY_TEXT, "A")
		text = strgsub(text, KEY_BUTTON1, "LMB")
		text = strgsub(text, KEY_BUTTON2, "RMB")
		text = strgsub(text, KEY_BUTTON3, "MMB")
		text = strgsub(text, KEY_MOUSEWHEELDOWN, "MWD")
		text = strgsub(text, KEY_MOUSEWHEELUP, "MWU")
	end

	self:SetFormattedText("%s", text or "")
end

local function SetHotKeyVertexColorHook(self, r, g, b)
	if r ~= 0.85 or g ~= 0.85 or b ~= 0.85 then
		self:SetVertexColor(0.85, 0.85, 0.85) -- M.colors.lightgray
	end
end

local function SetMacroTextHook(self)
	local button = self:GetParent()
	local bName = button.Name

	if bName then
		local text = bName:GetText() or ""

		bName:SetFormattedText("%s", E:StringTruncate(text, E:Round(button:GetWidth() / 8)))
	end
end

local function OTButton_OnDragHook(self)
	if _G.IsModifiedClick("PICKUPACTION") then
		local link = _G.GetQuestLogSpecialItemInfo(self:GetID())
		local bagID, slot = GetContainerSlotByItemLink(link)

		if bagID then
			_G.PickupContainerItem(bagID, slot)
		end
	end
end

local function SkinButton(button)
	local name = button:GetName()
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

	E:UpdateIcon(bIcon)

	if bFlash then
		bFlash:SetColorTexture(0.9, 0.15, 0.15, 0.65)
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
		bHotKey:SetFontObject("LS10Font_Outline")
		bHotKey:SetJustifyH("RIGHT")
		bHotKey:SetDrawLayer("OVERLAY")
		bHotKey:ClearAllPoints()
		bHotKey:SetPoint("TOPLEFT", -2, 0)
		bHotKey:SetPoint("TOPRIGHT", 2, 0)
		bHotKey:SetWidth(button:GetWidth())

		SetHotKeyTextHook(bHotKey)
		_G.hooksecurefunc(bHotKey, "SetText", SetHotKeyTextHook)

		bHotKey:SetVertexColor(unpack(M.colors.lightgray))
		_G.hooksecurefunc(bHotKey, "SetVertexColor", SetHotKeyVertexColorHook)

		if not C.bars.show_hotkey then
			bHotKey:Hide()
		end
	end

	if bCount then
		bCount:SetFontObject("LS10Font_Outline")
		bCount:SetJustifyH("RIGHT")
		bCount:SetDrawLayer("OVERLAY")
		bCount:ClearAllPoints()
		bCount:SetPoint("BOTTOMLEFT", -2, 0)
		bCount:SetPoint("BOTTOMRIGHT", 2, 0)
	end

	if bName then
		bName:SetFontObject("LS10Font_Outline")
		bName:SetJustifyH("CENTER")
		bName:SetDrawLayer("OVERLAY")
		bName:ClearAllPoints()
		bName:SetPoint("BOTTOMLEFT", -2, 0)
		bName:SetPoint("BOTTOMRIGHT", 2, 0)

		SetMacroTextHook(bName)
		_G.hooksecurefunc(bName, "SetText", SetMacroTextHook)

		if not C.bars.show_name then
			bName:Hide()
		end
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

		E:CreateBorder(button)

		_G.hooksecurefunc(bNormalTexture, "SetVertexColor", SetVertexColorHook)
	end

	if bPushedTexture then
		E:UpdatePushedTexture(button)
	end

	if bHighlightTexture then
		E:UpdateHighlightTexture(button)
	end

	if bCheckedTexture then
		E:UpdateCheckedTexture(button)
	end

	button:SetScript("OnUpdate", nil)
	button:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");

	button.HasAction = Button_HasAction

	buttons[button] = true
end

-----------
-- UTILS --
-----------

function E:UpdateIcon(object, texture, l, r, t, b)
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

function E:UpdatePushedTexture(button)
	if not button.SetPushedTexture then return end

	button:SetPushedTexture("Interface\\AddOns\\ls_UI\\media\\button-pushed")
	local texture = button:GetPushedTexture()
	texture:SetAllPoints()
end

function E:UpdateHighlightTexture(button)
	if not button.SetHighlightTexture then return end

	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	button:GetHighlightTexture():SetAllPoints()
end

function E:UpdateCheckedTexture(button)
	if not button.SetCheckedTexture then return end

	button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	local texture = button:GetCheckedTexture()
	texture:SetBlendMode("ADD")
	texture:SetAllPoints()
end

function E:CreateButton(parent, name, isSandwich, isSecure)
	local button = _G.CreateFrame("Button", name, parent, isSecure and "SecureActionButtonTemplate")
	button:SetSize(28, 28)

	button.Icon = E:UpdateIcon(button)

	E:CreateBorder(button)

	local count = E:CreateFontString(button, 10, "$parentCount", nil, true)
	count:SetJustifyH("RIGHT")
	count:SetPoint("TOPRIGHT", 2, 0)
	button.Count = count

	button.CD = E:CreateCooldown(button, 12)

	E:UpdatePushedTexture(button)
	E:UpdateHighlightTexture(button)

	if isSandwich then
		local cover = _G.CreateFrame("Frame", "$parentCover", button)
		cover:SetFrameLevel(button:GetFrameLevel() + 2)
		cover:SetAllPoints()

		count:SetParent(cover)
		-- duration:SetParent(cover)
	end

	return button
end

function E:CreateCheckButton(parent, name, isSandwich, isSecure)
	local button = _G.CreateFrame("CheckButton", name, parent, isSecure and "SecureActionButtonTemplate")
	button:SetSize(28, 28)

	button.Icon = E:UpdateIcon(button)

	E:CreateBorder(button)

	local count = E:CreateFontString(button, 10, "$parentCount", nil, true)
	count:SetJustifyH("RIGHT")
	count:SetPoint("TOPRIGHT", 2, 0)
	button.Count = count

	button.CD = E:CreateCooldown(button, 12)

	E:UpdatePushedTexture(button)
	E:UpdateHighlightTexture(button)
	E:UpdateCheckedTexture(button)

	if isSandwich then
		local cover = _G.CreateFrame("Frame", "$parentCover", button)
		cover:SetFrameLevel(button:GetFrameLevel() + 2)
		cover:SetAllPoints()

		count:SetParent(cover)
		-- duration:SetParent(cover)
	end

	return button
end

function E:SkinBagButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	local bCount = button.Count
	local bIconBorder = button.IconBorder

	if bCount then
		SetTextHook(bCount, bCount:GetText())
		_G.hooksecurefunc(bCount, "SetText", SetTextHook)
	end

	if bIconBorder then
		bIconBorder:SetTexture(nil)

		_G.hooksecurefunc(bIconBorder, "Hide", SetItemButtonBorderColor)
		_G.hooksecurefunc(bIconBorder, "Show", SetItemButtonBorderColor)
	end

	button.__type = "bag"
	button.styled = true
end

function E:SkinPetBattleButton(button)
	if not button or button.styled then return end

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
		bBetterIcon:SetDrawLayer("OVERLAY", 2)
		bBetterIcon:SetSize(18, 18)
		bBetterIcon:ClearAllPoints()
		bBetterIcon:SetPoint("BOTTOMRIGHT", 4, -4)
	end

	button:SetBorderColor(unpack(M.colors.yellow))

	button.__type = "petbattle"
	button.styled = true
end

function E:SkinExtraActionButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	E:ForceHide(button.style or button.Style)

	local CD = button.cooldown or button.Cooldown

	if CD.SetTimerTextHeight then
		CD:SetTimerTextHeight(14)
	end

	button.__type = "extra"
	button.styled = true
end

function E:SkinPetActionButton(button)
	if not button or button.styled then return end

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

		if not C.bars.show_hotkey then
			bHotKey:Hide()
		end
	end

	_G.hooksecurefunc(button, "SetNormalTexture", SetNormalTextureHook)

	button.__type = "petaction"
	button.styled = true
end

function E:SkinActionButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	local bFloatingBG = _G[button:GetName().."FloatingBG"]

	if bFloatingBG then
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.65)
	end

	button.__type = "action"
	button.styled = true
end

function E:SkinStanceButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	local bFloatingBG = _G[button:GetName().."FloatingBG"]

	if bFloatingBG then
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.65)
	end

	button.__type = "stance"
	button.styled = true
end

function E:SkinOTButton()
	if not self or self.styled then return end

	SkinButton(self)

	self:RegisterForDrag("LeftButton")
	self:HookScript("OnDragStart", OTButton_OnDragHook)
	self:HookScript("OnReceiveDrag", OTButton_OnDragHook)

	self.__type = "objective"
	self.styled = true
end

function E:SkinAuraButton(button)
	if not button or button.styled then return end

	local name = button:GetName()
	local bIcon = _G[name.."Icon"]
	local bBorder = _G[name.."Border"]
	local bCount = _G[name.."Count"]
	local bDuration = _G[name.."Duration"]

	if bIcon then
		E:UpdateIcon(bIcon)
	end

	E:CreateBorder(button)

	if bBorder then
		bBorder:SetTexture(nil)

		if strgsub(name, "%d", "") == "TempEnchant" then
			button:SetBorderColor(unpack(M.colors.darkmagenta))
		else
			_G.hooksecurefunc(bBorder, "SetVertexColor", SetVertexColorHook)
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

		_G.hooksecurefunc(bDuration, "SetFormattedText", SetFormattedTextHook)
	end

	button.styled = true
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

function E:SetupBar(bar, buttons, buttonSize, buttonGap, direction, skinFucntion)
	bar.buttons = buttons

	E:UpdateBarLayout(bar, buttonSize, buttonGap, direction)

	for i = 1, #buttons do
		local button = buttons[i]
		button:SetFrameLevel(bar:GetFrameLevel() + 1)

		if skinFucntion then
			skinFucntion(E, button)
		end
	end
end

function E:UpdateBarLayout(bar, size, gap, direction)
	if not bar.buttons then return end

	local previous
	local num = #bar.buttons

	if direction == "RIGHT" or direction == "LEFT" then
		bar:SetSize(size * num + gap * num, size + gap)
	else
		bar:SetSize(size + gap, size * num + gap * num)
	end

	for i = 1, num do
		local button = bar.buttons[i]
		button:ClearAllPoints()
		button:SetSize(size, size)

		if direction == "RIGHT" then
			if i == 1 then
				button:SetPoint("LEFT", bar, "LEFT", gap / 2, 0)
			else
				button:SetPoint("LEFT", previous, "RIGHT", gap, 0)
			end
		elseif direction == "LEFT" then
			if i == 1 then
				button:SetPoint("RIGHT", bar, "RIGHT", -gap / 2, 0)
			else
				button:SetPoint("RIGHT", previous, "LEFT", -gap, 0)
			end
		elseif direction == "DOWN" then
			if i == 1 then
				button:SetPoint("TOP", bar, "TOP", 0, -gap / 2)
			else
				button:SetPoint("TOP", previous, "BOTTOM", 0, -gap)
			end
		elseif direction == "UP" then
			if i == 1 then
				button:SetPoint("BOTTOM", bar, "BOTTOM", 0, gap / 2)
			else
				button:SetPoint("BOTTOM", previous, "TOP", 0, gap)
			end
		end

		previous = button
	end
end

function E:GetButtons()
	return buttons
end

----------------
-- DISPATCHER --
----------------

-- one OnUpdate to rule them all!
local flashTime = 0

local function Dispatcher_OnUpdate(self, elapsed)
	flashTime = flashTime - elapsed

	for button in next, actionButtons do
		if button.Flash and flashTime <= 0 and (button.flashing == true or button.flashing == 1) then
			if button.Flash:IsShown() then
				button.Flash:Hide()
			else
				button.Flash:Show()
			end
		end

		if button.__type == "objective" then
			local valid = IsQuestLogSpecialItemInRange(button:GetID())

			if valid == 0 then
				button.icon:SetVertexColor(unpack(M.colors.icon.oor))
			else
				button.icon:SetVertexColor(1, 1, 1, 1)
			end
		elseif button.__type == "action" or button.__type == "extra" then
			if IsActionInRange(button.action) == false then
				button.icon:SetVertexColor(unpack(M.colors.icon.oor))
			else
				local isUsable, notEnoughMana = IsUsableAction(button.action)

				if isUsable then
					button.icon:SetVertexColor(1, 1, 1, 1)
				elseif notEnoughMana then
					button.icon:SetVertexColor(unpack(M.colors.icon.oom))
				else
					button.icon:SetVertexColor(unpack(M.colors.icon.nu))
				end
			end
		end
	end

	if flashTime <= 0 then
		flashTime = flashTime + ATTACK_BUTTON_FLASH_TIME
	end
end

local function Dispatcher_OnEvent(self, event, ...)
	for button in next, buttons do
		if button:HasAction() then
			actionButtons[button] = true
		else
			actionButtons[button] = nil
		end
	end
end

local dispatcher = _G.CreateFrame("Frame")
dispatcher:SetScript("OnEvent", Dispatcher_OnEvent)
dispatcher:SetScript("OnUpdate", Dispatcher_OnUpdate)
dispatcher:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
dispatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
dispatcher:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
dispatcher:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
