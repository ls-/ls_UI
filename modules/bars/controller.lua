local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = _G

-- Mine
local isInit = false
local controller

local function PageButton_OnMouseDown(self)
	self.Bg:SetVertexColor(M.COLORS.YELLOW:GetRGB())
end

local function PageButton_OnMouseUp(self)
	self.Bg:SetVertexColor(M.COLORS.GREEN:GetRGB())

	_G.PlaySound("UChatScrollButton")
end

local function CreateCap(side)
	local frame = _G.CreateFrame("Frame", "$parent"..side.."Cap", controller)
	frame:SetFrameLevel(controller:GetFrameLevel() - 1)
	frame:SetSize(48, 50)

	local fg = controller:CreateTexture(nil, "ARTWORK", nil, 2)
	fg:SetAllPoints(frame)
	fg:SetTexture("Interface\\AddOns\\ls_UI\\media\\bottombar-main")

	-- Cogwheel
	local cog = frame:CreateTexture(nil, "ARTWORK", nil, -2)
	cog:SetTexture("Interface\\AddOns\\ls_UI\\media\\bottombar-cog")
	cog:SetTexCoord(1 / 128, 79 / 128, 1 / 128, 79 / 128)
	cog:SetSize(72, 72)
	frame.Cog = cog

	local ag = frame:CreateAnimationGroup()
	ag:SetLooping("REPEAT")
	controller[side.."RotationNormal"] = ag

	local anim = ag:CreateAnimation("Rotation")
	anim:SetChildKey("Cog")
	anim:SetOrder(1)
	anim:SetDegrees(-360)
	anim:SetDuration(20)

	ag:Play()

	ag = frame:CreateAnimationGroup()
	controller[side.."RotationRewind"] = ag

	anim = ag:CreateAnimation("Rotation")
	anim:SetChildKey("Cog")
	anim:SetDegrees(90)
	anim:SetDuration(0.25)

	ag = frame:CreateAnimationGroup()
	controller[side.."RotationFastForward"] = ag

	anim = ag:CreateAnimation("Rotation")
	anim:SetChildKey("Cog")
	anim:SetDegrees(-90)
	anim:SetDuration(0.25)

	ag = frame:CreateAnimationGroup()
	controller[side.."RotationLongRewind"] = ag

	anim = ag:CreateAnimation("Rotation")
	anim:SetChildKey("Cog")
	anim:SetDegrees(180)
	anim:SetDuration(0.5)

	-- Page button
	local button = _G.CreateFrame("Button", "$parent"..side.."PageButton", controller, "SecureActionButtonTemplate")
	button:SetFrameLevel(controller:GetFrameLevel() + 1)
	button:SetSize(22, 22)
	button:SetScript("OnMouseDown", PageButton_OnMouseDown)
	button:SetScript("OnMouseUp", PageButton_OnMouseUp)
	button:SetAttribute("type", "actionbar")
	button:SetAttribute("action", side == "Right" and "increment" or "decrement")
	button:SetHighlightTexture("Interface\\AddOns\\ls_UI\\media\\bottombar-page-button", "ADD")

	local bg = controller:CreateTexture(nil, "ARTWORK", nil, -1)
	bg:SetAllPoints(button)
	bg:SetTexture("Interface\\AddOns\\ls_UI\\media\\bottombar-page-button")
	bg:SetVertexColor(M.COLORS.GREEN:GetRGB())
	button.Bg = bg

	-- Micro menu artwork
	local nest = controller:CreateTexture(nil, "ARTWORK", nil, 3)
	nest:SetSize(146, 10)
	nest:SetTexture("Interface\\AddOns\\ls_UI\\media\\bottombar-nest")

	if side == "Left" then
		frame:SetPoint("BOTTOMRIGHT", controller, "BOTTOMLEFT", 3, 0)
		fg:SetTexCoord(1 / 64, 49 / 64, 51 / 256, 101 / 256)
		cog:SetPoint("CENTER", frame, "BOTTOMRIGHT", -4, 7)

		button:SetPoint("BOTTOMRIGHT", controller, "BOTTOMLEFT", -3, 7)
		bg:SetTexCoord(25 / 64, 47 / 64, 1 / 32, 23 / 32)
		button:GetHighlightTexture():SetTexCoord(1 / 64, 23 / 64, 1 / 32, 23 / 32)

		nest:SetTexCoord(1 / 256, 147 / 256, 1 / 64, 11 / 64)
		nest:SetPoint("BOTTOMRIGHT", controller, "BOTTOMLEFT", -36, 3)
	else
		frame:SetPoint("BOTTOMLEFT", controller, "BOTTOMRIGHT", -3, 0)
		fg:SetTexCoord(1 / 64, 49 / 64, 102 / 256, 152 / 256)
		cog:SetPoint("CENTER", frame, "BOTTOMLEFT", 4, 7)

		button:SetPoint("BOTTOMLEFT", controller, "BOTTOMRIGHT", 3, 7)
		bg:SetTexCoord(47 / 64, 25 / 64, 1 / 32, 23 / 32)
		button:GetHighlightTexture():SetTexCoord(23 / 64, 1 / 64, 1 / 32, 23 / 32)

		nest:SetTexCoord(1 / 256, 147 / 256, 12 / 64, 22 / 64)
		nest:SetPoint("BOTTOMLEFT", controller, "BOTTOMRIGHT", 36, 3)
	end
end

local function Controller_OnEvent(self)
	if _G.GetActionBarPage() > (self.Page or 1) then
		self.LeftRotationFastForward:Play()
		self.RightRotationFastForward:Play()
	else
		self.LeftRotationRewind:Play()
		self.RightRotationRewind:Play()
	end

	self.Page = _G.GetActionBarPage()
end

local function ControllerAnimation_OnPlay()
	controller.LeftRotationNormal:Stop()
	controller.LeftRotationLongRewind:Stop()

	controller.RightRotationNormal:Stop()
	controller.RightRotationLongRewind:Stop()

	E:StopFadeIn(_G.LSMainBar)
	E:FadeOut(_G.LSMainBar)

	E:StopFadeIn(_G.LSPetBattleBar)
	E:FadeOut(_G.LSPetBattleBar)
end

local function ControllerAnimation_OnFinished()
	controller.LeftRotationNormal:Play()
	controller.LeftRotationLongRewind:Play()

	controller.RightRotationNormal:Play()
	controller.RightRotationLongRewind:Play()

	E:StopFadeOut(_G.LSMainBar)
	E:FadeIn(_G.LSMainBar)

	E:StopFadeOut(_G.LSPetBattleBar)
	E:FadeIn(_G.LSPetBattleBar)
end

-----------------
-- INITIALISER --
-----------------

function BARS:ActionBarController_IsInit()
	return isInit
end

function BARS:ActionBarController_Init()
	if not isInit and C.bars.restricted then
		local hasSixButtons = _G.HasOverrideActionBar() or _G.HasVehicleActionBar() or _G.HasTempShapeshiftActionBar() or _G.C_PetBattles.IsInBattle()

		controller = _G.CreateFrame("Frame", "LSActionBarArtContainer", _G.UIParent, "SecureHandlerStateTemplate")
		controller:SetSize(32 * (hasSixButtons and 6 or 12), 50)
		controller:SetPoint("BOTTOM", 0, -3)
		controller:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
		controller:SetScript("OnEvent", Controller_OnEvent)

		local ag = controller:CreateAnimationGroup()
		ag:SetScript("OnPlay", ControllerAnimation_OnPlay)
		ag:SetScript("OnFinished", ControllerAnimation_OnFinished)

		local anim = ag:CreateAnimation("Translation")
		anim:SetOrder(1)
		anim:SetOffset(0, -50)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetOrder(2)
		anim:SetOffset(0, 50)
		anim:SetDuration(0.2)

		function controller.Update()
			ag:Play()
		end

		local texture = controller:CreateTexture(nil, "ARTWORK", nil, 1)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\bottombar-main", true)
		texture:SetHorizTile(true)
		texture:SetTexCoord(0 / 64, 64 / 64, 0 / 256, 50 / 256)
		controller.Fg = texture

		CreateCap("Left")
		CreateCap("Right")

		_G.LSMainBar:SetParent(controller)
		_G.LSMainBar:ClearAllPoints()
		_G.LSMainBar:SetPoint("CENTER", controller, "CENTER", 0, 0)
		_G.LSMainBar:SetAttribute("_childupdate-numbuttons", [[
			self:Hide()
			self:SetWidth(32 * message)
			self:Show()

			for i = 7, 12 do
				if message == 6 then
					buttons[i]:SetAttribute("ls-hidden", true)
					buttons[i]:Hide()
				else
					buttons[i]:SetAttribute("ls-hidden", false)
					buttons[i]:Show()
				end
			end
		]])

		_G.LSPetBattleBar:SetParent(controller)
		_G.LSPetBattleBar:ClearAllPoints()
		_G.LSPetBattleBar:SetPoint("CENTER", controller, "CENTER", 0, 0)

		_G.LSMBHolderLeft:SetParent(controller)
		_G.LSMBHolderLeft:ClearAllPoints()
		_G.LSMBHolderLeft:SetPoint("BOTTOMRIGHT", controller, "BOTTOMLEFT", -62, 9)

		_G.LSMBHolderRight:SetParent(controller)
		_G.LSMBHolderRight:ClearAllPoints()
		_G.LSMBHolderRight:SetPoint("BOTTOMLEFT", controller, "BOTTOMRIGHT", 62, 9)

		if C.bars.bags.enabled then
			_G.LSBagBar:SetParent(controller)
			_G.LSBagBar:ClearAllPoints()
			_G.LSBagBar:SetPoint("BOTTOMLEFT", controller, "BOTTOMRIGHT", 202, 9)

			texture = controller:CreateTexture(nil, "ARTWORK", nil, 1)
			texture:SetSize(50, 10)
			texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\bottombar-nest")
			texture:SetTexCoord(1 / 256, 51 / 256, 23 / 64, 33 / 64)
			texture:SetPoint("BOTTOMLEFT", controller, "BOTTOMRIGHT", 192, 3)
		end

		-- _"childupdate-numbuttons" is executed in controller's environment
		for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
			controller:SetFrameRef("ActionButton"..i, _G["ActionButton"..i])
		end

		controller:Execute([[
			buttons = table.new()

			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("ActionButton"..i))
			end
		]])

		controller:SetAttribute("_onstate-numbuttons", [[
			local width = 32 * newstate

			if width ~= floor(self:GetWidth()) then
				self:CallMethod("Update")
				self:SetWidth(width)
				self:ChildUpdate("numbuttons", newstate)
			end
		]])

		_G.RegisterStateDriver(controller, "numbuttons", "[vehicleui][petbattle][overridebar][possessbar] 6; 12")

		-- Finalise
		isInit = true
	end
end
