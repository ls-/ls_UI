local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Experience was unable to locate oUF install')

for tag, func in next, {
	['curxp'] = function(unit)
		return UnitXP(unit)
	end,
	['maxxp'] = function(unit)
		return UnitXPMax(unit)
	end,
	['perxp'] = function(unit)
		return math.floor(UnitXP(unit) / UnitXPMax(unit) * 100 + 0.5)
	end,
	['currested'] = function()
		return GetXPExhaustion()
	end,
	['perrested'] = function(unit)
		local rested = GetXPExhaustion()
		if(rested and rested > 0) then
			return math.floor(rested / UnitXPMax(unit) * 100 + 0.5)
		end
	end,
} do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP UPDATE_EXHAUSTION'
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.Experience
	if(element.PreUpdate) then element:PreUpdate(unit) end

	if(UnitLevel(unit) == element.__max or UnitHasVehicleUI('player') or C_PetBattles.IsInBattle()) then
		element:Hide()
	else
		element:Show()
	end

	local cur = UnitXP(unit)
	local max = UnitXPMax(unit)

	element:SetMinMaxValues(0, max)
	element:SetValue(cur)

	if(element.Rested) then
		local exhaustion = GetXPExhaustion() or 0
		element.Rested:SetMinMaxValues(0, max)
		element.Rested:SetValue(math.min(cur + exhaustion, max))
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, cur, max)
	end
end

local function Path(self, ...)
	return (self.Experience.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Experience
	if(element and unit == 'player') then
		element.__owner = self
		element.__max = (IsTrialAccount() and GetRestrictedAccountData or GetMaxPlayerLevel)()

		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_XP_UPDATE', Path)
		self:RegisterEvent('PLAYER_LEVEL_UP', Path)
		self:RegisterEvent('PET_BATTLE_OPENING_START', Path)
		self:RegisterEvent('PET_BATTLE_CLOSE', Path)

		local child = element.Rested
		if(child) then
			self:RegisterEvent('UPDATE_EXHAUSTION', Path)
			child:SetFrameLevel(element:GetFrameLevel() - 1)

			if(not child:GetStatusBarTexture()) then
				child:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end
		end

		if(not element:GetStatusBarTexture()) then
			element:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		end

		return true
	end
end

local function Disable(self)
	local element = self.Experience
	if(element) then
		self:UnregisterEvent('PLAYER_XP_UPDATE', Path)
		self:UnregisterEvent('PLAYER_LEVEL_UP', Path)
		self:UnregisterEvent('PET_BATTLE_OPENING_START', Path)
		self:UnregisterEvent('PET_BATTLE_CLOSE', Path)

		if(element.Rested) then
			self:UnregisterEvent('UPDATE_EXHAUSTION', Path)
		end
	end
end

oUF:AddElement('Experience', Path, Enable, Disable)
