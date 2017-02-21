local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local unpack = unpack

-- Mine
local function PostUpdateAltPower(bar, min, cur, max)
	if not bar.Text then return end

	local _, r, g, b = _G.UnitAlternatePowerTextureInfo(bar.__owner.unit, 2)

	if (r == 1 and g == 1 and b == 1) or not b then
		r, g, b = M.COLORS.INDIGO:GetRGB()
	end

	bar:SetStatusBarColor(r, g, b)

	if cur < max then
		if bar.isMouseOver then
			bar.Text:SetFormattedText("%s / %s - %d%%", E:NumberFormat(cur), E:NumberFormat(max), E:NumberToPerc(cur, max))
		elseif cur > 0 then
			bar.Text:SetFormattedText("%s", E:NumberFormat(cur))
		else
			bar.Text:SetText(nil)
		end
	else
		if bar.isMouseOver then
			bar.Text:SetFormattedText("%s", E:NumberFormat(cur))
		else
			bar.Text:SetText(nil)
		end
	end
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
	bar:SetSize(width - 8, 12)
	bar:EnableMouse(true)
	bar:SetScript("OnEnter", OnEnter)
	bar:SetScript("OnLeave", OnLeave)
	E:SmoothBar(bar)
	E:SetStatusBarSkin(bar, "HORIZONTAL-BIG")

	bar.Text:SetPoint("TOPLEFT", 1, 0)
	bar.Text:SetPoint("BOTTOMRIGHT", -1, 0)

	bar.colorTexture = true
	bar.PostUpdate = PostUpdateAltPower

	return bar
end
