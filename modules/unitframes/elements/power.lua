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
		if not max or max == 0 then
			element.Inset:Collapse()
		else
			element.Inset:Expand()
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

	if text then
		text = (textParent or element):CreateFontString(nil, "ARTWORK", textFontObject)
		text:SetWordWrap(false)
		E:ResetFontStringHeight(text)
		element.Text = text
	end

	E:SmoothBar(element)
	E:CreateGainLossIndicators(element)

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

	E:ReanchorGainLossIndicators(element, config.orientation)

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
