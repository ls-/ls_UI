local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS, TEXTURES = M.colors, M.textures
local B = E:GetModule("Bars")
local BARS_CFG

local pi = math.pi
local ActionBarUpButton, ActionBarDownButton = ActionBarUpButton, ActionBarDownButton
local GetActionBarPage = GetActionBarPage

local BarController

local function PageButton_OnMouseDown(self)
	self.Bg:SetVertexColor(0.9, 0.65, 0.15)
end

local function PageButton_OnMouseUp(self)
	self.Bg:SetVertexColor(0.15, 0.65, 0.15)
end

local function HandleActionPageButton(button, anchor, isReversed)
	button:Show()
	button:SetParent(BarController)
	button:SetFrameLevel(BarController:GetFrameLevel() + 1)
	button:SetSize(22, 22)
	button:ClearAllPoints()
	button:SetHitRectInsets(0, 0, 0, 0)
	button:SetScript("OnMouseDown", PageButton_OnMouseDown)
	button:SetScript("OnMouseUp", PageButton_OnMouseUp)

	local bg = BarController:CreateTexture(nil, "ARTWORK", nil, -1)
	bg:SetAllPoints(button)
	bg:SetTexture("Interface\\AddOns\\oUF_LS\\media\\bottombar")
	bg:SetVertexColor(0.15, 0.65, 0.15)
	button.Bg = bg

	button:SetNormalTexture("")
	button:SetPushedTexture("")
	button:SetDisabledTexture("")

	local highlight = button:GetHighlightTexture()
	highlight:SetTexture("Interface\\AddOns\\oUF_LS\\media\\bottombar")
	highlight:SetBlendMode("ADD")

	if isReversed then
		button:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 4, 7)
		bg:SetTexCoord(44 / 64, 22 / 64, 150 / 256, 172 / 256)
		highlight:SetTexCoord(22 / 64, 0, 150 / 256, 172 / 256)
	else
		button:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -4, 7)
		bg:SetTexCoord(22 / 64, 44 / 64, 150 / 256, 172 / 256)
		highlight:SetTexCoord(0, 22 / 64, 150 / 256, 172 / 256)
	end
end

local function CreateAnimationSet(object, side)
	local group = object:CreateAnimationGroup()
	group:SetIgnoreFramerateThrottle(true)
	group:SetLooping("REPEAT")
	BarController[side.."RotationNormal"] = group

	local animation = group:CreateAnimation("ROTATION")
	animation:SetRadians(-pi * 2)
	animation:SetDuration(20)

	group = object:CreateAnimationGroup()
	group:SetIgnoreFramerateThrottle(true)
	BarController[side.."RotationRewind"] = group

	animation = group:CreateAnimation("ROTATION")
	animation:SetRadians(pi / 2)
	animation:SetDuration(0.25)

	group = object:CreateAnimationGroup()
	group:SetIgnoreFramerateThrottle(true)
	BarController[side.."RotationFastForward"] = group

	animation = group:CreateAnimation("ROTATION")
	animation:SetRadians(-pi / 2)
	animation:SetDuration(0.25)

	group = object:CreateAnimationGroup()
	group:SetIgnoreFramerateThrottle(true)
	BarController[side.."RotationLongRewind"] = group

	animation = group:CreateAnimation("ROTATION")
	animation:SetRadians(pi)
	animation:SetDuration(0.5)
end

local function ConstructCap(side)
	local cap = BarController:CreateTexture(nil, "ARTWORK", nil, 2)
	cap:SetSize(48, 50)
	cap:SetTexture("Interface\\AddOns\\oUF_LS\\media\\bottombar")

	local cog = BarController:CreateTexture(nil, "ARTWORK", nil, -2)
	cog:SetTexture("Interface\\AddOns\\oUF_LS\\media\\cog")
	cog:SetTexCoord(0, 78 / 128, 0, 78 / 128)
	cog:SetSize(72, 72)

	local nest = BarController:CreateTexture(nil, "ARTWORK", nil, 3)
	nest:SetSize(146, 10)
	nest:SetTexture("Interface\\AddOns\\oUF_LS\\media\\micromenu")

	CreateAnimationSet(cog, side)
	BarController[side.."RotationNormal"]:Play()

	if side == "Right" then
		HandleActionPageButton(ActionBarUpButton, cap, true)

		cap:SetTexCoord(0, 48 / 64, 100 / 256, 150 / 256)
		cap:SetPoint("LEFT", BarController.Fg, "RIGHT", -3, 0)

		cog:SetPoint("CENTER", cap, "BOTTOMLEFT", 4, 7)

		nest:SetTexCoord(0, 146 / 256, 10 / 64, 20 / 64)
		nest:SetPoint("BOTTOMLEFT", BarController, "BOTTOMRIGHT", 36, 4)
	else
		HandleActionPageButton(ActionBarDownButton, cap)

		cap:SetTexCoord(0, 48 / 64, 50 / 256, 100 / 256)
		cap:SetPoint("RIGHT", BarController.Fg, "LEFT", 3, 0)

		cog:SetPoint("CENTER", cap, "BOTTOMRIGHT", -4, 7)

		nest:SetTexCoord(0, 146 / 256, 0, 10 / 64)
		nest:SetPoint("BOTTOMRIGHT", BarController, "BOTTOMLEFT", -36, 4)
	end
end

local function BarController_OnEvent(self, event, ...)
	if GetActionBarPage() > (self.Page or 1) then
		self.LeftRotationFastForward:Play()
		self.RightRotationFastForward:Play()
	else
		self.LeftRotationRewind:Play()
		self.RightRotationRewind:Play()
	end

	self.Page = GetActionBarPage()
end

local function BarControllerAnimation_OnPlay(self)
	BarController.LeftRotationNormal:Stop()
	BarController.RightRotationNormal:Stop()
	BarController.LeftRotationLongRewind:Stop()
	BarController.RightRotationLongRewind:Stop()

	if BarController.MainBars then
		for _, bar in next, BarController.MainBars do
			E:StopFadeIn(bar)
			E:FadeOut(bar)
		end
	end
end
local function BarControllerAnimation_OnFinished(self)
	BarController.LeftRotationNormal:Play()
	BarController.RightRotationNormal:Play()
	BarController.LeftRotationLongRewind:Play()
	BarController.RightRotationLongRewind:Play()

	if BarController.MainBars then
		for _, bar in next, BarController.MainBars do
			E:StopFadeOut(bar)
			E:FadeIn(bar)
		end
	end
end

function B:SetupControlledBar(bar, barType)
	if not BarController then return end

	if barType == "Main" then
		bar:SetParent(BarController)
		bar:ClearAllPoints()
		bar:SetPoint("CENTER", BarController, "CENTER", 0, 0)
		bar:SetAttribute("_onstate-numbuttons", [[
			self:Hide()
			self:SetWidth(32 * newstate)
			self:Show()
		]])
		RegisterStateDriver(bar, "numbuttons", "[vehicleui][overridebar] 6; 12")
		-- RegisterStateDriver(bar, "numbuttons", "[combat] 6; 12")

		if #bar.buttons > 6 then
			for i = 7, #bar.buttons, 1 do
				RegisterStateDriver(bar.buttons[i], "visibility", "[vehicleui][overridebar] hide; show")
				-- RegisterStateDriver(bar.buttons[i], "visibility", "[combat] hide; show")
			end
		end
		BarController.MainBars = BarController.MainBars or {}
		tinsert(BarController.MainBars, bar)
	elseif barType == "PetBattle" then
		bar:SetParent(BarController)
		bar:ClearAllPoints()
		bar:SetPoint("CENTER", BarController, "CENTER", 0, 0)

		BarController.MainBars = BarController.MainBars or {}
		tinsert(BarController.MainBars, bar)
	elseif barType == "MicroMenuLeft" then
		bar:SetParent(BarController)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOMRIGHT", BarController, "BOTTOMLEFT", -62, 10)
	elseif barType == "MicroMenuRight" then
		bar:SetParent(BarController)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOMLEFT", BarController, "BOTTOMRIGHT", 62, 10)
	end
end

function B:ActionBarController_Initialize()
	BARS_CFG = C.bars

	if BARS_CFG.restricted then
		BarController = CreateFrame("Frame", "LSActionBarArtContainer", UIParent, "SecureHandlerStateTemplate")
		BarController:SetSize(32 * 12, 50)
		BarController:SetPoint("BOTTOM", 0, -4)
		BarController:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
		BarController:SetScript("OnEvent", BarController_OnEvent)
		B.BarController = BarController

		local group = BarController:CreateAnimationGroup()
		group:SetIgnoreFramerateThrottle(true)
		group:SetScript("OnPlay", BarControllerAnimation_OnPlay)
		group:SetScript("OnFinished", BarControllerAnimation_OnFinished)
		BarController.SlideInOut = group

		local animation = group:CreateAnimation("TRANSLATION")
		animation:SetOrder(1)
		animation:SetOffset(0, -50)
		animation:SetDuration(0.1)

		animation = group:CreateAnimation("TRANSLATION")
		animation:SetOrder(2)
		animation:SetOffset(0, 50)
		animation:SetDuration(0.25)

		function BarController:Update()
			self.SlideInOut:Play()
		end

		local texture = BarController:CreateTexture(nil, "ARTWORK", nil, 1)
		texture:SetAllPoints()
		texture:SetTexture("Interface\\AddOns\\oUF_LS\\media\\bottombar", true)
		texture:SetHorizTile(true)
		texture:SetTexCoord(0, 1, 0, 50 / 256)
		BarController.Fg = texture

		ConstructCap("Left")
		ConstructCap("Right")

		BarController:SetAttribute("_onstate-numbuttons", [[
			local width = 32 * newstate
			if width ~= floor(self:GetWidth()) then
				self:CallMethod("Update")
				self:SetWidth(32 * newstate)
			end
		]])

		RegisterStateDriver(BarController, "numbuttons", "[vehicleui][petbattle][overridebar] 6; 12")
		-- RegisterStateDriver(BarController, "numbuttons", "[combat] 6; 12")
	end
end
