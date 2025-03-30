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
	local border = "Interface\\AddOns\\ls_UI\\assets\\border-thick"
	local glow = "Interface\\AddOns\\ls_UI\\assets\\border-thick-glow"

	if element._config then
		if UnitIsPlayer(self.unit) then
			border = "Interface\\AddOns\\ls_UI\\assets\\border-thick-player"
			glow = "Interface\\AddOns\\ls_UI\\assets\\border-thick-player-glow"

			if element._config.color.class then
				local _, class = UnitClass(self.unit)
				class = class or "WARRIOR"
				color = C.db.global.colors.class[class]
			elseif element._config.color.reaction then
				local reaction = UnitReaction(self.unit, "player") or 4
				color = C.db.global.colors.reaction[reaction]
			end
		elseif UnitIsBossMob(self.unit) then
			color = C.db.global.colors.yellow
			border = "Interface\\AddOns\\ls_UI\\assets\\border-thick-elite"
			glow = "Interface\\AddOns\\ls_UI\\assets\\border-thick-elite-glow"
		else
			local class = UnitClassification(self.unit)
			if class then
				if class == "elite" then
					color = C.db.global.colors.yellow
					border = "Interface\\AddOns\\ls_UI\\assets\\border-thick-rare"
					glow = "Interface\\AddOns\\ls_UI\\assets\\border-thick-rare-glow"
				elseif class == "rareelite" then
					color = C.db.global.colors.light_blue
					border = "Interface\\AddOns\\ls_UI\\assets\\border-thick-elite"
					glow = "Interface\\AddOns\\ls_UI\\assets\\border-thick-elite-glow"
				elseif class == "rare" then
					color = C.db.global.colors.light_blue
					border = "Interface\\AddOns\\ls_UI\\assets\\border-thick-rare"
					glow = "Interface\\AddOns\\ls_UI\\assets\\border-thick-rare-glow"
				elseif class ~= "worldboss" and element._config.color.reaction then
					local reaction = UnitReaction(self.unit, "player") or 4
					color = C.db.global.colors.reaction[reaction]
				end
			end
		end
	end

	if not element.__color or not element.__color:IsEqualTo(color) then
		self.Border:SetVertexColor(color:GetRGB())

		if self.Insets then
			self.Insets:SetVertexColor(color:GetRGB())
		end

		element.__color = color
	end

	if not element.__texture or element.__texture ~= border then
		self.Border:SetTexture(border)

		if self.ThreatIndicator then
			self.ThreatIndicator:SetTexture(glow)
		end

		element.__texture = border
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
	}, element_proto)
end
