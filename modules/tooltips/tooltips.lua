local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

E.TT = {}

local TT = E.TT

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local find = strfind

local function AuraTooltipHook(self, unit, index, filter)
	local caster, _, _, id = select(8, UnitAura(unit, index, filter))

	self:AddLine(" ")

	if caster then
		local name = UnitName(caster)
		local _, class = UnitClass(caster)
		local color = RAID_CLASS_COLORS[class]

		self:AddDoubleLine(ID..": "..id, name, 1, 1 , 1, color.r, color.g, color.b)
	else
		self:AddLine(ID..": "..id, 1, 1, 1)
	end

	self:Show()
end

local function ItemTooltipHook(self)
	local item, link = self:GetItem()
	local total = GetItemCount(item, true)
	local _, _, id = find(link, "item:(%d+)")

	self:AddLine(" ")
	self:AddDoubleLine(ID..": "..id, TOTAL..": "..total, 1, 1, 1, 1, 1, 1)
	self:Show()
end

local function SpellTooltipHook(self)
	local _, _, id = self:GetSpell()

	local line
	for i = 1, self:NumLines() do
		if find(_G["GameTooltipTextLeft"..i]:GetText(), ID..": "..id) then
			return
		end
	end

	self:AddLine(" ")
	self:AddLine(ID..": "..id, 1, 1, 1)
	self:Show()
end

function TT:Initialize()
	hooksecurefunc(GameTooltip, "SetUnitAura", AuraTooltipHook)
	hooksecurefunc(GameTooltip, "SetUnitBuff", AuraTooltipHook)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", AuraTooltipHook)

	GameTooltip:HookScript("OnTooltipSetItem", ItemTooltipHook)
	GameTooltip:HookScript("OnTooltipSetSpell", SpellTooltipHook)
end
