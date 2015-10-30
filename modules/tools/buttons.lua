local _, ns = ...
local E, M = ns.E, ns.M
local COLORS, TEXTURES = M.colors, M.textures

local unpack = unpack
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local function GetContainerSlotByItemLink(itemLink)
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			local _, _, _, _, _, _, link = GetContainerItemInfo(i, j)
			if link == itemLink then
				return i, j
			end
		end
	end

	return
end

local function SetFlashTexture(texture)
	texture:SetTexture(TEXTURES.button.flash)
	texture:SetTexCoord(0.234375, 0.765625, 0.234375, 0.765625)
	texture:SetAllPoints()
end

local function SetNilNormalTexture(self, texture)
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

local function SetCustomVertexColor(self, r, g, b)
	local button = self:GetParent()
	local action = button.action
	local name = gsub(button:GetName(), "%d", "")

	if name == "ExtraActionButton" then
		button:SetBorderColor(unpack(COLORS.orange))

		return
	end

	if action and IsEquippedAction(action) then
		button:SetBorderColor(unpack(COLORS.green))

		return
	end

	if r == 1 and g == 1 and b == 1 then
		if name == "ActionButton" then
			button:SetBorderColor(unpack(COLORS.yellow))
		else
			button:SetBorderColor(r, g, b)
		end
	else
		button:SetBorderColor(r, g, b)
	end
end

local function SetCustomText(self, text)
	self:SetFormattedText("%s", gsub(text, "[ .()]", ""))
end

local function SetCustomFormattedText(self, arg1, arg2)
	self:SetText(format(gsub(arg1, "[ .()]", ""), arg2))
end

local function SetCustomHotKeyText(self)
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

	local text = bType and GetBindingText(GetBindingKey(bType..button:GetID()))

	if text then
		text = gsub(text, ALT_KEY_TEXT.."%-", "A")
		text = gsub(text, CTRL_KEY_TEXT.."%-", "C")
		text = gsub(text, SHIFT_KEY_TEXT.."%-", "S")
		text = gsub(text, KEY_BUTTON1, "LMB")
		text = gsub(text, KEY_BUTTON2, "RMB")
		text = gsub(text, KEY_BUTTON3, "MMB")
		text = gsub(text, KEY_MOUSEWHEELDOWN, "MWU")
		text = gsub(text, KEY_MOUSEWHEELUP, "MWD")
	end

	self:SetFormattedText("%s", text or "")
end

local function ActionButton_OnUpdate(button)
	local action = button.action
	local bIcon = button.icon
	local bName = button.Name
	local bHotKey = button.HotKey

	if bIcon then
		if IsActionInRange(action) ~= false then
			local isUsable, notEnoughMana = IsUsableAction(action)
			if isUsable then
				bIcon:SetVertexColor(1, 1, 1, 1)
			elseif notEnoughMana then
				bIcon:SetVertexColor(unpack(COLORS.icon.oom))
			else
				bIcon:SetVertexColor(unpack(COLORS.icon.nu))
			end
		else
			bIcon:SetVertexColor(unpack(COLORS.icon.oor))
		end
	end

	if bName then
		local text = bName:GetText()
		if text then
			bName:SetText(E:StringTruncate(text, 4))
		end
	end

	if bHotKey then
		bHotKey:SetVertexColor(unpack(COLORS.lightgray))
	end
end

local function PetActionButton_OnUpdate(button)
	local bHotKey = button.HotKey

	if bHotKey then
		bHotKey:SetVertexColor(unpack(COLORS.lightgray))
	end
end

local function OTButton_OnUpdate(self, elapsed)
	local bIcon = self.icon

	if bIcon then
		local valid = IsQuestLogSpecialItemInRange(self:GetID())

		if valid == 0 then
			bIcon:SetVertexColor(unpack(COLORS.icon.oor))
		else
			bIcon:SetVertexColor(1, 1, 1, 1)
		end
	end
end

local function SkinButton(button)
	local name = button:GetName()
	local bIcon = button.icon or button.Icon
	local bFlash = button.Flash
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

	E:TweakIcon(bIcon)

	if bFlash then
		SetFlashTexture(bFlash)
	end

	if bFOBorder then
		E:ForceHide(bFOBorder)
	end

	if bFOBorderShadow then
		E:ForceHide(bFOBorderShadow)
	end

	if bHotKey then
		bHotKey:SetFont(M.font, 10, "THINOUTLINE")
		bHotKey:ClearAllPoints()
		bHotKey:SetPoint("TOPRIGHT", 2, 1)

		SetCustomHotKeyText(bHotKey)

		hooksecurefunc(bHotKey, "SetText", SetCustomHotKeyText)
	end

	if bCount then
		bCount:SetFont(M.font, 10, "THINOUTLINE")
		bCount:ClearAllPoints()
		bCount:SetPoint("BOTTOMRIGHT", 2, -1)
	end

	if bName then
		bName:SetFont(M.font, 10, "THINOUTLINE")
		bName:SetJustifyH("CENTER")
		bName:ClearAllPoints()
		bName:SetPoint("BOTTOMLEFT", -4, 0)
		bName:SetPoint("BOTTOMRIGHT", 4, 0)
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

		E:CreateBorder(button, 8)

		hooksecurefunc(bNormalTexture, "SetVertexColor", SetCustomVertexColor)
	end

	if bPushedTexture then
		ns.lsSetPushedTexture(bPushedTexture)
	end

	if bHighlightTexture then
		ns.lsSetHighlightTexture(bHighlightTexture)
	end

	if bCheckedTexture then
		ns.lsSetCheckedTexture(bCheckedTexture)
	end
end

function E:SetButtonPosition(buttons, buttonSize, buttonGap, header, direction, skinFucntion, originalBar)
	if originalBar and originalBar:GetParent() ~= header then
		originalBar:SetParent(header)
		originalBar:SetAllPoints()
		originalBar:EnableMouse(false)
		originalBar.ignoreFramePositionManager = true
	end

	local previous

	for i = 1, #buttons do
		local button = buttons[i]

		button:ClearAllPoints()
		button:SetSize(type(buttonSize) == "table" and buttonSize.w or buttonSize,
			type(buttonSize) == "table" and buttonSize.h or buttonSize)

		if not originalBar then button:SetParent(header) end

		button:SetFrameStrata("LOW")
		button:SetFrameLevel(2)

		if direction == "RIGHT" then
			if i == 1 then
				button:SetPoint("LEFT", header, "LEFT", E:Round(buttonGap / 2), 0)
			else
				button:SetPoint("LEFT", previous, "RIGHT", buttonGap, 0)
			end
		elseif direction == "LEFT" then
			if i == 1 then
				button:SetPoint("RIGHT", header, "RIGHT", E:Round(-buttonGap / 2), 0)
			else
				button:SetPoint("RIGHT", previous, "LEFT", -buttonGap, 0)
			end
		elseif direction == "DOWN" then
			if i == 1 then
				button:SetPoint("TOP", header, "TOP", 0, E:Round(-buttonGap / 2))
			else
				button:SetPoint("TOP", previous, "BOTTOM", 0, -buttonGap)
			end
		elseif direction == "UP" then
			if i == 1 then
				button:SetPoint("BOTTOM", header, "BOTTOM", 0, E:Round(buttonGap / 2))
			else
				button:SetPoint("BOTTOM", previous, "TOP", 0, buttonGap)
			end
		end

		if skinFucntion then skinFucntion(E, button) end

		previous = button
	end
end

function E:SkinBagButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	local bCount = button.Count
	local bIconBorder = button.IconBorder

	if bIconBorder then
		bIconBorder:SetTexture(nil)
		hooksecurefunc(bIconBorder, "Hide", SetItemButtonBorderColor)
		hooksecurefunc(bIconBorder, "Show", SetItemButtonBorderColor)
	end

	if bCount then
		hooksecurefunc(bCount, "SetText", SetCustomText)
	end

	button.styled = true
end

function E:SkinPetBattleButton(button)
	if not button or button.styled then return end

	SkinButton(button, true)

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
		bCD:SetFont(M.font, 16, "THINOUTLINE")
		bCD:ClearAllPoints()
		bCD:SetPoint("CENTER", 0, -2)
	end

	if bSelectedHighlight then
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
		bBetterIcon:SetSize(18, 18)
		bBetterIcon:ClearAllPoints()
		bBetterIcon:SetPoint("BOTTOMRIGHT", 4, -4)
	end

	button:SetBorderColor(unpack(COLORS.yellow))

	button.styled = true
end

function E:SkinExtraActionButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	button:SetBorderSize(10)

	E:ForceHide(button.style)

	button.styled = true
end

function E:SkinPetActionButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	button:SetBorderSize(6)

	local name = button:GetName()
	local bCD = button.cooldown
	local bAutoCast = _G[name.."AutoCastable"]
	local bShine = _G[name.."Shine"]
	local bHotKey = button.HotKey

	if bCD then
		bCD:SetTimerTextHeight(10)
	end

	if bAutoCast then
		bAutoCast:ClearAllPoints()
		bAutoCast:SetPoint("TOPLEFT", -14, 14)
		bAutoCast:SetPoint("BOTTOMRIGHT", 14, -14)
	end

	if bShine then
		bShine:ClearAllPoints()
		bShine:SetPoint("TOPLEFT", 1, -1)
		bShine:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	if bHotKey then
		bHotKey:SetFont(M.font, 8, "THINOUTLINE")
	end

	button:HookScript("OnUpdate", PetActionButton_OnUpdate)

	hooksecurefunc(button, "SetNormalTexture", SetNilNormalTexture)

	button.styled = true
end

function E:SkinActionButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	local name = button:GetName()
	local bFloatingBG = _G[name.."FloatingBG"]

	if bFloatingBG then
		E:ForceHide(bFloatingBG)
	end

	if button:GetScript("OnUpdate") then
		button:HookScript("OnUpdate", ActionButton_OnUpdate)
	end

	button.styled = true
end

local function OTButton_OnDrag(self)
	if IsModifiedClick("PICKUPACTION") then
		local link = GetQuestLogSpecialItemInfo(self:GetID())
		local bagID, slot = GetContainerSlotByItemLink(link)
		if bagID then
			PickupContainerItem(bagID, slot)
		end
	end
end

function E:SkinOTButton()
	if not self or self.styled then return end

	SkinButton(self)

	if self:GetScript("OnUpdate") then
		self:HookScript("OnUpdate", OTButton_OnUpdate)
	end

	self:RegisterForDrag("LeftButton")
	self:HookScript("OnDragStart", OTButton_OnDrag)
	self:HookScript("OnReceiveDrag", OTButton_OnDrag)

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
		if name == "ConsolidatedBuffs" then
			E:TweakIcon(bIcon, 18 / 128, 46 / 128, 18 / 64, 46 / 64)
		else
			E:TweakIcon(bIcon)
		end
	end

	E:CreateBorder(button, 8)

	if bBorder then
		bBorder:SetTexture(nil)

		if gsub(name, "%d", "") == "TempEnchant" then
			button:SetBorderColor(0.37, 0.15, 0.55)
		else
			hooksecurefunc(bBorder, "SetVertexColor", SetCustomVertexColor)
		end
	end

	if bCount then
		bCount:SetFont(M.font, 10, "THINOUTLINE")
		bCount:SetDrawLayer("OVERLAY", 1)
		bCount:ClearAllPoints()
		bCount:SetPoint("TOPRIGHT", 2, 1)
	end

	if bDuration then
		bDuration:SetFont(M.font, 11, "THINOUTLINE")
		bDuration:SetJustifyH("CENTER")
		bDuration:SetDrawLayer("OVERLAY", 1)
		bDuration:ClearAllPoints()
		bDuration:SetPoint("BOTTOMLEFT", -4, 0)
		bDuration:SetPoint("BOTTOMRIGHT", 4, 0)

		hooksecurefunc(bDuration, "SetFormattedText", SetCustomFormattedText)
	end

	button.styled = true
end

function E:SkinSquareButton(button)
	local texture = button.icon:GetTexture()
	local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = button.icon:GetTexCoord()
	local highlight = button:GetHighlightTexture()

	button.icon:SetSize(10, 10)

	highlight:SetTexture(texture)
	highlight:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
	highlight:ClearAllPoints()
	highlight:SetPoint("CENTER", 0, 0)
	highlight:SetSize(10, 10)

	button:SetNormalTexture("")
	button:SetPushedTexture("")
end
