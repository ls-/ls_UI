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

	local name = button.Name
	if name then
		text = text or name:GetText()
		if text then
			name:SetFormattedText("%s", s_utf8sub(text, 1, 4))
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

	button:SetPushedTexture("Interface\\Buttons\\CheckButtonHilight")
	button:GetPushedTexture():SetBlendMode("ADD")
	button:GetPushedTexture():SetAllPoints()
end

local function setHighlightTexture(button)
	if not button.SetHighlightTexture then return end

	button:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight")
	button:GetHighlightTexture():SetBlendMode("ADD")
	button:GetHighlightTexture():SetAllPoints()
end

local function setCheckedTexture(button)
	if not button.SetCheckedTexture then return end

	button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	button:GetCheckedTexture():SetBlendMode("ADD")
	button:GetCheckedTexture():SetAllPoints()
end

local function onSizeChanged(self, width, height)
	if self.OnSizeChanged then
		self:OnSizeChanged(width, height)
	else
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
end

local function skinButton(button)
	button:HookScript("OnSizeChanged", onSizeChanged)

	local cooldown = button.cooldown or button.Cooldown
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

		if cooldown:IsObjectType("Frame") then
			E.Cooldowns.Handle(cooldown)
		end
	end

	local textureParent = CreateFrame("Frame", nil, button)
	textureParent:SetFrameLevel((cooldown and cooldown.GetFrameLevel) and cooldown:GetFrameLevel() + 1 or button:GetFrameLevel() + 2)
	textureParent:SetAllPoints()
	button.TextureParent = textureParent

	local icon = button.icon or button.Icon
	if icon then
		setIcon(button.icon or button.Icon)

		local iconMask = button.IconMask
		if iconMask then
			icon:RemoveMaskTexture(iconMask)
		end
	end

	local slotBackground = button.SlotBackground
	if slotBackground then
		slotBackground:SetDrawLayer("BACKGROUND", -7)
		slotBackground:SetAlpha(1)
		slotBackground:SetAllPoints()
		slotBackground:SetColorTexture(0, 0, 0, 0.25)
	end

	local flash = button.Flash
	if flash then
		flash:SetColorTexture(E:GetRGBA(C.db.global.colors.red, 0.65))
		flash:SetAllPoints()
	end

	local hotKey = button.HotKey
	if hotKey then
		E.FontStrings:Capture(hotKey, "button")
		hotKey:ClearAllPoints()
		hotKey:SetDrawLayer("OVERLAY")
		hotKey:SetJustifyH("RIGHT")
		hotKey:SetPoint("TOPRIGHT", 2, 0)
		hotKey:SetSize(0, 0)
		hotKey:SetVertexColor(1, 1, 1, 1)
		hotKey:Show()

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

		updateHotKey(hotKey)
		hooksecurefunc(hotKey, "SetText", updateHotKey)
	end

	local count = button.Count
	if count then
		E.FontStrings:Capture(count, "button")
		count:ClearAllPoints()
		count:SetParent(textureParent)
		count:SetDrawLayer("OVERLAY")
		count:SetJustifyH("RIGHT")
		count:SetPoint("BOTTOMRIGHT", 2, 0)
		count:SetSize(0, 0)
		count:SetVertexColor(1, 1, 1, 1)
	end

	local name = button.Name
	if name then
		E.FontStrings:Capture(name, "button")
		name:ClearAllPoints()
		name:SetDrawLayer("OVERLAY")
		name:SetJustifyH("CENTER")
		name:SetPoint("BOTTOM", 0, 0)
		name:SetSize(0, 0)
		name:SetVertexColor(1, 1, 1, 1)

		updateMacroText(name)
		hooksecurefunc(name, "SetText", updateMacroText)
	end

	local border = button.Border
	if border then
		border:SetTexture(0)
	end

	local newActionTexture = button.NewActionTexture
	if newActionTexture then
		newActionTexture:SetDrawLayer("OVERLAY", 2)
		newActionTexture:ClearAllPoints()
		newActionTexture:SetPoint("TOPLEFT", -5, 5)
		newActionTexture:SetPoint("BOTTOMRIGHT", 5, -5)
	end

	local spellHighlightTexture = button.SpellHighlightTexture
	if spellHighlightTexture then
		spellHighlightTexture:SetDrawLayer("OVERLAY", 2)
		spellHighlightTexture:ClearAllPoints()
		spellHighlightTexture:SetPoint("TOPLEFT", -5, 5)
		spellHighlightTexture:SetPoint("BOTTOMRIGHT", 5, -5)
	end

	local autoCastable = button.AutoCastable
	if autoCastable then
		autoCastable:SetDrawLayer("OVERLAY", 2)
		autoCastable:ClearAllPoints()
		autoCastable:SetPoint("TOPLEFT", -12, 12)
		autoCastable:SetPoint("BOTTOMRIGHT", 12, -12)
	end

	local levelLinkLockIcon = button.LevelLinkLockIcon
	if levelLinkLockIcon then
		levelLinkLockIcon:SetDrawLayer("OVERLAY", 2)
	end

	local autoCastShine = button.AutoCastShine
	if autoCastShine then
		autoCastShine:ClearAllPoints()
		autoCastShine:SetPoint("TOPLEFT", 1, -1)
		autoCastShine:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	local normalTexture = button.GetNormalTexture and button:GetNormalTexture()
	if normalTexture then
		normalTexture:SetTexture(0)
		hooksecurefunc(button, "SetNormalTexture", setNormalTextureHook)

		border = E:CreateBorder(button)
		border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
		border:SetSize(16)
		border:SetOffset(-8)
		button.Border_ = border
	end

	local pushedTexture = button.GetPushedTexture and button:GetPushedTexture()
	if pushedTexture then
		setPushedTexture(button)
	end

	local highlightTexture = button.GetHighlightTexture and button:GetHighlightTexture()
	if highlightTexture then
		setHighlightTexture(button)
	end

	local checkedTexture = button.GetCheckedTexture and button:GetCheckedTexture()
	if checkedTexture then
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

		local border = button.Border
		if border then
			hooksecurefunc(border, "Show", updateBorderColor)
			hooksecurefunc(border, "Hide", updateBorderColor)
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

function E:SkinExtraActionButton(button)
	if not button or button.__styled then return end

	skinButton(button)

	local cooldown = button.cooldown or button.Cooldown
	if cooldown.SetTimerTextHeight then
		cooldown:SetTimerTextHeight(14)
	end

	button.__styled = true
end

function E:SkinPetActionButton(button)
	if not button or button.__styled then return end

	skinButton(button)

	local cooldown = button.cooldown
	if cooldown and cooldown.SetTimerTextHeight then
		cooldown:SetTimerTextHeight(10)
	end

	button.__styled = true
end

function E:SkinStanceButton(button)
	if not button or button.__styled then return end

	skinButton(button)

	button.__styled = true
end

function E:SkinPetBattleButton(button)
	if not button or button.__styled then return end

	skinButton(button)

	local cooldownShadow = button.CooldownShadow
	if cooldownShadow then
		cooldownShadow:SetAllPoints()
	end

	local cooldownFlash = button.CooldownFlash
	if cooldownFlash then
		cooldownFlash:SetAllPoints()
	end

	local cooldown = button.Cooldown
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("CENTER", 0, -2)
	end

	local selectedHighlight = button.SelectedHighlight
	if selectedHighlight then
		selectedHighlight:SetDrawLayer("OVERLAY", 2)
		selectedHighlight:ClearAllPoints()
		selectedHighlight:SetPoint("TOPLEFT", -8, 8)
		selectedHighlight:SetPoint("BOTTOMRIGHT", 8, -8)
	end

	local lock = button.Lock
	if lock then
		lock:ClearAllPoints()
		lock:SetPoint("TOPLEFT", 2, -2)
		lock:SetPoint("BOTTOMRIGHT", -2, 2)
	end

	local betterIcon = button.BetterIcon
	if betterIcon then
		betterIcon:SetDrawLayer("OVERLAY", 3)
		betterIcon:SetSize(18, 18)
		betterIcon:ClearAllPoints()
		betterIcon:SetPoint("BOTTOMRIGHT", 4, -4)
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
		local textureParent = CreateFrame("Frame", nil, button)
		textureParent:SetFrameLevel(button:GetFrameLevel() + 2)
		textureParent:SetAllPoints()
		button.TextureParent = textureParent

		if hasCount then
			button.Count:SetParent(textureParent)
		end
	end

	return button
end
