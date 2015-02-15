local _, ns = ...
local E, M = ns.E, ns.M

local COLORS, TEXTURES = ns.M.colors, M.textures

local function SetStancePetActionBarPosition(self)
	if self:GetName() == "lsPetActionBar" then
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["PET"..STANCE_PET_VISIBILITY[ns.E.playerclass]]))
	else
		self:SetPoint(unpack(STANCE_PET_VISIBILITY["STANCE"..STANCE_PET_VISIBILITY[ns.E.playerclass]]))
	end
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

local function SetCustomVertexColor(self, r, g, b)
	local button = self:GetParent()

	if button == ExtraActionButton1 then
		button.lsBorder:SetVertexColor(0.9, 0.4, 0.1)
	else
		button.lsBorder:SetVertexColor(r, g, b)
	end
end

local function CustomSetText(self, text)
	self:SetFormattedText("%s", gsub(text, "[ ()]", ""))
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
	local bCD = button.cooldown
	local bCDText = bCD and bCD:GetRegions() -- it's #1 region
	local bNormalTexture = button.GetNormalTexture and button:GetNormalTexture()
	local bPushedTexture = button.GetPushedTexture and button:GetPushedTexture()
	local bHighlightTexture = button.GetHighlightTexture and button:GetHighlightTexture()
	local bCheckedTexture = button.GetCheckedTexture and button:GetCheckedTexture()

	E:TweakIcon(bIcon)

	if bFlash then
		SetFlashTexture(bFlash)
	end

	if bFOBorder then
		E:AlwaysHide(bFOBorder)
	end

	if bFOBorderShadow then
		E:AlwaysHide(bFOBorderShadow)
	end

	if bHotKey then
		bHotKey:SetFont(ns.M.font, 10, "THINOUTLINE")
		bHotKey:ClearAllPoints()
		bHotKey:SetPoint("TOPRIGHT", 2, 1)
	end

	if bCount then
		bCount:SetFont(ns.M.font, 10, "THINOUTLINE")
		bCount:ClearAllPoints()
		bCount:SetPoint("BOTTOMRIGHT", 2, -1)
	end

	if bName then
		bName:SetFont(ns.M.font, 10, "THINOUTLINE")
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
		bCD:SetAllPoints()

		if bCDText then
			bCDText:SetFont(ns.M.font, 12, "THINOUTLINE")
			bCDText:ClearAllPoints()
			bCDText:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 4)
			bCDText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
		end
	end

	if bNormalTexture then
		bNormalTexture:SetTexture(nil)

		button.lsBorder = E:CreateButtonBorder(button)

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

function E:SetButtonPosition(buttons, buttonSize, buttonGap, header, orientation, direction, skinFucntion, originalBar)
	if originalBar and originalBar:GetParent() ~= header then
		originalBar:SetParent(header)
		originalBar:EnableMouse(false)
		originalBar.ignoreFramePositionManager = true
	end

	local previous

	for i = 1, #buttons do
		local button = buttons[i]

		button:ClearAllPoints()
		button:SetSize(buttonSize, buttonSize)

		if not originalBar then button:SetParent(header) end

		button:SetFrameStrata("LOW")
		button:SetFrameLevel(2)

		if orientation == "HORIZONTAL" then
			if direction == "RIGHT" then
				if i == 1 then
					button:SetPoint("LEFT", header, "LEFT", buttonGap / 2, 0)
				else
					button:SetPoint("LEFT", previous, "RIGHT", buttonGap, 0)
				end
			else
				if i == 1 then
					button:SetPoint("RIGHT", header, "RIGHT", -buttonGap / 2, 0)
				else
					button:SetPoint("RIGHT", previous, "LEFT", -buttonGap, 0)
				end
			end
		else
			if direction == "DOWN" then
				if i == 1 then
					button:SetPoint("TOP", header, "TOP", 0, -buttonGap / 2)
				else
					button:SetPoint("TOP", previous, "BOTTOM", 0, -buttonGap)
				end
			else
				if i == 1 then
					button:SetPoint("BOTTOM", header, "BOTTOM", 0, buttonGap / 2)
				else
					button:SetPoint("BOTTOM", previous, "TOP", 0, buttonGap)
				end
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
		E:AlwaysHide(bIconBorder)

		hooksecurefunc(bIconBorder, "SetVertexColor", SetCustomVertexColor)
	end

	if bCount then
		hooksecurefunc(bCount, "SetText", CustomSetText)
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
		bCD:SetFont(ns.M.font, 16, "THINOUTLINE")
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

	button.styled = true
end

function E:SkinExtraActionButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	E:AlwaysHide(button.style)
	E:AlwaysHide(button.HotKey)

	button.styled = true
end

function E:SkinPetActionButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	local name = button:GetName()
	local bAutoCast = _G[name.."AutoCastable"]
	local bShine = _G[name.."Shine"]

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

	hooksecurefunc(button, "SetNormalTexture", SetNilNormalTexture)

	E:AlwaysHide(button.HotKey)

	button.styled = true
end

function E:SkinActionButton(button)
	if not button or button.styled then return end

	SkinButton(button)

	local name = button:GetName()
	local bFloatingBG = _G[name.."FloatingBG"]

	if bFloatingBG then
		E:AlwaysHide(bFloatingBG)
	end

	button.styled = true
end

function E:SkinOTButton()
	if not self or self.styled then return end

	SkinButton(self)

	E:AlwaysHide(self.HotKey)

	self.styled = true
end
