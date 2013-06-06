if select(2, UnitClass("player")) ~= "WARLOCK" then return end

local __, ns = ...
local oUF = ns.oUF or oUF

local WARLOCK_SOULBURN = WARLOCK_SOULBURN
local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
local SOUL_SHARDS = SOUL_SHARDS

oUF.colors.shards = { 
	normal	= { 0.4, 0.28, 0.76 },
	full	= { 1, 0.1, 0.15 },
 }

local function Update(self, event, unit, powerType)
	local shards = self.SoulShards

	if(unit and unit ~= "player") or (powerType and powerType ~= "SOUL_SHARDS") or ((GetSpecialization() ~= SPEC_WARLOCK_AFFLICTION or not IsPlayerSpell(WARLOCK_SOULBURN)) and event ~= "UpdateVisibilityOnDisable") then
		return
	end

	local cur = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	local max = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)

	if event ~= "UpdateVisibilityOnDisable" then
		local oldMax = shards.__max
		if max ~= shards.__max  then
			if max < shards.__max then
				shards[shards.__max]:Hide()
			else
				shards[max]:Show()
			end
			shards.__max = max
		end

		for i = 1, max do
			if i <= cur then
				shards[i]:Show()
			else
				shards[i]:Hide()
			end
			if cur == max then
				local r, g, b = unpack(shards.colors and shards.colors.full or oUF.colors.shards.full)
				shards[i]:SetVertexColor(r, g, b)
				if shards[i].bg then
					local mp = shards[i].bg.multiplier or 0.25
					shards[i].bg:SetVertexColor(r * mp, g * mp, b * mp)
				end
			else
				local r, g, b = unpack(shards.colors and shards.colors.normal or oUF.colors.shards.normal)
				shards[i]:SetVertexColor(r, g, b)
				if shards[i].bg then
					local mp = shards[i].bg.multiplier or 0.25
					shards[i].bg:SetVertexColor(r * mp, g * mp, b * mp)
				end
			end
		end
	end

	if shards.PostUpdate then
		return shards:PostUpdate(cur, max, oldMax ~= max)
	end
end

local function Path(self, ...)
	return (self.SoulShards.Override or Update) (self, ...)
end

local function Visibility(self, event, unit)
	local elements = self.SoulShards
	local hasVehicle = UnitHasVehicleUI("player")
	if hasVehicle == false then
		if GetSpecialization() ~= SPEC_WARLOCK_AFFLICTION or not IsPlayerSpell(WARLOCK_SOULBURN) then
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
	local shards = self.SoulShards
	if not shards then return end
	shards.__owner = self
	shards.__max = 0
	shards.__enabled = nil
	shards.__hasVehicle = false
	shards.ForceUpdate = ForceUpdate

	self:RegisterEvent("SPELLS_CHANGED", Visibility)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", Visibility)
	self:RegisterEvent("UNIT_EXITED_VEHICLE", Visibility)

	for index = 1, 4 do
		local shard = shards[index]
		if shard:IsObjectType("Texture") and not shard:GetTexture() then
			shard:SetTexCoord(0.45703125, 0.60546875, 0.44531250, 0.73437500)
			shard:SetTexture([[Interface\PlayerFrame\Priest-ShadowUI]])
		end
	end
	return true
end

local function Disable(self)
	local shards = self.SoulShards

	if not shards then return end

	self:UnregisterEvent("SPELLS_CHANGED", Visibility)
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE", Visibility)
	self:UnregisterEvent("UNIT_EXITED_VEHICLE", Visibility)
	self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
	self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
end

oUF:AddElement("SoulShards", Path, Enable, Disable)