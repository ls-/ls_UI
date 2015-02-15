local _, ns = ...
local E = ns.E

local format, gsub, sub, tonumber = format, gsub, strsub, tonumber
local floor, fmod = floor, math.fmod

function E:NumberFormat(v, mod)
	if abs(v) >= 1E6 then
		return format("%."..(mod or 0).."f"..SECOND_NUMBER_CAP, v / 1E6)
	elseif abs(v) >= 1E4 then
		return format("%."..(mod or 0).."f"..FIRST_NUMBER_CAP, v / 1E3)
	else
		return v
	end
end

function E:NumberToPerc(v1, v2)
	return tonumber(format("%d", v1 / v2 * 100))
end

function E:Round(v)
	return tonumber(floor(v + 0.5))
end

function E:RGBToHEX(r, g, b)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	return format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function E:HexToRGB(hex)
	local rhex, ghex, bhex = sub(hex, 1, 2), sub(hex, 3, 4), sub(hex, 5, 6)

	return tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16)
end

function E:StringTruncate(s, l)
	if not s or not l then return end

	local len, lenutf8 = strlen(s), strlenutf8(s)

	if len > lenutf8 then
		return sub(s, 1, l * 2)
	else
		return sub(s, 1, l)
	end
end

function E:TimeFormat(s)
	if s >= 86400 then
		return format(gsub(DAY_ONELETTER_ABBR, "[ .]", ""), floor(s / 86400 + 0.5))
	elseif s >= 3600 then
		return format(gsub(HOUR_ONELETTER_ABBR, "[ .]", ""), floor(s / 3600 + 0.5))
	elseif s >= 60 then
		return format(gsub(MINUTE_ONELETTER_ABBR, "[ .]", ""), floor(s / 60 + 0.5))
	elseif s >= 1 then
		return format(gsub(SECOND_ONELETTER_ABBR, "[ .]", ""), fmod(s, 60))
	else
		return format("%.1f", s)
	end
end
