local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G

-- Mine
local function CommandBar_OnEnter(self)
	if not self.isShown then
		self.isShown = true
		self:SetPoint("TOP", 0, 0)
	end
end

local function CommandBar_OnLeave(self)
	if not self:IsMouseOver(4, 0, -4, 4) then
		self.isShown = false
		self:SetPoint("TOP", 0, 22)
	end
end

local function SubFrame_OnEnter(self)
	local bar = self:GetParent()

	if not bar.isShown then
		CommandBar_OnEnter(bar)
	end
end
local function SubFrame_OnLeave(self)
	local bar = self:GetParent()

	if bar.isShown then
		if not bar:IsMouseOver(4, 0, -4, 4) then
			CommandBar_OnLeave(bar)
		end
	end
end

function B:HandleCommandBar()
	if not _G.IsAddOnLoaded("Blizzard_OrderHallUI") then
		E:ForceLoadAddOn("Blizzard_OrderHallUI")
	end

	local bar = _G.OrderHallCommandBar

	bar:ClearAllPoints()
	bar:SetPoint("TOP", 0, 22)
	bar:SetPoint("LEFT", 0, 0)
	bar:SetPoint("RIGHT", 0, 0)
	bar:SetScript("OnEnter", CommandBar_OnEnter)
	bar:SetScript("OnLeave", CommandBar_OnLeave)

	bar.CurrencyHitTest:HookScript("OnEnter", SubFrame_OnEnter)
	bar.CurrencyHitTest:HookScript("OnLeave", SubFrame_OnLeave)

	bar.WorldMapButton:HookScript("OnEnter", SubFrame_OnEnter)
	bar.WorldMapButton:HookScript("OnLeave", SubFrame_OnLeave)
end
