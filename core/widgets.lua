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

-- Mine
function E:CalcSegmentsSizes(size, num)
	local size_wo_gaps = size - 2 * (num - 1)
	local seg_size = size_wo_gaps / num
	local mod = seg_size % 1
	local result = {}

	if mod == 0 then
		for k = 1, num do
			result[k] = seg_size
		end
	else
		seg_size = self:Round(seg_size)

		if num % 2 == 0 then
			local range = (num - 2) / 2

			for k = 1, range do
				result[k] = seg_size
			end

			for k = num - range + 1, num do
				result[k] = seg_size
			end

			seg_size = (size_wo_gaps - seg_size * range * 2) / 2
			result[range + 1] = seg_size
			result[range + 2] = seg_size
		else
			local range = (num - 1) / 2

			for k = 1, range do
				result[k] = seg_size
			end

			for k = num - range + 1, num do
				result[k] = seg_size
			end

			seg_size = size_wo_gaps - seg_size * range * 2
			result[range + 1] = seg_size
		end
	end

	return result
end
