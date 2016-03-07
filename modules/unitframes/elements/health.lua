local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")
local COLORS = M.colors

local function PostUpdateHealth(bar, unit, cur, max)
	if not bar.Value then return end

	local color
	if not UnitIsConnected(unit) then
		color = E:RGBToHEX(COLORS.disconnected)

		return bar.Value:SetFormattedText("|cff"..color.."%s|r", PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		color = E:RGBToHEX(COLORS.disconnected)

		return bar.Value:SetFormattedText("|cff"..color.."%s|r", DEAD)
	end

	local pattern = (unit == "target" or unit == "focus") and "|cffffffff%s - %d%%|r" or "|cffffffff%s|r"

	if cur < max then
		if bar.__owner.isMouseOver then
			bar.Value:SetFormattedText(pattern, E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
		else
			bar.Value:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
		end
	else
		if bar.__owner.isMouseOver then
			bar.Value:SetFormattedText(pattern, E:NumberFormat(cur, 1), E:NumberToPerc(cur, max))
		else
			bar.Value:SetText(nil)
		end
	end
end

function UF:CreateHealthBar(parent, textsize, reaction, vertical)
	local health = CreateFrame("StatusBar", "$parentHealthBar", parent)
	health:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
	health:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(health)

	health.colorHealth = true
	health.colorDisconnected = true
	health.colorReaction = reaction
	health.PostUpdate = PostUpdateHealth

	return health
end
