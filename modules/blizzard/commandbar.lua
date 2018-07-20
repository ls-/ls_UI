local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

--[[ luacheck: globals
	IsAddOnLoaded LoadAddOn OrderHallCommandBar
]]

-- Mine
local isInit = false

local function bar_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed > 0.032 then
		if self:IsMouseOver(0, -4, 0, 0) then
			self:SetPoint("TOP", 0, 1)
		else
			self:SetPoint("TOP", 0, 23)
		end

		self.elapsed = 0
	end
end

function MODULE.HasCommandBar()
	return isInit
end

function MODULE.SetUpCommandBar()
	if not isInit and C.db.char.blizzard.command_bar.enabled then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_OrderHallUI") then
			isLoaded = LoadAddOn("Blizzard_OrderHallUI")
		end

		if isLoaded then
			OrderHallCommandBar:ClearAllPoints()
			OrderHallCommandBar:SetPoint("TOP", 0, 23)
			OrderHallCommandBar:SetPoint("LEFT", 0, 0)
			OrderHallCommandBar:SetPoint("RIGHT", 0, 0)
			OrderHallCommandBar:HookScript("OnShow", function(self)
				self:SetScript("OnUpdate", bar_OnUpdate)
			end)
			OrderHallCommandBar:HookScript("OnHide", function(self)
				self:SetScript("OnUpdate", nil)
				self:SetPoint("TOP", 0, 23)
			end)

			E:ForceHide(OrderHallCommandBar.WorldMapButton)

			isInit = true
		end
	end
end
