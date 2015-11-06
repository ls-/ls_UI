local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local COLORS = M.colors
local UF = E.UF

local unpack = unpack

local function PostUpdateAltPower(bar, min, cur, max)
	if not bar.Value then return end

	local _, r, g, b = UnitAlternatePowerTextureInfo(bar.__owner.unit, 2)

	if (r == 1 and g == 1 and b == 1) or not b then
		r, g, b = unpack(COLORS.indigo)
	end

	bar:SetStatusBarColor(r, g, b)

	if cur < max then
		if bar.isMouseOver then
			bar.Value:SetFormattedText("%s / %s - %d%%", E:NumberFormat(cur), E:NumberFormat(max), E:NumberToPerc(cur, max))
		elseif cur > 0 then
			bar.Value:SetFormattedText("%s", E:NumberFormat(cur))
		else
			bar.Value:SetText(nil)
		end
	else
		if bar.isMouseOver then
			bar.Value:SetFormattedText("%s", E:NumberFormat(cur))
		else
			bar.Value:SetText(nil)
		end
	end
end

local function OnEnter(self)
	if not self:IsVisible() then return end

	self.isMouseOver = true
	self:ForceUpdate()

	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:UpdateTooltip()
end

local function OnLeave(self)
	self.isMouseOver = nil
	self:ForceUpdate()

	GameTooltip:Hide()
end

function UF:CreateAltPowerBar(parent, width, coords, preset)
	local bar = E:CreateStatusBar(parent, parent:GetName().."AltPowerBar", width - tonumber(preset), preset or "14", true)
	bar:SetPoint(unpack(coords))
	bar:EnableMouse(true)
	bar:SetScript("OnEnter", OnEnter)
	bar:SetScript("OnLeave", OnLeave)
	E:SmoothBar(bar)

	bar.Value = bar.Text
	bar.colorTexture = true
	bar.PostUpdate = PostUpdateAltPower

	return bar
end
