local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	CreateFrame
]]

-- Mine
local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].combat_feedback, self._config)
end

local function frame_UpdateCombatFeedback(self)
	local element = self.FloatingCombatFeedback
	element:UpdateConfig()

	element.mode = element._config.mode
	element.xOffset = element._config.x_offset
	element.yOffset = element._config.y_offset

	if element._config.enabled and not self:IsElementEnabled("FloatingCombatFeedback") then
		self:EnableElement("FloatingCombatFeedback")
	elseif not element._config.enabled and self:IsElementEnabled("FloatingCombatFeedback") then
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
	element.UpdateConfig = element_UpdateConfig

	frame.UpdateCombatFeedback = frame_UpdateCombatFeedback

	return element
end
