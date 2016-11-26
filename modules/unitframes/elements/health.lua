local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = _G

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
			return bar.Text:SetFormattedText("%s - %s%%", E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
		elseif unit:gsub("%d+", "") == "boss" then
			return bar.Text:SetFormattedText("%s", E:NumberFormat(cur, 1))
		end
	else
		if cur == max then
			if unit == "player" or unit == "vehicle" or unit == "pet" then
				return bar.Text:SetText(nil)
			end
		else
			if unit == "target" or unit == "focus" then
				return bar.Text:SetFormattedText("%s - %s%%", E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
			elseif unit:gsub("%d+", "") == "boss" then
				return bar.Text:SetFormattedText("%s%%", E:NumberToPerc(cur, max))
			end
		end
	end

	bar.Text:SetFormattedText("%s", E:NumberFormat(cur, 1))
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
