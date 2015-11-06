local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E.UF
local COLORS = M.colors

local function PostUpdateHealth(bar, unit, cur, max)
	if bar.LowHP then
		if E:NumberToPerc(cur, max) <= 25 and cur > 1 then
			E:Blink(bar.LowHP, 0.5)
		else
			E:StopBlink(bar.LowHP)
		end
	end

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

function UF:CreateHealthBar(parent, textsize, reaction, vertical, lowhp)
	local unit = parent.unit

	local health = CreateFrame("StatusBar", "$parentHealthBar", parent)
	health:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
	health:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(health)

	local value = E:CreateFontString(health, textsize, "$parentHealthValue", true)
	health.Value = value

	if lowhp then
		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
		glow:SetTexCoord(98 / 512, 198 / 512, 202 / 512, 340 / 512)
		glow:SetSize(100, 138)
		glow:SetPoint("CENTER")
		glow:SetVertexColor(unpack(COLORS.red))
		glow:SetAlpha(0)
		health.LowHP = glow
	end

	health.colorHealth = true
	health.colorDisconnected = true
	health.colorReaction = reaction
	health.PostUpdate = PostUpdateHealth

	return health
end