local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local UF = P:GetModule("UnitFrames")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

-- Mine
local function update(self)
	if not (self.unit and self:IsShown()) then
		return
	end

	local element = self.ClassIndicator
	local color = C.db.global.colors.white

	if element._config then
		if element._config.color.class and UnitIsPlayer(self.unit) and UnitClass(self.unit) then
			local _, class = UnitClass(self.unit)
			color = C.db.global.colors.class[class]
		elseif element._config.color.reaction and UnitReaction(self.unit, "player") then
			local reaction = UnitReaction(self.unit, "player")
			color = C.db.global.colors.reaction[reaction]
		else
			local class = UnitClassification(self.unit)
			if class and (class == "worldboss" or class == "elite" or class == "rareelite") then
				color = C.db.global.colors.yellow
			end
		end
	end

	if not self.__color or not self.__color:IsEqualTo(color) then
		self.Border:SetVertexColor(color:GetRGB())

		if self.Insets then
			self.Insets:SetVertexColor(color:GetRGB())
		end

		self.__color = color
	end
end

local element_proto = {}

function element_proto:UpdateConfig()
	local unit = self.__owner.__unit
	self._config = E:CopyTable(C.db.profile.units[unit].border, self._config)
end

function element_proto:ForceUpdate()
	update(self.__owner)
end

local frame_proto = {}

function frame_proto:UpdateClassIndicator()
	self.ClassIndicator:UpdateConfig()
	update(self)
end

function UF:CreateClassIndicator(frame)
	Mixin(frame, frame_proto)

	hooksecurefunc(frame, "Show", update)

	if frame.Border then
		E:SmoothColor(frame.Border)
	end

	if frame.Insets then
		E:SmoothColor(frame.Insets)
	end

	return Mixin({
		__owner = frame,
		__color = {},
	}, element_proto)
end
