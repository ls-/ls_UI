local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local next = _G.next
local unpack = _G.unpack

-- Mine
local isInit = false
local isFinilized = false

local barController
local animController

local ENDCAPS = {
	[1] = {
		["Alliance"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-gryphon",
		["Horde"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-wyvern",
		["Neutral"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-wyvern",
	},
	[2] = {
		["Alliance"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-gryphon",
		["Horde"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-wyvern",
		["Neutral"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-gryphon",
	},
}

local WIDGETS = {
	["ACTION_BAR"] = {
		frame_level_offset = 2,
		point = {"BOTTOM", "LSActionBarControllerBottom", "BOTTOM", 0, 15},
		children = {
			"LSActionBar2",
			"LSActionBar3",
			"LSActionBar4",
			"LSActionBar5",
			"LSActionBar6",
			"LSActionBar7",
			"LSActionBar8",
			"LSPetBar",
			"LSStanceBar",
		},
		attributes = {
			["_childupdate-numbuttons"] = [[
				self:Hide()
				self:SetWidth(36 * message)
				self:Show()

				for i = 7, 12 do
					if i > message then
						buttons[i]:SetAttribute("statehidden", true)
						buttons[i]:Hide()
					else
						buttons[i]:SetAttribute("statehidden", nil)
						buttons[i]:Show()
					end
				end
			]],
		},
	},
	["PET_BATTLE_BAR"] = {
		frame_level_offset = 2,
		point = {"BOTTOM", "LSActionBarControllerBottom", "BOTTOM", 0, 15},
	},
	["XP_BAR"] = {
		frame_level_offset = 3,
		point = {"BOTTOM", "LSActionBarControllerBottom", "BOTTOM", 0, 0},
		on_play = function(frame, newstate)
			frame:UpdateSize(756 / 2 + 36 * (newstate - 6), 12)
		end,
	},
}

function MODULE:AddControlledWidget(slot, frame)
	if isInit then
		local widget = WIDGETS[slot]
		if widget and not widget.frame then
			frame:SetParent(barController)
			frame:SetFrameLevel(barController:GetFrameLevel() + widget.frame_level_offset)
			frame:ClearAllPoints()
			frame:SetPoint(unpack(widget.point))

			if widget.attributes then
				for attr, body in next, widget.attributes do
					frame:SetAttribute(attr, body)
				end
			end

			widget.frame = frame
		end
	end
end

function MODULE:IsRestricted()
	return isInit
end

function MODULE:SetupActionBarController()
	if not isInit and PrC.db.profile.bars.restricted then
		barController = CreateFrame("Frame", "LSActionBarController", UIParent, "SecureHandlerStateTemplate")
		barController:SetSize(32, 32)
		barController:SetPoint("BOTTOM", 0, 0)
		barController:SetAttribute("numbuttons", 12)
		barController.Update = function()
			if barController.Shuffle:IsPlaying() then
				barController.Shuffle:Stop()
			end

			barController.Shuffle:Play()
		end
		barController.UpdateSimple = function(_, newstate)
			for _, widget in next, WIDGETS do
				if widget.frame and widget.on_play then
					widget.on_play(widget.frame, newstate)
				end
			end

			animController.Top:SetWidth(newstate == 6 and 0.001 or 36 * (newstate - 6))
			animController.Top.Mid:SetTexCoord(233 / 2048, (233 + 72 * (newstate - 6)) / 2048, 1 / 256, 91 / 256)

			animController.Bottom:SetWidth(newstate == 6 and 0.001 or 36 * (newstate - 6))
			animController.Bottom.Mid:SetTexCoord(569 / 2048, (569 + 72 * (newstate - 6)) / 2048, 92 / 256, 138 / 256)
		end

		-- These frames are used as anchors/parents for secure/protected frames
		local top = CreateFrame("Frame", "$parentTop", barController, "SecureHandlerBaseTemplate")
		top:SetFrameLevel(barController:GetFrameLevel() + 1)
		top:SetPoint("BOTTOM", 0, 28 / 2)
		top:SetSize(432 / 2, 90 / 2)
		barController.Top = top
		barController:SetFrameRef("top", top)

		local bottom = CreateFrame("Frame", "$parentBottom", barController, "SecureHandlerBaseTemplate")
		bottom:SetFrameLevel(barController:GetFrameLevel() + 7)
		bottom:SetPoint("BOTTOM", 0, 0)
		bottom:SetSize(432 / 2, 46 / 2)
		barController.Bottom = bottom
		barController:SetFrameRef("bottom", bottom)

		-- These frames are used as anchors/parents for textures because I'm using C_Timer.After,
		-- so I can't resize protected frames while in combat
		animController = CreateFrame("Frame", nil, UIParent)
		animController:SetFrameLevel(barController:GetFrameLevel())
		animController:SetAllPoints(barController)

		top = CreateFrame("Frame", nil, animController)
		top:SetFrameLevel(animController:GetFrameLevel() + 1)
		top:SetPoint("BOTTOM", 0, 28 / 2)
		top:SetSize(432 / 2, 90 / 2)
		animController.Top = top

		local texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(1 / 2048, 233 / 2048, 1 / 256, 91 / 256)
		texture:SetPoint("BOTTOMRIGHT", top, "BOTTOMLEFT", 0, 0)
		texture:SetSize(232 / 2, 90 / 2)
		top.Left = texture

		texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(233 / 2048, 665 / 2048, 1 / 256, 91 / 256)
		texture:SetAllPoints()
		top.Mid = texture

		texture = top:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(665 / 2048, 897 / 2048, 1 / 256, 91 / 256)
		texture:SetPoint("BOTTOMLEFT", top, "BOTTOMRIGHT", 0, 0)
		texture:SetSize(232 / 2, 90 / 2)
		top.Right = texture

		bottom = CreateFrame("Frame", nil, animController)
		bottom:SetFrameLevel(animController:GetFrameLevel() + 7)
		bottom:SetPoint("BOTTOM", 0, 0)
		bottom:SetSize(432 / 2, 46 / 2)
		animController.Bottom = bottom

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(1 / 2048, 569 / 2048, 92 / 256, 138 / 256)
		texture:SetPoint("BOTTOMRIGHT", bottom, "BOTTOMLEFT", 0, 0)
		texture:SetSize(568 / 2, 46 / 2)
		bottom.Left = texture

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(569 / 2048, 1001 / 2048, 92 / 256, 138 / 256)
		texture:SetAllPoints()
		bottom.Mid = texture

		texture = bottom:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		texture:SetTexCoord(1001 / 2048, 1569 / 2048, 92 / 256, 138 / 256)
		texture:SetPoint("BOTTOMLEFT", bottom, "BOTTOMRIGHT", 0, 0)
		texture:SetSize(568 / 2, 46 / 2)
		bottom.Right = texture

		texture = bottom:CreateTexture(nil, "ARTWORK", nil, -1)
		texture:SetTexture(ENDCAPS[1][E.PLAYER_FACTION])
		texture:SetTexCoord(1 / 256, 189 / 256, 1 / 128, 125 / 128)
		texture:SetPoint("BOTTOMRIGHT", bottom, "BOTTOMLEFT", -92, 14)
		texture:SetSize(188 / 2, 124 / 2)
		animController.LeftCap = texture

		texture = bottom:CreateTexture(nil, "ARTWORK", nil, -1)
		texture:SetTexture(ENDCAPS[2][E.PLAYER_FACTION])
		texture:SetTexCoord(189 / 256, 1 / 256, 1 / 128, 125 / 128)
		texture:SetPoint("BOTTOMLEFT", bottom, "BOTTOMRIGHT", 92, 14)
		texture:SetSize(188 / 2, 124 / 2)
		animController.RightCap = texture

		local ag = animController:CreateAnimationGroup()
		ag:SetScript("OnPlay", function()
			local newstate = barController:GetAttribute("numbuttons")

			for _, widget in next, WIDGETS do
				if widget.frame then
					widget.frame:SetAlpha(0)

					if widget.children then
						for _, child in next, widget.children do
							E:FadeOut(_G[child], nil, nil, nil, _G[child]:GetAlpha())
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

			C_Timer.After(0.4, function()
				animController.Top:SetWidth(newstate == 6 and 0.001 or 36 * (newstate - 6))
				animController.Top.Mid:SetTexCoord(233 / 2048, (233 + 72 * (newstate - 6)) / 2048, 1 / 256, 91 / 256)

				animController.Bottom:SetWidth(newstate == 6 and 0.001 or 36 * (newstate - 6))
				animController.Bottom.Mid:SetTexCoord(569 / 2048, (569 + 72 * (newstate - 6)) / 2048, 92 / 256, 138 / 256)
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
							child = _G[child]
							if child:IsShown() then
								E:FadeIn(child, nil, nil, nil, true)
							else
								child:SetAlpha(1)
							end
						end
					end
				end
			end
		end)
		barController.Shuffle = ag

		local anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Top")
		anim:SetOrder(1)
		anim:SetOffset(0, -55)
		anim:SetStartDelay(0.02)
		anim:SetDuration(0.15)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("LeftCap")
		anim:SetOrder(2)
		anim:SetOffset(0, -76)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("RightCap")
		anim:SetOrder(2)
		anim:SetOffset(0, -76)
		anim:SetStartDelay(0.05)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bottom")
		anim:SetOrder(3)
		anim:SetOffset(0, -23)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bottom")
		anim:SetOrder(4)
		anim:SetOffset(0, 23)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("LeftCap")
		anim:SetOrder(5)
		anim:SetOffset(0, 76)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("RightCap")
		anim:SetOrder(5)
		anim:SetOffset(0, 76)
		anim:SetStartDelay(0.05)
		anim:SetDuration(0.1)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Top")
		anim:SetOrder(6)
		anim:SetOffset(0, 55)
		anim:SetDuration(0.15)

		self:UpdateEndcaps()

		isInit = true
	end
end

function MODULE:FinalizeActionBarController()
	if isInit and not isFinilized then
		-- "_childupdate-numbuttons" is executed in barController's environment
		for i = 1, 12 do
			barController:SetFrameRef("button" .. i, _G["LSActionBar1Button" .. i])
		end

		barController:Execute([[
			top = self:GetFrameRef("top")
			bottom = self:GetFrameRef("bottom")
			buttons = table.new()

			for i = 1, 12 do
				table.insert(buttons, self:GetFrameRef("button" .. i))
			end
		]])

		barController:SetAttribute("_onstate-mode", [[
			if newstate ~= self:GetAttribute("numbuttons") then
				self:SetAttribute("numbuttons", newstate)
				self:ChildUpdate("numbuttons", newstate)
				self:CallMethod("Update")

				top:SetWidth(newstate == 6 and 0.001 or 36 * (newstate - 6))
				bottom:SetWidth(newstate == 6 and 0.001 or 36 * (newstate - 6))
			end
		]])

		isFinilized = true

		self:UpdateMainBarMaxButtons(LSActionBar1:GetAttribute("maxbuttons"))
		self:UpdateScale(LSActionBar1:GetAttribute("scale"))
	end
end

function MODULE:UpdateEndcaps()
	local endcaps = C.db.profile.bars.endcaps
	if endcaps == "BOTH" then
		animController.LeftCap:Show()
		animController.RightCap:Show()
	elseif endcaps == "LEFT" then
		animController.LeftCap:Show()
		animController.RightCap:Hide()
	elseif endcaps == "RIGHT" then
		animController.LeftCap:Hide()
		animController.RightCap:Show()
	else
		animController.LeftCap:Hide()
		animController.RightCap:Hide()
	end
end

function MODULE:UpdateScale(scale)
	if not isFinilized then return end
	if not scale then return end

	barController:SetScale(scale)
	animController:SetScale(scale)
end

function MODULE:UpdateMainBarMaxButtons(num)
	if not isFinilized then return end
	if not num then return end

	barController:Execute(([[
		self:SetAttribute("numbuttons", %1$d)
		self:ChildUpdate("numbuttons", %1$d)
		self:CallMethod("UpdateSimple", %1$d)

		top:SetWidth(%1$d == 6 and 0.001 or 36 * (%1$d - 6))
		bottom:SetWidth(%1$d == 6 and 0.001 or 36 * (%1$d - 6))
	]]):format(num))

	RegisterStateDriver(barController, "mode", "[vehicleui][petbattle][overridebar][possessbar] 6; " .. num)
end
