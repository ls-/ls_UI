-- Based on SmoothStatusBarMixin code.

local _, ns = ...
local E = ns.E

-- Lua
local _G = _G
local math = _G.math
local pairs = _G.pairs

-- Blizz
local FrameDeltaLerp = _G.FrameDeltaLerp

--Mine
local bars = {}

local function ProcessSmoothStatusBars()
	for bar, targetValue in pairs(bars) do
		local newValue = FrameDeltaLerp(bar._value, targetValue, .25)

		if math.abs(newValue - targetValue) <= .005 then
			newValue = targetValue
			bars[bar] = nil
		end

		bar:SetValue_(newValue)
		bar._value = newValue
	end
end

_G.C_Timer.NewTicker(0, ProcessSmoothStatusBars)

local function SetSmoothedValue(self, value)
	self._value = self:GetValue()
	bars[self] = value
end

local function SetSmoothedMinMaxValues(self, min, max)
	self:SetMinMaxValues_(min, max)

	if self._max and self._max ~= max then
		local targetValue = bars[self]
		local curValue = self._value
		local ratio = 1

		if max ~= 0 and self._max and self._max ~= 0 then
			ratio = max / (self._max or max)
		end

		if targetValue then
			bars[self] = targetValue * ratio
		end

		if curValue then
			self:SetValue_(curValue * ratio)
		end
	end

	self._min = min
	self._max = max
end

function E:SmoothBar(bar)
	bar.SetValue_ = bar.SetValue
	bar.SetMinMaxValues_ = bar.SetMinMaxValues
	bar.SetValue = SetSmoothedValue
	bar.SetMinMaxValues = SetSmoothedMinMaxValues
end
