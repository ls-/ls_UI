local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local m_abs = _G.math.abs
local next = _G.next
local s_match = _G.string.match
local s_split = _G.string.split
local type = _G.type

-- Blizz
local GetTime = _G.GetTime

----------------
-- STATUS BAR --
----------------

do
	local function HandleStatusBar(bar, isCascade)
		local children = {bar:GetChildren()}
		local regions = {bar:GetRegions()}
		local sbt = bar.GetStatusBarTexture and bar:GetStatusBarTexture()
		local bg, text, tbg, ttext, tsbt, rbar

		for _, region in next, regions do
			if region:IsObjectType("Texture") then
				local texture = region:GetTexture()
				local layer = region:GetDrawLayer()

				if layer == "BACKGROUND" then
					if texture and s_match(texture, "[Cc][Oo][Ll][Oo][Rr]") then
						bg = region
					elseif texture and s_match(texture, "[Bb][Aa][Cc][Kk][Gg][Rr][Oo][Uu][Nn][Dd]") then
						bg = region
					else
						E:ForceHide(region)
					end
				else
					if region ~= sbt then
						E:ForceHide(region)
					end
				end
			elseif region:IsObjectType("FontString") then
				text = region
			end
		end

		for _, child in next, children do
			if child:IsObjectType("StatusBar") then
				tbg, ttext, tsbt = HandleStatusBar(child, true)
			end
		end

		sbt = tsbt or sbt
		bg = tbg or bg
		text = ttext or text
		rbar = sbt:GetParent()

		if not isCascade then
			bar.ignoreFramePositionManager = true
			bar:SetSize(168, 12)

			if rbar ~= bar then
				rbar:SetAllPoints()
			end

			if not bg then
				bg = bar:CreateTexture(nil, "BACKGROUND")
			end

			bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
			bg:SetAllPoints()
			bar.Bg = bg

			if not text then
				text = bar:CreateFontString(nil, "ARTWORK", "LS12Font_Shadow")
				text:SetWordWrap(false)
				text:SetJustifyV("MIDDLE")
			else
				text:SetFontObject("LS12Font_Shadow")
				text:SetWordWrap(false)
				text:SetJustifyV("MIDDLE")
			end

			text:SetDrawLayer("ARTWORK")
			text:ClearAllPoints()
			text:SetPoint("TOPLEFT", 1, 0)
			text:SetPoint("BOTTOMRIGHT", -1, 0)
			bar.Text = text

			sbt:SetTexture("Interface\\BUTTONS\\WHITE8X8")
			bar.Texture = sbt

			bar.handled = true

			return bar
		else
			return bg, text, sbt
		end
	end

	local function CreateStatusBar(parent, name, orientation)
		local bar = _G.CreateFrame("StatusBar", name, parent)
		bar:SetOrientation(orientation)
		bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")

		local bg = bar:CreateTexture(nil, "BACKGROUND")
		bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
		bg:SetAllPoints()
		bar.Bg = bg

		local text = bar:CreateFontString("$parentText", "ARTWORK", "LS12Font_Shadow")
		text:SetWordWrap(false)
		bar.Text = text

		bar.handled = true

		return bar
	end

	local function Hide(self)
		for i = 1, 4 do
			self[i]:Hide()
		end
	end

	local function Show(self)
		for i = 1, 4 do
			self[i]:Show()
		end
	end

	-- flags:
	-- "HORIZONTAL-L", "HORIZONTAL-M", "HORIZONTAL-GLASS"
	-- "VERTICAL-L", "VERTICAL-M", "VERTICAL-GLASS"
	-- "NONE"
	local function SetStatusBarSkin(object, flag)
		P.argcheck(1, object, "table")
		P.argcheck(2, flag, "string")

		local s, v = s_split("-", flag)

		object.Tube = object.Tube or {
			[1] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- left/top
			[2] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- mid
			[3] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- right/bottom
			[4] = object.Glass or object:CreateTexture(nil, "ARTWORK", nil, 6), -- glass
			Hide = Hide,
			Show = Show,
		}

		if s == "HORIZONTAL" then
			local glass = object.Tube[4]
			glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal")
			glass:SetTexCoord(0 / 128, 128 / 128, 1 / 256, 25 / 256)
			glass:SetAllPoints()

			if v == "GLASS" then
				object.Tube[1]:SetTexture(nil)
				object.Tube[2]:SetTexture(nil)
				object.Tube[3]:SetTexture(nil)
			elseif v == "M" or v == "L" then
				local left = object.Tube[1]
				left:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal")
				left:ClearAllPoints()
				left:SetPoint("RIGHT", object, "LEFT", 10 / 2, 0)

				local right = object.Tube[3]
				right:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal")
				right:ClearAllPoints()
				right:SetPoint("LEFT", object, "RIGHT", -10 / 2, 0)

				local mid = object.Tube[2]
				mid:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-horizontal", true)
				mid:SetHorizTile(true)
				mid:ClearAllPoints()
				mid:SetPoint("TOPLEFT", left, "TOPRIGHT")
				mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")

				if v == "M" then
					left:SetTexCoord(1 / 128, 29 / 128, 108 / 256, 144 / 256)
					left:SetSize(14.0, 18.0)

					right:SetTexCoord(30 / 128, 58 / 128, 108 / 256, 144 / 256)
					right:SetSize(14.0, 18.0)

					mid:SetTexCoord(0 / 128, 128 / 128, 26 / 256, 62 / 256)
				elseif v == "L" then
					left:SetTexCoord(59 / 128, 89 / 128, 108 / 256, 152 / 256)
					left:SetSize(15.0, 22.0)

					right:SetTexCoord(90 / 128, 120 / 128, 108 / 256, 152 / 256)
					right:SetSize(15.0, 22.0)

					mid:SetTexCoord(0 / 128, 128 / 128, 63 / 256, 107 / 256)
				end
			else
				P.print("Invalid flag:", flag)
			end
		elseif s == "VERTICAL" then
			local glass = object.Tube[4]
			glass:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-vertical")
			glass:SetTexCoord(1 / 256, 25 / 256, 0 / 128, 128 / 128)
			glass:SetAllPoints()

			if v == "GLASS" then
				object.Tube[1]:SetTexture(nil)
				object.Tube[2]:SetTexture(nil)
				object.Tube[3]:SetTexture(nil)
			elseif v == "M" or v == "L" then
				local top = object.Tube[1]
				top:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-vertical")
				top:ClearAllPoints()
				top:SetPoint("BOTTOM", object, "TOP", 0, -10 / 2)

				local bottom = object.Tube[3]
				bottom:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-vertical")
				bottom:ClearAllPoints()
				bottom:SetPoint("TOP", object, "BOTTOM", 0, 10 / 2)

				local mid = object.Tube[2]
				mid:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar-vertical", true)
				mid:SetVertTile(true)
				mid:ClearAllPoints()
				mid:SetPoint("TOPLEFT", top, "BOTTOMLEFT")
				mid:SetPoint("BOTTOMRIGHT", bottom, "TOPRIGHT")

				if v == "M" then
					top:SetTexCoord(108 / 256, 144 / 256, 1 / 128, 29 / 128)
					top:SetSize(36 / 2, 28 / 2)

					bottom:SetTexCoord(108 / 256, 144 / 256, 30 / 128, 58 / 128)
					bottom:SetSize(36 / 2, 28 / 2)

					mid:SetTexCoord(26 / 256, 62 / 256, 0 / 128, 128 / 128)
				elseif v == "L" then
					top:SetTexCoord(108 / 256, 152 / 256, 58 / 128, 88 / 128)
					top:SetSize(44 / 2, 30 / 2)

					bottom:SetTexCoord(108 / 256, 152 / 256, 89 / 128, 119 / 128)
					bottom:SetSize(44 / 2, 30 / 2)

					mid:SetTexCoord(63 / 256, 107 / 256, 0 / 128, 128 / 128)
				end
			else
				P.print("Invalid flag:", flag)
			end
		elseif s == "NONE" then
			object.Tube[1]:SetTexture(nil)
			object.Tube[2]:SetTexture(nil)
			object.Tube[3]:SetTexture(nil)
			object.Tube[4]:SetTexture(nil)
		else
			P.print("Invalid flag:", flag)
		end
	end

	local diffThreshold = 0.1

	local function AttachGainToVerticalBar(object, prev, max)
		local offset = object:GetHeight() * (1 - E:Clamp(prev / max))

		object.Gain:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, -offset)
		object.Gain:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, -offset)
	end

	local function AttachLossToVerticalBar(object, prev, max)
		local offset = object:GetHeight() * (1 - E:Clamp(prev / max))

		object.Loss:SetPoint("TOPLEFT", object, "TOPLEFT", 0, -offset)
		object.Loss:SetPoint("TOPRIGHT", object, "TOPRIGHT", 0, -offset)
	end

	local function AttachGainToHorizontalBar(object, prev, max)
		local offset = object:GetWidth() * (1 - E:Clamp(prev / max))

		object.Gain:SetPoint("TOPLEFT", object, "TOPRIGHT", -offset, 0)
		object.Gain:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -offset, 0)
	end

	local function AttachLossToHorizontalBar(object, prev, max)
		local offset = object:GetWidth() * (1 - E:Clamp(prev / max))

		object.Loss:SetPoint("TOPRIGHT", object, "TOPRIGHT", -offset, 0)
		object.Loss:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -offset, 0)
	end

	local function UpdateGainLoss(object, cur, max, condition)
		if max ~= 0 and (condition == nil or condition)then
			local prev = object._prev or 0
			local diff = cur - prev

			if m_abs(diff) / max < diffThreshold then
				diff = 0
			end

			if diff > 0 then
				if object.Gain:GetAlpha() == 0 then
					object.Gain:SetAlpha(1)

					if object:GetOrientation() == "VERTICAL" then
						AttachGainToVerticalBar(object, prev, max)
					else
						AttachGainToHorizontalBar(object, prev, max)
					end

					object.Gain.FadeOut:Play()
				end
			elseif diff < 0 then
				object.Gain.FadeOut:Stop()
				object.Gain:SetAlpha(0)

				if object.Loss:GetAlpha() == 0 then
					object.Loss:SetAlpha(1)

					if object:GetOrientation() == "VERTICAL" then
						AttachLossToVerticalBar(object, prev, max)
					else
						AttachLossToHorizontalBar(object, prev, max)
					end

					object.Loss.FadeOut:Play()
				end
			end
		else
			object.Gain.FadeOut:Stop()
			object.Gain:SetAlpha(0)

			object.Loss.FadeOut:Stop()
			object.Loss:SetAlpha(0)
		end

		object._prev = cur
	end

	local function CreateGainLossIndicators(object)
		local gainTexture = object:CreateTexture(nil, "ARTWORK", nil, 1)
		gainTexture:SetColorTexture(M.COLORS.LIGHT_GREEN:GetRGB())
		gainTexture:SetAlpha(0)
		object.Gain = gainTexture

		local lossTexture = object:CreateTexture(nil, "BACKGROUND")
		lossTexture:SetColorTexture(M.COLORS.DARK_RED:GetRGB())
		lossTexture:SetAlpha(0)
		object.Loss = lossTexture

		local ag = gainTexture:CreateAnimationGroup()
		ag:SetToFinalAlpha(true)
		gainTexture.FadeOut = ag

		local anim1 = ag:CreateAnimation("Alpha")
		anim1:SetOrder(1)
		anim1:SetFromAlpha(1)
		anim1:SetToAlpha(0)
		anim1:SetStartDelay(0.6)
		anim1:SetDuration(0.2)

		ag = lossTexture:CreateAnimationGroup()
		ag:SetToFinalAlpha(true)
		lossTexture.FadeOut = ag

		anim1 = ag:CreateAnimation("Alpha")
		anim1:SetOrder(1)
		anim1:SetFromAlpha(1)
		anim1:SetToAlpha(0)
		anim1:SetStartDelay(0.6)
		anim1:SetDuration(0.2)

		object.UpdateGainLoss = UpdateGainLoss
	end

	local function ReanchorGainLossIndicators(object, orientation)
		if orientation == "HORIZONTAL" then
			object.Gain:ClearAllPoints()
			object.Gain:SetPoint("TOPRIGHT", object:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
			object.Gain:SetPoint("BOTTOMRIGHT", object:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

			object.Loss:ClearAllPoints()
			object.Loss:SetPoint("TOPLEFT", object:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
			object.Loss:SetPoint("BOTTOMLEFT", object:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		else
			object.Gain:ClearAllPoints()
			object.Gain:SetPoint("TOPLEFT", object:GetStatusBarTexture(), "TOPLEFT", 0, 0)
			object.Gain:SetPoint("TOPRIGHT", object:GetStatusBarTexture(), "TOPRIGHT", 0, 0)

			object.Loss:ClearAllPoints()
			object.Loss:SetPoint("BOTTOMLEFT", object:GetStatusBarTexture(), "TOPLEFT", 0, 0)
			object.Loss:SetPoint("BOTTOMRIGHT", object:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		end
	end

	function E:HandleStatusBar(...)
		return HandleStatusBar(...)
	end

	function E:CreateStatusBar(...)
		return CreateStatusBar(...)
	end

	function E:SetStatusBarSkin(...)
		SetStatusBarSkin(...)
	end

	function E:CreateGainLossIndicators(...)
		CreateGainLossIndicators(...)
	end

	function E:ReanchorGainLossIndicators(...)
		ReanchorGainLossIndicators(...)
	end
end

--------------
-- COOLDOWN --
--------------

do
	local THRESHOLD = 1.5

	local handled = {}

	local function Timer_OnUpdate(self, elapsed)
		if not self.Timer:IsShown() then return end

		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed > 0.1 then
			local timer = self.Timer

			local time, color, abbr = E:TimeFormat(timer.duration + timer.start - GetTime(), true)

			if time >= 0.1 then
				timer:SetFormattedText("%s"..abbr.."|r", color, time)
			else
				timer:SetText("")
				timer:Hide()
			end

			self.elapsed = 0
		end
	end

	local function SetCooldownHook(self, start, duration)
		local timer = self.Timer

		if start > 0 and duration > THRESHOLD then
			timer.start = start
			timer.duration = duration
			timer:Show()

			self:SetScript("OnUpdate", Timer_OnUpdate)
		else
			timer:Hide()

			self:SetScript("OnUpdate", nil)
		end
	end

	local function SetTimerTextHeight(self, height)
		self.Timer:SetFontObject("LS"..height.."Font_Outline")
	end

	local function HandleCooldown(cooldown, textSize)
		if E.OMNICC or handled[cooldown] then
			return
		end

		cooldown:SetDrawEdge(false)
		cooldown:SetHideCountdownNumbers(true)
		cooldown:GetRegions():SetAlpha(0) -- Default CD timer is region #1

		local text_parent = _G.CreateFrame("Frame", nil, cooldown)
		text_parent:SetAllPoints()

		local timer = text_parent:CreateFontString(nil, "ARTWORK", "LS"..textSize.."Font_Outline")
		timer:SetPoint("TOPLEFT", -4, 0)
		timer:SetPoint("BOTTOMRIGHT", 4, 0)
		timer:SetWordWrap(false)
		timer:SetJustifyH("CENTER")
		timer:SetJustifyV("MIDDLE")

		hooksecurefunc(cooldown, "SetCooldown", SetCooldownHook)

		cooldown.Timer = timer
		cooldown.SetTimerTextHeight = SetTimerTextHeight

		handled[cooldown] = true

		return cooldown
	end

	local function CreateCooldown(parent, textSize)
		local cooldown = _G.CreateFrame("Cooldown", nil, parent, "CooldownFrameTemplate")
		cooldown:SetPoint("TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

		HandleCooldown(cooldown, textSize)

		return cooldown
	end

	function E:HandleCooldown(...)
		return HandleCooldown(...)
	end

	function E:CreateCooldown(...)
		return CreateCooldown(...)
	end
end

------------
-- BORDER --
------------

-- Based on code from oUF_Phanx by Phanx <addons@phanx.net>

do
	local sections = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}

	local function SetBorderColor(self, r, g, b, a)
		local t = self.borderTextures
		if not t then return end

		for _, tex in next, t do
			tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
		end
	end

	local function GetBorderColor(self)
		return self.borderTextures and self.borderTextures.TOPLEFT:GetVertexColor()
	end

	local function ShowBorder(self)
		local t = self.borderTextures
		if not t then return end

		for _, tex in next, t do
			tex:Show()
		end
	end

	local function HideBorder(self)
		local t = self.borderTextures
		if not t then return end

		for _, tex in next, t do
			tex:Hide()
		end
	end

	local function CreateBorder(object, isThick)
		local t = {}
		local thickness = 16
		local texture, offset

		if isThick then
			texture = "Interface\\AddOns\\ls_UI\\media\\border-thick-"
			offset = 6
		else
			texture = "Interface\\AddOns\\ls_UI\\media\\border-thin-"
			offset = 4
		end

		for i = 1, #sections do
			local x = object:CreateTexture(nil, "OVERLAY", nil, 1)

			if i > 4 then
				x:SetTexture(texture..sections[i], true)
			else
				x:SetTexture(texture..sections[i])
			end

			t[sections[i]] = x
		end

		t.TOPLEFT:SetSize(thickness, thickness)
		t.TOPLEFT:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", offset, -offset)

		t.TOPRIGHT:SetSize(thickness, thickness)
		t.TOPRIGHT:SetPoint("BOTTOMLEFT", object, "TOPRIGHT", -offset, -offset)

		t.BOTTOMLEFT:SetSize(thickness, thickness)
		t.BOTTOMLEFT:SetPoint("TOPRIGHT", object, "BOTTOMLEFT", offset, offset)

		t.BOTTOMRIGHT:SetSize(thickness, thickness)
		t.BOTTOMRIGHT:SetPoint("TOPLEFT", object, "BOTTOMRIGHT", -offset, offset)

		t.TOP:SetHeight(thickness)
		t.TOP:SetHorizTile(true)
		t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT", 0, 0)
		t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT", 0, 0)

		t.BOTTOM:SetHeight(thickness)
		t.BOTTOM:SetHorizTile(true)
		t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
		t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

		t.LEFT:SetWidth(thickness)
		t.LEFT:SetVertTile(true)
		t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT", 0, 0)
		t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT", 0, 0)

		t.RIGHT:SetWidth(thickness)
		t.RIGHT:SetVertTile(true)
		t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
		t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

		object.borderTextures = t
		object.SetBorderColor = SetBorderColor
		object.GetBorderColor = GetBorderColor
		object.ShowBorder = ShowBorder
		object.HideBorder = HideBorder
	end

	function E:CreateBorder(object, isThick)
		if type(object) ~= "table" or not object.CreateTexture or object.borderTextures then
			return
		end

		CreateBorder(object, isThick)
	end

	local function SetGlowColor(self, r, g, b, a)
		local t = self._t
		if not t then return end

		for _, tex in next, t do
			tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
		end
	end

	local function GetGlowColor(self)
		return self._t and self._t.TOPLEFT:GetVertexColor()
	end

	local function ShowGlow(self)
		local t = self._t
		if not t then return end

		for _, tex in next, t do
			tex:Show()
		end
	end

	local function HideGlow(self)
		local t = self._t
		if not t then return end

		for _, tex in next, t do
			tex:Hide()
		end
	end

	local function CreateBorderGlow(object, isThick)
		-- PH
		isThick = true

		local t = {}
		local thickness = 16
		local texture, offset

		if isThick then
			texture = "Interface\\AddOns\\ls_UI\\media\\border-thick-glow-"
			offset = 6
		else
			texture = "Interface\\AddOns\\ls_UI\\media\\border-thin-glow-"
			offset = 4
		end

		for i = 1, #sections do
			local x = object:CreateTexture(nil, "BACKGROUND", nil, -7)

			if i > 4 then
				x:SetTexture(texture..sections[i], true)
			else
				x:SetTexture(texture..sections[i])
			end

			t[sections[i]] = x
		end

		t.TOPLEFT:SetSize(thickness, thickness)
		t.TOPLEFT:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", offset, -offset)

		t.TOPRIGHT:SetSize(thickness, thickness)
		t.TOPRIGHT:SetPoint("BOTTOMLEFT", object, "TOPRIGHT", -offset, -offset)

		t.BOTTOMLEFT:SetSize(thickness, thickness)
		t.BOTTOMLEFT:SetPoint("TOPRIGHT", object, "BOTTOMLEFT", offset, offset)

		t.BOTTOMRIGHT:SetSize(thickness, thickness)
		t.BOTTOMRIGHT:SetPoint("TOPLEFT", object, "BOTTOMRIGHT", -offset, offset)

		t.TOP:SetHeight(thickness)
		t.TOP:SetHorizTile(true)
		t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT", 0, 0)
		t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT", 0, 0)

		t.BOTTOM:SetHeight(thickness)
		t.BOTTOM:SetHorizTile(true)
		t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
		t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

		t.LEFT:SetWidth(thickness)
		t.LEFT:SetVertTile(true)
		t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT", 0, 0)
		t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT", 0, 0)

		t.RIGHT:SetWidth(thickness)
		t.RIGHT:SetVertTile(true)
		t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
		t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

		return {
			_t = t,
			SetVertexColor = SetGlowColor,
			GetVertexColor = GetGlowColor,
			Show = ShowGlow,
			Hide = HideGlow,
			IsObjectType = E.NOOP,
		}
	end

	function E:CreateBorderGlow(object, isThick)
		if type(object) ~= "table" or not object.CreateTexture then
			return
		end

		return CreateBorderGlow(object, isThick)
	end
end
