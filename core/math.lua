local _, ns = ...
local E = ns.E

local format, gsub, sub, tonumber = format, gsub, strsub, tonumber
local floor, ceil = floor, ceil

local FIRST_NUMBER_CAP, SECOND_NUMBER_CAP = FIRST_NUMBER_CAP, SECOND_NUMBER_CAP
local SECOND_ONELETTER_ABBR, MINUTE_ONELETTER_ABBR, HOUR_ONELETTER_ABBR, DAY_ONELETTER_ABBR =
	SECOND_ONELETTER_ABBR, MINUTE_ONELETTER_ABBR, HOUR_ONELETTER_ABBR, DAY_ONELETTER_ABBR

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

function E:HEXToRGB(hex)
	local rhex, ghex, bhex = tonumber(sub(hex, 1, 2), 16), tonumber(sub(hex, 3, 4), 16), tonumber(sub(hex, 5, 6), 16)

	return tonumber(format("%.2f", rhex / 255)), tonumber(format("%.2f", ghex / 255)), tonumber(format("%.2f", bhex / 255))
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

function E:TimeFormat(s, abbr)
	if s >= 86400 then
		return ceil(s / 86400), "|cffe5e5e5", abbr and gsub(DAY_ONELETTER_ABBR, "[ .]", "")
	elseif s >= 3600 then
		return ceil(s / 3600), "|cffe5e5e5", abbr and gsub(HOUR_ONELETTER_ABBR, "[ .]", "")
	elseif s >= 60 then
		return ceil(s / 60), "|cffe5e5e5", abbr and gsub(MINUTE_ONELETTER_ABBR, "[ .]", "")
	elseif s >= 1 then
		return floor(s), s >= 30 and "|cffe5e5e5" or s >= 10 and "|cffffbf19" or "|cffe51919", abbr and gsub(SECOND_ONELETTER_ABBR, "[ .]", "")
	else
		return tonumber(format("%.1f", s)), "|cffe51919", abbr and "%.1f"
	end
end
