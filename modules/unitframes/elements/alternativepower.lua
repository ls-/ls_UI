local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local math = _G.math

-- Blizz
local UnitGUID = _G.UnitGUID
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

-- Mine
local diffThreshold = 0.1

local function AttachGainToVerticalBar(parent, prev, max)
	local offset = parent:GetHeight() * (1 - E:Clamp(prev / max))

	parent.Gain:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Gain:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachLossToVerticalBar(parent, prev, max)
	local offset = parent:GetHeight() * (1 - E:Clamp(prev / max))

	parent.Loss:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachGainToHorizontalBar(parent, prev, max)
	local offset = parent:GetWidth() * (1 - E:Clamp(prev / max))

	parent.Gain:SetPoint("TOPLEFT", parent, "TOPRIGHT", -offset, 0)
	parent.Gain:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function AttachLossToHorizontalBar(parent, prev, max)
	local offset = parent:GetWidth() * (1 - E:Clamp(prev / max))

	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -offset, 0)
	parent.Loss:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function PostUpdate(element, unit, cur, _, max)
	if element.Inset then
		if not element:IsShown() or not max or max == 0 then
			if element.Inset:IsExpanded() then
				element.Inset:Collapse()
			end
		else
			if not element.Inset:IsExpanded() then
				element.Inset:Expand()
			end
		end
	end

	if element:IsShown() then
		local unitGUID = UnitGUID(unit)

		if max ~= 0 and unitGUID == element.lastUnitGUID then
			local prev = element._prev or 0
			local diff = cur - prev

			if math.abs(diff) / max < diffThreshold then
				diff = 0
			end

			if diff > 0 then
				if element.Gain:GetAlpha() == 0 then
					element.Gain:SetAlpha(1)

					if element:GetOrientation() == "VERTICAL" then
						AttachGainToVerticalBar(element, prev, max)
					else
						AttachGainToHorizontalBar(element, prev, max)
					end

					element.Gain.FadeOut:Play()
				end
			elseif diff < 0 then
				element.Gain.FadeOut:Stop()
				element.Gain:SetAlpha(0)

				if element.Loss:GetAlpha() == 0 then
					element.Loss:SetAlpha(1)

					if element:GetOrientation() == "VERTICAL" then
						AttachLossToVerticalBar(element, prev, max)
					else
						AttachLossToHorizontalBar(element, prev, max)
					end

					element.Loss.FadeOut:Play()
				end
			end
		else
			element.Gain.FadeOut:Stop()
			element.Gain:SetAlpha(0)

			element.Loss.FadeOut:Stop()
			element.Loss:SetAlpha(0)
		end

		element._prev = cur
		element.lastUnitGUID = unitGUID
	else
		return element.Text and element.Text:SetText(nil)
	end

	if not element.Text then
		return
	else
		if max == 0 then
			return element.Text:SetText(nil)
		elseif UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
			element:SetValue(0)

			return element.Text:SetText(nil)
		end
	end

	local _, r, g, b = _G.UnitAlternatePowerTextureInfo(unit, 2)

	if (r == 1 and g == 1 and b == 1) or not b then
		r, g, b = M.COLORS.INDIGO:GetRGB()
	end

	local hex = E:RGBToHEX(E:AdjustColor(r, g, b, 0.2))

	element:SetStatusBarColor(r, g, b)

	if element.__owner.isMouseOver then
		return element.Text:SetFormattedText(L["BAR_COLORED_DETAILED_VALUE_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberFormat(max, 1), hex)
	else
		if cur == max or cur == 0 then
			return element.Text:SetText(nil)
		end
	end

	element.Text:SetFormattedText(L["BAR_COLORED_VALUE_TEMPLATE"], E:NumberFormat(cur, 1), hex)
end

function UF:CreateAlternativePower(parent, text, textFontObject, textParent)
	local element = _G.CreateFrame("StatusBar", "$parentPowerBar", parent)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	E:SmoothBar(element)

	if text then
		text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
		text:SetWordWrap(false)
		E:ResetFontStringHeight(text)
		element.Text = text
	end

	local gainTexture = element:CreateTexture(nil, "ARTWORK", nil, 1)
	gainTexture:SetColorTexture(M.COLORS.LIGHT_GREEN:GetRGB())
	gainTexture:SetAlpha(0)
	element.Gain = gainTexture

	local lossTexture = element:CreateTexture(nil, "BACKGROUND")
	lossTexture:SetColorTexture(M.COLORS.DARK_RED:GetRGB())
	lossTexture:SetAlpha(0)
	element.Loss = lossTexture

	local ag = gainTexture:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	gainTexture.FadeOut = ag

	local anim1 = ag:CreateAnimation("Alpha")
	anim1:SetOrder(1)
	anim1:SetFromAlpha(1)
	anim1:SetToAlpha(0)
	anim1:SetStartDelay(0.6)
	anim1:SetDuration(0.2)

	ag = lossTexture:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	lossTexture.FadeOut = ag

	anim1 = ag:CreateAnimation("Alpha")
	anim1:SetOrder(1)
	anim1:SetFromAlpha(1)
	anim1:SetToAlpha(0)
	anim1:SetStartDelay(0.6)
	anim1:SetDuration(0.2)

	element.PostUpdate = PostUpdate

	return element
end

function UF:UpdateAlternativePower(frame)
	local config = frame._config.alt_power
	local element = frame.AlternativePower

	element:SetOrientation(config.orientation)

	if element.Text then
		element.Text:SetJustifyV(config.text.v_alignment or "MIDDLE")
		element.Text:SetJustifyH(config.text.h_alignment or "CENTER")

		local point1 = config.text.point1

		element.Text:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)

		local point2 = config.text.point2

		if point2 then
			element.Text:SetPoint(point2.p, E:ResolveAnchorPoint(frame, point2.anchor), point2.rP, point2.x, point2.y)
		end
	end

	if config.orientation == "HORIZONTAL" then
		element.Gain:SetPoint("TOPRIGHT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		element.Gain:SetPoint("BOTTOMRIGHT", element:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

		element.Loss:SetPoint("TOPLEFT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		element.Loss:SetPoint("BOTTOMLEFT", element:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	else
		element.Gain:SetPoint("TOPLEFT", element:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		element.Gain:SetPoint("TOPRIGHT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)

		element.Loss:SetPoint("BOTTOMLEFT", element:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		element.Loss:SetPoint("BOTTOMRIGHT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	end

	frame._mouseovers[element] = config.update_on_mouseover and true or nil

	if config.enabled and not frame:IsElementEnabled("AlternativePower") then
		frame:EnableElement("AlternativePower")
	elseif not config.enabled and frame:IsElementEnabled("AlternativePower") then
		frame:DisableElement("AlternativePower")
	end

	if frame:IsElementEnabled("AlternativePower") then
		element:ForceUpdate()
	end
end
