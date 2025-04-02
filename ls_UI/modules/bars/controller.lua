local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
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

local NUM_STATIC_BUTTONS = 6
local NUM_PER_SEGMENT = 6

local ANIM_SPEED_MULT = 0.7

local ENDCAPS = {
	[1] = {
		["ALLIANCE"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-gryphon",
		["HORDE"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-wyvern",
		["NEUTRAL"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-wyvern",
	},
	[2] = {
		["ALLIANCE"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-gryphon",
		["HORDE"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-wyvern",
		["NEUTRAL"] = "Interface\\AddOns\\ls_UI\\assets\\endcap-gryphon",
	},
}

local WIDGETS = {
	["ACTION_BAR"] = {
		frame_level_offset = 2,
		point = {"BOTTOMLEFT", "LSActionBarControllerBottom", "BOTTOMLEFT", -108, 15}, -- 36 * 3
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
				if message > 12 then
					message = 12
				end

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
		on_play = function(frame, totalButtons)
			frame:UpdateSize(756 / 2 + 36 * (totalButtons - NUM_STATIC_BUTTONS), 12)
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

local function adjustTopTextures(totalButtons)
	local numButtons = totalButtons - NUM_STATIC_BUTTONS
	local numFull = numButtons / NUM_PER_SEGMENT
	local numActive = numFull + 0.9

	animController.Top:SetWidth(totalButtons == 6 and 0.001 or 36 * numButtons)

	for i = 1, 3 do
		if i > numFull then
			if i > numActive then
				animController.Top["Mid" .. i]:SetWidth(0.0001)
			else
				animController.Top["Mid" .. i]:SetWidth(36 * (numButtons % NUM_PER_SEGMENT))
				animController.Top["Mid" .. i]:SetTexCoord(233 / 2048, (233 + 72 * (numButtons % NUM_PER_SEGMENT)) / 2048, 1 / 256, 91 / 256)
			end
		else
			animController.Top["Mid" .. i]:SetWidth(36 * NUM_PER_SEGMENT)
			animController.Top["Mid" .. i]:SetTexCoord(233 / 2048, (233 + 72 * NUM_PER_SEGMENT) / 2048, 1 / 256, 91 / 256)
		end
	end
end

local function adjustBottomTextures(totalButtons)
	local numButtons = totalButtons - NUM_STATIC_BUTTONS
	local numFull = numButtons / NUM_PER_SEGMENT
	local numActive = numFull + 0.9

	animController.Bottom:SetWidth(totalButtons == 6 and 0.001 or 36 * numButtons)

	for i = 1, 3 do
		if i > numFull then
			if i > numActive then
				animController.Bottom["Mid" .. i]:SetWidth(0.0001)
			else
				animController.Bottom["Mid" .. i]:SetWidth(36 * (numButtons % NUM_PER_SEGMENT))
				animController.Bottom["Mid" .. i]:SetTexCoord(569 / 2048, (569 + 72 * (numButtons % NUM_PER_SEGMENT)) / 2048, 92 / 256, 138 / 256)
			end
		else
			animController.Bottom["Mid" .. i]:SetWidth(36 * NUM_PER_SEGMENT)
			animController.Bottom["Mid" .. i]:SetTexCoord(569 / 2048, (569 + 72 * NUM_PER_SEGMENT) / 2048, 92 / 256, 138 / 256)
		end
	end
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
		barController.UpdateInsecure = function(_, totalButtons)
			for _, widget in next, WIDGETS do
				if widget.frame and widget.on_play then
					widget.on_play(widget.frame, totalButtons)
				end
			end

			adjustTopTextures(totalButtons)
			adjustBottomTextures(totalButtons)
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

		local topInsecure = CreateFrame("Frame", nil, animController)
		topInsecure:SetFrameLevel(animController:GetFrameLevel() + 1)
		topInsecure:SetPoint("BOTTOM", 0, 28 / 2)
		topInsecure:SetSize(432 / 2, 90 / 2)
		animController.Top = topInsecure

		local topLeft = topInsecure:CreateTexture(nil, "ARTWORK")
		topLeft:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		topLeft:SetTexCoord(1 / 2048, 233 / 2048, 1 / 256, 91 / 256)
		topLeft:SetPoint("BOTTOMRIGHT", topInsecure, "BOTTOMLEFT", 0, 0)
		topLeft:SetSize(232 / 2, 90 / 2)
		topInsecure.Left = topLeft

		local topMidLeft = topInsecure:CreateTexture(nil, "ARTWORK")
		topMidLeft:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		topMidLeft:SetTexCoord(233 / 2048, 665 / 2048, 1 / 256, 91 / 256)
		topMidLeft:SetPoint("BOTTOMLEFT", topInsecure, "BOTTOMLEFT", 0, 0)
		topMidLeft:SetSize(0.001, 90 / 2)
		topInsecure.Mid1 = topMidLeft

		local topMidRight = topInsecure:CreateTexture(nil, "ARTWORK")
		topMidRight:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		topMidRight:SetTexCoord(233 / 2048, 665 / 2048, 1 / 256, 91 / 256)
		topMidRight:SetPoint("BOTTOMRIGHT", topInsecure, "BOTTOMRIGHT", 0, 0)
		topMidRight:SetSize(0.001, 90 / 2)
		topInsecure.Mid3 = topMidRight

		local topMidCenter = topInsecure:CreateTexture(nil, "ARTWORK")
		topMidCenter:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		topMidCenter:SetTexCoord(233 / 2048, 665 / 2048, 1 / 256, 91 / 256)
		topMidCenter:SetPoint("BOTTOMLEFT", topMidLeft, "BOTTOMRIGHT", 0, 0)
		topMidCenter:SetPoint("BOTTOMRIGHT", topMidRight, "BOTTOMLEFT", 0, 0)
		topMidCenter:SetSize(0.001, 90 / 2)
		topInsecure.Mid2 = topMidCenter

		local topRight = topInsecure:CreateTexture(nil, "ARTWORK")
		topRight:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		topRight:SetTexCoord(665 / 2048, 897 / 2048, 1 / 256, 91 / 256)
		topRight:SetPoint("BOTTOMLEFT", topInsecure, "BOTTOMRIGHT", 0, 0)
		topRight:SetSize(232 / 2, 90 / 2)
		topInsecure.Right = topRight

		local bottomInsecure = CreateFrame("Frame", nil, animController)
		bottomInsecure:SetFrameLevel(animController:GetFrameLevel() + 7)
		bottomInsecure:SetPoint("BOTTOM", 0, 0)
		bottomInsecure:SetSize(432 / 2, 46 / 2)
		animController.Bottom = bottomInsecure

		local bottomLeft = bottomInsecure:CreateTexture(nil, "ARTWORK")
		bottomLeft:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		bottomLeft:SetTexCoord(1 / 2048, 569 / 2048, 92 / 256, 138 / 256)
		bottomLeft:SetPoint("BOTTOMRIGHT", bottomInsecure, "BOTTOMLEFT", 0, 0)
		bottomLeft:SetSize(568 / 2, 46 / 2)
		bottomInsecure.Left = bottomLeft

		local bottomMidLeft = bottomInsecure:CreateTexture(nil, "ARTWORK")
		bottomMidLeft:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		bottomMidLeft:SetTexCoord(569 / 2048, 1001 / 2048, 92 / 256, 138 / 256)
		bottomMidLeft:SetPoint("BOTTOMLEFT", bottomInsecure, "BOTTOMLEFT", 0, 0)
		bottomMidLeft:SetSize(0.001, 46 / 2)
		bottomInsecure.Mid1 = bottomMidLeft

		local bottomMidRight = bottomInsecure:CreateTexture(nil, "ARTWORK")
		bottomMidRight:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		bottomMidRight:SetTexCoord(569 / 2048, 1001 / 2048, 92 / 256, 138 / 256)
		bottomMidRight:SetPoint("BOTTOMRIGHT", bottomInsecure, "BOTTOMRIGHT", 0, 0)
		bottomMidRight:SetSize(0.001, 46 / 2)
		bottomInsecure.Mid3 = bottomMidRight

		local bottomMidCenter = bottomInsecure:CreateTexture(nil, "ARTWORK")
		bottomMidCenter:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		bottomMidCenter:SetTexCoord(569 / 2048, 1001 / 2048, 92 / 256, 138 / 256)
		bottomMidCenter:SetPoint("BOTTOMLEFT", bottomMidLeft, "BOTTOMRIGHT", 0, 0)
		bottomMidCenter:SetPoint("BOTTOMRIGHT", bottomMidRight, "BOTTOMLEFT", 0, 0)
		bottomMidCenter:SetSize(0.001, 46 / 2)
		bottomInsecure.Mid2 = bottomMidCenter

		local bottomRight = bottomInsecure:CreateTexture(nil, "ARTWORK")
		bottomRight:SetTexture("Interface\\AddOns\\ls_UI\\assets\\console")
		bottomRight:SetTexCoord(1001 / 2048, 1569 / 2048, 92 / 256, 138 / 256)
		bottomRight:SetPoint("BOTTOMLEFT", bottomInsecure, "BOTTOMRIGHT", 0, 0)
		bottomRight:SetSize(568 / 2, 46 / 2)
		bottomInsecure.Right = bottomRight

		local leftCap = bottomInsecure:CreateTexture(nil, "ARTWORK", nil, -1)
		leftCap:SetTexCoord(1 / 256, 189 / 256, 1 / 128, 125 / 128)
		leftCap:SetPoint("BOTTOMRIGHT", bottomInsecure, "BOTTOMLEFT", -92, 14)
		leftCap:SetSize(188 / 2, 124 / 2)
		animController.LeftCap = leftCap

		local rightCap = bottomInsecure:CreateTexture(nil, "ARTWORK", nil, -1)
		rightCap:SetTexCoord(189 / 256, 1 / 256, 1 / 128, 125 / 128)
		rightCap:SetPoint("BOTTOMLEFT", bottomInsecure, "BOTTOMRIGHT", 92, 14)
		rightCap:SetSize(188 / 2, 124 / 2)
		animController.RightCap = rightCap

		local ag = animController:CreateAnimationGroup()
		ag:SetScript("OnPlay", function()
			local newstate = barController:GetAttribute("numbuttons")

			for _, widget in next, WIDGETS do
				if widget.frame then
					widget.frame:SetAlpha(0)

					if widget.children then
						for _, child in next, widget.children do
							child = _G[child]

							if newstate == 6 then
								E:FadeOut(child, nil, nil, nil, child:GetAlpha())
							else
								child:SetAlpha(0)
							end
						end
					end
				end
			end

			C_Timer.After(0.02 * ANIM_SPEED_MULT, function()
				for _, widget in next, WIDGETS do
					if widget.frame and widget.on_play then
						widget.on_play(widget.frame, newstate)
					end
				end
			end)

			C_Timer.After(0.4 * ANIM_SPEED_MULT, function()
				adjustTopTextures(newstate)
				adjustBottomTextures(newstate)
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
		anim:SetDuration(0.15 * ANIM_SPEED_MULT)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("LeftCap")
		anim:SetOrder(2)
		anim:SetOffset(0, -76)
		anim:SetDuration(0.1 * ANIM_SPEED_MULT)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("RightCap")
		anim:SetOrder(2)
		anim:SetOffset(0, -76)
		anim:SetStartDelay(0.05)
		anim:SetDuration(0.1 * ANIM_SPEED_MULT)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bottom")
		anim:SetOrder(3)
		anim:SetOffset(0, -23)
		anim:SetDuration(0.1 * ANIM_SPEED_MULT)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Bottom")
		anim:SetOrder(4)
		anim:SetOffset(0, 23)
		anim:SetDuration(0.1 * ANIM_SPEED_MULT)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("LeftCap")
		anim:SetOrder(5)
		anim:SetOffset(0, 76)
		anim:SetDuration(0.1 * ANIM_SPEED_MULT)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("RightCap")
		anim:SetOrder(5)
		anim:SetOffset(0, 76)
		anim:SetStartDelay(0.05)
		anim:SetDuration(0.1 * ANIM_SPEED_MULT)

		anim = ag:CreateAnimation("Translation")
		anim:SetChildKey("Top")
		anim:SetOrder(6)
		anim:SetOffset(0, 55)
		anim:SetDuration(0.15 * ANIM_SPEED_MULT)

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

		self:UpdateMainBarMaxButtons(C.db.profile.bars.bar1.num)
		self:UpdateScale(C.db.profile.bars.bar1.scale)
	end
end

function MODULE:UpdateEndcaps()
	local v = C.db.profile.bars.endcaps.visibility
	if v == "BOTH" then
		animController.LeftCap:Show()
		animController.RightCap:Show()
	elseif v == "LEFT" then
		animController.LeftCap:Show()
		animController.RightCap:Hide()
	elseif v == "RIGHT" then
		animController.LeftCap:Hide()
		animController.RightCap:Show()
	else
		animController.LeftCap:Hide()
		animController.RightCap:Hide()
	end

	local t = C.db.profile.bars.endcaps.type
	if t == "ALLIANCE" or t == "HORDE" or t == "NEUTRAL" then
		animController.LeftCap:SetTexture(ENDCAPS[1][t])
		animController.RightCap:SetTexture(ENDCAPS[2][t])
	else
		animController.LeftCap:SetTexture(ENDCAPS[1][E.PLAYER_FACTION:upper()])
		animController.RightCap:SetTexture(ENDCAPS[2][E.PLAYER_FACTION:upper()])
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
		self:CallMethod("UpdateInsecure", %1$d)

		top:SetWidth(%1$d == 6 and 0.001 or 36 * (%1$d - 6))
		bottom:SetWidth(%1$d == 6 and 0.001 or 36 * (%1$d - 6))
	]]):format(num))

	RegisterStateDriver(barController, "mode", "[vehicleui][petbattle][overridebar][possessbar] 6; " .. num)
end
