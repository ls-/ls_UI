local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local next = _G.next
local s_match = _G.string.match
local s_split = _G.string.split
local hooksecurefunc = _G.hooksecurefunc
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

	local function SetStatusBarSkin_old(bar, skinType)
		local orientation, size = s_split("-", skinType or "")

		bar.Tube = bar.Tube or {
			[1] = bar:CreateTexture(nil, "ARTWORK", nil, 7), -- left
			[2] = bar:CreateTexture(nil, "ARTWORK", nil, 7), -- right
			[3] = bar:CreateTexture(nil, "ARTWORK", nil, 7), -- top
			[4] = bar:CreateTexture(nil, "ARTWORK", nil, 7), -- bottom
			[5] = bar.Gloss or bar:CreateTexture(nil, "ARTWORK", nil, 6), -- gloss
		}

		if orientation == "HORIZONTAL" then
			local leftTexture = bar.Tube[1]
			leftTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
			leftTexture:SetPoint("RIGHT", bar, "LEFT", 3, 0)

			local rightTexture = bar.Tube[2]
			rightTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
			rightTexture:SetPoint("LEFT", bar, "RIGHT", -3, 0)

			local topTexture = bar.Tube[3]
			topTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal", true)
			topTexture:SetTexCoord(0 / 64, 64 / 64, 21 / 64, 24 / 64)
			topTexture:SetHeight(3)
			topTexture:SetHorizTile(true)
			topTexture:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 0)
			topTexture:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 0)

			local bottomTexture = bar.Tube[4]
			bottomTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal", true)
			bottomTexture:SetTexCoord(0 / 64, 64 / 64, 24 / 64, 21 / 64)
			bottomTexture:SetHeight(3)
			bottomTexture:SetHorizTile(true)
			bottomTexture:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, 0)
			bottomTexture:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)

			local gloss = bar.Tube[5]
			gloss:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_horizontal")
			gloss:SetTexCoord(0 / 64, 64 / 64, 0 / 64, 20 / 64)
			gloss:SetAllPoints()

			if size == "SMALL" or size == "S" then
				leftTexture:SetTexCoord(0 / 64, 10 / 64, 25 / 64, 35 / 64)
				leftTexture:SetSize(10, 10)

				rightTexture:SetTexCoord(0 / 64, 10 / 64, 36 / 64, 46 / 64)
				rightTexture:SetSize(10, 10)
			elseif size == "M" then
				leftTexture:SetTexCoord(33 / 64, 42 / 64, 25 / 64, 41 / 64)
				leftTexture:SetSize(9, 16)

				rightTexture:SetTexCoord(43 / 64, 52 / 64, 25 / 64, 41 / 64)
				rightTexture:SetSize(9, 16)
			elseif size == "BIG" or size == "L" then
				leftTexture:SetTexCoord(11 / 64, 21 / 64, 25 / 64, 45 / 64)
				leftTexture:SetSize(10, 20)

				rightTexture:SetTexCoord(22 / 64, 32 / 64, 25 / 64, 45 / 64)
				rightTexture:SetSize(10, 20)
			end
		elseif orientation == "VERTICAL" then
			local leftTexture = bar.Tube[1]
			leftTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical", true)
			leftTexture:SetTexCoord(21 / 64, 24 / 64, 0 / 64, 64 / 64)
			leftTexture:SetWidth(3)
			leftTexture:SetVertTile(true)
			leftTexture:SetPoint("TOPRIGHT", bar, "TOPLEFT", 0, 0)
			leftTexture:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", 0, 0)

			local rightTexture = bar.Tube[2]
			rightTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical", true)
			rightTexture:SetTexCoord(24 / 64, 21 / 64, 0 / 64, 64 / 64)
			rightTexture:SetWidth(3)
			rightTexture:SetVertTile(true)
			rightTexture:SetPoint("TOPLEFT", bar, "TOPRIGHT", 0, 0)
			rightTexture:SetPoint("BOTTOMLEFT", bar, "BOTTOMRIGHT", 0, 0)

			local topTexture = bar.Tube[3]
			topTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical")
			topTexture:SetPoint("BOTTOM", bar, "TOP", 0, -3)

			local bottomTexture = bar.Tube[4]
			bottomTexture:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical")
			bottomTexture:SetPoint("TOP", bar, "BOTTOM", 0, 3)

			local gloss = bar.Tube[5]
			gloss:SetTexture("Interface\\AddOns\\ls_UI\\media\\statusbar_vertical")
			gloss:SetTexCoord(0 / 64, 20 / 64, 0 / 64, 64 / 64)
			gloss:SetAllPoints()

			if size == "S" then
				topTexture:SetTexCoord(25 / 64, 35 / 64, 0 / 64, 10 / 64)
				topTexture:SetSize(10, 10)

				bottomTexture:SetTexCoord(36 / 64, 46 / 64, 0 / 64, 10 / 64)
				bottomTexture:SetSize(10, 10)
			elseif size == "M" then
				topTexture:SetTexCoord(25 / 64, 41 / 64, 33 / 64, 42 / 64)
				topTexture:SetSize(16, 9)

				bottomTexture:SetTexCoord(25 / 64, 41 / 64, 43 / 64, 52 / 64)
				bottomTexture:SetSize(16, 9)
			elseif size == "L" then
				topTexture:SetTexCoord(25 / 64, 45 / 64, 11 / 64, 21 / 64)
				topTexture:SetSize(20, 10)

				bottomTexture:SetTexCoord(25 / 64, 45 / 64, 22 / 64, 32 / 64)
				bottomTexture:SetSize(20, 10)
			end
		elseif orientation == "NONE" then
			bar.Tube[1]:SetTexture(nil)
			bar.Tube[2]:SetTexture(nil)
			bar.Tube[3]:SetTexture(nil)
			bar.Tube[4]:SetTexture(nil)
			bar.Tube[5]:SetTexture(nil)
		end
	end

	function E:HandleStatusBar(...)
		return HandleStatusBar(...)
	end

	function E:CreateStatusBar(...)
		return CreateStatusBar(...)
	end

	function E:SetStatusBarSkin(object, flag)
		if flag == "HORIZONTAL-S" or flag == "HORIZONTAL-SMALL" then
			SetStatusBarSkin_old(object, flag)
		else
			SetStatusBarSkin(object, flag)
		end
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

	local function CrateBorder(object, isThick)
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
			x:SetTexture(texture..sections[i], true)
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
	end

	function E:CreateBorder(object, isThick)
		if type(object) ~= "table" or not object.CreateTexture or object.borderTextures then
			return
		end

		CrateBorder(object, isThick)
	end
end
