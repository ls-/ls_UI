local _, ns = ...
local E, M = ns.E, ns.M

E.width, E.height = string.match(GetCVar("gxResolution"), "(%d+)x(%d+)")
E.playerclass = select(2, UnitClass("player"))

function E:CreateFontString(parent, size, name, shadow, outline, wrap, ...)
	local r, g, b, a = ...

	local object = parent:CreateFontString(name, "OVERLAY", outline and "LS"..size.."Font_Outline" or "LS"..size.."Font")
	object:SetTextColor(r or 1, g or 1, b or 1, a or 1)
	object:SetWordWrap(wrap or false)

	if shadow then
		object:SetShadowColor(0, 0, 0)
		object:SetShadowOffset(1, -1)
	end

	return object
end

function E:TweakIcon(icon, l, r, t, b)
	icon:SetTexCoord(l or 0.0625, r or 0.9375, t or 0.0625, b or 0.9375)
	icon:SetDrawLayer("BACKGROUND", 0)
	icon:SetAllPoints()
end

function E:AlwaysShow(object)
	if not object then return end

	object:Show()

	object.Hide = object.Show
end

function E:AlwaysHide(object)
	if not object then return end

	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(M.hiddenParent)
	else
		object.Show = object.Hide
	end

	object:Hide()
end

function E:GetCoords(object)
	local p, anchor, rP, x, y = object:GetPoint()

	if not x then
		return p, anchor, rP, x, y
	else
		return p, anchor and anchor:GetName() or "UIParent", rP, E:Round(x), E:Round(y)
	end
end
