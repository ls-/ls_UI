-- Contributors:

local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	GetLocale
]]

if GetLocale() ~= "koKR" then return end

-- Lua
local m_modf = _G.math.modf
local s_format = _G.string.format

-- Mine
do
	local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
	local SECOND_NUMBER_CAP = "%s.%d" .. _G.SECOND_NUMBER_CAP_NO_SPACE
	local FIRST_NUMBER_CAP = "%s.%d" .. _G.FIRST_NUMBER_CAP_NO_SPACE

	function E:NumberFormat(v)
		if v >= 1E8 then
			local i, f = m_modf(v / 1E8)
			return s_format(SECOND_NUMBER_CAP, BreakUpLargeNumbers(i), f * 10)
		elseif v >= 1E4 then
			local i, f = m_modf(v / 1E4)
			return s_format(FIRST_NUMBER_CAP, BreakUpLargeNumbers(i), f * 10)
		elseif v >= 0 then
			return BreakUpLargeNumbers(v)
		else
			return 0
		end
	end
end
