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
local Lerp = _G.Lerp

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
			bar.RealBar = rbar
		end

		if not bg then
			bg = bar:CreateTexture(nil, "BACKGROUND")
		end

		bg:SetColorTexture(E:GetRGB(C.db.global.colors.dark_gray))
		bg:SetAllPoints()
		bar.Bg = bg

		if not text then
			text = bar:CreateFontString(nil, "ARTWORK")
		end

		E.FontStrings:Capture(text, "statusbar")
		text:UpdateFont(12)
		text:SetWordWrap(false)
		text:SetJustifyV("MIDDLE")
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
	bg:SetColorTexture(E:GetRGB(C.db.global.colors.dark_gray))
	bg:SetAllPoints()
	bar.Bg = bg

	local text = bar:CreateFontString("$parentText", "ARTWORK")
	E.FontStrings:Capture(text, "statusbar")
	text:UpdateFont(12)
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
		for i = 1, 5 do
			self[i]:Hide()
		end
	end

	local function show(self)
		for i = 1, 5 do
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
			for i = 1, 5 do
				object.Tube[i]:SetTexture(nil)
				object.Tube[i]:ClearAllPoints()
			end
		end
	end
end

do
	local function clamp(v, min, max)
		return m_min(max or 1, m_max(min or 0, v))
	end

	local function attachGainToVerticalBar(self, object, prev, max)
		local offset = object:GetHeight() * (1 - clamp(prev / max))

		self:SetPoint("BOTTOMLEFT", object, "TOPLEFT", 0, -offset)
		self:SetPoint("BOTTOMRIGHT", object, "TOPRIGHT", 0, -offset)
	end

	local function attachLossToVerticalBar(self, object, prev, max)
		local offset = object:GetHeight() * (1 - clamp(prev / max))

		self:SetPoint("TOPLEFT", object, "TOPLEFT", 0, -offset)
		self:SetPoint("TOPRIGHT", object, "TOPRIGHT", 0, -offset)
	end

	local function attachGainToHorizontalBar(self, object, prev, max)
		local offset = object:GetWidth() * (1 - clamp(prev / max))

		self:SetPoint("TOPLEFT", object, "TOPRIGHT", -offset, 0)
		self:SetPoint("BOTTOMLEFT", object, "BOTTOMRIGHT", -offset, 0)
	end

	local function attachLossToHorizontalBar(self, object, prev, max)
		local offset = object:GetWidth() * (1 - clamp(prev / max))

		self:SetPoint("TOPRIGHT", object, "TOPRIGHT", -offset, 0)
		self:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -offset, 0)
	end

	local function update(self, cur, max, condition)
		if max and max ~= 0 and (condition == nil or condition) then
			local prev = (self._prev or cur) * max / (self._max or max)
			local diff = cur - prev

			if m_abs(diff) / max < self.threshold then
				diff = 0
			end

			if diff > 0 then
				if self.Gain and self.Gain:GetAlpha() == 0 then
					if self.orientation == "VERTICAL" then
						attachGainToVerticalBar(self.Gain, self.__owner, prev, max)
					else
						attachGainToHorizontalBar(self.Gain, self.__owner, prev, max)
					end

					self.Gain:SetAlpha(1)
					self.Gain.FadeOut:Play()
				end
			elseif diff < 0 then
				if self.Gain then
					self.Gain.FadeOut:Stop()
					self.Gain:SetAlpha(0)
				end

				if self.Loss then
					if self.Loss:GetAlpha() <= 0.33 then
						if self.orientation == "VERTICAL" then
							attachLossToVerticalBar(self.Loss, self.__owner, prev, max)
						else
							attachLossToHorizontalBar(self.Loss, self.__owner, prev, max)
						end

						self.Loss:SetAlpha(1)
						self.Loss.FadeOut:Restart()
					elseif self.Loss.FadeOut.Alpha:IsDelaying() or self.Loss:GetAlpha() >= 0.66 then
						self.Loss.FadeOut:Restart()
					end
				end
			end
		else
			if self.Gain then
				self.Gain.FadeOut:Stop()
				self.Gain:SetAlpha(0)
			end

			if self.Loss then
				self.Loss.FadeOut:Stop()
				self.Loss:SetAlpha(0)
			end
		end

		if max and max ~= 0 then
			self._prev = cur
			self._max = max
		else
			self._prev = nil
			self._max = nil
		end
	end

	local function updateColors(self)
		self.Gain_:SetColorTexture(E:GetRGB(C.db.global.colors.gain))
		self.Loss_:SetColorTexture(E:GetRGB(C.db.global.colors.loss))
	end

	local function updatePoints(self, orientation)
		orientation = orientation or "HORIZONTAL"
		if orientation == "HORIZONTAL" then
			self.Gain_:ClearAllPoints()
			self.Gain_:SetPoint("TOPRIGHT", self.__owner:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
			self.Gain_:SetPoint("BOTTOMRIGHT", self.__owner:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

			self.Loss_:ClearAllPoints()
			self.Loss_:SetPoint("TOPLEFT", self.__owner:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
			self.Loss_:SetPoint("BOTTOMLEFT", self.__owner:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		else
			self.Gain_:ClearAllPoints()
			self.Gain_:SetPoint("TOPLEFT", self.__owner:GetStatusBarTexture(), "TOPLEFT", 0, 0)
			self.Gain_:SetPoint("TOPRIGHT", self.__owner:GetStatusBarTexture(), "TOPRIGHT", 0, 0)

			self.Loss_:ClearAllPoints()
			self.Loss_:SetPoint("BOTTOMLEFT", self.__owner:GetStatusBarTexture(), "TOPLEFT", 0, 0)
			self.Loss_:SetPoint("BOTTOMRIGHT", self.__owner:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		end

		self.orientation = orientation
	end

	local function updateThreshold(self, value)
		self.threshold = value or 0.01
	end

	function E:CreateGainLossIndicators(object)
		local gainTexture = object:CreateTexture(nil, "ARTWORK", nil, 1)
		gainTexture:SetAlpha(0)

		local ag = gainTexture:CreateAnimationGroup()
		ag:SetToFinalAlpha(true)
		gainTexture.FadeOut = ag

		local anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetStartDelay(0.25)
		anim:SetDuration(0.1)
		ag.Alpha = anim

		local lossTexture = object:CreateTexture(nil, "BACKGROUND")
		lossTexture:SetAlpha(0)

		ag = lossTexture:CreateAnimationGroup()
		ag:SetToFinalAlpha(true)
		lossTexture.FadeOut = ag

		anim = ag:CreateAnimation("Alpha")
		anim:SetOrder(1)
		anim:SetFromAlpha(1)
		anim:SetToAlpha(0)
		anim:SetStartDelay(0.25)
		anim:SetDuration(0.1)
		ag.Alpha = anim

		return {
			__owner = object,
			threshold = 0.01,
			Gain = gainTexture,
			Gain_ = gainTexture,
			Loss = lossTexture,
			Loss_ = lossTexture,
			Update = update,
			UpdateColors = updateColors,
			UpdatePoints = updatePoints,
			UpdateThreshold = updateThreshold,
		}
	end
end

do
	local activeObjects = {}
	local handledObjects = {}

	local TARGET_FPS = 60
	local AMOUNT = 0.33

	local function clamp(v, min, max)
		min = min or 0
		max = max or 1

		if v > max then
			return max
		elseif v < min then
			return min
		end

		return v
	end

	local function isCloseEnough(new, target, range)
		if range > 0 then
			return m_abs((new - target) / range) <= 0.001
		end

		return true
	end

	local frame = CreateFrame("Frame", "LSBarSmoother")

	local function onUpdate(_, elapsed)
		for object, target in next, activeObjects do
			local new = Lerp(object._value, target, clamp(AMOUNT * elapsed * TARGET_FPS))
			if isCloseEnough(new, target, object._max - object._min) then
				new = target
				activeObjects[object] = nil
			end

			object:SetValue_(new)
			object._value = new
		end
	end

	local function bar_SetSmoothedValue(self, value)
		self._value = self:GetValue()
		activeObjects[self] = clamp(value, self._min, self._max)
	end

	local function bar_SetSmoothedMinMaxValues(self, min, max)
		self:SetMinMaxValues_(min, max)

		if self._max and self._max ~= max then
			local ratio = 1
			if max ~= 0 and self._max and self._max ~= 0 then
				ratio = max / (self._max or max)
			end

			local target = activeObjects[self]
			if target then
				activeObjects[self] = target * ratio
			end

			local cur = self._value
			if cur then
				self:SetValue_(cur * ratio)
				self._value = cur * ratio
			end
		end

		self._min = min
		self._max = max
	end

	function E:SmoothBar(bar)
		if handledObjects[bar] then return end

		bar._min, bar._max = bar:GetMinMaxValues()
		bar._value = bar:GetValue()

		bar.SetValue_ = bar.SetValue
		bar.SetMinMaxValues_ = bar.SetMinMaxValues
		bar.SetValue = bar_SetSmoothedValue
		bar.SetMinMaxValues = bar_SetSmoothedMinMaxValues

		handledObjects[bar] = true

		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", onUpdate)
		end
	end

	function E:DesmoothBar(bar)
		if not handledObjects[bar] then return end

		if activeObjects[bar] then
			bar:SetValue_(activeObjects[bar])
			activeObjects[bar] = nil
		end

		if bar.SetValue_ then
			bar.SetValue = bar.SetValue_
			bar.SetValue_ = nil
		end

		if bar.SetMinMaxValues_ then
			bar.SetMinMaxValues = bar.SetMinMaxValues_
			bar.SetMinMaxValues_ = nil
		end

		handledObjects[bar] = nil

		if not next(handledObjects) then
			frame:SetScript("OnUpdate", nil)
		end
	end

	function E:SetSmoothingAmount(amount)
		AMOUNT = clamp(amount, 0.3, 0.6)
	end
end
