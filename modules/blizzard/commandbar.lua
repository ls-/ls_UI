local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
local BLIZZARD = P:GetModule("Blizzard")

-- Lua
local _G = getfenv(0)

-- Mine
local isInit = false

function BLIZZARD:HasCommandBar()
	return isInit
end

function BLIZZARD:SetUpCommandBar()
	if C.db.char.blizzard.command_bar.enabled then
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
			_G.OrderHallCommandBar:SetScript("OnEnter", function(self)
				if not self.isShown then
					self.isShown = true
					self:SetPoint("TOP", 0, 1)
				end
			end
			)
			_G.OrderHallCommandBar:SetScript("OnLeave", function(self)
				if not self:IsMouseOver(0, -6, 0, 0) then
					self.isShown = false
					self:SetPoint("TOP", 0, 23)
				end
			end)

			E:ForceHide(_G.OrderHallCommandBar.WorldMapButton)

			isInit = true

			self.SetUpCommandBar = E.NOOP
		end
	end
end
