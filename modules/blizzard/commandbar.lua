local _, ns = ...
local E = ns.E
local B = E:GetModule("Blizzard")

-- Lua
local _G = _G

-- Mine
local function CommandBar_OnEnter(self)
	if not self.isShown then
		self.isShown = true
		self:SetPoint("TOP", 0, 1)
	end
end

local function CommandBar_OnLeave(self)
	if not self:IsMouseOver(0, -6, 0, 0) then
		self.isShown = false
		self:SetPoint("TOP", 0, 23)
	end
end

function B:HandleCommandBar()
	local isLoaded = true

	if not _G.IsAddOnLoaded("Blizzard_OrderHallUI") then
		isLoaded = _G.LoadAddOn("Blizzard_OrderHallUI")
	end

	if isLoaded then
		_G.OrderHallCommandBar:ClearAllPoints()
		_G.OrderHallCommandBar:SetPoint("TOP", 0, 23)
		_G.OrderHallCommandBar:SetPoint("LEFT", 0, 0)
		_G.OrderHallCommandBar:SetPoint("RIGHT", 0, 0)
		_G.OrderHallCommandBar:SetHitRectInsets(0, 0, 0, -8)
		_G.OrderHallCommandBar:SetScript("OnEnter", CommandBar_OnEnter)
		_G.OrderHallCommandBar:SetScript("OnLeave", CommandBar_OnLeave)

		E:ForceHide(_G.OrderHallCommandBar.WorldMapButton)
	end
end
