local _, ns = ...
local E, C, M, L, P = ns.E, ns.C, ns.M, ns.L, ns.P
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
	MainMenuBar:SetSize(0.001, 0.001)

	E:ForceHide(SpellFlyoutBackgroundEnd)
	E:ForceHide(SpellFlyoutHorizontalBackground)
	E:ForceHide(SpellFlyoutVerticalBackground)
end
