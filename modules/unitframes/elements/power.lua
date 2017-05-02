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

local function CalcMult(prev, max)
	local d = prev / max

	return 1 - E:Clamp(d)
end

local function AttachGainToVerticalBar(parent, prev, max)
	local offset = parent:GetHeight() * CalcMult(prev, max)

	parent.Gain:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Gain:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachLossToVerticalBar(parent, prev, max)
	local offset = parent:GetHeight() * CalcMult(prev, max)

	parent.Loss:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -offset)
	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -offset)
end

local function AttachGainToHorizontalBar(parent, prev, max)
	local offset = parent:GetWidth() * CalcMult(prev, max)

	parent.Gain:SetPoint("TOPLEFT", parent, "TOPRIGHT", -offset, 0)
	parent.Gain:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function AttachLossToHorizontalBar(parent, prev, max)
	local offset = parent:GetWidth() * CalcMult(prev, max)

	parent.Loss:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -offset, 0)
	parent.Loss:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, 0)
end

local function PostUpdate(bar, unit, cur, _, max)
	if bar.Inset then
		if not max or max == 0 then
			bar.Inset:Collapse()
		else
			bar.Inset:Expand()
		end
	end

	if bar:IsShown() then
		local unitGUID = UnitGUID(unit)

		if max ~= 0 and unitGUID == bar.lastUnitGUID then
			local prev = bar.prev or 0
			local diff = cur - prev

			if math.abs(diff) / max < diffThreshold then
				diff = 0
			end

			if diff > 0 then
				if bar.Gain:GetAlpha() == 0 then
					bar.Gain:SetAlpha(1)

					if bar:GetOrientation() == "VERTICAL" then
						AttachGainToVerticalBar(bar, prev, max)
					else
						AttachGainToHorizontalBar(bar, prev, max)
					end

					bar.Gain.FadeOut:Play()
				end
			elseif diff < 0 then
				bar.Gain.FadeOut:Stop()
				bar.Gain:SetAlpha(0)

				if bar.Loss:GetAlpha() == 0 then
					bar.Loss:SetAlpha(1)

					if bar:GetOrientation() == "VERTICAL" then
						AttachLossToVerticalBar(bar, prev, max)
					else
						AttachLossToHorizontalBar(bar, prev, max)
					end

					bar.Loss.FadeOut:Play()
				end
			end
		else
			bar.Gain.FadeOut:Stop()
			bar.Gain:SetAlpha(0)

			bar.Loss.FadeOut:Stop()
			bar.Loss:SetAlpha(0)
		end

		bar.prev = cur
		bar.lastUnitGUID = unitGUID
	end

	if max == 0 then
		return bar.Text:SetText(nil)
	elseif UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
		bar:SetValue(0)

		return bar.Text:SetText(nil)
	end

	local r, g, b = bar:GetStatusBarColor()
	local color = E:RGBToHEX(E:AdjustColor(r, g, b, 0.3))

	if bar.__owner.isMouseOver then
		if unit ~= "player" and unit ~= "vehicle" and unit ~= "pet" then
			return bar.Text:SetFormattedText(L["BAR_COLORED_DETAILED_VALUE_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberFormat(max, 1), color)
		end
	else
		if cur == max or cur == 0 then
			if unit == "player" or unit == "vehicle" or unit == "pet" then
				return bar.Text:SetText(nil)
			end
		end
	end

	bar.Text:SetFormattedText(L["BAR_COLORED_VALUE_TEMPLATE"], E:NumberFormat(cur, 1), color)
end

function UF:CreatePower(parent, text, textFontObject, textParent)
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

	element.colorPower = true
	element.colorDisconnected = true
	element.frequentUpdates = true
	element.PostUpdate = PostUpdate

	return element
end

function UF:UpdatePower(frame)
	local config = frame._config.power
	local element = frame.Power

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

	if config.enabled and not frame:IsElementEnabled("Power") then
		frame:EnableElement("Power")
	elseif not config.enabled and frame:IsElementEnabled("Power") then
		frame:DisableElement("Power")
	end

	if frame:IsElementEnabled("Power") then
		element:ForceUpdate()
	end
end
