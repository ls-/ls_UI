local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
local function PostUpdate(element, _, cur, max)
	if element:IsShown() then
		element:UpdateGainLoss(cur, max)
	end
end

function UF:CreateAdditionalPower(parent)
	local element = _G.CreateFrame("StatusBar", "$parentAdditionalPowerBar", parent)
	element:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")

	E:SmoothBar(element)
	E:CreateGainLossIndicators(element)

	element.colorPower = true
	element.PostUpdate = PostUpdate

	return element
end

function UF:UpdateAdditionalPower(frame)
	local config = frame._config.add_power
	local element = frame.AdditionalPower

	element:SetOrientation(config.orientation)

	E:ReanchorGainLossIndicators(element, config.orientation)

	if config.enabled and not frame:IsElementEnabled("AdditionalPower") then
		frame:EnableElement("AdditionalPower")
	elseif not config.enabled and frame:IsElementEnabled("AdditionalPower") then
		frame:DisableElement("AdditionalPower")
	end

	if frame:IsElementEnabled("AdditionalPower") then
		element:ForceUpdate()
	end
end
