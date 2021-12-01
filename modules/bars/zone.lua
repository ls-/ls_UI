local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local t_insert = _G.table.insert
local t_wipe = _G.table.wipe

--[[ luacheck: globals
	CreateFrame UIParent UIPARENT_MANAGED_FRAME_POSITIONS ZoneAbilityFrame
]]

-- Mine
local isInit = false

function MODULE.CreateZoneButton()
	if not isInit then
		local bar = CreateFrame("Frame", "LSZoneAbilityBar", UIParent, "SecureHandlerStateTemplate")
		bar._id = "zone"
		bar._buttons = {}

		MODULE:AddBar("zone", bar)

		bar.Update = function(self)
			self:UpdateConfig()
			self:UpdateVisibility()
			self:UpdateCooldownConfig()
			self:UpdateFading()

			ZoneAbilityFrame:ClearAllPoints()
			ZoneAbilityFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
			ZoneAbilityFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)

			local width, height = ZoneAbilityFrame.SpellButtonContainer:GetSize()
			if width < 1 then
				local num = ZoneAbilityFrame.SpellButtonContainer.contentFramePool.numActiveObjects
				num = num > 0 and num or 1
				local spacing = ZoneAbilityFrame.SpellButtonContainer.spacing
				width = height * num + spacing * (num - 1)
			end

			self:SetSize(width + 4, height + 4)
			E.Movers:Get(self):UpdateSize()
		end

		ZoneAbilityFrame.ignoreFramePositionManager = true
		UIPARENT_MANAGED_FRAME_POSITIONS["ZoneAbilityFrame"] = nil
		UIPARENT_MANAGED_FRAME_POSITIONS["ExtraAbilityContainer"] = nil

		ZoneAbilityFrame:EnableMouse(false)
		ZoneAbilityFrame:SetParent(bar)
		ZoneAbilityFrame.ignoreInLayout = true

		ZoneAbilityFrame.SetParent_ = ZoneAbilityFrame.SetParent
		hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
			if parent ~= bar then
				self:SetParent_(bar)
			end
		end)

		local num = 0
		hooksecurefunc(ZoneAbilityFrame, "UpdateDisplayedZoneAbilities", function(self)
			t_wipe(bar._buttons)

			for button in self.SpellButtonContainer:EnumerateActive() do
				E:SkinExtraActionButton(button)

				button._parent = bar
				t_insert(bar._buttons, button)
			end

			if #bar._buttons ~= num then
				bar:UpdateCooldownConfig()
				num = #bar._buttons
			end
		end)

		hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "SetSize", function(self)
			if not InCombatLockdown() then
				local width, height = self:GetSize()
				bar:SetSize(width + 4, height + 4)
				E.Movers:Get(bar):UpdateSize()
			end
		end)

		E:ForceHide(ZoneAbilityFrame.Style)

		local point = C.db.profile.bars.zone.point[E.UI_LAYOUT]
		bar:SetPoint(point.p, point.anchor, point.rP, point.x, point.y)
		E.Movers:Create(bar)

		bar:Update()

		isInit = true
	end
end
