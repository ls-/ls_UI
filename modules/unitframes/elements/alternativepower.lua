local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function PostUpdateAltPower(bar, unit, cur, _, max)
	if not bar.Text then return end

	local _, r, g, b = _G.UnitAlternatePowerTextureInfo(unit, 2)

	if (r == 1 and g == 1 and b == 1) or not b then
		r, g, b = M.COLORS.INDIGO:GetRGB()
	end

	bar:SetStatusBarColor(r, g, b)

	if bar.isMouseOver then
		return bar.Text:SetFormattedText(L["BAR_COLORED_DETAILED_VALUE_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberFormat(max, 1), E:RGBToHEX(r, g, b))
	else
		if cur == max or cur == 0 then
			return bar.Text:SetText(nil)
		end
	end

	bar.Text:SetFormattedText(L["BAR_VALUE_TEMPLATE"], E:NumberFormat(cur))
end

local function OnEnter(self)
	if not self:IsVisible() then return end

	self.isMouseOver = true
	self:ForceUpdate()

	_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, self)
	self:UpdateTooltip()
end

local function OnLeave(self)
	self.isMouseOver = nil
	self:ForceUpdate()

	_G.GameTooltip:Hide()
end

function UF:CreateAltPowerBar(parent, width)
	local bar = E:CreateStatusBar(parent, "$parentAltPowerBar", "HORIZONTAL")
	bar:SetSize(width - 16, 12)
	bar:EnableMouse(true)
	bar:SetScript("OnEnter", OnEnter)
	bar:SetScript("OnLeave", OnLeave)
	E:SmoothBar(bar)
	E:SetStatusBarSkin(bar, "HORIZONTAL-L")

	bar.Text:SetPoint("TOPLEFT", 1, 0)
	bar.Text:SetPoint("BOTTOMRIGHT", -1, 0)

	bar.colorTexture = true
	bar.PostUpdate = PostUpdateAltPower

	return bar
end
