local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

-- Mine
function UF:CreateCombatFeedback(parent)
	local element = _G.CreateFrame("Frame", "$parentFeedbackFrame", parent)
	element:SetSize(32, 32)

	for i = 1, 6 do
		element[i] = element:CreateFontString(nil, "OVERLAY", "CombatTextFont")
	end

	element.abbreviateNumbers = true

	return element
end

function UF:UpdateCombatFeedback(frame)
	local config = frame._config.combat_feedback
	local element = frame.FloatingCombatFeedback

	element.mode = config.mode
	element.xOffset = config.x_offset
	element.yOffset = config.y_offset

	if config.enabled and not frame:IsElementEnabled("FloatingCombatFeedback") then
		frame:EnableElement("FloatingCombatFeedback")
	elseif not config.enabled and frame:IsElementEnabled("FloatingCombatFeedback") then
		frame:DisableElement("FloatingCombatFeedback")
	end

	if frame:IsElementEnabled("FloatingCombatFeedback") then
		element:ForceUpdate()
	end
end
