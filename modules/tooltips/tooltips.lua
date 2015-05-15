local _, ns = ...
local E, C, M = ns.E, ns.C, ns.M

E.TT = {}

local TT = E.TT

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local find = strfind

local function AuraTooltipHook(self, unit, index, filter)
	local caster, _, _, id = select(8, UnitAura(unit, index, filter))

	if not id then return end

	self:AddLine(" ")

	if caster then
		local name = UnitName(caster)
		local _, class = UnitClass(caster)
		local color = RAID_CLASS_COLORS[class]

		self:AddDoubleLine("|cffffd100"..ID..":|r "..id, name, 1, 1 , 1, color.r, color.g, color.b)
	else
		self:AddLine("|cffffd100"..ID..":|r "..id, 1, 1, 1)
	end

	self:Show()
end

local function ItemTooltipHook(self)
	local item, link = self:GetItem()

	if not link then return end

	local total = GetItemCount(item, true)
	local _, _, id = find(link, "item:(%d+)")

	local line
	for i = 1, self:NumLines() do
		if find(_G["GameTooltipTextLeft"..i]:GetText(), "|cffffd100"..ID..":|r "..id) then
			return
		end
	end

	self:AddLine(" ")
	self:AddDoubleLine("|cffffd100"..ID..":|r "..id, "|cffffd100"..TOTAL..":|r "..total, 1, 1, 1, 1, 1, 1)
	self:Show()
end

local function SpellTooltipHook(self)
	local _, _, id = self:GetSpell()

	if not id then return end

	local line
	for i = 1, self:NumLines() do
		if find(_G["GameTooltipTextLeft"..i]:GetText(), "|cffffd100"..ID..":|r "..id) then
			return
		end
	end

	self:AddLine(" ")
	self:AddLine("|cffffd100"..ID..":|r "..id, 1, 1, 1)
	self:Show()
end

local function AddTooltipStatusBar(self, num)
	local bar
	for i = 1, num do
		bar = CreateFrame("StatusBar", "GameTooltipStatusBar"..i, self, "TooltipStatusBarTemplate")
		bar:SetStatusBarColor(0.15, 0.65, 0.15)
		E:HandleStatusBar(bar, nil, 12)
		bar.Text:SetFont(M.font, 10)
	end

	self.numStatusBars, self.shownStatusBars = num, 0
end

function TT:Initialize()
	hooksecurefunc(GameTooltip, "SetUnitAura", AuraTooltipHook)
	hooksecurefunc(GameTooltip, "SetUnitBuff", AuraTooltipHook)
	hooksecurefunc(GameTooltip, "SetUnitDebuff", AuraTooltipHook)

	GameTooltip:HookScript("OnTooltipSetItem", ItemTooltipHook)
	GameTooltip:HookScript("OnTooltipSetSpell", SpellTooltipHook)

	AddTooltipStatusBar(GameTooltip, 6)
end
