local _, ns = ...
local E, L = ns.E, ns.L

-- Lua
local _G = _G

if _G.GetLocale() ~= "zhTW" then return end

-- Lua
local math = _G.math
local string = _G.string

-- Blizz
local FIRST_NUMBER_CAP_NO_SPACE = _G.FIRST_NUMBER_CAP_NO_SPACE
local SECOND_NUMBER_CAP_NO_SPACE = _G.SECOND_NUMBER_CAP_NO_SPACE

-- Mine
function E:NumberFormat(v, mod)
	v = math.abs(v)

	if v >= 1E8 then
		return string.format("%."..(mod or 0).."f"..SECOND_NUMBER_CAP_NO_SPACE, v / 1E8)
	elseif v >= 1E4 then
		return string.format("%."..(mod or 0).."f"..FIRST_NUMBER_CAP_NO_SPACE, v / 1E4)
	else
		return v
	end
end
