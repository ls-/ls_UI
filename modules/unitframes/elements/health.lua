local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

-- Lua
local _G = _G
local strmatch = string.match

-- Blizz
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local DEAD = DEAD
local PLAYER_OFFLINE = PLAYER_OFFLINE

-- Mine
local function PostUpdateHealth(bar, unit, cur, max)
	if not bar.Text then return end

	local color

	if not UnitIsConnected(unit) then
		color = E:RGBToHEX(M.colors.disconnected)

		return bar.Text:SetFormattedText("|cff"..color.."%s|r", PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		color = E:RGBToHEX(M.colors.disconnected)

		return bar.Text:SetFormattedText("|cff"..color.."%s|r", DEAD)
	end

	if cur == max then
		if bar.__owner.isMouseOver then
			if unit == "target" or unit == "focus" then
				bar.Text:SetFormattedText("|cffffffff%s - %d%%|r", E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
			else
				bar.Text:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
			end
		else
			if unit == "player" or unit == "vehicle" or unit == "pet" then
				bar.Text:SetText(nil)
			else
				bar.Text:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
			end
		end
	else
		if bar.__owner.isMouseOver then
			if unit == "target" or unit == "focus" then
				bar.Text:SetFormattedText("|cffffffff%s - %d%%|r", E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
			else
				bar.Text:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
			end
		else
			bar.Text:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
		end
	end
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
