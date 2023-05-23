local _, ns = ...
local E, C, PrC, M, L, P, D, PrD, oUF, Profiler = ns.E, ns.C, ns.PrC, ns.M, ns.L, ns.P, ns.D, ns.PrD, ns.oUF, ns.Profiler
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

local function hideBar(object, skipEvents)
	if not object then return end

	E:ForceHide(object, skipEvents)

	if object.system then
		E:PurgeKey(object, "isShownExternal")
	end
end

local function hidebutton(object)
	if not object then return end

	object:Hide(true)
	object:UnregisterAllEvents()
	object:SetAttribute("statehidden", true)
end

function MODULE:CleanUp()
	hideBar(MainMenuBar, true)
	hideBar(MultiBarBottomLeft)
	hideBar(MultiBarBottomRight)
	hideBar(MultiBarLeft)
	hideBar(MultiBarRight)
	hideBar(MultiBar5)
	hideBar(MultiBar6)
	hideBar(MultiBar7)
	hideBar(PetActionBar)
	hideBar(StanceBar)
	hideBar(PossessActionBar)
	hideBar(MultiCastActionBarFrame)

	for i = 1, 12 do
		hidebutton(_G["ActionButton" .. i])
		hidebutton(_G["MultiBarBottomLeftButton" .. i])
		hidebutton(_G["MultiBarBottomRightButton" .. i])
		hidebutton(_G["MultiBarLeftButton" .. i])
		hidebutton(_G["MultiBarRightButton" .. i])
		hidebutton(_G["MultiBar5Button" .. i])
		hidebutton(_G["MultiBar6Button" .. i])
		hidebutton(_G["MultiBar7Button" .. i])
	end

	for i = 1, 10 do
		hidebutton(_G["PetActionButton" .. i])
		hidebutton(_G["StanceButton" .. i])
	end

	hideBar(StatusTrackingBarManager)

	if NewPlayerExperience then
		disableNPE()
	else
		E:AddOnLoadTask("Blizzard_NewPlayerExperience", disableNPE)
	end

	hideBar(MicroMenu)
	hideBar(MicroButtonAndBagsBar)

	QueueStatusButton:SetParent(UIParent)
	QueueStatusButton:ClearAllPoints()
	QueueStatusButton:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -216, 4)
	E.Movers:Create(QueueStatusButton)

	E:ForceHide(SpellFlyout.Background)

	hidebutton(MainMenuBarVehicleLeaveButton)

	hideBar(ExtraAbilityContainer)
	ExtraAbilityContainer:SetScript("OnShow", nil)
	ExtraAbilityContainer:SetScript("OnHide", nil)
end
