local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

--[[ luacheck: globals
	UnitClass UnitClassification UnitIsPlayer UnitReaction
]]

-- Mine
local function update(self)
	if not (self.unit and self:IsShown()) then return end

	local element = self.ClassIndicator
	local color = C.db.global.colors.white

	if element._config then
		if element._config.color.class and UnitIsPlayer(self.unit) and UnitClass(self.unit) then
			local _, class = UnitClass(self.unit)
			color = C.db.global.colors.class[class]
		elseif element._config.color.selection then
			color = E:GetUnitSelectionColor(self.unit)
		elseif element._config.color.reaction and UnitReaction(self.unit, "player") then
			local reaction = UnitReaction(self.unit, "player")
			color = C.db.profile.colors.reaction[reaction]
		else
			local class = UnitClassification(self.unit)
			if class and (class == "worldboss" or class == "elite" or class == "rareelite") then
				color = C.db.global.colors.yellow
			end
		end
	end

	if not self._color or not E:AreColorsEqual(self._color, color) then
		self.Border:SetVertexColor(E:GetRGB(color))

		if self.Insets then
			self.Insets:SetVertexColor(E:GetRGB(color))
		end

		self._color = self._color or {}
		E:SetRGB(self._color, E:GetRGB(color))
	end
end

local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].border, self._config)
end

local function element_ForceUpdate(self)
	update(self.__owner)
end

local function frame_UpdateClassIndicator(self)
	self.ClassIndicator:UpdateConfig()
	update(self)
end

function UF:CreateClassIndicator(frame)
	hooksecurefunc(frame, "Show", update)

	if frame.Border then
		E:SmoothColor(frame.Border)
	end

	if frame.Insets then
		E:SmoothColor(frame.Insets)
	end

	frame.UpdateClassIndicator = frame_UpdateClassIndicator

	return {
		__owner = frame,
		_color = {},
		ForceUpdate = element_ForceUpdate,
		UpdateConfig = element_UpdateConfig,
	}
end
