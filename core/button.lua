local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local s_gsub = _G.string.gsub
local s_utf8sub = _G.string.utf8sub
local select = _G.select

--[[ luacheck: globals
	CreateFrame GetBindingKey GetBindingText LibStub SetBinding

	RANGE_INDICATOR
]]

-- Mine
local LibKeyBound = LibStub("LibKeyBound-1.0")

local function button_GetHotkey(self)
	return LibKeyBound:ToShortKey(
		(self._command and GetBindingKey(self._command))
		or (self:GetName() and GetBindingKey("CLICK " .. self:GetName() .. ":LeftButton"))
		or ""
	)
end

local function button_SetKey(self, key)
	SetBinding(key, self._command)
end

local function button_GetBindings(self)
	local binding = self._command
	local keys = ""

	for i = 1, select("#", GetBindingKey(binding)) do
		if keys ~= "" then
			keys = keys .. ", "
		end

		keys = keys .. GetBindingText(select(i, GetBindingKey(binding)), nil)
	end

	if self:GetName() then
		binding = "CLICK " .. self:GetName() .. ":LeftButton"

		for i = 1, select("#", GetBindingKey(binding)) do
			if keys ~= "" then
				keys = keys .. ", "
			end

			keys = keys .. GetBindingText(select(i, GetBindingKey(binding)), nil)
		end
	end

	return keys
end

local function button_ClearBindings(self)
	local binding = self._command

	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end

	if self:GetName() then
		binding = "CLICK " .. self:GetName() .. ":LeftButton"

		while GetBindingKey(binding) do
			SetBinding(GetBindingKey(binding), nil)
		end
	end
end

local function setNormalTextureHook(self, texture)
	if texture then
		self:SetNormalTexture(nil)
	end
end

local function updateHotKey(self, text)
	if text ~= RANGE_INDICATOR then
		self:SetFormattedText("%s", self:GetParent():GetHotkey() or "")
	end
end

local function updateMacroText(self, text)
	local button = self:GetParent()
	local bName = button.Name

	if bName then
		text = text or bName:GetText()

		if text then
			bName:SetFormattedText("%s", s_utf8sub(text, 1, 4))
		end
	end
end

local function setIcon(button, texture, l, r, t, b)
	local icon

	if button.CreateTexture then
		icon = button:CreateTexture(nil, "BACKGROUND", nil, 0)
	else
		icon = button
		icon:SetDrawLayer("BACKGROUND", 0)
	end

	icon:SetAllPoints()
	icon:SetTexCoord(l or 0.0625, r or 0.9375, t or 0.0625, b or 0.9375)

	if texture then
		icon:SetTexture(texture)
	end

	return icon
end

local function setPushedTexture(button)
	if not button.SetPushedTexture then return end

	button:SetPushedTexture("Interface\\Buttons\\ButtonHilight-Square")
	button:GetPushedTexture():SetBlendMode("ADD")
	button:GetPushedTexture():SetDesaturated(true)
	button:GetPushedTexture():SetVertexColor(E:GetRGB(C.db.global.colors.yellow))
	button:GetPushedTexture():SetAllPoints()
end

local function setHighlightTexture(button)
	if not button.SetHighlightTexture then return end

	button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	button:GetHighlightTexture():SetAllPoints()
end

local function setCheckedTexture(button)
	if not button.SetCheckedTexture then return end

	button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	button:GetCheckedTexture():SetBlendMode("ADD")
	button:GetCheckedTexture():SetAllPoints()
end

local function onSizeChanged(self, width, height)
	local icon = self.icon or self.Icon
	if icon then
		if width > height then
			local offset = 0.875 * (1 - height / width) / 2
			icon:SetTexCoord(0.0625, 0.9375, 0.0625 + offset, 0.9375 - offset)
		elseif width < height then
			local offset = 0.875 * (1 - width / height) / 2
			icon:SetTexCoord(0.0625 + offset, 0.9375 - offset, 0.0625, 0.9375)
		else
			icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
		end
	end
end

local function skinButton(button)
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

	local fgParent = CreateFrame("Frame", nil, button)
	fgParent:SetFrameLevel((bCD and bCD.GetFrameLevel) and bCD:GetFrameLevel() + 1 or button:GetFrameLevel() + 2)
	fgParent:SetAllPoints()
	button.FGParent = fgParent

	button:HookScript("OnSizeChanged", onSizeChanged)

	setIcon(bIcon)

	if bFlash then
		bFlash:SetColorTexture(E:GetRGBA(C.db.global.colors.red, 0.65))
		bFlash:SetAllPoints()
	end

	if bFOArrow then
		bFOArrow:SetDrawLayer("OVERLAY", 2)
	end

	if bHotKey then
		E.FontStrings:Capture(bHotKey, "button")
		bHotKey:ClearAllPoints()
		bHotKey:SetDrawLayer("OVERLAY")
		bHotKey:SetJustifyH("RIGHT")
		bHotKey:SetPoint("TOPRIGHT", 2, 0)
		bHotKey:SetSize(0, 0)
		bHotKey:SetVertexColor(1, 1, 1, 1)
		bHotKey:Show()

		if not button.GetHotkey then
			button.GetHotkey = button_GetHotkey
		end

		if not button.SetKey then
			button.SetKey = button_SetKey
		end

		if not button.GetBindings then
			button.GetBindings = button_GetBindings
		end

		if not button.ClearBindings then
			button.ClearBindings = button_ClearBindings
		end

		updateHotKey(bHotKey)
		hooksecurefunc(bHotKey, "SetText", updateHotKey)
	end

	if bCount then
		E.FontStrings:Capture(bCount, "button")
		bCount:ClearAllPoints()
		bCount:SetParent(fgParent)
		bCount:SetDrawLayer("OVERLAY")
		bCount:SetJustifyH("RIGHT")
		bCount:SetPoint("BOTTOMRIGHT", 2, 0)
		bCount:SetSize(0, 0)
		bCount:SetVertexColor(1, 1, 1, 1)
	end

	if bName then
		E.FontStrings:Capture(bName, "button")
		bName:ClearAllPoints()
		bName:SetDrawLayer("OVERLAY")
		bName:SetJustifyH("CENTER")
		bName:SetPoint("BOTTOM", 0, 0)
		bName:SetSize(0, 0)
		bName:SetVertexColor(1, 1, 1, 1)

		updateMacroText(bName)
		hooksecurefunc(bName, "SetText", updateMacroText)
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
			E.Cooldowns.Handle(bCD)
		end
	end

	if bNormalTexture then
		bNormalTexture:SetTexture(nil)
		hooksecurefunc(button, "SetNormalTexture", setNormalTextureHook)

		local border = E:CreateBorder(button)
		border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
		border:SetSize(16)
		border:SetOffset(-8)
		button.Border_ = border
	end

	if bPushedTexture then
		setPushedTexture(button)
	end

	if bHighlightTexture then
		setHighlightTexture(button)
	end

	if bCheckedTexture then
		setCheckedTexture(button)
	end
end

-- E:SkinActionButton
do
	local function updateBorderColor(self)
		local button = self:GetParent()

		if button:IsEquipped() then
			button.Border_:SetVertexColor(E:GetRGB(C.db.global.colors.green))
		else
			button.Border_:SetVertexColor(1, 1, 1)
		end
	end

	function E:SkinActionButton(button)
		if not button or button.__styled then return end

		skinButton(button)

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
	end
end

function E:SkinFlyoutButton(button)
	if not button or button.__styled then return end

	self:SkinActionButton(button)

	button.HotKey:Hide()
end

-- E:SkinInvSlotButton
do
	local function azeriteSetDrawLayerHook(self, layer)
		if layer ~= "BACKGROUND" then
			self:SetDrawLayer("BACKGROUND", -1)
		end
	end

	local function updateBorderColor(self)
		if self:IsShown() then
			self:GetParent().Border_:SetVertexColor(self:GetVertexColor())
		else
			self:GetParent().Border_:SetVertexColor(0.6, 0.6, 0.6)
		end
	end

	local function setTextureHook(self, texture)
		if texture then
			self:SetTexture(nil)
		end
	end

	function E:SkinInvSlotButton(button)
		if not button or button.__styled then return end

		skinButton(button)

		local azeriteTexture = button.AzeriteTexture
		if azeriteTexture then
			azeriteTexture:SetDrawLayer("BACKGROUND", -1)
			hooksecurefunc(azeriteTexture, "SetDrawLayer", azeriteSetDrawLayerHook)
		end

		local bIconBorder = button.IconBorder
		if bIconBorder then
			bIconBorder:SetTexture(nil)

			hooksecurefunc(bIconBorder, "Hide", updateBorderColor)
			hooksecurefunc(bIconBorder, "Show", updateBorderColor)
			hooksecurefunc(bIconBorder, "SetVertexColor", updateBorderColor)
			hooksecurefunc(bIconBorder, "SetTexture", setTextureHook)
		end

		button.__styled = true
	end
end

-- E:SkinBagButton
do
	local function updateCountText(self, text)
		if not text then return end

		self:SetFormattedText("%s", s_gsub(text, "[ .()]", ""))
	end

	local function updateBorderColor(self)
		local button = self:GetParent()

		if self:IsShown() then
			button.Border_:SetVertexColor(self:GetVertexColor())
		end
	end

	function E:SkinBagButton(button)
		if not button or button.__styled then return end

		skinButton(button)

		local bCount = button.Count
		local bIconBorder = button.IconBorder

		if bCount then
			updateCountText(bCount, bCount:GetText())
			hooksecurefunc(bCount, "SetText", updateCountText)
		end

		if bIconBorder then
			bIconBorder:SetTexture(nil)

			hooksecurefunc(bIconBorder, "Hide", updateBorderColor)
			hooksecurefunc(bIconBorder, "Show", updateBorderColor)
			hooksecurefunc(bIconBorder, "SetVertexColor", updateBorderColor)
		end

		button.__styled = true
	end
end

function E:SkinExtraActionButton(button)
	if not button or button.__styled then return end

	skinButton(button)

	local CD = button.cooldown or button.Cooldown

	if CD.SetTimerTextHeight then
		CD:SetTimerTextHeight(14)
	end

	button.__styled = true
end

function E:SkinPetActionButton(button)
	if not button or button.__styled then return end

	skinButton(button)

	local name = button:GetName()
	local bCD = button.cooldown
	local bAutoCast = _G[name.."AutoCastable"]
	local bShine = _G[name.."Shine"]

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

	button.__styled = true
end

function E:SkinPetBattleButton(button)
	if not button or button.__styled then return end

	skinButton(button)

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
end

function E:SkinStanceButton(button)
	if not button or button.__styled then return end

	skinButton(button)

	local bFloatingBG = _G[button:GetName().."FloatingBG"]

	if bFloatingBG then
		bFloatingBG:SetAlpha(1)
		bFloatingBG:SetAllPoints()
		bFloatingBG:SetColorTexture(0, 0, 0, 0.25)
	end

	button.__styled = true
end

function E:SetIcon(...)
	return setIcon(...)
end

function E:CreateButton(parent, name, hasCount, hasCooldown, isSandwich, isSecure)
	local button = CreateFrame("Button", name, parent, isSecure and "SecureActionButtonTemplate")
	button:SetSize(28, 28)
	button:HookScript("OnSizeChanged", onSizeChanged)

	button.Icon = setIcon(button)

	local border = E:CreateBorder(button)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
	border:SetSize(16)
	border:SetOffset(-8)
	button.Border = border

	setHighlightTexture(button)
	setPushedTexture(button)

	if hasCount then
		local count = button:CreateFontString(nil, "ARTWORK")
		E.FontStrings:Capture(count, "button")
		count:UpdateFont(14)
		count:SetWordWrap(false)
		count:SetJustifyH("RIGHT")
		count:SetPoint("TOPRIGHT", 2, 0)
		button.Count = count
	end

	if hasCooldown then
		button.CD = E.Cooldowns.Create(button)
	end

	if isSandwich then
		local fgParent = CreateFrame("Frame", nil, button)
		fgParent:SetFrameLevel(button:GetFrameLevel() + 2)
		fgParent:SetAllPoints()
		button.FGParent = fgParent

		if hasCount then
			button.Count:SetParent(fgParent)
		end
	end

	return button
end
