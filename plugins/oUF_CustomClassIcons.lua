--[[
Temp plug-in
Modded version of original classicons module by haste, includes changes from my pull request
I’ll keep it until my patch is merged into master branch or gets rejected.
]]

local __, ns = ...
local oUF = ns.oUF or oUF

local PlayerClass = select(2, UnitClass'player')

local ClassPowerType, ClassPowerTypes
local ClassPowerEnable, ClassPowerDisable
local RequireSpell

local PALADIN_WORD_OF_GLORY = 85673
local PRIEST_SHADOW_ORBS = 95740

local UpdateTexture = function(element)
	local red, green, blue, desaturated
	if(PlayerClass == 'MONK') then
		red, green, blue = 0, 1, .59
		desaturated = true
	elseif(PlayerClass == 'WARLOCK') then
		red, green, blue = 1, .5, 1
		desaturated = true
	elseif(PlayerClass == 'PRIEST') then
		red, green, blue = 1, 1, 1
	elseif(PlayerClass == 'PALADIN') then
		red, green, blue = 1, .96, .41
		desaturated = true
	end

	for i=1, 5 do
		if(element[i].SetDesaturated) then
			element[i]:SetDesaturated(desaturated)
		end

		element[i]:SetVertexColor(red, green, blue)
	end
end

local ToggleVehicle = function(self, state)
	local element = self.CustomClassIcons
	for i=1, 5 do
		element[i]:Hide()
	end

	(element.UpdateTexture or UpdateTexture) (element)

	if(state) then
		ClassPowerDisable(self)
	else
		ClassPowerEnable(self)
	end
end

local Update = function(self, event, unit, powerType)
	local element = self.CustomClassIcons
	local hasVehicle = UnitHasVehicleUI('player')
	if(element.__inVehicle ~= hasVehicle) then
		element.__inVehicle = hasVehicle
		ToggleVehicle(self, hasVehicle)

		if(hasVehicle) then return end
	end

	if((unit and unit ~= 'player') or (powerType and not ClassPowerTypes[powerType])) then
		return
	end

	if(element.PreUpdate) then
		element:PreUpdate()
	end

	local cur = UnitPower('player', ClassPowerType)
	local max = UnitPowerMax('player', ClassPowerType)

	local oldMax = element.__max
	if event ~= "UpdateVisibilityOnDisable" then
		for i=1, max do
			if(i <= cur) then
				element[i]:Show()
			else
				element[i]:Hide()
			end
		end

		if(max ~= element.__max) then
			if(max < element.__max) then
				for i=max + 1, element.__max do
					element[i]:Hide()
				end
			end

			element.__max = max
		end
	else
		cur, max = 0, 0
	end

	if(element.PostUpdate) then
		return element:PostUpdate(cur, max, oldMax ~= max)
	end
end

local Path = function(self, ...)
	return (self.CustomClassIcons.Override or Update) (self, ...)
end


local Visibility = function(self, event, unit)
	local element = self.CustomClassIcons
	if(RequireSpell and not IsPlayerSpell(RequireSpell)) then
		for i=1, 5 do
			element[i]:Hide()
		end
		ClassPowerDisable(self)
		return Path(self, 'UpdateVisibilityOnDisable')
	else
		ClassPowerEnable(self)
		return Path(self, 'UpdateVisibilityOnEnable')
	end
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

do
	ClassPowerEnable = function(self)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Update)
		self:RegisterEvent('UNIT_POWER_FREQUENT', Update)
	end

	ClassPowerDisable = function(self)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Update)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Update)
	end

	if(PlayerClass == 'MONK') then
		ClassPowerType = SPELL_POWER_CHI
		ClassPowerTypes = {
			['CHI'] = true,
			['DARK_FORCE'] = true,
		}
	elseif(PlayerClass == 'PALADIN') then
		ClassPowerType = SPELL_POWER_HOLY_POWER
		ClassPowerTypes = {
			HOLY_POWER = true,
		}
		RequireSpell = PALADIN_WORD_OF_GLORY
	elseif(PlayerClass == 'PRIEST') then
		ClassPowerType = SPELL_POWER_SHADOW_ORBS
		ClassPowerTypes = {
			SHADOW_ORBS = true,
		}
		RequireSpell = PRIEST_SHADOW_ORBS
	elseif(PlayerClass == 'WARLOCK') then
		ClassPowerType = SPELL_POWER_SOUL_SHARDS
		ClassPowerTypes = {
			SOUL_SHARDS = true,
		}
		RequireSpell = WARLOCK_SOULBURN
	end
end

local Enable = function(self, unit)
	local element = self.CustomClassIcons
	if(not element) then return end

	element.__owner = self
	element.__max = 0
	element.ForceUpdate = ForceUpdate

	if(RequireSpell) then
		self:RegisterEvent('SPELLS_CHANGED', Visibility)
	end

	for i=1, 5 do
		local icon = element[i]
		if(icon:IsObjectType'Texture' and not icon:GetTexture()) then
			icon:SetTexCoord(0.45703125, 0.60546875, 0.44531250, 0.73437500)
			icon:SetTexture([[Interface\PlayerFrame\Priest-ShadowUI]])
		end
	end

	(element.UpdateTexture or UpdateTexture) (element)

	return true
end

local Disable = function(self)
	local element = self.CustomClassIcons
	if(not element) then return end

	if(RequireSpell) then
		self:UnregisterEvent('SPELLS_CHANGED', Visibility)
	end
end

oUF:AddElement('CustomClassIcons', Update, Enable, Disable)