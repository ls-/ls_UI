local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF Debuff Highlight was unable to locate oUF install")

local _, PlayerClass = UnitClass("player")

local DISPELTYPES = {
	PALADIN = {Magic = false, Disease = false, Poison = false},
	SHAMAN = {Magic = false, Curse = false},
	DRUID = {Magic = false, Curse = false, Poison = false},
	PRIEST = {Magic = false, Disease = false},
	MONK = {Magic = false, Disease = false, Poison = false},
	MAGE = {Curse = false},
}

local CanDispel = DISPELTYPES[PlayerClass]
local OriginalColors = {}
local DebuffTypeColor = DebuffTypeColor

local function GetDebuffType(unit, filter)
	if not UnitCanAssist("player", unit) then return nil end

	local i = 1
	local name, debuffType
	while true do
		name, _, _, _, debuffType = UnitAura(unit, i, "HARMFUL")

		if not name then break end

		if debuffType and not filter or (filter and CanDispel[debuffType]) then
			return debuffType, DebuffTypeColor[debuffType]
		end

		i = i + 1
	end
end

local function CheckDispelTypes(self, event)
	for k, v in pairs(CanDispel) do
		CanDispel[k] = false
	end

	if PlayerClass == "PALADIN" then
		if IsPlayerSpell(4987) then -- Cleanse
			CanDispel.Poison = true
			CanDispel.Disease = true

			if IsPlayerSpell(53551) then -- Sacred Cleansing
				CanDispel.Magic = true
			end
		end
	elseif PlayerClass == "SHAMAN" then
		if IsPlayerSpell(51886) then -- Cleanse Spirit
			CanDispel.Curse = true
		elseif IsPlayerSpell(77130) then -- Purify Spirit
			CanDispel.Curse = true
			CanDispel.Magic = true
		end
	elseif PlayerClass == "DRUID" then
		if IsPlayerSpell(2782) then -- Remove Corruption
			CanDispel.Curse = true
			CanDispel.Poison = true
		elseif IsPlayerSpell(88423) then -- Nature's Cure
			CanDispel.Magic = true
			CanDispel.Curse = true
			CanDispel.Poison = true
		end
	elseif PlayerClass == "PRIEST"  then
		if IsPlayerSpell(527) then -- Purify
			CanDispel.Magic = true
			CanDispel.Disease = true
		elseif IsPlayerSpell(32375) then -- Mass Dispel
			if IsPlayerSpell(55691) then						 
				CanDispel.Magic = true
			end

			CanDispel.Disease = false
		end
	elseif PlayerClass == "MONK" then
		if IsPlayerSpell(115450) then -- Detox
			CanDispel.Poison = true
			CanDispel.Disease = true

			if IsPlayerSpell(115451) then -- Internal Medicine
				CanDispel.Magic = true
			end
		elseif IsPlayerSpell(115310) then -- Revival
			CanDispel.Poison = true
			CanDispel.Disease = true
			CanDispel.Magic = true
		end
	elseif PlayerClass == "MAGE" then
		if IsPlayerSpell(475) then -- Remove Curse
			CanDispel.Curse = true
		end
	end
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end

	local dbh = self.DebuffHighlight
	local debuffType, color = GetDebuffType(unit, dbh.Filter)

	if debuffType then
		dbh:SetVertexColor(color.r, color.g, color.b, dbh.Alpha or .5)
	else
		color = OriginalColors[self]
		dbh:SetVertexColor(color.r, color.g, color.b, color.a)
	end
end

local function Path(self, ...)
	return (self.DebuffHighlight.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local dbh = self.DebuffHighlight

	if not dbh then return end

	if dbh.Filter and not DISPELTYPES[PlayerClass] then
		return
	end

	if dbh:IsObjectType("Texture") and not dbh:GetTexture() then
		print("No texture is set for debuff highlight. DBH is disabled for ", self:GetName())
	end

	dbh.__owner = self
	dbh.ForceUpdate = ForceUpdate

	self:RegisterEvent("UNIT_AURA", Path)
	self:RegisterEvent("SPELLS_CHANGED", CheckDispelTypes)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckDispelTypes)

	local r, g, b, a = dbh:GetVertexColor()
	OriginalColors[self] = {r = r, g = g, b = b, a = a}

	return true
end

local function Disable(self)
	local dbh = self.DebuffHighlight

	if not dbh then return end

	self:UnregisterEvent("UNIT_AURA", Path)
	self:UnregisterEvent("SPELLS_CHANGED", CheckDispelTypes)
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckDispelTypes)
end

oUF:AddElement('DebuffHighlight', Path, Enable, Disable)
