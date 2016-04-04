local _, ns = ...
local E, L = ns.E, ns.L

if GetLocale() ~= "zhCN" then
	return
end

function E:NumberFormat(v, mod)
	if abs(v) >= 1E8 then
		return format("%."..(mod or 0).."f"..SECOND_NUMBER_CAP_NO_SPACE, v / 1E8)
	elseif abs(v) >= 1E4 then
		return format("%."..(mod or 0).."f"..FIRST_NUMBER_CAP_NO_SPACE, v / 1E4)
	else
		return v
	end
end
