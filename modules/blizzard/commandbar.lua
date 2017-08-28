local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Blizz
local IsAddOnLoaded = _G.IsAddOnLoaded
local LoadAddOn = _G.LoadAddOn

-- Mine
local isInit = false

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
			OrderHallCommandBar:SetHitRectInsets(0, 0, 0, -8)
			OrderHallCommandBar:SetScript("OnEnter", function(self)
				if not self.isShown then
					self.isShown = true
					self:SetPoint("TOP", 0, 1)
				end
			end
			)
			OrderHallCommandBar:SetScript("OnLeave", function(self)
				if not self:IsMouseOver(0, -6, 0, 0) then
					self.isShown = false
					self:SetPoint("TOP", 0, 23)
				end
			end)

			E:ForceHide(OrderHallCommandBar.WorldMapButton)

			isInit = true
		end
	end
end
