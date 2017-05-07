local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Blizz
local UnitGUID = _G.UnitGUID
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

-- Mine
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

		element:UpdateGainLoss(cur, max, unitGUID == element._UnitGUID)

		element._UnitGUID = unitGUID
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
	local element = _G.CreateFrame("StatusBar", nil, parent)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")

	if text then
		text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
		text:SetWordWrap(false)
		E:ResetFontStringHeight(text)
		element.Text = text
	end

	E:SmoothBar(element)
	E:CreateGainLossIndicators(element)

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

	E:ReanchorGainLossIndicators(element, config.orientation)

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
