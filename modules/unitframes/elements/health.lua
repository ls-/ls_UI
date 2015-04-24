local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

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
		color = E:RGBToHEX(bar.__owner.colors.disconnected)

		return bar.Value:SetFormattedText("|cff"..color.."%s|r", PLAYER_OFFLINE)
	elseif UnitIsDeadOrGhost(unit) then
		color = E:RGBToHEX(bar.__owner.colors.disconnected)

		-- for some locales DEAD string is loosely translated
		return bar.Value:SetFormattedText("|cff"..color.."%s|r", gsub(unit == "player" and SPELL_FAILED_CASTER_DEAD or DEAD, "[.]", ""))
	end

	if cur < max then
		if bar.__owner.isMouseOver then
			bar.Value:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
		else
			if GetCVar("statusTextDisplay") == "PERCENT" then
				bar.Value:SetFormattedText("|cffffffff%d%%|r", E:NumberToPerc(cur, max))
			else
				bar.Value:SetFormattedText("|cffffffff%s|r", E:NumberFormat(cur, 1))
			end
		end
	else
		if bar.__owner.isMouseOver then
			bar.Value:SetFormattedText("|cffffffff%s|r", E:NumberFormat(max, 1))
		else
			bar.Value:SetText(nil)
		end
	end
end

function UF:CreateHealthBar(parent, vertical, textsize, reaction, lowhp)
	local unit = parent.unit

	local health = CreateFrame("StatusBar", "$parentHealthBar", parent)
	health:SetFrameLevel(2) -- +1
	health:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
	health:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(health)

	local value = E:CreateFontString(parent.Cover, textsize, "$parentHealthValue", true)
	health.Value = value

	if lowhp then
		local glow = parent.Cover:CreateTexture(nil, "ARTWORK", nil, 3)
		glow:SetTexture("Interface\\AddOns\\oUF_LS\\media\\frame_player")
		glow:SetTexCoord(98 / 512, 198 / 512, 202 / 512, 340 / 512)
		glow:SetSize(100, 138)
		glow:SetPoint("CENTER")
		glow:SetVertexColor(0.9, 0.15, 0.15)
		glow:SetAlpha(0)
		health.LowHP = glow
	end

	health.colorHealth = true
	health.colorDisconnected = true
	health.colorReaction = reaction
	health.PostUpdate = PostUpdateHealth

	return health
end