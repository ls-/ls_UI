local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local m_abs = _G.math.abs

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
		if not max or max == 0 then
			element.Inset:Collapse()
		else
			element.Inset:Expand()
		end
	end

	if element:IsShown() then
		local unitGUID = UnitGUID(unit)

		if max ~= 0 and unitGUID == element.lastUnitGUID then
			local prev = element._prev or 0
			local diff = cur - prev

			if m_abs(diff) / max < diffThreshold then
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

	local r, g, b = element:GetStatusBarColor()
	local hex = E:RGBToHEX(E:AdjustColor(r, g, b, 0.2))

	if element.__owner.isMouseOver then
		if unit ~= "player" and unit ~= "vehicle" and unit ~= "pet" then
			return element.Text:SetFormattedText(L["BAR_COLORED_DETAILED_VALUE_TEMPLATE"], E:NumberFormat(cur, 1), E:NumberFormat(max, 1), hex)
		end
	else
		if cur == max or cur == 0 then
			if unit == "player" or unit == "vehicle" or unit == "pet" then
				return element.Text:SetText(nil)
			end
		end
	end

	element.Text:SetFormattedText(L["BAR_COLORED_VALUE_TEMPLATE"], E:NumberFormat(cur, 1), hex)
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
		element.Text:ClearAllPoints()

		local point1 = config.text.point1

		if point1 and point1.p then
			element.Text:SetPoint(point1.p, E:ResolveAnchorPoint(frame, point1.anchor), point1.rP, point1.x, point1.y)
		end

		local point2 = config.text.point2

		if point2 and point2.p then
			element.Text:SetPoint(point2.p, E:ResolveAnchorPoint(frame, point2.anchor), point2.rP, point2.x, point2.y)
		end
	end

	if config.orientation == "HORIZONTAL" then
		element.Gain:ClearAllPoints()
		element.Gain:SetPoint("TOPRIGHT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		element.Gain:SetPoint("BOTTOMRIGHT", element:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

		element.Loss:ClearAllPoints()
		element.Loss:SetPoint("TOPLEFT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		element.Loss:SetPoint("BOTTOMLEFT", element:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	else
		element.Gain:ClearAllPoints()
		element.Gain:SetPoint("TOPLEFT", element:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		element.Gain:SetPoint("TOPRIGHT", element:GetStatusBarTexture(), "TOPRIGHT", 0, 0)

		element.Loss:ClearAllPoints()
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
