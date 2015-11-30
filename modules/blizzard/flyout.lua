local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:GetModule("Blizzard")

local function FlyoutButtonToggleHook(...)
	local self, flyoutID = ...

	if not self:IsShown() then return end

	local _, _, numSlots = GetFlyoutInfo(flyoutID)
	for i = 1, numSlots do
		E:SkinActionButton(_G["SpellFlyoutButton"..i])
	end
end

function B:HandleSpellFlyout()
	hooksecurefunc(SpellFlyout, "Toggle", FlyoutButtonToggleHook)
end
