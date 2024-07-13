local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF

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

		bg:SetTexture("Interface\\HELPFRAME\\DarkSandstone-Tile", "REPEAT", "REPEAT")
		bg:SetVertexColor(1, 1, 1, 1)
		bg:SetHorizTile(true)
		bg:SetVertTile(true)
		bg:SetAllPoints()
		bar.Background = bg

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

local gradientColorMin = {r = 0, g = 0, b = 0, a = 0}
local gradientColorMax = {r = 0, g = 0, b = 0, a = 0.4}

function E:ReskinStatusBar(bar)
	if bar.TextureParent then return end

	local textureParent = CreateFrame("Frame", nil, bar)
	textureParent:SetFrameLevel(bar:GetFrameLevel() + 2)
	textureParent:SetAllPoints()
	bar.TextureParent = textureParent

	local border = E:CreateBorder(textureParent, "BORDER")
	border:SetTexture("Interface\\AddOns\\ls_UI\\assets\\border-statusbar")
	border:SetSize(16)
	border:SetOffset(-4)
	textureParent.Border = border

	local gradient = textureParent:CreateTexture(nil, "BORDER", nil, -1)
	gradient:SetAllPoints(textureParent)
	gradient:SetSnapToPixelGrid(false)
	gradient:SetTexelSnappingBias(0)
	gradient:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	gradient:SetGradient("VERTICAL", gradientColorMin, gradientColorMax)
	textureParent.Gradient = gradient

	if bar.Text then
		bar.Text:SetParent(textureParent)
	end
end

do
	local activeObjects = {}
	local handledObjects = {}

	local TARGET_FPS = 60
	local AMOUNT = 0.4

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
