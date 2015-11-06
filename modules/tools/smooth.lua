-- Based on code from oUF Smooth Update by Xuerian

local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L

local Smoother = CreateFrame("Frame")

local min, max, pairs = min, max, pairs

local bars = {}

local function Smooth(self, value)
	local _, barmax = self:GetMinMaxValues()

	if value == self:GetValue() or (self._max and self._max ~= barmax) then
		bars[self] = nil
		self:SetValue_(value)
	else
		bars[self] = value
	end
	self._max = barmax
end

local function Smoother_OnUpdate(self)
	local limit = 30/GetFramerate()

	for bar, value in pairs(bars) do
		local cur = bar:GetValue()
		local new = cur + min((value - cur) / 10, max(value - cur, limit))

		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end

		bar:SetValue_(new)

		if cur == value or abs(new - value) < 2 then
			bar:SetValue_(value)
			bars[bar] = nil
		end
	end
end

function E:SmoothBar(bar)
	bar.SetValue_ = bar.SetValue
	bar.SetValue = Smooth

	if not Smoother:GetScript("OnUpdate") then
		Smoother:SetScript("OnUpdate", Smoother_OnUpdate)
	end
end
