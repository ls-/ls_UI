local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BARS = P:GetModule("Bars")

-- Lua
local _G = _G
local unpack = _G.unpack
local pairs = _G.pairs

-- Mine
local isInit = false
local controller

local elements = {
	top = {
		left = {
			size = {226 / 2, 84 / 2},
			coords = {1 / 2048, 227 / 2048, 1 / 128, 85 / 128},
		},
		mid = {
			size = {432 / 2, 84 / 2},
			coords = {227 / 2048, 659 / 2048, 1 / 128, 85 / 128},
		},
		right = {
			size = {226 / 2, 84 / 2},
			coords = {659 / 2048, 885 / 2048, 1 / 128, 85 / 128},
		},
	},
	bottom = {
		left = {
			size = {544 / 2, 32 / 2},
			coords = {1 / 2048, 545 / 2048, 86 / 128, 118 / 128},
		},
		mid = {
			size = {432 / 2, 32 / 2},
			coords = {545 / 2048, 977 / 2048, 86 / 128, 118 / 128},
		},
		right = {
			size = {544 / 2, 32 / 2},
			coords = {977 / 2048, 1521 / 2048, 86 / 128, 118 / 128},
		},
	},
}

local WIDGETS = {
	ACTION_BAR = {
		frame = false,
		point = {"BOTTOM", "LSActionBarArtContainerBottom", "BOTTOM", 0, 11},
		attribute = {
			name = "_childupdate-numbuttons",
			condition = [[
				self:Hide()
				self:SetWidth(36 * message)
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
			]]
		},
	},
	PET_BATTLE_BAR = {
		frame = false,
		point = {"BOTTOM", "LSActionBarArtContainerBottom", "BOTTOM", 0, 11},
	},
	BAG = {
		frame = false,
		point = {"BOTTOMLEFT", "LSActionBarArtContainerBottom", "BOTTOMRIGHT", 294, 11},
	},
	MM_LEFT = {
		frame = false,
		point = {"BOTTOMRIGHT", "LSActionBarArtContainerBottom", "BOTTOMLEFT", -148, 11},
	},
	MM_RIGHT = {
		frame = false,
		point = {"BOTTOMLEFT", "LSActionBarArtContainerBottom", "BOTTOMRIGHT", 148, 11},
	},
	EXP_BAR = {
		frame = false,
		point = {"BOTTOM", "LSActionBarArtContainerBottom", "BOTTOM", 0, 0},
		post = function(_, newstate)
			BARS:SetExpBarMode(newstate == 6 and "SHORT" or "DEFAULT")
		end
	},
}

local function ControllerAnimation_OnPlay()
	local newstate = controller:GetAttribute("numbuttons")

	for _, widget in pairs(WIDGETS) do
		if widget.frame then
			E:StopFadeIn(widget.frame)
			E:FadeOut(widget.frame, 0.001)
		end
	end

	_G.C_Timer.After(0.02, function()
		for _, widget in pairs(WIDGETS) do
			if widget.frame and widget.post then
				widget.post(widget.frame, newstate)
			end
		end
	end)

	_G.C_Timer.After(0.25, function()
		controller.Top:SetWidth(newstate == 6 and 0.001 or 216)
		controller.Bottom:SetWidth(newstate == 6 and 0.001 or 216)
	end)
end

local function ControllerAnimation_OnFinished()
	for _, widget in pairs(WIDGETS) do
		if widget.frame then
			E:StopFadeOut(widget.frame)
			E:FadeIn(widget.frame, 0.1)
		end
	end
end

------------
-- PUBLIC --
------------

local isDriverRegistered = false

function BARS:ActionBarController_AddWidget(frame, slot)
	if isInit then
		if WIDGETS[slot].frame == false then
			WIDGETS[slot].frame = frame

			frame:SetParent(controller)
			frame:ClearAllPoints()
			frame:SetPoint(unpack(WIDGETS[slot].point))

			if slot == "ACTION_BAR" or slot == "MM_LEFT" or slot == "MM_RIGHT" or slot == "BAG" then
				frame:SetFrameLevel(controller:GetFrameLevel() + 2)
			elseif slot == "EXP_BAR" then
				frame:SetFrameLevel(controller:GetFrameLevel() + 3)
			end

			if WIDGETS[slot].attribute then
				frame:SetAttribute(WIDGETS[slot].attribute.name, WIDGETS[slot].attribute.condition)
			end

			-- register state driver & trigger update
			if not isDriverRegistered
				and WIDGETS["ACTION_BAR"].frame
				and WIDGETS["PET_BATTLE_BAR"].frame
				and WIDGETS["MM_LEFT"].frame
				and WIDGETS["MM_RIGHT"].frame
				and WIDGETS["EXP_BAR"].frame
				and (C.bars.bags.enabled and WIDGETS["EXP_BAR"].frame or not C.bars.bags.enabled) then
				_G.RegisterStateDriver(controller, "width", "[vehicleui][petbattle][overridebar][possessbar] 6; 12")

				isDriverRegistered = true
			end
		end
	end
end

-----------------
-- INITIALISER --
-----------------

function BARS:ActionBarController_IsInit()
	return isInit
end

function BARS:ActionBarController_Init()
	if not isInit and C.bars.restricted then
		controller = _G.CreateFrame("Frame", "LSActionBarArtContainer", _G.UIParent, "SecureHandlerStateTemplate")
		controller:SetSize(32, 32)
		controller:SetPoint("BOTTOM", 0, 0)
		controller:SetAttribute("numbuttons", 12)
		controller.Update = function()
			controller.Shuffle:Play()
		end

		-- top
		local top = _G.CreateFrame("Frame", "$parentTop", controller)
		top:SetFrameLevel(controller:GetFrameLevel() + 1)
		top:SetPoint("BOTTOM", 0, 20 / 2)
		top:SetSize(unpack(elements.top.mid.size))
		controller.Top = top

		local texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\console")
		texture:SetTexCoord(unpack(elements.top.left.coords))
		texture:SetPoint("BOTTOMRIGHT", top, "BOTTOMLEFT", 0, 0)
		texture:SetSize(unpack(elements.top.left.size))
		top.Left = texture

		texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\console")
		texture:SetTexCoord(unpack(elements.top.mid.coords))
		texture:SetAllPoints()
		top.Mid = texture

		texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\console")
		texture:SetTexCoord(unpack(elements.top.right.coords))
		texture:SetPoint("BOTTOMLEFT", top, "BOTTOMRIGHT", 0, 0)
		texture:SetSize(unpack(elements.top.right.size))
		top.Right = texture

		-- bottom
		local bottom = _G.CreateFrame("Frame", "$parentBottom", controller)
		bottom:SetFrameLevel(controller:GetFrameLevel() + 7)
		bottom:SetPoint("BOTTOM", 0, 0)
		bottom:SetSize(unpack(elements.bottom.mid.size))
		controller.Bottom = bottom

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\console")
		texture:SetTexCoord(unpack(elements.bottom.left.coords))
		texture:SetPoint("BOTTOMRIGHT", bottom, "BOTTOMLEFT", 0, 0)
		texture:SetSize(unpack(elements.bottom.left.size))
		bottom.Left = texture

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\console")
		texture:SetTexCoord(unpack(elements.bottom.mid.coords))
		texture:SetAllPoints()
		bottom.Mid = texture

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\media\\console")
		texture:SetTexCoord(unpack(elements.bottom.right.coords))
		texture:SetPoint("BOTTOMLEFT", bottom, "BOTTOMRIGHT", 0, 0)
		texture:SetSize(unpack(elements.bottom.right.size))
		bottom.Right = texture

		local ag = controller:CreateAnimationGroup()
		ag:SetScript("OnPlay", ControllerAnimation_OnPlay)
		ag:SetScript("OnFinished", ControllerAnimation_OnFinished)
		controller.Shuffle = ag

		local anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Top")
		anim:SetOrder(1)
		anim:SetOffset(0, -52)
		anim:SetStartDelay(0.02)
		anim:SetDuration(0.15)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bottom")
		anim:SetOrder(2)
		anim:SetOffset(0, -16)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bottom")
		anim:SetOrder(3)
		anim:SetOffset(0, 16)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Top")
		anim:SetOrder(4)
		anim:SetOffset(0, 52)
		anim:SetDuration(0.15)

		-- _"childupdate-numbuttons" is executed in controller's environment
		for i = 1, _G.NUM_ACTIONBAR_BUTTONS do
			controller:SetFrameRef("ActionButton"..i, _G["ActionButton"..i])
		end

		controller:SetFrameRef("top", top)
		controller:SetFrameRef("bottom", bottom)
		controller:Execute([[
			top = self:GetFrameRef("top")
			bottom = self:GetFrameRef("bottom")
			buttons = table.new()

			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("ActionButton"..i))
			end
		]])

		controller:SetAttribute("_onstate-width", [[
			if newstate ~= self:GetAttribute("numbuttons") then
				self:SetAttribute("numbuttons", newstate)
				self:CallMethod("Update")
				self:ChildUpdate("numbuttons", newstate)
			end
		]])

		-- Finalise
		isInit = true

		return true
	end
end
