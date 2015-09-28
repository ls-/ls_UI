local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M
local UF = E.UF
local POWERCOLORS = M.colors.power

local UnitIsDeadOrGhost, UnitIsConnected = UnitIsDeadOrGhost, UnitIsConnected

local function PostUpdatePower(bar, unit, cur, max)
	if bar.Tube then
		if max == 0 then
			for i = 1, #bar.Tube do
				bar.Tube[i]:Hide()
			end
		else
			for i = 1, #bar.Tube do
				bar.Tube[i]:Show()
			end
		end
	end

	if not bar.Value then return end

	if max == 0 then
		return bar.Value:SetText(nil)
	elseif UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)

		return bar.Value:SetText(nil)
	end

	local color = E:RGBToHEX(bar:GetStatusBarColor())

	if cur < max then
		if bar.__owner.isMouseOver then
			bar.Value:SetFormattedText("%s / |cff"..color.."%s|r", E:NumberFormat(cur), E:NumberFormat(max))
		elseif cur > 0 then
			bar.Value:SetFormattedText("|cff"..color.."%s|r", E:NumberFormat(cur))
		else
			bar.Value:SetText(nil)
		end
	else
		if bar.__owner.isMouseOver then
			bar.Value:SetFormattedText("|cff"..color.."%s|r", E:NumberFormat(cur))
		else
			bar.Value:SetText(nil)
		end
	end
end

function UF:CreatePowerBar(parent, textsize, textbg, vertical)
	local unit = parent.unit

	local power = CreateFrame("StatusBar", "$parentPowerBar", parent)
	power:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
	power:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(power)

	local value = E:CreateFontString(power, textsize, "$parentPowerValue", true)
	power.Value = value

	if textbg then
		local shadow = power:CreateTexture(nil, "OVERLAY", nil, 1)
		shadow:SetTexture("Interface\\Scenarios\\Objective-Lineglow")
		shadow:SetTexCoord(0, 1, 0, 13 / 16)
		shadow:SetVertexColor(0, 0, 0)
		shadow:SetPoint("TOPLEFT", value, "TOPLEFT", 0, -2)
		shadow:SetPoint("BOTTOMRIGHT", value, "BOTTOMRIGHT", 0, 2)
	end

	power.colorPower = true
	power.colorDisconnected = true
	power.frequentUpdates = true
	power.PostUpdate = PostUpdatePower

	return power
end
