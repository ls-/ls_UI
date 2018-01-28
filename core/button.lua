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

local function getBindingKey(self)
	local text = self._command and GetBindingKey(self._command) or ""

	if text and text ~= "" then
		text = text:gsub("SHIFT%-", "S")
		text = text:gsub("CTRL%-", "C")
		text = text:gsub("ALT%-", "A")
		text = text:gsub("BUTTON1", "LM")
		text = text:gsub("BUTTON2", "RM")
		text = text:gsub("BUTTON3", "MM")
		text = text:gsub("BUTTON", "M")
		text = text:gsub("MOUSEWHEELDOWN", "WD")
		text = text:gsub("MOUSEWHEELUP", "WU")
		text = text:gsub("NUMPADDECIMAL", "N.")
		text = text:gsub("NUMPADDIVIDE", "N/")
		text = text:gsub("NUMPADMINUS", "N-")
		text = text:gsub("NUMPADMULTIPLY", "N*")
		text = text:gsub("NUMPADPLUS", "N+")
		text = text:gsub("NUMPAD", "N")
		text = text:gsub("PAGEDOWN", "PD")
		text = text:gsub("PAGEUP", "PU")
		text = text:gsub("SPACE", "Sp")
		text = text:gsub("DOWN", "Dn")
		text = text:gsub("LEFT", "Lt")
		text = text:gsub("RIGHT", "Rt")
		text = text:gsub("UP", "Up")
	end

	if not text or text == "" then
		text = RANGE_INDICATOR
	end

	return text
end

local function updateHotKey(self)
	self:SetFormattedText("%s", getBindingKey(self:GetParent()))
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

	if bHotKey then
		bHotKey:SetFontObject("LS10Font_Outline")
		bHotKey:SetJustifyH("RIGHT")
		bHotKey:SetDrawLayer("OVERLAY")
		bHotKey:ClearAllPoints()
		bHotKey:SetWidth(0, 0)
		bHotKey:SetPoint("TOPRIGHT", 2, 0)
		bHotKey:Show()

		updateHotKey(bHotKey)
		hooksecurefunc(bHotKey, "SetText", updateHotKey)
		button.GetBindingKey = getBindingKey
	end

	if bCount then
		bCount:SetFontObject("LS10Font_Outline")
		bCount:SetJustifyH("RIGHT")
		bCount:SetDrawLayer("OVERLAY")
		bCount:ClearAllPoints()
		bCount:SetSize(0, 0)
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
	if not button or (button and button.__styled) then return end

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
	if not button or (button and button.__styled) then return end

	self:SkinActionButton(button)

	button.HotKey:Hide()
end

function E:SkinAuraButton(button)
	if not button or (button and button.__styled) then return end

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
	if not button or (button and button.__styled) then return end

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
end

function E:SkinExtraActionButton(button)
	if not button or (button and button.__styled) then return end

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
	if not button or (button and button.__styled) then return end

	self:SkinExtraActionButton(button)
end

function E:SkinPetActionButton(button)
	if not button or (button and button.__styled) then return end

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
		button.AutoCastBorder = bAutoCast
	end

	if bShine then
		bShine:ClearAllPoints()
		bShine:SetPoint("TOPLEFT", 1, -1)
		bShine:SetPoint("BOTTOMRIGHT", -1, 1)
		button.AutoCastShine = bShine
	end

	if bHotKey then
		bHotKey:SetFontObject("LS8Font_Outline")
	end

	button.__styled = true

	actionButtons[button] = true
end

function E:SkinPetBattleButton(button)
	if not button or (button and button.__styled) then return end

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

	actionButtons[button] = true
end

function E:SkinStanceButton(button)
	if not button or (button and button.__styled) then return end

	SkinButton(button)

	local bFloatingBG = _G[button:GetName().."FloatingBG"]
	local bHotKey = button.HotKey

	if bFloatingBG then
		bFloatingBG:SetAlpha(1)
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.25)
	end

	if bHotKey then
		bHotKey:SetFontObject("LS8Font_Outline")
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
