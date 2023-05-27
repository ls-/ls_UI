local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler

-- Lua
local _G = getfenv(0)
local collectgarbage = _G.collectgarbage
local debugprofilestop = _G.debugprofilestop
local hooksecurefunc = _G.hooksecurefunc
local s_gsub = _G.string.gsub
local s_utf8sub = _G.string.utf8sub
local select = _G.select

-- Mine
local LibKeyBound = LibStub("LibKeyBound-1.0")

local function button_GetHotkey(self)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local hotkey = LibKeyBound:ToShortKey(
		(self._command and GetBindingKey(self._command))
		or (self:GetName() and GetBindingKey("CLICK " .. self:GetName() .. ":LeftButton"))
		or ""
	)

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "GetHotkey", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end

	return hotkey
end

local function button_SetKey(self, key)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	SetBinding(key, self._command)

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "SetKey", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function button_GetBindings(self)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

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

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "SetKey", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end

	return keys
end

local function button_ClearBindings(self)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

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

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "ClearBindings", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function addMaskTextureHook(self, texture)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self:RemoveMaskTexture(texture)

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "addMaskTextureHook", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function setNormalAtlasTextureHook(self, texture)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if texture and texture ~= 0 then
		self:SetNormalTexture(0)
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "setNormalAtlasTextureHook", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function updateHotKey(self, text)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	if text ~= RANGE_INDICATOR then
		self:SetFormattedText("%s", self:GetParent():GetHotkey() or "")
	end

	if Profiler:IsLogging() then
		Profiler:Log(self:GetParent():GetDebugName(), "updateHotKey", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function updateMacroText(self, text)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	local button = self:GetParent()

	local name = button.Name
	if name then
		text = text or name:GetText()
		if text then
			name:SetFormattedText("%s", s_utf8sub(text, 1, 4))
		end
	end

	if Profiler:IsLogging() then
		Profiler:Log(button:GetDebugName(), "updateMacroText", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function setIcon(button, texture, l, r, t, b)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

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

	if Profiler:IsLogging() then
		Profiler:Log(button:GetDebugName(), "setIcon", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end

	return icon
end

local function setPushedTexture(button)
	if not button.SetPushedTexture then return end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	button:SetPushedTexture("Interface\\Buttons\\CheckButtonHilight")
	button:GetPushedTexture():SetBlendMode("ADD")
	button:GetPushedTexture():SetAllPoints()

	if Profiler:IsLogging() then
		Profiler:Log(button:GetDebugName(), "setPushedTexture", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function setHighlightTexture(button)
	if not button.SetHighlightTexture then return end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	button:SetHighlightTexture("Interface\\Buttons\\CheckButtonHilight")
	button:GetHighlightTexture():SetBlendMode("ADD")
	button:GetHighlightTexture():SetAllPoints()

	if Profiler:IsLogging() then
		Profiler:Log(button:GetDebugName(), "setHighlightTexture", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function setCheckedTexture(button)
	if not button.SetCheckedTexture then return end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	button:GetCheckedTexture():SetBlendMode("ADD")
	button:GetCheckedTexture():SetAllPoints()

	if Profiler:IsLogging() then
		Profiler:Log(button:GetDebugName(), "setCheckedTexture", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function onSizeChanged(self, width, height)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

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

	if Profiler:IsLogging() then
		Profiler:Log(self:GetDebugName(), "onSizeChanged", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

local function skinButton(button)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

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
			hooksecurefunc(icon, "AddMaskTexture", addMaskTextureHook)
		end
	end

	local slotBackground = button.SlotBackground
	if slotBackground then
		slotBackground:Show()
		slotBackground:SetDrawLayer("BACKGROUND", -7)
		slotBackground:SetAlpha(1)
		slotBackground:SetAllPoints()
		slotBackground:SetColorTexture(0, 0, 0, 0.25)
	end

	local flash = button.Flash
	if flash then
		flash:SetColorTexture(C.db.global.colors.red:GetRGBA(0.65))
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
		hooksecurefunc(button, "SetNormalTexture", setNormalAtlasTextureHook)
		hooksecurefunc(button, "SetNormalAtlas", setNormalAtlasTextureHook)
	end

	-- ExtraActionButton1 has no normal texture
	border = E:CreateBorder(button)
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-thin")
	border:SetSize(16)
	border:SetOffset(-8)
	button.Border_ = border

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

	if Profiler:IsLogging() then
		Profiler:Log(button:GetDebugName(), "skinButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

-- E:SkinActionButton
do
	local function updateBorderColor(self)
		local timeStart, memStart
		if Profiler:IsLogging() then
			timeStart, memStart = debugprofilestop(), collectgarbage("count")
		end

		local button = self:GetParent()

		if button:IsEquipped() then
			button.Border_:SetVertexColor(C.db.global.colors.button.equipped:GetRGB())
		else
			button.Border_:SetVertexColor(1, 1, 1)
		end

		if Profiler:IsLogging() then
			Profiler:Log(button:GetDebugName(), "updateBorderColor", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
		end
	end

	function E:SkinActionButton(button)
		if not button or button.__styled then return end

		local timeStart, memStart
		if Profiler:IsLogging() then
			timeStart, memStart = debugprofilestop(), collectgarbage("count")
		end

		skinButton(button)

		local border = button.Border
		if border then
			hooksecurefunc(border, "Show", updateBorderColor)
			hooksecurefunc(border, "Hide", updateBorderColor)
		end

		button.__styled = true


		if Profiler:IsLogging() then
			Profiler:Log("E", "SkinActionButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
		end
	end
end

function E:SkinFlyoutButton(button)
	if not button or button.__styled then return end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	self:SkinActionButton(button)

	button.HotKey:Hide()

	if Profiler:IsLogging() then
		Profiler:Log("E", "SkinFlyoutButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

-- E:SkinInvSlotButton
do
	local function azeriteSetDrawLayerHook(self, layer)
		local timeStart, memStart
		if Profiler:IsLogging() then
			timeStart, memStart = debugprofilestop(), collectgarbage("count")
		end

		if layer ~= "BACKGROUND" then
			self:SetDrawLayer("BACKGROUND", -1)
		end

		if Profiler:IsLogging() then
			Profiler:Log(self:GetDebugName(), "azeriteSetDrawLayerHook", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
		end
	end

	local function updateBorderColor(self)
		local timeStart, memStart
		if Profiler:IsLogging() then
			timeStart, memStart = debugprofilestop(), collectgarbage("count")
		end

		if self:IsShown() then
			self:GetParent().Border_:SetVertexColor(self:GetVertexColor())
		else
			self:GetParent().Border_:SetVertexColor(0.6, 0.6, 0.6)
		end

		if Profiler:IsLogging() then
			Profiler:Log(self:GetDebugName(), "updateBorderColor", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
		end
	end

	local function setTextureHook(self, texture)
		local timeStart, memStart
		if Profiler:IsLogging() then
			timeStart, memStart = debugprofilestop(), collectgarbage("count")
		end

		if texture then
			self:SetTexture(nil)
		end

		if Profiler:IsLogging() then
			Profiler:Log(self:GetDebugName(), "setTextureHook", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
		end
	end

	function E:SkinInvSlotButton(button)
		if not button or button.__styled then return end

		local timeStart, memStart
		if Profiler:IsLogging() then
			timeStart, memStart = debugprofilestop(), collectgarbage("count")
		end

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

		if Profiler:IsLogging() then
			Profiler:Log("E", "SkinInvSlotButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
		end
	end
end

function E:SkinExtraActionButton(button)
	if not button or button.__styled then return end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	skinButton(button)

	local cooldown = button.cooldown or button.Cooldown
	if cooldown.SetTimerTextHeight then
		cooldown:SetTimerTextHeight(14)
	end

	button.__styled = true

	if Profiler:IsLogging() then
		Profiler:Log("E", "SkinExtraActionButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function E:SkinPetActionButton(button)
	if not button or button.__styled then return end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	skinButton(button)

	local cooldown = button.cooldown
	if cooldown and cooldown.SetTimerTextHeight then
		cooldown:SetTimerTextHeight(10)
	end

	button.__styled = true

	if Profiler:IsLogging() then
		Profiler:Log("E", "SkinPetActionButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function E:SkinStanceButton(button)
	if not button or button.__styled then return end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

	skinButton(button)

	button.__styled = true

	if Profiler:IsLogging() then
		Profiler:Log("E", "SkinStanceButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function E:SkinPetBattleButton(button)
	if not button or button.__styled then return end

	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

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

	if Profiler:IsLogging() then
		Profiler:Log("E", "SkinPetBattleButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end
end

function E:SetIcon(...)
	return setIcon(...)
end

function E:CreateButton(parent, name, hasCount, hasCooldown, isSandwich, isSecure)
	local timeStart, memStart
	if Profiler:IsLogging() then
		timeStart, memStart = debugprofilestop(), collectgarbage("count")
	end

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
		button.Cooldown = E.Cooldowns.Create(button)
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

	if Profiler:IsLogging() then
		Profiler:Log("E", "CreateButton", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	end

	return button
end
