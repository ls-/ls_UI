local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next
local unpack = _G.unpack

-- Blizz
local C_Timer = _G.C_Timer

--[[ luacheck: globals
	CreateFrame RegisterStateDriver UIParent
]]

-- Mine
local isInit = false
local controller
local anim_controller

local elements = {
	top = {
		left = {
			size = {232 / 2, 90 / 2},
			coords = {1 / 2048, 233 / 2048, 1 / 256, 91 / 256},
		},
		mid = {
			size = {432 / 2, 90 / 2},
			coords = {233 / 2048, 665 / 2048, 1 / 256, 91 / 256},
		},
		right = {
			size = {232 / 2, 90 / 2},
			coords = {665 / 2048, 897 / 2048, 1 / 256, 91 / 256},
		},
	},
	bottom = {
		left = {
			size = {568 / 2, 46 / 2},
			coords = {1 / 2048, 569 / 2048, 92 / 256, 138 / 256},
		},
		mid = {
			size = {432 / 2, 46 / 2},
			coords = {569 / 2048, 1001 / 2048, 92 / 256, 138 / 256},
		},
		right = {
			size = {568 / 2, 46 / 2},
			coords = {1001 / 2048, 1569 / 2048, 92 / 256, 138 / 256},
		},
	},
}

local WIDGETS = {}

WIDGETS.ACTION_BAR = {
	frame = false,
	children = false,
	point = {"BOTTOM", "LSActionBarControllerBottom", "BOTTOM", 0, 15},
	on_add = function ()
		WIDGETS.ACTION_BAR.children = {
			[1] = _G["LSActionBar2"],
			[2] = _G["LSActionBar3"],
			[3] = _G["LSActionBar4"],
			[4] = _G["LSActionBar5"],
			[5] = _G["LSPetBar"],
			[6] = _G["LSStanceBar"],
		}
	end,
	attribute = {
		name = "_childupdate-numbuttons",
		condition = [[
			self:Hide()
			self:SetWidth(36 * message)
			self:Show()

			for i = 7, 12 do
				if message == 6 then
					buttons[i]:SetAttribute("statehidden", true)
					buttons[i]:Hide()
				else
					buttons[i]:SetAttribute("statehidden", nil)
					buttons[i]:Show()
				end
			end
		]]
	},
}

WIDGETS.PET_BATTLE_BAR = {
	frame = false,
	children = false,
	point = {"BOTTOM", "LSActionBarControllerBottom", "BOTTOM", 0, 15},
}

WIDGETS.XP_BAR = {
	frame = false,
	children = false,
	point = {"BOTTOM", "LSActionBarControllerBottom", "BOTTOM", 0, 0},
	on_play = function(_, newstate)
		MODULE:GetBar("xpbar"):UpdateSize(newstate == 6 and 756 / 2 or 1188 / 2, 12)
	end
}

function MODULE.ActionBarController_AddWidget(_, frame, slot)
	if isInit then
		if WIDGETS[slot].frame == false then
			WIDGETS[slot].frame = frame

			frame:SetParent(controller)
			frame:ClearAllPoints()
			frame:SetPoint(unpack(WIDGETS[slot].point))

			if slot == "ACTION_BAR" then
				frame:SetFrameLevel(controller:GetFrameLevel() + 2)
			elseif slot == "XP_BAR" then
				frame:SetFrameLevel(controller:GetFrameLevel() + 3)
			end

			if WIDGETS[slot].attribute then
				frame:SetAttribute(WIDGETS[slot].attribute.name, WIDGETS[slot].attribute.condition)
			end

			if WIDGETS[slot].on_add then
				WIDGETS[slot].on_add(frame)
			end

			-- register state driver & trigger update
			if not controller.isDriverRegistered
				and WIDGETS["ACTION_BAR"].frame
				and WIDGETS["PET_BATTLE_BAR"].frame
				and WIDGETS["XP_BAR"].frame then

				-- _"childupdate-numbuttons" is executed in controller's environment
				for i = 1, 12 do
					controller:SetFrameRef("button" .. i, _G["LSActionBar1Button" .. i])
				end

				controller:Execute([[
					top = self:GetFrameRef("top")
					bottom = self:GetFrameRef("bottom")
					buttons = table.new()

					for i = 1, 12 do
						table.insert(buttons, self:GetFrameRef("button" .. i))
					end
				]])

				controller:SetAttribute("_onstate-mode", [[
					if newstate ~= self:GetAttribute("numbuttons") then
						self:SetAttribute("numbuttons", newstate)
						self:ChildUpdate("numbuttons", newstate)
						self:CallMethod("Update")

						top:SetWidth(newstate == 6 and 0.001 or 216)
						bottom:SetWidth(newstate == 6 and 0.001 or 216)
					end
				]])

				RegisterStateDriver(controller, "mode", "[vehicleui][petbattle][overridebar][possessbar] 6; 12")

				controller.isDriverRegistered = true
			end
		end
	end
end

function MODULE.IsRestricted()
	return isInit
end

function MODULE.SetupActionBarController()
	if not isInit and C.db.char.bars.restricted then
		controller = CreateFrame("Frame", "LSActionBarController", UIParent, "SecureHandlerStateTemplate")
		controller:SetSize(32, 32)
		controller:SetPoint("BOTTOM", 0, 0)
		controller:SetAttribute("numbuttons", 12)
		controller.Update = function()
			if controller.Shuffle:IsPlaying() then
				controller.Shuffle:Stop()
			end

			controller.Shuffle:Play()
		end

		anim_controller = CreateFrame("Frame", "LSActionBarAnimController", UIParent)
		anim_controller:SetFrameLevel(controller:GetFrameLevel())
		anim_controller:SetAllPoints(controller)

		-- These frames are used as anchors/parents for other frames, some of
		-- which are protected, so make these secure too
		local top = CreateFrame("Frame", "$parentTop", controller, "SecureHandlerBaseTemplate")
		top:SetFrameLevel(controller:GetFrameLevel() + 1)
		top:SetPoint("BOTTOM", 0, 28 / 2)
		top:SetSize(unpack(elements.top.mid.size))
		controller.Top = top
		controller:SetFrameRef("top", top)

		local bottom = CreateFrame("Frame", "$parentBottom", controller, "SecureHandlerBaseTemplate")
		bottom:SetFrameLevel(controller:GetFrameLevel() + 7)
		bottom:SetPoint("BOTTOM", 0, 0)
		bottom:SetSize(unpack(elements.bottom.mid.size))
		controller.Bottom = bottom
		controller:SetFrameRef("bottom", bottom)

		-- These frames are used as anchors/parents for textures
		top = CreateFrame("Frame", "$parentTop", anim_controller)
		top:SetFrameLevel(anim_controller:GetFrameLevel() + 1)
		top:SetPoint("BOTTOM", 0, 28 / 2)
		top:SetSize(unpack(elements.top.mid.size))
		anim_controller.Top = top

		local texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(unpack(elements.top.left.coords))
		texture:SetPoint("BOTTOMRIGHT", top, "BOTTOMLEFT", 0, 0)
		texture:SetSize(unpack(elements.top.left.size))
		top.Left = texture

		texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(unpack(elements.top.mid.coords))
		texture:SetAllPoints()
		top.Mid = texture

		texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(unpack(elements.top.right.coords))
		texture:SetPoint("BOTTOMLEFT", top, "BOTTOMRIGHT", 0, 0)
		texture:SetSize(unpack(elements.top.right.size))
		top.Right = texture

		bottom = CreateFrame("Frame", "$parentBottom", anim_controller)
		bottom:SetFrameLevel(anim_controller:GetFrameLevel() + 7)
		bottom:SetPoint("BOTTOM", 0, 0)
		bottom:SetSize(unpack(elements.bottom.mid.size))
		anim_controller.Bottom = bottom

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(unpack(elements.bottom.left.coords))
		texture:SetPoint("BOTTOMRIGHT", bottom, "BOTTOMLEFT", 0, 0)
		texture:SetSize(unpack(elements.bottom.left.size))
		bottom.Left = texture

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(unpack(elements.bottom.mid.coords))
		texture:SetAllPoints()
		bottom.Mid = texture

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(unpack(elements.bottom.right.coords))
		texture:SetPoint("BOTTOMLEFT", bottom, "BOTTOMRIGHT", 0, 0)
		texture:SetSize(unpack(elements.bottom.right.size))
		bottom.Right = texture

		local ag = anim_controller:CreateAnimationGroup()
		ag:SetScript("OnPlay", function()
			local newstate = controller:GetAttribute("numbuttons")

			for _, widget in next, WIDGETS do
				if widget.frame then
					E:FadeOut(widget.frame)

					if widget.children then
						for _, child in next, widget.children do
							E:FadeOut(child)
						end
					end
				end
			end

			C_Timer.After(0.02, function()
				for _, widget in next, WIDGETS do
					if widget.frame and widget.on_play then
						widget.on_play(widget.frame, newstate)
					end
				end
			end)

			C_Timer.After(0.25, function()
				anim_controller.Top:SetWidth(newstate == 6 and 0.001 or 216)
				anim_controller.Bottom:SetWidth(newstate == 6 and 0.001 or 216)
			end)
		end)
		ag:SetScript("OnFinished", function()
			for _, widget in next, WIDGETS do
				if widget.frame then
					if widget.frame:IsShown() then
						E:FadeIn(widget.frame)
					else
						widget.frame:SetAlpha(1)
					end

					if widget.children then
						for _, child in next, widget.children do
							if child:IsShown() then
								E:FadeIn(child)
							else
								child:SetAlpha(1)
							end
						end
					end
				end
			end
		end)
		controller.Shuffle = ag

		local anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Top")
		anim:SetOrder(1)
		anim:SetOffset(0, -55)
		anim:SetStartDelay(0.02)
		anim:SetDuration(0.15)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bottom")
		anim:SetOrder(2)
		anim:SetOffset(0, -23)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bag")
		anim:SetOrder(2)
		anim:SetOffset(0, -23)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bottom")
		anim:SetOrder(3)
		anim:SetOffset(0, 23)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bag")
		anim:SetOrder(3)
		anim:SetOffset(0, 23)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Top")
		anim:SetOrder(4)
		anim:SetOffset(0, 55)
		anim:SetDuration(0.15)

		isInit = true
	end
end
