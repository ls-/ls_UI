local _, ns = ...
local E = ns.E

local format, gsub, sub, tonumber = format, gsub, strsub, tonumber
local floor, ceil, modf, min = floor, ceil, math.modf, min
local bitand, bitor, bitnot = bit.band, bit.bor, bit.bnot
local FIRST_NUMBER_CAP_NO_SPACE, SECOND_NUMBER_CAP_NO_SPACE = FIRST_NUMBER_CAP_NO_SPACE, SECOND_NUMBER_CAP_NO_SPACE
local SECOND_ONELETTER_ABBR, MINUTE_ONELETTER_ABBR, HOUR_ONELETTER_ABBR, DAY_ONELETTER_ABBR =
	SECOND_ONELETTER_ABBR, MINUTE_ONELETTER_ABBR, HOUR_ONELETTER_ABBR, DAY_ONELETTER_ABBR

function E:NumberFormat(v, mod)
	if abs(v) >= 1E6 then
		return format("%."..(mod or 0).."f"..SECOND_NUMBER_CAP_NO_SPACE, v / 1E6)
	elseif abs(v) >= 1E4 then
		return format("%."..(mod or 0).."f"..FIRST_NUMBER_CAP_NO_SPACE, v / 1E3)
	else
		return v
	end
end

function E:NumberToPerc(v1, v2)
	return floor(v1 / v2 * 100 + 0.5)
end

function E:Round(v)
	return floor(v + 0.5)
end

function E:NumberTruncate(v, l)
	return v - (v % (0.1 ^ (l or 0)))
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
	s = abs(s)
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

-- http://wow.gamepedia.com/ColorGradient for 3 colours
function E:ColorGradient(perc, ...)
	if perc >= 1 then
		return select(7, ...)
	elseif perc <= 0 then
		return ...
	end

	local segment, relperc = modf(perc * 2)
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2 -r1 ) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

function E:ColorLighten(r, g, b, perc)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	return min(1, r + 1 * perc), min(1, g + 1 * perc), min(1, b + 1 * perc)
end

function E:ColorDarken(r, g, b, perc)
	if type(r) == "table" then
		if r.r then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end

	return max(0, r - 1 * perc), max(0, g - 1 * perc), max(0, b - 1 * perc)
end

function E:IsFilterApplied(mask, filter)
	return bitand(mask, filter) == filter
end

function E:AddFilterToMask(mask, filter)
	return bitor(mask, filter)
end

function E:DeleteFilterFromMask(mask, filter)
	return bitand(mask, bitnot(filter))
end
