if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local __, ns = ...
local oUF = ns.oUF or oUF

local SPEC_WARLOCK_DESTRUCTION = SPEC_WARLOCK_DESTRUCTION
local WARLOCK_BURNING_EMBERS = WARLOCK_BURNING_EMBERS
local SPELL_POWER_BURNING_EMBERS = SPELL_POWER_BURNING_EMBERS
local MAX_POWER_PER_EMBER = MAX_POWER_PER_EMBER
local BURNING_EMBERS = BURNING_EMBERS

oUF.colors.embers = {0.9, 0.4, 0.1}

local function Update(self, event, unit, powerType)
	local embers = self.BurningEmbers

	if(unit and unit ~= "player") or (powerType and powerType ~= "BURNING_EMBERS") or ((GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION or not IsPlayerSpell(WARLOCK_BURNING_EMBERS)) and event ~= "UpdateVisibilityOnDisable") then
		return
	end

	local cur = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
	local max = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
	local full = floor(cur / MAX_POWER_PER_EMBER)
	local count = floor(max / MAX_POWER_PER_EMBER)

	if event ~= "UpdateVisibilityOnDisable" then
		if full ~= embers.__full  then
			for i = (full == 0 and 1 or full), 4 do
				embers[i]:SetValue(0)
			end
			embers.__full = full
		end

		if full > 0 then
			for i = 1, full do
				embers[i]:SetValue(MAX_POWER_PER_EMBER)
			end
			if full ~= count then
				local value = cur - full * MAX_POWER_PER_EMBER
				embers[full + 1]:SetValue(value)
			end
		else
			local value = cur - full * MAX_POWER_PER_EMBER
			embers[1]:SetValue(value)
		end

		for i = 1, count do
			embers[i]:SetStatusBarColor(unpack(embers.color or oUF.colors.embers))
			if embers[i].bg then
				local mp = embers[i].bg.multiplier or 0.25
				local r, g, b = embers[i]:GetStatusBarColor()
				embers[i].bg:SetVertexColor(r * mp, g * mp, b * mp)
			end

		end
	end

	if embers.PostUpdate then
		return embers:PostUpdate(full, count)
	end
end

local function Path(self, ...)
	return (self.BurningEmbers.Override or Update) (self, ...)
end

local function Visibility(self, event, unit)
	local elements = self.BurningEmbers
	local hasVehicle = UnitHasVehicleUI("player")
	if hasVehicle == false then
		if GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION or not IsPlayerSpell(WARLOCK_BURNING_EMBERS) then
			if elements.__enabled ~= false then
				for i = 1, 4 do
					elements[i]:Hide()
				end
				self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
				self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
				elements.__enabled = false
				return Path(self, "UpdateVisibilityOnDisable")
			end
		else
			if elements.__enabled ~= true then
				if not elements[1]:IsShown() then
					for i = 1, 4 do
						elements[i]:Show()
					end
				end
				self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
				self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
				elements.__enabled = true
				return Path(self, "UpdateVisibilityOnEnbale")
			end
		end
	else
		if elements.__enabled ~= false then
			for i = 1, 4 do
				elements[i]:Hide()
			end
			self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
			self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
			elements.__enabled = false
			return Path(self, "UpdateVisibilityOnDisable")
		end
	end
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local embers = self.BurningEmbers
	if not embers then return end
	embers.__owner = self
	embers.__full = 0
	embers.__enabled = nil
	embers.__hasVehicle = false
	embers.ForceUpdate = ForceUpdate

	self:RegisterEvent("SPELLS_CHANGED", Visibility)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", Visibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", Visibility)

	for index = 1, 4 do
		local ember = embers[index]
		if ember:IsObjectType("StatusBar") then
			if not ember:GetStatusBarTexture()  then
				ember:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
			end
			ember:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
			ember:SetValue(0)
		end
	end
	return true
end

local function Disable(self)
	local embers = self.BurningEmbers

	if not embers then return end

	self:UnregisterEvent("SPELLS_CHANGED", Visibility)
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE", Visibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", Visibility)
	self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
	self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
end

oUF:AddElement("BurningEmbers", Path, Enable, Disable)