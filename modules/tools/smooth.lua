-- Based on SmoothStatusBarMixin code.

local _, ns = ...
local E = ns.E

-- Lua
local _G = _G
local pairs = pairs
local mabs = math.abs

-- Blizz
local FrameDeltaLerp = FrameDeltaLerp

--Mine
local bars = {}

local function ProcessSmoothStatusBars()
    for bar, targetValue in pairs(bars) do
        local newValue = FrameDeltaLerp(bar:GetValue(), targetValue, .25)

        if mabs(newValue - targetValue) < .005 then
            bars[bar] = nil
        end

        bar:SetValue_(newValue)
    end
end

_G.C_Timer.NewTicker(0, ProcessSmoothStatusBars)

local function SetSmoothedValue(self, value)
    bars[self] = value
    self._value = value
end

local function SetMinMaxSmoothedValues(self, min, max)
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
    bar.SetMinMaxValues = SetMinMaxSmoothedValues
end
