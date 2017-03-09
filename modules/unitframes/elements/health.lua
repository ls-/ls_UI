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
local function PostUpdateHealth(bar, unit, cur, max)
	if not bar.Text then return end

	if not UnitIsConnected(unit) then
		bar:SetValue(0)

		return bar.Text:SetText(PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		bar:SetValue(0)

		return bar.Text:SetText(DEAD)
	end

	if bar.__owner.isMouseOver then
		if unit == "target" or unit == "focus" then
			return bar.Text:SetFormattedText(L["BAR_VALUE_PERC_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
		elseif unit:match("(boss)%d+") then
			return bar.Text:SetFormattedText(L["BAR_VALUE_TEMPLATE"], E:NumberFormat(cur, 1))
		end
	else
		if cur == max then
			if unit == "player" or unit == "vehicle" or unit == "pet" then
				return bar.Text:SetText(nil)
			end
		else
			if unit == "target" or unit == "focus" then
				return bar.Text:SetFormattedText(L["BAR_VALUE_PERC_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
			elseif unit:match("(boss)%d+") then
				return bar.Text:SetFormattedText(L["BAR_PERC_TEMPLATE"], E:NumberToPerc(cur, max))
			end
		end
	end

	bar.Text:SetFormattedText(L["BAR_VALUE_TEMPLATE"], E:NumberFormat(cur, 1))
end

function UF:CreateHealthBar_new(parent, textFontObject, options)
	P.argcheck(1, parent, "table")
	P.argcheck(2, textFontObject, "string")

	options = options or {}

	local bar = _G.CreateFrame("StatusBar", "$parentHealthBar", parent)
	bar:SetOrientation(options.is_vertical and "VERTICAL" or "HORIZONTAL")
	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(bar)

	local text = (options.text_parent or bar):CreateFontString(nil, "ARTWORK", textFontObject)
	text:SetWordWrap(false)
	E:ResetFontStringHeight(text)
	bar.Text = text

	bar.colorHealth = true
	bar.colorDisconnected = true
	bar.colorReaction = options.color_reaction
	bar.PostUpdate = PostUpdateHealth

	return bar
end

function UF:CreateHealthBar(parent, textSize, reaction, vertical)
	local health = _G.CreateFrame("StatusBar", "$parentHealthBar", parent)
	health:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
	health:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(health)

	local text = E:CreateFontString(health, textSize, "$parentHealthText", true)
	health.Text = text

	health.colorHealth = true
	health.colorDisconnected = true
	health.colorReaction = reaction
	health.PostUpdate = PostUpdateHealth

	return health
end
