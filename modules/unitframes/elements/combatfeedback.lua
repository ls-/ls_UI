local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local function frame_UpdateCombatFeedback(self)
	local config = self._config.combat_feedback
	local element = self.FloatingCombatFeedback

	element.mode = config.mode
	element.xOffset = config.x_offset
	element.yOffset = config.y_offset

	if config.enabled and not self:IsElementEnabled("FloatingCombatFeedback") then
		self:EnableElement("FloatingCombatFeedback")
	elseif not config.enabled and self:IsElementEnabled("FloatingCombatFeedback") then
		self:DisableElement("FloatingCombatFeedback")
	end

	if self:IsElementEnabled("FloatingCombatFeedback") then
		element:ForceUpdate()
	end
end

function UF:CreateCombatFeedback(frame)
	local element = CreateFrame("Frame", nil, frame)
	element:SetSize(32, 32)

	for i = 1, 6 do
		element[i] = element:CreateFontString(nil, "OVERLAY", "CombatTextFont")
	end

	element.abbreviateNumbers = true

	frame.UpdateCombatFeedback = frame_UpdateCombatFeedback

	return element
end
