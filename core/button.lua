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
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = _G
local string = _G.string
local hooksecurefunc = _G.hooksecurefunc
local next = _G.next
local unpack = _G.unpack

-- Blizz
local IsActionInRange = _G.IsActionInRange
local IsUsableAction = _G.IsUsableAction
local ALT_KEY_TEXT = _G.ALT_KEY_TEXT
local CTRL_KEY_TEXT = _G.CTRL_KEY_TEXT
local KEY_BUTTON1 = _G.KEY_BUTTON1
local KEY_BUTTON2 = _G.KEY_BUTTON2
local KEY_BUTTON3 = _G.KEY_BUTTON3
local KEY_MOUSEWHEELDOWN = _G.KEY_MOUSEWHEELDOWN
local KEY_MOUSEWHEELUP = _G.KEY_MOUSEWHEELUP
local KEY_SPACE = _G.KEY_SPACE
local SHIFT_KEY_TEXT = _G.SHIFT_KEY_TEXT

-- Mine
local actionButtons = {}
local handledButtons = {}

-------------
-- HELPERS --
-------------

local function Button_HasAction(self)
	if self.__type == "action" or self.__type == "extra" then
		return self.action and _G.HasAction(self.action)
	elseif self.__type == "petaction" then
		return _G.GetPetActionInfo(self:GetID())
	end
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
	local name = string.gsub(button:GetName(), "%d", "")

	if action and _G.IsEquippedAction(action) then
		button:SetBorderColor(M.COLORS.GREEN:GetRGB())

		return
	end

	if r == 1 and g == 1 and b == 1 then
		if name == "ActionButton" then
			button:SetBorderColor(M.COLORS.YELLOW:GetRGB())
		else
			button:SetBorderColor(r, g, b)
		end
	else
		button:SetBorderColor(r, g, b)
	end
end

local function SetTextHook(self, text)
	if not text then return end

	self:SetFormattedText("%s", string.gsub(text, "[ .()]", ""))
end

local function SetFormattedTextHook(self, pattern, text)
	if not pattern then return end

	self:SetText(string.format(string.gsub(pattern, "[ .()]", ""), text))
end

local function SetHotKeyTextHook(self)
	local button = self:GetParent()
	local name = button:GetName()
	local bType = button.buttonType

	if not bType then
		if name and not string.match(name, "Stance") then
			if string.match(name, "PetAction") then
				bType = "BONUSACTIONBUTTON"
			else
				bType = "ACTIONBUTTON"
			end
		end
	end

	local text = bType and _G.GetBindingText(_G.GetBindingKey(bType..button:GetID())) or ""

	if text and text ~= "" then
		text = string.gsub(text, SHIFT_KEY_TEXT, "S")
		text = string.gsub(text, CTRL_KEY_TEXT, "C")
		text = string.gsub(text, ALT_KEY_TEXT, "A")
		text = string.gsub(text, KEY_BUTTON1, "LM")
		text = string.gsub(text, KEY_BUTTON2, "RM")
		text = string.gsub(text, KEY_BUTTON3, "MM")
		text = string.gsub(text, KEY_MOUSEWHEELDOWN, "MWD")
		text = string.gsub(text, KEY_MOUSEWHEELUP, "MWU")
		text = string.gsub(text, KEY_SPACE, "SP")
		text = string.gsub(text, "%-", "")
	end

	self:SetFormattedText("%s", text or "")
end

local function SetHotKeyVertexColorHook(self, r, g, b)
	if r ~= 0.79 or g ~= 0.79 or b ~= 0.79 then
		self:SetVertexColor(0.79, 0.79, 0.79) -- M.COLORS.LIGHT_GRAY
	end
end

local function SetMacroTextHook(self, text)
	local button = self:GetParent()
	local bName = button.Name

	if bName then
		text = text or bName:GetText()

		if text then
			bName:SetFormattedText("%s", string.utf8sub(text, 1, 4))
		end
	end
end

local function SetPushedTexture(button)
	if not button.SetPushedTexture then return end

	button:SetPushedTexture("Interface\\AddOns\\ls_UI\\media\\button-pushed")
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

	E:SetIcon(bIcon)

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
		bHotKey:SetFontObject("LS10Font_Outline")
		bHotKey:SetJustifyH("RIGHT")
		bHotKey:SetDrawLayer("OVERLAY")
		bHotKey:ClearAllPoints()
		bHotKey:SetPoint("TOPLEFT", -2, 0)
		bHotKey:SetPoint("TOPRIGHT", 2, 0)
		bHotKey:SetWidth(button:GetWidth())

		SetHotKeyTextHook(bHotKey)
		hooksecurefunc(bHotKey, "SetText", SetHotKeyTextHook)

		bHotKey:SetVertexColor(M.COLORS.LIGHT_GRAY:GetRGB())
		hooksecurefunc(bHotKey, "SetVertexColor", SetHotKeyVertexColorHook)

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
		bName:SetSize(0, 0)
		bName:SetPoint("BOTTOM", 0, 0)

		SetMacroTextHook(bName)
		hooksecurefunc(bName, "SetText", SetMacroTextHook)

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

		hooksecurefunc(bNormalTexture, "SetVertexColor", SetVertexColorHook)
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

	button:SetScript("OnUpdate", nil)
	button:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");

	button.HasAction = Button_HasAction

	handledButtons[button] = true
end

-----------
-- SKINS --
-----------

function E:SkinActionButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	local bFloatingBG = _G[button:GetName().."FloatingBG"]

	if bFloatingBG then
		bFloatingBG:SetAlpha(1)
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.25)
	else
		bFloatingBG = button:CreateTexture("$parentFloatingBG", "BACKGROUND", nil, -1)
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.25)
	end

	button.__type = "action"
	button.__styled = true
end

function E:SkinAuraButton(button)
	if not button or button.__styled then return end

	local name = button:GetName()
	local bIcon = _G[name.."Icon"]
	local bBorder = _G[name.."Border"]
	local bCount = _G[name.."Count"]
	local bDuration = _G[name.."Duration"]

	if bIcon then
		E:SetIcon(bIcon)
	end

	E:CreateBorder(button)

	if bBorder then
		bBorder:SetTexture(nil)

		if string.gsub(name, "%d", "") == "TempEnchant" then
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

	button.__type = "bag"
	button.__styled = true
end

function E:SkinExtraActionButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	E:ForceHide(button.style or button.Style)

	local CD = button.cooldown or button.Cooldown

	if CD.SetTimerTextHeight then
		CD:SetTimerTextHeight(14)
	end

	button.__type = "extra"
	button.__styled = true
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

		if not C.bars.show_hotkey then
			bHotKey:Hide()
		end
	end

	hooksecurefunc(button, "SetNormalTexture", SetNormalTextureHook)

	button.__type = "petaction"
	button.__styled = true
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
		bBetterIcon:SetDrawLayer("OVERLAY", 2)
		bBetterIcon:SetSize(18, 18)
		bBetterIcon:ClearAllPoints()
		bBetterIcon:SetPoint("BOTTOMRIGHT", 4, -4)
	end

	button:SetBorderColor(M.COLORS.YELLOW:GetRGB())

	button.__type = "petbattle"
	button.__styled = true
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

function E:SkinStanceButton(button)
	if not button or button.__styled then return end

	SkinButton(button)

	local bFloatingBG = _G[button:GetName().."FloatingBG"]

	if bFloatingBG then
		bFloatingBG:SetAlpha(1)
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.25)
	end

	button.__type = "stance"
	button.__styled = true
end

-----------
-- UTILS --
-----------

function E:SetIcon(object, texture, l, r, t, b)
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

function E:CreateButton(parent, name, isSandwich, isSecure)
	local button = _G.CreateFrame("Button", name, parent, isSecure and "SecureActionButtonTemplate")
	button:SetSize(28, 28)

	button.Icon = E:SetIcon(button)

	E:CreateBorder(button)

	local count = E:CreateFontString(button, 10, nil, nil, true)
	count:SetJustifyH("RIGHT")
	count:SetPoint("TOPRIGHT", 2, 0)
	button.Count = count

	button.CD = E:CreateCooldown(button, 12)

	SetPushedTexture(button)
	SetHighlightTexture(button)

	if isSandwich then
		local cover = _G.CreateFrame("Frame", "$parentCover", button)
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

	button.Icon = E:SetIcon(button)

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
		local cover = _G.CreateFrame("Frame", "$parentCover", button)
		cover:SetFrameLevel(button:GetFrameLevel() + 2)
		cover:SetAllPoints()

		count:SetParent(cover)
	end

	return button
end

function E:GetButtons()
	return handledButtons
end

-------------
-- UPDATES --
-------------

do
	local function UpdateActionButtonsTable()
		for button in next, handledButtons do
			if button:HasAction() then
				actionButtons[button] = true
			else
				actionButtons[button] = nil
			end
		end
	end

	E:RegisterEvent("ACTIONBAR_SLOT_CHANGED", UpdateActionButtonsTable)
	E:RegisterEvent("PLAYER_LOGIN", UpdateActionButtonsTable)
	E:RegisterEvent("UPDATE_SHAPESHIFT_FORM", UpdateActionButtonsTable)
	E:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", UpdateActionButtonsTable)
end

local function OnUpdate(self, elapsed)
	self.flashTime = (self.flashTime or 0) - elapsed

	for button in next, actionButtons do
		if button.Flash and self.flashTime <= 0 and (button.flashing == true or button.flashing == 1) then
			if button.Flash:IsShown() then
				button.Flash:Hide()
			else
				button.Flash:Show()
			end
		end

		if button.__type == "action" or button.__type == "extra" then
			if IsActionInRange(button.action) == false then
				button.icon:SetDesaturated(true)
				button.icon:SetVertexColor(M.COLORS.BUTTON_ICON.OOR:GetRGBA(0.65))
			else
				local isUsable, notEnoughMana = IsUsableAction(button.action)

				if isUsable then
					button.icon:SetDesaturated(false)
					button.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA())
				elseif notEnoughMana then
					button.icon:SetDesaturated(true)
					button.icon:SetVertexColor(M.COLORS.BUTTON_ICON.OOM:GetRGBA(0.65))
				else
					button.icon:SetDesaturated(true)
					button.icon:SetVertexColor(M.COLORS.BUTTON_ICON.N:GetRGBA(0.65))
				end
			end
		end
	end

	if self.flashTime <= 0 then
		self.flashTime = self.flashTime + 0.4
	end
end

local updater = _G.CreateFrame("Frame")
updater:SetScript("OnUpdate", OnUpdate)
