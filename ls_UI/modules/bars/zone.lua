local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc
local t_insert = _G.table.insert
local t_wipe = _G.table.wipe
local unpack = _G.unpack

-- Mine
local isInit = false

local bar_proto = {}

function bar_proto:Update()
	self:UpdateConfig()
	self:UpdateVisibility()
	self:UpdateArtwork()
	self:UpdateCooldownConfig()
	self:UpdateFading()

	ZoneAbilityFrame:ClearAllPoints()
	ZoneAbilityFrame:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
	ZoneAbilityFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)

	local width, height = ZoneAbilityFrame.SpellButtonContainer:GetSize()
	if width < 1 then
		local num = ZoneAbilityFrame.SpellButtonContainer.contentFramePool:GetNumActive()
		num = num > 0 and num or 1
		local spacing = ZoneAbilityFrame.SpellButtonContainer.spacing
		width = height * num + spacing * (num - 1)
	end

	self:SetSize(width + 4, height + 4)
	self:SetScale(self._config.scale)

	local mover = E.Movers:Get(self)
	if mover then
		mover:UpdateSize()
	end
end

function bar_proto:UpdateArtwork()
	if self._config.artwork then
		ZoneAbilityFrame.Style:Show()
		ZoneAbilityFrame.Style:SetParent(ZoneAbilityFrame)
	else
		ZoneAbilityFrame.Style:Hide()
		ZoneAbilityFrame.Style:SetParent(E.HIDDEN_PARENT)
	end
end

function MODULE:CreateZoneButton()
	if not isInit then
		local bar = Mixin(self:Create("zone", "LSZoneAbilityBar"), bar_proto)

		ZoneAbilityFrame.ignoreFramePositionManager = true
		ZoneAbilityFrame.ignoreInLayout = true
		ZoneAbilityFrame:EnableMouse(false)
		ZoneAbilityFrame:SetParent(bar)

		hooksecurefunc(ZoneAbilityFrame, "SetParent", function(self, parent)
			if parent ~= bar then
				self:SetParent(bar)
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

		bar:SetPoint(unpack(C.db.profile.bars.zone.point))
		E.Movers:Create(bar)

		bar:Update()

		isInit = true
	end
end
