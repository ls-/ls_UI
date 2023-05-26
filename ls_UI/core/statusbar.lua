local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs
local next = _G.next
local s_match = _G.string.match
local s_split = _G.string.split
local unpack = _G.unpack

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

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

		bg:SetColorTexture(C.db.global.colors.dark_gray:GetRGB())
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

		sbt:SetTexture(LSM:Fetch("statusbar", C.db.global.textures.statusbar.horiz))
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
	bg:SetColorTexture(C.db.global.colors.dark_gray:GetRGB())
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
	local activeObjects = {}
	local handledObjects = {}

	local TARGET_FPS = 60
	local AMOUNT = 0.44

	local function lerp(v1, v2, perc)
		return v1 + (v2 - v1) * perc
	end

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

	local smoother = CreateFrame("Frame", "LSBarSmoother")
	local add, remove

	local function onUpdate(_, elapsed)
		for object, target in next, activeObjects do
			local new = lerp(object._value, target, clamp(AMOUNT * elapsed * TARGET_FPS))
			object:SetValue_(new)
			object._value = new

			if not object:IsVisible() or isCloseEnough(new, target, object._max - object._min) then
				remove(object)
			end
		end
	end

	function add(bar, target)
		activeObjects[bar] = clamp(target, bar._min, bar._max)

		if not smoother:GetScript("OnUpdate") then
			smoother:SetScript("OnUpdate", onUpdate)
		end
	end

	function remove(bar)
		if activeObjects[bar] then
			bar:SetValue_(activeObjects[bar])
			bar._value = activeObjects[bar]

			activeObjects[bar] = nil
		end

		if not next(activeObjects) then
			smoother:SetScript("OnUpdate", nil)
		end
	end

	local function bar_SetValue(self, new)
		if not self:IsVisible() or isCloseEnough(self._value, new, self._max - self._min) then
			activeObjects[self] = nil

			self:SetValue_(new)
			self._value = new

			return
		end

		add(self, new)
	end

	local function bar_SetMinMaxValues(self, min, max)
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
		bar.SetValue = bar_SetValue
		bar.SetMinMaxValues_ = bar.SetMinMaxValues
		bar.SetMinMaxValues = bar_SetMinMaxValues

		handledObjects[bar] = true
	end

	function E:DesmoothBar(bar)
		if not handledObjects[bar] then return end

		remove(bar)

		if bar.SetValue_ then
			bar.SetValue = bar.SetValue_
			bar.SetValue_ = nil
		end

		if bar.SetMinMaxValues_ then
			bar.SetMinMaxValues = bar.SetMinMaxValues_
			bar.SetMinMaxValues_ = nil
		end

		handledObjects[bar] = nil
	end

	function E:SetSmoothingAmount(v)
		AMOUNT = clamp(v, 0.3, 0.6)
	end
end
