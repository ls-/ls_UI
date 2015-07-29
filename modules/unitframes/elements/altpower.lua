local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

local UF = E.UF

local function PostUpdateAltPower(bar, min, cur, max)
	if not bar.Value then return end

	local _, r, g, b = UnitAlternatePowerTextureInfo(bar.__owner.unit, 2)

	if (r == 1 and g == 1 and b == 1) or not b then
		r, g, b = 0.4, 0.65, 0.95
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
	self:UpdateTooltip()
end

local function OnLeave(self)
	self.isMouseOver = nil
	self:ForceUpdate()

	GameTooltip:Hide()
end

function UF:CreateAltPowerBar(parent, width, coords)
	local bar = CreateFrame("StatusBar", parent:GetName().."AltPowerBar", parent)
	bar:SetStatusBarTexture(M.textures.statusbar)
	bar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 1)
	bar:SetSize(width, 18)
	bar:SetPoint(unpack(coords))
	bar:EnableMouse(true)
	bar:SetScript("OnEnter", OnEnter)
	bar:SetScript("OnLeave", OnLeave)
	E:SmoothBar(bar)
	E:CreateBorder(bar, 8)

	local bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetAllPoints()
	bg:SetTexture(0.15, 0.15, 0.15, 1)

	local value = E:CreateFontString(bar, 10, "$parentAltPowerValue", true)
	bar.Value = value

	bar.colorTexture = true
	bar.PostUpdate = PostUpdateAltPower

	return bar
end
