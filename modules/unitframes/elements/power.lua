local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

local function PostUpdatePower(bar, unit, cur, max)
	-- bar.Value:SetText(E:NumberFormat(cur))
	-- bar.Value:SetVertexColor(0.4, 0.65, 0.95)
	-- bar.Value:SetVertexColor(0.11, 0.75, 0.95)
	-- local realUnit = self.__owner:GetAttribute("oUF-guessUnit") or unit
	-- if realUnit ~= "player" and realUnit ~= "vehicle" and realUnit ~= "pet" then
	-- 	if self.prevMax ~= max then
	-- 		self.prevMax = max
	-- 		if max == 0 then
	-- 			ns.UnitFrameReskin(self.__owner, "sol")
	-- 			return self:Hide(), self.Value:Hide()
	-- 		else
	-- 			ns.UnitFrameReskin(self.__owner, "sep")
	-- 			self:Show() self.Value:Show()
	-- 		end
	-- 	end
	-- end

	if not bar.Value then return end

	if max == 0 then
		return bar.Value:SetText(nil)
	elseif UnitIsDeadOrGhost(unit) then
		bar:SetValue(0)

		return bar.Value:SetText(nil)
	end

	local _, powerType = UnitPowerType(unit)
	local color = E:RGBToHEX(bar.__owner.colors.power[powerType] or bar.__owner.colors.power["FOCUS"])

	if cur < max then
		if bar.__owner.isMouseOver then
			bar.Value:SetFormattedText("%s / |cff"..color.."%s|r", E:NumberFormat(cur), E:NumberFormat(max))
		elseif cur > 0 then
			if GetCVar("statusTextDisplay") == "PERCENT" then
				bar.Value:SetFormattedText("%d|cff"..color.."%%|r", E:NumberToPerc(cur, max))
			else
				bar.Value:SetFormattedText("|cff"..color.."%s|r", E:NumberFormat(cur))
			end
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

function UF:CreatePowerBar(parent, vertical)
	local unit = parent.unit

	local power = CreateFrame("StatusBar", "$parentPowerBar", parent)
	power:SetFrameLevel(4)
	power:SetOrientation(vertical and "VERTICAL" or "HORIZONTAL")
	power:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(power)

	local tex = power:CreateTexture(nil, "OVERLAY", nil, 0)
	tex:SetTexture("Interface\\AddOns\\oUF_LS\\media\\power")
	tex:SetTexCoord(6 / 512, 26 / 512, 8 / 256, 152 / 256)
	tex:SetSize(20, 144)
	tex:SetPoint("CENTER")

	local value = E:CreateFontString(parent.Cover, 14, "$parentPowerValue", true)
	power.Value = value

	if unit == "player" then
		power:SetSize(12, 128)
		power:SetPoint("RIGHT", -19, 0)
		value:SetPoint("CENTER", 0, -8)
	end

	power.colorPower = true
	power.colorDisconnected = true
	power.frequentUpdates = true
	power.PostUpdate = PostUpdatePower

	return power
end
