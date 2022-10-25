local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)
local hooksecurefunc = _G.hooksecurefunc

local isNPEHooked = false

local function disableNPE()
	if NewPlayerExperience then
		if NewPlayerExperience:GetIsActive() then
			NewPlayerExperience:Shutdown()
		end

		if not isNPEHooked then
			hooksecurefunc(NewPlayerExperience, "Begin", disableNPE)
			isNPEHooked = true
		end
	end
end

function MODULE:CleanUp()
	E:ForceHide(MainMenuBar, true)
	E:ForceHide(MultiBarBottomLeft)
	E:ForceHide(MultiBarBottomRight)
	E:ForceHide(MultiBarLeft)
	E:ForceHide(MultiBarRight)
	E:ForceHide(MultiBar5)
	E:ForceHide(MultiBar6)
	E:ForceHide(MultiBar7)

	E:ForceHide(PetActionBar)
	E:ForceHide(PossessActionBar)
	E:ForceHide(StanceBar)
	E:ForceHide(MultiCastActionBarFrame)

	E:ForceHide(StatusTrackingBarManager)

	if NewPlayerExperience then
		disableNPE()
	else
		E:AddOnLoadTask("Blizzard_NewPlayerExperience", disableNPE)
	end

	E:ForceHide(MicroButtonAndBagsBar)

	QueueStatusButton:SetParent(UIParent)
	QueueStatusButton:ClearAllPoints()
	QueueStatusButton:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -216, 4)
	E.Movers:Create(QueueStatusButton)

	E:ForceHide(SpellFlyout.Background)

	E:ForceHide(MainMenuBarVehicleLeaveButton)

	E:ForceHide(ExtraAbilityContainer)
	ExtraAbilityContainer:SetScript("OnShow", nil)
	ExtraAbilityContainer:SetScript("OnHide", nil)
end
