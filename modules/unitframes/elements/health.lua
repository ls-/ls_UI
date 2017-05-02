local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local DEAD = _G.DEAD
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE

-- Mine
local function PostUpdateHealth(element, unit, cur, max)
	if not UnitIsConnected(unit) then
		element:SetValue(0)

		return element.Text and element.Text:SetText(PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		element:SetValue(0)

		return element.Text and element.Text:SetText(DEAD)
	end

	if not element.Text then
		return
	end

	if element.__owner.isMouseOver then
		if unit == "target" or unit == "focus" then
			return element.Text:SetFormattedText(L["BAR_VALUE_PERC_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
		elseif unit:match("(boss)%d+") then
			return element.Text:SetFormattedText(L["BAR_VALUE_TEMPLATE"], E:NumberFormat(cur, 1))
		end
	else
		if cur == max then
			if unit == "player" or unit == "vehicle" or unit == "pet" then
				return element.Text:SetText(nil)
			end
		else
			if unit == "target" or unit == "focus" then
				return element.Text:SetFormattedText(L["BAR_VALUE_PERC_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
			elseif unit:match("(boss)%d+") then
				return element.Text:SetFormattedText(L["BAR_PERC_TEMPLATE"], E:NumberToPerc(cur, max))
			end
		end
	end

	element.Text:SetFormattedText(L["BAR_VALUE_TEMPLATE"], E:NumberFormat(cur, 1))
end

function UF:CreateHealth(parent, text, textFontObject, textParent)
	local element = _G.CreateFrame("StatusBar", "$parentHealthBar", parent)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(element)

	if text then
		text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
		text:SetWordWrap(false)
		E:ResetFontStringHeight(text)
		element.Text = text
	end

	element.colorHealth = true
	element.colorTapping = true
	element.colorDisconnected = true
	element.PostUpdate = PostUpdateHealth

	return element
end

function UF:UpdateHealth(frame)
	local config = frame._config.health
	local element = frame.Health

	element:SetOrientation(config.orientation)

	if config.color then
		element.colorClass = config.color.class
		element.colorReaction = config.color.reaction
	end

	if element.Text then
		element.Text:SetJustifyV(config.text.v_alignment or "MIDDLE")
		element.Text:SetJustifyH(config.text.h_alignment or "CENTER")

		local point1 = config.text.point1

		element.Text:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)

		local point2 = config.text.point2

		if point2 then
			element.Text:SetPoint(point2.p, E:ResolveAnchorPoint(frame, point2.anchor), point2.rP, point2.x, point2.y)
		end
	end

	frame._mouseovers[element] = config.update_on_mouseover and true or nil

	if element.ForceUpdate then
		element:ForceUpdate()
	end
end
