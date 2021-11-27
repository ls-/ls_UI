local _, ns = ...
local E, C, PrC, M, L, P = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P
local MODULE = P:GetModule("Bars")

-- Lua
local _G = getfenv(0)

function MODULE.CleanUp()
	E:ForceHide(MainMenuBarArtFrame, true)
	E:ForceHide(MultiBarBottomLeft)
	E:ForceHide(MultiBarBottomRight)
	E:ForceHide(MultiBarLeft)
	E:ForceHide(MultiBarRight)

	E:ForceHide(PetActionBarFrame)
	E:ForceHide(PossessBarFrame)
	E:ForceHide(StanceBarFrame)

	E:ForceHide(MainMenuExpBar)
	E:ForceHide(MainMenuBarMaxLevelBar)
	E:ForceHide(ReputationWatchBar)
	E:ForceHide(ArtifactWatchBar)
	E:ForceHide(HonorWatchBar)

	StatusTrackingBarManager:Hide()

	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetScript("OnShow", function()
		UpdateMicroButtonsParent(MicroButtonAndBagsBar)
		MoveMicroButtons("BOTTOMLEFT", MicroButtonAndBagsBar, "BOTTOMLEFT", 6, 3, false)
	end)

	UpdateMicroButtonsParent(MicroButtonAndBagsBar)

	E:ForceHide(SpellFlyoutBackgroundEnd)
	E:ForceHide(SpellFlyoutHorizontalBackground)
	E:ForceHide(SpellFlyoutVerticalBackground)

	E:ForceHide(MainMenuBarVehicleLeaveButton)
end
