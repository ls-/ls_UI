if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local __, ns = ...
local oUF = ns.oUF or oUF

local SPEC_WARLOCK_DEMONOLOGY = SPEC_WARLOCK_DEMONOLOGY
local WARLOCK_METAMORPHOSIS = WARLOCK_METAMORPHOSIS
local SPELL_POWER_DEMONIC_FURY = SPELL_POWER_DEMONIC_FURY
local DEMONIC_FURY = DEMONIC_FURY

oUF.colors.fury = {
	full	= { 0, 1, 0.1 },
	normal	= { 0.9, 0.1, 0.75 },
 }

local function Update(self, event, unit, powerType)
	local fury = self.DemonicFury

	if(unit and unit ~= "player") or (powerType and powerType ~= "DEMONIC_FURY") or (GetSpecialization() ~= SPEC_WARLOCK_DEMONOLOGY and event ~= "UpdateVisibilityOnDisable") then
		return
	end

	local cur = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
	local max = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)

	if event ~= "UpdateVisibilityOnDisable" then
		fury:SetValue(cur)
	end

	if fury.PostUpdate then
		return fury:PostUpdate(cur, max)
	end
end

local function Path(self, ...)
	return (self.DemonicFury.Override or Update) (self, ...)
end

local function MetamorphosisCheck(self)
	local fury = self.DemonicFury
	local activated = false
	for i = 1, 40 do
		local name, _, _, _, _, _, _, _, _, _, spell = UnitBuff("player", i)
		if spell == WARLOCK_METAMORPHOSIS then
			activated = true
			break
		end
		if not spell then
			break
		end
	end

	if activated and not fury.__activated then
		local r, g, b = unpack(fury.colors and fury.colors.full or oUF.colors.fury.full)
		fury:SetStatusBarColor(r, g, b)
		if fury.bg then
			local mp = fury.bg.multiplier or 0.25
			fury.bg:SetVertexColor(r * mp, g * mp, b * mp)
		end
		fury.__activated = true
	elseif not activated and fury.__activated then
		local r, g, b = unpack(fury.colors and fury.colors.normal or oUF.colors.fury.normal)
		fury:SetStatusBarColor(r, g, b)
		if fury.bg then
			local mp = fury.bg.multiplier or 0.25
			fury.bg:SetVertexColor(r * mp, g * mp, b * mp)
		end
		fury.__activated = nil
	end
end

local function Visibility(self, event, unit)
	local fury = self.DemonicFury
	local hasVehicle = UnitHasVehicleUI("player")
	if hasVehicle == false then
		if GetSpecialization() ~= SPEC_WARLOCK_DEMONOLOGY then
			if fury.__enabled ~= false then
				fury:Hide()
				fury.__activated = nil
				self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
				self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
				fury.__enabled = false
				return Path(self, "UpdateVisibilityOnDisable")
			end
		else
			if fury.__enabled ~= true then
				if not fury:IsShown() then
					fury:Show()
				end
				fury.__activated = true
				MetamorphosisCheck(self)
				self:RegisterEvent("UNIT_DISPLAYPOWER", Path)
				self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
				fury.__enabled = true
				return Path(self, "UpdateVisibilityOnEnbale")
			end
		end
	else
		if fury.__enabled ~= false then
			fury:Hide()
			fury.__activated = nil
			self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
			self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
			fury.__enabled = false
			return Path(self, "UpdateVisibilityOnDisable")
		end
	end
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local fury = self.DemonicFury
	if not fury then return end
	fury.__owner = self
	fury.__activated = nil
	fury.__enabled = nil
	fury.__hasVehicle = false
	fury.ForceUpdate = ForceUpdate

	self:RegisterEvent("UNIT_AURA", MetamorphosisCheck)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", Visibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", Visibility)

	Visibility(self)

	if fury:IsObjectType("StatusBar") then
		if not fury:GetStatusBarTexture()  then
			fury:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		end
		fury:SetMinMaxValues(0, 1000)
		fury:SetValue(0)
	end
	return true
end

local function Disable(self)
	local fury = self.DemonicFury

	if not fury then return end

	self:UnregisterEvent("UNIT_AURA", MetamorphosisCheck)
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE", Visibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", Visibility)
	self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
	self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
end

oUF:AddElement("DemonicFury", Path, Enable, Disable)
