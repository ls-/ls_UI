local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

--[[ luacheck: globals
	UnitClass UnitClassification UnitIsPlayer
]]

-- Mine
local function update(self)
	local element = self.ClassIndicator
	local class, _

	if UnitIsPlayer(self.unit) then
		if element._config and element._config.player then
			_, class = UnitClass(self.unit)
			if class and self._skin ~= class then
				self.Border:SetVertexColor(E:GetRGB(C.db.global.colors.class[class]))

				if self.Insets then
					self.Insets:SetVertexColor(E:GetRGB(C.db.global.colors.class[class]))
				end

				self._skin = class

				return
			end
		end
	else
		if element._config and element._config.npc then
			class = UnitClassification(self.unit)
			if class and (class == "worldboss" or class == "elite" or class == "rareelite") then
				if self._skin ~= "elite" then
					self.Border:SetVertexColor(E:GetRGB(C.db.global.colors.yellow))

					if self.Insets then
						self.Insets:SetVertexColor(E:GetRGB(C.db.global.colors.yellow))
					end

					self._skin = "elite"

					return
				end
			else
				class = nil
			end
		end
	end

	if not class and self._skin ~= "none" then
		self.Border:SetVertexColor(1, 1, 1)

		if self.Insets then
			self.Insets:SetVertexColor(1, 1, 1)
		end

		self._skin = "none"
	end
end

local function element_UpdateConfig(self)
	local unit = self.__owner._unit
	self._config = E:CopyTable(C.db.profile.units[unit].class, self._config)
end

local function frame_UpdateClassIndicator(self)
	self.ClassIndicator:UpdateConfig()
	update(self)
end

function UF:CreateClassIndicator(frame)
	frame._skin = "none"

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
		UpdateConfig = element_UpdateConfig,
	}
end
