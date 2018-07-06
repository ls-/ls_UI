local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local m_max = _G.math.max
local m_min = _G.math.min
local next = _G.next
local s_match = _G.string.match
local s_split = _G.string.split
local unpack = _G.unpack

-- Blizz
local FrameDeltaLerp = _G.FrameDeltaLerp

-- Mine
function E:HandleStatusBar(bar, isRecursive)
	if bar.handled then return end

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
			tbg, ttext, tsbt = self:HandleStatusBar(child, true)
		end
	end

	sbt = tsbt or sbt
	bg = tbg or bg
	text = ttext or text
	rbar = sbt:GetParent()

	if not isRecursive then
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
			text = bar:CreateFontString(nil, "ARTWORK", "LSFont12_Shadow")
			text:SetWordWrap(false)
			text:SetJustifyV("MIDDLE")
		else
			text:SetFontObject("LSFont12_Shadow")
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

function E:CreateStatusBar(parent, name, orientation)
	local bar = CreateFrame("StatusBar", name, parent)
	bar:SetOrientation(orientation)
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetColorTexture(M.COLORS.DARK_GRAY:GetRGB())
	bg:SetAllPoints()
	bar.Bg = bg

	local text = bar:CreateFontString("$parentText", "ARTWORK", "LSFont12_Shadow")
	text:SetWordWrap(false)
	bar.Text = text

	bar.handled = true

	return bar
end

do
	local LAYOUT = {
		HORIZONTAL = {
			["8"] = {
				[1] = {
					coords = {1 / 128, 31 / 128, 14 / 512, 50 / 512},
					size = {30 / 2, 36 / 2},
				},
				[2] = {
					coords = {32 / 128, 62 / 128, 14 / 512, 50 / 512},
					size = {30 / 2, 36 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 0, 0.025390625, 1, 0.001953125, 1, 0.025390625},
					size = {0, 12 / 2},
				},
				[4] = {
					coords = {0, 0.025390625, 0, 0.001953125, 1, 0.025390625, 1, 0.001953125},
					size = {0, 12 / 2},
				},
			},
			["12"] = {
				[1] = {
					coords = {1 / 128, 31 / 128, 51 / 512, 95 / 512},
					size = {30 / 2, 44 / 2},
				},
				[2] = {
					coords = {32 / 128, 62 / 128, 51 / 512, 95 / 512},
					size = {30 / 2, 44 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 0, 0.025390625, 1, 0.001953125, 1, 0.025390625},
					size = {0, 12 / 2},
				},
				[4] = {
					coords = {0, 0.025390625, 0, 0.001953125, 1, 0.025390625, 1, 0.001953125},
					size = {0, 12 / 2},
				},
			},
			["16"] = {
				[1] = {
					coords = {1 / 128, 31 / 128, 96 / 512, 148 / 512},
					size = {30 / 2, 52 / 2},
				},
				[2] = {
					coords = {32 / 128, 62 / 128, 96 / 512, 148 / 512},
					size = {30 / 2, 52 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 0, 0.025390625, 1, 0.001953125, 1, 0.025390625},
					size = {0, 12 / 2},
				},
				[4] = {
					coords = {0, 0.025390625, 0, 0.001953125, 1, 0.025390625, 1, 0.001953125},
					size = {0, 12 / 2},
				},
			},
			["20"] = {
				[1] = {
					coords = {1 / 128, 31 / 128, 149 / 512, 209 / 512},
					size = {30 / 2, 60 / 2},
				},
				[2] = {
					coords = {32 / 128, 62 / 128, 149 / 512, 209 / 512},
					size = {30 / 2, 60 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 0, 0.025390625, 1, 0.001953125, 1, 0.025390625},
					size = {0, 12 / 2},
				},
				[4] = {
					coords = {0, 0.025390625, 0, 0.001953125, 1, 0.025390625, 1, 0.001953125},
					size = {0, 12 / 2},
				},
			},
			["24"] = {
				[1] = {
					coords = {1 / 128, 31 / 128, 210 / 512, 278 / 512},
					size = {30 / 2, 68 / 2},
				},
				[2] = {
					coords = {32 / 128, 62 / 128, 210 / 512, 278 / 512},
					size = {30 / 2, 68 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 0, 0.025390625, 1, 0.001953125, 1, 0.025390625},
					size = {0, 12 / 2},
				},
				[4] = {
					coords = {0, 0.025390625, 0, 0.001953125, 1, 0.025390625, 1, 0.001953125},
					size = {0, 12 / 2},
				},
			},
			["28"] = {
				[1] = {
					coords = {1 / 128, 31 / 128, 279 / 512, 355 / 512},
					size = {30 / 2, 76 / 2},
				},
				[2] = {
					coords = {32 / 128, 62 / 128, 279 / 512, 355 / 512},
					size = {30 / 2, 76 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 0, 0.025390625, 1, 0.001953125, 1, 0.025390625},
					size = {0, 12 / 2},
				},
				[4] = {
					coords = {0, 0.025390625, 0, 0.001953125, 1, 0.025390625, 1, 0.001953125},
					size = {0, 12 / 2},
				},
			},
			["32"] = {
				[1] = {
					coords = {1 / 128, 31 / 128, 356 / 512, 440 / 512},
					size = {30 / 2, 84 / 2},
				},
				[2] = {
					coords = {32 / 128, 62 / 128, 356 / 512, 440 / 512},
					size = {30 / 2, 84 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 0, 0.025390625, 1, 0.001953125, 1, 0.025390625},
					size = {0, 12 / 2},
				},
				[4] = {
					coords = {0, 0.025390625, 0, 0.001953125, 1, 0.025390625, 1, 0.001953125},
					size = {0, 12 / 2},
				},
			},
		},
		VERTICAL = {
			["8"] = {
				[1] = {
					coords = {0.0078125, 0.02734375, 0.2421875, 0.02734375, 0.0078125, 0.09765625, 0.2421875, 0.09765625},
					size = {36 / 2, 30 / 2},
				},
				[2] = {
					coords = {0.25, 0.02734375, 0.484375, 0.02734375, 0.25, 0.09765625, 0.484375, 0.09765625},
					size = {36 / 2, 30 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 1, 0.001953125, 0, 0.025390625, 1, 0.025390625},
					size = {12 / 2, 0},
				},
				[4] = {
					coords = {0, 0.025390625, 1, 0.025390625, 0, 0.001953125, 1, 0.001953125},
					size = {12 / 2, 0},
				},
			},
			["12"] = {
				[1] = {
					coords = {0.0078125, 0.099609375, 0.2421875, 0.099609375, 0.0078125, 0.185546875, 0.2421875, 0.185546875},
					size = {44 / 2, 30 / 2},
				},
				[2] = {
					coords = {0.25, 0.099609375, 0.484375, 0.099609375, 0.25, 0.185546875, 0.484375, 0.185546875},
					size = {44 / 2, 30 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 1, 0.001953125, 0, 0.025390625, 1, 0.025390625},
					size = {12 / 2, 0},
				},
				[4] = {
					coords = {0, 0.025390625, 1, 0.025390625, 0, 0.001953125, 1, 0.001953125},
					size = {12 / 2, 0},
				},
			},
			["16"] = {
				[1] = {
					coords = {0.0078125, 0.1875, 0.2421875, 0.1875, 0.0078125, 0.2890625, 0.2421875, 0.2890625},
					size = {52 / 2, 30 / 2},
				},
				[2] = {
					coords = {0.25, 0.1875, 0.484375, 0.1875, 0.25, 0.2890625, 0.484375, 0.2890625},
					size = {52 / 2, 30 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 1, 0.001953125, 0, 0.025390625, 1, 0.025390625},
					size = {12 / 2, 0},
				},
				[4] = {
					coords = {0, 0.025390625, 1, 0.025390625, 0, 0.001953125, 1, 0.001953125},
					size = {12 / 2, 0},
				},
			},
			["20"] = {
				[1] = {
					coords = {0.0078125, 0.291015625, 0.2421875, 0.291015625, 0.0078125, 0.408203125, 0.2421875, 0.408203125},
					size = {60 / 2, 30 / 2},
				},
				[2] = {
					coords = {0.25, 0.291015625, 0.484375, 0.291015625, 0.25, 0.408203125, 0.484375, 0.408203125},
					size = {60 / 2, 30 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 1, 0.001953125, 0, 0.025390625, 1, 0.025390625},
					size = {12 / 2, 0},
				},
				[4] = {
					coords = {0, 0.025390625, 1, 0.025390625, 0, 0.001953125, 1, 0.001953125},
					size = {12 / 2, 0},
				},
			},
			["24"] = {
				[1] = {
					coords = {0.0078125, 0.41015625, 0.2421875, 0.41015625, 0.0078125, 0.54296875, 0.2421875, 0.54296875},
					size = {68 / 2, 30 / 2},
				},
				[2] = {
					coords = {0.25, 0.41015625, 0.484375, 0.41015625, 0.25, 0.54296875, 0.484375, 0.54296875},
					size = {68 / 2, 30 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 1, 0.001953125, 0, 0.025390625, 1, 0.025390625},
					size = {12 / 2, 0},
				},
				[4] = {
					coords = {0, 0.025390625, 1, 0.025390625, 0, 0.001953125, 1, 0.001953125},
					size = {12 / 2, 0},
				},
			},
			["28"] = {
				[1] = {
					coords = {0.0078125, 0.544921875, 0.2421875, 0.544921875, 0.0078125, 0.693359375, 0.2421875, 0.693359375},
					size = {76 / 2, 30 / 2},
				},
				[2] = {
					coords = {0.25, 0.544921875, 0.484375, 0.544921875, 0.25, 0.693359375, 0.484375, 0.693359375},
					size = {76 / 2, 30 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 1, 0.001953125, 0, 0.025390625, 1, 0.025390625},
					size = {12 / 2, 0},
				},
				[4] = {
					coords = {0, 0.025390625, 1, 0.025390625, 0, 0.001953125, 1, 0.001953125},
					size = {12 / 2, 0},
				},
			},
			["32"] = {
				[1] = {
					coords = {0.0078125, 0.6953125, 0.2421875, 0.6953125, 0.0078125, 0.859375, 0.2421875, 0.859375},
					size = {84 / 2, 30 / 2},
				},
				[2] = {
					coords = {0.25, 0.6953125, 0.484375, 0.6953125, 0.25, 0.859375, 0.484375, 0.859375},
					size = {84 / 2, 30 / 2},
				},
				[3] = {
					coords = {0, 0.001953125, 1, 0.001953125, 0, 0.025390625, 1, 0.025390625},
					size = {12 / 2, 0},
				},
				[4] = {
					coords = {0, 0.025390625, 1, 0.025390625, 0, 0.001953125, 1, 0.001953125},
					size = {12 / 2, 0},
				},
			},
		},
	}

	local function hide(self)
		for i = 1, 6 do
			self[i]:Hide()
		end
	end

	local function show(self)
		for i = 1, 6 do
			self[i]:Show()
		end
	end

	function E:SetStatusBarSkin(object, flag)
		local s, v = s_split("-", flag)

		object.Tube = object.Tube or {
			[1] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- left/top
			[2] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- right/bottom
			[3] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- top/right
			[4] = object:CreateTexture(nil, "ARTWORK", nil, 7), -- bottom/right
			[5] = object:CreateTexture(nil, "ARTWORK", nil, 6), -- glass
			[6] = object:CreateTexture(nil, "ARTWORK", nil, 5), -- glass shadow
			Hide = hide,
			Show = show,
		}

		if s == "HORIZONTAL" or s == "VERTICAL" then
			for i = 1, 4 do
				if v == "GLASS" then
					object.Tube[i]:SetTexture(nil)
					object.Tube[i]:ClearAllPoints()
				else
					object.Tube[i]:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar")
					object.Tube[i]:SetTexCoord(unpack(LAYOUT[s][v][i].coords))
					object.Tube[i]:ClearAllPoints()
					object.Tube[i]:SetSize(unpack(LAYOUT[s][v][i].size))
				end
			end

			object.Tube[5]:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass")
			object.Tube[5]:SetAllPoints()
			object.Tube[6]:SetTexture("Interface\\AddOns\\ls_UI\\assets\\statusbar-glass-shadow")
			object.Tube[6]:SetAllPoints()

			if s == "HORIZONTAL" then
				object.Tube[5]:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)

				if v ~= "GLASS" then
					object.Tube[1]:SetPoint("RIGHT", object, "LEFT", 10 / 2, 0)
					object.Tube[2]:SetPoint("LEFT", object, "RIGHT", -10 / 2, 0)
					object.Tube[3]:SetPoint("TOPLEFT", object.Tube[1], "TOPRIGHT", 0, 0)
					object.Tube[3]:SetPoint("TOPRIGHT", object.Tube[2], "TOPLEFT", 0, 0)
					object.Tube[4]:SetPoint("BOTTOMLEFT", object.Tube[1], "BOTTOMRIGHT", 0, 0)
					object.Tube[4]:SetPoint("BOTTOMRIGHT", object.Tube[2], "BOTTOMLEFT", 0, 0)
				end
			else
				object.Tube[5]:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1)

				if v ~= "GLASS" then
					object.Tube[1]:SetPoint("BOTTOM", object, "TOP", 0, -10 / 2)
					object.Tube[2]:SetPoint("TOP", object, "BOTTOM", 0, 10 / 2)
					object.Tube[3]:SetPoint("TOPLEFT", object.Tube[1], "BOTTOMLEFT", 0, 0)
					object.Tube[3]:SetPoint("BOTTOMLEFT", object.Tube[2], "TOPLEFT", 0, 0)
					object.Tube[4]:SetPoint("TOPRIGHT", object.Tube[1], "BOTTOMRIGHT", 0, 0)
					object.Tube[4]:SetPoint("BOTTOMRIGHT", object.Tube[2], "TOPRIGHT", 0, 0)
				end
			end
		elseif s == "NONE" then
			for i = 1, 6 do
				object.Tube[i]:SetTexture(nil)
				object.Tube[i]:ClearAllPoints()
			end
		end
	end
end

do
	local function attachGainToVerticalBar(object, prev, max)
		local offset = object:GetHeight() * (1 - E:Clamp(prev / max))

		object.Gain:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, -offset)
		object.Gain:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, -offset)
	end

	local function attachLossToVerticalBar(object, prev, max)
		local offset = object:GetHeight() * (1 - E:Clamp(prev / max))

		object.Loss:SetPoint("TOPLEFT", object, "TOPLEFT", 0, -offset)
		object.Loss:SetPoint("TOPRIGHT", object, "TOPRIGHT", 0, -offset)
	end

	local function attachGainToHorizontalBar(object, prev, max)
		local offset = object:GetWidth() * (1 - E:Clamp(prev / max))

		object.Gain:SetPoint("TOPLEFT", object, "TOPRIGHT", -offset, 0)
		object.Gain:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -offset, 0)
	end

	local function attachLossToHorizontalBar(object, prev, max)
		local offset = object:GetWidth() * (1 - E:Clamp(prev / max))

		object.Loss:SetPoint("TOPRIGHT", object, "TOPRIGHT", -offset, 0)
		object.Loss:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -offset, 0)
	end

	local function object_UpdateGainLoss(object, cur, max, condition)
		if max ~= 0 and (condition == nil or condition) then
			local prev = object._prev or 0
			local diff = cur - prev

			if m_abs(diff) / max < 0.1 then
				diff = 0
			end

			if diff > 0 then
				if object.Gain:GetAlpha() == 0 then
					object.Gain:SetAlpha(1)

					if object:GetOrientation() == "VERTICAL" then
						attachGainToVerticalBar(object, prev, max)
					else
						attachGainToHorizontalBar(object, prev, max)
					end

					object.Gain.FadeOut:Play()
				end
			elseif diff < 0 then
				object.Gain.FadeOut:Stop()
				object.Gain:SetAlpha(0)

				if object.Loss:GetAlpha() == 0 then
					object.Loss:SetAlpha(1)

					if object:GetOrientation() == "VERTICAL" then
						attachLossToVerticalBar(object, prev, max)
					else
						attachLossToHorizontalBar(object, prev, max)
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

	function E.CreateGainLossIndicators(_, object)
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

		object.UpdateGainLoss = object_UpdateGainLoss
	end

	function E.ReanchorGainLossIndicators(_, object, orientation)
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
end

do
	local objects = {}

	local function clamp(v, min, max)
		return m_min(max or 1, m_max(min or 0, v))
	end

	local function isCloseEnough(new, target, range)
		if range > 0 then
			return m_abs((new - target) / range) <= 0.001
		end

		return true
	end

	C_Timer.NewTicker(0, function()
		for object, target in next, objects do
			local new = FrameDeltaLerp(object._value, target, 0.25)

			if isCloseEnough(new, target, object._max - object._min) then
				new = target
				objects[object] = nil
			end

			object:SetValue_(new)
			object._value = new
		end
	end)

	local function bar_SetSmoothedValue(self, value)
		self._value = self:GetValue()
		objects[self] = clamp(value, self._min, self._max)
	end

	local function bar_SetSmoothedMinMaxValues(self, min, max)
		self:SetMinMaxValues_(min, max)

		if self._max and self._max ~= max then
			local target = objects[self]
			local cur = self._value
			local ratio = 1

			if max ~= 0 and self._max and self._max ~= 0 then
				ratio = max / (self._max or max)
			end

			if target then
				objects[self] = target * ratio
			end

			if cur then
				self:SetValue_(cur * ratio)
			end
		end

		self._min = min
		self._max = max
	end

	function E:SmoothBar(bar)
		-- reset the bar
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(0)

		bar.SetValue_ = bar.SetValue
		bar.SetMinMaxValues_ = bar.SetMinMaxValues
		bar.SetValue = bar_SetSmoothedValue
		bar.SetMinMaxValues = bar_SetSmoothedMinMaxValues
	end
end
