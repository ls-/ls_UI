local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local UF = E:GetModule("UnitFrames")

-- Lua
local _G = _G

-- Blizz
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

-- Mine
local function PostUpdatePower(bar, unit, cur, max)
	if bar.Tube then
		if max == 0 then
			for i = 0, #bar.Tube do
				bar.Tube[i]:Hide()
			end
		else
			for i = 0, #bar.Tube do
				bar.Tube[i]:Show()
			end
		end
	end

	if not bar.Text then return end

	if max == 0 then
		return bar.Text:SetText(nil)
	elseif UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)

		return bar.Text:SetText(nil)
	end

	local color = E:RGBToHEX(bar:GetStatusBarColor())

	if cur == max then
		if bar.__owner.isMouseOver then
			bar.Text:SetFormattedText("|cff"..color.."%s|r", E:NumberFormat(cur, 1))
		else
			if unit == "player" or unit == "vehicle" or unit == "pet" then
				bar.Text:SetText(nil)
			else
				bar.Text:SetFormattedText("|cff"..color.."%s|r", E:NumberFormat(cur, 1))
			end
		end
	else
		if bar.__owner.isMouseOver then
			bar.Text:SetFormattedText("%s / |cff"..color.."%s|r", E:NumberFormat(cur, 1), E:NumberFormat(max, 1))
		else
			bar.Text:SetFormattedText("|cff"..color.."%s|r", E:NumberFormat(cur, 1))
		end
	end
end

function UF:CreatePowerBar(parent, textSize, textBg, vertical)
	local power = _G.CreateFrame("StatusBar", "$parentPowerBar", parent)
	power:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
	power:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(power)

	local text = E:CreateFontString(power, textSize, "$parentPowerValue", true)
	power.Text = text

	if textBg then
		local shadow = power:CreateTexture(nil, "ARTWORK", nil, 7)
		shadow:SetTexture("Interface\\Scenarios\\Objective-Lineglow")
		shadow:SetTexCoord(0, 1, 0, 13 / 16)
		shadow:SetVertexColor(0, 0, 0)
		shadow:SetPoint("TOPLEFT", text, "TOPLEFT", 0, -2)
		shadow:SetPoint("BOTTOMRIGHT", text, "BOTTOMRIGHT", 0, 2)
	end

	power.colorPower = true
	power.colorDisconnected = true
	power.frequentUpdates = true
	power.PostUpdate = PostUpdatePower

	return power
end
